import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

/// A service a route can take in one tap; its [heads] are mihomo rule heads
/// without a target, checked against the bundled GEOSITE and GEOIP data.
class RcxTrafficPreset {
  const RcxTrafficPreset(this.label, this.emoji, this.heads);

  final String label;
  final String emoji;
  final List<String> heads;

  String get routeName => '$emoji $label';
}

const rcxTrafficPresets = [
  RcxTrafficPreset('YouTube', '▶️', ['GEOSITE,youtube']),
  RcxTrafficPreset('Google', '🔍', ['GEOSITE,google']),
  RcxTrafficPreset('Gemini', '✨', ['GEOSITE,google-gemini']),
  RcxTrafficPreset('ChatGPT', '🤖', ['GEOSITE,openai']),
  RcxTrafficPreset('Claude', '🧠', ['GEOSITE,anthropic']),
  RcxTrafficPreset('Telegram', '✈️', [
    'GEOSITE,telegram',
    'GEOIP,telegram,no-resolve',
  ]),
  RcxTrafficPreset('Discord', '🎮', ['GEOSITE,discord']),
  RcxTrafficPreset('WhatsApp', '💬', ['GEOSITE,whatsapp']),
  RcxTrafficPreset('Instagram', '📷', ['GEOSITE,instagram']),
  RcxTrafficPreset('Facebook', '👥', ['GEOSITE,facebook']),
  RcxTrafficPreset('X', '𝕏', ['GEOSITE,twitter']),
  RcxTrafficPreset('TikTok', '🎵', ['GEOSITE,tiktok']),
  RcxTrafficPreset('Netflix', '🎬', ['GEOSITE,netflix']),
  RcxTrafficPreset('Spotify', '🎧', ['GEOSITE,spotify']),
  RcxTrafficPreset('Twitch', '📺', ['GEOSITE,twitch']),
  RcxTrafficPreset('Steam', '🕹️', ['GEOSITE,steam']),
  RcxTrafficPreset('GitHub', '🐙', ['GEOSITE,github']),
  RcxTrafficPreset('Apple', '🍎', ['GEOSITE,apple']),
  RcxTrafficPreset('Microsoft', '🪟', ['GEOSITE,microsoft']),
];

/// The entry types offered for a custom entry, most common first.
const _customTypes = [
  'DOMAIN-SUFFIX',
  'DOMAIN',
  'DOMAIN-KEYWORD',
  'GEOSITE',
  'GEOIP',
  'IP-CIDR',
  'PROCESS-NAME',
  'RULE-SET',
];

const _ipTypes = {'GEOIP', 'IP-CIDR', 'IP-CIDR6', 'IP-ASN', 'SRC-IP-CIDR'};
const _noResolve = 'no-resolve';

final _domain = RegExp(
  r'^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)*[a-z0-9]([a-z0-9-]*[a-z0-9])?$',
  caseSensitive: false,
);
final _category = RegExp(r'^[a-z0-9!@._-]+$', caseSensitive: false);
final _plain = RegExp(r'^[^,\s][^,]*$');

typedef RcxMatchEntry = ({String type, String value, bool noResolve});

RcxMatchEntry rcxMatchEntry(String head) {
  final parts = head.split(',');
  final noResolve = parts.length > 2 && parts.last.trim() == _noResolve;
  return (
    type: parts.first.trim().toUpperCase(),
    value: parts.length > 1 ? parts[1].trim() : '',
    noResolve: noResolve,
  );
}

String rcxMatchHead(RcxMatchEntry entry) => [
  entry.type,
  entry.value,
  if (entry.noResolve && _ipTypes.contains(entry.type)) _noResolve,
].join(',');

String rcxMatchTypeLabel(AppLocalizations l, String type) => switch (type) {
  'DOMAIN' => l.rcxMatchDomain,
  'DOMAIN-SUFFIX' => l.rcxMatchSuffix,
  'DOMAIN-KEYWORD' => l.rcxMatchKeyword,
  'GEOSITE' => l.rcxMatchGeosite,
  'GEOIP' => l.rcxMatchGeoip,
  'IP-CIDR' || 'IP-CIDR6' => l.rcxMatchCidr,
  'PROCESS-NAME' => l.rcxMatchProcess,
  'RULE-SET' => l.rcxMatchRuleSet,
  _ => type,
};

String _hintOf(String type) => switch (type) {
  'DOMAIN' => 'www.example.com',
  'DOMAIN-SUFFIX' => 'example.com',
  'DOMAIN-KEYWORD' => 'example',
  'GEOSITE' => 'category-ai-chat-!cn',
  'GEOIP' => 'telegram',
  'IP-CIDR' || 'IP-CIDR6' => '10.0.0.0/8',
  'PROCESS-NAME' => 'Telegram.exe',
  'RULE-SET' => 'my-rules',
  _ => '',
};

