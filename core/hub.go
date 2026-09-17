package main

import (
	"cmp"
	"context"
	"errors"
	"net"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"slices"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

var (
	logMu         sync.Mutex
	logSubscriber observable.Subscription[log.Event]
	logCancel     context.CancelFunc
)

const coreMemoryLimit = 96 * 1024 * 1024

func handleInitClash(params *InitParams) bool {
	debug.SetGCPercent(50)
	debug.SetMemoryLimit(coreMemoryLimit)
	startHealthCheckCadence()
	func() {
		configMu.Lock()
		defer configMu.Unlock()
		sdkVersion.Store(int32(params.Version))
		constant.SetHomeDir(params.HomeDir)
		initOwnership(params.HomeDir)
		isInit.Store(true)
	}()
	rcxEngineInstance.Start()
	return true
}

func handleStartListener() bool {
	configMu.Lock()
	defer configMu.Unlock()
	odometerInstance.NoteUp(time.Now(), takeOdoStartReason())
	isRunning.Store(true)
	updateListeners(currentConfig)
	syncTunUp()
	resolver.ResetConnection()
	return requestedTunError() == nil
}

func handleStopListener() bool {
	configMu.Lock()
	defer configMu.Unlock()
	odometerInstance.NoteDown(time.Now(), false)
	isRunning.Store(false)
	tunPaused.Store(false)
	stopListeners()
	resolver.ResetConnection()
	return true
}

func handlePauseTun() bool {
	if features.Android {
		return true
	}
	configMu.Lock()
	defer configMu.Unlock()
	// Only a stop clears the flag, so arming it while the listeners are down
	// would leave the next start without TUN.
	if !isRunning.Load() {
		return true
	}
	if tunPaused.Swap(true) {
		return true
	}
	updateListeners(currentConfig)
	syncTunUp()
	return true
}

func handleResumeTun() bool {
	if features.Android {
		return true
	}
	configMu.Lock()
	defer configMu.Unlock()
	if !tunPaused.Swap(false) {
		return true
	}
	updateListeners(currentConfig)
	syncTunUp()
	return requestedTunError() == nil
}

func handleSetUiActive(active bool) bool {
	uiActive.Store(active)
	return true
}

func handleGetIsInit() bool {
	return isInit.Load()
}

func handleForceGC() {
	log.Infoln("[APP] request force GC")
	tunnel.InvalidateAllProxies()
	runtime.GC()
	if features.Android {
		debug.FreeOSMemory()
	}
}

func handleShutdown() bool {
	odometerInstance.NoteDown(time.Now(), false)
	odometerInstance.Flush()
	stopHealthCheckCadence()
	handleStopLog()
	rcxEngineInstance.Stop()

	configMu.Lock()
	isRunning.Store(false)
	tunPaused.Store(false)
	stopListeners()
	updater.StopGeoUpdater()
	executor.Shutdown()
	currentConfig = nil
	tunRequested.Store(false)
	isInit.Store(false)
	configMu.Unlock()

	doctorReset()
	handleForceGC()
	return true
}

func handleValidateConfig(path string) string {
	buf, err := os.ReadFile(path)
	if err != nil {
		return err.Error()
	}
	if _, err = config.UnmarshalRawConfig(buf); err != nil {
		return err.Error()
	}
	return ""
}

// The host decides whether a parsed profile is worth keeping, so validation
// hands over the proxy servers it saw instead of only a yes/no.
func handleInspectConfig(path string) map[string]any {
	buf, err := os.ReadFile(path)
	if err != nil {
		return map[string]any{"error": err.Error()}
	}
	raw, err := config.UnmarshalRawConfig(buf)
	if err != nil {
		return map[string]any{"error": err.Error()}
	}
	servers := make([]any, 0, len(raw.Proxy))
	for _, proxy := range raw.Proxy {
		if server, ok := proxy["server"].(string); ok {
			servers = append(servers, server)
		}
	}
	return map[string]any{
		"servers":   servers,
		"providers": len(raw.ProxyProvider) > 0,
	}
}

const globalProxyName = "GLOBAL"

func isProxyGroupType(adapterType constant.AdapterType) bool {
	switch adapterType {
	case constant.Selector, constant.URLTest, constant.Fallback, constant.Relay, constant.LoadBalance:
		return true
	default:
		return false
	}
}

func proxyGroupNames(
	nameList []string,
	typeOf func(name string) (constant.AdapterType, bool),
) []string {
	hasGlobal := false
	names := make([]string, 0, len(nameList)+1)

	for _, name := range nameList {
		if name == globalProxyName {
			hasGlobal = true
		}
		adapterType, ok := typeOf(name)
		if !ok || !isProxyGroupType(adapterType) {
			continue
		}
		names = append(names, name)
	}

	if !hasGlobal {
		if adapterType, ok := typeOf(globalProxyName); ok && isProxyGroupType(adapterType) {
			names = append([]string{globalProxyName}, names...)
		}
	}

	return names
}

func handleGetProxies() ProxiesData {
	proxies := tunnel.AllProxies()

	allNames := proxyGroupNames(config.GetProxyNameList(), func(name string) (constant.AdapterType, bool) {
		p, ok := proxies[name]
		if !ok || p == nil {
			return 0, false
		}
		return p.Type(), true
	})

	return ProxiesData{
		All:     allNames,
		Proxies: proxies,
	}
}

const activeServerMaxDepth = 16

type ActiveServer struct {
	Group string `json:"group"`
	Name  string `json:"name"`
}

func activeServerForGroup(groupHint string, group outboundgroup.ProxyGroup) *ActiveServer {
	if group.Type() == constant.LoadBalance {
		return &ActiveServer{Group: groupHint, Name: group.Name()}
	}
	return nil
}

func proxyGroup(proxy constant.Proxy) (outboundgroup.ProxyGroup, bool) {
	if proxy == nil {
		return nil, false
	}
	group, ok := proxy.Adapter().(outboundgroup.ProxyGroup)
	return group, ok
}

func selectedGroupMember(group outboundgroup.ProxyGroup) (selected constant.Proxy) {
	defer func() {
		if recover() != nil {
			selected = nil
		}
	}()

	members := group.Proxies()
	if len(members) == 0 {
		return nil
	}
	name := group.Now()
	if name == "" {
		return nil
	}
	for _, member := range members {
		if member != nil && member.Name() == name {
			return member
		}
	}
	return nil
}

func handleGetActiveServer(groupHint string) *ActiveServer {
	if groupHint == "" {
		return nil
	}
	proxies := tunnel.AllProxies()
	group, ok := proxyGroup(proxies[groupHint])
	if !ok {
		return nil
	}

	seen := map[string]struct{}{groupHint: {}}
	for depth := 0; depth < activeServerMaxDepth; depth++ {
		if active := activeServerForGroup(groupHint, group); active != nil {
			return active
		}
		selected := selectedGroupMember(group)
		if selected == nil {
			return nil
		}
		nested, nestedGroup := proxyGroup(proxies[selected.Name()])
		if !nestedGroup {
			return &ActiveServer{Group: groupHint, Name: selected.Name()}
		}
		if _, exists := seen[selected.Name()]; exists {
			return nil
		}
		seen[selected.Name()] = struct{}{}
		group = nested
	}
	return nil
}

var (
	errGroupNotFound    = errors.New("Not found group")
	errGroupInvalidType = errors.New("Group has invalid proxy type")
	errGroupNotSelect   = errors.New("Group is not selectable")
)

func lookupProxy(name string) constant.Proxy {
	return tunnel.AllProxies()[name]
}

func selectableGroup(groupName string) (outboundgroup.SelectAble, error) {
	group := lookupProxy(groupName)
	if group == nil {
		return nil, errGroupNotFound
	}
	adapterProxy, ok := group.(*adapter.Proxy)
	if !ok {
		return nil, errGroupInvalidType
	}
	selector, ok := adapterProxy.ProxyAdapter.(outboundgroup.SelectAble)
	if !ok {
		return nil, errGroupNotSelect
	}
	return selector, nil
}

// RCX-NODE is engine-owned but hand-selectable, which is what arms
// manual-hold; the other RCX groups are invisible plumbing.
func rcxIsSelectableServiceGroup(name string) bool {
	return rcxIsServiceGroup(name) && name != rcxGroupNode
}

func handleChangeProxy(params *ChangeProxyParams) string {
	if rcxIsSelectableServiceGroup(params.GroupName) {
		return errGroupNotFound.Error()
	}

	if err := func() string {
		selectMu.Lock()
		defer selectMu.Unlock()

		selector, err := selectableGroup(params.GroupName)
		if err != nil {
			return err.Error()
		}
		if params.ProxyName == "" {
			selector.ForceSet(params.ProxyName)
			return ""
		}
		if err := selector.Set(params.ProxyName); err != nil {
			return err.Error()
		}
		return ""
	}(); err != "" {
		return err
	}

	// The host already wrote the selector: the engine only learns the pick.
	if params.GroupName == rcxGroupNode {
		rcxEngineInstance.OnManualAsserted(params.ProxyName)
	}
	if params.Manual && params.ProxyName != "" {
		odometerInstance.NoteManualSwitch(time.Now())
	}
	doctorBumpGeneration(doctorRoutingGeneration)
	return ""
}

func handleGetTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.NowTraffic(onlyStatisticsProxy)
	return Traffic{
		Up:   up,
		Down: down,
	}
}

func handleGetTotalTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.TotalTraffic(onlyStatisticsProxy)
	return Traffic{
		Up:   up,
		Down: down,
	}
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func delayValue(delay uint16) int32 {
	if delay == 0 {
		return -1
	}
	return int32(delay)
}

var anyDelayTestStatus utils.IntRanges[uint16]

func delayTestTimeout(milliseconds int64) time.Duration {
	if milliseconds <= 0 {
		return defaultDelayTestTimeout
	}
	return time.Duration(milliseconds) * time.Millisecond
}

var missingDelayTestProxyAt atomic.Int64

// A delay test against a name the tunnel does not know is what an apply that
// fell back to the default config looks like from the outside: the profile
// still lists every node and every one of them reports Timeout. Say so, once a
// second rather than once per node, so the log names the real failure.
func reportMissingDelayTestProxy(name string) {
	now := time.Now().UnixNano()
	last := missingDelayTestProxyAt.Load()
	if last != 0 && now-last < int64(time.Second) {
		return
	}
	if !missingDelayTestProxyAt.CompareAndSwap(last, now) {
		return
	}
	logError("delay test: %q is not part of the applied config", name)
}

func handleTestDelay(params *TestDelayParams) *Delay {
	url := params.TestUrl
	if url == "" {
		url = currentTestURL()
	}
	delayData := &Delay{
		Name:  params.ProxyName,
		Url:   url,
		Value: -1,
	}

	proxy := lookupProxy(params.ProxyName)
	if proxy == nil {
		reportMissingDelayTestProxy(params.ProxyName)
		return delayData
	}

	timeout := delayTestTimeout(params.Timeout)

	// Queueing for a slot and probing the node each get the full timeout.
	// Sharing one deadline meant a node that waited four seconds behind a
	// saturated semaphore had one second left to connect, so a bulk test of a
	// large subscription reported Timeout for whatever happened to be at the
	// back of the queue.
	queueCtx, cancelQueue := context.WithTimeout(context.Background(), timeout)
	granted := acquireDelayTestSlot(queueCtx)
	cancelQueue()
	if !granted {
		return nil
	}
	defer releaseDelayTestSlot()

	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	delay, err := proxy.URLTest(ctx, url, anyDelayTestStatus)
	if err != nil {
		return delayData
	}

	delayData.Value = delayValue(delay)
	return delayData
}

