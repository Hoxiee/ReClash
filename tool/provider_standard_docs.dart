// Authored English prose for tool/gen_provider_standard.dart. The generator
// derives every name, list and constraint from the model files; this file
// supplies the human-readable value/purpose/example text that cannot be
// derived. The generator fails when a derived header or widget has no entry
// here, so descriptions can never silently drift out of the doc.
library;

const docTitle = 'Subscription response headers';

const docIntro =
    'ReClash can read account data and provider-specific metadata from the '
    'HTTP response that returns a subscription. These headers are optional: '
    'the subscription body remains the source of the proxy configuration, '
    'while headers add usage data, update policy, provider links, dashboard '
    'content, and appearance.\n\n'
    'Header names are case-insensitive. When a ReClash header and one of its '
    'compatibility aliases are both present, the `reclash-*` value wins. Empty '
    'and unknown headers are ignored. If a response repeats the same header, '
    'ReClash joins its values with commas before parsing it.';

const responsePreamble = '''
HTTP/1.1 200 OK
Content-Type: application/yaml; charset=utf-8
Subscription-Userinfo: upload=1048576; download=2097152; total=107374182400; expire=1798761600
Profile-Title: Example VPN''';

const responseExampleNote =
    '`upload`, `download`, and `total` are byte counts. `expire` is a Unix '
    'timestamp in seconds.';

// Honoured by the app but parsed outside the converter list.
const externalDocs = <String, Map<String, String>>{
  'subscription-userinfo': {
    'value':
        'upload=<bytes>; download=<bytes>; total=<bytes>; expire=<unix-seconds>',
    'purpose': 'Shows traffic usage and expiration information.',
  },
  'content-disposition': {
    'value': 'A response filename',
    'purpose': 'Used as a profile-name fallback.',
  },
};

