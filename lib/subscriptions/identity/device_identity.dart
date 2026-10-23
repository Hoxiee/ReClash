import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/path.dart';
import 'package:reclash/common/constant.dart';
import 'package:win32_registry/win32_registry.dart';

const _appChannel = MethodChannel('$packageName/app');

/// Russian providers commonly refuse subscriptions to clients without an
/// HWID, so that region starts with sending on until the user chooses.
bool sendsDeviceIdentityByDefault(String? regionCode) => regionCode == 'RU';

class DeviceIdentity {
  const DeviceIdentity({
    required this.hwid,
    required this.source,
    required this.os,
    required this.osVersion,
    required this.model,
  });

  final String hwid;
  final String source;
  final String os;
  final String osVersion;
  final String model;

  Map<String, Object?> toJson() => {
    'hwid': hwid,
    'source': source,
    'os': os,
    'osVersion': osVersion,
    'model': model,
  };

  factory DeviceIdentity.fromJson(Map<String, dynamic> json) => DeviceIdentity(
    hwid: json['hwid'] as String,
    source: json['source'] as String,
    os: json['os'] as String,
    osVersion: json['osVersion'] as String,
    model: json['model'] as String,
  );
}

class DeviceIdentityConsent {
  const DeviceIdentityConsent({
    required this.profileId,
    required this.origin,
    required this.sendDetails,
  });

  final int profileId;
  final String origin;
  final bool sendDetails;

  Map<String, Object?> toJson() => {
    'profileId': profileId,
    'origin': origin,
    'sendDetails': sendDetails,
  };

  factory DeviceIdentityConsent.fromJson(Map<String, dynamic> json) =>
      DeviceIdentityConsent(
        profileId: json['profileId'] as int,
        origin: json['origin'] as String,
        sendDetails: json['sendDetails'] as bool? ?? false,
      );
}

class DeviceIdentityMaterial {
  const DeviceIdentityMaterial({
    required this.value,
    required this.source,
    required this.os,
    required this.osVersion,
    required this.model,
  });

  final String value;
  final String source;
  final String os;
  final String osVersion;
  final String model;
}

abstract interface class DeviceIdentityStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class FileDeviceIdentityStorage implements DeviceIdentityStorage {
  const FileDeviceIdentityStorage(this.file);

  final File file;
  static const fileName = 'subscription-device.json';

  static Future<File> defaultFile() async {
    if (Platform.isAndroid) {
      final path = await _appChannel.invokeMethod<String>(
        'deviceIdentityStoragePath',
      );
      if (path == null || path.isEmpty) {
        throw StateError('Device-local storage unavailable');
      }
      return File(path);
    }
    return File(p.join(await appPath.homeDirPath, fileName));
  }

  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    if (await file.length() > 64 * 1024) {
      throw const FormatException('Device-local storage exceeds limit');
    }
    return file.readAsString();
  }

  @override
  Future<void> write(String value) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(value, flush: true);
    await temporary.rename(file.path);
  }
}

class DeviceIdentityStore {
  DeviceIdentityStore({required this.storage, required this.source});

  final DeviceIdentityStorage storage;
  final Future<DeviceIdentityMaterial?> Function() source;
  Future<void> _tail = Future<void>.value();
  Map<String, dynamic>? _document;

  static final Map<String, DeviceIdentityStore> _defaultStores = {};

  static Future<DeviceIdentityStore> create() async {
    final file = await FileDeviceIdentityStorage.defaultFile();
    final key = p.normalize(p.absolute(file.path));
    return _defaultStores.putIfAbsent(
      key,
      () => DeviceIdentityStore(
        storage: FileDeviceIdentityStorage(file),
        source: readDeviceIdentityMaterial,
      ),
    );
  }

  Future<bool> globalSendEnabled({bool byDefault = false}) =>
      _serialized(() async {
        try {
          final document = await _load();
          return document['globalSendEnabled'] as bool? ?? byDefault;
        } on Object {
          return byDefault;
        }
      });

  Future<void> setGlobalSendEnabled(bool enabled) => _serialized(() async {
    final document = await _load();
    document['globalSendEnabled'] = enabled;
    await _save(document);
  });

  Future<bool?> profileSendOverride(int profileId) => _serialized(() async {
    try {
      final document = await _load();
      final overrides =
          document['profileSendOverrides'] as Map<String, dynamic>;
      return overrides['$profileId'] as bool?;
    } on Object {
      return null;
    }
  });

  Future<void> setProfileSendOverride(int profileId, bool? enabled) =>
      _serialized(() async {
        final document = await _load();
        final overrides =
            document['profileSendOverrides'] as Map<String, dynamic>;
        if (enabled == null) {
          overrides.remove('$profileId');
        } else {
          overrides['$profileId'] = enabled;
        }
        await _save(document);
      });

