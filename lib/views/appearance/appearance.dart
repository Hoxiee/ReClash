import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'color_tab.dart';
import 'layout_tab.dart';
import 'motion_tab.dart';
import 'theme_tab.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.appearance,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: appLocalizations.appearanceTheme),
                Tab(text: appLocalizations.appearanceColor),
                Tab(text: appLocalizations.appearanceLayout),
                Tab(text: appLocalizations.appearanceMotion),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AppearanceThemeTab(),
                  AppearanceColorTab(),
                  AppearanceLayoutTab(),
                  AppearanceMotionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