// Keyed by the converter's canonical key. `example` is the wire line shown in
// the response-example block, emitted in converter order.
const headerDocs = <String, Map<String, String>>{
  'hwidMaxDevicesReached': {
    'value': '`true`',
    'purpose':
        'Shows the device-limit message and offers `reclash-supporturl` when '
        'available.',
  },
  'hwidNotSupported': {
    'value': '`true`',
    'purpose': 'Shows that the selected client/device mode is unsupported.',
  },
  'announce': {
    'value': 'Plain text or Base64',
    'purpose': 'Provider announcement. Takes priority over `announce`.',
    'example': 'ReClash-Announce: Maintenance is scheduled for Sunday.',
  },
  'supportUrl': {
    'value': 'Provider support URL',
    'purpose': 'Support page. Use an absolute HTTPS URL.',
    'example': 'ReClash-SupportURL: https://support.example.com',
  },
  'reportUrl': {
    'value': 'Provider issue-report URL',
    'purpose': 'Subscription issue-report action. Use an absolute HTTPS URL.',
    'example': 'ReClash-ReportURL: https://example.com/report',
  },
  'announceUrl': {
    'value': 'Provider announcement URL',
    'purpose':
        'Turns the announcement into a link: opens instead of the dismiss '
        'button on the announcement sheet and card. Use an absolute HTTPS URL.',
    'example': 'ReClash-AnnounceURL: https://example.com/news',
  },
  'webPageUrl': {
    'value': 'Provider account URL',
    'purpose':
        'Personal-account link in the subscription details. Also read from the '
        'Profile-Web-Page-Url header that marzban and 3x-ui already emit. Use '
        'an absolute HTTPS URL.',
    'example': 'ReClash-WebPageURL: https://example.com/account',
  },
  'expireNotifyDays': {
    'value': 'Comma-separated days',
    'purpose':
        'Days-before-expiry the client reminds at. Overrides the default 3,2,1.',
    'example': 'ReClash-ExpireDays: 7,3,1',
  },
  'trafficNotifyPercent': {
    'value': 'Comma-separated percents',
    'purpose':
        'Used-traffic percents the client reminds at on metered plans. '
        'Overrides the default 90.',
    'example': 'ReClash-TrafficPercent: 80,95',
  },
  'updateIntervalMinutes': {
    'value':
        'Positive integer (minutes for `reclash-autoupdateinterval`, hours '
        'for the aliases)',
    'purpose': 'Sets the profile update interval.',
    'example': 'ReClash-AutoUpdateInterval: 60',
  },
  'serviceName': {
    'value': 'Plain text or Base64',
    'purpose': 'Provider name shown in the dashboard.',
    'example': 'ReClash-ServiceName: Example VPN',
  },
  'serviceLogo': {
    'value': 'Absolute HTTPS image URL',
    'purpose': 'Provider logo shown in the dashboard and connection control.',
    'example': 'ReClash-ServiceLogo: https://cdn.example.com/logo.svg',
  },
  'serverInfoGroup': {
    'value': 'Proxy-group name, plain text or Base64',
    'purpose':
        'Group used to resolve the active server shown in the dashboard.',
    'example': 'ReClash-ServerInfo: Proxy',
  },
  'activeText': {
    'value': 'Plain text or Base64',
    'purpose':
        'Replaces the active protection caption under the hero orb and in the '
        'Android notification.',
    'example': 'ReClash-ActiveText: Protected by Example VPN',
  },
  'buyPlanUrl': {
    'value': 'Provider URL',
    'purpose':
        'Subscription renewal or plan purchase action. Use an absolute HTTPS '
        'URL.',
    'example': 'ReClash-BuyPlan: https://example.com/plans',
  },
  'buyTrafficUrl': {
    'value': 'Provider URL',
    'purpose': 'Extra-traffic purchase action. Use an absolute HTTPS URL.',
    'example': 'ReClash-BuyTraffic: https://example.com/traffic',
  },
  'proxiesView': {
    'value': 'Proxy-page tokens',
    'purpose': 'Suggests the proxy-page presentation for this profile.',
    'example':
        'ReClash-View: type:list; sort:delay; layout:tight; icon:none; card:min',
  },
  'themeHex': {
    'value': 'Theme tokens',
    'purpose': 'Applies a theme while this profile is active.',
    'example': 'ReClash-Hex: FF5733:vibrant:pureblack',
  },
  'background': {
    'value': 'Image URL and optional opacity',
    'purpose': 'Applies a dashboard background while this profile is active.',
    'example': 'ReClash-Background: https://cdn.example.com/background.webp,18',
  },
  'heroRing': {
    'value': 'Three colors',
    'purpose': 'Sets the connected-state hero-ring gradient.',
    'example': 'ReClash-HeroRing: 2E5BFF;7A36F0;FF1744',
  },
  'heroEffect': {
    'value': '`aurora` or `none`',
    'purpose':
        'Adds an animated aurora effect to the connected-state hero orb. '
        'Default `none`.',
    'example': 'ReClash-HeroEffect: aurora',
  },
  'panelWidgets': {
    'value': 'Comma-separated widget names',
    'purpose': 'Suggests dashboard widgets and their order.',
    'example':
        'ReClash-Widgets: networkSpeed,trafficUsage,serviceInfo,changeServerButton',
  },
  'widgetsApplyMode': {
    'value': '`add` or `update`',
    'purpose': 'Controls how `reclash-widgets` is merged.',
    'example': 'ReClash-Custom: add',
  },
  'panelSettings': {
    'value': 'Comma-separated setting tokens',
    'purpose': 'Supplies application defaults when the profile is first added.',
    'example': 'ReClash-Settings: autorun,autoupdate',
  },
  'newDomain': {
    'value': 'Hostname with optional port',
    'purpose':
        'Proposes a subscription-domain migration subject to fetch and '
        'configuration checks.',
    'example': 'ReClash-NewDomain: subscriptions.example.net',
  },
  'fallbackHosts': {
    'value': 'Up to four comma-separated hostnames',
    'purpose': 'Supplies fallback hosts for transient fetch failures.',
    'example': 'ReClash-FallbackHosts: spare-a.example.com,spare-b.example.com',
  },
  'profileTitle': {
    'value': 'Profile name, plain UTF-8 or Base64',
    'purpose':
        'Names the imported profile unless the user has renamed it. Use '
        '`base64:` for non-ASCII text.',
  },
};

