package com.reclash.service.modules

import android.app.Service
import com.reclash.core.Core
import com.reclash.service.ByeDpiRuntime
import com.reclash.service.VpnService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

internal interface ServiceModule {
    fun start()

    fun stop()
}

internal class ServiceModules(private val service: Service) {
    private var scope: CoroutineScope? = null
    private var modules = emptyList<ServiceModule>()

    @Synchronized
    fun start() {
        if (scope != null) return

        val nextScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        val networkModule = NetworkObserveModule(service)
        // Only the VPN can pause: tearing a proxy listener down has no meaning here.
        val pauseModule = (service as? VpnService)?.let { vpn ->
            SmartPauseModule(nextScope, VpnPauseActions(vpn)).also { module ->
                networkModule.onPhysicalNetworksChanged = module::onPhysicalNetworksChanged
            }
        }
        val desyncModule = ByeDpiModule(
            nextScope,
            ByeDpiRuntime(service, (service as? VpnService)?.let { vpn -> vpn::protect }),
            status = { status -> Core.doctorByeDpiStatus(status.toJson()) },
        ).also { module ->
            networkModule.onNetworkFactsChanged = { facts ->
                module.onEnvironmentChanged(byeDpiEnvKey(facts))
            }
        }
        val nextModules = buildList {
            add(NotificationModule(service, nextScope, pauseSupported = pauseModule != null))
            add(networkModule)
            add(SuspendModule(service, nextScope))
            add(WakeLockModule(service, nextScope))
            if (pauseModule != null) add(pauseModule)
            add(desyncModule)
        }
        val startedModules = mutableListOf<ServiceModule>()

        try {
            nextModules.forEach { module ->
                module.start()
                startedModules.add(module)
            }
            scope = nextScope
            modules = nextModules
        } catch (error: Throwable) {
            nextScope.cancel()
            startedModules.asReversed().forEach { module ->
                runCatching { module.stop() }
            }
            throw error
        }
    }

    @Synchronized
    fun stop() {
        val currentScope = scope ?: return
        val currentModules = modules
        scope = null
        modules = emptyList()

        currentScope.cancel()
        currentModules.asReversed().forEach { module ->
            runCatching { module.stop() }
        }
    }
}

private class VpnPauseActions(private val vpn: VpnService) : SmartPauseModule.Actions {
    override fun pause() = vpn.pause(manual = false)

    override fun resume() = vpn.resume(manual = false)
}
