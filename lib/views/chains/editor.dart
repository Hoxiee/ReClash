import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/proxies/routing_country.dart';
import 'package:reclash/widgets/widgets.dart';

import 'issues.dart';
import 'marks.dart';

/// Opens the one sheet that makes, shows and fixes a chain.
Future<void> showChainEditor(BuildContext context, {ProxyChain? chain}) {
  if (chain != null && isProviderChainId(chain.id)) {
    return _offerCopy(context, chain);
  }
  return showSheet<void>(
    context: context,
    props: const SheetProps(detents: [0.9]),
    builder: (_) => ChainEditor(chain: chain),
  );
}

/// A provider updates its chains with the manifest, so a change would be lost.
Future<void> _offerCopy(BuildContext context, ProxyChain chain) async {
  final l = context.appLocalizations;
  final container = ProviderScope.containerOf(context, listen: false);
  final confirmed = await dialogs.showMessage(
    message: TextSpan(text: l.chainsProviderManaged(chainTitle(chain))),
    confirmText: l.chainsDuplicate,
  );
  if (confirmed != true) return;
  await globalState.safeRun(
    () => container
        .read(proxyChainsActionProvider.notifier)
        .copyProviderChain(chain),
    silence: false,
  );
}

enum ChainHopSlot { entry, middle, exit }

/// Names a chain can't go through: the Core's built-in outbounds.
const _builtins = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'PASS',
  'PASS-RULE',
  'COMPATIBLE',
  'GLOBAL',
};

const _maxIssues = 3;

class ChainEditor extends ConsumerStatefulWidget {
  const ChainEditor({super.key, this.chain});

  final ProxyChain? chain;

  @override
  ConsumerState<ChainEditor> createState() => _ChainEditorState();
}

class _ChainEditorState extends ConsumerState<ChainEditor> {
  String? _entry;
  String? _middle;
  String? _exit;
  bool _hasMiddle = false;
  String? _name;
  bool _offered = true;
  String? _targetGroup;
  ChainHopSlot? _picking;
  bool _changed = false;
  bool _saving = false;

  ChainInspection? _inspection;
  Map<String, ChainIssueCode> _blocked = const {};
  ChainDelay? _delays;
  Timer? _inspectTimer;
  int _inspectRevision = 0;

  ProxyChain? get _chain => widget.chain;

  @override
  void initState() {
    super.initState();
    final chain = _chain;
    if (chain == null) {
      _picking = ChainHopSlot.entry;
    } else {
      _entry = chain.entry;
      _exit = chain.exit;
      _middle = chain.middle;
      _hasMiddle = chain.middle != null;
      _name = chain.nameAuto ? null : chain.name;
      _offered = chain.offered;
      _targetGroup = chain.targetGroup;
      unawaited(_testDelay());
    }
    _scheduleInspect(immediate: true);
  }

  @override
  void dispose() {
    _inspectTimer?.cancel();
    super.dispose();
  }

  List<String?> get _slots => [_entry, if (_hasMiddle) _middle, _exit];

  List<ChainHopSlot> get _order => [
    ChainHopSlot.entry,
    if (_hasMiddle) ChainHopSlot.middle,
    ChainHopSlot.exit,
  ];

  List<String>? get _hops {
    final slots = _slots;
    if (slots.any((hop) => hop == null || hop.isEmpty)) return null;
    return slots.cast<String>();
  }

  String? _valueOf(ChainHopSlot slot) => switch (slot) {
    ChainHopSlot.entry => _entry,
    ChainHopSlot.middle => _middle,
    ChainHopSlot.exit => _exit,
  };

  void _scheduleInspect({bool immediate = false}) {
    _inspectTimer?.cancel();
    if (immediate) {
      unawaited(_inspect());
      return;
    }
    _inspectTimer = Timer(const Duration(milliseconds: 150), _inspect);
  }