func handleGetConnections() *statistic.Snapshot {
	return statistic.DefaultManager.Snapshot()
}

func handleCloseConnections() bool {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		_ = c.Close()
		return true
	})
	return true
}

func handleResetConnections() bool {
	resolver.ResetConnection()
	return true
}

func handleCloseConnection(connectionId string) bool {
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return false
	}
	_ = c.Close()
	return true
}

func handleGetExternalProviders() []ExternalProvider {
	providers := externalProviders()
	eps := make([]ExternalProvider, 0, len(providers))
	for _, p := range providers {
		externalProvider, err := toExternalProvider(p)
		if err != nil {
			continue
		}
		eps = append(eps, *externalProvider)
	}
	slices.SortFunc(eps, func(a, b ExternalProvider) int {
		return cmp.Compare(a.Name, b.Name)
	})
	return eps
}

func handleGetExternalProvider(externalProviderName string) *ExternalProvider {
	p, exist := lookupExternalProvider(externalProviderName)
	if !exist {
		return nil
	}
	externalProvider, err := toExternalProvider(p)
	if err != nil {
		return nil
	}
	return externalProvider
}

var geoResourceUpdaters = map[string]func() error{
	"MMDB":    updater.UpdateMMDB,
	"ASN":     updater.UpdateASN,
	"GEOIP":   updater.UpdateGeoIp,
	"GEOSITE": updater.UpdateGeoSite,
}