const widgetsIntro =
    '`reclash-widgets` accepts the following names. Matching is '
    'case-insensitive; the canonical spellings below are recommended. '
    'Unsupported names and widgets unavailable on the current platform or '
    'connection mode are ignored, and duplicates are removed.';

const widgetsMergeNote =
    '`reclash-custom: update` replaces the current widget list with the '
    'supported provider list. The default mode is `add`: ReClash adopts the '
    'provider order while the user still has the default or previous provider '
    'layout; after a user customization, missing provider widgets are appended '
    "without removing the user's choices.";

// Keyed by the DashboardWidget enum name. Platforms and modes are derived.
const widgetDocs = <String, String>{
  'networkSpeed': 'Live upload and download rates.',
  'trafficUsage': 'Session upload, download and total traffic.',
  'networkDetection': 'Connectivity and latency probe.',
  'tunButton': 'Toggles the TUN system tunnel.',
  'vpnButton': 'Toggles the VPN service.',
  'systemProxyButton': 'Toggles the system proxy.',
  'intranetIp': 'Shows the local network address.',
  'memoryInfo': 'Core memory usage.',
  'goroutineInfo': 'Core goroutine count.',
  'metaInfo': 'Core version and build details.',
  'announce': 'Provider announcement banner.',
  'serviceInfo': 'Provider service name and logo.',
  'changeServerButton': 'Opens the server picker.',
  'smartRouting': 'Smart-routing control.',
  'desyncStrategy': 'DPI-desync strategy selector.',
  'desyncTest': 'DPI-desync strategy test.',
  'desyncEngine': 'DPI-desync engine selector.',
  'serviceStatus': 'Connection state and active-server readout.',
  'connections': 'Active connections list.',
  'dnsQueries': 'Recent DNS queries.',
  'requests': 'Recent proxied requests.',
  'runTime': 'Connection uptime.',
  'proxyGroups': 'Proxy-group selectors.',
  'profiles': 'Profile switcher.',
  'overrideDnsButton': 'Toggles the DNS override.',
};

const textBase64Prose =
    '`reclash-announce`, `reclash-servicename`, `reclash-serverinfo`, and '
    '`reclash-activetext` accept plain text and Base64. `profile-title` '
    'follows the same practical convention. Prefix encoded values with '
    '`base64:` or `base64,`:\n\n'
    '```http\nReClash-ServiceName: base64:0J/RgNC40LzQtdGAIFZQTg==\n```\n\n'
    'The prefix is recommended even though ReClash can recognize some '
    'unprefixed Base64 values. Invalid payloads remain plain text instead of '
    'failing the subscription update. `reclash-activetext` is trimmed after '
    'decoding. If it is absent or empty, ReClash uses its localized protection '
    'caption; a later successful refresh without the header clears the '
    'previous override.';

const logoProse =
    '`reclash-servicelogo` should be an absolute HTTPS URL to a PNG or SVG '
    'hosted by the provider. Use a square image with a transparent background '
    'rather than a wide wordmark. A 256-512 px source with important content '
    'inside the central 80% works well at the small sizes used by the '
    'interface. Keep brand color in `reclash-hex`; do not bake a large colored '
    'tile into the logo.';

const themeProse =
    '`reclash-hex` accepts a 6-digit `RRGGBB` color or an 8-digit `AARRGGBB` '
    'color, optionally followed by a scheme variant and `pureblack`. Separate '
    'tokens with `:`, `;`, or `,`:\n\n'
    '```http\nReClash-Hex: FF5733:vibrant:pureblack\n```';

const themeVariantsNote =
    "Theme values dress the active profile without overwriting the user's "
    'saved theme.';