  Future<void> _inspect() async {
    final revision = ++_inspectRevision;
    final action = ref.read(proxyChainsActionProvider.notifier);
    final hops = _hops;
    final picking = _picking;
    try {
      final whole = hops == null
          ? null
          : await action.inspect(hops, targetGroup: _targetGroup);
      Map<String, ChainIssueCode> blocked = const {};
      if (picking != null) {
        final (slotHops, slot) = _slotQuery(picking);
        blocked = (await action.inspect(
          slotHops,
          slot: slot,
          targetGroup: _targetGroup,
        )).blocked;
      }
      if (!mounted || revision != _inspectRevision) return;
      setState(() {
        _inspection = whole;
        _blocked = blocked;
      });
    } catch (error) {
      commonPrint.log('Chain inspect failed: $error');
    }
  }

  /// The hops and the slot the Core checks candidates for: a trailing empty
  /// slot is appended, an inner one is replaced.
  (List<String>, int) _slotQuery(ChainHopSlot picking) {
    final order = _order;
    final index = order.indexOf(picking);
    final values = [for (final slot in order) _valueOf(slot) ?? ''];
    final rest = values.skip(index + 1).every((value) => value.isEmpty);
    if (values[index].isEmpty && rest) {
      return (values.take(index).toList(), index);
    }
    return (values, index);
  }

  Future<void> _testDelay() async {
    final chain = _chain;
    if (chain == null || _changed) return;
    final delays = await ref
        .read(proxyChainsActionProvider.notifier)
        .testDelay(chain);
    if (!mounted || _changed) return;
    setState(() => _delays = delays);
  }

  void _pick(ChainHopSlot slot) {
    setState(() {
      _picking = slot;
      _blocked = const {};
    });
    _scheduleInspect(immediate: true);
  }

  void _fill(ChainHopSlot slot, String name) {
    setState(() {
      switch (slot) {
        case ChainHopSlot.entry:
          _entry = name;
        case ChainHopSlot.middle:
          _middle = name;
        case ChainHopSlot.exit:
          _exit = name;
      }
      _changed = true;
      _delays = null;
      _picking = _order.where((slot) => _valueOf(slot) == null).firstOrNull;
      _blocked = const {};
    });
    _scheduleInspect();
  }

  void _addMiddle() {
    setState(() {
      _hasMiddle = true;
      _middle = null;
      _changed = true;
      _delays = null;
    });
    _pick(ChainHopSlot.middle);
  }

  void _removeMiddle() {
    setState(() {
      _hasMiddle = false;
      _middle = null;
      _changed = true;
      _delays = null;
    });
    _scheduleInspect();
  }