bool _isCidr(String value) {
  final slash = value.indexOf('/');
  if (slash <= 0) return false;
  final address = InternetAddress.tryParse(value.substring(0, slash));
  final bits = int.tryParse(value.substring(slash + 1));
  if (address == null || bits == null) return false;
  final max = address.type == InternetAddressType.IPv6 ? 128 : 32;
  return bits >= 0 && bits <= max;
}

/// Why [value] cannot be an entry of [type], or null when it can.
String? rcxMatchError(AppLocalizations l, String type, String value) {
  if (value.isEmpty) return l.required;
  if (!_plain.hasMatch(value)) return l.rcxMatchInvalid;
  final valid = switch (type) {
    'DOMAIN' || 'DOMAIN-SUFFIX' => _domain.hasMatch(value),
    'GEOSITE' || 'GEOIP' => _category.hasMatch(value),
    'IP-CIDR' || 'IP-CIDR6' || 'SRC-IP-CIDR' => _isCidr(value),
    'IP-ASN' || 'DST-PORT' => RegExp(r'^[0-9/-]+$').hasMatch(value),
    _ => true,
  };
  return valid ? null : l.rcxMatchInvalid;
}

bool _covers(List<String> match, RcxTrafficPreset preset) =>
    preset.heads.every(match.contains);

/// The heads no fully picked preset accounts for.
List<String> _customOf(List<String> match) {
  final picked = {
    for (final preset in rcxTrafficPresets)
      if (_covers(match, preset)) ...preset.heads,
  };
  return [
    for (final head in match)
      if (!picked.contains(head)) head,
  ];
}

/// "YouTube · 2 more": the services by name, then the own entries.
String rcxTrafficSummary(AppLocalizations l, List<String> match) {
  final names = [
    for (final preset in rcxTrafficPresets)
      if (_covers(match, preset)) preset.label,
    for (final head in _customOf(match)) rcxMatchEntry(head).value,
  ];
  return switch (names.length) {
    0 => l.rcxMatchNone,
    1 => names.single,
    _ => l.rcxMatchMore(names.first, names.length - 1),
  };
}

/// A route name from the first service picked, else empty.
String rcxTrafficName(List<String> match) =>
    rcxTrafficPresets
        .where((preset) => _covers(match, preset))
        .firstOrNull
        ?.routeName ??
    '';

/// Asks what traffic a new route takes; null when the user backs out.
Future<List<String>?> pickRouteTraffic(BuildContext context) {
  return BaseNavigator.push<List<String>>(context, const _TrafficPicker());
}

class _TrafficPicker extends StatefulWidget {
  const _TrafficPicker();

  @override
  State<_TrafficPicker> createState() => _TrafficPickerState();
}

class _TrafficPickerState extends State<_TrafficPicker> {
  List<String> _match = const [];

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return FormPage(
      title: l.rcxRouteNew,
      saveLabel: l.rcxMatchNext,
      onSave: _match.isEmpty ? null : () => Navigator.of(context).pop(_match),
      children: [
        RouteTrafficSection(
          match: _match,
          onChanged: (match) => setState(() => _match = match),
          footer: l.rcxMatchPickHint,
        ),
      ],
    );
  }
}

/// Services shown before the rest are asked for; picked ones always show.
const _foldedServices = 8;

/// The traffic of one route: services as chips, then the user's own entries.
/// [errors] maps an index into [match] to the problem the lint found there.
class RouteTrafficSection extends StatefulWidget {
  const RouteTrafficSection({
    super.key,
    required this.match,
    required this.onChanged,
    this.errors = const {},
    this.footer,
  });

  final List<String> match;
  final ValueChanged<List<String>> onChanged;
  final Map<int, String> errors;
  final String? footer;

  @override
  State<RouteTrafficSection> createState() => _RouteTrafficSectionState();
}

class _RouteTrafficSectionState extends State<RouteTrafficSection> {
  bool _all = false;

  List<String> get match => widget.match;

  ValueChanged<List<String>> get onChanged => widget.onChanged;

  void _toggle(RcxTrafficPreset preset) {
    if (_covers(match, preset)) {
      onChanged([
        for (final head in match)
          if (!preset.heads.contains(head)) head,
      ]);
    } else {
      onChanged([
        ...match,
        for (final head in preset.heads)
          if (!match.contains(head)) head,
      ]);
    }
  }

