// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a kk locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'kk';

  static String m0(count, skipped) =>
      "Қосуға ${count} жазба, бұрыннан бар болғандықтан ${skipped} өткізілді";

  static String m1(detail) => "Деректерді тазалау мүмкін болмады: ${detail}";

  static String m2(code) =>
      "Windows ReClashCore.exe файлын іске қосудан бас тартты (${code} қатесі). Smart App Control немесе AppLocker сияқты қолданба бақылау саясаты қолтаңбасы жоқ қолданбаларды блоктайды; сол саясатта ReClash-ке рұқсат беріңіз немесе саясатты өшіріңіз де, қайталап көріңіз.";

  static String m3(name) =>
      "Қолданба қатарынан екі рет іске қосылуын аяқтай алмады. Циклді тоқтату үшін ${name} профилі таңдаудан алынып тасталды, автоматты баптау жасалмады. Профильді кез келген уақытта қайта таңдай аласыз.";

  static String m4(url) => "${url} сілтемесінен профиль жасағыңыз келе ме?";

  static String m5(groups) =>
      "${groups} прокси топтарынан include-all алынып тасталды; олардың қолданатын проксилерін немесе прокси провайдерлерін қосыңыз";

  static String m6(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE ережесі алынып тасталды, өйткені арнайы профильдер ішкі ережелерді қолдамайды', other: '${label} SUB-RULE ережесі алынып тасталды, өйткені арнайы профильдер ішкі ережелерді қолдамайды')}";

  static String m7(message) => "Ядро бұл проксиді талдай алмады: ${message}";

  static String m8(proxy, target) =>
      "${proxy} ${target} арқылы қосылады, бірақ ол жол қайта ${proxy} арқылы өтеді, сондықтан қосылу циклге айналады";

  static String m9(name) =>
      "${name} атауын басқа прокси немесе прокси тобы бұрыннан қолданып жүр";

  static String m10(path) => "Прокси топтары циклде бір-бірін атайды: ${path}";

  static String m11(name) =>
      "Бос қосалқы прокси болуы керек, бірақ ${name} жоқ немесе ол прокси тобы";

  static String m12(name, message) =>
      "${name} — жарамды тұрақты өрнек емес: ${message}";

  static String m13(name) => "Dialer proxy ${name} жоқ";

  static String m14(names) => "Бұл прокси провайдерлері жоқ: ${names}";

  static String m15(names) => "Бұл проксилер немесе саясаттар жоқ: ${names}";

  static String m16(name) =>
      "${name} — кірістірілген саясат атауы, бұл жерде қолданылуы мүмкін емес";

  static String m17(count) =>
      "${count} жазбада мәселе бар, бұл профильді қолдану сәтсіз аяқталуы мүмкін";

  static String m18(count) =>
      "${Intl.plural(count, one: '1 күн бұрын', other: '${count} күн бұрын')}";

  static String m19(count) =>
      "${Intl.plural(count, other: '${count} күн бұрын')}";

  static String m20(label) => "Таңдалған ${label} жойылсын ба?";

  static String m21(label) => "Бұл ${label} жойылсын ба?";

  static String m22(label) => "${label} туралы мәліметтер";

  static String m23(name) =>
      "${name} арқылы қосылу оны қолданған проксиге қайтып оралады, сондықтан байланыс тоқтатылды";

  static String m24(label) => "${label} бос болмауы керек";

  static String m25(label) => "${label} бұрыннан бар";

  static String m26(count) => "${count} жазба сәтсіз аяқталды";

  static String m27(label, message) => "${label}: ${message}";

  static String m28(name) => "${name} ең соңғы нұсқада тұр";

  static String m29(name) => "${name} жаңартылды";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 топ', other: '${count} топ')}";

  static String m31(count) => "${count} уақыты өткен";

  static String m32(action) =>
      "«${action}» үшін қолданылып жүр. Сақтасаңыз, осында ауысады.";

  static String m33(actions) => "Экспортталмады: ${actions}";

  static String m34(modifiers) => "Кемінде ${modifiers} біреуін қосыңыз";

  static String m35(count) =>
      "${Intl.plural(count, one: '1 сағат бұрын', other: '${count} сағат бұрын')}";

  static String m36(count) =>
      "${Intl.plural(count, other: '${count} сағат бұрын')}";

  static String m37(target) => "${target} — жарамсыз саясат";

  static String m38(proxyName) => "${proxyName} — жарамсыз прокси";

  static String m39(providerName) =>
      "${providerName} — жарамсыз прокси провайдері";

  static String m40(ruleSet) => "${ruleSet} — жарамсыз ереже жинағы";

  static String m41(subRule) => "${subRule} — жарамсыз SUB_RULE";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 жазба', other: '${count} жазба')}";

  static String m43(line, message) => "${line}-жол: ${message}";

  static String m44(appName) =>
      "1. Жүйелік баптауларды ашып, «Жекелік және қауіпсіздік» бөліміне өтіңіз\n2. Орналасу қызметтерін таңдаңыз\n3. Тізімнен ${appName} қолданбасын тауып, құсбелгі қойыңыз\n\nДайын болған соң қолданбаға оралыңыз. Ынтымақтастығыңыз үшін рахмет.";

  static String m45(label, max) =>
      "${label} ең көбі ${max} таңбадан аспауы керек";

  static String m46(size) => "${size} босатылды";

  static String m47(count) =>
      "${Intl.plural(count, one: '1 минут бұрын', other: '${count} минут бұрын')}";

  static String m48(count) =>
      "${Intl.plural(count, other: '${count} минут бұрын')}";

  static String m49(count) =>
      "${Intl.plural(count, one: '1 ай бұрын', other: '${count} ай бұрын')}";

  static String m50(count) =>
      "${Intl.plural(count, other: '${count} ай бұрын')}";

  static String m51(code) =>
      "Сервер рұқсат бермеді (HTTP ${code}). Сілтеменің мерзімі біткен немесе деректемелер дұрыс емес болуы мүмкін";

  static String m52(code) => "Сервер сұрауды қабылдамады (HTTP ${code})";

  static String m53(code) =>
      "Бұл мекенжайда ештеңе табылмады (HTTP ${code}). URL дұрыс екенін тексеріңіз";

  static String m54(detail) => "Желі сұрауы сәтсіз аяқталды: ${detail}";

  static String m55(code) =>
      "Серверде ақау шықты (HTTP ${code}). Кейінірек қайталап көріңіз";

  static String m56(label) => "Әзірге ${label} жоқ";

  static String m57(label, min, max) =>
      "${label} ${min} мен ${max} аралығында болуы керек";

  static String m58(label) => "${label} сан болуы керек";

  static String m59(label) => "${label} 1024 пен 49151 аралығында болуы керек";

  static String m60(port) => "Порт ${port}";

  static String m61(days) =>
      "${Intl.plural(days, one: '1 күн қалды', other: '${days} күн қалды')}";

  static String m62(date, days) =>
      "Мерзімі бітеді: ${date}, ${Intl.plural(days, one: '1 күн', other: '${days} күн')} қалды";

  static String m63(time) => "Жаңартылды: ${time}";

  static String m64(label, profiles) =>
      "${label} әлі де ${profiles} пайдалануда, ол жойылғанда олар дұрыс жұмыс істемей қалады. Шынымен жойғыңыз келе ме?";

  static String m65(count, label) =>
      "${Intl.plural(count, one: '1 прокси', other: '${label} прокси')}";

  static String m66(name, count) => "${name} және басқалары (${count} прокси)";

  static String m67(removed) =>
      "Бұл проксилер жойылады: ${removed}. Атауы өзгерген жол жаңа прокси саналады, ал жойылғандарын атап өтетін арнайы профильдер оларды жоқ деп белгілейді. Бәрібір қолдану керек пе?";

  static String m68(removed, added) =>
      "Бұл проксилер жойылады: ${removed}. Осы қосылады: ${added}. Атауы өзгерген жол жаңа прокси саналады, ал жойылғандарын атап өтетін арнайы профильдер оларды жоқ деп белгілейді. Бәрібір қолдану керек пе?";

  static String m69(label) =>
      "Осы профильдегі ережелер, прокси топтары, dialer проксилер, DNS немесе NTP ${label} атауын әлі қолданады; ол жойылғанда олар тоқтап қалады. Шынымен жойғыңыз келе ме?";

  static String m70(count, label) =>
      "${Intl.plural(count, one: '1 прокси тобы', other: '${label} прокси тобы')}";

  static String m71(region, bypassed, proxied) =>
      "${region}: VPN айналып өту тізіміне ${bypassed} қолданба, VPN тізіміне ${proxied} қолданба кіреді. Екі тізім де ауыстырылады; режим мен басқа параметрлер өзгермейді. Пакет пен SDK сәйкестігі — тек ұсыныс: қолданғаннан кейін нәтижені тексеріңіз.";

  static String m72(region, value) =>
      "${region} аймағының тізімі: ${value}. Қолмен жасалған тізім аймақтық мәндерді ауыстырады.";

  static String m73(region, source) => "Ұсыныс: ${region} · ${source}";

  static String m74(region, value) =>
      "${region} аймағының DNS параметрлері: ${value}. Осы экрандағы қолмен орнатылған мәндер басым.";

  static String m75(region) => "Ел профилі: ${region}";

  static String m76(value) => "TUN MTU: ${value}";

  static String m77(value) => "Әдепкі қызмет тексерістері: ${value}";

  static String m78(region, value) =>
      "${region} аймағының MTU мәні: ${value}. Өз мәніңізді қолдану үшін MTU параметрін қосыңыз.";

  static String m79(count, label) =>
      "${Intl.plural(count, one: '1 ереже', other: '${label} ереже')}";

  static String m80(appName) => "${appName} (Қауіпсіз режим)";

  static String m81(count) =>
      "${Intl.plural(count, one: '1 секунд', other: '${count} секунд')}";

  static String m82(count) => "${count} күшіне еніп тұр";

  static String m83(count) =>
      "${Intl.plural(count, one: '1 мәселе', other: '${count} мәселе')}";

  static String m84(time) => "${time} тексерілді";

  static String m85(count) =>
      "${Intl.plural(count, one: '1 баптау', other: '${count} баптау')}";

  static String m86(count) => "Қолжетімді профильдер: ${count}";

  static String m87(step, total) => "${step} / ${total}";

  static String m88(server) => "${server} серверін көру";

  static String m89(link) => "${link} сілтемесінен прокси оқу мүмкін болмады";

  static String m90(label) => "${label} жалғыз жазба болуы керек";

  static String m91(client, format, count) =>
      "${client} ретінде алынды: ${format}, прокси түйіндер саны: ${count}.";

  static String m92(sections) =>
      "Мына бастапқы бөлімдер тасымалданбайды: ${sections}.";

  static String m93(count, format) =>
      "${format} пішімінен ${count} прокси түйінін импорттауға болады.";

  static String m94(count) => "Түрлендірілмейтін түйіндер саны: ${count}.";

  static String m95(count) => "${count} нәтиже";

  static String m96(value) => "Шың: ${value}";

  static String m97(value) => "Барлығы: ${value}";

  static String m98(version) => "Орнатылған нұсқа: ${version}";

  static String m99(nodes, groups, providers) =>
      "Прокси: ${nodes}, топтар: ${groups}, қашықтағы провайдерлер: ${providers}";

  static String m100(action) =>
      "Сілтеме «${action}» әрекетін сұрайды. ReClash қолданбасына орындауға рұқсат бересіз бе?";

  static String m101(name, source) =>
      "${source} көзінен «${name}» импортталсын ба? Растаудан кейін профиль мен түрлендіру тексеріледі.";

  static String m102(label) => "${label} URL болуы керек";

  static String m103(index) => "Фон ${index}";

  static String m104(count) =>
      "Ең көбі ${count} фон сақтауға болады. Жаңасын қосу үшін біреуін жойыңыз.";

  static String m105(version) => "Орнатылған нұсқа: ${version}";

  static String m106(count) =>
      "${Intl.plural(count, one: '1 жыл бұрын', other: '${count} жыл бұрын')}";

  static String m107(count) =>
      "${Intl.plural(count, other: '${count} жыл бұрын')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Қолданба туралы"),
    "accessControl": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды бақылау",
    ),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Тек таңдалған қолданбалар ғана VPN арқылы өтеді",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды бақылау проксиді қай қолданбалар пайдаланатынын таңдайды.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба қатынасын бақылау өшірілген",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған қолданбалар VPN арқылы өтпейді",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Рұқсатты басқару баптаулары",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Тіркелгі"),
    "action": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Барлық кідірістерді тексеру",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Тікелей режим"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Глобалды режим"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Режимді ауыстыру"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Жүйелік прокси"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Ереже режимі"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Іске қосу/Тоқтату"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Профильдерді жаңарту",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Көрсету/Жасыру"),
    "add": MessageLookupByLibrary.simpleMessage("Қосу"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Прокси қосу"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Сүзгілерді қосу"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Түйіндерді қосу"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Ауыстыру жазбасын қосу",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Профиль қосу"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Прокси тобын қосу"),
    "addRule": MessageLookupByLibrary.simpleMessage("Ереже қосу"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Баптау қосу"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSID қосу"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Қосымша ережелер"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Қосымша параметрлер",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Атау префиксі"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Атау суффиксі"),
    "address": MessageLookupByLibrary.simpleMessage("Мекенжай"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV серверінің мекенжайы",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Жарамды WebDAV мекенжайын енгізіңіз",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Кеңейтілген конфигурация",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Кеңейтілген конфигурация желіні, DNS-ті, қосымша ережелер мен скрипттерді сақтайды.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Шифрланған профиль",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Age құпия кілті"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Бұл профиль age көмегімен шифрланған, оны шешу үшін age құпия кілті керек",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Келісемін"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Сілтеме жасалған барлық проксилер",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Сілтеме жасалған барлық прокси провайдерлері",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларға VPN-ді айналып өтуге рұқсат беру",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN-ға рұқсат беру"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Рұқсат етілген IP-лер"),
    "answers": MessageLookupByLibrary.simpleMessage("Жауаптар"),
    "app": MessageLookupByLibrary.simpleMessage("Қолданба"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Қолданба қатынасын бақылау",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Қолданба таңбашасының дизайны",
    ),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Жергілікті проксилер жоқ",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage("Қолданба аймағы"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Фон"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Интерфейс"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Тақырып"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Жүйелік DNS-ті қосу",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Қолданба баптаулары",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Аутентификация жергілікті прокси портында пайдаланушы атауы мен құпиясөзді сұрайды.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Аутентификация қосулы кезде жүйелік прокси қолданылмайды.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Рұқсат беру"),
    "authorized": MessageLookupByLibrary.simpleMessage("Рұқсат етілген"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Жаңартуларды автоматты тексеру",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды автоматты жабу",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды автоматты жабу проксилерді ауыстырғанда ашық қосылымдарды жабады.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("Автокірістіру"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автоматты іске қосу"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автоқосу"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Автоқосу қолданба ашылғанда проксиді қосады.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Жүйелік DNS-ті автоматты орнату",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автожаңарту"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Артқа"),
    "backup": MessageLookupByLibrary.simpleMessage("Сақтық көшірме"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірме және қалпына келтіру",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Бұл сақтық көшірме қолданбаның жаңалау нұсқасынан алынған. Қалпына келтірер алдында қолданбаны жаңартыңыз",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірме жасалды",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Негізгі ақпарат"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage(
      "Негізгі стратегиялар",
    ),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Топтап қосу"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Топтап импорттау"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Әр жолда бір сілтеме",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Әр жолда бір жазба немесе үтірмен ажыратылған",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Әр жолда бір жазба: кілт, бос орын, одан кейін мән",
    ),
    "batchPreviewTip": m0,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Әр жолда бір URL",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Батарея оңтайландыруын елемеу қолданбаның фонда жұмыс істеп тұруын қамтамасыз етеді.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Байланыстыру"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Қара тізім режимі"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Қосылымды блоктау",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Жарықтық"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass домендері"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Bypass домендері тек жүйелік прокси қосулы кезде ғана күшіне енеді.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Жеке адрестерді айналып өту",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Жеке адрестерді айналып өту қосулы кезде LAN, loopback және multicast адрестері TUN-ды айналып өтеді.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Кэш"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Кэш алгоритмі"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш зақымдалды. Тазалансын ба?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Кэш өлшемі"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QR кодтарды сканерлеу үшін жүйелік баптауларда камераға рұқсат беріңіз немесе галереядан QR код суретін таңдаңыз.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Камераға рұқсат қажет",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Камера қолжетімсіз",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Бас тарту"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Таңдауды алып тастау",
    ),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Сақтау мүмкін болмады"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Прокси ауыстырылмады, алдыңғы таңдау қалпына келтірілді",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Үйлесімділікті бұзатын өзгерістер",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage(
      "Жаңа мүмкіндіктер",
    ),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Қателерді түзету"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Өнімділік"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage(
      "Қайтарылған өзгерістер",
    ),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "TLS сертификаттарын тексеру",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS тексерімі өшірулі болғанда жазылымдар мен сақтық көшірмелер делдал шабуылына осал болады.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Жаңартуларды тексеру"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Қолданба ең соңғы нұсқада",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Шифр"),
    "clearData": MessageLookupByLibrary.simpleMessage("Деректерді тазалау"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Бұл барлық профильдер, баптаулар мен жергілікті деректерді жойып, қолданбаны жабады. Жаңадан бастау үшін оны қайта ашыңыз.",
    ),
    "clearDataFailed": m1,
    "clearSearch": MessageLookupByLibrary.simpleMessage("Іздеуді тазарту"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Клиент саусақ ізі",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферіне экспорттау",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферінен импорттау",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферіне көшіру мүмкін болмады. Таңдалған мәтін тым үлкен болуы мүмкін",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Жабу"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды жабу",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Түс"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Түс стилі"),
    "columns": MessageLookupByLibrary.simpleMessage("Бағандар"),
    "compact": MessageLookupByLibrary.simpleMessage("Ықшам"),
    "compatible": MessageLookupByLibrary.simpleMessage("Үйлесімділік режимі"),
    "confirm": MessageLookupByLibrary.simpleMessage("Растау"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Барлық деректер тазалансын ба?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Бұл прокси тобын жойғыңыз келе ме?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы терезеден шыққыңыз келе ме?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Ядро мәжбүрлеп құлатылсын ба?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Кептеліс басқаруы",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "TCP кептелісін басқару",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP кептелісін басқару тек mips стегімен жұмыс істейді.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Жалғанған"),
    "connecting": MessageLookupByLibrary.simpleMessage("Қосылуда…"),
    "connection": MessageLookupByLibrary.simpleMessage("Қосылым"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Байланыс статистикасы",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы қосылымдар, соңғы сұраулар және DNS сұраулары",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Қосылымдар"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Байланыс: "),
    "content": MessageLookupByLibrary.simpleMessage("Мазмұн"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Мазмұн бос болмауы тиіс",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Глобалдық қосымша ережелерді басқару",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Көшіру"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Орта айнымалыларын көшіру",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Сілтемені көшіру"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Көшірілді"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Архитектура"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control ReClashCore.exe файлын қолтаңбасы жоқ болғандықтан блоктады. Windows қауіпсіздігі → «Қолданбалар мен браузерді бақылау» → Smart App Control баптауларына өтіп, «Өшірулі» опциясын таңдаңыз да, ReClash-ті қайта іске қосыңыз. Smart App Control-ті қайта қосу үшін Windows-ты қайта орнату керек.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage(
      "Жинақтау жалаушалары",
    ),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("Жиналған уақыты"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Орта"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("Ядро файлы"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ядро туралы ақпаратты алу мүмкін болмады",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Іске қосу тәсілі"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Орналасуы"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Басқарылатын жоғары құқықты процесс",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Helper арқылы процесс",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Кірістірілген кітапхана",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Қолтаңбасы бар Helper арқылы басқарылатын процесс",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("Бөлек процесс"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Орындалу конфигурациясын ашу",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Платформа"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Жұмыс істеп тұр"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Орындалу конфигурациясы",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Баптаулар мен скрипттерден кейінгі қорытынды конфигурация. Тек оқуға арналған.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Орындалу конфигурациясын оқу мүмкін болмады",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Іске қосылуда…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Ядро күйі"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Тоқтатылған"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Деректер каталогы",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Өңір"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Құлау анықталды"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Құлау тесті"),
    "create": MessageLookupByLibrary.simpleMessage("Жасау"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("Жасалу уақыты"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage(
      "ByeDPI — DPI айналып өту құралы",
    ),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — осы қолданбаның негізі",
    ),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "FlClash-Patched — қосымша мүмкіндіктер",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — провайдер мүмкіндіктері мен идеялары",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage(
      "mihomo — прокси ядросы",
    ),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Бастау түймесін ұстайды және алынып тасталмайды",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "customColor": MessageLookupByLibrary.simpleMessage("Арнайы түс"),
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("Атау бос"),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Прокси немесе прокси провайдері таңдалмады, сондықтан ядро осы топты қабылдамайды",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Прокси топтары мен ережелерді қолданба проксилерінен және басқа профильдерден құрастыру",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Арнайы профиль ресурстары",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Арнайы профиль ресурстары проксилерді, ереже провайдерлерін, сүзгілер мен таңбаша жинақтарын сақтайды.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Қиып алу"),
    "dark": MessageLookupByLibrary.simpleMessage("Қараңғы"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Бақылау тақтасы"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Қосуға қолжетімді",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Өзгеріс сақталмады, кері қайтарылды",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("Әдепкі таңдау"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Әдепкі"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Конфигурация атауы мен түрі бар YAML сөздігі болуы керек",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Кідіріс"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Сәтсіз"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Кідіріс сынағы"),
    "delete": MessageLookupByLibrary.simpleMessage("Жою"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta негізіндегі көп платформалы прокси клиент. Қарапайым әрі ыңғайлы, ашық код, жарнамасыз.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Графикалық рұқсат агенті қолжетімсіз. Оны осы жұмыс үстелі сеансында іске қосып, қайталап көріңіз.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Рұқсат беру тоқтатылды. TUN іске қосылмады.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "Рұқсат берілмеді. TUN іске қосылмады.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN үшін рұқсат қажет. Рұқсат беру үшін қосылымды іске қосыңыз немесе TUN режимін қосыңыз.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Рұқсат күту уақыты аяқталды. Қосылым түймесі арқылы қайталап көріңіз.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "Рұқсат берілген Core тексерілген іске қосуды аяқтай алмады. Пакет пен жүйе журналдарын тексеріңіз.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core немесе Helper тұтастық тексеруінен өтпеді. Толық ReClash пакетін қайта орнатыңыз.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Жүйе параметрлері → Жалпы → Кіру элементтері мен кеңейтімдер бөлімінде ReClash Helper қызметіне рұқсат беріп, қайталап көріңіз.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "Орнатылған Helper басқа протоколды қолданады. Басқа орнатуды немесе қызметтің қайта анықталған баптауларын тексеріп, толық пакетті қайта орнатыңыз.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "Бар Linux Helper тіркеуін қауіпсіз ауыстыру мүмкін емес. Қызметтің иесін және тіркеуін тексеріңіз: қайта авторизациялау қақтығысты шешпейді.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd TUN Helper-ін іске қоса алмады. Қызмет журналын тексеріңіз: орнатушы алдыңғы орнатуды қалпына келтіруге тырысты.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN үшін systemd басқаратын Linux сеансы қажет. Бұл жүйе желілік Helper-ді іске қоса алмайды.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN Helper қолжетімсіз. Орнатылған пакет пен қызметті тексеріп, қайталап көріңіз.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы рұқсат беру немесе Core тоқтату әлі аяқталмады. Аяқталғанша күтіп, қайталап көріңіз.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN үшін дұрыс қол қойылған ReClash қолданбасы мен Helper қажет. Қолтаңбасыз немесе ad-hoc қолтаңбалы жинаққа рұқсат берілмейді.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core іске қосылды, бірақ TUN адаптері дайын емес. TUN қолданбас бұрын Core журналын тексеріңіз.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Нысан"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Нысан GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("Нысан IP ASN"),
    "details": m22,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Үшінші тарап API-іне сүйенеді; нәтиже — тек ақпарат",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Әзірлеуші режимі"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Әзірлеуші режимі қосылды.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Қосылым проксиі"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Dialer proxy — NTP серверіне жетуге қолданылатын шығыс.",
    ),
    "dialerProxyLoopStopped": m23,
    "direct": MessageLookupByLibrary.simpleMessage("Тікелей"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP бағыттауды өшіру",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP бағыттау өшірілгенде TUN ping-ке өзі жауап береді, сондықтан ping енді шынайы кідірісті көрсетпейді.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "TCP тірі ұстауды өшіру",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP-ні өшіру"),
    "disabled": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер жойылсын ба?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Жауапкершіліктен бас тарту",
    ),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарламаны орнату, көшіру немесе пайдалану арқылы сіз осы мәлімдемені толығымен оқыған және келісім берген деп есептелесіз. Оның қандай да бір шартына келіспесеңіз, Бағдарламаны пайдалануды дереу тоқтатып, жойыңыз.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("Қабылдау"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "Мен осы мәлімдемені оқыдым және түсіндім",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Түсінгеніңізді растау үшін төмендегі мәлімдемені оқып, төмендегі құсбелгіні қойыңыз:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Мәлімдемені растау",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Әзірлеушілер осы мәлімдемені кез келген шығарылыммен қайта қарап береді, ал өзгеріс ол шығарылым жарияланғанда күшіне енеді. Жаңартқаннан кейін Бағдарламаны әрі қарай пайдалану — қайта қаралған мәлімдемені қабылдағаныңыз.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Осы мәлімдемеге өзгертулер",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash («Бағдарлама») қолданар алдында осы мәлімдемені мұқият оқып шығып, оны толық түсінгеніңізді тексеріңіз. «Келісемін» басу — осы мәлімдемені оқығаныңызды, түсінгеніңізді және төмендегі әр шартты қабылдағаныңызды білдіреді. Келіспейтін болсаңыз, «Шығу» батырмасын басып, Бағдарламаны пайдалануды тоқтатыңыз.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "Қолданылмалы заң рұқсат ететін ең үлкен шекте әзірлеушілер де, ешбір үлес қосушы да Бағдарламаны пайдалану немесе пайдалана алмау нәтижесінде пайда болатын тікелей, жанама, кездейсоқ, ерекше, айыппұлдық немесе одан туындайтын зияндар — соның ішінде, бірақ олармен шектелмей: деректердің жоғалуы, құрылғының зақымдалуы, желі ақаулары, бизнестің тоқтауы, түсімнің жоғалуы немесе одан туындаған кез келген құқықтық дау — үшін жауапкершілік көтермейді, олардың болуы мүмкін екені алдын ала хабарланғанда да.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Жауапкершілікті шектеу",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарлама GPL-3.0 лицензиясы бойынша ашық кодты. Сол лицензияны сақтағанда оны еркін қолдануға, өзгертуге және таратуға болады; осы лицензия туынды шығармаларды да GPL-3.0 бойынша шығаруды және бастапқы авторлық құқық белгілерінің сақталуын талап етеді.\n\nБағдарламаның үшінші тарап компоненттері, соның ішінде Clash.Meta ядросы, өз лицензияларын ұстанады. Түпнұсқа авторлары өзгертілген немесе қайта таратылған нұсқалардан туындаған мәселелер үшін жауапкершілік көтермейді.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Ашық код лицензиясы",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Бағдарламаның өзі прокси серверін, түйінді, жазылымды немесе желіге қатынау қызметін де ұсынбайды және мұндай қызметтерді ұсынатын ешбір провайдермен серіктестік, агенттік немесе кепілдік қатынасында емес.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарлама жазылым URL-деріңізді, түйіндердің бөлшек мәліметтерін, конфигурация мазмұнын, кірген сайттарыңызды, байланыс жазбаларын, трафик мазмұнын немесе журналдарды жинамайды және жүктеп жібермейді. Бұл деректер құрылғыңызда қалады, оларға әзірлеушілер қол жеткізе алмайды.\n\nБағдарлама желіге тек оны қажет ететін мүмкіндікті қолданғанда ғана қол жеткізеді, мысалы, профильді жаңарту кезінде сіз көрсеткен жазылым URL-ын алу немесе жаңартуларды тексергенде GitHub-ға хабарласу.\n\nБағдарламада ешбір платформада аналитика немесе құлау туралы есеп беру қызметі жоқ.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Деректер жинау және құпиялылық",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Соңына дейін оқу",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарламаны пайдалану сіз тұратын жерде заңға сай болуын тексеру — сіздің міндетіңіз, ал онымен не істесеңіз де және соның зардаптары да заңды жауапкершілікті тек сіз көтересіз.\n\nСіз импорттайтын жазылымдар, түйіндер мен конфигурациялар — өзіңіздің таңдауыңыз. Олардың көзі заңды ма, мазмұны қауіпсіз бе, қызметі сенімді ме — бұл сіз бен олардың провайдерлерінің арасындағы мәселе.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Сіздің жауапкершілігіңіз",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Жоғарыдағы мәлімдемені енгізіңіз",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Мәлімдемеге сәйкес келмейді",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Түсінгеніңізді растау үшін төмендегі өріске осы мәлімдемені толық енгізіңіз:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Мәлімдемені қайталау",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарлама — Clash.Meta (mihomo) ядросы негізінде жасалған ашық кодты желілік прокси клиент. Ол тек конфигурацияны басқару, ережелер бойынша бағыттау және трафикті жіберу сияқты жергілікті мүмкіндіктерді ұсынады.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Бағдарламаның мәні",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Жазылым сілтемелері, конфигурация файлдары, ереже жинақтары, скрипттер, сыртқы ресурстар мен сыртқы сілтемелер — бәрін үшінші тарап ұсынады. Әзірлеушілер олардың заңдылығын, дәлдігін, қауіпсіздігі мен қолжетімділігін қарап шығу мүмкіндігі жоқ және оларға кепілдік бермейді.\n\nҮшінші тарап мазмұнының салдарынан туындаған деректердің ағып кетуі, ақшалай шығын, тіркелгіні бұғаттау немесе басқа да шығын сіз бен үшінші тараптың арасында шешіледі; оның үшін әзірлеушілер жауапкершілік көтермейді.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Үшінші тарап мазмұны",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарлама оқу, алмасу және техникалық зерттеу сияқты коммерциялық емес мақсаттарға ғана арналған. Оны кез келген коммерциялық мақсатта пайдалануға қатаң тыйым салынады, соның ішінде, бірақ олармен шектелмей: ақылы тарату, қоса сату, коммерциялық қызметтің бір бөлігі ретінде қолдану немесе Бағдарлама атынан бизнеспен айналысу. Кез келген коммерциялық қызметтің Бағдарлама мен оның әзірлеушілеріне қатысы жоқ.\n\nБағдарламаны сіздің еліңіздің немесе өңіріңіздің заңдары мен ережелерін бұзатын кез келген нәрсе үшін пайдалануға қатаң тыйым салынады, соның ішінде, бірақ олармен шектелмей: заңды түрде енгізілген желіге қатынау шектеулерін айналып өту, заңсыз мазмұнды тарату, желілік шабуыл жасау немесе басқалардың заңды құқықтарын бұзу.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Пайдалану шектеулері",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Бағдарлама «as is» (қалай болса солай) және «as available» (қолжетімдігінде) жағдайында ұсынылады: айқын да, жасырын да ешбір түрдегі кепілдік берілмейді, соның ішінде, бірақ олармен шектелмей: саудаға жарамдылық, белгілі бір мақсатқа сай келу, құқық бұзушылықсыздық, үзіліссіз қолжетімділік, қателердің және қауіпсіздік кемшіліктерінің болмауы.\n\nӘзірлеушілер Бағдарламаны қажеттеріңізді қанағаттандыратынына, үзіліссіз немесе қателіксіз жұмыс істейтініне кепілдік бермейді.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Кепілдік жоқ",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Ажыратылған"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Жаңа нұсқа табылды",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Осы жазба болмаса, TUN әр DNS сұрауын 53 портына (any:53) басып алады.",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS басып алу"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS режимі"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Осы жерге қосылған жазбалар әр URL мен файл профилінің DNS-ін алмастырады; қосылмағаны профильдің өз баптауын сақтайды. Арнайы профильдер DNS-ін өз мазмұнында орнатады.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS сұраулары"),
    "docked": MessageLookupByLibrary.simpleMessage("Бекітілген"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "done": MessageLookupByLibrary.simpleMessage("Дайын"),
    "download": MessageLookupByLibrary.simpleMessage("Жүктеу"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("Жүктеу жолағы"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Жаңарту жүктелуде",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Ұзақтығы"),
    "edit": MessageLookupByLibrary.simpleMessage("Өңдеу"),
    "editDashboard": MessageLookupByLibrary.simpleMessage(
      "Бақылау тақтасын өңдеу",
    ),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Глобалдық ережелерді өңдеу",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Проксиді өңдеу"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Прокси тобын өңдеу",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Ережені өңдеу"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSID өңдеу"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Редактор қолжетімсіз",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Уақыт"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Бос қосалқы"),
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("Ағылшынша"),
    "enabled": MessageLookupByLibrary.simpleMessage("Қосулы"),
    "entries": MessageLookupByLibrary.simpleMessage(" жазба"),
    "error": MessageLookupByLibrary.simpleMessage("Қате"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Қате мәліметтері"),
    "es": MessageLookupByLibrary.simpleMessage("Испанша"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Соңғы қолданбалардан жасыру",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Шығарылған нысан порттары",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Шығарылған нысан порттарына кететін трафик TUN арқылы өтпейді.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage(
      "Алып тастау сүзгісі",
    ),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Шығарылған интерфейстер",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "docker0 сияқты шығарылған интерфейстерден келетін трафик TUN арқылы өтпейді.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Шығарылған бастапқы порттар",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Шығарылған бастапқы порттардан келетін трафик TUN арқылы өтпейді.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Елемеу SSID-лері"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Елемеу SSID-і бар Wi-Fi-ға қосылғанда қолданбаның жұмыс күйі автоматты түрде ауысады.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage(
      "Шығарылған пайдаланушы идентификаторлары",
    ),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Шығарылған пайдаланушы идентификаторларының процестерінен келетін трафик TUN арқылы өтпейді.",
    ),
    "existsTip": m25,
    "exit": MessageLookupByLibrary.simpleMessage("Шығу"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Толық экраннан шығу",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Шығу түйіндері"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Күтілетін күй"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Жарамдылық мерзімі"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Файлды экспорттау"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "Журналдарды экспорттау",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Экспорт сәтті аяқталды",
    ),
    "extend": MessageLookupByLibrary.simpleMessage("Кеңейту"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Кеңейту режимі"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Кеңейту скрипті"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллер ядроны 9090 порты арқылы басқаруға мүмкіндік береді.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллер құпиясы",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Сыртқы сілтеме"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Өте үлкен"),
    "fade": MessageLookupByLibrary.simpleMessage("Еру"),
    "failedCount": m26,
    "failedItem": m27,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP сүзгісі"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Fake-IP сүзгі режимі",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP сүзгі режимінде қара тізім сәйкестіктерді алып тастайды, ақ тізім сәйкестіктерге ғана Fake-IP береді, ал ереже режимі сәйкестікті ережелермен анықтайды.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP ауқымы"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Fake-IP ауқымы (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Қосалқы сүзгісі"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль файлын тікелей жүктеп салу",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл өзгертілді. Өзгерістер сақталсын ба?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Сүзгі"),
    "filters": MessageLookupByLibrary.simpleMessage("Сүзгілер"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Процесті табу"),
    "floating": MessageLookupByLibrary.simpleMessage("Жүзбелі"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Профиль бойынша"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Жүйе бойынша"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Қаріп отбасы"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Өлшем"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "DNS сәйкестендіруін мәжбүрлеу",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNS сәйкестендіруін мәжбүрлеу домені DNS сәйкестендіруінен келген қосылымдарды да тыңдайды.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Домендерді мәжбүрлеу"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Домендерді мәжбүрлеу тізіміндегілер де тыңдалады; домені әлде бар қалған қосылымдарға тиіспейді.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Ядро мәжбүрлеп қайта іске қосылсын ба?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Французша"),
    "general": MessageLookupByLibrary.simpleMessage("Жалпы"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo: жад үнемдеу"),
    "global": MessageLookupByLibrary.simpleMessage("Глобалды"),
    "go": MessageLookupByLibrary.simpleMessage("Өту"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Жүктеу"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Қосымша ережелер баптауларына өту",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Скриптті баптауға өту",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Алғыс"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash олардың еңбегі арқасында өмір сүреді",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Тор"),
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("топ"),
    "groupTimeoutCount": m31,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер кэшке сақталсын ба?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Кіріс пайдаланушысы бойынша хеш",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Жарамдылық тексерімі"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Көмекші қызмет қолжетімсіз; TUN режимін қосу мүмкін емес. Қалпына келтіру үшін ReClash-ті қайта орнатыңыз.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Тізімнен жасыру"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP жасыру"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді жасыру"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Уақыты өткен проксилерді жасыру",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Соңғы кідіріс сынағының уақыты өткен проксилерді көрсетпеу",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Ауысу аралығы"),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostname": MessageLookupByLibrary.simpleMessage("Хост атауы"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Барлығын тазалау"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Барлық перне тіркесімдерін жою керек пе?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Композитор конфигурациясы",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Композитор конфигурациясына файлды қосу жолын енгізуге де болады. Бұл файлдар ReClash тіркесімдерімен бірге жаңарып, пернелерді жазу кезінде уақытша тазартылады. Жұмыс үстелінің конфигурациясы автоматты түрде өзгермейді; тіркесім қайшылықтарын сол жерде шешіңіз.",
    ),
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Жаһандық жылдам пернелер терезе жасырылған кезде де жұмыс істейді. Перне тіркесімін жазу үшін әрекетті түртіңіз.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Жұмыс үстелінің перне тіркесімдері",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Жұмыс үстелінің баптауларында команданы перне тіркесіміне тағайындаңыз. ReClash іске қосулы болуы керек, бірақ терезесі жасырын бола алады. Бұл жаһандық тіркесімдер жұмыс үстелінің баптауларында басқарылады.",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Композитор конфигурациясының файлдары қолжетімсіз. Жоғарыдағы жұмыс үстелі командаларын қолдана аласыз.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл тіркесімдер қолданба терезесі фокуста болғанда жұмыс істейді. Жаһандық перне тіркесімдері үшін төмендегі бөлімде жұмыс үстелі командаларын баптаңыз.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Перне тіркесімдерін басқару",
    ),
    "hotkeyNeedsModifier": m34,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Орнатылмаған"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Әдепкіні қалпына келтіру",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Барлық тіркесімдерді әдепкімен ауыстыру керек пе?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "Қауіпсіз режим перне тіркесімдерінің әрекеттерін өшіреді, бірақ тіркесімдерді өңдеуге болады.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Тіркелмеді, оны басқа қолданба алып қойған болуы мүмкін",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("сағат"),
    "hoursAgo": m35,
    "hoursAgoShort": m36,
    "hue": MessageLookupByLibrary.simpleMessage("Реңк"),
    "icon": MessageLookupByLibrary.simpleMessage("Таңбаша"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Белгіше жазбалары"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Таңбаша жинақтары"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Әзірге таңбаша жинақтары жоқ. Оларды Арнайы профиль ресурстары → Таңбаша жинақтары бөлімінде қосыңыз",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Таңбаша стилі"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Толтырылған"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Жасырын"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Қарапайым"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Белгіше URL-і"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Батарея оңтайландыруын елемеу",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорттау"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Бұл файл импорттауға болатын конфигурация емес",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Импорттау бұл профилде қазір бар прокси топтары, ережелер мен баптауларды алмастырады",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Файлдан импорттау"),
    "importFromLink": MessageLookupByLibrary.simpleMessage(
      "Сілтемеден импорттау",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL-ден импорттау"),
    "inbound": MessageLookupByLibrary.simpleMessage("Кіріс"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Қосылған интерфейстер",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Тек қосылған интерфейстерден келетін трафик TUN арқылы өтеді, ал шығарылған интерфейстер енді қолданылмайды.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage(
      "Қосылған пайдаланушы идентификаторлары",
    ),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Тек қосылған пайдаланушы идентификаторларының процестерінен келетін трафик TUN арқылы өтеді.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "Мерзімі ешқашан бітпейді",
    ),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "initFailed": MessageLookupByLibrary.simpleMessage(
      "Іске қосу сәтсіз аяқталды",
    ),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash іске қосылғанда қатені кезіктіріп, одан әрі жалғастыра алмайды. Мәселені хабарлау үшін мәліметтерді көшіріп алыңыз. Бұл қайталана берсе, деректерді тазалау әдетте қолданбаға қайта іске қосылуға мүмкіндік береді.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Бастамашы"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("Кім"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Прокси тобының атауын енгізіңіз",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Ереже мазмұнын енгізіңіз",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage("Жаңартуды орнату"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "Қолданбалар тізіміне рұқсат берілмегендіктен орнатылған қолданбалар көрінбейді. Рұқсатты жүйе баптауларынан қолмен беріңіз.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл жүйе рұқсат берілмейінше орнатылған қолданбалар тізімін жасырады. Қолданба сайын прокси баптау үшін рұқсат беріңіз.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Қолданбалар тізіміне рұқсат қажет",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Орнатылған қаріптер",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Ақылды таңдау",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Интерфейс атауы"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Интерфейс атауы — шығыс қосылымдар қолданатын желілік интерфейс.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Шығыс интерфейсі",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Тазалау"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Қолмен"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияға сәйкес",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Аралық"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Ішкі желі IP-і"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Жарамсыз сақтық көшірме файлы",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "192.168.0.0/16 сияқты CIDR пішінді IP ауқымын енгізіңіз",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP белгісі 63-тен аспауы керек",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Домен немесе IP мекенжайын енгізіңіз",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Жарамды таңбаша жинағы емес",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Жазылым сілтемесі немесе прокси бөлісу сілтемесі емес",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053 сияқты мекенжай мен порт енгізіңіз",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Тек tcp немесе udp қолданылады",
    ),
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 немесе 8000-9000 сияқты порт немесе ауқым енгізіңіз",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Бұл QR кодында профиль сілтемесі жоқ",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 немесе 8000-9000 сияқты сандар мен ауқымдарды / арқылы ажыратып енгізіңіз",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP мекенжай"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage(
      "Асыра пайдалану тарихы",
    ),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Белгілер"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Ұйым"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP түрін анықтау мүмкін болмады",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Жақсы"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Деңгей"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Қайта тексеру"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Тәуекелді"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Сапа"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Жауап берді"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Дереккөздер"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Басқа шығыс IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Түрі жоқ"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("Сұраныс шегі"),
    "ipType": MessageLookupByLibrary.simpleMessage("Түрі"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Корпоративтік"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Дата-орталық"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Мобильді желі"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Үй желісі"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Түрі белгісіз"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP нұсқасы"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 қосулы кезде ғана IPv6 трафигі қабылданады.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6 қосулы кезде VPN кіріс IPv6 трафигіне рұқсат береді.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "IPv6 күту уақыты (мс)",
    ),
    "itemsCount": m42,
    "ja": MessageLookupByLibrary.simpleMessage("Жапонша"),
    "justNow": MessageLookupByLibrary.simpleMessage("Дәл қазір"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "TCP тірі ұстаудың бос күту уақыты",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP тірі ұстау аралығы",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Кілт"),
    "kk": MessageLookupByLibrary.simpleMessage("Қазақша"),
    "ko": MessageLookupByLibrary.simpleMessage("Корейше"),
    "label": MessageLookupByLibrary.simpleMessage("Белгі"),
    "language": MessageLookupByLibrary.simpleMessage("Тіл"),
    "large": MessageLookupByLibrary.simpleMessage("Үлкен"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Соңғы жаңарту"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Іске қосу аяқталмады",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "Соңғы рет қолданба іске қоса бастағанда күтпеген жағдайда жабылып қалды, сондықтан автоматты баптау жасалмады. Оны қолмен бастап, қайталап көре аласыз.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Орналасу"),
    "license": MessageLookupByLibrary.simpleMessage("Лицензия"),
    "licenses": MessageLookupByLibrary.simpleMessage("Лицензиялар"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаға кіретін дестелер",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Ашық"),
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Жолдарды тасымалдау"),
    "link": MessageLookupByLibrary.simpleMessage("Сілтеме"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Профильді жазылым сілтемесінен немесе прокси бөлісу сілтемесінен алу",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("Тізім"),
    "listen": MessageLookupByLibrary.simpleMessage("Тыңдау"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Тыңдау үшін маршруттық белгі",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Тыңдау үшін маршруттық белгі тек Linux-те жұмыс істейді.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы қосылымдар",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Жүктеліп жатыр…"),
    "local": MessageLookupByLibrary.simpleMessage("Жергілікті"),
    "localImage": MessageLookupByLibrary.simpleMessage("Жергілікті сурет"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желі рұқсаты берілмеген: gvisor стегі қолданылғанда LAN-ға қол жетпейді.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage(
      "Жергілікті проксилер",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Орналасу рұқсаты",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Орналасу рұқсаты берілмегендіктен ағымдағы Wi-Fi атауы оқылмайды. Рұқсатты жүйе баптауларынан қолмен беріңіз.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Жүйе Wi-Fi атауын оқу үшін орналасу рұқсатын талап етеді. Android-де «Әрқашан рұқсат ету» опциясын таңдаңыз, әйтпесе қолданба фонда жүргенде Wi-Fi атауын оқи алмайды.",
    ),
    "locationPermissionGuide": m44,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Орналасу рұқсаты қажет",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Журнал"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Журнал деңгейі"),
    "logcat": MessageLookupByLibrary.simpleMessage("Журнал жинау"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Logcat өшірілгенде журнал бөлімі жасырылады.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Журналдар"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Журналдар және диагностика",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Журнал тесті"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback ерекшелігі"),
    "loose": MessageLookupByLibrary.simpleMessage("Кең"),
    "madeBy": MessageLookupByLibrary.simpleMessage("Жасаған"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Регистрді ескеру"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP-ді сәйкестендіру",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. сәтсіздік саны",
    ),
    "maxLengthTip": m45,
    "maximize": MessageLookupByLibrary.simpleMessage("Үлкейту"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Резиденттік жад",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage(
      "Қолданба және ортақ",
    ),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Бос үйінді"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage(
      "Пайдаланылған үйінді",
    ),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Ядро жұмыс істемей тұр",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Орта үстеме шығыны",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage(
      "Горутина стектері",
    ),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Процестің резиденттік жады бойынша бағаланған; жүйе көрсететін мәннен өзгеше болуы мүмкін.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Ядро қолданба процесінің ішінде жұмыс істейді. Оның үлесі орындалу ортасының статистикасы бойынша бағаланады, ал қалғаны қолданба мен ортақ жад ретінде есептеледі.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Жад ақпараты"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба мен ядро қолданатын жад",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Жад босатылды"),
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("Хабарлама тесті"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Бұл — хабарлама."),
    "minimize": MessageLookupByLibrary.simpleMessage("Кішірейту"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Шығу кезінде кішірейту",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Аралас порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("Тағы"),
    "name": MessageLookupByLibrary.simpleMessage("Атауы"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Төменгі панель",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Желі"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Сұрау тоқтатылды",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Серверге қосылу мүмкін болмады. Желі байланысыңызды немесе прокси баптауларын тексеріңіз",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Сервер мекенжайы анықталмады. URL дұрыс және DNS жұмыс істеп тұрғанын тексеріңіз",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Желі атауы"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Сұраулар тым көп (HTTP 429). Бір сәт күтіп, қайталап көріңіз",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Желі құпиясы"),
    "networkServerError": m55,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Желі жылдамдығы"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Трафикті басып алу",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Сұрау уақыты өтті. Желіңізді немесе проксиді тексеріп, қайталап көріңіз",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Қауіпсіз қосылым орындалмады. Сервер сертификаты жарамсыз болуы мүмкін немесе қосылымға біреу араласып жатыр",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Желі түрі"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Келесі сәйкестік"),
    "no": MessageLookupByLibrary.simpleMessage("Жоқ"),
    "noData": MessageLookupByLibrary.simpleMessage("Деректер жоқ"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Ақпарат жоқ"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("Енді еске салмау"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Желі жоқ"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Желісіз қолданбалар"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP-ті анықтамау"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Хост атауын шешпеу",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Сәйкес нәтиже табылмады",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Түйіндер"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Бұл сыртқы ресурс мәтін файлы емес",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Жоқ"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Жұмыс істемей тұр"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы прокси тобын таңдау мүмкін емес",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Синхрондау аралығы (минут)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP уақытты жүйелік сағаттың орнына NTP серверінен алады.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Бастау үшін профиль қосыңыз",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
    "obfs": MessageLookupByLibrary.simpleMessage("Бүркемелеу"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Бүркемелеу хосты"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Бүркемелеу режимі"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Бүркемелеу параметрі"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Бүркемелеу құпиясөзі",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("Қажет болғанда"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Қажет болғанда елемеу Wi-Fi-да проксиді кідіртеді.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Тек прокси трафигін есептеу",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Міндетті емес"),
    "options": MessageLookupByLibrary.simpleMessage("Опциялар"),
    "other": MessageLookupByLibrary.simpleMessage("Басқа"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Басқа үлес қосушылар",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Шығыс"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Шығысы"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Шығыс IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Шығыс режимі"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Нысанды алмастыру",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Нысанды алмастыру бастапқы мекенжайдың орнына тыңдалған доменге қосылады.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Ауыстыру жазбалары",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Таза IP-ді талдау"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Таза IP-ді талдау тек IP мекенжайы ғана бар қосылымдарды тыңдайды.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Құпиясөз"),
    "paste": MessageLookupByLibrary.simpleMessage("Қою"),
    "peers": MessageLookupByLibrary.simpleMessage("Пирлер"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Галереядан таңдау"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Терезені бекіту"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "WebDAV-ты байланыстырыңыз",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Скрипт атауын енгізіңіз",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Жарамды QR кодын жүктеңіз.",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Плагин"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Плагин хосты"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Плагин режимі"),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Басқа порт енгізіңіз",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Порт ауысуы"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("Порттар"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage(
      "Алдын ала бөлінген кілт",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Алғышарттар"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Пернені басыңыз"),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Жазылым қайталануын болдырмау",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Бұрыннан бар профиль қолданатын жазылым сілтемесін қабылдамау",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Алдын ала қарау"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Алдыңғы сәйкестік"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Жеке кілт"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Жеке кілттің пароль-фразасы",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Жарамды аралықты енгізіңіз."),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Автожаңарту аралығын енгізіңіз."),
    "profileDaysLeft": m61,
    "profileExpiresIn": m62,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль өзгертілді. Автоматты жаңарту өшірілсін бе?",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылым сілтемесі бар профиль қазірдің өзінде бар",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль атауын енгізіңіз.",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Тек осы профильге қолданылады; қосылмағаны әдепкісін қолданады.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Тек осы профильге қолданылады және желі баптауларындағы TUN алмастыру жазбаларынан басым болады.",
    ),
    "profileUpdatedAt": m63,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Жарамды профиль URL-ін енгізіңіз.",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль URL-ін енгізіңіз.",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профильдер"),
    "profilesSort": MessageLookupByLibrary.simpleMessage(
      "Профильдерді сұрыптау",
    ),
    "project": MessageLookupByLibrary.simpleMessage("Жоба"),
    "protocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Протокол параметрі"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("Протокол нұсқасы"),
    "providerInUse": m64,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Тек қашықтағы провайдерлерге қолдау көрсетіледі",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Сыртқы ресурстар"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m65,
    "proxiesProfileLabel": m66,
    "proxiesRemovedTip": m67,
    "proxiesReplacedTip": m68,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Прокси тізбегі"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Прокси тобы"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("Прокси тобы бос"),
    "proxyGroupInUse": m69,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Ядро іске қосылғанда топтар осы жерде пайда болады",
    ),
    "proxyGroupsCount": m70,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлері",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Прокси түрі"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Кэшті тазарту"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Жария кілт"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Таза қара"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Таза қара режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR коды"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QR кодын сканерлеу арқылы профиль алу",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Жылдам әрекеттер"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Жылдам өңдеу"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Соңғы сұраулар"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Ұсынылған"),
    "recordType": MessageLookupByLibrary.simpleMessage("Жазба түрі"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir порты"),
    "redo": MessageLookupByLibrary.simpleMessage("Қайтадан жасау"),
    "regex": MessageLookupByLibrary.simpleMessage("Тұрақты өрнек"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Аймақты қолдану"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "Аймақ немесе қолданба тізімдері өзгерді. Ағымдағы параметрлермен таңдауды қайталаңыз.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Бұл аймаққа сәйкес қолданбалар табылмады. Тізімдеріңіз өзгермеді.",
    ),
    "regionAppsPreview": m71,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Қолданба таңдауының алдын ала қарауы",
    ),
    "regionBypassSettings": m72,
    "regionChina": MessageLookupByLibrary.simpleMessage("Қытай"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("Елді таңдаңыз"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("Ағымдағы аймақ"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Қолмен орнатылған DNS пен MTU, айналып өту тізімі, бағыттау ережелері және қызмет таңдауы сақталады.",
    ),
    "regionDetected": m73,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage(
      "Құрылғы ұсынысы",
    ),
    "regionDnsSettings": m74,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Мысыр"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Интерфейс тіліне тәуелсіз аймақтық желі параметрлері мен қызмет тексерістері.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Желі параметрлері мен қызмет тексерістері өзгермейді.",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "Сәйкес ұсыныс табылмады. Тек уақыт белдеуі мен жүйе локалі пайдаланылады.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Қызмет тексерістері өшірулі",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Басқа / жалпы"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "Android жүйесінде MTU не айналып өту өзгерістері VPN қайта іске қосылуын растауды талап етуі мүмкін. Қолданбалар бөлек таңдалады.",
    ),
    "regionPreviewBase": m75,
    "regionPreviewMtu": m76,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "Прокси таңдауы мен бағыттау ережелері өзгермейді.",
    ),
    "regionPreviewServices": m77,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Алдын ала қарау",
    ),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage(
      "Профиль параметрлері",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Ресей"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды аймақ бойынша таңдау",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Аймақтық қолданба ұсыныстарын пайдалану үшін алдымен қолдау көрсетілетін аймақты таңдаңыз.",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "жүйелік тіл параметріндегі ел",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "жүйе тілі",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage(
      "уақыт белдеуі",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Аймақ профилі"),
    "regionTunSettings": m78,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage(
      "Анықталған аймақты таңдау",
    ),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "Елді таңдау тек алдын ала қарауды жаңартады. Аймақтық параметрлер қолданғаннан кейін өзгереді.",
    ),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Аймақтық бейімдеу",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Жадты босату"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Жадты босату мүмкін болмады",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Қашықтағы"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Қашықтағы нысан",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Қашықтағы DNS шешімі",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Алып тастау"),
    "rename": MessageLookupByLibrary.simpleMessage("Атауын өзгерту"),
    "replace": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Барлығын ауыстыру"),
    "request": MessageLookupByLibrary.simpleMessage("Сұрау"),
    "requests": MessageLookupByLibrary.simpleMessage("Сұраулар"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Сұраулар және жаңартулар",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Міндетті"),
    "reset": MessageLookupByLibrary.simpleMessage("Ысыру"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Бұл бетте өзгерістер бар. Олар бастапқы күйіне қайтарылсын ба?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Ысырылсын ба?"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы 0-ден үлкен болуы керек",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурстар"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Ережелерді ұстану"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Ережелерді ұстану DNS қосылымдарын ережелер бойынша бағыттайды және Proxy Server Nameserver қажет етеді.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Жауап коды"),
    "restart": MessageLookupByLibrary.simpleMessage("Қайта іске қосу"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Ядро қайта іске қосылсын ба?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Қалпына келтіру"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Барлық деректерді қалпына келтіру",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Тек профильдерді қалпына келтіру",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Қалпына келтіру стратегиясы",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Үйлесімділік",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Қайта жазу",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Қалпына келтіру сәтті аяқталды.",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Нәтиже"),
    "retry": MessageLookupByLibrary.simpleMessage("Қайталау"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("Автор және мейнтейнер"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Бағыттау адрестері"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Маршруттан шығарылған мекенжайлар",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Маршруттық белгі"),
    "ru": MessageLookupByLibrary.simpleMessage("Орысша"),
    "rule": MessageLookupByLibrary.simpleMessage("Ереже"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Логикалық «ЖӘНЕ» ережесі",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Толық доменді сәйкестендіру",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Домен кілт сөзін сәйкестендіру",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Доменнің тұрақты өрнегі бойынша сәйкестендіру",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Домен жұрнағын сәйкестендіру",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Толтырғыш таңбалар бойынша сәйкестендіру; тек * және ? қолданылады",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP белгісін сәйкестендіру (тек tproxy UDP кірісі үшін)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Мақсат портының диапазонын сәйкестендіру",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "IP-дің ел кодын сәйкестендіру",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite-тегі домендерді сәйкестендіру",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Кіріс атауын сәйкестендіру",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Кіріс портын сәйкестендіру",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Кіріс түрін сәйкестендіру",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Кіріс пайдаланушы атауын сәйкестендіру; бірнеше атауды / арқылы бөліңіз",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IP-дің ASN-ін сәйкестендіру",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP адрес диапазонын сәйкестендіру; IP-CIDR6 — жай ғана балама атау",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IP адрес диапазонын сәйкестендіру",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IP жұрнағының диапазонын сәйкестендіру",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Барлық сұрауларды сәйкестендіреді; шарттар қажет емес",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP немесе UDP-ні сәйкестендіру",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Логикалық «ЕМЕС» ережесі",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Логикалық «НЕМЕСЕ» ережесі",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Процесс атауы бойынша сәйкестендіру; Android-та пакет атауына сәйкес келеді",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Процесс атауының тұрақты өрнегі бойынша сәйкестендіру; Android-та пакет атауына сәйкес келеді",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Процесс атауының толтырғыш таңбалары бойынша сәйкестендіру; тек * және ? қолданылады",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Процестің толық жолы бойынша сәйкестендіру",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Процесс жолының тұрақты өрнегі бойынша сәйкестендіру",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Процесс жолының толтырғыш таңбалары бойынша сәйкестендіру; тек * және ? қолданылады",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Қайта сәйкестендіру атауын сәйкестендіру; бірнеше атауды / арқылы бөліңіз",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағына сілтеме жасайды; rule-providers қажет",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP-дің ел кодын сәйкестендіру",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP-дің ASN-ін сәйкестендіру",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP адрес диапазонын сәйкестендіру",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP жұрнағының диапазонын сәйкестендіру",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Бастапқы порттың диапазонын сәйкестендіру",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Ішкі ережеге сәйкестендіру; жақшаларға назар аударыңыз",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux пайдаланушы идентификаторын сәйкестендіру",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Ереже бос"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Ережелер әр элементте бір ережесі бар YAML тізімі болуы керек, мысалы - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent тікелей",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS бөгеу",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Прокси loopback бөгеу",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("QUIC бөгеу"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("STUN бөгеу"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желі тікелей",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple және Microsoft тікелей",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "Ереже провайдерлері",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Ереже жинағы"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағында қолдануға болатын жазба жоқ",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Бұл mrs файлын оқу мүмкін болмады",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағы домендер мен IP ауқымдарын араластырады, сондықтан оның түрін анықтау мүмкін емес",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Ереже нысаны"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "Ереже қолданылатын түрімен басталуы керек, мысалы DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Ережелер"),
    "rulesCount": m79,
    "runTime": MessageLookupByLibrary.simpleMessage("Жұмыс уақыты"),
    "running": MessageLookupByLibrary.simpleMessage("Жұмыс істеп тұр"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Орындалу конфигурациясы",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Қауіпсіз режим"),
    "safeModeAppTitle": m80,
    "saturation": MessageLookupByLibrary.simpleMessage("Қанықтық"),
    "save": MessageLookupByLibrary.simpleMessage("Сақтау"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер сақталсын ба?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрипт режимі: бүкіл профиль кеңейту скриптімен қайта жазылады",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Таңдалғанға жылжыту",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Іздеу"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m81,
    "secretKey": MessageLookupByLibrary.simpleMessage("Кілт"),
    "sectionsInEffect": m82,
    "selectAll": MessageLookupByLibrary.simpleMessage("Барлығын таңдау"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағын таңдаңыз",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Бөлу стратегиясын таңдаңыз",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Таңдалған"),
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serviceAbnormalCount": m83,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Барлығы қолжетімді",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Қолжетімді"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Бұғатталған"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Тексеру"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Барлығын тексеру"),
    "serviceCheckedAt": m84,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Жақында"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Провайдер бұғатталған",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage(
      "Тексеру сәтсіз аяқталды",
    ),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Қызметтерді баптау"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Тек түпнұсқалар",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Тексерілмеген"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Қатынас шектелген",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Бақылау тақтасында көрсетіледі",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Қызметтер күйі"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Қолжетімсіз"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Аймаққа қолдау жоқ",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("баптаулар"),
    "settings": MessageLookupByLibrary.simpleMessage("Баптаулар"),
    "settingsCount": m85,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Бұл профиль шифрланған. Жалғастыру үшін age кілтін енгізіңіз.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Бұл сервер бөлек сынаққа жауап берді. Оған ауысып, бүкіл маршрутты қайта тексеріңіз.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "ReClash ашылғанда қосылу",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Осы қосылымды қолданбамен бірге іске қосу.",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Қосылымды тексеру",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "Нәтиже барлық қолданбаға немесе веб-сайтқа емес, осы маршрутқа қатысты.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдалған бір маршрутты тексереміз. Жүйенің рұқсат сұраулары бөлек ашылады.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылып, тексерілуде",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Расталды"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдалған маршрут жауап берді. Трафик профиль ережелеріне сай жүреді.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым жұмыс істеп тұр",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Прокси мекенжайын көшіру",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage(
      "Барлық қолданбалар",
    ),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN құрылғы трафигін ұстайды. Жүйе рұқсат сұрауы мүмкін.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android VPN қосылымын жасауға рұқсат сұрайды. Қолданбаларды таңдауды қолжетімділік баптауларынан жасауға болады.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданатын қолданбаларды таңдаңыз. Қай қосылымдардың сервер арқылы өтетінін профиль ережелері анықтайды.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды өзім қолмен баптаймын",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Қосқыңыз келетін әр қолданбада жергілікті прокси мекенжайын көрсетіңіз.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Барлық трафикті ұстау оның бәрін сервер арқылы жіберу дегенді білдірмейді. Тікелей маршруттар сақталады.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Жүйелік прокси",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Жүйелік проксиді қолдамайтын қолданбалар тікелей қосылады.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Қай қолданбалар қосылуы керек?",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Мәліметтер"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылымға назар аудару қажет",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Кез келген таңдауды баптаулардан өзгертуге болады.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Жалғастыру"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Шарттарды оқымас бұрын тілді таңдаңыз. Оны кейін өзгертуге болады.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Тілді таңдаңыз",
    ),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "Баптау аяқталмады; қосылым тексерілген жоқ.",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Осы мекенжайды қосқыңыз келетін қолданбаларда көрсетіңіз. Бұл тексеру олардың бапталғанын растамайды.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Жергілікті прокси дайын",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Тексерілмеген"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "Маршрут жауап берді, бірақ кейбір тексерулерді растау мүмкін болмады.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылды, бірақ шектеулер бар",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Жүйе сұрауында қосылымға рұқсат беріңіз, қайта көріңіз немесе басқа ауқымды таңдаңыз.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Рұқсат қажет",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Басқа сервер ізделуде",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Қосылым іске қосылуда",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage(
      "Негізгі модуль іске қосылуда",
    ),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Шығу нүктесі расталуда",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Профиль қолданылуда",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Маршрут тексерілуде",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Қызметтер тексерілуде",
    ),
    "setupProfileCount": m86,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash серверлер ұсынбайды. Провайдеріңіздің жазылымын немесе конфигурациясын импорттаңыз.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Профильді импорттау",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Жазылым немесе бөлісу сілтемесі",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Профиль дайын"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("Кейін баптау"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым профилін қосу",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Қосылымыңыз"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Тексеру"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Қамту аясы"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage(
      "Осы аймақтық параметрлерді қолдану",
    ),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "Ұсынылған аймақ интерфейс тіліне емес, осы құрылғыға негізделген. Оны желіңізге сәйкес келсе ғана қолданыңыз.",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Профильдің әдепкі мәндерін сақтау",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Қайта тексеру"),
    "setupReport": MessageLookupByLibrary.simpleMessage("Тексеру есебі"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Қосылымға рұқсат беру",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage("Қосылымды баптау"),
    "setupResume": MessageLookupByLibrary.simpleMessage("Баптауды жалғастыру"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "Тексеру кезінде маршрут өзгерді. Ағымдағы қосылымды қайта тексеріңіз.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "Қауіпсіз режим нақты қосылымды іске қоспайды. Баптауды сақтаңыз немесе қалыпты жинақта тексеріңіз.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Таңдауларыңызды сақтау мүмкін болмады. Қайталап көріңіз.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Қоспай сақтау",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдауларыңыз сақталды. Дайын болғанда негізгі беттен қосыла аласыз.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("Кейін қосылу"),
    "setupStepStatus": m87,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдауларыңыз сақталды. Алдыңғы қосылым тоқтатылған жоқ.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Тексеру тоқтатылды",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Алғашқы қосылым"),
    "setupTryServer": m88,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Жауап жоқ"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "Қосылым іске қосылды, бірақ таңдалған маршрут жеткілікті нәтиже бермеді.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым расталмады",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "Әрекет аяқталмады. Қайталап көріңіз немесе мәліметтерді ашыңыз.",
    ),
    "shareLinkUnreadable": m89,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Сілтемелерден прокси оқу мүмкін болмады",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Көрсету"),
    "showLess": MessageLookupByLibrary.simpleMessage("Жию"),
    "showMore": MessageLookupByLibrary.simpleMessage("Жаю"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Хабарламадағы «Тоқтату» түймесі",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді көрсету"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Бүйірлік панельді бұлыңғырлау",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Терезе артындағы бұлыңғыр жұмыс үстелін бүйірлік панель арқылы көрсету",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Жасырын іске қосу"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Жасырын іске қосу терезені көрсетпей іске қосады.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Жекелей қосу"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Жекелей импорттау"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Осы жерге бір сілтеме енгізіңіз; бірнешеуін тізімнің жылдам өңдеуінен өңдеңіз",
    ),
    "singleValueTip": m90,
    "size": MessageLookupByLibrary.simpleMessage("Өлшем"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Сертификатты тексеруді елемеу",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Елемеу домендер"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Елемеу домендер тізіміндегі тыңдалған домен қолданылмайды.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Нысан мекенжайларын елемеу",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Бастапқы мекенжайларды елемеу",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Жылжу"),
    "sliders": MessageLookupByLibrary.simpleMessage("Жүгірткілер"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Протоколдар"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Sniffer TLS, HTTP және QUIC трафигінен доменді оқиды, сондықтан ережелер оны сәйкестендіре алады.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS порты"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Жұмсақ"),
    "sort": MessageLookupByLibrary.simpleMessage("Сұрыптау"),
    "source": MessageLookupByLibrary.simpleMessage("Дереккөз"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Бастапқы IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Арнайы прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Арнайы ережелер"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Спектр"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Жылдамдық статистикасы",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Бөлу стратегиясы"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Бөлу стратегиясы бос болмауы тиіс",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSID-лер бос"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Стек режимі"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Стек ізі"),
    "standard": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартты режим: профиль үстіне ережелер қосылады",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Іске қосу"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("Нөлден бастау"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN іске қосылуда…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Іске қосу және фон",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Күй"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS өшірілгенде жүйелік DNS қолданылады.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Тоқтату"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN тоқтатылуда…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Қатаң маршруттау"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Қатаң маршруттау DNS сияқты трафиктің TUN-ды айналып өтуіне жол бермейді және басқа құрылғылар бұл құрылғыға енді қатынай алмайды.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "submit": MessageLookupByLibrary.simpleMessage("Жіберу"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("Автоматты"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Таңдамалы User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Басқару таңбаларынсыз жарамды User-Agent енгізіңіз.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Клиентті таңдау құрылғы идентификаторын жібермейді.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Сұрау клиенті",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Бұл параметрлер жазылым URL мекенжайларына қолданылады. Прокси сілтемелері жергілікті түрде импортталады.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылымды тексеру үшін AGE кілтін енгізіңіз.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Тексерілген нәтижені қолдану"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "Сервер авторизацияны қабылдамады. Клиент таңдау тоқтатылды.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Тексеру",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Үйлесімді жазылымды алу мүмкін болмады. Бұрынғы конфигурация өзгерген жоқ.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы мәндерді сақтамай және VPN-ді қайта іске қоспай тексереді. Түйіндердің қолжетімділігі емес, конфигурацияның талдануы тексеріледі.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Импорттағы деректер жоғалуы туралы қайта сұрау",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Жазылым URL мекенжайын жасыру",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Соңғы сәтті клиент"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "Импорт кезінде бастапқы деректердің бір бөлігі тасымалданбайды. Қолданар алдында жоғалатын деректерді тексеріңіз.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Осы клиентті пайдалану"),
    "subscriptionCompatibilityPrepared": m91,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core бұл нәтижені талдады. Ол әлі сақталған да, қолданылған да жоқ.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "Сервер сұрауларды шектеді. Кейінірек қайталаңыз.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Жазылым URL мекенжайын көрсету",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "Пішін немесе профиль өзгерді. Жазылымды қайта тексеріңіз.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "Жазылымды тексеру уақыты аяқталды.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Үйлесімділік",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Қосылу мүмкін болмады. Клиент таңдау тоқтатылды.",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Операциялық жүйе мен құрылғы моделін де жіберу",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "Идентификатормен бірге операциялық жүйе нұсқасы мен құрылғы моделі жіберіледі.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Осы жазылым көзіне тұрақты бүркеншік құрылғы идентификаторы жіберіледі. Бұл аппараттық аттестаттау емес, келісім тек осы құрылғыда сақталады.",
    ),
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "Қосылғанда, профиль бұл параметрді өзгертпесе, құрылғы идентификаторы барлық URL жазылымдарының сұрауларымен жіберіледі. Операциялық жүйе мен құрылғы мәліметтерін әр жазылым үшін бөлек қосуға болады.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылым идентификаторы",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "HWID жіберу",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Жалпы параметрді қолдану",
    ),
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "Қабылдау және импорттау",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Бастапқы деректердің бір бөлігі сақталмайтынын түсінемін.",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "Тек қолдау көрсетілетін түйіндермен жалғастыру.",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "Бастапқы клиент параметрлері тасымалданбайтынын түсінемін.",
    ),
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash конфигурациясы",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "шифрланған жазылым",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "прокси сілтемелері",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "белгісіз пішім",
    ),
    "subscriptionImportIgnoredSections": m92,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Импорттауға болатын қолдау көрсетілетін прокси түйіндері жоқ.",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Осы жазылым үшін келісімді есте сақтау",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Тек осы дереккөзге, форматқа және қабылданған жоғалту түрлеріне қолданылады. Жаңа жоғалтуларға қайта келісу қажет.",
        ),
    "subscriptionImportReviewSummary": m93,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылым импортын тексеру",
    ),
    "subscriptionImportSkippedNodes": m94,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Жазылыс туралы ақпарат",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Жазылым"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Тіркелгі",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Жоспар сатып алу",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Трафик сатып алу",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "Логотип сілтемесі",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Қолдау",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Веб-сайт",
    ),
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Провайдердің жаңарту аралығын пайдалану",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "sudo үшін құпиясөзіңізді енгізіңіз",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Кідірілді…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Профильді ауыстыру"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхрондау"),
    "system": MessageLookupByLibrary.simpleMessage("Жүйе"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Жүйелік қолданбалар"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Жүйелік прокси"),
    "tab": MessageLookupByLibrary.simpleMessage("Қойынды"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Қойынды анимациясы"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Қайта тексеру үшін белгіні түртіңіз",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Рұқсат беру үшін түртіңіз",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Нысан"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage(
      "Параллельді TCP қосылымдары",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Сынақ аралығы"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Сынау URL-ы"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Қолданған кезде сынау",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Мәтін масштабы"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Мәтін осылай көрінеді",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Тақырып"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Тақырып түсі"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Тақырып режимі"),
    "tight": MessageLookupByLibrary.simpleMessage("Тығыз"),
    "time": MessageLookupByLibrary.simpleMessage("Уақыт"),
    "timeout": MessageLookupByLibrary.simpleMessage("Күту уақыты"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Тондалған"),
    "tip": MessageLookupByLibrary.simpleMessage("Кеңес"),
    "tk": MessageLookupByLibrary.simpleMessage("Түрікменше"),
    "toggle": MessageLookupByLibrary.simpleMessage("Қосу/Өшіру"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Төзімділік"),
    "tools": MessageLookupByLibrary.simpleMessage("Құралдар"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Бөлімді таңдаңыз немесе баптауды іздеңіз",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Бұл барлық белсенді қосылымдарды жабады. Жалғастырасыз ба?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("Әрекет аяқталды"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Конфигурация"),
    "toolsData": MessageLookupByLibrary.simpleMessage(
      "Ресурстар және деректер",
    ),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "Сәйкес баптаулар немесе әрекеттер жоқ",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Мәлімет және жөндеу",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("Соңғы қолданылған"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Алдымен аутентификацияны қосыңыз",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Алдымен сыртқы контроллерді қосыңыз",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Бұл әрекетті қолдану үшін ядроны іске қосыңыз",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Алдымен арнайы желілік интерфейсті таңдаңыз",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Алдымен MIPS желі стегін таңдаңыз",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Алдымен осы DNS алмастыруын DNS бетінде қосыңыз",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Алдымен WebDAV-ты баптаңыз",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Диагностика"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Бекіту"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Бекітілген"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Ядроны қайта іске қосу",
    ),
    "toolsResults": m95,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Іске қосу"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Бөлім"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Баптау"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Босату"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Ресурстарды жаңарту",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Ережелер мен скрипттерді жаңарту конфигурацияны қайта қолдана алады және қосылымдарға әсер етеді. Жалғастырасыз ба?",
    ),
    "torch": MessageLookupByLibrary.simpleMessage("Қолшам"),
    "total": MessageLookupByLibrary.simpleMessage("Барлығы"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Жүктелген"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Жалпы трафик"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Жүктеп салынған"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy порты"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficPeak": m96,
    "trafficTotal": m97,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Трафик шығыны"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash әртүрлі елдердің адамдары пайдалана алатындай сіздің тіліңізде сөйлейді. Қандай да бір сөз тіркесі көзге оғаш көрінсе — жазыңыз, түзетеміз.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Аударма түзетуін ұсыну",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Тасымал"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN рұқсаттау сәтсіз болды, сондықтан ол өшірілді.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN тек әкімші режимінде ғана жұмыс істейді.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Осы жерге қосылған жазбалар әр профильдің TUN баптауларын алмастырады; қосылмағаны профильдің өз баптауын сақтайды. Арнайы профиль өзі қосқан жазбалар басым болады.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Өшіру"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Қосу"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP реле режимі"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP күту уақыты"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP күту уақыты секундпен есептеледі және тек gvisor, system және mixed стектерімен жұмыс істейді.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Кері қайтару"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Бірыңғай кідіріс"),
    "unknown": MessageLookupByLibrary.simpleMessage("Белгісіз"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Белгісіз желі қатесі",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage(
      "Бұрынғы өлшеміне келтіру",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Атаусыз"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Терезені босату"),
    "update": MessageLookupByLibrary.simpleMessage("Жаңарту"),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Жаңарту арнасы"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage(
      "Алдын ала шығарылым",
    ),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Тұрақты релиз",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Жаңартуларды тексеру мүмкін болмады.",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Жаңартуды жүктеу мүмкін болмады.",
    ),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Пакет орнатқышын іске қосу мүмкін болмады.",
    ),
    "updateInstalledVersion": m98,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage(
      "Сізде соңғы нұсқа орнатылған.",
    ),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage("Не жаңалық"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Релиз ескертпелері қолжетімсіз.",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданбасына осы көзден қолданбалар орнатуға рұқсат беріп, жалғастыру үшін қайта оралыңыз.",
    ),
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Толық релиз ескертпелерін көру",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Барлық өзгерістерді көрсету",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Жүктелген жаңартудың тұтастығын тексеру мүмкін болмады.",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Жүктеп салу"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Жүктеп салу жолағы",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL схемасы"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Жазылым қосу"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP немесе HTTPS жазылым сілтемесінен профиль жасау. Атау міндетті емес.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Шифрланған сілтеменің түпнұсқалығы расталмады. Ол бүлінген немесе басқа кілтті қолдануы мүмкін.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Сілтеме жасау"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "Тек осы әрекетке қажетті өрістер қосылады. Конфигурация сілтемесі барлық мазмұнды қамтиды және растауды айналып өтпейді.",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Қолданбаны жабу"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Жабу баптауына сай терезені жасыру немесе ReClash қолданбасынан шығу. Android қалыпты жабу тәртібін қолданады.",
    ),
    "urlSchemeConfigCounts": m99,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML немесе JSON конфигурациясын қойыңыз",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Конфигурация құрамы",
    ),
    "urlSchemeConfirmMessage": m100,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Қолданбаның сыртқы пәрмені",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Сыртқы қосылу және жабу пәрмендері растауды талап етеді. Қосылым пәрмендерін қолданбас бұрын бастапқы баптауды аяқтаңыз.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Қосылу"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған профиль мен ағымдағы қамту баптауларын пайдаланып қосылымды бастау.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Қосылым"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Мазмұн пішімі",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "Түрлендіру кезінде кейбір мазмұн өткізіледі. Импорт кезінде өзгерістерді қарап, растаңыз.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Сілтемені көшіру мүмкін болмады. Қайталап көріңіз.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage(
      "Сілтемені көшіру",
    ),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Сілтеме жеткізілмеді немесе кезек толды. Ағымдағы әрекет аяқталған соң қайталап көріңіз.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Ажырату"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған профильді өзгертпей қосылымды тоқтату.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Ендірілген конфигурация",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Профиль мысалы",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны импорттау",
    ),
    "urlSchemeImportConfirm": m101,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Сілтемеге Base64 түрінде енгізілген UTF-8 конфигурациясын импорттау. Атау міндетті емес.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Сілтемені тексеру",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Қолданба немесе профиль сілтемесін қойыңыз",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "Тексеру осы құрылғыда орындалады. Ол сілтемені ашпайды, жазылымды жүктемейді және профильді импорттамайды.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "Сілтеме құрылымы дұрыс. Жазылымның қолжетімділігі мен ядро тексеруі импорт кезінде ғана орындалады.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Тексеру нәтижесі",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны орнату",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash клиенттері қолдайтын install-config сілтемесі арқылы жазылымды импорттау.",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданбасын жарлықтармен, сайттармен және басқа қолданбалармен байланыстырыңыз. Дайын сілтеме жасаңыз немесе оны ашпай тұрып тексеріңіз.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "Ендірілген конфигурация дұрыс UTF-8 Base64 деректері емес.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "Сілтеме дұрыс емес. Құрылымын және пайыздық кодталуын тексеріңіз.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Профиль атауы 64 таңбадан аспауы және басқару таңбаларын қамтымауы керек.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Дұрыс HTTP немесе HTTPS жазылым URL мекенжайын енгізіңіз.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "Сілтемеде жазылым URL мекенжайы немесе конфигурация жоқ.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "Ешбір әрекет орындалмады.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Қолданбаны көрсету"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Қосылымды өзгертпей ReClash қолданбасын алдыңғы қатарға шығару.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Параметрлер"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферін оқу мүмкін болмады. Сілтемені қолмен қойыңыз.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage(
      "Сілтемені алдын ала қарау",
    ),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Сілтемені көру үшін міндетті өрістерді толтырыңыз.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Сілтемеде кіру токендері немесе прокси деректері болуы мүмкін. Оны тек сенімді адамдармен бөлісіңіз; ReClash сілтемелер тарихын сақтамайды.",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "Профиль пәрмендері құрастыру құралын ашады. Сыртқы импорт келісімді сұрайды және қалыпты тексеру мен түрлендіруді сақтайды.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Профильдер"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Прокси сілтемелері",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Сілтеме танылды",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Сыртқы қосылым пәрмендерін қолданбас бұрын қосылым баптауын аяқтаңыз.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Қолдау көрсетілетін импорт сілтемелері",
    ),
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Clash сілтемелері, INCY және Happ орауыштары және прокси сілтемелері қолмен импорттауда және QR сканерлеуде де жұмыс істейді. Белгісіз шифрлау нұсқалары қабылданбайды.",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Қосылымды ауыстыру",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Тоқтап тұрса қосылу, жұмыс істеп тұрса ажырату. Растау терезесі нақты әрекетті көрсетеді.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "Сілтемеде кірістірілген орауыштар тым көп.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "Сілтеме 4 МБ немесе ендірілген конфигурация 2 МБ шегінен асады.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Бұл сілтеме пәрменіне қолдау көрсетілмейді.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Бұл шифрлау нұсқасына қолдау көрсетілмейді. Қалыпты жазылым сілтемесін сұраңыз.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage(
      "Мысалды қолдану",
    ),
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "Жазылым сілтемелері, ендірілген конфигурациялар және INCY crypt1",
    ),
    "urlTip": m102,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hosts файлын қолдану"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Жүйелік hosts файлын қолдану",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("қолданылған"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Жұмсалған трафик"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Пайдаланушы атауы"),
    "uz": MessageLookupByLibrary.simpleMessage("Өзбекше"),
    "value": MessageLookupByLibrary.simpleMessage("Мән"),
    "view": MessageLookupByLibrary.simpleMessage("Көру"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Виртуалды IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Жанды"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN баптауларының өзгергені анықталды",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN барлық жүйелік трафикті VpnService арқылы автоматты түрде бағыттайды.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Бұлыңғырлау"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Карточкалардың мөлдір еместігі",
    ),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("Суретті таңдау"),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Қараңғылату"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("Суретті реттеу"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Жеке фонды пайдалану",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("Суретті орналастыру"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Сыйдыру"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Толтыру"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Созу"),
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "Қолдану үшін сақталған фонды түртіңіз немесе жаңасын қосыңыз.",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Көлденең орналасуы",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG немесе WebP пішіміндегі жарамды суретті таңдаңыз.",
    ),
    "wallpaperImageLabel": m103,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрлау"),
    "wallpaperLibraryFull": m104,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Суреттің мөлдір еместігі",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage(
      "Оқуға ыңғайлылық",
    ),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("Суретті жою"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Әсерлерді қалпына келтіру",
    ),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Кадрлауды қалпына келтіру",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Фонды сақтау мүмкін болмады. Алдыңғы фон сақталды.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Масштаб"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG немесе WebP · 20 МБ-қа дейін",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("Жеке фон"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Көлемі 20 МБ-тан, ал ажыратымдылығы 50 мегапиксельден аспайтын суретті таңдаңыз.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Сурет қолжетімсіз",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Тік орналасуы",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV баптаулары",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Веб-панель"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Панельге қолжетімділік тоқтатылды",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік жергілікті және аутентификациямен қорғалған. Сақталған сыртқы контроллер параметрлері өзгермейді. Браузерде жұмысты аяқтаған соң қолжетімділікті осы жерден тоқтатыңыз.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Панель конфигурациясын қолдану мүмкін болмады.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "Жүктелген файл жарамды панель мұрағаты емес.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Ядро тіркелгі деректерін қабылдамады. Панельді қайта ашыңыз.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "Браузердің қолжетімділігі тоқтатылғанға немесе ReClash жабылғанға дейін сақталады",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Басқа панель әрекеті орындалуда.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Панель әрекеті тоқтатылды.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "Бақылау сомасы бекітілген шығарылымға сәйкес келмейді.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ядро дайын емес.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Ядроны басқаруға арналған жергілікті веб-панельдер",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Панельді жүктеу мүмкін болмады. Қайталап көріңіз.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Панель жүктелуде",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "Панель жабылғанда қолжетімділік тоқтайды",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Панельге қолжетімділікті тоқтату",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Панель мұрағаты ашылуда",
    ),
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage(
      "Панель файлдары",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Панель"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Панельді орнату",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Таңдалған панель алғаш ашылғанда жүктеледі. Бекітілген шығарылым SHA-256 арқылы тексеріледі.",
    ),
    "webDashboardInstalledVersion": m105,
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Браузерді ашу мүмкін болмады.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Белсенді панель сеансы жоқ",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Панельді ашпас бұрын профильді таңдаңыз.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Орнатылмаған",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Панельді ашу"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Браузерде ашу",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Қайта жүктеу"),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "Қауіпсіз режимде панельге қолжетімділік өшірулі.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Панель файлдарын қауіпсіз оқу немесе ауыстыру мүмкін болмады.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "Панель мұрағаты рұқсат етілген өлшемнен асады.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Ядро бұл панельді ұсынбайды.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Жүктеу тексерілуде",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Ақ тізім режимі"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Жүйеге жазу"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Write to system жүйелік сағатты да орнатады; Android оны елемейді.",
    ),
    "yearsAgo": m106,
    "yearsAgoShort": m107,
    "yes": MessageLookupByLibrary.simpleMessage("Иә"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Қытайша (жеңілдетілген)"),
  };
}
