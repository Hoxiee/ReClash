import 'package:reclash/common/common.dart';

import 'interface.dart';
import 'lib.dart';
import 'service.dart';

export 'desktop/model.dart';
export 'event.dart';
export 'handler_actions.dart';
export 'interface.dart';
export 'lib.dart';
export 'method.dart';
export 'service.dart';

/// The platform's live core handler: the Android library on mobile, the desktop
/// service elsewhere. Both carry the [CoreHandlerActions] helpers.
CoreHandlerInterface get coreHandlerInstance =>
    system.isAndroid ? coreLib! : coreService!;
