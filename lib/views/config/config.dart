import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/util/context.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/widgets/widgets.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: context.appLocalizations.basicConfig,
      body: const GeneralListView(),
    );
  }
}