  Future<void> allow(int profileId, Uri origin, {bool sendDetails = false}) =>
      _serialized(() async {
        final document = await _load();
        final canonicalOrigin = normalizeIdentityOrigin(origin);
        final consents = document['consents'] as List<dynamic>;
        consents.removeWhere((raw) {
          final item = DeviceIdentityConsent.fromJson(
            raw as Map<String, dynamic>,
          );
          return item.profileId == profileId && item.origin == canonicalOrigin;
        });
        consents.add(
          DeviceIdentityConsent(
            profileId: profileId,
            origin: canonicalOrigin,
            sendDetails: sendDetails,
          ).toJson(),
        );
        await _save(document);
      });

  Future<void> revoke(int profileId, [Uri? origin]) => _serialized(() async {
    final document = await _load();
    final canonicalOrigin = origin == null
        ? null
        : normalizeIdentityOrigin(origin);
    (document['consents'] as List<dynamic>).removeWhere((raw) {
      final item = DeviceIdentityConsent.fromJson(raw as Map<String, dynamic>);
      return item.profileId == profileId &&
          (canonicalOrigin == null || item.origin == canonicalOrigin);
    });
    if (origin == null) {
      (document['profileSendOverrides'] as Map<String, dynamic>).remove(
        '$profileId',
      );
    }
    await _save(document);
  });

  Future<DeviceIdentityConsent?> consent(int profileId, Uri origin) =>
      _serialized(() async {
        try {
          final document = await _load();
          final canonicalOrigin = normalizeIdentityOrigin(origin);
          for (final raw in document['consents'] as List<dynamic>) {
            final item = DeviceIdentityConsent.fromJson(
              raw as Map<String, dynamic>,
            );
            if (item.profileId == profileId && item.origin == canonicalOrigin) {
              return item;
            }
          }
        } catch (_) {
          return null;
        }
        return null;
      });

  Future<Map<String, String>?> requestFields(
    int profileId,
    Uri origin, {
    bool sendByDefault = false,
  }) => _serialized(() async {
    try {
      final document = await _load();
      final overrides =
          document['profileSendOverrides'] as Map<String, dynamic>;
      final enabled =
          overrides['$profileId'] as bool? ??
          document['globalSendEnabled'] as bool? ??
          sendByDefault;
      if (!enabled) return null;
      final permission = await _consentLocked(profileId, origin);
      final value = await _identityLocked();
      if (value == null) return null;
      final fields = <String, String>{'x-hwid': value.hwid};
      if (permission?.sendDetails == true) {
        if (value.os.isNotEmpty) fields['x-device-os'] = value.os;
        if (value.osVersion.isNotEmpty) {
          fields['x-ver-os'] = value.osVersion;
        }
        if (value.model.isNotEmpty) fields['x-device-model'] = value.model;
      }
      return fields;
    } on Object {
      return null;
    }
  });

  Future<DeviceIdentity?> _identityLocked() async {
    try {
      final document = await _load();
      final saved = document['identity'];
      if (saved is Map<String, dynamic>) return DeviceIdentity.fromJson(saved);

      DeviceIdentityMaterial? material;
      try {
        material = await source();
      } on Object {
        material = null;
      }
      final rawValue = material?.value.trim();
      final actual = rawValue == null || rawValue.isEmpty
          ? _randomMaterial()
          : material!;
      final identity = _derive(actual);
      document['identity'] = identity.toJson();
      await _save(document);
      return identity;
    } on Object {
      return null;
    }
  }

  Future<DeviceIdentityConsent?> _consentLocked(
    int profileId,
    Uri origin,
  ) async {
    final document = await _load();
    final canonicalOrigin = normalizeIdentityOrigin(origin);
    for (final raw in document['consents'] as List<dynamic>) {
      final item = DeviceIdentityConsent.fromJson(raw as Map<String, dynamic>);
      if (item.profileId == profileId && item.origin == canonicalOrigin) {
        return item;
      }
    }
    return null;
  }

  Future<T> _serialized<T>(Future<T> Function() operation) async {
    final previous = _tail;
    final release = Completer<void>();
    _tail = release.future;
    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }

  Future<Map<String, dynamic>> _load() async {
    if (_document != null) return _document!;
    final raw = await storage.read();
    final value = raw == null
        ? <String, dynamic>{'version': 1, 'consents': <dynamic>[]}
        : jsonDecode(raw) as Map<String, dynamic>;
    value.putIfAbsent('profileSendOverrides', () => <String, dynamic>{});
    if (value['version'] != 1 ||
        value['consents'] is! List ||
        (value['consents'] as List).length > 512 ||
        (value['globalSendEnabled'] != null &&
            value['globalSendEnabled'] is! bool) ||
        value['profileSendOverrides'] is! Map ||
        (value['profileSendOverrides'] as Map).length > 512 ||
        (value['profileSendOverrides'] as Map).entries.any(
          (entry) =>
              entry.key is! String ||
              int.tryParse(entry.key as String) == null ||
              entry.value is! bool,
        )) {
      throw const FormatException('Invalid device-local state');
    }
    for (final item in value['consents'] as List) {
      final consent = DeviceIdentityConsent.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      if (consent.origin !=
          normalizeIdentityOrigin(Uri.parse(consent.origin))) {
        throw const FormatException('Invalid consent origin');
      }
    }
    if (value['identity'] case final Map identity) {
      final device = DeviceIdentity.fromJson(
        Map<String, dynamic>.from(identity),
      );
      if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(device.hwid) ||
          device.source.length > 64 ||
          device.os.length > 160 ||
          device.osVersion.length > 160 ||
          device.model.length > 160) {
        throw const FormatException('Invalid stored identity');
      }
    }
    _document = value;
    return value;
  }

  Future<void> _save(Map<String, dynamic> value) async {
    try {
      await storage.write(jsonEncode(value));
      _document = value;
    } catch (_) {
      _document = null;
      rethrow;
    }
  }

  DeviceIdentityMaterial _randomMaterial() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return DeviceIdentityMaterial(
      value: base64Url.encode(bytes),
      source: 'random',
      os: Platform.operatingSystem,
      osVersion: '',
      model: '',
    );
  }

  DeviceIdentity _derive(DeviceIdentityMaterial material) {
    final native = sha256.convert(
      utf8.encode('ReClash/HWID/v1\u0000${material.value}'),
    );
    return DeviceIdentity(
      hwid: native.toString().substring(0, 32),
      source: material.source,
      os: _wireDetail(material.os),
      osVersion: _wireDetail(material.osVersion),
      model: _wireDetail(material.model),
    );
  }
}

String normalizeIdentityOrigin(Uri origin) {
  final scheme = origin.scheme.toLowerCase();
  final host = origin.host.toLowerCase();
  if ((scheme != 'https' && scheme != 'http') ||
      host.isEmpty ||
      origin.userInfo.isNotEmpty) {
    throw ArgumentError.value(origin, 'origin', 'Expected an HTTP(S) origin');
  }
  final port =
      origin.hasPort &&
          !((scheme == 'https' && origin.port == 443) ||
              (scheme == 'http' && origin.port == 80))
      ? origin.port
      : null;
  return Uri(scheme: scheme, host: host, port: port).toString();
}

Future<DeviceIdentityMaterial?> readDeviceIdentityMaterial() async {
  if (Platform.isAndroid) {
    final values = await _appChannel.invokeMapMethod<String, Object?>(
      'deviceIdentity',
    );
    final value = values?['id']?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    return DeviceIdentityMaterial(
      value: value,
      source: 'android_id',
      os: 'android',
      osVersion: values?['osVersion']?.toString() ?? '',
      model: values?['model']?.toString() ?? '',
    );
  }
  final plugin = DeviceInfoPlugin();
  if (Platform.isMacOS) {
    final info = await plugin.macOsInfo;
    final value = info.systemGUID?.trim() ?? '';
    if (value.isEmpty) return null;
    return DeviceIdentityMaterial(
      value: value,
      source: 'system_guid',
      os: 'macos',
      osVersion: info.osRelease,
      model: info.model,
    );
  }
  if (Platform.isWindows) {
    final info = await plugin.windowsInfo;
    final key = LOCAL_MACHINE.open(r'SOFTWARE\Microsoft\Cryptography');
    try {
      final value = key.getValue('MachineGuid');
      final machineGuid = value is StringValue ? value.value.trim() : '';
      if (machineGuid.isEmpty) return null;
      return DeviceIdentityMaterial(
        value: machineGuid,
        source: 'machine_guid',
        os: 'windows',
        osVersion:
            '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
        model: '',
      );
    } finally {
      key.close();
    }
  }
  if (Platform.isLinux) {
    final machineId = (await File('/etc/machine-id').readAsString()).trim();
    if (machineId.isEmpty) return null;
    return DeviceIdentityMaterial(
      value: machineId,
      source: 'machine_id',
      os: 'linux',
      osVersion: Platform.operatingSystemVersion,
      model: '',
    );
  }
  return null;
}

String _wireDetail(String value) => value.runes
    .where((r) => r >= 32 && r <= 126)
    .take(160)
    .map(String.fromCharCode)
    .join();
