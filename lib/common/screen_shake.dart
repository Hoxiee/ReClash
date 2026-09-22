import 'package:flutter/widgets.dart';

/// Screen-wide impact offset in logical pixels. The app root translates its
/// whole subtree by this, so a transient effect — the hero orb's big bang, for
/// one — recoils the real UI, not just a layer floating over it: a smooth
/// overlay sliding over static content reads as nothing moving, while the
/// sharp app frame jumping is what the eye feels as a hit. `Offset.zero` at
/// rest; a driver clears it back to zero when its effect ends.
final ValueNotifier<Offset> screenImpactOffset = ValueNotifier<Offset>(
  Offset.zero,
);
