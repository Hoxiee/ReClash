import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'metadata.dart';
import 'provider_conditions.dart';

const providerCardLimit = 8;
const providerCopyLimit = 256;
const providerShareLimit = 1024;
const providerTitleLimit = 80;
const providerTextLimit = 280;
const providerLabelLimit = 32;

final _cardId = RegExp(r'^[a-z0-9._:#-]{1,64}$');

enum ProviderAppAction {
  support,
  website,
  renew,
  topUp,
  updateProfile,
  speedTest,
  doctor,
  updateApp,
}

enum ProviderActionKind { url, copy, share, app }

class ProviderAction {
  const ProviderAction.url(Uri this.url)
    : kind = ProviderActionKind.url,
      text = null,
      app = null;
  const ProviderAction.copy(String this.text)
    : kind = ProviderActionKind.copy,
      url = null,
      app = null;
  const ProviderAction.share(String this.text)
    : kind = ProviderActionKind.share,
      url = null,
      app = null;
  const ProviderAction.app(ProviderAppAction this.app)
    : kind = ProviderActionKind.app,
      url = null,
      text = null;

  final ProviderActionKind kind;
  final Uri? url;
  final String? text;
  final ProviderAppAction? app;
}

enum ProviderBannerLayout { hero, split, strip, image }

enum ProviderBannerSide { start, end }

enum ProviderBannerTone { surface, primary, secondary, tertiary }

enum ProviderNoteLevel { info, warning, critical }

class ProviderButton {
  const ProviderButton(this.label, this.action);

  final String label;
  final ProviderAction action;
}

class ProviderActionItem {
  const ProviderActionItem(this.icon, this.label, this.action);

  final String icon;
  final String label;
  final ProviderAction action;
}

sealed class ProviderCard {
  const ProviderCard({
    required this.id,
    this.when = ProviderWhen.always,
    this.dismissible = false,
  });

  final String id;
  final ProviderWhen when;
  final bool dismissible;

  Iterable<int> get boundaries => when.boundaries;
}

class ProviderBanner extends ProviderCard {
  const ProviderBanner({
    required super.id,
    super.when,
    super.dismissible,
    this.layout = ProviderBannerLayout.hero,
    this.title,
    this.text,
    this.image,
    this.imageDark,
    this.side = ProviderBannerSide.end,
    this.tone = ProviderBannerTone.surface,
    this.countdown,
    this.button,
    this.action,
  });

  final ProviderBannerLayout layout;
  final String? title;
  final String? text;
  final Uri? image;
  final Uri? imageDark;
  final ProviderBannerSide side;
  final ProviderBannerTone tone;
  final int? countdown;
  final ProviderButton? button;
  final ProviderAction? action;

  @override
  Iterable<int> get boundaries => [...super.boundaries, ?countdown];
}

class ProviderNote extends ProviderCard {
  const ProviderNote({
    required super.id,
    required this.text,
    super.when,
    super.dismissible,
    this.level = ProviderNoteLevel.info,
    this.action,
  });

  final String text;
  final ProviderNoteLevel level;
  final ProviderAction? action;
}

class ProviderActions extends ProviderCard {
  const ProviderActions({
    required super.id,
    required this.items,
    super.when,
    super.dismissible,
  });

  final List<ProviderActionItem> items;
}

typedef ProviderCardsResult = ({
  List<ProviderCard> cards,
  List<String> warnings,
});

const _actionKeys = {'url', 'copy', 'share', 'app'};
const _cardKeys = {'id', 'type', 'when', 'dismissible'};
const _bannerKeys = {
  ..._cardKeys,
  ..._actionKeys,
  'layout',
  'title',
  'text',
  'image',
  'image-dark',
  'side',
  'tone',
  'countdown',
  'button',
};
const _noteKeys = {..._cardKeys, ..._actionKeys, 'text', 'level'};
const _actionsKeys = {..._cardKeys, 'items'};
const _labeledActionKeys = {..._actionKeys, 'label'};
const _itemKeys = {..._labeledActionKeys, 'icon'};

