import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_doctor_path.dart';

part 'connection_doctor_cards.dart';
part 'connection_doctor_labels.dart';

class ConnectionDoctorView extends ConsumerStatefulWidget {
  const ConnectionDoctorView({super.key});

  @override
  ConsumerState<ConnectionDoctorView> createState() =>
      _ConnectionDoctorViewState();
}
