import 'package:reclash/core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/core.g.dart';

@Riverpod(keepAlive: true)
CoreHandlerInterface coreHandler(Ref ref) => coreHandlerInstance;