  Future<void> _edit(BuildContext context, int? index) async {
    final head = await showFormSheet<String>(
      context: context,
      builder: (_) =>
          _MatchEntryForm(head: index == null ? null : match[index]),
    );
    if (head == null) return;
    if (index == null) {
      if (!match.contains(head)) onChanged([...match, head]);
    } else {
      onChanged([...match]..[index] = head);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final custom = _customOf(match);
    final presets = [
      for (final (index, preset) in rcxTrafficPresets.indexed)
        if (_all || index < _foldedServices || _covers(match, preset)) preset,
    ];
    return Column(
      children: [
        generateSection(
          title: l.rcxMatchServices,
          items: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in presets)
                  _ServiceChip(
                    label: '${preset.emoji} ${preset.label}',
                    selected: _covers(match, preset),
                    onPressed: () => _toggle(preset),
                  ),
                if (presets.length < rcxTrafficPresets.length)
                  _ServiceChip(
                    label: l.rcxMatchAllServices,
                    selected: false,
                    glyph: AppGlyphs.chevronDown,
                    onPressed: () => setState(() => _all = true),
                  ),
              ],
            ),
          ],
        ),
        generateAnimatedSection(
          title: l.rcxMatchCustom,
          footer: widget.footer ?? l.rcxMatchHint,
          items: [
            for (final head in custom)
              _entryRow(context, l, head, match.indexOf(head)),
            FormRow(
              key: const ValueKey('add'),
              title: l.rcxMatchAdd,
              leading: EntryButton.add(onPressed: () => _edit(context, null)),
              onPressed: () => _edit(context, null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _entryRow(
    BuildContext context,
    AppLocalizations l,
    String head,
    int index,
  ) {
    final entry = rcxMatchEntry(head);
    final error = widget.errors[index];
    return ContextMenuRegion(
      key: ValueKey(head),
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.delete,
          label: l.delete,
          danger: true,
          onPressed: () => onChanged([...match]..removeAt(index)),
        ),
      ],
      child: DecorationListItem(
        invalid: error != null,
        title: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(error ?? rcxMatchTypeLabel(l, entry.type)),
        onPressed: () => _edit(context, index),
        trailing: const DisclosureIndicator(),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.glyph,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Glyph? glyph;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foreground = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    return SizedBox(
      height: 36,
      child: CommonCard(
        isSelected: selected,
        fillsSelection: true,
        shape: AppShape.full,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (selected)
              GlyphIcon(AppGlyphs.check, size: 16, color: foreground),
            EmojiText(
              label,
              maxLines: 1,
              style: AppTextStyle.subheadline
                  .of(context, emphasized: true)
                  .copyWith(color: foreground),
            ),
            if (glyph case final glyph?)
              GlyphIcon(glyph, size: 16, color: foreground),
          ],
        ),
      ),
    );
  }
}

/// One own entry: its type and value, checked as it is typed.
class _MatchEntryForm extends StatefulWidget {
  const _MatchEntryForm({this.head});

  final String? head;

  @override
  State<_MatchEntryForm> createState() => _MatchEntryFormState();
}

class _MatchEntryFormState extends State<_MatchEntryForm> {
  late final RcxMatchEntry _initial = widget.head == null
      ? (type: _customTypes.first, value: '', noResolve: false)
      : rcxMatchEntry(widget.head!);
  late String _type = _initial.type;
  late bool _noResolve = _initial.noResolve;
  late final _value = TextEditingController(text: _initial.value);

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  String get _effectiveType =>
      _type == 'IP-CIDR' && _value.text.contains(':') ? 'IP-CIDR6' : _type;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final value = _value.text.trim();
    final error = value.isEmpty ? null : rcxMatchError(l, _type, value);
    final types = [..._customTypes, if (!_customTypes.contains(_type)) _type];
    return FormPage(
      title: widget.head == null ? l.rcxMatchAdd : rcxMatchTypeLabel(l, _type),
      onSave: value.isEmpty || error != null
          ? null
          : () => Navigator.of(context).pop(
              rcxMatchHead((
                type: _effectiveType,
                value: value,
                noResolve: _noResolve,
              )),
            ),
      children: [
        generateAnimatedSection(
          footer: error ?? l.rcxMatchTypeHint,
          items: [
            ListItem<String>.options(
              key: const ValueKey('type'),
              title: Text(l.rcxMatchType),
              options: types,
              value: _type,
              textBuilder: (type) => rcxMatchTypeLabel(l, type),
              onChanged: (type) => setState(() => _type = type),
            ),
            FormRow(
              key: const ValueKey('value'),
              title: l.rcxMatchValue,
              invalid: error != null,
              trailing: FormRowTextField(
                controller: _value,
                autofocus: widget.head == null,
                autocorrect: false,
                hintText: _hintOf(_type),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_ipTypes.contains(_type))
              ListItem.toggle(
                key: const ValueKey('no-resolve'),
                title: Text(l.rcxMatchNoResolve),
                value: _noResolve,
                onChanged: (on) => setState(() => _noResolve = on),
              ),
          ],
        ),
      ],
    );
  }
}
