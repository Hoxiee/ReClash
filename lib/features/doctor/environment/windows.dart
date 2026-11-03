import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32_registry/win32_registry.dart';

import 'catalogue.dart';
import 'facts.dart';
import 'reader.dart';
import 'tunnels.dart';

/// Native, read-only Win32 calls only: no process is ever spawned, so an
/// antivirus sees an app that looks and does not touch. Offsets below are the
/// 64-bit layouts of the documented structures.
final DynamicLibrary _iphlpapi = DynamicLibrary.open('iphlpapi.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
final DynamicLibrary _advapi32 = DynamicLibrary.open('advapi32.dll');
final DynamicLibrary _shell32 = DynamicLibrary.open('shell32.dll');

typedef _AdaptersC =
    Uint32 Function(
      Uint32,
      Uint32,
      Pointer<Void>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _AdaptersD =
    int Function(int, int, Pointer<Void>, Pointer<Uint8>, Pointer<Uint32>);
typedef _ForwardC = Uint32 Function(Uint16, Pointer<Pointer<Uint8>>);
typedef _ForwardD = int Function(int, Pointer<Pointer<Uint8>>);
typedef _FreeC = Void Function(Pointer<Uint8>);
typedef _FreeD = void Function(Pointer<Uint8>);
typedef _TcpTableC =
    Uint32 Function(
      Pointer<Uint8>,
      Pointer<Uint32>,
      Int32,
      Uint32,
      Int32,
      Uint32,
    );
typedef _TcpTableD =
    int Function(Pointer<Uint8>, Pointer<Uint32>, int, int, int, int);
typedef _SnapshotC = IntPtr Function(Uint32, Uint32);
typedef _SnapshotD = int Function(int, int);
typedef _ProcessC = Int32 Function(IntPtr, Pointer<Uint8>);
typedef _ProcessD = int Function(int, Pointer<Uint8>);
typedef _CloseC = Int32 Function(IntPtr);
typedef _CloseD = int Function(int);
typedef _OpenScmC = IntPtr Function(Pointer<Utf16>, Pointer<Utf16>, Uint32);
typedef _OpenScmD = int Function(Pointer<Utf16>, Pointer<Utf16>, int);
typedef _OpenSvcC = IntPtr Function(IntPtr, Pointer<Utf16>, Uint32);
typedef _OpenSvcD = int Function(int, Pointer<Utf16>, int);
typedef _QueryC = Int32 Function(IntPtr, Pointer<Uint8>);
typedef _QueryD = int Function(int, Pointer<Uint8>);
typedef _ExecC =
    IntPtr Function(
      IntPtr,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Int32,
    );
typedef _ExecD =
    int Function(
      int,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      int,
    );

const _afUnspec = 0;
const _afInet = 2;
const _afInet6 = 23;
const _bufferOverflow = 111;
const _internetSettings =
    r'Software\Microsoft\Windows\CurrentVersion\Internet Settings';

final class _Adapter {
  _Adapter(
    this.name,
    this.description,
    this.index,
    this.index6,
    this.metric4,
    this.metric6,
  );

  final String name;
  final String description;
  final int index;
  final int index6;
  final int metric4;
  final int metric6;
  final List<String> dns = [];
}

InternetAddress? _sockaddr(Pointer<Uint8> sa) {
  final family = sa.cast<Uint16>().value;
  if (family == _afInet) {
    return InternetAddress.fromRawAddress((sa + 4).asTypedList(4).sublist(0));
  }
  if (family == _afInet6) {
    return InternetAddress.fromRawAddress((sa + 8).asTypedList(16).sublist(0));
  }
  return null;
}

List<_Adapter> _readAdapters() {
  final getAdapters = _iphlpapi.lookupFunction<_AdaptersC, _AdaptersD>(
    'GetAdaptersAddresses',
  );
  final size = calloc<Uint32>()..value = 32768;
  Pointer<Uint8> buffer = calloc<Uint8>(size.value);
  try {
    var result = getAdapters(_afUnspec, 0x6, nullptr, buffer, size);
    if (result == _bufferOverflow) {
      calloc.free(buffer);
      buffer = calloc<Uint8>(size.value);
      result = getAdapters(_afUnspec, 0x6, nullptr, buffer, size);
    }
    if (result != 0) return const [];
    final adapters = <_Adapter>[];
    var node = buffer;
    while (node != nullptr) {
      final up = (node + 104).cast<Uint32>().value == 1;
      if (up) {
        final adapter = _Adapter(
          (node + 72).cast<Pointer<Utf16>>().value.toDartString(),
          (node + 64).cast<Pointer<Utf16>>().value.toDartString(),
          (node + 4).cast<Uint32>().value,
          (node + 108).cast<Uint32>().value,
          (node + 216).cast<Uint32>().value,
          (node + 220).cast<Uint32>().value,
        );
        var dns = (node + 48).cast<Pointer<Uint8>>().value;
        while (dns != nullptr) {
          final address = _sockaddr((dns + 16).cast<Pointer<Uint8>>().value);
          if (address != null) adapter.dns.add(address.address);
          dns = (dns + 8).cast<Pointer<Uint8>>().value;
        }
        adapters.add(adapter);
      }
      node = (node + 8).cast<Pointer<Uint8>>().value;
    }
    return adapters;
  } finally {
    calloc.free(buffer);
    calloc.free(size);
  }
}

List<({int index, InternetAddress destination, int prefix, int metric})>
_readRoutes() {
  final forward = _iphlpapi.lookupFunction<_ForwardC, _ForwardD>(
    'GetIpForwardTable2',
  );
  final free = _iphlpapi.lookupFunction<_FreeC, _FreeD>('FreeMibTable');
  final table = calloc<Pointer<Uint8>>();
  try {
    if (forward(_afUnspec, table) != 0) return const [];
    final base = table.value;
    final count = base.cast<Uint32>().value;
    final rows =
        <({int index, InternetAddress destination, int prefix, int metric})>[];
    for (var i = 0; i < count; i++) {
      final row = (base + 8 + i * 104);
      final destination = _sockaddr((row + 12));
      if (destination == null) continue;
      rows.add((
        index: (row + 8).cast<Uint32>().value,
        destination: destination,
        prefix: (row + 40).value,
        metric: (row + 84).cast<Uint32>().value,
      ));
    }
    free(base);
    return rows;
  } finally {
    calloc.free(table);
  }
}

Map<int, String> _readProcessNames() {
  final snapshot = _kernel32.lookupFunction<_SnapshotC, _SnapshotD>(
    'CreateToolhelp32Snapshot',
  );
  final first = _kernel32.lookupFunction<_ProcessC, _ProcessD>(
    'Process32FirstW',
  );
  final next = _kernel32.lookupFunction<_ProcessC, _ProcessD>('Process32NextW');
  final close = _kernel32.lookupFunction<_CloseC, _CloseD>('CloseHandle');
  final handle = snapshot(0x2, 0);
  if (handle == -1 || handle == 0) return const {};
  final entry = calloc<Uint8>(568);
  final names = <int, String>{};
  try {
    entry.cast<Uint32>().value = 568;
    var ok = first(handle, entry);
    while (ok != 0) {
      names[(entry + 8).cast<Uint32>().value] = (entry + 44)
          .cast<Utf16>()
          .toDartString();
      ok = next(handle, entry);
    }
  } finally {
    calloc.free(entry);
    close(handle);
  }
  return names;
}

/// Listening TCP ports and their owning pids, both families.
Map<int, int> _readListeners() {
  final table = _iphlpapi.lookupFunction<_TcpTableC, _TcpTableD>(
    'GetExtendedTcpTable',
  );
  final owners = <int, int>{};
  for (final (family, stride, portAt, pidAt) in const [
    (_afInet, 24, 8, 20),
    (_afInet6, 56, 20, 52),
  ]) {
    final size = calloc<Uint32>();
    Pointer<Uint8> buffer = nullptr;
    try {
      table(nullptr, size, 0, family, 3, 0);
      for (var attempt = 0; attempt < 3; attempt++) {
        if (buffer != nullptr) calloc.free(buffer);
        buffer = calloc<Uint8>(size.value + 4096);
        size.value += 4096;
        if (table(buffer, size, 0, family, 3, 0) == 0) {
          final count = buffer.cast<Uint32>().value;
          for (var i = 0; i < count; i++) {
            final row = (buffer + 4 + i * stride);
            final raw = (row + portAt).cast<Uint32>().value;
            final port = ((raw & 0xFF) << 8) | ((raw >> 8) & 0xFF);
            owners[port] = (row + pidAt).cast<Uint32>().value;
          }
          break;
        }
      }
    } finally {
      if (buffer != nullptr) calloc.free(buffer);
      calloc.free(size);
    }
  }
  return owners;
}

bool _serviceRunning(int scm, String name) {
  final openService = _advapi32.lookupFunction<_OpenSvcC, _OpenSvcD>(
    'OpenServiceW',
  );
  final query = _advapi32.lookupFunction<_QueryC, _QueryD>(
    'QueryServiceStatus',
  );
  final close = _advapi32.lookupFunction<_CloseC, _CloseD>(
    'CloseServiceHandle',
  );
  final wide = name.toNativeUtf16();
  final status = calloc<Uint8>(28);
  try {
    final service = openService(scm, wide, 0x4);
    if (service == 0) return false;
    try {
      return query(service, status) != 0 &&
          (status + 4).cast<Uint32>().value == 4;
    } finally {
      close(service);
    }
  } finally {
    calloc.free(wide);
    calloc.free(status);
  }
}

SoftwareFact? _scanSoftware(bool deep) {
  final services = <String>[];
  final drivers = <String>[];
  final open = _advapi32.lookupFunction<_OpenScmC, _OpenScmD>('OpenSCManagerW');
  final close = _advapi32.lookupFunction<_CloseC, _CloseD>(
    'CloseServiceHandle',
  );
  final scm = open(nullptr, nullptr, 0x1);
  if (scm == 0) return null;
  try {
    for (final name in catalogueServices) {
      if (_serviceRunning(scm, name)) services.add(name);
    }
    for (final name in catalogueDrivers) {
      if (_serviceRunning(scm, name)) drivers.add(name);
    }
  } finally {
    close(scm);
  }
  var processes = const <String>[];
  if (deep) {
    final wanted = catalogueProcesses;
    processes = {
      for (final name in _readProcessNames().values)
        if (wanted.contains(name.toLowerCase())) name.toLowerCase(),
    }.toList()..sort();
  }
  return SoftwareFact(
    services: services..sort(),
    drivers: drivers..sort(),
    processes: processes,
    processesScanned: deep,
  );
}

TunnelsFact _scanTunnels(String? ours) {
  final adapters = _readAdapters();
  final byIndex = <int, _Adapter>{};
  for (final adapter in adapters) {
    byIndex[adapter.index] = adapter;
    if (adapter.index6 != 0) byIndex[adapter.index6] = adapter;
  }
  final routes = <RouteEntry>[];
  for (final row in _readRoutes()) {
    final adapter = byIndex[row.index];
    if (adapter == null) continue;
    final v4 = row.destination.type == InternetAddressType.IPv4;
    routes.add(
      RouteEntry(
        adapter: adapter.name,
        destination: row.destination,
        prefix: row.prefix,
        metric: row.metric + (v4 ? adapter.metric4 : adapter.metric6),
      ),
    );
  }
  return buildTunnels(
    adapters: [
      for (final a in adapters)
        AdapterInfo(name: a.name, description: a.description),
    ],
    routes: routes,
    ours: ours,
  );
}

Map<int, PortOwner> _scanPortOwners(Set<int> ports) {
  final listeners = _readListeners();
  final names = _readProcessNames();
  return {
    for (final port in ports)
      if (listeners[port] case final pid?)
        port: PortOwner(pid: pid, name: names[pid] ?? ''),
  };
}

List<String> _scanDnsServers() {
  final servers = <String>[];
  for (final adapter in _readAdapters()) {
    for (final server in adapter.dns) {
      if (!servers.contains(server)) servers.add(server);
    }
  }
  return servers;
}

/// The FFI scans block for tens of milliseconds on machines with many
/// adapters or processes, so each runs in its own isolate.
final class WindowsReader extends EnvironmentReader {
  @override
  String get hostsPath =>
      '${Platform.environment['SystemRoot'] ?? r'C:\Windows'}'
      r'\System32\drivers\etc\hosts';

  @override
  Future<SoftwareFact?> software({required bool deep}) =>
      Isolate.run(() => _scanSoftware(deep));

  @override
  Future<TunnelsFact?> tunnels({String? ours}) =>
      Isolate.run(() => _scanTunnels(ours));

  @override
  Future<SystemProxyFact?> systemProxy() async {
    final key = CURRENT_USER.open(_internetSettings);
    try {
      final enabled = (key.getInt('ProxyEnable') ?? 0) != 0;
      final server = enabled ? key.getString('ProxyServer') ?? '' : '';
      final parsed = parseProxyServer(server);
      return SystemProxyFact(
        enabled: enabled && parsed.host.isNotEmpty,
        host: parsed.host,
        port: parsed.port,
        pac: key.getString('AutoConfigURL') ?? '',
      );
    } finally {
      key.close();
    }
  }

  @override
  Future<Map<int, PortOwner>?> portOwners(Set<int> ports) =>
      Isolate.run(() => _scanPortOwners(ports));

  @override
  Future<Set<int>> reservedPorts(Set<int> ports) async {
    final reserved = <int>{};
    for (final port in ports) {
      try {
        final socket = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          port,
        );
        await socket.close();
      } on SocketException catch (error) {
        if (error.osError?.errorCode == 10013) reserved.add(port);
      }
    }
    return reserved;
  }

  @override
  Future<List<String>?> dnsServers() => Isolate.run(_scanDnsServers);

  @override
  Future<bool> openHosts() async {
    final execute = _shell32.lookupFunction<_ExecC, _ExecD>('ShellExecuteW');
    final verb = 'runas'.toNativeUtf16();
    final file = 'notepad.exe'.toNativeUtf16();
    final parameters = hostsPath.toNativeUtf16();
    try {
      return execute(0, verb, file, parameters, nullptr, 1) > 32;
    } on Object {
      return false;
    } finally {
      calloc
        ..free(verb)
        ..free(file)
        ..free(parameters);
    }
  }
}
