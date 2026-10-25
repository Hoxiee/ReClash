import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Picks countries: the ones the servers have first (with counts), then all.
Future<List<String>?> pickCountries(
  BuildContext context, {
  List<String> selected = const [],
  String? groupName,
  bool multiple = true,
}) {
  return showInSheet<List<String>>(
    context,
    builder: (_) => CountryPicker(
      selected: selected,
      groupName: groupName,
      multiple: multiple,
    ),
  );
}

/// The country with its flag in the user's language where the table has it.
String rcxCountryName(BuildContext context, String code) =>
    rcxCountryNameIn(Localizations.localeOf(context).languageCode, code);

/// "🇸🇪 Sweden" for [language]; Russian has its own names, every other
/// language reads the English ones.
String rcxCountryNameIn(String language, String code) {
  final upper = code.toUpperCase();
  final names = _countries[upper];
  final flag = rcxCountryFlag(upper);
  if (names == null) return flag.isEmpty ? code : '$flag $upper';
  final name = language.startsWith('ru') ? names.ru : names.en;
  return '$flag $name';
}

/// The flag emoji of an ISO 3166-1 alpha-2 code, empty for anything else.
String rcxCountryFlag(String code) {
  final upper = code.toUpperCase();
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper)) return '';
  return String.fromCharCodes(upper.codeUnits.map((c) => c + 0x1F1A5));
}

bool rcxIsCountry(String code) => _countries.containsKey(code.toUpperCase());

final _flagPattern = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);
final _codePattern = RegExp(r'(?<![A-Za-z])[A-Z]{2}(?![A-Za-z])');

/// The country a server's name gives, read the way the Core reads it when
/// no exit check has run: a flag first, then a whole-word upper-case code,
/// then an English country name.
String? rcxCountryOfName(String name) {
  if (_flagPattern.firstMatch(name)?.group(0) case final flag?) {
    final code = String.fromCharCodes(flag.runes.map((r) => r - 0x1F1A5));
    if (rcxIsCountry(code)) return code;
  }
  for (final match in _codePattern.allMatches(name)) {
    final code = match.group(0)!;
    if (rcxIsCountry(code)) return code;
  }
  final lower = name.toLowerCase();
  String? best;
  var length = 0;
  // The longest name wins, so Equatorial Guinea is not read as Guinea.
  for (final MapEntry(:key, :value) in _countries.entries) {
    final index = lower.indexOf(value.en.toLowerCase());
    if (index < 0 || value.en.length <= length) continue;
    final end = index + value.en.length;
    final before = index == 0 || !_isLetter(lower.codeUnitAt(index - 1));
    final after = end == lower.length || !_isLetter(lower.codeUnitAt(end));
    if (before && after) (best, length) = (key, value.en.length);
  }
  return best;
}

bool _isLetter(int unit) =>
    (unit >= 0x61 && unit <= 0x7A) || (unit >= 0x41 && unit <= 0x5A);

/// The countries [names] give, most servers first.
List<RcxCountry> rcxCountriesOfNames(Iterable<String> names) {
  final counts = <String, int>{};
  for (final name in names) {
    if (rcxCountryOfName(name) case final code?) {
      counts[code] = (counts[code] ?? 0) + 1;
    }
  }
  return [
    for (final MapEntry(:key, :value) in counts.entries)
      RcxCountry(code: key, count: value),
  ]..sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    return byCount != 0 ? byCount : a.code.compareTo(b.code);
  });
}

/// Every server [groupName] reaches, through nested groups too; all
/// servers of the config without a group.
List<Proxy> rcxServersOf(List<Group> groups, String? groupName) {
  final seen = <String>{};
  final servers = <String, Proxy>{};
  void visit(Group group) {
    if (!seen.add(group.name)) return;
    for (final proxy in group.all) {
      final nested = groups.getGroup(proxy.name);
      if (nested != null) {
        visit(nested);
      } else {
        servers[proxy.name] = proxy;
      }
    }
  }

  if (groupName == null) {
    groups.forEach(visit);
  } else if (groups.getGroup(groupName) case final group?) {
    visit(group);
  }
  servers.removeWhere((name, _) => name == 'DIRECT' || name == 'REJECT');
  return servers.values.toList();
}

class CountryPicker extends ConsumerStatefulWidget {
  const CountryPicker({
    super.key,
    required this.selected,
    required this.groupName,
    required this.multiple,
  });

  final List<String> selected;
  final String? groupName;
  final bool multiple;