const backgroundProse =
    '`reclash-background` accepts an absolute HTTP or HTTPS image URL followed '
    'by an optional opacity. The default is 10. URLs containing credentials '
    'and non-web schemes are rejected.\n\n'
    '```http\nReClash-Background: https://cdn.example.com/background.webp,18\n```';

const heroRingProse =
    '`reclash-heroring` requires exactly three `RRGGBB` or `AARRGGBB` colors '
    'separated by semicolons or commas. A leading `#` is accepted.\n\n'
    '```http\nReClash-HeroRing: 2E5BFF;7A36F0;FF1744\n```';

const heroEffectProse =
    '`reclash-heroeffect` turns on an animated effect behind the '
    'connected-state hero orb. `none`, the default, keeps the orb static. The '
    'value is case-insensitive.\n\n'
    '```http\nReClash-HeroEffect: aurora\n```';

const viewProse =
    '`reclash-view` is a semicolon- or comma-separated set of `key:value` '
    'tokens:\n\n'
    '```http\nReClash-View: type:list; sort:delay; layout:tight; icon:none; card:min\n```';

const viewOnelineNote =
    '`oneline` maps to the closest ReClash size, `min`. The suggestion follows '
    'the active profile and applies only to fields the user has not '
    'customized; users can stop following provider layout entirely.';

const settingsIntro =
    '`reclash-settings` is offered only when a URL profile is first added. '
    'ReClash shows the requested app-wide changes and applies them only after '
    'the user confirms. Later subscription updates do not overwrite these '
    'user-owned settings. Only listed tokens are enabled; unlisted app '
    'settings keep their current values. Token matching is case-insensitive.';

const settingsTokens = <String, String>{
  'minimize': 'Minimize instead of exiting',
  'autorun': 'Start the connection when ReClash opens',
  'shadowstart': 'Launch ReClash in the background',
  'autostart': 'Launch ReClash at operating-system startup',
  'autoupdate': 'Check for ReClash updates at startup',
  'openlogs': 'Open logs with the connection',
  'closeconnections': 'Close existing connections when the VPN pauses',
};

const domainProse =
    '`reclash-newdomain` contains only a hostname and optional port, without a '
    'scheme, path, query, or credentials. ReClash preserves the original URL '
    'scheme, path, query, and token, downloads the subscription from the '
    'proposed authority, validates the configuration, and checks that it '
    'contains a dialable node. The stored subscription URL changes only after '
    'those checks succeed.\n\n'
    '`reclash-fallbackhosts` contains bare hostnames without ports. ReClash '
    'lowercases and deduplicates them, keeps at most four, and preserves the '
    'original URL path and query when trying one. Fallbacks are used for '
    'transport failures, timeouts, HTTP 408/429, and server errors; they are '
    'not used to bypass ordinary authentication or client errors.';

const hwidIntro =
    'Sending device identity is disabled by default and controlled by the '
    'user in ReClash settings. When enabled for subscription refreshes, '
    'ReClash sends the request headers below. A provider can answer with '
    'either verdict, carried as `true`. Do not use these headers as an '
    'authentication boundary: they are client-supplied metadata.';

const hwidRequestHeaders = <String, String>{
  'x-hwid': 'Stable 16-character device hash',
  'x-device-os': 'Operating-system name',
  'x-ver-os': 'Operating-system version',
  'x-device-model': 'Device model or host name',
};

const aliasesProse =
    'ReClash accepts selected Clash and FlClashX spellings for '
    'interoperability, shown as the lower-priority wire keys above. This '
    'compatibility does not imply affiliation with or endorsement by those '
    'projects.';

const securityProse =
    'Return provider metadata only over HTTPS and keep linked assets on '
    'infrastructure you control. Treat subscription URLs and their query '
    'parameters as credentials: never place them in logos, support links, '
    'logs, examples, or public bug reports. Keep announcements short and do '
    'not put executable markup in headers. Users should import subscriptions '
    'only from providers they trust: a subscription response can change the '
    'update interval, add external links and remote images, suggest '
    'appearance and dashboard layout, or propose a new subscription host.';
