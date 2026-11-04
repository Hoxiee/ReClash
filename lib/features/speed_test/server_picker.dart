import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'result.dart';

class SpeedTestServerPicker extends ConsumerStatefulWidget {
  const SpeedTestServerPicker({super.key});

  @override
  ConsumerState<SpeedTestServerPicker> createState() =>
      _SpeedTestServerPickerState();
}

class _SpeedTestServerPickerState extends ConsumerState<SpeedTestServerPicker> {
  final _search = TextEditingController();
  late final SpeedTestServers _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(speedTestServersProvider.notifier);
  }

  @override
  void dispose() {
    _search.dispose();
    scheduleMicrotask(_notifier.cancel);
    super.dispose();
  }

  void _select(SpeedTestServer? server) {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (value) => value.copyWith(
            speedTest: value.speedTest.copyWith(
              server: server,
              clearServer: server == null,
            ),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final results = ref.watch(speedTestServersProvider);
    final selected = ref.watch(
      appSettingProvider.select((value) => value.speedTest.server),
    );
    return CommonScaffold(
      title: l.speedTestChooseServer,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding + 12,
          16,
          context.bottomInset + 24,
        ),
        children: [
          SearchField(
            controller: _search,
            hintText: l.speedTestServerSearch,
            onSubmitted: () => unawaited(_notifier.search(_search.text)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: results?.isLoading == true
                  ? null
                  : () => _notifier.search(_search.text),
              icon: results?.isLoading == true
                  ? const CommonCircleLoading(size: 18)
                  : const GlyphIcon(AppGlyphs.search, fill: 1, size: 18),
              label: Text(l.speedTestFindServers),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.speedTestServerPrivacy,
            style: AppTextStyle.footnote.of(context),
          ),
          const SizedBox(height: 16),
          CommonCard(
            child: ListItem(
              title: Text(l.speedTestServerAutomatic),
              isSelected: selected == null,
              trailing: selected == null ? const SelectionCheck() : null,
              onTap: () => _select(null),
            ),
          ),
          if (results?.hasError == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l.speedTestServerFailed,
                style: AppTextStyle.body
                    .of(context)
                    .copyWith(color: context.colorScheme.error),
              ),
            ),
          if (results?.value case final servers?) ...[
            if (servers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.speedTestNoServers),
              ),
            for (final server in servers)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CommonCard(
                  child: ListItem(
                    title: Text(
                      server.title.isEmpty ? server.host : server.title,
                    ),
                    subtitle: Text(
                      [
                        server.country,
                        server.host,
                        if (server.latencyMs case final latency?)
                          l.speedTestMs(speedTestNumber(latency)),
                      ].where((value) => value.isNotEmpty).join(' · '),
                    ),
                    isSelected: selected?.host == server.host,
                    trailing: selected?.host == server.host
                        ? const SelectionCheck()
                        : null,
                    onTap: () => _select(server),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
