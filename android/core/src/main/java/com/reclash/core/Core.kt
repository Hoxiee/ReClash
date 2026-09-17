package com.reclash.core

import java.net.BindException
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.net.SocketTimeoutException
import java.net.URI
import org.json.JSONObject
import kotlin.math.ceil

object Core {
    private external fun startTun(
        fd: Int,
        cb: TunInterface,
        stack: String,
        address: String,
        dns: String,
    ): Boolean


    external fun forceGC()

    external fun updateDNS(
        dns: String,
    )

    private fun parseInetSocketAddress(address: String): InetSocketAddress {
        val uri = URI("tcp://$address")
        val host = requireNotNull(uri.host) { "Missing host in address: $address" }
        require(uri.port >= 0) { "Missing port in address: $address" }
        return InetSocketAddress(InetAddress.getByName(host), uri.port)
    }

    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        protectSubscription: (Int) -> Boolean,
        resolveUid: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress) -> Int,
        resolvePackage: (uid: Int) -> String,
        stack: String,
        address: String,
        dns: String,
    ): Boolean {
        val doctorProbes = DoctorProbeRegistry()
        return startTun(
            fd,
            object : TunInterface {
                override fun protect(fd: Int): Boolean = protect(fd)

                override fun protectSubscription(fd: Int): Boolean = protectSubscription(fd)

                override fun resolveUid(
                    protocol: Int,
                    source: String,
                    target: String,
                ): Int {
                    return resolveUid(
                        protocol,
                        parseInetSocketAddress(source),
                        parseInetSocketAddress(target),
                    )
                }

                override fun resolvePackage(uid: Int): String = resolvePackage(uid)

                override fun runDoctorProbe(requestJson: String): String =
                    executeDoctorProbe(requestJson, doctorProbes)

                override fun cancelDoctorProbe(probeId: String) {
                    doctorProbes.cancel(probeId)
                }
            },
            stack,
            address,
            dns,
        )
    }

    private fun executeDoctorProbe(
        requestJson: String,
        registry: DoctorProbeRegistry,
    ): String {
        val request = runCatching { parseDoctorProbeRequest(requestJson) }.getOrElse {
            return doctorProbeResult("", "unsupported", "invalidRequest")
        }
        val started = System.nanoTime()
        val socket = Socket()
        if (!registry.register(request.probeId, socket)) {
            return doctorProbeResult(request.probeId, "cancelled", "probeCancelled")
        }
        return try {
            socket.use {
                socket.reuseAddress = false
                socket.bind(InetSocketAddress(request.sourcePort))
                socket.soTimeout = request.readTimeoutMillis
                socket.connect(
                    InetSocketAddress(request.destination, request.destinationPort),
                    request.connectTimeoutMillis,
                )
                socket.getOutputStream().write(
                    "GET / HTTP/1.0\r\nConnection: close\r\n\r\n".toByteArray(),
                )
                socket.getOutputStream().flush()
                val input = socket.getInputStream()
                val buffer = ByteArray(minOf(request.byteBudget, 256))
                val readDeadline = System.nanoTime() + request.readTimeoutMillis * 1_000_000L
                var remaining = request.byteBudget
                while (remaining > 0) {
                    val remainingNanos = readDeadline - System.nanoTime()
                    if (remainingNanos <= 0) throw SocketTimeoutException()
                    socket.soTimeout =
                        (remainingNanos / 1_000_000L)
                            .coerceAtLeast(1L)
                            .coerceAtMost(Int.MAX_VALUE.toLong())
                            .toInt()
                    val count = input.read(buffer, 0, minOf(buffer.size, remaining))
                    if (count < 0) break
                    remaining -= count
                }
            }
            doctorProbeResult(request.probeId, "completed", durationMillis = elapsedBucket(started))
        } catch (_: BindException) {
            doctorProbeResult(request.probeId, "bindCollision", "sourcePortInUse", elapsedBucket(started))
        } catch (_: SocketTimeoutException) {
            if (registry.isCancelled(request.probeId)) {
                doctorProbeResult(request.probeId, "cancelled", "probeCancelled", elapsedBucket(started))
            } else {
                doctorProbeResult(request.probeId, "timeout", "socketTimeout", elapsedBucket(started))
            }
        } catch (_: SecurityException) {
            doctorProbeResult(request.probeId, "unsupported", "socketDenied", elapsedBucket(started))
        } catch (_: java.io.IOException) {
            if (registry.isCancelled(request.probeId)) {
                doctorProbeResult(request.probeId, "cancelled", "probeCancelled", elapsedBucket(started))
            } else {
                doctorProbeResult(request.probeId, "ioError", "socketIoError", elapsedBucket(started))
            }
        } finally {
            registry.complete(request.probeId, socket)
        }
    }

    private fun parseDoctorProbeRequest(value: String): DoctorProbeRequest {
        require(value.length <= 4096)
        val json = JSONObject(value)
        require(json.getInt("schemaVersion") == 1)
        require(json.getString("protocol") == "tcp")
        val examId = json.getString("examId")
        val probeId = json.getString("probeId")
        require(examId.isNotEmpty() && examId.length <= 64)
        require(probeId.isNotEmpty() && probeId.length <= 64)
        val destinationIp = json.getString("destinationIp")
        require(isNumericAddress(destinationIp))
        val address = InetAddress.getByName(destinationIp)
        val destinationPort = json.getInt("destinationPort")
        val sourcePort = json.getInt("sourcePort")
        val connectTimeoutMillis = json.getInt("connectTimeoutMillis")
        val readTimeoutMillis = json.getInt("readTimeoutMillis")
        val byteBudget = json.getInt("byteBudget")
        require(destinationPort in 1..65535)
        require(sourcePort in 49152..65535)
        require(connectTimeoutMillis in 1..5_000)
        require(readTimeoutMillis in 1..5_000)
        require(byteBudget in 1..4096)
        return DoctorProbeRequest(
            probeId,
            address,
            destinationPort,
            sourcePort,
            connectTimeoutMillis,
            readTimeoutMillis,
            byteBudget,
        )
    }

    private fun isNumericAddress(value: String): Boolean {
        if (value.contains(':')) {
            return value.isNotEmpty() && value.all { it.isDigit() || it.lowercaseChar() in 'a'..'f' || it == ':' }
        }
        val octets = value.split('.')
        return octets.size == 4 && octets.all { octet ->
            octet.isNotEmpty() && octet.length <= 3 && octet.all(Char::isDigit) && octet.toInt() in 0..255
        }
    }

    private fun doctorProbeResult(
        probeId: String,
        outcome: String,
        errorCode: String? = null,
        durationMillis: Long = 0,
    ): String =
        JSONObject().apply {
            put("probeId", probeId)
            put("outcome", outcome)
            if (errorCode != null) put("errorCode", errorCode)
            if (durationMillis > 0) put("durationBucketMs", durationMillis)
        }.toString()

    private fun elapsedBucket(started: Long): Long {
        val elapsed = ceil((System.nanoTime() - started) / 1_000_000.0).toLong()
        return listOf(50L, 100L, 250L, 500L, 1_000L, 2_000L, 5_000L)
            .firstOrNull { elapsed <= it } ?: 5_000L
    }

    private class DoctorProbeRegistry {
        private val lock = Any()
        private val sockets = mutableMapOf<String, Socket>()
        private val cancelled = mutableSetOf<String>()
        private var shutdown = false

        fun register(probeId: String, socket: Socket): Boolean = synchronized(lock) {
            if (shutdown || cancelled.remove(probeId)) {
                false
            } else {
                sockets[probeId] = socket
                true
            }
        }

        fun cancel(probeId: String) {
            val active = synchronized(lock) {
                if (probeId.isEmpty()) {
                    shutdown = true
                    cancelled += sockets.keys
                    sockets.values.toList()
                } else {
                    cancelled += probeId
                    listOfNotNull(sockets[probeId])
                }
            }
            active.forEach { runCatching { it.close() } }
        }

        fun isCancelled(probeId: String): Boolean = synchronized(lock) {
            shutdown || probeId in cancelled
        }

        fun complete(probeId: String, socket: Socket) {
            synchronized(lock) {
                sockets.remove(probeId, socket)
                cancelled.remove(probeId)
            }
        }
    }

    private data class DoctorProbeRequest(
        val probeId: String,
        val destination: InetAddress,
        val destinationPort: Int,
        val sourcePort: Int,
        val connectTimeoutMillis: Int,
        val readTimeoutMillis: Int,
        val byteBudget: Int,
    )

    external fun suspended(
        suspended: Boolean,
    )

    external fun screenOff(
        off: Boolean,
    )

    private external fun invokeMethod(
        data: String,
        cb: InvokeInterface,
    )

    fun invokeMethod(
        data: String,
        cb: (result: String?) -> Unit,
    ) {
        invokeMethod(
            data,
            object : InvokeInterface {
                override fun onResult(result: String?) {
                    cb(result)
                }
            },
        )
    }

    private fun invokeWithoutArguments(method: String) {
        invokeMethod("""{"method":"$method"}""") {}
    }

    fun resetConnections() = invokeWithoutArguments("resetConnections")

    fun closeConnections() = invokeWithoutArguments("closeConnections")

    fun rcxNetwork(payload: String) {
        invokeMethod("""{"method":"rcxNetwork","arguments":$payload}""") {}
    }

    fun doctorByeDpiStatus(payload: String) {
        invokeMethod("""{"method":"doctorPlatformStatus","arguments":$payload}""") {}
    }

    fun doctorPathStatus(
        pathKind: String,
        phase: String,
        generation: Long,
        timestamp: Long,
    ) {
        require(pathKind == "vpn" || pathKind == "localProxy")
        require(phase == "active" || phase == "inactive" || phase == "paused")
        require(generation > 0)
        require(timestamp >= 0)
        val payload = JSONObject()
            .put("pathKind", pathKind)
            .put("phase", phase)
            .put("generation", generation)
            .put("timestamp", timestamp)
        invokeMethod("""{"method":"doctorPathStatus","arguments":$payload}""") {}
    }

    private external fun setEventListener(cb: InvokeInterface?)

    fun updateEventListener(
        callback: ((result: String?) -> Unit)?,
    ) {
        if (callback == null) {
            setEventListener(null)
        } else {
            setEventListener(
                object : InvokeInterface {
                    override fun onResult(result: String?) {
                        callback(result)
                    }
                },
            )
        }
    }

    fun quickSetup(
        initParamsString: String,
        setupParamsString: String,
        callback: (result: String?) -> Unit,
    ) {
        quickSetup(
            initParamsString,
            setupParamsString,
            object : InvokeInterface {
                override fun onResult(result: String?) {
                    callback(result)
                }
            },
        )
    }

    private external fun quickSetup(
        initParamsString: String,
        setupParamsString: String,
        cb: InvokeInterface,
    )

    external fun stopTun()

    external fun getActiveServer(groupHint: String): String

    external fun getTraffic(onlyStatisticsProxy: Boolean): String

    external fun getTotalTraffic(onlyStatisticsProxy: Boolean): String

    init {
        System.loadLibrary("core")
    }
}