const (
	geoUpdateScope      = "geo:"
	providerUpdateScope = "provider:"
)

var (
	updateMu       sync.Mutex
	updateInFlight = map[string]bool{}
	geoHookClaims  = map[string]bool{}
)

func claimUpdate(key string) bool {
	updateMu.Lock()
	defer updateMu.Unlock()
	if updateInFlight[key] {
		return false
	}
	updateInFlight[key] = true
	return true
}

func releaseUpdate(key string) {
	updateMu.Lock()
	defer updateMu.Unlock()
	delete(updateInFlight, key)
	delete(geoHookClaims, key)
}

func claimGeoUpdate(geoType string) bool {
	return claimUpdate(geoUpdateScope + geoType)
}

func releaseGeoUpdate(geoType string) {
	releaseUpdate(geoUpdateScope + geoType)
}

func claimGeoUpdateFromHook(geoType string) {
	key := geoUpdateScope + geoType
	updateMu.Lock()
	defer updateMu.Unlock()
	if updateInFlight[key] {
		return
	}
	updateInFlight[key] = true
	geoHookClaims[key] = true
}

func releaseGeoUpdateFromHook(geoType string) {
	key := geoUpdateScope + geoType
	updateMu.Lock()
	defer updateMu.Unlock()
	if !geoHookClaims[key] {
		return
	}
	delete(geoHookClaims, key)
	delete(updateInFlight, key)
}

func handleUpdateGeoData(geoType string) string {
	update, exist := geoResourceUpdaters[geoType]
	if !exist {
		logError("updateGeoData: unknown geo resource %q", geoType)
		return "unknown geo resource: " + geoType
	}
	if !claimGeoUpdate(geoType) {
		return "geo update already in progress: " + geoType
	}
	safeGoDetached("updateGeoData("+geoType+")", func() {
		defer releaseGeoUpdate(geoType)
		if err := update(); err != nil {
			logError("updateGeoData(%s) error: %v", geoType, err)
		}
	})
	return ""
}

func providerRequestErrorCode(err error) string {
	message := err.Error()
	if len(message) >= 4 && message[3] == ' ' {
		status, parseErr := strconv.Atoi(message[:3])
		if parseErr == nil && status >= 100 && status <= 599 {
			return "request_bad_response"
		}
	}
	var urlError *url.Error
	var networkError net.Error
	if errors.Is(err, context.DeadlineExceeded) ||
		errors.As(err, &urlError) ||
		errors.As(err, &networkError) {
		return "request_error"
	}
	return ""
}

func providerMethodError(code, providerName string, err error) *MethodError {
	return &MethodError{
		Code:    code,
		Message: err.Error(),
		Details: map[string]any{"providerName": providerName},
	}
}

func handleUpdateExternalProvider(providerName string) *MethodError {
	p, exist := lookupExternalProvider(providerName)
	if !exist {
		return providerMethodError(
			"provider_not_found",
			providerName,
			errors.New("external provider does not exist"),
		)
	}
	key := providerUpdateScope + providerName
	if !claimUpdate(key) {
		return providerMethodError(
			"provider_updating",
			providerName,
			errors.New("external provider is updating"),
		)
	}
	defer releaseUpdate(key)
	if err := p.Update(); err != nil {
		code := providerRequestErrorCode(err)
		if code == "" {
			code = "provider_update_error"
		}
		return providerMethodError(code, providerName, err)
	}
	return nil
}

func handleSideLoadExternalProvider(providerName string, data []byte) *MethodError {
	p, exist := lookupExternalProvider(providerName)
	if !exist {
		return providerMethodError(
			"provider_not_found",
			providerName,
			errors.New("external provider does not exist"),
		)
	}
	key := providerUpdateScope + providerName
	if !claimUpdate(key) {
		return providerMethodError(
			"provider_updating",
			providerName,
			errors.New("external provider is updating"),
		)
	}
	defer releaseUpdate(key)
	if err := sideUpdateExternalProvider(p, data); err != nil {
		return providerMethodError("provider_update_error", providerName, err)
	}
	return nil
}