  Future<void> _rename() async {
    final l = context.appLocalizations;
    final hops = _hops;
    final value = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: l.name,
        value: _name ?? (hops == null ? '' : chainHopsTitle(hops)),
        labelText: l.name,
      ),
    );
    if (value == null || !mounted) return;
    final typed = value.trim();
    setState(() {
      _name =
          typed.isEmpty ||
              (hops != null &&
                  (typed == autoChainName(hops) ||
                      typed == chainHopsTitle(hops)))
          ? null
          : typed;
      _changed = true;
    });
  }

  Future<void> _save() async {
    final hops = _hops;
    if (hops == null || _saving) return;
    final action = ref.read(proxyChainsActionProvider.notifier);
    setState(() => _saving = true);
    final saved = await globalState.safeRun(() async {
      final chain = _chain;
      final name = _name?.trim() ?? '';
      if (chain == null) {
        final profileId = ref.read(currentProfileIdProvider);
        if (profileId == null) return false;
        await action.create(
          profileId: profileId,
          hops: hops,
          name: name,
          offered: _offered,
          targetGroup: _targetGroup,
        );
      } else {
        await action.update(
          chain.copyWith(
            hops: hops,
            name: name.isEmpty ? chain.name : name,
            nameAuto: name.isEmpty,
            offered: _offered,
            targetGroup: _targetGroup,
          ),
        );
      }
      return true;
    }, silence: false);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved == true) {
      _changed = false;
      context.safeNestedPop();
    }
  }

  Future<void> _delete() async {
    final chain = _chain;
    if (chain == null) return;
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: l.chainsDeleteConfirm(chainTitle(chain))),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(proxyChainsActionProvider.notifier).delete(chain);
    if (!mounted) return;
    _changed = false;
    context.safeNestedPop();
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l = context.appLocalizations;
    final discard = await dialogs.showMessage(
      title: l.chainsDiscardTitle,
      message: const TextSpan(),
      confirmText: l.chainsDiscard,
      destructive: true,
    );
    return discard == true;
  }

  String get _offeredGroup {
    if (_targetGroup case final target?) return target;
    return ref.watch(chainMainGroupProvider)?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final chain = _chain;
    final report = chain == null
        ? null
        : ref.watch(chainReportProvider(chain.id));
    final hops = _hops;
    final inspection = _inspection;
    final canSave =
        !_saving &&
        hops != null &&
        inspection != null &&
        !inspection.blocksSave &&
        (chain == null || _changed);
    final broken =
        !_changed && _picking == null && report != null && report.isBroken;
    final issues = _changed || report == null
        ? inspection?.issues ?? const <ChainIssue>[]
        : report.issues;
    final picking = _picking;
    final Widget body = switch ((picking, broken)) {
      (final slot?, _) => _HopPicker(
        key: ValueKey(slot),
        slot: slot,
        current: _valueOf(slot),
        entry: _entry,
        blocked: _blocked,
        onPicked: (name) => _fill(slot, name),
      ),
      (null, true) => _BrokenBody(
        chain: chain!,
        report: report!,
        onTake: (slot, name) => _fill(slot, name),
        onPick: _pick,
        onDelete: _delete,
      ),
      _ => _ReadyBody(
        order: _order,
        valueOf: _valueOf,
        hasMiddle: _hasMiddle,
        issues: issues,
        hops: hops ?? const [],
        name: _name ?? (hops == null ? '' : chainHopsTitle(hops)),
        offered: _offered,
        offeredGroup: _offeredGroup,
        onPick: _pick,
        onAddMiddle: _addMiddle,
        onRemoveMiddle: _removeMiddle,
        onRename: _rename,
        onOffered: (value) => setState(() {
          _offered = value;
          _changed = true;
        }),
        onTargetGroup: (group) {
          setState(() {
            _targetGroup = group;
            _offered = true;
            _changed = true;
          });
          _scheduleInspect();
        },
        onDelete: chain == null ? null : _delete,
        onRefresh: chain == null || _changed ? null : _testDelay,
      ),
    };
    return CommonPopScope(
      onPop: _changed ? _confirmDiscard : null,
      child: CommonScaffold(
        title: chain == null ? l.chainsNew : chainTitle(chain),
        isLoading: _saving,
        confirmationAction: IconButtonData(
          glyph: AppGlyphs.check,
          tooltip: l.save,
          onPressed: canSave ? _save : null,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                context.contentTopPadding + 8,
                16,
                8,
              ),
              child: ContextMenuRegion(
                menuItems: chain == null || _changed
                    ? null
                    : [
                        CommonPopupMenuItem(
                          label: l.chainsTest,
                          glyph: AppGlyphs.refresh,
                          onPressed: _testDelay,
                        ),
                      ],
                child: _EditorStrip(
                  order: _order,
                  valueOf: _valueOf,
                  picking: picking,
                  issues: issues,
                  delays: _delays,
                  onPick: _pick,
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _EditorStrip extends ConsumerWidget {
  const _EditorStrip({
    required this.order,
    required this.valueOf,
    required this.picking,
    required this.issues,
    required this.delays,
    required this.onPick,
  });

  final List<ChainHopSlot> order;
  final String? Function(ChainHopSlot slot) valueOf;
  final ChainHopSlot? picking;
  final List<ChainIssue> issues;
  final ChainDelay? delays;
  final ValueChanged<ChainHopSlot> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final missing = {
      for (final issue in issues)
        if (issue.code == ChainIssueCode.missingHop) issue.hop,
    };
    final complete = order.every((slot) => valueOf(slot) != null);
    final entryDelay = delays?.entry;
    final chainDelay = delays?.chain;
    var reachedEmpty = false;
    final nodes = <StripNode>[youNode(context)];
    final failed = <bool>[];
    for (final (index, slot) in order.indexed) {
      final value = valueOf(slot);
      final role = switch (slot) {
        ChainHopSlot.entry => l.chainsEntry,
        ChainHopSlot.middle => l.chainsMiddle,
        ChainHopSlot.exit => l.chainsExit,
      };
      if (slot == picking) {
        nodes.add(
          StripNode(
            label: role,
            caption: l.chainsCaptionPick,
            slot: ChainSlot.active,
            onTap: () => onPick(slot),
          ),
        );
        failed.add(false);
        reachedEmpty = true;
        continue;
      }
      if (value == null) {
        nodes.add(
          StripNode(
            label: role,
            caption: reachedEmpty ? l.chainsCaptionLater : l.chainsCaptionPick,
            slot: ChainSlot.empty,
            onTap: () => onPick(slot),
          ),
        );
        failed.add(false);
        reachedEmpty = true;
        continue;
      }
      if (missing.contains(index)) {
        nodes.add(
          StripNode(
            label: serverTitle(value),
            caption: l.chainsCaptionMissing,
            slot: ChainSlot.failed,
            captionTone: colorScheme.error,
            onTap: () => onPick(slot),
          ),
        );
        failed.add(true);
        continue;
      }
      final caption = switch (slot) {
        ChainHopSlot.entry when entryDelay != null && entryDelay > 0 =>
          l.chainsCaptionEntry(chainLatency(l, entryDelay)),
        ChainHopSlot.entry when entryDelay != null => l.chainsNoResponse,
        ChainHopSlot.entry => l.chainsRoleEntry,
        ChainHopSlot.middle => l.chainsCaptionMiddle,
        ChainHopSlot.exit => l.chainsCaptionExit,
      };
      nodes.add(
        StripNode(
          code: hopCountry(ref, value),
          group: GroupTypeExtension.getGroupType(_typeOf(ref, value)) != null,
          label: serverTitle(value),
          caption: caption,
          captionTone: slot == ChainHopSlot.entry && entryDelay == -1
              ? colorScheme.error
              : null,
          onTap: () => onPick(slot),
        ),
      );
      failed.add(false);
    }
    final anyFailed = failed.contains(true);
    nodes.add(
      StripNode(
        label: l.chainsInternet,
        caption: switch (chainDelay) {
          _ when anyFailed || (entryDelay != null && entryDelay <= 0) => '—',
          final delay? when delay > 0 => chainLatency(l, delay),
          _? => l.chainsNoResponse,
          null => '',
        },
        captionTone: chainDelay != null && chainDelay <= 0 && !anyFailed
            ? colorScheme.error
            : null,
        glyph: AppGlyphs.proxies,
      ),
    );
    final entrySeg = failed.first
        ? ChainSeg.fail
        : valueOf(ChainHopSlot.entry) == null
        ? ChainSeg.idle
        : entryDelay == null
        ? ChainSeg.ok
        : chainSegOf(entryDelay);
    final pathSeg = !complete || anyFailed
        ? ChainSeg.idle
        : chainDelay == null
        ? ChainSeg.ok
        : chainSegOf(chainDelay);
    final segments = [
      entrySeg,
      for (var index = 1; index < nodes.length - 1; index++)
        index < failed.length && failed[index] ? ChainSeg.fail : pathSeg,
    ];
    return RouteStrip(
      nodes: nodes,
      segments: segments,
      flag: order.length > 2 ? 40 : 44,
    );
  }
}

String _typeOf(WidgetRef ref, String name) {
  final groups = ref.watch(groupsProvider);
  for (final group in groups) {
    if (group.name == name) return group.type.name;
  }
  return '';
}

typedef _Candidate = ({
  String name,
  String search,
  String? code,
  Proxy proxy,
  Group? group,
});

typedef _Catalog = ({
  List<_Candidate> groups,
  List<_Candidate> leaves,
  Map<String, int> counts,
});

class _HopPicker extends ConsumerStatefulWidget {
  const _HopPicker({
    super.key,
    required this.slot,
    required this.current,
    required this.entry,
    required this.blocked,
    required this.onPicked,
  });

  final ChainHopSlot slot;
  final String? current;
  final String? entry;
  final Map<String, ChainIssueCode> blocked;
  final ValueChanged<String> onPicked;

  @override
  ConsumerState<_HopPicker> createState() => _HopPickerState();
}

class _HopPickerState extends ConsumerState<_HopPicker> {
  String _query = '';
  String? _country;
  _Catalog? _catalog;
  List<Group>? _catalogGroups;
  ChainGeneratedNames? _catalogNames;
  Map<String, ChainIssueCode>? _catalogBlocked;

  /// Finding a server's country scans every country name, so the catalog is
  /// rebuilt when the groups behind it change, never per keystroke.
  _Catalog _catalogOf(List<Group> all, ChainGeneratedNames names) {
    final blocked = widget.blocked;
    if (_catalog case final cached?
        when identical(all, _catalogGroups) &&
            identical(names, _catalogNames) &&
            identical(blocked, _catalogBlocked)) {
      return cached;
    }
    final groups = names.visibleGroups(all);
    bool usable(String name) =>
        !_builtins.contains(name) &&
        !names.groups.contains(name) &&
        !names.clones.contains(name) &&
        blocked[name] != ChainIssueCode.unchainableHop;
    final groupCandidates = <_Candidate>[
      for (final group in groups)
        if (group.hidden != true && usable(group.name))
          (
            name: group.name,
            search: group.name.toLowerCase(),
            code: countryOfHopName(group.name),
            proxy: Proxy(name: group.name, type: group.type.name),
            group: group,
          ),
    ];
    final seen = <String>{};
    final leaves = <_Candidate>[
      for (final group in groups)
        for (final proxy in group.all)
          if (GroupTypeExtension.getGroupType(proxy.type) == null &&
              usable(proxy.name) &&
              seen.add(proxy.name))
            (
              name: proxy.name,
              search: proxy.name.toLowerCase(),
              code: countryOfHopName(proxy.name),
              proxy: proxy,
              group: null,
            ),
    ];
    final counts = <String, int>{};
    for (final leaf in leaves) {
      if (leaf.code case final code?) counts[code] = (counts[code] ?? 0) + 1;
    }
    _catalogGroups = all;
    _catalogNames = names;
    _catalogBlocked = blocked;
    return _catalog = (groups: groupCandidates, leaves: leaves, counts: counts);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final slot = widget.slot;
    final catalog = _catalogOf(
      ref.watch(groupsProvider),
      ref.watch(chainGeneratedNamesProvider),
    );
    final region = ref
        .watch(appSettingProvider.select((setting) => setting.regionCode))
        ?.toLowerCase();
    final blocked = widget.blocked;
    final testUrl = ref.watch(chainMainGroupProvider)?.testUrl;
    final counts = catalog.counts;
    final countries = counts.keys.toList()
      ..sort((a, b) {
        if (a == region || b == region) {
          final first = slot == ChainHopSlot.entry ? a == region : b == region;
          return first ? -1 : 1;
        }
        return counts[b]!.compareTo(counts[a]!);
      });
    final query = _query.trim().toLowerCase();
    final countryNames = <String, String>{};
    bool matches(_Candidate candidate) {
      final code = candidate.code;
      if (_country != null && code != _country) return false;
      if (query.isEmpty || candidate.search.contains(query)) return true;
      return code != null &&
          countryNames
              .putIfAbsent(
                code,
                () => rcxCountryName(context, code.toUpperCase()).toLowerCase(),
              )
              .contains(query);
    }

    final shownGroups = catalog.groups.where(matches).toList();
    final shown = catalog.leaves.where(matches).toList();
    final home = region == null
        ? const <_Candidate>[]
        : [
            for (final candidate in shown)
              if (candidate.code == region) candidate,
          ];
    final abroad = region == null
        ? shown
        : [
            for (final candidate in shown)
              if (candidate.code != region) candidate,
          ];
    final homeName = region == null
        ? ''
        : nameWithoutFlag(rcxCountryName(context, region.toUpperCase()));
    Widget row(_Candidate candidate) => _HopRow(
      candidate: candidate,
      testUrl: testUrl,
      selected: candidate.name == widget.current,
      blocked: switch (blocked[candidate.name]) {
        final code? => chainBlockedReason(
          l,
          code,
          entry: serverTitle(widget.entry ?? ''),
        ),
        null => null,
      },
      onPressed: () => widget.onPicked(candidate.name),
    );
    final hint = switch (slot) {
      ChainHopSlot.entry =>
        region == 'ru'
            ? '${l.chainsPickEntryHint} ${l.chainsPickEntryHintRu}'
            : l.chainsPickEntryHint,
      ChainHopSlot.middle => l.chainsPickMiddleHint,
      ChainHopSlot.exit => l.chainsPickExitHint,
    };
    final entries = <Widget Function()>[];
    void section(String title, List<_Candidate> items) {
      if (items.isEmpty) return;
      entries.add(() => ListHeader(title: title));
      for (final (index, candidate) in items.indexed) {
        final position = ItemPosition.get(index, items.length);
        entries.add(
          () => ItemPositionProvider(position: position, child: row(candidate)),
        );
      }
    }

    section(l.chainsGroupsSection, shownGroups);
    if (slot == ChainHopSlot.entry) {
      section(l.chainsNearYou(homeName), home);
      section(home.isEmpty ? l.chainsServers : l.chainsOtherCountries, abroad);
    } else {
      section(region == null ? l.chainsServers : l.chainsAbroad, abroad);
      if (home.isNotEmpty && slot == ChainHopSlot.exit) {
        entries.add(() => ListFooter(text: l.chainsExitFooter(homeName)));
      }
      section(l.chainsNearYou(homeName), home);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    hint,
                    style: AppTextStyle.subheadline
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 12),
                SearchField(
                  hintText: l.chainsSearchHint,
                  fill: context.raisedSurfaceLevel.colorOf(context.colorScheme),
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (countries.length > 1) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final code = countries[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: _CountryChip(
                            code: code,
                            label:
                                '${nameWithoutFlag(rcxCountryName(context, code.toUpperCase()))}'
                                ' · ${counts[code]}',
                            selected: _country == code,
                            onPressed: () => setState(
                              () => _country = _country == code ? null : code,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + context.bottomInset),
          sliver: SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (_, index) => entries[index](),
          ),
        ),
      ],
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.code,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: AppCorner.full,
      isSelected: selected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 12, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            ShapeFlag(code: code, size: 22),
            Text(
              label,
              style: AppTextStyle.footnote.of(context, emphasized: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _HopRow extends ConsumerWidget {
  const _HopRow({
    required this.candidate,
    required this.testUrl,
    required this.selected,
    required this.blocked,
    required this.onPressed,
  });

  final _Candidate candidate;
  final String? testUrl;
  final bool selected;
  final String? blocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final blocked = this.blocked;
    final group = candidate.group;
    final delay = group == null
        ? ref.watch(delayProvider(proxyName: candidate.name, testUrl: testUrl))
        : null;
    final subtitle =
        blocked ??
        switch (group?.type) {
          GroupType.URLTest => l.chainsGroupFastest(group!.all.length),
          GroupType.Fallback => l.chainsGroupFallback(group!.all.length),
          GroupType.LoadBalance => l.chainsGroupBalance(group!.all.length),
          GroupType.Selector ||
          GroupType.Relay => l.chainsGroupManual(group!.all.length),
          null => candidate.proxy.typeLabel,
        };
    final row = DecorationListItem(
      isSelected: selected,
      onPressed: blocked == null ? onPressed : null,
      leading: group != null && candidate.code == null
          ? ShapeBadge(
              shape: MaterialShapes.circle,
              color: DashboardColors.of(context).tone2,
              size: 32,
              child: GlyphIcon(
                AppGlyphs.proxies,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : ShapeFlag(code: candidate.code, size: 32),
      title: EmojiText(
        serverTitle(candidate.name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitle, maxLines: 2),
      trailing: delay == null ? null : ChainDelayText(delay: delay),
    );
    return blocked == null ? row : Opacity(opacity: 0.5, child: row);
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Flexible(
          child: EmojiText(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.subheadline.of(context).copyWith(color: color),
          ),
        ),
        GlyphIcon(AppGlyphs.chevronForward, size: 18, color: color),
      ],
    );
  }
}

class _ReadyBody extends ConsumerWidget {
  const _ReadyBody({
    required this.order,
    required this.valueOf,
    required this.hasMiddle,
    required this.issues,
    required this.hops,
    required this.name,
    required this.offered,
    required this.offeredGroup,
    required this.onPick,
    required this.onAddMiddle,
    required this.onRemoveMiddle,
    required this.onRename,
    required this.onOffered,
    required this.onTargetGroup,
    required this.onDelete,
    required this.onRefresh,
  });

  final List<ChainHopSlot> order;
  final String? Function(ChainHopSlot slot) valueOf;
  final bool hasMiddle;
  final List<ChainIssue> issues;
  final List<String> hops;
  final String name;
  final bool offered;
  final String offeredGroup;
  final ValueChanged<ChainHopSlot> onPick;
  final VoidCallback onAddMiddle;
  final VoidCallback onRemoveMiddle;
  final VoidCallback onRename;
  final ValueChanged<bool> onOffered;
  final ValueChanged<String?> onTargetGroup;
  final VoidCallback? onDelete;
  final Future<void> Function()? onRefresh;

  String? _actionOf(AppLocalizations l, ChainIssue issue) =>
      switch (issue.code) {
        ChainIssueCode.mainGroupAutomatic when issue.suggest.isNotEmpty =>
          l.chainsIssueAutomaticAction(issue.suggest.first),
        ChainIssueCode.udpLost ||
        ChainIssueCode.udpTransportMissing => l.chainsPickUdpEntry,
        ChainIssueCode.missingHop ||
        ChainIssueCode.unchainableHop ||
        ChainIssueCode.loop ||
        ChainIssueCode.providerPending ||
        ChainIssueCode.emptyExit => l.chainsPickOther,
        _ => null,
      };

  void _act(ChainIssue issue) {
    switch (issue.code) {
      case ChainIssueCode.mainGroupAutomatic when issue.suggest.isNotEmpty:
        onTargetGroup(issue.suggest.first);
      case ChainIssueCode.udpLost || ChainIssueCode.udpTransportMissing:
        onPick(ChainHopSlot.entry);
      case _ when issue.hop >= 0 && issue.hop < order.length:
        onPick(order[issue.hop]);
      case _:
        onPick(ChainHopSlot.exit);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final automatic = issues.any(
      (issue) => issue.code == ChainIssueCode.mainGroupAutomatic,
    );
    final shownIssues = [
      ...issues.where((issue) => issue.code.isError),
      ...issues.where((issue) => !issue.code.isError),
    ].take(_maxIssues);
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + context.bottomInset),
      children: [
        generateSection(
          items: [
            for (final slot in order)
              _RouteRow(
                role: switch (slot) {
                  ChainHopSlot.entry => l.chainsEntry,
                  ChainHopSlot.middle => l.chainsMiddle,
                  ChainHopSlot.exit => l.chainsExit,
                },
                hop: valueOf(slot),
                onPressed: () => onPick(slot),
              ),
            if (hasMiddle)
              DecorationListItem(
                onPressed: onRemoveMiddle,
                leading: const SizedBox(
                  width: 28,
                  child: GlyphIcon(AppGlyphs.remove, size: 20),
                ),
                title: Text(l.chainsRemoveMiddle),
              )
            else if (hops.length < maxChainHops)
              DecorationListItem(
                onPressed: onAddMiddle,
                leading: SizedBox(
                  width: 28,
                  child: GlyphIcon(
                    AppGlyphs.add,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                title: Text(
                  l.chainsAddMiddle,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
          ],
        ),
        for (final issue in shownIssues) ...[
          const SizedBox(height: 12),
          if (chainIssueCopy(l, issue, hops, group: offeredGroup, name: name)
              case final copy)
            IssueCard(
              tone: issue.code.isError ? IssueTone.error : IssueTone.warning,
              title: copy.title,
              body: copy.body,
              action: _actionOf(l, issue),
              onAction: () => _act(issue),
            ),
        ],
        generateSection(
          items: [
            DecorationListItem(
              onPressed: onRename,
              title: Text(l.name),
              trailing: _Value(name),
            ),
            if (!automatic)
              DecorationListItem(
                title: Text(l.chainsOffered),
                trailing: CommonSwitch(value: offered, onChanged: onOffered),
              ),
          ],
          footer: !automatic && offered && offeredGroup.isNotEmpty
              ? l.chainsOfferedFooter(offeredGroup)
              : null,
        ),
        if (onDelete case final onDelete?)
          generateSection(
            items: [
              DecorationListItem(
                onPressed: onDelete,
                title: Text(
                  l.chainsDelete,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
      ],
    );
    final onRefresh = this.onRefresh;
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh, child: list);
  }
}

/// A slot of the route as a row: what it is, which server fills it.
class _RouteRow extends ConsumerWidget {
  const _RouteRow({
    required this.role,
    required this.hop,
    required this.onPressed,
  });

  final String role;
  final String? hop;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hop = this.hop;
    return DecorationListItem(
      onPressed: onPressed,
      leading: ShapeFlag(
        code: hop == null ? null : hopCountry(ref, hop),
        size: 28,
      ),
      title: Text(role),
      trailing: _Value(
        hop == null
            ? context.appLocalizations.chainsCaptionPick
            : serverTitle(hop),
      ),
    );
  }
}

class _BrokenBody extends ConsumerWidget {
  const _BrokenBody({
    required this.chain,
    required this.report,
    required this.onTake,
    required this.onPick,
    required this.onDelete,
  });

  final ProxyChain chain;
  final ChainReport report;
  final void Function(ChainHopSlot slot, String name) onTake;
  final ValueChanged<ChainHopSlot> onPick;
  final VoidCallback onDelete;

  ChainHopSlot _slotOf(int hop) {
    if (hop <= 0) return ChainHopSlot.entry;
    if (hop >= chain.hops.length - 1) return ChainHopSlot.exit;
    return ChainHopSlot.middle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final issue = leadingIssue(report.errors) ?? leadingIssue(report.issues);
    final group = report.target ?? '';
    final slot = issue == null ? ChainHopSlot.entry : _slotOf(issue.hop);
    final testUrl = ref.watch(chainMainGroupProvider)?.testUrl;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + context.bottomInset),
      children: [
        if (issue != null)
          if (chainIssueCopy(
                l,
                issue,
                chain.hops,
                group: group,
                name: chainTitle(chain),
              )
              case final copy)
            IssueCard(
              tone: IssueTone.error,
              title: copy.title,
              body: copy.body,
            ),
        generateSection(
          title: issue?.suggest.isNotEmpty == true
              ? switch (slot) {
                  ChainHopSlot.entry => l.chainsSimilarEntry,
                  ChainHopSlot.exit => l.chainsSimilarExit,
                  ChainHopSlot.middle => l.chainsSimilar,
                }
              : null,
          items: [
            for (final (index, name) in (issue?.suggest ?? const []).indexed)
              _SuggestRow(
                name: name,
                testUrl: testUrl,
                same: index == 0 && issue?.fingerprint != null,
                onTake: () => onTake(slot, name),
              ),
            DecorationListItem(
              onPressed: () => onPick(slot),
              title: Text(l.chainsPickFromAll),
              trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
            ),
          ],
        ),
        generateSection(
          items: [
            DecorationListItem(
              onPressed: onDelete,
              title: Text(
                l.chainsDelete,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuggestRow extends ConsumerWidget {
  const _SuggestRow({
    required this.name,
    required this.testUrl,
    required this.same,
    required this.onTake,
  });

  final String name;
  final String? testUrl;
  final bool same;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final delay = ref.watch(delayProvider(proxyName: name, testUrl: testUrl));
    return DecorationListItem(
      onPressed: onTake,
      leading: ShapeFlag(code: hopCountry(ref, name), size: 32),
      title: EmojiText(serverTitle(name), maxLines: 1),
      subtitle: same
          ? Text(l.chainsSuggestSame)
          : delay != null && delay > 0
          ? Text(chainLatency(l, delay))
          : null,
      trailing: FilledButton.tonal(
        onPressed: onTake,
        child: Text(l.chainsTake),
      ),
    );
  }
}
