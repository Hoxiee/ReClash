package com.reclash.service

import android.net.LocalServerSocket
import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.os.ParcelFileDescriptor
import android.system.Os
import android.system.OsConstants
import com.reclash.common.GlobalState
import java.io.File
import java.io.FileDescriptor
import java.io.IOException

internal object ByeDpiProtectPolicy {
    // A missing ack makes ByeDPI treat the dial as failed and drop it, which is the
    // outcome we want when protect() did not take: better no connection than one
    // that loops back through the tun.
    fun shouldAck(results: List<Boolean>): Boolean = results.isNotEmpty() && results.all { it }
}

internal class ByeDpiProtect(
    private val socketFile: File,
    private val protect: (Int) -> Boolean,
    private val log: (String) -> Unit = GlobalState::log,
) {
    private var server: LocalServerSocket? = null

    // The bound LocalSocket owns the listening fd; dropping the reference lets
    // the LocalSocketImpl finalizer close it under the live server at the next
    // GC, and LocalServerSocket(fd).close() is a no-op on Android 11.
    private var bound: LocalSocket? = null

    val path: String
        get() = socketFile.path

    fun open(): LocalServerSocket {
        socketFile.delete()
        val socket = LocalSocket(LocalSocket.SOCKET_STREAM)
        socket.bind(LocalSocketAddress(socketFile.path, LocalSocketAddress.Namespace.FILESYSTEM))
        return LocalServerSocket(socket.fileDescriptor).also {
            bound = socket
            server = it
        }
    }

    fun acceptLoop(listener: LocalServerSocket) {
        while (true) {
            val client = try {
                listener.accept()
            } catch (error: IOException) {
                log("Desync protect accept loop ended: $error")
                return
            }
            runCatching { serve(client) }
                .onFailure { error -> log("ByeDpi protect failed: $error") }
        }
    }

    fun close() {
        // A thread blocked in accept(2) is not woken by close() from another
        // thread; shutdown is what makes accept fail so the loop can exit.
        bound?.fileDescriptor?.let { fd ->
            runCatching { Os.shutdown(fd, OsConstants.SHUT_RDWR) }
        }
        runCatching { server?.close() }
        server = null
        runCatching { bound?.close() }
        bound = null
        socketFile.delete()
    }

    private fun serve(client: LocalSocket) {
        client.use {
            if (client.inputStream.read() < 0) return
            val received = client.ancillaryFileDescriptors?.filterNotNull().orEmpty()
            val results = received.map(::protectDescriptor)
            if (ByeDpiProtectPolicy.shouldAck(results)) {
                client.outputStream.write(ACK)
                client.outputStream.flush()
            }
        }
    }

    private fun protectDescriptor(descriptor: FileDescriptor): Boolean {
        val duplicate = ParcelFileDescriptor.dup(descriptor)
        val applied = try {
            protect(duplicate.fd)
        } finally {
            runCatching { duplicate.close() }
            runCatching { Os.close(descriptor) }
        }
        return applied
    }

    private companion object {
        val ACK = byteArrayOf('1'.code.toByte())
    }
}