  @override
  ConsumerState<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends ConsumerState<CountryPicker> {
  late final _chosen = <String>[
    for (final code in widget.selected) code.toUpperCase(),
  ];
  late final ScrollController _controller;
  List<RcxCountry>? _present;
  var _query = SearchQuery('');

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
    unawaited(_load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ref.read(rcxRoutingActionProvider.notifier).studio({
      'op': 'countries',
      'group': ?widget.groupName,
    });
    if (!mounted) return;
    var present = result?.countries ?? const <RcxCountry>[];
    if (present.isEmpty) {
      final servers = rcxServersOf(ref.read(groupsProvider), widget.groupName);
      present = rcxCountriesOfNames(servers.map((proxy) => proxy.name));
    }
    setState(() => _present = present);
  }

  void _toggle(String code) {
    if (!widget.multiple) {
      Navigator.of(context).pop([code]);
      return;
    }
    setState(() {
      if (!_chosen.remove(code)) _chosen.add(code);
    });
  }

  bool _matches(String code) {
    if (_query.isEmpty) return true;
    final names = _countries[code];
    return _query.matches([code, names?.en, names?.ru]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final language = Localizations.localeOf(context).languageCode;
    final present = _present;
    final counts = {for (final c in present ?? const <RcxCountry>[]) c.code: c};
    final ours = [
      for (final c in present ?? const <RcxCountry>[])
        if (_matches(c.code)) c.code,
    ];
    final others = [
      for (final code in _sortedCodes(language))
        if (!counts.containsKey(code) && _matches(code)) code,
    ];
    Widget rows(List<String> codes) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: codes.length,
        itemBuilder: (context, index) {
          final code = codes[index];
          final country = counts[code];
          final selected = _chosen.contains(code);
          return ItemPositionProvider(
            position: ItemPosition.get(index, codes.length),
            child: DecorationListItem(
              isSelected: selected,
              title: EmojiText(rcxCountryNameIn(language, code), maxLines: 1),
              subtitle: country == null
                  ? null
                  : Row(
                      spacing: 4,
                      children: [
                        Text(l.rcxCountryServers(country.count)),
                        if (country.verified) ...[
                          GlyphIcon(
                            AppGlyphs.verified,
                            size: 14,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          Text(l.rcxCountryVerified),
                        ],
                      ],
                    ),
              onPressed: () => _toggle(code),
              trailing: selected ? const SelectionCheck() : null,
            ),
          );
        },
      ),
    );
    Widget header(String title) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(child: ListHeader(title: title)),
    );
    return CommonScaffold(
      title: widget.multiple ? l.rcxCountryPickMany : l.rcxCountryPickOne,
      isLoading: present == null,
      searchState: AppBarSearchState(
        onSearch: (query) => setState(() => _query = SearchQuery(query)),
      ),
      confirmationAction: widget.multiple
          ? IconButtonData(
              glyph: AppGlyphs.check,
              tooltip: l.save,
              onPressed: () => Navigator.of(context).pop([..._chosen]),
            )
          : null,
      body: present == null
          ? const SizedBox.shrink()
          : CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.sectionsTopPadding),
                ),
                if (ours.isNotEmpty) ...[
                  header(l.rcxCountryOnServers),
                  rows(ours),
                ],
                if (others.isNotEmpty) ...[
                  header(l.rcxCountryAll),
                  rows(others),
                ],
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) =>
                        SizedBox(height: 20 + context.bottomInset),
                  ),
                ),
              ],
            ),
    );
  }
}

final _sortedByLanguage = <String, List<String>>{};

List<String> _sortedCodes(String language) {
  final ru = language.startsWith('ru');
  return _sortedByLanguage[ru ? 'ru' : 'en'] ??= _countries.keys.toList()
    ..sort((a, b) {
      final x = _countries[a]!, y = _countries[b]!;
      return ru ? x.ru.compareTo(y.ru) : x.en.compareTo(y.en);
    });
}

typedef _Names = ({String en, String ru});

/// ISO 3166-1 alpha-2, as code|English|Russian.
final Map<String, _Names> _countries = {
  for (final line in _table.trim().split('\n'))
    if (line.split('|') case [final code, final en, final ru])
      code: (en: en, ru: ru),
};