/// Cards in order. A card that is invalid, unknown or over the limit is
/// skipped alone with a warning; so is every key the card type does not have.
ProviderCardsResult parseProviderCards(Object? json) {
  if (json is! List) {
    return (cards: const [], warnings: const ['Cards must be a list']);
  }
  final cards = <ProviderCard>[];
  final warnings = <String>[];
  final ids = <String>{};
  for (var i = 0; i < json.length; i++) {
    if (cards.length >= providerCardLimit) {
      warnings.add('Cards beyond $providerCardLimit dropped');
      break;
    }
    final entry = json[i];
    final id = entry is Map ? entry['id'] : null;
    final card = id is String && _cardId.hasMatch(id) && !ids.contains(id)
        ? _parseCard(entry as Map, id, warnings)
        : null;
    if (card == null) {
      warnings.add('Card ${id is String ? id : '#$i'} skipped');
      continue;
    }
    ids.add(id as String);
    cards.add(card);
  }
  return (
    cards: List.unmodifiable(cards),
    warnings: List.unmodifiable(warnings),
  );
}

ProviderCard? _parseCard(Map json, String id, List<String> warnings) {
  final when = ProviderWhen.parse(json['when']);
  final dismissible = json['dismissible'];
  if (when == null || (dismissible != null && dismissible is! bool)) {
    return null;
  }
  void warnUnknown(Map map, Set<String> known) {
    for (final key in map.keys) {
      if (!known.contains(key)) warnings.add('Unknown key $key in card $id');
    }
  }

  if (json['when'] case final Map clause) {
    warnUnknown(clause, ProviderWhen.knownKeys);
  }
  switch (json['type']) {
    case 'banner':
      warnUnknown(json, _bannerKeys);
      if (json['button'] case final Map button) {
        warnUnknown(button, _labeledActionKeys);
      }
      return _banner(json, id, when, dismissible == true);
    case 'note':
      warnUnknown(json, _noteKeys);
      return _note(json, id, when, dismissible == true);
    case 'actions':
      warnUnknown(json, _actionsKeys);
      for (final item in json['items'] is List ? json['items'] as List : []) {
        if (item is Map) warnUnknown(item, _itemKeys);
      }
      return _actions(json, id, when, dismissible == true);
  }
  return null;
}

ProviderBanner? _banner(Map json, String id, ProviderWhen when, bool dismiss) {
  final layout = _enumOf(
    ProviderBannerLayout.values,
    json['layout'],
    ProviderBannerLayout.hero,
  );
  final side = _enumOf(
    ProviderBannerSide.values,
    json['side'],
    ProviderBannerSide.end,
  );
  final tone = _enumOf(
    ProviderBannerTone.values,
    json['tone'],
    ProviderBannerTone.surface,
  );
  final title = _text(json['title'], providerTitleLimit);
  final text = _text(json['text'], providerTextLimit);
  final image = _image(json['image']);
  final imageDark = _image(json['image-dark']);
  final countdown = json['countdown'];
  final action = _action(json);
  final button = _button(json['button']);
  if (layout == null ||
      side == null ||
      tone == null ||
      title == _bad ||
      text == _bad ||
      image == _badUri ||
      imageDark == _badUri ||
      (countdown != null &&
          (countdown is! int || !validProviderUnixSeconds(countdown))) ||
      action == _badAction ||
      button == _badButton) {
    return null;
  }
  return ProviderBanner(
    id: id,
    when: when,
    dismissible: dismiss,
    layout: layout,
    title: title,
    text: text,
    image: image,
    imageDark: imageDark,
    side: side,
    tone: tone,
    countdown: countdown as int?,
    button: button,
    action: action,
  );
}

ProviderNote? _note(Map json, String id, ProviderWhen when, bool dismiss) {
  final text = _text(json['text'], providerTextLimit);
  final level = _enumOf(
    ProviderNoteLevel.values,
    json['level'],
    ProviderNoteLevel.info,
  );
  final action = _action(json);
  if (text == null || text == _bad || level == null || action == _badAction) {
    return null;
  }
  return ProviderNote(
    id: id,
    text: text,
    when: when,
    dismissible: dismiss,
    level: level,
    action: action,
  );
}

ProviderActions? _actions(
  Map json,
  String id,
  ProviderWhen when,
  bool dismiss,
) {
  final raw = json['items'];
  if (raw is! List || raw.length < 2 || raw.length > 6) return null;
  final items = <ProviderActionItem>[];
  for (final entry in raw) {
    if (entry is! Map) return null;
    final icon = entry['icon'];
    final label = _text(entry['label'], providerLabelLimit);
    final action = _action(entry);
    if (icon is! String ||
        !_cardId.hasMatch(icon) ||
        label == null ||
        label == _bad ||
        action == null ||
        action == _badAction) {
      return null;
    }
    items.add(ProviderActionItem(icon, label, action));
  }
  return ProviderActions(
    id: id,
    items: List.unmodifiable(items),
    when: when,
    dismissible: dismiss,
  );
}

const _bad = '\u0000bad';
final _badUri = Uri(path: 'bad');
const _badAction = ProviderAction.copy('\u0000bad');
const _badButton = ProviderButton('\u0000bad', _badAction);

T? _enumOf<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw == null) return fallback;
  return values.where((value) => value.name == raw).firstOrNull;
}