const healthCheckCadenceInterval = 5 * time.Minute

var (
	healthCheckCadenceMu     sync.Mutex
	healthCheckCadenceCancel context.CancelFunc
	healthCheckCadenceEvery  = healthCheckCadenceInterval
)

func healthCheckProviders() []cp.ProxyProvider {
	providers := make([]cp.ProxyProvider, 0)
	healthCheckSeen := make(map[cp.ProxyProvider]struct{})
	add := func(provider cp.ProxyProvider) {
		if provider == nil {
			return
		}
		if _, seen := healthCheckSeen[provider]; seen {
			return
		}
		healthCheckSeen[provider] = struct{}{}
		providers = append(providers, provider)
	}
	for _, provider := range tunnel.ProvidersSnapshot() {
		add(provider)
	}
	for _, proxy := range tunnel.AllProxies() {
		adapterProxy, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}
		group, ok := adapterProxy.ProxyAdapter.(outboundgroup.ProxyGroup)
		if !ok {
			continue
		}
		for _, provider := range group.Providers() {
			add(provider)
		}
	}
	return providers
}

func runHealthCheckRefresh() {
	for _, provider := range healthCheckProviders() {
		log.Debugln("[APP] re-checking provider %s", provider.Name())
		provider.Touch()
		provider.HealthCheck()
	}
}

func defaultRefreshHealthChecks() {
	safeGoDetached("refreshHealthChecks", runHealthCheckRefresh)
}

var refreshHealthChecks = defaultRefreshHealthChecks

func startHealthCheckCadence() {
	healthCheckCadenceMu.Lock()
	defer healthCheckCadenceMu.Unlock()
	if healthCheckCadenceCancel != nil {
		return
	}
	ctx, cancel := context.WithCancel(context.Background())
	healthCheckCadenceCancel = cancel
	every := healthCheckCadenceEvery
	safeGoDetached("healthCheckCadence", func() {
		ticker := time.NewTicker(every)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				if tunUp.Load() && !isScreenOff.Load() && !isSuspended.Load() {
					refreshHealthChecks()
				}
			}
		}
	})
}

func stopHealthCheckCadence() {
	healthCheckCadenceMu.Lock()
	defer healthCheckCadenceMu.Unlock()
	if healthCheckCadenceCancel == nil {
		return
	}
	healthCheckCadenceCancel()
	healthCheckCadenceCancel = nil
}

// Doze is minutes away when a screen goes off, so a health check gated on
// suspension alone still probes every provider from a pocketed phone.
func handleScreenOff(off bool) {
	wasOff := isScreenOff.Swap(off)
	provider.SetScreenOff(off)
	rcxEngineInstance.OnScreenOff(off)
	if wasOff && !off && tunUp.Load() && !isSuspended.Load() && !rcxEngineInstance.Enabled() {
		refreshHealthChecks()
	}
}

func handleSuspend(suspended bool) bool {
	wasSuspended := isSuspended.Swap(suspended)
	if suspended {
		tunnel.OnSuspend()
		rcxEngineInstance.OnSuspend(true)
		return true
	}

	tunnel.OnRunning()
	// Provider health checks keep ticking through Doze, where the app has no
	// network at all, so coming back means every proxy is marked dead and every
	// delay reads Timeout. A lazy provider then skips its next tick because
	// nothing touched it in the meantime, and the whole list stays wrong until
	// the user tests by hand. Re-check now instead - but not while the
	// listeners are stopped, since the service also resumes the core on its way
	// down, and not when the routing engine is on: it buys one probe for the
	// node in use instead of one per provider.
	if wasSuspended && !isScreenOff.Load() && isRunning.Load() && !rcxEngineInstance.Enabled() {
		refreshHealthChecks()
	}
	rcxEngineInstance.OnSuspend(false)
	return true
}

// A failure measured while the device is dozing says nothing about the node -
// the app had no network at all - and publishing it repaints the entire list as
// Timeout for a user who is not even looking. Successes still are worth having,
// whenever they happen.
func shouldPublishDelay(delay uint16) bool {
	return delay != 0 || !isSuspended.Load()
}

