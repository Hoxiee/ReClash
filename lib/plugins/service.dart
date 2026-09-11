import 'dart:async';
import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/event.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class ServiceListener {
  void onServiceEvent(CoreEvent event) {}

  void onPauseStateChanged(bool paused) {}

  void onWidgetSelections(Map<String, String> selections) {}
}

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;

  final ObserverList<ServiceListener> _listeners =
      ObserverList<ServiceListener>();

  bool? _nativePaused;

  /// The service's own pause flag, or null before the first report.
  bool? get nativePaused => _nativePaused;

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Service._internal() {
    methodChannel = const MethodChannel('$packageName/service');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'pauseState':
          final paused = call.arguments as bool? ?? false;
          _nativePaused = paused;
          for (final listener in List.of(_listeners)) {
            listener.onPauseStateChanged(paused);
          }
          break;
        case 'widgetSelections':
          return _deliverWidgetSelections(call.arguments);
        case 'event':
          final data = call.arguments as String? ?? '';
          final methodCall = CoreMethodCall.fromJson(
            Map<String, Object?>.from(json.decode(data) as Map),
          );
          for (final event in coreEventsFromData(methodCall.arguments)) {
            for (final listener in List.of(_listeners)) {
              try {
                listener.onServiceEvent(event);
              } catch (error) {
                commonPrint.log(
                  'Unable to dispatch Android Core event '
                  '${event.type.name}: $error',
                  logLevel: LogLevel.error,
                );
              }
            }
          }
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  Future<CoreMethodResponse?> invokeMethod(CoreMethodCall call) async {
    final data = await methodChannel.invokeMethod<String>(
      'invokeMethod',
      json.encode(call),
    );
    if (data == null) {
      return null;
    }
    final dataJson = await data.decodeJson<dynamic>();
    return CoreMethodResponse.fromJson(dataJson);
  }

  Future<bool> start() async {
    return await methodChannel.invokeMethod<bool>('start') ?? false;
  }

  Future<bool> stop() async {
    return await methodChannel.invokeMethod<bool>('stop') ?? false;
  }

  Future<bool> pause() async {
    return await methodChannel.invokeMethod<bool>('pause') ?? false;
  }

  Future<bool> resume() async {
    return await methodChannel.invokeMethod<bool>('resume') ?? false;
  }

  Future<bool?> getPauseState() async {
    return methodChannel.invokeMethod<bool>('getPauseState');
  }

  /// Node picks made from the home-screen widget while Flutter was not running.
  Future<void> deliverPendingWidgetSelections() async {
    final batch = await methodChannel.invokeMethod<Object?>(
      'peekWidgetSelections',
    );
    final decoded = _decodeSelectionBatch(batch);
    if (decoded == null || !_dispatchWidgetSelections(decoded.selections)) {
      return;
    }
    await methodChannel.invokeMethod<bool>(
      'ackWidgetSelections',
      decoded.token,
    );
  }

  Future<bool> _deliverWidgetSelections(Object? data) async {
    final decoded = _decodeSelectionBatch(data);
    return decoded != null && _dispatchWidgetSelections(decoded.selections);
  }

  bool _dispatchWidgetSelections(Map<String, String> selections) {
    if (selections.isEmpty || _listeners.isEmpty) {
      return false;
    }
    for (final listener in List.of(_listeners)) {
      listener.onWidgetSelections(selections);
    }
    return true;
  }

  _WidgetSelectionBatch? _decodeSelectionBatch(Object? data) {
    try {
      final decoded = Map<String, Object?>.from(data! as Map);
      final token = decoded['token'];
      final selections = Map<String, Object?>.from(
        decoded['selections']! as Map,
      );
      if (token is! String || token.isEmpty) {
        return null;
      }
      return _WidgetSelectionBatch(token, {
        for (final entry in selections.entries)
          if (entry.value is String && (entry.value! as String).isNotEmpty)
            entry.key: entry.value! as String,
      });
    } catch (error) {
      commonPrint.log(
        'Unable to decode widget selections: $error',
        logLevel: LogLevel.error,
      );
      return null;
    }
  }

  Future<String> init() async {
    return await methodChannel.invokeMethod<String>('init') ?? '';
  }

  Future<String> syncState(SharedState state) async {
    return await methodChannel.invokeMethod<String>(
          'syncState',
          json.encode(state),
        ) ??
        '';
  }

  Future<bool> shutdown() async {
    return await methodChannel.invokeMethod<bool>('shutdown') ?? true;
  }

  Future<DateTime?> getRunTime() async {
    final ms = await methodChannel.invokeMethod<int>('getRunTime') ?? 0;
    if (ms == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ServiceListener listener) {
    _listeners.remove(listener);
  }
}

class _WidgetSelectionBatch {
  final String token;
  final Map<String, String> selections;

  const _WidgetSelectionBatch(this.token, this.selections);
}

Service? get service => system.isAndroid ? Service() : null;
