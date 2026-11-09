import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
  final control = defaultTargetPlatform != TargetPlatform.macOS;
  return SingleActivator(trigger, control: control, meta: !control);
}