func handleStartLog() {
	logMu.Lock()
	if logCancel != nil {
		logCancel()
		logCancel = nil
	}
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	ctx, cancel := context.WithCancel(context.Background())
	subscriber := log.Subscribe()
	logSubscriber = subscriber
	logCancel = cancel
	logMu.Unlock()

	go func() {
		defer func() {
			logMu.Lock()
			if logSubscriber == subscriber {
				log.UnSubscribe(subscriber)
				logSubscriber = nil
				logCancel = nil
			}
			logMu.Unlock()
		}()
		for {
			select {
			case <-ctx.Done():
				return
			case logData, ok := <-subscriber:
				if !ok {
					return
				}
				if logData.LogLevel < log.Level() {
					continue
				}
				sendMessage(Message{
					Type: LogMessage,
					Data: logData,
				})
			}
		}
	}()
}

func handleStopLog() {
	logMu.Lock()
	defer logMu.Unlock()
	if logCancel != nil {
		logCancel()
		logCancel = nil
	}
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}

func handleGetMemory() uint64 {
	return statistic.DefaultManager.Memory()
}

func handleGetConfig(path string) (*config.RawConfig, error) {
	buf, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	return config.UnmarshalRawConfig(buf)
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleUpdateConfig(params *UpdateParams) string {
	err := updateConfig(params)
	if err != nil && !errors.Is(err, errTunNotActive) {
		return err.Error()
	}
	if change := doctorGenerationForUpdate(params); change != (doctorGenerationChange{}) {
		doctorBumpGenerations(change)
	}
	if err != nil {
		return err.Error()
	}
	return ""
}

// The profile ID is an int64 rendered through strconv, so the last element can
// never carry a separator or a `..` — that is what keeps handleClearEffect from
// becoming a general-purpose privileged file deletion API.
func providerPaths(homeDir string, profileId int64) (root string, target string) {
	root = filepath.Join(homeDir, "profiles", "providers")
	return root, filepath.Join(root, strconv.FormatInt(profileId, 10))
}

// handleClearEffect derives the provider directory from a profile ID so the
// method cannot be used as a general-purpose privileged file deletion API.
func handleClearEffect(profileId int64) string {
	if !isInit.Load() {
		return "not initialized"
	}
	if profileId <= 0 {
		return "invalid profile id"
	}
	providersRoot, providersPath := providerPaths(constant.Path.HomeDir(), profileId)
	if err := os.RemoveAll(providersPath); err != nil {
		return err.Error()
	}
	_ = os.Remove(providersRoot)
	return ""
}

var setupConfig = applyConfig

func handleSetupConfig(params *SetupParams) string {
	if !isInit.Load() {
		return "not initialized"
	}
	if err := setupConfig(params); err != nil {
		return err.Error()
	}
	refreshHealthChecks()
	return ""
}

func init() {
	adapter.UrlTestHook = func(url string, name string, delay uint16) {
		rcxEngineInstance.NoteHarvestedProbe(url, name, int(delay))
		if !shouldPublishDelay(delay) {
			return
		}
		sendMessage(Message{
			Type: DelayMessage,
			Data: &Delay{
				Url:   url,
				Name:  name,
				Value: delayValue(delay),
			},
		})
	}
	tunnel.DefaultFlowEvidenceNotify = connectionDoctor.ObserveFlow
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		connectionDoctor.ObserveTracker(c, false)
		rcxEngineInstance.NoteTracker(c)
		sendMessage(Message{
			Type: RequestMessage,
			Data: c,
		})
	}
	statistic.DefaultFirstProgressNotify = func(c statistic.Tracker) {
		connectionDoctor.ObserveTracker(c, true)
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		scheduleReclaimOwnership()
		rcxEngineInstance.OnProvidersLoaded()
		sendMessage(Message{
			Type: LoadedMessage,
			Data: providerName,
		})
	}
	updater.GeoUpdateHook = func(geoType string, updating bool, skipped bool, updateErr error) {
		if updating {
			claimGeoUpdateFromHook(geoType)
		} else {
			releaseGeoUpdateFromHook(geoType)
			scheduleReclaimOwnership()
		}
		status := GeoUpdateStatus{
			Type:     geoType,
			Updating: updating,
			Skipped:  skipped,
		}
		if updateErr != nil {
			status.Error = updateErr.Error()
		}
		sendMessage(Message{
			Type: GeoUpdateMessage,
			Data: status,
		})
	}
}
