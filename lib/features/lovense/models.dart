import 'dart:convert';
import 'dart:io';

const lovenseDefaultAddress = 'https://127-0-0-1.lovense.club:30010';
const lovenseMinDuration = 2;
const lovenseMaxDuration = 60;

enum LovenseErrorKind {
  invalidAddress,
  invalidCommand,
  unavailable,
  timeout,
  tls,
  invalidResponse,
  remote,
  cancelled,
}

class LovenseError extends Error {
  LovenseError(this.kind, {this.code});

  final LovenseErrorKind kind;
  final int? code;

  @override
  String toString() => 'LovenseError(${kind.name}, code: $code)';
}

class LovenseEndpoint {
  const LovenseEndpoint._(this.uri, this.address);

  final Uri uri;
  final InternetAddress address;

  String get displayAddress => uri.replace(path: '').toString();

  factory LovenseEndpoint.parse(String value) {
    try {
      final input = value.trim();
      if (input.isEmpty) throw const FormatException();
      final uri = Uri.parse(input.contains('://') ? input : 'https://$input');
      if (!{'http', 'https'}.contains(uri.scheme) ||
          !uri.hasAuthority ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          !{'', '/', '/command'}.contains(uri.path)) {
        throw const FormatException();
      }
      final port = uri.hasPort
          ? uri.port
          : uri.scheme == 'https'
          ? 30010
          : 20010;
      if (port < 1 || port > 65535) throw const FormatException();
      final host = uri.host.toLowerCase();
      InternetAddress? address;
      if (host == 'localhost') {
        address = InternetAddress.loopbackIPv4;
      } else if (host.endsWith('.lovense.club')) {
        final match = RegExp(
          r'^(\d{1,3})-(\d{1,3})-(\d{1,3})-(\d{1,3})\.lovense\.club$',
        ).firstMatch(host);
        if (match != null) {
          address = InternetAddress.tryParse(
            List.generate(4, (index) => match.group(index + 1)!).join('.'),
          );
        }
      } else {
        address = InternetAddress.tryParse(host);
      }
      if (address == null || !_isLocal(address)) {
        throw const FormatException();
      }
      final String requestHost;
      if (address.type == InternetAddressType.IPv4) {
        requestHost = '${address.address.replaceAll('.', '-')}.lovense.club';
      } else {
        requestHost = address.address;
      }
      return LovenseEndpoint._(
        Uri(
          scheme: uri.scheme,
          host: requestHost,
          port: port,
          path: '/command',
        ),
        address,
      );
    } on FormatException {
      throw LovenseError(LovenseErrorKind.invalidAddress);
    } on ArgumentError {
      throw LovenseError(LovenseErrorKind.invalidAddress);
    }
  }

  static bool _isLocal(InternetAddress address) {
    if (address.isLoopback) return true;
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      return bytes[0] == 10 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
          (bytes[0] == 192 && bytes[1] == 168) ||
          (bytes[0] == 169 && bytes[1] == 254);
    }
    return (bytes[0] & 0xfe) == 0xfc ||
        (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80);
  }
}

enum LovenseFunction {
  vibrate('Vibrate', 20, 'v'),
  rotate('Rotate', 20, 'r'),
  pump('Pump', 3, 'p'),
  thrusting('Thrusting', 20, 't'),
  fingering('Fingering', 20, 'f'),
  suction('Suction', 20, 's'),
  depth('Depth', 3, 'd'),
  oscillate('Oscillate', 20, 'o');

  const LovenseFunction(this.apiName, this.maxStrength, this.shortName);

  final String apiName;
  final int maxStrength;
  final String shortName;
}

class LovenseStroke {
  const LovenseStroke(this.start, this.end);

  final int start;
  final int end;

  bool get isValid => start >= 0 && end <= 100 && end - start >= 20;
}

class LovenseToy {
  LovenseToy({
    required this.id,
    required this.name,
    required this.connected,
    this.nickName = '',
    this.battery,
    List<LovenseFunction> functions = const [LovenseFunction.vibrate],
    this.hasFunctionInfo = false,
    this.supportsStroke = false,
  }) : functions = List.unmodifiable(functions);

  final String id;
  final String name;
  final String nickName;
  final bool connected;
  final int? battery;
  final List<LovenseFunction> functions;
  final bool hasFunctionInfo;
  final bool supportsStroke;

  String get displayName => nickName.trim().isEmpty ? name : nickName;

  factory LovenseToy.fromJson(Map<String, dynamic> json, String fallbackId) {
    final id = json['id'] as String? ?? fallbackId;
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(id)) {
      throw LovenseError(LovenseErrorKind.invalidResponse);
    }
    final full = json['fullFunctionNames'];
    final short = json['shortFunctionNames'];
    if ((full != null && full is! List) || (short != null && short is! List)) {
      throw LovenseError(LovenseErrorKind.invalidResponse);
    }
    final hasFunctions = full is List || short is List;
    final names =
        (full is List
                ? full
                : short is List
                ? short
                : const [])
            .whereType<String>()
            .map((name) => name.toLowerCase())
            .toSet();
    final battery = int.tryParse('${json['battery']}');
    return LovenseToy(
      id: id,
      name: _text(json['name'], fallback: 'Lovense'),
      nickName: _text(json['nickName']),
      connected: json['status'] == true || '${json['status']}' == '1',
      battery: battery != null && battery >= 0 && battery <= 100
          ? battery
          : null,
      functions: hasFunctions
          ? LovenseFunction.values
                .where(
                  (function) =>
                      names.contains(function.apiName.toLowerCase()) ||
                      names.contains(function.shortName),
                )
                .toList()
          : const [LovenseFunction.vibrate],
      hasFunctionInfo: hasFunctions,
      supportsStroke: names.contains('stroke'),
    );
  }

  static String _text(Object? value, {String fallback = ''}) {
    if (value is! String || value.trim().isEmpty) return fallback;
    return value.length > 256 ? value.substring(0, 256) : value;
  }
}

List<LovenseToy> parseLovenseToys(Object? raw) {
  try {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is! Map || decoded.length > 100) {
      throw LovenseError(LovenseErrorKind.invalidResponse);
    }
    final toys = <LovenseToy>[];
    for (final entry in decoded.entries) {
      if (entry.key is! String || entry.value is! Map) {
        throw LovenseError(LovenseErrorKind.invalidResponse);
      }
      toys.add(
        LovenseToy.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
          entry.key as String,
        ),
      );
    }
    toys.sort((a, b) => a.displayName.compareTo(b.displayName));
    return List.unmodifiable(toys);
  } on FormatException {
    throw LovenseError(LovenseErrorKind.invalidResponse);
  } on TypeError {
    throw LovenseError(LovenseErrorKind.invalidResponse);
  }
}