const _table = '''
AD|Andorra|Андорра
AE|United Arab Emirates|ОАЭ
AF|Afghanistan|Афганистан
AG|Antigua and Barbuda|Антигуа и Барбуда
AI|Anguilla|Ангилья
AL|Albania|Албания
AM|Armenia|Армения
AO|Angola|Ангола
AQ|Antarctica|Антарктида
AR|Argentina|Аргентина
AS|American Samoa|Американское Самоа
AT|Austria|Австрия
AU|Australia|Австралия
AW|Aruba|Аруба
AX|Åland Islands|Аландские острова
AZ|Azerbaijan|Азербайджан
BA|Bosnia and Herzegovina|Босния и Герцеговина
BB|Barbados|Барбадос
BD|Bangladesh|Бангладеш
BE|Belgium|Бельгия
BF|Burkina Faso|Буркина-Фасо
BG|Bulgaria|Болгария
BH|Bahrain|Бахрейн
BI|Burundi|Бурунди
BJ|Benin|Бенин
BL|Saint Barthélemy|Сен-Бартелеми
BM|Bermuda|Бермуды
BN|Brunei|Бруней
BO|Bolivia|Боливия
BQ|Caribbean Netherlands|Бонэйр, Синт-Эстатиус и Саба
BR|Brazil|Бразилия
BS|Bahamas|Багамы
BT|Bhutan|Бутан
BV|Bouvet Island|Остров Буве
BW|Botswana|Ботсвана
BY|Belarus|Беларусь
BZ|Belize|Белиз
CA|Canada|Канада
CC|Cocos Islands|Кокосовые острова
CD|DR Congo|ДР Конго
CF|Central African Republic|ЦАР
CG|Congo|Республика Конго
CH|Switzerland|Швейцария
CI|Côte d’Ivoire|Кот-д’Ивуар
CK|Cook Islands|Острова Кука
CL|Chile|Чили
CM|Cameroon|Камерун
CN|China|Китай
CO|Colombia|Колумбия
CR|Costa Rica|Коста-Рика
CU|Cuba|Куба
CV|Cape Verde|Кабо-Верде
CW|Curaçao|Кюрасао
CX|Christmas Island|Остров Рождества
CY|Cyprus|Кипр
CZ|Czechia|Чехия
DE|Germany|Германия
DJ|Djibouti|Джибути
DK|Denmark|Дания
DM|Dominica|Доминика
DO|Dominican Republic|Доминиканская Республика
DZ|Algeria|Алжир
EC|Ecuador|Эквадор
EE|Estonia|Эстония
EG|Egypt|Египет
EH|Western Sahara|Западная Сахара
ER|Eritrea|Эритрея
ES|Spain|Испания
ET|Ethiopia|Эфиопия
FI|Finland|Финляндия
FJ|Fiji|Фиджи
FK|Falkland Islands|Фолклендские острова
FM|Micronesia|Микронезия
FO|Faroe Islands|Фарерские острова
FR|France|Франция
GA|Gabon|Габон
GB|United Kingdom|Великобритания
GD|Grenada|Гренада
GE|Georgia|Грузия
GF|French Guiana|Французская Гвиана
GG|Guernsey|Гернси
GH|Ghana|Гана
GI|Gibraltar|Гибралтар
GL|Greenland|Гренландия
GM|Gambia|Гамбия
GN|Guinea|Гвинея
GP|Guadeloupe|Гваделупа
GQ|Equatorial Guinea|Экваториальная Гвинея
GR|Greece|Греция
GS|South Georgia|Южная Георгия
GT|Guatemala|Гватемала
GU|Guam|Гуам
GW|Guinea-Bissau|Гвинея-Бисау
GY|Guyana|Гайана
HK|Hong Kong|Гонконг
HM|Heard and McDonald Islands|Острова Херд и Макдональд
HN|Honduras|Гондурас
HR|Croatia|Хорватия
HT|Haiti|Гаити
HU|Hungary|Венгрия
ID|Indonesia|Индонезия
IE|Ireland|Ирландия
IL|Israel|Израиль
IM|Isle of Man|Остров Мэн
IN|India|Индия
IO|British Indian Ocean Territory|Британская территория в Индийском океане
IQ|Iraq|Ирак
IR|Iran|Иран
IS|Iceland|Исландия
IT|Italy|Италия
JE|Jersey|Джерси
JM|Jamaica|Ямайка
JO|Jordan|Иордания
JP|Japan|Япония
KE|Kenya|Кения
KG|Kyrgyzstan|Киргизия
KH|Cambodia|Камбоджа
KI|Kiribati|Кирибати
KM|Comoros|Коморы
KN|Saint Kitts and Nevis|Сент-Китс и Невис
KP|North Korea|КНДР
KR|South Korea|Южная Корея
KW|Kuwait|Кувейт
KY|Cayman Islands|Каймановы острова
KZ|Kazakhstan|Казахстан
LA|Laos|Лаос
LB|Lebanon|Ливан
LC|Saint Lucia|Сент-Люсия
LI|Liechtenstein|Лихтенштейн
LK|Sri Lanka|Шри-Ланка
LR|Liberia|Либерия
LS|Lesotho|Лесото
LT|Lithuania|Литва
LU|Luxembourg|Люксембург
LV|Latvia|Латвия
LY|Libya|Ливия
MA|Morocco|Марокко
MC|Monaco|Монако
MD|Moldova|Молдова
ME|Montenegro|Черногория
MF|Saint Martin|Сен-Мартен
MG|Madagascar|Мадагаскар
MH|Marshall Islands|Маршалловы Острова
MK|North Macedonia|Северная Македония
ML|Mali|Мали
MM|Myanmar|Мьянма
MN|Mongolia|Монголия
MO|Macao|Макао
MP|Northern Mariana Islands|Северные Марианские острова
MQ|Martinique|Мартиника
MR|Mauritania|Мавритания
MS|Montserrat|Монтсеррат
MT|Malta|Мальта
MU|Mauritius|Маврикий
MV|Maldives|Мальдивы
MW|Malawi|Малави
MX|Mexico|Мексика
MY|Malaysia|Малайзия
MZ|Mozambique|Мозамбик
NA|Namibia|Намибия
NC|New Caledonia|Новая Каледония
NE|Niger|Нигер
NF|Norfolk Island|Остров Норфолк
NG|Nigeria|Нигерия
NI|Nicaragua|Никарагуа
NL|Netherlands|Нидерланды
NO|Norway|Норвегия
NP|Nepal|Непал
NR|Nauru|Науру
NU|Niue|Ниуэ
NZ|New Zealand|Новая Зеландия
OM|Oman|Оман
PA|Panama|Панама
PE|Peru|Перу
PF|French Polynesia|Французская Полинезия
PG|Papua New Guinea|Папуа — Новая Гвинея
PH|Philippines|Филиппины
PK|Pakistan|Пакистан
PL|Poland|Польша
PM|Saint Pierre and Miquelon|Сен-Пьер и Микелон
PN|Pitcairn Islands|Острова Питкэрн
PR|Puerto Rico|Пуэрто-Рико
PS|Palestine|Палестина
PT|Portugal|Португалия
PW|Palau|Палау
PY|Paraguay|Парагвай
QA|Qatar|Катар
RE|Réunion|Реюньон
RO|Romania|Румыния
RS|Serbia|Сербия
RU|Russia|Россия
RW|Rwanda|Руанда
SA|Saudi Arabia|Саудовская Аравия
SB|Solomon Islands|Соломоновы Острова
SC|Seychelles|Сейшелы
SD|Sudan|Судан
SE|Sweden|Швеция
SG|Singapore|Сингапур
SH|Saint Helena|Остров Святой Елены
SI|Slovenia|Словения
SJ|Svalbard and Jan Mayen|Шпицберген и Ян-Майен
SK|Slovakia|Словакия
SL|Sierra Leone|Сьерра-Леоне
SM|San Marino|Сан-Марино
SN|Senegal|Сенегал
SO|Somalia|Сомали
SR|Suriname|Суринам
SS|South Sudan|Южный Судан
ST|São Tomé and Príncipe|Сан-Томе и Принсипи
SV|El Salvador|Сальвадор
SX|Sint Maarten|Синт-Мартен
SY|Syria|Сирия
SZ|Eswatini|Эсватини
TC|Turks and Caicos Islands|Тёркс и Кайкос
TD|Chad|Чад
TF|French Southern Territories|Французские Южные территории
TG|Togo|Того
TH|Thailand|Таиланд
TJ|Tajikistan|Таджикистан
TK|Tokelau|Токелау
TL|Timor-Leste|Восточный Тимор
TM|Turkmenistan|Туркменистан
TN|Tunisia|Тунис
TO|Tonga|Тонга
TR|Türkiye|Турция
TT|Trinidad and Tobago|Тринидад и Тобаго
TV|Tuvalu|Тувалу
TW|Taiwan|Тайвань
TZ|Tanzania|Танзания
UA|Ukraine|Украина
UG|Uganda|Уганда
UM|U.S. Outlying Islands|Внешние малые острова США
US|United States|США
UY|Uruguay|Уругвай
UZ|Uzbekistan|Узбекистан
VA|Vatican City|Ватикан
VC|Saint Vincent and the Grenadines|Сент-Винсент и Гренадины
VE|Venezuela|Венесуэла
VG|British Virgin Islands|Британские Виргинские острова
VI|U.S. Virgin Islands|Виргинские острова США
VN|Vietnam|Вьетнам
VU|Vanuatu|Вануату
WF|Wallis and Futuna|Уоллис и Футуна
WS|Samoa|Самоа
YE|Yemen|Йемен
YT|Mayotte|Майотта
ZA|South Africa|ЮАР
ZM|Zambia|Замбия
ZW|Zimbabwe|Зимбабве
''';