/// Null when absent, [_bad] when present but not a plain string in the limit.
String? _text(Object? raw, int limit) {
  if (raw == null) return null;
  if (raw is! String || raw.trim().isEmpty || raw.runes.length > limit) {
    return _bad;
  }
  return raw;
}

Uri? _image(Object? raw) {
  if (raw == null) return null;
  final uri = raw is String ? safeSubscriptionLink(raw, httpsOnly: true) : null;
  return uri ?? _badUri;
}

ProviderButton? _button(Object? raw) {
  if (raw == null) return null;
  if (raw is! Map) return _badButton;
  final label = _text(raw['label'], providerLabelLimit);
  final action = _action(raw);
  if (label == null ||
      label == _bad ||
      action == null ||
      action == _badAction) {
    return _badButton;
  }
  return ProviderButton(label, action);
}

/// Null without an action key, [_badAction] for none valid or several.
ProviderAction? _action(Map json) {
  final keys = _actionKeys.where(json.containsKey).toList();
  if (keys.isEmpty) return null;
  if (keys.length > 1) return _badAction;
  final value = json[keys.single];
  if (value is! String) return _badAction;
  switch (keys.single) {
    case 'url':
      final uri = value.length <= 2048
          ? safeSubscriptionSupportLink(value)
          : null;
      return uri == null ? _badAction : ProviderAction.url(uri);
    case 'copy':
      return _bounded(value, providerCopyLimit)
          ? ProviderAction.copy(value)
          : _badAction;
    case 'share':
      return _bounded(value, providerShareLimit)
          ? ProviderAction.share(value)
          : _badAction;
    default:
      final app = _enumOf(
        ProviderAppAction.values,
        value,
        ProviderAppAction.support,
      );
      return app == null || value != app.name
          ? _badAction
          : ProviderAction.app(app);
  }
}

bool _bounded(String value, int bytes) =>
    value.isNotEmpty && utf8.encode(value).length <= bytes;

String _actionKey(ProviderAction? action) => action == null
    ? ''
    : '${action.kind.name}:${action.url ?? action.text ?? action.app?.name}';

String _cardContent(ProviderCard card) => switch (card) {
  ProviderNote() =>
    '${card.level.name}\n${card.text}\n${_actionKey(card.action)}',
  ProviderBanner() =>
    '${card.layout.name}\n${card.title}\n${card.text}\n${card.image}\n'
        '${card.imageDark}\n${card.countdown}\n${card.button?.label}\n'
        '${_actionKey(card.button?.action)}\n${_actionKey(card.action)}',
  ProviderActions() => [
    for (final item in card.items)
      '${item.icon}|${item.label}|${_actionKey(item.action)}',
  ].join('\n'),
};

/// Identifies a card's exact content, so a changed card shows again.
String providerCardDismissId(ProviderCard card) =>
    md5.convert(utf8.encode('${card.id}\n${_cardContent(card)}')).toString();

/// The [cards] whose conditions hold in [snapshot], minus expired countdowns
/// and the ones the user dismissed.
List<ProviderCard> visibleProviderCards(
  List<ProviderCard> cards,
  ProviderConditionSnapshot snapshot,
  Set<String> dismissed,
) {
  final seconds = snapshot.now.millisecondsSinceEpoch ~/ 1000;
  return [
    for (final card in cards)
      if (card.when.holds(snapshot) &&
          !(card is ProviderBanner &&
              card.countdown != null &&
              card.countdown! <= seconds) &&
          !(card.dismissible &&
              dismissed.contains(providerCardDismissId(card))))
        card,
  ];
}
