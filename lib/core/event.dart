import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

List<CoreEvent> coreEventsFromData(Object? data) {
  final items = data is List ? data : [data];
  final events = <CoreEvent>[];
  for (final item in items.whereType<Map>()) {
    try {
      events.add(CoreEvent.fromJson(Map<String, Object?>.from(item)));
    } catch (error) {
      commonPrint.log(
        'Unable to parse Core event: $error',
        logLevel: LogLevel.error,
      );
    }
  }
  return events;
}

abstract mixin class CoreEventListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onRequest(TrackerInfo connection) {}

  void onDnsQuery(DnsQuery dnsQuery) {}

  void onLoaded(String providerName) {}

  void onCrash(String message) {}

  void onGeoUpdate(
    String geoType,
    bool updating,
    bool skipped,
    String? error,
  ) {}

  void onRcxStatus(RcxStatus status) {}

  void onDoctorStatus(DoctorStatus status) {}

  void onRouteChanged(RouteSnapshot snapshot) {}

  void onScreenChanged(bool screenOff) {}
}

class CoreEventManager {
  CoreEventManager._();

  static final CoreEventManager instance = CoreEventManager._();

  final ObserverList<CoreEventListener> _listeners =
      ObserverList<CoreEventListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void sendEvent(CoreEvent event) {
    for (final CoreEventListener listener in List.of(_listeners)) {
      try {
        _dispatch(listener, event);
      } catch (error) {
        commonPrint.log(
          'Unable to dispatch Core event ${event.type.name}: $error',
          logLevel: LogLevel.error,
        );
      }
    }
  }

  void _dispatch(CoreEventListener listener, CoreEvent event) {
    switch (event.type) {
      case CoreEventType.log:
        listener.onLog(
          Log.fromJson(event.data).copyWith(source: LogSource.core),
        );
      case CoreEventType.delay:
        listener.onDelay(Delay.fromJson(event.data));
      case CoreEventType.request:
        listener.onRequest(TrackerInfo.fromJson(event.data));
      case CoreEventType.dns:
        listener.onDnsQuery(
          DnsQuery.fromJson(Map<String, Object?>.from(event.data as Map)),
        );
      case CoreEventType.loaded:
        listener.onLoaded(event.data);
      case CoreEventType.crash:
        listener.onCrash(event.data);
      case CoreEventType.rcxStatus:
        listener.onRcxStatus(
          RcxStatus.fromJson(Map<String, Object?>.from(event.data as Map)),
        );
      case CoreEventType.doctorStatus:
        listener.onDoctorStatus(
          DoctorStatus.fromJson(Map<String, Object?>.from(event.data as Map)),
        );
      case CoreEventType.routeChanged:
        listener.onRouteChanged(
          RouteSnapshot.fromJson(Map<String, Object?>.from(event.data as Map)),
        );
      case CoreEventType.screenChanged:
        listener.onScreenChanged(event.data as bool);
      case CoreEventType.geoUpdate:
        final data = event.data as Map<String, dynamic>;
        listener.onGeoUpdate(
          data['type'] as String,
          data['updating'] as bool,
          data['skipped'] as bool? ?? false,
          data['error'] as String?,
        );
    }
  }

  void addListener(CoreEventListener listener) {
    _listeners.add(listener);
  }

  void removeListener(CoreEventListener listener) {
    _listeners.remove(listener);
  }
}

final coreEventManager = CoreEventManager.instance;
