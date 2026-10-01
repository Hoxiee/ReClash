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

  static String m0(value) => "Off (suggested ${value})";

  static String m1(time) => "DPI айналып өтуі белсенді: ${time}";

  static String m2(code) => "Растау коды: ${code}";

  static String m3(when) => "Соңғы байланыс ${when}";

  static String m4(seconds) => "Код ${seconds} секундтан кейін жарамсыз болады";

  static String m5(host) => "${host} мекенжайында жұптасуға дайын";

  static String m6(time) => "Қосылғаны: ${time}";

  static String m7(code) =>
      "Windows ReClashCore.exe файлын іске қосудан бас тартты (${code} қатесі). Smart App Control немесе AppLocker сияқты қолданба бақылау саясаты қолтаңбасы жоқ қолданбаларды блоктайды; сол саясатта ReClash-ке рұқсат беріңіз немесе саясатты өшіріңіз де, қайталап көріңіз.";

  static String m8(name) =>
      "Қолданба қатарынан екі рет іске қосылуын аяқтай алмады. Циклді тоқтату үшін ${name} профилі таңдаудан алынып тасталды, автоматты баптау жасалмады. Профильді кез келген уақытта қайта таңдай аласыз.";

  static String m9(url) => "${url} сілтемесінен профиль жасағыңыз келе ме?";

  static String m10(date, days) => "${date} бастап · ${days} күн қамту";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 күн бұрын', other: '${count} күн бұрын')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 күн қалды', other: '${count} күн қалды')}";

  static String m13(label) => "Таңдалған ${label} жойылсын ба?";

  static String m14(label) => "Бұл ${label} жойылсын ба?";

  static String m15(token) => "${token} қолданба орнатады, алынып тасталады";

  static String m16(count) =>
      "${Intl.plural(count, zero: 'аргумент жоқ', other: '${count} аргумент')}";

  static String m17(token) => "${token} мән қажет";

  static String m18(token) => "${token} опция емес";

  static String m19(token) => "Белгісіз опция ${token}";

  static String m20(count) =>
      "ByeDPI движогын ${count} бағыттау санаты қолданады";

  static String m21(passed, total) => "Саты нәтижесі: ${passed}/${total}";

  static String m22(presets, groups, domains) =>
      "${presets} пресет · ${groups} топ · ${domains} хост";

  static String m23(count) =>
      "${Intl.plural(count, one: '1 домен', other: '${count} домен')}";

  static String m24(count) => "Дайын: ${count} стратегия сынаалды";

  static String m25(count) =>
      "Барлық белгілі стратегияны движок арқылы ${count} хостқа жеке сынаайды; аяқталғаннан кейін ағымдағы стратегия қалпына келеді";

  static String m26(index, total) => "Тестіленуде ${index}, барлығы ${total}";

  static String m27(passed, total) => "${total} хосттың ${passed} жауап береді";

  static String m28(label) => "${label} туралы мәліметтер";

  static String m29(days) => "${days} тәулік";

  static String m30(name) => "${name} орнатылды";

  static String m31(completed, total) =>
      "Checking connection: ${completed}/${total}";

  static String m32(layer) => "Connection issue: ${layer}";

  static String m33(station) =>
      "${station} жерінде үзіліс — одан кейінгінің бәрі жауапсыз.";

  static String m34(completed, total) => "Step ${completed} of ${total}";

  static String m35(count) => "${count} жазба";

  static String m36(layer) =>
      "${layer} деңгейінде үзіліс. Одан кейінгі деңгейлер іске қосылмады.";

  static String m37(layer, duration) =>
      "Ең баяу деңгей — ${layer}, ${duration}. Толық бағыт қалыпты шамада қалды.";

  static String m38(label) => "${label} бос болмауы керек";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 жазба', other: '${count} жазба')}";

  static String m40(label) => "${label} бұрыннан бар";

  static String m41(action) =>
      "Сыртқы сілтемеге «${action}» әрекетін орындауға рұқсат берілсін бе?";

  static String m42(date) => "${date} табылды";

  static String m43(found, total) => "${total} ішінен ${found} ашылды";

  static String m44(count) => "Тағы ${count} табылмады";

  static String m45(days) => "Келесі белгіге дейін ${days} күн";

  static String m46(name) => "${name} ең соңғы нұсқада тұр";

  static String m47(name) => "${name} жаңартылды";

  static String m48(time) => "${time} бұрын";

  static String m49(action) =>
      "«${action}» үшін қолданылып жүр. Сақтасаңыз, осында ауысады.";

  static String m50(modifiers) => "Кемінде ${modifiers} біреуін қосыңыз";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 сағат бұрын', other: '${count} сағат бұрын')}";

  static String m52(count) =>
      "${Intl.plural(count, one: '1 сағат', other: '${count} сағат')}";

  static String m53(target) => "${target} — жарамсыз саясат";

  static String m54(proxyName) => "${proxyName} — жарамсыз прокси";

  static String m55(providerName) =>
      "${providerName} — жарамсыз прокси провайдері";

  static String m56(subRule) => "${subRule} — жарамсыз SUB_RULE";

  static String m57(address) =>
      "Немесе телефон браузерінде ${address} мекенжайын ашыңыз";

  static String m58(appName) =>
      "1. Жүйелік баптауларды ашып, «Жекелік және қауіпсіздік» бөліміне өтіңіз\n2. Орналасу қызметтерін таңдаңыз\n3. Тізімнен ${appName} қолданбасын тауып, құсбелгі қойыңыз\n\nДайын болған соң қолданбаға оралыңыз. Ынтымақтастығыңыз үшін рахмет.";

  static String m59(label, max) =>
      "${label} ең көбі ${max} таңбадан аспауы керек";

  static String m60(size) => "${size} босатылды";

  static String m61(count) =>
      "${Intl.plural(count, one: '1 минут бұрын', other: '${count} минут бұрын')}";

  static String m62(count) =>
      "${Intl.plural(count, one: '1 ай бұрын', other: '${count} ай бұрын')}";

  static String m63(label) => "Әзірге ${label} жоқ";

  static String m64(label) => "${label} сан болуы керек";

  static String m65(settings) =>
      "Бұл жазылым қолданбаның мына жалпы баптауларын сұрайды:\n${settings}";

  static String m66(label) => "${label} 1024 пен 49151 аралығында болуы керек";

  static String m67(count) =>
      "Профиль импортталды; қолдау көрсетілмейтін ${count} түйін өткізіп жіберілді";

  static String m68(format, client, nodes, groups) =>
      "Импортталды: ${format} · ${client} · ${nodes} түйін · ${groups} топ";

  static String m69(days) => "${days} күн қолданылмады";

  static String m70(months) => "${months} ай қолданылмады";

  static String m71(count) =>
      "${Intl.plural(count, one: '1 прокси', other: '${count} прокси')}";

  static String m72(count) => "Профильдер: ${count}";

  static String m73(count) => "Прокси топтары: ${count}";

  static String m74(count) => "Ережелер: ${count}";

  static String m75(count) => "Сценарийлер: ${count}";

  static String m76(count) =>
      "${Intl.plural(count, one: '1 ереже', other: '${count} ереже')}";

  static String m77(darkAt, lightAt) => "Қараңғы режим: ${darkAt} — ${lightAt}";

  static String m78(count) =>
      "${Intl.plural(count, one: '1 секунд', other: '${count} секунд')}";

  static String m79(count) => "${count} таңдалды";

  static String m80(time) => "${time} тексерілді";

  static String m81(count) => "${count} профиль дайын";

  static String m82(step, count) => "${count} қадамның ${step}-қадамы";

  static String m83(name) => "Профиль: ${name}";

  static String m84(value) => "Ақылды бағыттау: ${value}";

  static String m85(rule, time) => "Сәйкестік ${rule} • ${time}";

  static String m86(alive, total) =>
      "Қазір қолжетімді серверлер: ${alive}/${total}";

  static String m87(percent, duration) => "${duration} ішінде ${percent}%";

  static String m88(band) => "жолақ ${band}";

  static String m89(bands) => "Жолақтар: ${bands}";

  static String m90(count) => "${count} сәтсіздіктен кейін салқындап тұр";

  static String m91(answered, total) => "${answered} / ${total} жауап берді";

  static String m92(seconds) => "${seconds} с қалды";

  static String m93(count) => "${count} эпизод";

  static String m94(count) => "Қатар келген ${count} сәтсіздік";

  static String m95(strategy) => "${strategy} әдепкісінен өзгертілді";

  static String m96(count) => "${count} жазба жоғалды";

  static String m97(count) => "×${count}";

  static String m98(step) => "Ұтылған жол: ${step}";

  static String m99(duration) => "${duration} ішінде өлшенді";

  static String m100(ms) => "${ms} мс";

  static String m101(minutes) => "${minutes} мин";

  static String m102(measured, total) => "өлшенді: ${measured} / ${total}";

  static String m103(value) => "${value}%";

  static String m104(preset) => "${preset} · өзгертілді";

  static String m105(left, cap) =>
      "Осы сағатта қалған өлшеулер: ${left} / ${cap}";

  static String m106(value, against) => "${value} — ${against}";

  static String m107(seconds) => "${seconds} с";

  static String m108(eligible, total) =>
      "${eligible} / ${total} қолдануға жарамды";

  static String m109(count) => "Арнайы сервер белгілері: ${count}";

  static String m110(provider) => "Провайдер: ${provider}";

  static String m111(count) => "Провайдер берген белгілер: ${count}";

  static String m112(eligible, total) => "${total} серверден ${eligible} дайын";

  static String m113(label) =>
      "«${label}» UTF-8 бойынша 64 байттан аспауы тиіс";

  static String m114(node) => "${node} арқылы";

  static String m115(eligible, total, blocked) =>
      "${total} сервердің ішінен ${eligible} өтті, ${blocked} ұсталды";

  static String m116(strategy) => "${strategy} · өзгертілген";

  static String m117(from, to) => "${from} → ${to}";

  static String m118(time) => "${time} бұрын ауыстырылды";

  static String m119(label) => "Әдепкі: ${label}";

  static String m120(count) => "${count} сервер";

  static String m121(step) => "Жоғары тұрған жол: ${step}";

  static String m122(host) => "Провайдер ${host} мекенжайына көшкен";

  static String m123(count) =>
      "${Intl.plural(count, one: 'Жазылыс мерзімі ертең аяқталады', other: 'Жазылыс мерзімі ${count} күннен кейін аяқталады')}";

  static String m124(value) => "Провайдер ${value} ұсынады";

  static String m125(percent) => "Трафиктің ${percent}% жұмсалды";

  static String m126(count) =>
      "${Intl.plural(count, zero: 'Нәтиже жоқ', one: '1 нәтиже', other: '${count} нәтиже')}";

  static String m127(total) => "${total} ішінен бос";

  static String m128(label) => "${label} URL болуы керек";

  static String m129(count) =>
      "Ең көбі ${count} фон сақтауға болады. Жаңасын қосу үшін біреуін жойыңыз.";

  static String m130(count) =>
      "${Intl.plural(count, one: '1 жыл бұрын', other: '${count} жыл бұрын')}";

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
      "Қай қолданбалар прокси арқылы жұмыс істейтінін басқару",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба қатынасын бақылау өшірілген",
    ),
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "VPN-нен шығару",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "VPN-ге қосу",
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
    "addNetwork": MessageLookupByLibrary.simpleMessage("Желі қосу"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Ауыстыру жазбасын қосу",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Профиль қосу"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Проксилер қосу"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Прокси тобын қосу"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлерін қосу",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Ереже қосу"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Виджет қосу"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Қосымша ережелер"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Қосымша параметрлер",
    ),
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
      "Әртүрлі баптау мүмкіндіктері",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Келісемін"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларға VPN-ді айналып өтуге рұқсат беру",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Қосулы кезде кейбір қолданбалар VPN-ді айналып өте алады",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN-ға рұқсат беру"),
    "allowLanAccess": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желіден қатынауға рұқсат ету",
    ),
    "allowLanAccessDesc": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллерге жергілікті желіден қатынауға рұқсат ету",
    ),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "LAN арқылы проксиге қосылуға рұқсат беру",
    ),
    "animations": MessageLookupByLibrary.simpleMessage("Анимациялар"),
    "announce": MessageLookupByLibrary.simpleMessage("Хабарландырулар"),
    "answers": MessageLookupByLibrary.simpleMessage("Жауаптар"),
    "app": MessageLookupByLibrary.simpleMessage("Қолданба"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Қолданба қатынасын бақылау",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Сызба"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Лаунчер таңбашаны бірнеше секундта қайта салады. Бекітілген таңбашалар кейбір лаунчерлерде жоғалып кетуі мүмкін.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Сұлба"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Жаңғырық"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Сия"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("Орнату"),
    "appIconPreview": MessageLookupByLibrary.simpleMessage(
      "Белгішені алдын ала қарау",
    ),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Сынықтар"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Күн"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Ұшқын"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Қабаттар"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Топография"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Із"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Барқыт"),
    "appRegion": MessageLookupByLibrary.simpleMessage("Қолданба өңірі"),
    "appRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Желі өңірін таңдаңыз. Ресей таңдалса, HWID қосылады; оны төменде өшіруге болады. Ақылды бағыттау бөлек қосылады.",
    ),
    "appRegionOther": MessageLookupByLibrary.simpleMessage("Басқа"),
    "appearance": MessageLookupByLibrary.simpleMessage("Сыртқы түр"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Фон"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Тақырып, түстер, таңбашалар және бақылау тақтасы көрінісі",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("Таңбаша"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Тақырып"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Жүйелік DNS-ті қосу",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Жүйелік DNS-ті конфигурацияға мәжбүрлеп қосады",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Қолданба"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба баптауларын реттеу",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Жергілікті прокси портына логин мен құпиясөз талап етіледі, басқа қолданбалар оны пайдалана алмайды",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Аутентификация қосулы кезде жүйелік прокси қолданылмайды",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Рұқсат беру"),
    "authorized": MessageLookupByLibrary.simpleMessage("Рұқсат етілген"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Жаңартуларды автоматты тексеру",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба іске қосылғанда жаңартулар автоматты түрде тексеріледі",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды автоматты жабу",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Түйін ауыстырғаннан кейін қосылымдар автоматты жабылады",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автоматты іске қосу"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Жүйе жүктелгенде автоматты түрде іске қосылады",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автоқосу"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба ашылғанда автоматты түрде қосылады",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Жүйелік DNS-ті автоматты орнату",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автожаңарту"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы (минут)",
    ),
    "autoUpdateOffSuggested": m0,
    "back": MessageLookupByLibrary.simpleMessage("Артқа"),
    "backup": MessageLookupByLibrary.simpleMessage("Сақтық көшірме"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірме және қалпына келтіру",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді WebDAV арқылы немесе файлмен синхрондау",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірме жасалды",
    ),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Негізгі конфигурация"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Негізгі конфигурацияны бүкіл қолданба үшін өзгерту",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Негізгі ақпарат"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage(
      "Негізгі стратегиялар",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба фондық режимде де жұмыс істеп тұруы үшін батарея оңтайландыруын өшіріңіз. Баптауларды ашу үшін түртіңіз.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Жүйелік шектеулерге байланысты қолданба істеп тұрғанда батареяны оңтайландыру күйі дұрыс оқылмайды",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Байланыстыру"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Қара тізім режимі"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Қосылымды блоктау",
    ),
    "broadNetworkWarn": MessageLookupByLibrary.simpleMessage(
      "Кең ереже — үлкен мекенжай ауқымына сенеді",
    ),
    "byedpiActive": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өтуі белсенді",
    ),
    "byedpiActiveFor": m1,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage(
      "DPI движогы тексерілуде",
    ),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage(
      "DPI движогын тексеру керек",
    ),
    "byedpiOff": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өтуі өшірулі",
    ),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өтуі кідіртілді",
    ),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage(
      "DPI движогы қайта іске қосылуда",
    ),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өтуі іске қосылуда",
    ),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өтуін жалғастыру үшін түртіңіз",
    ),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage(
      "Жергілікті айналып өту движогын іске қосу үшін түртіңіз",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass домендері"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Тек жүйелік прокси іске қосылғанда күшіне енеді",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Кэш"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш зақымдалды. Тазалансын ба?",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Камераға рұқсат өшірулі. QR-кодты сканерлеу үшін оны параметрлерде қосыңыз.",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Бас тарту"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Таңдауды алып тастау",
    ),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Прокси ауыстырылмады, алдыңғы таңдау қалпына келтірілді",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("Серверді ауыстыру"),
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
      "Сенімсіз сертификаттар қабылданбайды. Өшірілгенде жазылыстар мен сақтық көшірмелер делдал шабуылына осал болады",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Жаңартуларды тексеру"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Қолданба ең соңғы нұсқада",
    ),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("Дәстүрлі"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Іске қосу түймесі бар плитка торы",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Деректерді тазалау"),
    "clearDataBackupHint": MessageLookupByLibrary.simpleMessage(
      "Алдымен жоғарыдағы түймелермен сақтық көшірме жасаңыз — қайтарудың жалғыз жолы осы.",
    ),
    "clearDataDesc": MessageLookupByLibrary.simpleMessage(
      "Барлық профильдер, параметрлер және файлдар жойылады. Қолданба жабылады.",
    ),
    "clearDataIrreversible": MessageLookupByLibrary.simpleMessage(
      "Мұны қайтару мүмкін емес.",
    ),
    "clearDataWarning": MessageLookupByLibrary.simpleMessage(
      "ReClash мыналарды біржола жояды:\n• Барлық профильдер мен олардың файлдары\n• WebDAV байланысын қоса, барлық параметрлер\n• Скрипттер, ережелер және басқа жергілікті деректер\n• Кэштелген провайдер деректері\n\nАяқталғанда қолданба жабылады.",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Іздеуді тазарту"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage(
      "Клиентке қолдау жоқ",
    ),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "Провайдер бұл клиентті қолдамайды.",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферіне экспорттау",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферінен импорттау",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Жабу"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды жабу",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN кідіртілгенде ашық қосылымдардың бәрі үзіледі",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Түс"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Түс схемалары"),
    "columns": MessageLookupByLibrary.simpleMessage("Бағандар"),
    "companionAccessRevoked": MessageLookupByLibrary.simpleMessage(
      "Қатынау кері қайтарылды",
    ),
    "companionActiveProfile": MessageLookupByLibrary.simpleMessage("Жазылым"),
    "companionAddPhone": MessageLookupByLibrary.simpleMessage("Телефон қосу"),
    "companionAddTelevision": MessageLookupByLibrary.simpleMessage(
      "Теледидар қосу",
    ),
    "companionCommandDone": MessageLookupByLibrary.simpleMessage("Дайын"),
    "companionCommandFailed": MessageLookupByLibrary.simpleMessage(
      "Орындалмады. Қайталап көріңіз.",
    ),
    "companionConfirmCode": m2,
    "companionConfirmOnTv": MessageLookupByLibrary.simpleMessage(
      "Осы кодтың теледидардағы кодпен сәйкес келетінін тексеріп, теледидарда растаңыз.",
    ),
    "companionConfirmPhone": MessageLookupByLibrary.simpleMessage(
      "Осы телефонды растайсыз ба?",
    ),
    "companionControlPanel": MessageLookupByLibrary.simpleMessage(
      "Қашықтан басқару",
    ),
    "companionControllingHint": MessageLookupByLibrary.simpleMessage(
      "Сіз осы құрылғыны басқарып жатырсыз",
    ),
    "companionCurrentNode": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы түйін",
    ),
    "companionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Бұл теледидарда сенімді телефондардың саны шегіне жетті",
    ),
    "companionDeviceName": MessageLookupByLibrary.simpleMessage("Құрылғы аты"),
    "companionEnableReceiver": MessageLookupByLibrary.simpleMessage(
      "Телефоннан басқаруға рұқсат ету",
    ),
    "companionEnterUrl": MessageLookupByLibrary.simpleMessage("Сілтеме енгізу"),
    "companionForgetDevice": MessageLookupByLibrary.simpleMessage(
      "Осы теледидарды ұмыту",
    ),
    "companionIdentityChanged": MessageLookupByLibrary.simpleMessage(
      "Осы теледидардың сәйкестендіргіші өзгерді. Оны жойып, қайта жұптастырыңыз.",
    ),
    "companionLanHelp": MessageLookupByLibrary.simpleMessage(
      "Екі құрылғы да бір жергілікті желіде болуы керек.",
    ),
    "companionLastSeen": m3,
    "companionNeverConnected": MessageLookupByLibrary.simpleMessage(
      "Әлі қосылмаған",
    ),
    "companionNewSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "Жазылым сілтемесі",
    ),
    "companionNoLan": MessageLookupByLibrary.simpleMessage(
      "Алдымен теледидарды Wi-Fi немесе Ethernet желісіне қосыңыз",
    ),
    "companionNoMeasurement": MessageLookupByLibrary.simpleMessage("Өлшеу жоқ"),
    "companionOffline": MessageLookupByLibrary.simpleMessage("Желіде емес"),
    "companionOnline": MessageLookupByLibrary.simpleMessage("Желіде"),
    "companionOutcomeUnknown": MessageLookupByLibrary.simpleMessage(
      "Растау мүмкін болмады — күйді тексеріңіз",
    ),
    "companionPaired": MessageLookupByLibrary.simpleMessage("Жұптасты"),
    "companionPairingExpired": MessageLookupByLibrary.simpleMessage(
      "Жұптасу коды жарамсыз болды. Теледидардан жаңа кодты көрсетуін сұраңыз.",
    ),
    "companionPairingExpires": m4,
    "companionPairingRejected": MessageLookupByLibrary.simpleMessage(
      "Жұптасу қабылданбады",
    ),
    "companionProfileActive": MessageLookupByLibrary.simpleMessage("Белсенді"),
    "companionProfiles": MessageLookupByLibrary.simpleMessage("Профильдер"),
    "companionReceiverExplain": MessageLookupByLibrary.simpleMessage(
      "Қабылдау қосулы кезде осы желідегі телефондар бұл теледидарды басқара алады.",
    ),
    "companionReceiverExplainPhone": MessageLookupByLibrary.simpleMessage(
      "Қабылдау қосулы кезде осы желідегі басқа телефондар бұл телефонды басқара алады.",
    ),
    "companionReceiverRunning": m5,
    "companionReceiverStopped": MessageLookupByLibrary.simpleMessage(
      "Телефоннан басқару өшірулі",
    ),
    "companionReconnect": MessageLookupByLibrary.simpleMessage("Қайта қосылу"),
    "companionReject": MessageLookupByLibrary.simpleMessage("Қабылдамау"),
    "companionReload": MessageLookupByLibrary.simpleMessage("Жаңарту"),
    "companionRename": MessageLookupByLibrary.simpleMessage("Атын өзгерту"),
    "companionResetIdentity": MessageLookupByLibrary.simpleMessage(
      "Жұптасу сәйкестендіргішін қалпына келтіру",
    ),
    "companionResetIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Барлық жұптасқан телефондарды және теледидардың қауіпсіздік кілтін жояды.",
    ),
    "companionRestartRequired": MessageLookupByLibrary.simpleMessage(
      "Қолдану үшін қосылымды қайта іске қосыңыз",
    ),
    "companionRevokePhone": MessageLookupByLibrary.simpleMessage(
      "Осы телефонды кері қайтару",
    ),
    "companionScanTvQr": MessageLookupByLibrary.simpleMessage(
      "Теледидарда көрсетілген кодты сканерлеңіз",
    ),
    "companionScanWithPhone": MessageLookupByLibrary.simpleMessage(
      "Телефоныңызда ReClash ашып, осы кодты сканерлеңіз",
    ),
    "companionSelectNode": MessageLookupByLibrary.simpleMessage(
      "Түйінді таңдау",
    ),
    "companionSendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Осы телефоннан жіберу",
    ),
    "companionSendProfile": MessageLookupByLibrary.simpleMessage(
      "Осы телефоннан профиль жіберу",
    ),
    "companionSetSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылымды орнату",
    ),
    "companionStaleState": MessageLookupByLibrary.simpleMessage(
      "Соңғы белгілі күй көрсетілген",
    ),
    "companionStatusChecking": MessageLookupByLibrary.simpleMessage(
      "Тексерілуде…",
    ),
    "companionStatusOff": MessageLookupByLibrary.simpleMessage(
      "Қорғаныс өшірулі",
    ),
    "companionStatusOn": MessageLookupByLibrary.simpleMessage(
      "Қорғаныс қосулы",
    ),
    "companionSwitchProfile": MessageLookupByLibrary.simpleMessage(
      "Осы профильге ауысу",
    ),
    "companionTrustedPhones": MessageLookupByLibrary.simpleMessage(
      "Сенімді телефондар",
    ),
    "companionTurnOff": MessageLookupByLibrary.simpleMessage("Өшіру"),
    "companionTurnOn": MessageLookupByLibrary.simpleMessage("Қосу"),
    "companionUnreachable": MessageLookupByLibrary.simpleMessage(
      "Бұл желіде теледидарға қол жеткізу мүмкін емес",
    ),
    "companionUpdateSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылымды жаңарту",
    ),
    "companionWaitingApproval": MessageLookupByLibrary.simpleMessage(
      "Теледидарда растауды күтуде",
    ),
    "compatible": MessageLookupByLibrary.simpleMessage("Үйлесімділік режимі"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияда деректер табылды",
    ),
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
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "Растасаңыз, бар деректердің үстінен жазылады.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Жалғанған"),
    "connectedFor": m6,
    "connecting": MessageLookupByLibrary.simpleMessage("Қосылуда…"),
    "connection": MessageLookupByLibrary.simpleMessage("Қосылым"),
    "connectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Қосылым диагностикасы",
    ),
    "connectionProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "connectionType": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Қосылымдар"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы қосылымдарды көру",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Байланыс: "),
    "content": MessageLookupByLibrary.simpleMessage("Мазмұн"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Мазмұн бос болмауы тиіс",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Мазмұн"),
    "contrast": MessageLookupByLibrary.simpleMessage("Контраст"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "Таза қара фонда +0,3 контраст әдетте жақсырақ оқылады",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Глобалдық қосымша ережелерді басқару",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Көшіру"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Нұсқа ақпаратын көшіру",
    ),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Орта айнымалыларын көшіру",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Сілтемені көшіру"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Көшірілді"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreBlockedByPolicyTip": m7,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control ReClashCore.exe файлын қолтаңбасы жоқ болғандықтан блоктады. Windows қауіпсіздігі → «Қолданбалар мен браузерді бақылау» → Smart App Control баптауларына өтіп, «Өшірулі» опциясын таңдаңыз да, ReClash-ті қайта іске қосыңыз. Smart App Control-ті қайта қосу үшін Windows-ты қайта орнату керек.",
    ),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Жұмыс істеп тұр"),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Іске қосылуда…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Ядро күйі"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Тоқтатылған"),
    "country": MessageLookupByLibrary.simpleMessage("Өңір"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Құлау анықталды"),
    "crashDetectedTip": m8,
    "crashTest": MessageLookupByLibrary.simpleMessage("Құлау тесті"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Құлау аналитикасы"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "Қосулы болса, қолданба құлағанда сезімтал деректерсіз құлау журналдары автоматты түрде жүктеп жіберіледі",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Жасау"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Профиль жасау"),
    "createProfileFromUrlTip": m9,
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
    "crownHistory": m10,
    "custom": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("Қиып алу"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Қауіпті аймақ"),
    "dark": MessageLookupByLibrary.simpleMessage("Қараңғы"),
    "darkAt": MessageLookupByLibrary.simpleMessage("Қараңғы уақыты"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Бақылау тақтасы"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "VPN профилінсіз DPI-ді айналып өту үшін тек ByeDPI режимін пайдаланыңыз.",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage(
      "VPN провайдері жоқ па?",
    ),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Профильдер сақталған, бірақ ешқайсысы белсенді емес. VPN басқаруын ашу үшін біреуін таңдаңыз.",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "VPN профилін таңдаңыз",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Сенімді провайдерден VPN профилін қосыңыз. Оған дейін VPN өшірулі қалады.",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылымды баптау",
    ),
    "dashboardProviderDetails": MessageLookupByLibrary.simpleMessage(
      "Толығырақ",
    ),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage(
      "Профильді таңдау",
    ),
    "dashboardShowConnection": MessageLookupByLibrary.simpleMessage(
      "Қосылымға оралу",
    ),
    "dashboardShowProvider": MessageLookupByLibrary.simpleMessage(
      "Жазылым мәліметтерін көрсету",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage(
      "Бақылау тақтасының стилі",
    ),
    "dashboardSubscriptionAttention": MessageLookupByLibrary.simpleMessage(
      "Назар аудару қажет",
    ),
    "dashboardSubscriptionCurrent": MessageLookupByLibrary.simpleMessage(
      "Жазылым белсенді",
    ),
    "dashboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Жазылым мерзімі аяқталды",
    ),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage(
      "ByeDPI пайдалану",
    ),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Деректер өзгерген. Сақталсын ба?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "Бұл қолданба тұрақтылықты жақсарту үшін Firebase Crashlytics көмегімен құлау туралы ақпарат жинайды.\nЖиналатын деректер — құрылғы туралы ақпарат пен құлау егжей-тегжейлері; жеке сезімтал деректер болмайды.\nМұны баптаулардан өшіре аласыз.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Деректер жинау туралы хабарлама",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Өзгеріс сақталмады, кері қайтарылды",
    ),
    "day": MessageLookupByLibrary.simpleMessage("күн"),
    "days": MessageLookupByLibrary.simpleMessage("күн"),
    "daysAgo": m11,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("күн"),
    "daysLeft": m12,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Әдепкі DNS сервері",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNS серверлерін шешу үшін қолданылады",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Әдепкі"),
    "delay": MessageLookupByLibrary.simpleMessage("Кідіріс"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Кідіріс сынағы"),
    "delete": MessageLookupByLibrary.simpleMessage("Жою"),
    "deleteMultipTip": m13,
    "deleteTip": m14,
    "desc": MessageLookupByLibrary.simpleMessage(
      "mihomo ядросы мен FlClash жобасына негізделген көп платформалы клиент. Ашық код, жарнамасыз, телеметриясыз.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Нысан"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Нысан GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("Нысан IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPI айналып өту"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage(
      "Белсенді стратегия",
    ),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Движок аргументтері"),
    "desyncArgsAppOwnedFlag": m15,
    "desyncArgsCount": m16,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m17,
    "desyncArgsPositional": m18,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "Жабылмаған тырнақша",
    ),
    "desyncArgsUnknownFlag": m19,
    "desyncCache": MessageLookupByLibrary.simpleMessage("Стратегиялар кэші"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған стратегиялар желілер бойынша сақталады",
    ),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage(
      "Стратегия кэші өшірулі",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("Сақтау мерзімі"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage(
      "Әдепкі баспалдақ",
    ),
    "desyncDesc": MessageLookupByLibrary.simpleMessage(
      "ByeDPI десинхронизация стратегиялары",
    ),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("Движок"),
    "desyncEngineSummary": m20,
    "desyncFeatureEnable": MessageLookupByLibrary.simpleMessage("ByeDPI қосу"),
    "desyncFeatureEnableDesc": MessageLookupByLibrary.simpleMessage(
      "DPI айналып өту қозғалтқышын және оның бақылау тақтасындағы режимін қосады. Өшірулі кезде ByeDPI еш жерде көрсетілмейді.",
    ),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("TCP-ні мәжбүрлеу"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Жоғарыдағы санаттар үшін QUIC блокталады; десинхронизация UDP-ге жетпейді",
    ),
    "desyncLadderResult": m21,
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("Қосылу режимі"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("Бағыттау"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған GEOSITE санаттарынан тыс бүкіл трафик тікелей өтеді",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "Санат құрамы кіріктірілген GEOSITE базасынан алынады; тест домендерінің тізімдері бөлек",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "Айналып өту санаттары таңдалмаған",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "Қазір ешбір сервис ByeDPI арқылы бағытталмайды",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage(
      "Қолданыстағы ережелер",
    ),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage(
      "Ағымдағыны сақтау",
    ),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage(
      "Стратегия атауы",
    ),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "Тоқтатылды: стратегиялар движокқа жетпей қалды",
    ),
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("Тесттер жинағы"),
    "desyncTestBatterySummary": m22,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("Тест domenдері"),
    "desyncTestDomainsCount": m23,
    "desyncTestDone": m24,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "Движок осы стратегияда құлады",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "Движок істемейді — алдымен DPI айналып өтуді қосып қосылыңыз",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Бұл стратегиядан өтпеген хосттар",
    ),
    "desyncTestHint": m25,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Төменнен кемінде бір домен тізімін таңдаңыз",
    ),
    "desyncTestProgress": m26,
    "desyncTestScore": m27,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage(
      "Стратегия тесті",
    ),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("Бастау"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage(
      "Барлық пресетті өткізу",
    ),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 сағат"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 сағат"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 сағат"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 күн"),
    "details": m28,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Үшінші тарап API-іне сүйенеді; нәтиже — тек ақпарат",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("IP анықталуда…"),
    "developerAllRewards": MessageLookupByLibrary.simpleMessage(
      "Барлық марапаттарды көрсету",
    ),
    "developerFindingEvents": MessageLookupByLibrary.simpleMessage(
      "Табылғанды қайталау",
    ),
    "developerFindingQueued": MessageLookupByLibrary.simpleMessage(
      "Байланысы дұрыс бақылау тақтасы ашылғанша кезекте. Қайта көрсетуге болады.",
    ),
    "developerFindings": MessageLookupByLibrary.simpleMessage(
      "Табылғандарды алдын ала қарау",
    ),
    "developerFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "Тек уақытша алдын ала қарау: есептегіштер, алынған табылғандар мен желі баптаулары өзгермейді. Ысыру немесе әзірлеуші режимін өшіру алдын ала қарауды тоқтатады. Әсерлер байланысы дұрыс бақылау тақтасы ашылғанда көрсетіліп, безендіру баптауларына бағынады. Безендіруде таңдалған белгіше мен тақырып сақталады.",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Әзірлеуші режимі"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Әзірлеуші режимі қосылды.",
    ),
    "developerPatina": MessageLookupByLibrary.simpleMessage(
      "Профильдердегі шаң",
    ),
    "developerPatinaApply": MessageLookupByLibrary.simpleMessage(
      "Бүкіл тізімге қолдану",
    ),
    "developerPatinaApplyDesc": MessageLookupByLibrary.simpleMessage(
      "Барлық профильді осы жасқа дейін ескірту. Өшірулі болса — әрқайсысы өзінің нақты соңғы қолданылу күнінде қалады.",
    ),
    "developerPatinaDays": m29,
    "developerPatinaLab": MessageLookupByLibrary.simpleMessage(
      "Шаң зертханасы",
    ),
    "developerPatinaSample": MessageLookupByLibrary.simpleMessage(
      "Ұмытылған жазылым",
    ),
    "developerPreviewAutomatic": MessageLookupByLibrary.simpleMessage(
      "Автоматты",
    ),
    "developerPreviewReset": MessageLookupByLibrary.simpleMessage(
      "Алдын ала қарауды ысыру",
    ),
    "developerSeasonAnniversary": MessageLookupByLibrary.simpleMessage(
      "Алғашқы іске қосу мерейтойы",
    ),
    "developerSeasonBirthday": MessageLookupByLibrary.simpleMessage(
      "ReClash туған күні",
    ),
    "developerSeasonDrift": MessageLookupByLibrary.simpleMessage(
      "Маусымдық реңк",
    ),
    "developerSeasonNewYear": MessageLookupByLibrary.simpleMessage("Жаңа жыл"),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "Провайдер виджеттері, сервер ауыстыру және прокси көрінісі",
    ),
    "developerSubscriptionEmberDesc": MessageLookupByLibrary.simpleMessage(
      "Панельдің бәрі бірден: квота, виджеттер, тақырып және жергілікті фон",
    ),
    "developerSubscriptionInstalled": m30,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "Квота, жарамдылық мерзімі, хабарландыру, домен көшіру және ұсыныстар",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "Бренд түстері, жеке Hero Ring және жергілікті логотип",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Сынақ жазылымдары",
    ),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage(
      "Құрылғы лимитіне жетті",
    ),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "Провайдер құрылғылар саны шектен асқанын хабарлады. Жазылыс бәрібір жаңартылды.",
    ),
    "devices": MessageLookupByLibrary.simpleMessage("Құрылғылар"),
    "devicesDescription": MessageLookupByLibrary.simpleMessage(
      "Осы телефоннан теледидардағы ReClash-ты басқарыңыз",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Қосылым проксиі"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "NTP серверіне қосылу үшін қолданылатын прокси",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Тікелей"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP-ні өшіру"),
    "disabled": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер жойылсын ба?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Жауапкершіліктен бас тарту",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл қолданба тек оқу және зерттеу сияқты коммерциялық емес мақсаттарға арналған. Оны кез келген коммерциялық мақсатта пайдалануға қатаң тыйым салынады; кез келген коммерциялық қызметтің бұл қолданбаға қатысы жоқ.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Ажыратылған"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Жаңа нұсқа табылды",
    ),
    "discoveredFindings": MessageLookupByLibrary.simpleMessage("Ашылғандар"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-ке қатысты баптауларды реттеу",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS басып алу"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS режимі"),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS сұраулары"),
    "dnsQueriesDesc": MessageLookupByLibrary.simpleMessage(
      "Туннель арқылы шешілген DNS сұрауларын қарау",
    ),
    "doctorActionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Not available right now",
    ),
    "doctorBrokenDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor confirmed the first failing layer.",
    ),
    "doctorBrokenTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым мәселесі табылды",
    ),
    "doctorByeDpiFailedDesc": MessageLookupByLibrary.simpleMessage(
      "Жергілікті ByeDPI проксиі қолжетімсіз, сондықтан трафик ол арқылы өте алмайды.",
    ),
    "doctorByeDpiFailedTitle": MessageLookupByLibrary.simpleMessage(
      "ByeDPI іске қосылмады",
    ),
    "doctorCancelExam": MessageLookupByLibrary.simpleMessage(
      "Тексеруді тоқтату",
    ),
    "doctorCancelledDesc": MessageLookupByLibrary.simpleMessage(
      "No diagnosis was changed. You can start another check.",
    ),
    "doctorCancelledTitle": MessageLookupByLibrary.simpleMessage(
      "Check cancelled",
    ),
    "doctorCapabilities": MessageLookupByLibrary.simpleMessage(
      "Diagnostic coverage",
    ),
    "doctorCapabilityAppIngressProbe": MessageLookupByLibrary.simpleMessage(
      "App ingress probe",
    ),
    "doctorCapabilityByedpiStatus": MessageLookupByLibrary.simpleMessage(
      "ByeDPI status",
    ),
    "doctorCapabilityCancel": MessageLookupByLibrary.simpleMessage(
      "Cancellable checks",
    ),
    "doctorCapabilityDnsFlush": MessageLookupByLibrary.simpleMessage(
      "DNS cache flush",
    ),
    "doctorCapabilityExplicitExam": MessageLookupByLibrary.simpleMessage(
      "On-demand check",
    ),
    "doctorCapabilityPassiveWitness": MessageLookupByLibrary.simpleMessage(
      "Passive witness",
    ),
    "doctorCapabilityRedactedExport": MessageLookupByLibrary.simpleMessage(
      "Redacted export",
    ),
    "doctorCapabilityTunIngressProof": MessageLookupByLibrary.simpleMessage(
      "TUN ingress proof",
    ),
    "doctorCaptureActive": MessageLookupByLibrary.simpleMessage("Белсенді"),
    "doctorCaptureInactive": MessageLookupByLibrary.simpleMessage(
      "Белсенді емес",
    ),
    "doctorCaptureNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Қолданылмайды",
    ),
    "doctorConfidence": MessageLookupByLibrary.simpleMessage("Confidence"),
    "doctorConfidenceConfirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmed",
    ),
    "doctorConfidenceInsufficient": MessageLookupByLibrary.simpleMessage(
      "Insufficient",
    ),
    "doctorConfidenceProbable": MessageLookupByLibrary.simpleMessage(
      "Probable",
    ),
    "doctorDeepExam": MessageLookupByLibrary.simpleMessage("Терең тексеру"),
    "doctorDegradedDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor found a probable problem on the network path.",
    ),
    "doctorDegradedTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым сапасы төмендеді",
    ),
    "doctorDetails": MessageLookupByLibrary.simpleMessage("Диагноз"),
    "doctorDnsFailedDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба тексеру мекенжайын анықтай алмады.",
    ),
    "doctorDnsFailedTitle": MessageLookupByLibrary.simpleMessage(
      "DNS жұмыс істемейді",
    ),
    "doctorDnsStaleDesc": MessageLookupByLibrary.simpleMessage(
      "Кэштелген мекенжай ағымдағы желіге енді сәйкес келмейді.",
    ),
    "doctorDnsStaleTitle": MessageLookupByLibrary.simpleMessage(
      "DNS деректері ескірген",
    ),
    "doctorEndpointReachableDesc": MessageLookupByLibrary.simpleMessage(
      "Core тексеру мекенжайына жетті, бірақ толық қорғалған жол расталмады.",
    ),
    "doctorEndpointReachableTitle": MessageLookupByLibrary.simpleMessage(
      "Тексеру мекенжайы қолжетімді",
    ),
    "doctorEvidence": MessageLookupByLibrary.simpleMessage("Дәлелдер"),
    "doctorEvidenceConsequence": MessageLookupByLibrary.simpleMessage(
      "Consequence of an earlier fault",
    ),
    "doctorExaminingDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor is following the network path with bounded probes.",
    ),
    "doctorExaminingTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым тексерілуде",
    ),
    "doctorExportConfirm": MessageLookupByLibrary.simpleMessage(
      "The report contains diagnostic codes, timing buckets, platform details and recent redacted evidence. It never includes addresses, hostnames, profile, node or app names. Save it as JSON?",
    ),
    "doctorExportReport": MessageLookupByLibrary.simpleMessage(
      "Есепті экспорттау",
    ),
    "doctorFlushDns": MessageLookupByLibrary.simpleMessage("DNS кэшін тазалау"),
    "doctorFlushDnsUnavailable": MessageLookupByLibrary.simpleMessage(
      "DNS тазалау тек DNS деңгейіндегі ақауға қолданылады.",
    ),
    "doctorFresh": MessageLookupByLibrary.simpleMessage("Өзекті"),
    "doctorGenerationDrift": MessageLookupByLibrary.simpleMessage(
      "Network or configuration changed since this check ran; its evidence may no longer hold.",
    ),
    "doctorGenericDesc": MessageLookupByLibrary.simpleMessage(
      "Тексеру қосылым мәселесін тапты, бірақ нақты себебін анықтай алмады.",
    ),
    "doctorHealAttempts": MessageLookupByLibrary.simpleMessage(
      "Repair attempts",
    ),
    "doctorHealthyDesc": MessageLookupByLibrary.simpleMessage(
      "The observed path completed successfully.",
    ),
    "doctorHealthyEasterEgg": MessageLookupByLibrary.simpleMessage(
      "Науқас күмән туғызарлықтай сау.",
    ),
    "doctorHealthyTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым қалыпты",
    ),
    "doctorHeroExamining": m31,
    "doctorHeroIssue": m32,
    "doctorInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "The check could not prove a fault without guessing.",
    ),
    "doctorInconclusiveTitle": MessageLookupByLibrary.simpleMessage(
      "Дәлел жеткіліксіз",
    ),
    "doctorIngressDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба трафик жіберді, бірақ ол VPN немесе жергілікті прокси кірісіне жетпеді.",
    ),
    "doctorIngressTitle": MessageLookupByLibrary.simpleMessage(
      "Трафик туннельге кірмеді",
    ),
    "doctorIpUnavailable": MessageLookupByLibrary.simpleMessage(
      "Жалпы IP өлшенбеді",
    ),
    "doctorLayer": MessageLookupByLibrary.simpleMessage("Causal layer"),
    "doctorLayerCapture": MessageLookupByLibrary.simpleMessage("Capture"),
    "doctorLayerDial": MessageLookupByLibrary.simpleMessage("Connection setup"),
    "doctorLayerDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "doctorLayerIngress": MessageLookupByLibrary.simpleMessage("VPN ingress"),
    "doctorLayerMarker": MessageLookupByLibrary.simpleMessage(
      "Application response",
    ),
    "doctorLayerRoute": MessageLookupByLibrary.simpleMessage("Routing"),
    "doctorLayerTransport": MessageLookupByLibrary.simpleMessage("Transport"),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("Deep"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage(
      "No usable evidence yet",
    ),
    "doctorNoHealAttempts": MessageLookupByLibrary.simpleMessage(
      "No repair attempts yet",
    ),
    "doctorNoIncidents": MessageLookupByLibrary.simpleMessage(
      "No completed checks yet",
    ),
    "doctorNoNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғы Wi-Fi немесе мобильді желіге қосылмаған.",
    ),
    "doctorNoNetworkTitle": MessageLookupByLibrary.simpleMessage(
      "Интернетке қосылым жоқ",
    ),
    "doctorNoNodeDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл қосылым үшін белсенді прокси сервер жоқ.",
    ),
    "doctorNoNodeTitle": MessageLookupByLibrary.simpleMessage(
      "Прокси сервер таңдалмаған",
    ),
    "doctorNodeDownDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған прокси сервер қосылымды қабылдамады немесе жауап бермеді.",
    ),
    "doctorNodeDownTitle": MessageLookupByLibrary.simpleMessage(
      "Прокси сервер қолжетімсіз",
    ),
    "doctorNodeRefusedDesc": MessageLookupByLibrary.simpleMessage(
      "Прокси қосылды, бірақ тексеру мекенжайы күтілген жауапты қайтармады.",
    ),
    "doctorNodeRefusedTitle": MessageLookupByLibrary.simpleMessage(
      "Тексеру мекенжайы сұрауды қабылдамады",
    ),
    "doctorObservingDesc": MessageLookupByLibrary.simpleMessage(
      "No active probes are running. Evidence appears as the app is used.",
    ),
    "doctorObservingTitle": MessageLookupByLibrary.simpleMessage(
      "Нақты трафик бақылануда",
    ),
    "doctorOutcomeDropped": MessageLookupByLibrary.simpleMessage("Dropped"),
    "doctorOutcomeFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "doctorOutcomeNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Not applicable",
    ),
    "doctorOutcomeSeen": MessageLookupByLibrary.simpleMessage("Observed"),
    "doctorOutcomeSucceeded": MessageLookupByLibrary.simpleMessage("Succeeded"),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("Қолданба"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("Тексерілуде"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы мәселеден кейін тексерілмеді",
    ),
    "doctorPathDescAppFail": MessageLookupByLibrary.simpleMessage(
      "сұраулар құрылғыдан шықпай жатыр",
    ),
    "doctorPathDescAppOk": MessageLookupByLibrary.simpleMessage(
      "сұраулар құрылғыдан шығады",
    ),
    "doctorPathDescConsequence": MessageLookupByLibrary.simpleMessage(
      "өткізілді — ақау жоғарыда",
    ),
    "doctorPathDescIngressFail": MessageLookupByLibrary.simpleMessage(
      "трафикті түсіру өшірулі",
    ),
    "doctorPathDescIngressOk": MessageLookupByLibrary.simpleMessage(
      "трафик түсіріліп, қорғалған",
    ),
    "doctorPathDescInternetFail": MessageLookupByLibrary.simpleMessage(
      "түйін жауап бермей жатыр",
    ),
    "doctorPathDescInternetOk": MessageLookupByLibrary.simpleMessage(
      "шетелдегі түйін жауап береді",
    ),
    "doctorPathDescResponseFail": MessageLookupByLibrary.simpleMessage(
      "жауап қайтып келмеді",
    ),
    "doctorPathDescResponseOk": MessageLookupByLibrary.simpleMessage(
      "деректер бүтін қайтып келді",
    ),
    "doctorPathDescRouteFail": MessageLookupByLibrary.simpleMessage(
      "бағыт ешбір түйінге жетпеді",
    ),
    "doctorPathDescRouteOk": MessageLookupByLibrary.simpleMessage(
      "ережелер түйінді таңдады",
    ),
    "doctorPathFailed": MessageLookupByLibrary.simpleMessage("Мәселе осында"),
    "doctorPathIngress": MessageLookupByLibrary.simpleMessage(
      "VPN / жергілікті кіріс",
    ),
    "doctorPathIngressByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "doctorPathIngressDirect": MessageLookupByLibrary.simpleMessage("Тікелей"),
    "doctorPathIngressLocalProxy": MessageLookupByLibrary.simpleMessage(
      "Жергілікті прокси",
    ),
    "doctorPathIngressTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "doctorPathIngressVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "doctorPathInternet": MessageLookupByLibrary.simpleMessage(
      "Прокси / Интернет",
    ),
    "doctorPathNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Қажет емес",
    ),
    "doctorPathPassed": MessageLookupByLibrary.simpleMessage("Жұмыс істейді"),
    "doctorPathResponse": MessageLookupByLibrary.simpleMessage("Жауап"),
    "doctorPathRoute": MessageLookupByLibrary.simpleMessage("DNS / маршрут"),
    "doctorPathSummaryBreak": m33,
    "doctorPathSummaryExamining": MessageLookupByLibrary.simpleMessage(
      "Әр кезеңді бірінен соң бірін тексеру.",
    ),
    "doctorPathSummaryHealthy": MessageLookupByLibrary.simpleMessage(
      "Трафик бағыттағы әр кезеңнен өтеді.",
    ),
    "doctorPathSummaryIdle": MessageLookupByLibrary.simpleMessage(
      "Бағытты қадағалау үшін тексеруді іске қосыңыз.",
    ),
    "doctorPathSummaryStale": MessageLookupByLibrary.simpleMessage(
      "Бұл соңғы нәтиже — тірі бағытты қадағалау үшін жаңа тексеру бастаңыз.",
    ),
    "doctorPathSummaryUnsupported": MessageLookupByLibrary.simpleMessage(
      "Бұл нұсқада бағытты қадағалау қолжетімсіз.",
    ),
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("Қосылым жолы"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("Тексерілмеді"),
    "doctorPortalDesc": MessageLookupByLibrary.simpleMessage(
      "Желіге кірмейінше, интернетке кіру бұғатталады.",
    ),
    "doctorPortalTitle": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желісіне кіру қажет",
    ),
    "doctorProgress": m34,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("Қорғаныс"),
    "doctorRawEvidence": MessageLookupByLibrary.simpleMessage("Шикі дәлелдер"),
    "doctorRawEvidenceCount": m35,
    "doctorRecentChecks": MessageLookupByLibrary.simpleMessage(
      "Соңғы тексерулер",
    ),
    "doctorRefresh": MessageLookupByLibrary.simpleMessage("Диагнозды жаңарту"),
    "doctorRemedyOpenDns": MessageLookupByLibrary.simpleMessage(
      "DNS баптаулары",
    ),
    "doctorRemedyStartVpn": MessageLookupByLibrary.simpleMessage(
      "VPN-ді іске қосу",
    ),
    "doctorRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы профиль бұл қосылым үшін жұмыс істейтін бағытты таңдай алмады.",
    ),
    "doctorRouteTitle": MessageLookupByLibrary.simpleMessage(
      "Трафик қате бағытталды",
    ),
    "doctorRun": MessageLookupByLibrary.simpleMessage("Run a check"),
    "doctorScope": MessageLookupByLibrary.simpleMessage("Evidence scope"),
    "doctorScopeApp": MessageLookupByLibrary.simpleMessage("This app"),
    "doctorScopeInbound": MessageLookupByLibrary.simpleMessage("Local inbound"),
    "doctorSlowDesc": MessageLookupByLibrary.simpleMessage(
      "Тексеру берілген уақытта аяқталмады.",
    ),
    "doctorSlowTitle": MessageLookupByLibrary.simpleMessage("Қосылым тым баяу"),
    "doctorStale": MessageLookupByLibrary.simpleMessage("Ескірген"),
    "doctorStaleHint": MessageLookupByLibrary.simpleMessage(
      "The environment may have changed. Refresh or run a new check before acting on this result.",
    ),
    "doctorStaleTitle": MessageLookupByLibrary.simpleMessage("Нәтиже ескірген"),
    "doctorStandardExam": MessageLookupByLibrary.simpleMessage(
      "Тексеруді бастау",
    ),
    "doctorStepChangeDns": MessageLookupByLibrary.simpleMessage(
      "Профиль баптауларында басқа DNS серверін қолданып көріңіз.",
    ),
    "doctorStepCheckRules": MessageLookupByLibrary.simpleMessage(
      "Профиль ережелері мен бағыттау режимін тексеріңіз.",
    ),
    "doctorStepCheckWifi": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi немесе мобильді желіге қосылып, қайта тексеріңіз.",
    ),
    "doctorStepDeepCheck": MessageLookupByLibrary.simpleMessage(
      "DNS жолдарын салыстыру үшін терең тексеруді іске қосыңыз.",
    ),
    "doctorStepFlushDns": MessageLookupByLibrary.simpleMessage(
      "DNS кэшін тазалап, қайта тексеріңіз.",
    ),
    "doctorStepPickNode": MessageLookupByLibrary.simpleMessage(
      "Басқа прокси серверді таңдаңыз.",
    ),
    "doctorStepRecheckLater": MessageLookupByLibrary.simpleMessage(
      "Кейінірек немесе басқа желіде қайта тексеріңіз.",
    ),
    "doctorStepRestartByeDpi": MessageLookupByLibrary.simpleMessage(
      "ByeDPI-ді кеңейтілген баптауларда қайта іске қосыңыз.",
    ),
    "doctorStepRestartTunnel": MessageLookupByLibrary.simpleMessage(
      "Қосылымды қайта іске қосып, қайта тексеріңіз.",
    ),
    "doctorStepSignInPortal": MessageLookupByLibrary.simpleMessage(
      "Желіге кіру бетін ашып, қайта тексеріңіз.",
    ),
    "doctorStepStartVpn": MessageLookupByLibrary.simpleMessage(
      "VPN-ді іске қосып, қайта тексеріңіз.",
    ),
    "doctorStepSwitchNetwork": MessageLookupByLibrary.simpleMessage(
      "Басқа желіге ауысыңыз немесе интернетті қалпына келтіріңіз.",
    ),
    "doctorStepUpdateSubscription": MessageLookupByLibrary.simpleMessage(
      "Басқа серверлер де істемесе, жазылымды жаңартыңыз.",
    ),
    "doctorStepUseAppThenRecheck": MessageLookupByLibrary.simpleMessage(
      "Мәселе бар қолданбаны пайдаланып, қайтып келіп қайта тексеріңіз.",
    ),
    "doctorStormTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылымның барлық кезеңі қолжетімсіз",
    ),
    "doctorStormVerdict": MessageLookupByLibrary.simpleMessage(
      "Тексеру жұмыс істейтін жолды таппады. Кейінгі ақаулар алғашқы ақаудың салдары болуы мүмкін.",
    ),
    "doctorSupersededDesc": MessageLookupByLibrary.simpleMessage(
      "The check stopped because the network or configuration changed.",
    ),
    "doctorSupersededTitle": MessageLookupByLibrary.simpleMessage(
      "Environment changed",
    ),
    "doctorTechnicalDetails": MessageLookupByLibrary.simpleMessage(
      "Техникалық мәліметтер",
    ),
    "doctorUnsupportedDesc": MessageLookupByLibrary.simpleMessage(
      "This Core version does not support connection diagnosis.",
    ),
    "doctorUnsupportedTitle": MessageLookupByLibrary.simpleMessage(
      "Диагностика қолжетімсіз",
    ),
    "doctorUnvalidatedDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғы желіге қосылған, бірақ Android ол арқылы интернетке шыға алмайды.",
    ),
    "doctorUnvalidatedTitle": MessageLookupByLibrary.simpleMessage(
      "Желіде интернетке қолжетімділік жоқ",
    ),
    "doctorVpnInactiveDesc": MessageLookupByLibrary.simpleMessage(
      "VPN қорғанысы күтілді, бірақ TUN жолы белсенді емес.",
    ),
    "doctorVpnInactiveTitle": MessageLookupByLibrary.simpleMessage(
      "VPN белсенді емес",
    ),
    "doctorWaterfall": MessageLookupByLibrary.simpleMessage(
      "Latency waterfall",
    ),
    "doctorWaterfallDesc": MessageLookupByLibrary.simpleMessage(
      "Each bar is a probe on the connection path, placed by when it started and how long it took.",
    ),
    "doctorWaterfallHintBreak": m36,
    "doctorWaterfallHintClear": MessageLookupByLibrary.simpleMessage(
      "Тексерілген әр деңгей жауап берді.",
    ),
    "doctorWaterfallHintSlow": m37,
    "doctorWhatToTry": MessageLookupByLibrary.simpleMessage(
      "Не істеуге болады",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "download": MessageLookupByLibrary.simpleMessage("Жүктеу"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Жаңарту жүктелуде…",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Өңдеу"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Глобалдық ережелерді өңдеу",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Желіні өңдеу"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Проксиді өңдеу"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Прокси тобын өңдеу",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Ережені өңдеу"),
    "emptyTip": m38,
    "en": MessageLookupByLibrary.simpleMessage("Ағылшынша"),
    "enableExternalController": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллерді қосу",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Қосулы"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Қолмен енгізу"),
    "entries": MessageLookupByLibrary.simpleMessage(" жазба"),
    "entriesCount": m39,
    "error": MessageLookupByLibrary.simpleMessage("Қате"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Соңғы қолданбалардан жасыру",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба фонда жүргенде оны соңғы қолданбалардан жасыру",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Проксилерді алып тастау сүзгісі",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Алып тастау түрі"),
    "existsTip": m40,
    "exit": MessageLookupByLibrary.simpleMessage("Шығу"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Толық экраннан шығу",
    ),
    "expand": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Күтілетін күй"),
    "experimentalEnable": MessageLookupByLibrary.simpleMessage("Бәрібір қосу"),
    "experimentalLabel": MessageLookupByLibrary.simpleMessage("Тәжірибелік"),
    "experimentalNoticeTitle": MessageLookupByLibrary.simpleMessage(
      "Тәжірибелік мүмкіндік",
    ),
    "expireTime": MessageLookupByLibrary.simpleMessage("Жарамдылық мерзімі"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Файлды экспорттау"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "Журналдарды экспорттау",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Экспорт сәтті аяқталды",
    ),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивті"),
    "externalActionConfirmMessage": m41,
    "externalActionConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Сыртқы әрекетті растау",
    ),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Сыртқы контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Қосулы кезде Clash ядросын 9090 порты арқылы басқаруға болады",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("Сырттан алу"),
    "externalLink": MessageLookupByLibrary.simpleMessage("Сыртқы сілтеме"),
    "extra": MessageLookupByLibrary.simpleMessage("Қосымша"),
    "fade": MessageLookupByLibrary.simpleMessage("Еру"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP сүзгісі"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP ауқымы"),
    "fallback": MessageLookupByLibrary.simpleMessage("Қосалқы"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("Әдетте шетелдік DNS"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Қосалқы сүзгісі"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Дәлдік"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль файлын тікелей жүктеп салу",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл өзгертілді. Өзгерістер сақталсын ба?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Сүзгі"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Процесті табу"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Қосқанда өнімділік сәл төмендеуі мүмкін",
    ),
    "findingAuscultation": MessageLookupByLibrary.simpleMessage("Тыңдау"),
    "findingCrown": MessageLookupByLibrary.simpleMessage("Тәж"),
    "findingDiscoveredOn": m42,
    "findingFullLadder": MessageLookupByLibrary.simpleMessage("Толық саты"),
    "findingMarks": MessageLookupByLibrary.simpleMessage("Белгілер"),
    "findingMarksDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash белгілер жинағы ашылды.",
    ),
    "findingMeridian": MessageLookupByLibrary.simpleMessage("Бес меридиан"),
    "findingOdometer": MessageLookupByLibrary.simpleMessage("Одометр"),
    "findingOscilloscope": MessageLookupByLibrary.simpleMessage("Осциллограф"),
    "findingOscilloscopeDesc": MessageLookupByLibrary.simpleMessage(
      "Сақина алты секунд бойы нақты трафикті тыңдады.",
    ),
    "findingPi": MessageLookupByLibrary.simpleMessage("Пи"),
    "findingPiDesc": MessageLookupByLibrary.simpleMessage(
      "Бақылау тақтасы ашық кезде сеанс 3:14:15 межесінен өтті.",
    ),
    "findingPorcelain": MessageLookupByLibrary.simpleMessage("Фарфор"),
    "findingSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "Үнсіз автопилот",
    ),
    "findingSingularity": MessageLookupByLibrary.simpleMessage("Сингулярлық"),
    "findingSingularityDesc": MessageLookupByLibrary.simpleMessage(
      "Сақина бір нүктеге сығылғанша ұсталып, қайта жарылды.",
    ),
    "findingTurn": MessageLookupByLibrary.simpleMessage("Айналым"),
    "findingTurnDesc": MessageLookupByLibrary.simpleMessage(
      "Сеанс Жаңа жыл түн ортасынан өтті.",
    ),
    "findingVigil": MessageLookupByLibrary.simpleMessage("Күзет"),
    "findings": MessageLookupByLibrary.simpleMessage("Табылғандар"),
    "findingsCount": m43,
    "findingsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданылғанда тыныш ашылған бөлшектер",
    ),
    "findingsLocked": m44,
    "findingsMoments": MessageLookupByLibrary.simpleMessage("Сәттер"),
    "findingsNextMilestone": m45,
    "findingsRelics": MessageLookupByLibrary.simpleMessage("Жәдігерлер"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Профиль бойынша"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Жүйе бойынша"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Қаріп отбасы"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Ядро мәжбүрлеп қайта іске қосылсын ба?",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Жеміс салаты"),
    "general": MessageLookupByLibrary.simpleMessage("Жалпы"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Автожаңарту"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Автожаңарту аралығы 0-ден үлкен болуы керек",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo баптаулары"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo ресурстары"),
    "geoSkipped": m46,
    "geoUpdated": m47,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo: жад үнемдеу"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Geo деректерін жадты үнемдейтін режимде жүктеу",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP коды"),
    "global": MessageLookupByLibrary.simpleMessage("Глобалды"),
    "go": MessageLookupByLibrary.simpleMessage("Өту"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Жүктеу"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Скриптті баптауға өту",
    ),
    "goroutineInfo": MessageLookupByLibrary.simpleMessage("Горутиндер"),
    "gratitude": MessageLookupByLibrary.simpleMessage("Алғыс"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash олардың еңбегі арқасында өмір сүреді",
    ),
    "happImportAsClient": MessageLookupByLibrary.simpleMessage(
      "Қалыпты импорт",
    ),
    "happImportAsClientDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash жазылымды өз атынан сұрайды және пішімді автоматты түрде анықтайды.",
    ),
    "happImportAsHapp": MessageLookupByLibrary.simpleMessage(
      "Happ үйлесімділік режимі",
    ),
    "happImportAsHappDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash өзін Happ қосымшасы ретінде таныстырып, оның пішімін оқиды. Провайдер түйіндерді Happ-қа бейімдеп бергенде қажет.",
    ),
    "happImportChoiceTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылымды импорттау",
    ),
    "happImportPrompt": MessageLookupByLibrary.simpleMessage(
      "Бұл сілтеме Happ арқылы ашылды. Жазылымды Happ үйлесімділік режимінде сұрау керек пе, әлде ReClash-тың қалыпты тәсілімен бе?",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер кэшке сақталсын ба?",
    ),
    "helperAgentUnavailable": MessageLookupByLibrary.simpleMessage(
      "Жүйенің авторизация агенті қолжетімсіз. Жұмыс үстелі сеансында polkit аутентификация агентін іске қосып, қайталап көріңіз.",
    ),
    "helperAuthorizationContinue": MessageLookupByLibrary.simpleMessage(
      "Жалғастыру",
    ),
    "helperAuthorizationLater": MessageLookupByLibrary.simpleMessage(
      "Кейінірек",
    ),
    "helperAuthorizationMessage": MessageLookupByLibrary.simpleMessage(
      "TUN режимі үшін ReClash көмекші қызметін орнату немесе жаңарту қажет. Жүйенің авторизация терезесін ашу үшін «Жалғастыру» түймесін басыңыз. Құпиясөзді тек сол терезеде енгізіңіз: ReClash құпиясөздерді жинамайды.",
    ),
    "helperAuthorizationTitle": MessageLookupByLibrary.simpleMessage(
      "Көмекші қызметті баптауға рұқсат бересіз бе?",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Көмекші қызмет қолжетімсіз; TUN режимін қосу мүмкін емес. Қалпына келтіру үшін ReClash-ті қайта орнатыңыз.",
    ),
    "helperInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Көмекші қызметті орнату немесе жаңарту мүмкін болмады. Журналдарды тексеріп, қайталап көріңіз.",
    ),
    "helperInstallNotReady": MessageLookupByLibrary.simpleMessage(
      "Көмекші қызметті баптау аяқталды, бірақ қызмет әлі дайын емес. Журналдарды тексеріп, қайталап көріңіз.",
    ),
    "helperPkexecUnavailable": MessageLookupByLibrary.simpleMessage(
      "pkexec қолжетімсіз. Дистрибутивіңізге арналған polkit бумасын орнатып, қайталап көріңіз.",
    ),
    "helperSystemdUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN режиміне systemd қажет, бірақ бұл жүйеде ол қолжетімсіз.",
    ),
    "heroBlockedHint": MessageLookupByLibrary.simpleMessage(
      "Басқа VPN трафикті ұстап тұр — қайталау үшін түртіңіз",
    ),
    "heroBlockedTitle": MessageLookupByLibrary.simpleMessage(
      "Туннель бұғатталды",
    ),
    "heroChecking": MessageLookupByLibrary.simpleMessage("Желі тексерілуде…"),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage(
      "Таңдалған сервер өлшенуде",
    ),
    "heroConfigInvalidHint": MessageLookupByLibrary.simpleMessage(
      "Провайдердің қолдау қызметіне хабарласыңыз",
    ),
    "heroConfigInvalidTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылым жарамсыз",
    ),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("Қосылуда…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("жаңа ғана"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage(
      "Қосылым жұмыс істемейді",
    ),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage(
      "Сервер жауап бермейді",
    ),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage(
      "Трафик кідірілген, қорғаныс күтуде",
    ),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage(
      "Сервер баяу жауап береді",
    ),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage(
      "Байланыс күтіледі",
    ),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("Қорғалмаған"),
    "heroPaused": MessageLookupByLibrary.simpleMessage(
      "Кідірілді — сенімді желі",
    ),
    "heroProtected": MessageLookupByLibrary.simpleMessage("Сіз қорғалғансыз"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage("Қайта қосылуда…"),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage(
      "Туннель қалпына келтірілуде",
    ),
    "heroRoutingAgo": m48,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау өшірулі",
    ),
    "heroStatusEasterEgg": MessageLookupByLibrary.simpleMessage(
      "Бүгін пакеттер ерекше тілалғыш.",
    ),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage(
      "Қорғанысты қосу үшін түртіңіз",
    ),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage(
      "Қорғанысты жалғастыру үшін түртіңіз",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Тізімнен жасыру"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP жасыру"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді жасыру"),
    "highPriorityAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Жоғары басымдықпен автоқосу",
    ),
    "highPriorityAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Ертерек іске қосу үшін Windows жоспарлағыш тапсырмасын пайдалану",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Хост жазбаларын қосу"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Барлығын тазалау"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Барлық перне тіркесімдерін жою керек пе?",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Пернелер тіркесімі қақтығысы",
    ),
    "hotkeyConflictWith": m49,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Жаһандық жылдам пернелер терезе жасырылған кезде де жұмыс істейді. Перне тіркесімін жазу үшін әрекетті түртіңіз.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Перне тіркесімдерін басқару",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаны пернетақтамен басқару",
    ),
    "hotkeyNeedsModifier": m50,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Орнатылмаған"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Әдепкіні қалпына келтіру",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Барлық тіркесімдерді әдепкімен ауыстыру керек пе?",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Тіркелмеді, оны басқа қолданба алып қойған болуы мүмкін",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("сағат"),
    "hours": MessageLookupByLibrary.simpleMessage("сағат"),
    "hoursAgo": m51,
    "hoursCount": m52,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("сағат"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("сағат"),
    "icon": MessageLookupByLibrary.simpleMessage("Таңбаша"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Белгіше жазбалары"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Таңбаша стилі"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Белгіше URL-і"),
    "identity": MessageLookupByLibrary.simpleMessage("Идентификация"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Батарея оңтайландыруын елемеу",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорттау"),
    "importFile": MessageLookupByLibrary.simpleMessage("Файлдан импорттау"),
    "importFromURL": MessageLookupByLibrary.simpleMessage(
      "URL арқылы импорттау",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL-ден импорттау"),
    "inbound": MessageLookupByLibrary.simpleMessage("Кіріс"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Барлық проксилерді қосу",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Прокси топтарынан тыс барлық проксилерді импорттайды; төменде қосымша прокси топтарын қосуға болады",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Барлық прокси провайдерлерін қосу",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "Қосылғанда импортталған прокси провайдерлері алмастырылады",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "Мерзімі ешқашан бітпейді",
    ),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "initiator": MessageLookupByLibrary.simpleMessage("Бастамашы"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Жарамды перне тіркесімін енгізіңіз",
    ),
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
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Ақылды таңдау",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Интерфейс атауы"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Шығыс қосылымдары үшін қолданылатын желілік интерфейс",
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
    "invalidPolicy": m53,
    "invalidProxy": m54,
    "invalidProxyProvider": m55,
    "invalidSubRule": m56,
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
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Қосулы кезде IPv6 трафигін қабылдауға болады",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Кіріс IPv6 трафигіне рұқсат беру",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Жапонша"),
    "justNow": MessageLookupByLibrary.simpleMessage("Дәл қазір"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP тірі ұстау аралығы",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Кілт"),
    "kk": MessageLookupByLibrary.simpleMessage("Қазақша"),
    "ko": MessageLookupByLibrary.simpleMessage("Корейше"),
    "lanProfileImport": MessageLookupByLibrary.simpleMessage("Телефоннан алу"),
    "lanProfileImportAddress": m57,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желі арқылы телефоннан жазылым жіберуге арналған бір реттік бетті көрсету",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Жазылымды импорттау мүмкін болмады",
    ),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage(
      "Жазылым алынды",
    ),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "Жазылым импортталуда…",
    ),
    "lanProfileImportPhoneFailed": MessageLookupByLibrary.simpleMessage(
      "Жазылымды импорттау мүмкін болмады. Сілтемені тексеріп, қайталап көріңіз.",
    ),
    "lanProfileImportPhoneHint": MessageLookupByLibrary.simpleMessage(
      "Жазылымды теледидарға импорттау үшін оның сілтемесін қойыңыз.",
    ),
    "lanProfileImportPhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Жазылым импортталды. Теледидарға оралып, осы бетті жабуға болады.",
    ),
    "lanProfileImportPhoneUnreachable": MessageLookupByLibrary.simpleMessage(
      "Теледидармен байланыс жоқ. Қосылымды тексеріп, нәтижені білу үшін осы бетте сұрауды қайталаңыз.",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "Осы QR кодын сол желідегі телефонмен сканерлеп, жазылым URL мекенжайын қойыңыз",
    ),
    "lanProfileImportSend": MessageLookupByLibrary.simpleMessage(
      "Теледидарға импорттау",
    ),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желі арқылы жіберуді іске қосу мүмкін болмады",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "Бір реттік сілтеменің мерзімі аяқталды",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылымды алу",
    ),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage(
      "Жазылым күтілуде…",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Тіл"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Соңғы жаңарту"),
    "lastUsed": MessageLookupByLibrary.simpleMessage("Соңғы қолданылған уақыт"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Іске қосу аяқталмады",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "Соңғы рет қолданба іске қоса бастағанда күтпеген жағдайда жабылып қалды, сондықтан автоматты баптау жасалмады. Оны қолмен бастап, қайталап көре аласыз.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Орналасу"),
    "level": MessageLookupByLibrary.simpleMessage("Деңгей"),
    "license": MessageLookupByLibrary.simpleMessage("Лицензия"),
    "licenses": MessageLookupByLibrary.simpleMessage("Лицензиялар"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаға кіретін дестелер",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Ашық"),
    "lightAt": MessageLookupByLibrary.simpleMessage("Ашық уақыты"),
    "list": MessageLookupByLibrary.simpleMessage("Тізім"),
    "listen": MessageLookupByLibrary.simpleMessage("Тыңдау"),
    "listeningPort": MessageLookupByLibrary.simpleMessage("Тыңдау порты"),
    "loading": MessageLookupByLibrary.simpleMessage("Жүктеліп жатыр…"),
    "local": MessageLookupByLibrary.simpleMessage("Жергілікті"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді құрылғыда көшіріп сақтау",
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
    "locationPermissionGuide": m58,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Орналасу рұқсаты қажет",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Журнал"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Журнал деңгейі"),
    "logcat": MessageLookupByLibrary.simpleMessage("Журнал жинау"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Өшірілгенде журнал бөлімі жасырылады",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Журналдар"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Журналдар және диагностика",
    ),
    "logsDesc": MessageLookupByLibrary.simpleMessage(
      "Жиналған журнал жазбалары",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Журнал тесті"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Loopback бұғатын ашу құралы",
    ),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "UWP қолданбаларының loopback шектеуін алып тастайды",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Кең"),
    "madeBy": MessageLookupByLibrary.simpleMessage("Жасаған"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP-ді сәйкестендіру",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET нысанына бағытталған ережелердің қайда жіберілетінін анықтайды. Әдепкіде осы профильдегі соңғы MATCH ережесінің нысаны қолданылады.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("MATCH нысаны"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. сәтсіздік саны",
    ),
    "maxLengthTip": m59,
    "maximize": MessageLookupByLibrary.simpleMessage("Үлкейту"),
    "memory": MessageLookupByLibrary.simpleMessage("Memory"),
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
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Жад босатылды"),
    "memoryReleasedSize": m60,
    "messageTest": MessageLookupByLibrary.simpleMessage("Хабарлама тесті"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Бұл — хабарлама."),
    "metaInfo": MessageLookupByLibrary.simpleMessage("Жазылыс"),
    "milestoneDecorations": MessageLookupByLibrary.simpleMessage(
      "Жасырын олжалар",
    ),
    "milestoneDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash пайдалану кезінде табылған олжаларды көрсету",
    ),
    "milestoneRevealAuscultation": MessageLookupByLibrary.simpleMessage(
      "Жүз тексеріс. Желінің тамыры соғып тұр.",
    ),
    "milestoneRevealCrown": MessageLookupByLibrary.simpleMessage(
      "Қамтылған уақыттың бір жылы.",
    ),
    "milestoneRevealFullLadder": MessageLookupByLibrary.simpleMessage(
      "Барлық сатыдан өтіп, біріншісіне қайту.",
    ),
    "milestoneRevealMeridian": MessageLookupByLibrary.simpleMessage(
      "Бес меридиан кесіп өтілді.",
    ),
    "milestoneRevealOdometer": MessageLookupByLibrary.simpleMessage(
      "Бір терабайт өтіп кетті.",
    ),
    "milestoneRevealPorcelain": MessageLookupByLibrary.simpleMessage(
      "Жеті тыныш күн.",
    ),
    "milestoneRevealSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "Араласусыз мың шешім.",
    ),
    "milestoneRevealVigil": MessageLookupByLibrary.simpleMessage(
      "Үзіліссіз тоқсан күн.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Минималды"),
    "minimize": MessageLookupByLibrary.simpleMessage("Кішірейту"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Шығу кезінде кішірейту",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Жүйенің әдепкі шығу әрекетін ауыстырады",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesAgo": m61,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("минут"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Аралас порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m62,
    "more": MessageLookupByLibrary.simpleMessage("Тағы"),
    "moveDown": MessageLookupByLibrary.simpleMessage("Төмен жылжыту"),
    "moveToBottom": MessageLookupByLibrary.simpleMessage("Соңына жылжыту"),
    "moveToTop": MessageLookupByLibrary.simpleMessage("Басына жылжыту"),
    "moveUp": MessageLookupByLibrary.simpleMessage("Жоғары жылжыту"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "Бірнеше мәнді үтірмен ажыратыңыз",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Атауы"),
    "nameserver": MessageLookupByLibrary.simpleMessage("DNS сервері"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Домен атауларын шешу үшін қолданылады",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "DNS серверлерінің саясаты",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Сәйкес домендер үшін DNS серверлерінің саясатын көрсетіңіз",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Желі"),
    "networkDefaultLanBypass": MessageLookupByLibrary.simpleMessage(
      "Арнайы маршруттар болмаса, жергілікті желі VPN-ді айналып өтеді. Оны қамту үшін маршруттарды нақты көрсетіңіз.",
    ),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Желіге қатысты баптауларды реттеу",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Желіні тексеру"),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Үй Wi-Fi) немесе желі ауқымы (192.168.1.0/24)",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Желі қатесі. Байланысты тексеріп, қайталап көріңіз.",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Желі жылдамдығы"),
    "networkType": MessageLookupByLibrary.simpleMessage("Желі түрі"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage(
      "Әзірге сенімді желілер жоқ",
    ),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Бейтарап"),
    "neverUsed": MessageLookupByLibrary.simpleMessage("Әлі қолданылмаған"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("Жаңа көрініс"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Астында трафик көрсетілген қосылым сақинасы",
    ),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("Жаңа"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Келесі сәйкестік"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage(
      "Хабарландырулар жоқ",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("Деректер жоқ"),
    "noFilterCondition": MessageLookupByLibrary.simpleMessage(
      "Сүзгі шарттары жоқ",
    ),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Перне тіркесімі әлі жоқ"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Ақпарат жоқ"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("Енді еске салмау"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Желі жоқ"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Желісіз қолданбалар"),
    "noRecords": MessageLookupByLibrary.simpleMessage("Жазбалар жоқ"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP-ті анықтамау"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Хост атауын шешпеу",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Сәйкес нәтиже табылмады",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Жоқ"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы прокси тобын таңдау мүмкін емес",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі сенімді емес",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Хабарлама"),
    "notificationActionButtons": MessageLookupByLibrary.simpleMessage(
      "Әрекет түймелері",
    ),
    "notificationActionButtonsDesc": MessageLookupByLibrary.simpleMessage(
      "Хабарландыруда кідірту және тоқтату түймелерін көрсету",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Компонент қосу",
    ),
    "notificationAndroidOnly": MessageLookupByLibrary.simpleMessage(
      "Android жүйесінде қолжетімді",
    ),
    "notificationAndroidOnlyDesc": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы жоспар хабарламасының параметрлері тек Android VPN қызметіне қолданылады.",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Автоматты топ",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Сервер тобы анықталмаған, сондықтан бұл жол көрсетілмейді",
    ),
    "notificationBlockedSmartRoutingOff": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау өшірулі, сондықтан бұл жол көрсетілмейді",
    ),
    "notificationComponentBehaviour": MessageLookupByLibrary.simpleMessage(
      "Тәртібі",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Хабарлама компоненттері",
    ),
    "notificationComponentsActive": MessageLookupByLibrary.simpleMessage(
      "Хабарландыруда",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Хабарламаны нақты уақыттағы күй компоненттерінен құрастырыңыз.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Компоненттер қосылмаған",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Компоненттер болмаса, хабарландыру тек қорғаныс күйін көрсетеді.",
    ),
    "notificationComponentsOrderHint": MessageLookupByLibrary.simpleMessage(
      "Жолдар осы ретпен шығады. Хабарландыру жиналғанда деректері бар алғашқы жол көрінеді.",
    ),
    "notificationConnectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Қосылым диагностикасы",
    ),
    "notificationConnectionDoctorDesc": MessageLookupByLibrary.simpleMessage(
      "Байланыс диагностикасының қорытындысын көрсету",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Мазмұн"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы сервер",
    ),
    "notificationCurrentServerDesc": MessageLookupByLibrary.simpleMessage(
      "Топта таңдалған торапты көрсету",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android хабарламасын жеткізу",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android хабарлама рұқсатын тексеру",
    ),
    "notificationDeliveryFix": MessageLookupByLibrary.simpleMessage("Түзету"),
    "notificationDeliveryOff": MessageLookupByLibrary.simpleMessage(
      "Хабарлама жүйе параметрлерінде өшірілген",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "ReClash хабарламалары бұғатталған",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Хабарламаларды жеткізуге болады",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash қызмет арнасы өшірілген",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Жазылым еске салғыштары арнасы өшірілген",
        ),
    "notificationDetailedDesc": MessageLookupByLibrary.simpleMessage(
      "Тікелей күй жолдары, жылдам әрекеттер және күй жолағындағы белгіше көрсетіледі",
    ),
    "notificationDoctorPriority": MessageLookupByLibrary.simpleMessage(
      "Қосылым диагностикасының басымдығы",
    ),
    "notificationDoctorPriorityAlways": MessageLookupByLibrary.simpleMessage(
      "Әрқашан",
    ),
    "notificationDoctorPriorityProblems": MessageLookupByLibrary.simpleMessage(
      "Тек мәселелер",
    ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Бос кезде жылдамдықты жасыру",
    ),
    "notificationHideIdleSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик болмаған кезде жылдамдық мәндерін жасыру",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Құлып экранында құпия мәліметтерді жасыру",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғы құлыптаулы кезде профиль, бағыттау және диагностика мәліметтерін жасыру",
    ),
    "notificationMinimalDesc": MessageLookupByLibrary.simpleMessage(
      "Тек қорғаныс күйі, жедел мәліметтер мен жылдам әрекеттерсіз",
    ),
    "notificationMoveDown": MessageLookupByLibrary.simpleMessage(
      "Төмен жылжыту",
    ),
    "notificationMoveUp": MessageLookupByLibrary.simpleMessage(
      "Жоғары жылжыту",
    ),
    "notificationNetworkNormal": MessageLookupByLibrary.simpleMessage(
      "Қалыпты",
    ),
    "notificationNetworkOffline": MessageLookupByLibrary.simpleMessage(
      "Офлайн",
    ),
    "notificationNetworkPortal": MessageLookupByLibrary.simpleMessage(
      "Авторизация порталы",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Желі жылдамдығы",
    ),
    "notificationNetworkSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы жүктеу және жіберу жылдамдығын көрсету",
    ),
    "notificationNetworkState": MessageLookupByLibrary.simpleMessage(
      "Желі күйі",
    ),
    "notificationNetworkStateDesc": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы RCX желі ахуалын көрсету",
    ),
    "notificationNetworkUnknown": MessageLookupByLibrary.simpleMessage(
      "Белгісіз",
    ),
    "notificationNetworkWhitelist": MessageLookupByLibrary.simpleMessage(
      "Рұқсат тізімі",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Құпиялылық"),
    "notificationProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "Тұрақты хабарлама қорғаныстың белсенді екенін көрсетеді.",
    ),
    "notificationProtectionTitle": MessageLookupByLibrary.simpleMessage(
      "Қорғау күйі",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Еске салғыштар",
    ),
    "notificationRemindersDesc": MessageLookupByLibrary.simpleMessage(
      "Еске салғыштар өз арнасын пайдаланады және кез келген хабарлама деңгейінде келеді.",
    ),
    "notificationRemoveComponent": MessageLookupByLibrary.simpleMessage(
      "Хабарландырудан алып тастау",
    ),
    "notificationReorder": MessageLookupByLibrary.simpleMessage(
      "Ретін өзгерту",
    ),
    "notificationSelectServerGroup": MessageLookupByLibrary.simpleMessage(
      "Серверлер тобын таңдау",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "Таңдалған топ профильде жоқ",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Қызмет арнасы",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Сеанс трафигі",
    ),
    "notificationSessionTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Осы сеанстың жүктелген және жіберілген трафигін көрсету",
    ),
    "notificationSmartRouting": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау",
    ),
    "notificationSmartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Белсенді смарт бағыттау шешімін көрсету",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Жазылым еске салғыштары арнасы",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Жазылым еске салғыштары",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Жазылымға назар қажет болғанда хабарлау",
        ),
    "notificationTurnOff": MessageLookupByLibrary.simpleMessage(
      "Хабарламаны өшіру",
    ),
    "notificationTurnOffDesc": MessageLookupByLibrary.simpleMessage(
      "Қорғаныс жұмыс істеп тұрғанда Android хабарламаны талап етеді. Осы арнаны өшіру үшін жүйе параметрлерін ашыңыз.",
    ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Хабарлама деңгейі",
    ),
    "notificationVisibilityAlways": MessageLookupByLibrary.simpleMessage(
      "Әрқашан көрсетіледі",
    ),
    "notificationVisibilityCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Сервер тобы анықталғанда көрсетіледі",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Толық",
    ),
    "notificationVisibilityDoctorProblems":
        MessageLookupByLibrary.simpleMessage(
          "Ақаулық анықталғанда көрсетіледі",
        ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Ең аз",
    ),
    "notificationVisibilitySessionTraffic":
        MessageLookupByLibrary.simpleMessage(
          "Сессияда трафик болғанда көрсетіледі",
        ),
    "notificationVisibilitySmartRoutingOn":
        MessageLookupByLibrary.simpleMessage(
          "Смарт бағыттау қосулы кезде көрсетіледі",
        ),
    "notificationVisibilitySpeedIdle": MessageLookupByLibrary.simpleMessage(
      "Трафик болмағанда жасырылады",
    ),
    "ntpDesc": MessageLookupByLibrary.simpleMessage(
      "Желілік уақытты синхрондауды баптау",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Әзірге профильдер жоқ. Алдымен профиль қосыңыз.",
    ),
    "nullTip": m63,
    "numberTip": m64,
    "off": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Таңбаша ғана"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Тек прокси трафигін есептеу",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Қосулы кезде тек прокси трафигі есептеледі",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("Браузерде ашу"),
    "optional": MessageLookupByLibrary.simpleMessage("Міндетті емес"),
    "options": MessageLookupByLibrary.simpleMessage("Опциялар"),
    "other": MessageLookupByLibrary.simpleMessage("Басқа"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Басқа үлес қосушылар",
    ),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Шығыс IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Шығыс режимі"),
    "override": MessageLookupByLibrary.simpleMessage("Әдепкіні ауыстыру"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS-ті алмастыру"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Қосылғанда профильдегі DNS баптауларының орнына қолданба мәндері қолданылады",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Ауыстыру жазбалары",
    ),
    "overrideKeys": MessageLookupByLibrary.simpleMessage(
      "Ауыстырылатын кілттер",
    ),
    "overrideKeysDesc": MessageLookupByLibrary.simpleMessage(
      "Тек таңдалған кілттер профиль мәндерін алмастырады",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Қайта жазу режимі"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Желі баптауларын алмастыру",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мәндерінің орнына қолданба портын, IPv6, allow-lan, find-process-mode және TUN стегін қолдану",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("NTP-ды ауыстыру"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "Профильдің NTP параметрлерін таңдалған кілттермен алмастыру",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage(
      "Қайта жазу скрипті",
    ),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Арнайы режим: прокси топтары мен ережелерді толықтай өз қалауыңызша баптау",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("Бет анимациясы"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Беттер арасында ауысу анимациясы",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "panelHwidIdentityDisabled": MessageLookupByLibrary.simpleMessage(
      "HWID жіберу өшірулі. Панельге сенсеңіз ғана қосыңыз.",
    ),
    "panelHwidNotSupported": MessageLookupByLibrary.simpleMessage(
      "Панель HWID шектеуі туралы хабарлады",
    ),
    "panelHwidNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "Панель x-hwid-not-supported қайтарды. Бұл клиенттің үйлесімсіздігін дәлелдемейді. HWID баптаулары мен жазылым талаптарын тексеріңіз.",
    ),
    "panelSettingsConfirmMessage": m65,
    "panelSettingsConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Провайдер баптауларын қолдану",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Құпиясөз"),
    "paste": MessageLookupByLibrary.simpleMessage("Қою"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("Қою"),
    "pause": MessageLookupByLibrary.simpleMessage("Кідірту"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("VPN кідіртілуде…"),
    "paused": MessageLookupByLibrary.simpleMessage("Кідірілді"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage(
      "Мәңгілік жазылыс",
    ),
    "personalCabinet": MessageLookupByLibrary.simpleMessage("Жеке кабинет"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Галереядан таңдау"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Желіні таңдау"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Маңайдағы Wi-Fi желілері",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желілері табылмады",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Маңайдағы Wi-Fi желілерін көрсету үшін орналасу рұқсаты қажет",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Жаңарту"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Маңайдағы Wi-Fi желілері ізделуде…",
    ),
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
    "porcelainThemeDesc": MessageLookupByLibrary.simpleMessage(
      "Салқын, монохромға жуық палитраны қолдану",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Басқа порт енгізіңіз",
    ),
    "portTip": m66,
    "predictiveBack": MessageLookupByLibrary.simpleMessage(
      "Болжамды «Артқа» қимылы",
    ),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "DoH үшін HTTP/3-ті артық көру",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Алғышарттар"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Пернені басыңыз"),
    "preview": MessageLookupByLibrary.simpleMessage("Алдын ала қарау"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Алдыңғы сәйкестік"),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Жарамды аралықты енгізіңіз."),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Автожаңарту аралығын енгізіңіз."),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль өзгертілді. Автоматты жаңарту өшірілсін бе?",
    ),
    "profileImportEmptyResponse": MessageLookupByLibrary.simpleMessage(
      "Сервер бос профиль қайтарды",
    ),
    "profileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Профильді импорттау мүмкін болмады",
    ),
    "profileImportFileReadFailed": MessageLookupByLibrary.simpleMessage(
      "Таңдалған файлды оқу мүмкін болмады",
    ),
    "profileImportFormatClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "profileImportFormatLinks": MessageLookupByLibrary.simpleMessage(
      "Бөлісу сілтемелері",
    ),
    "profileImportFormatSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box",
    ),
    "profileImportFormatWireguard": MessageLookupByLibrary.simpleMessage(
      "WireGuard",
    ),
    "profileImportFormatXray": MessageLookupByLibrary.simpleMessage("Xray"),
    "profileImportInvalidConfig": MessageLookupByLibrary.simpleMessage(
      "Профиль конфигурациясы жарамсыз",
    ),
    "profileImportSkippedNodes": m67,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль импортталды",
    ),
    "profileImportSuccessSummary": m68,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "Импорт сілтемесі зақымдалған немесе қолдау көрсетілмейді",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль атауын енгізіңіз.",
    ),
    "profileUnusedForDays": m69,
    "profileUnusedForMonths": m70,
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
    "providerEffects": MessageLookupByLibrary.simpleMessage(
      "Провайдер әсерлері",
    ),
    "providerEffectsDesc": MessageLookupByLibrary.simpleMessage(
      "Жазылымға басты экранға декоративті әсер қосуға рұқсат ету",
    ),
    "providerView": MessageLookupByLibrary.simpleMessage("Провайдер көрінісі"),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылыс прокси бетін безендірсін. Сіз өзгерткендеріңіз сақталып қалады.",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Сыртқы ресурстар"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m71,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Проксилер бос"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Прокси тізбегі"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Таңдалған проксилерде ауытқу байқалды",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Прокси сүзгісі"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Прокси тобы"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы прокси тобында ауытқу байқалды",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("Прокси тобы бос"),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Мұндай атаумен прокси тобы бұрыннан бар",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Прокси тобының атауы бос болмауы тиіс",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "Прокси DNS сервері",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Прокси түйіндерінің домен атауларын шешу үшін қолданылады",
    ),
    "proxyNode": MessageLookupByLibrary.simpleMessage("Прокси түйіні"),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Таңдалған прокси провайдерлерінде ауытқу байқалды",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлері",
    ),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлері бос",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлері бос болмауы тиіс",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Прокси түрі"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Кэшті тазарту"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Таза қара"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Таза қара режим"),
    "qrScanUnsupported": MessageLookupByLibrary.simpleMessage(
      "Бұл құрылғыда QR-кодтарды сканерлеуге қолдау көрсетілмейді.",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR коды"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QR кодын сканерлеу арқылы профиль алу",
    ),
    "quickAdd": MessageLookupByLibrary.simpleMessage("Жылдам қосу"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Жылдам өңдеу"),
    "quickFill": MessageLookupByLibrary.simpleMessage("Жылдам толтыру"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Кемпірқосақ"),
    "random": MessageLookupByLibrary.simpleMessage("Кездейсоқ"),
    "recordType": MessageLookupByLibrary.simpleMessage("Жазба түрі"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir порты"),
    "redo": MessageLookupByLibrary.simpleMessage("Қайтадан жасау"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("Қимылды азайту"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage(
      "Безендіру анимацияларын өшіру",
    ),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage(
      "Жүйе баптауларында қосылып қойған",
    ),
    "regexSearch": MessageLookupByLibrary.simpleMessage(
      "Тұрақты өрнек арқылы іздеу",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Жадты босату"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Жадты босату мүмкін болмады",
    ),
    "reload": MessageLookupByLibrary.simpleMessage("Қайта жүктеу"),
    "remaining": MessageLookupByLibrary.simpleMessage("Қалған"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("Қалғаны"),
    "remote": MessageLookupByLibrary.simpleMessage("Қашықтағы"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді WebDAV-қа көшіріп сақтау",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Қашықтағы нысан",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Алып тастау"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылысты ұзарту",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Сұрау"),
    "requests": MessageLookupByLibrary.simpleMessage("Сұраулар"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Соңғы сұрау жазбаларын көру",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Ысыру"),
    "resetFindings": MessageLookupByLibrary.simpleMessage(
      "Табылғандарды ысыру",
    ),
    "resetFindingsConfirm": MessageLookupByLibrary.simpleMessage(
      "Ашылған жазбалар жасырылып, қайта пайда бола алады. Қолдану тарихы өзгермейді.",
    ),
    "resetFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "Қолдану тарихын өшірмей, ашылу сәттерін қайта көрсету",
    ),
    "resetFindingsTitle": MessageLookupByLibrary.simpleMessage(
      "Табылғандарды ысыру керек пе?",
    ),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Бұл бетте өзгерістер бар. Олар бастапқы күйіне қайтарылсын ба?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Ысырылсын ба?"),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурстар"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Сыртқы ресурстар туралы ақпарат",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Ережелерді ұстану"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS қосылымдары ережелерге сәйкес жүреді; proxy-server-nameserver қажет",
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
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Қалпына келтіру қатесі",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді файлдан қалпына келтіру",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді WebDAV арқылы қалпына келтіру",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Тек профильдерді қалпына келтіру",
    ),
    "restorePreviewDescription": MessageLookupByLibrary.simpleMessage(
      "Растамайынша ештеңе өзгермейді.",
    ),
    "restorePreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Қалпына келтіруді тексеру",
    ),
    "restoreProfilesCount": m72,
    "restoreProxyGroupsCount": m73,
    "restoreRulesCount": m74,
    "restoreScriptsCount": m75,
    "restoreSettingsIncluded": MessageLookupByLibrary.simpleMessage(
      "Баптаулар бар",
    ),
    "restoreSettingsNotIncluded": MessageLookupByLibrary.simpleMessage(
      "Бұл сақтық көшірмеде баптаулар жоқ",
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
    "resume": MessageLookupByLibrary.simpleMessage("Жалғастыру"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("Автор және мейнтейнер"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Бағыттау адрестері"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Бағыттау адрестерін баптау",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Бағыттау режимі"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Жеке адрестерді айналып өту",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны қолдану",
    ),
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
    "ruleName": MessageLookupByLibrary.simpleMessage("Ереже атауы"),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent тікелей",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS бөгеу",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("QUIC бөгеу"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("STUN бөгеу"),
    "rulePresetChinaDirect": MessageLookupByLibrary.simpleMessage(
      "Қытай қызметтері тікелей",
    ),
    "rulePresetIranDirect": MessageLookupByLibrary.simpleMessage(
      "Иран қызметтері тікелей",
    ),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "Жергілікті желі тікелей",
    ),
    "rulePresetRussiaDirect": MessageLookupByLibrary.simpleMessage(
      "Ресей қызметтері тікелей",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple және Microsoft тікелей",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Ереже жинағы"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Ереже нысаны"),
    "rules": MessageLookupByLibrary.simpleMessage("Ережелер"),
    "rulesCount": m76,
    "save": MessageLookupByLibrary.simpleMessage("Сақтау"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер сақталсын ба?",
    ),
    "schedule": MessageLookupByLibrary.simpleMessage("Кесте бойынша"),
    "scheduleDesc": m77,
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрипт режимі: сыртқы кеңейту скрипттері арқылы конфигурацияны бір шертумен қайта жазады",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Таңдалғанға жылжыту",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Іздеу"),
    "searchApps": MessageLookupByLibrary.simpleMessage("Қолданбаларды іздеу"),
    "seasonBirthdayNote": MessageLookupByLibrary.simpleMessage(
      "Бүгін ReClash туған күні.",
    ),
    "seasonFirstRunNote": MessageLookupByLibrary.simpleMessage(
      "Бүгін алғашқы іске қосуыңыздың жылдығы.",
    ),
    "seasonalDecorations": MessageLookupByLibrary.simpleMessage(
      "Маусымдық безендіру",
    ),
    "seasonalDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "Басты экранда нәзік маусымдық бөлшектерді көрсету",
    ),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m78,
    "selectAll": MessageLookupByLibrary.simpleMessage("Барлығын таңдау"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET нысанын таңдау",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage(
      "Проксилерді таңдаңыз",
    ),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Прокси провайдерлерін таңдаңыз",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағын таңдаңыз",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Бөлу стратегиясын таңдаңыз",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Ішкі ережені таңдаңыз",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Таңдалған"),
    "selectedCountTitle": m79,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage(
      "Құрылғы идентификаторын жіберу",
    ),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғы идентификаторын, қолданба нұсқасын және құрылғы атауын провайдер серверіне жіберу",
    ),
    "sendDeviceIdentityDisableWarning": MessageLookupByLibrary.simpleMessage(
      "HWID жіберуді өшірсеңіз, жазылымдардың көпшілігі жұмыс істемей қалады. Жалғастырасыз ба?",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Белсендіні автоматты тексеру",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Барлығын автоматты тексеру",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Қолжетімді"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Бұғатталған"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Тексеру"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Барлығын тексеру"),
    "serviceCheckedAt": m80,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Жақында"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Провайдер бұғатталған",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage(
      "Тексеру сәтсіз аяқталды",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Сервис"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Қызметтерді баптау"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Тек түпнұсқалар",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Тексерілмеген"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Қатынас шектелген",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Қызметтер күйі"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Қолжетімсіз"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Аймаққа қолдау жоқ",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Баптаулар"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage("Тағы қосу"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage(
      "ReClash ашылғанда қосылу",
    ),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Жарамды профиль жүктелген соң VPN-ді автоматты іске қосады",
    ),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "Автоматты қосылу үшін профиль қосыңыз",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("Артқа"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "Профильсіз жалғастыру",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN өшірулі қалады. Профильді кейін қосуға немесе VPN провайдерінсіз тек ByeDPI режимін пайдалануға болады.",
    ),
    "setupContinueWithoutProfileDescPlain":
        MessageLookupByLibrary.simpleMessage(
          "VPN өшірулі қалады. Профильді кейін қосуға болады.",
        ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "Қосымша ақау есептерін жіберу",
    ),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба ақауларын табуға көмектеседі. Өзіңіз қоспасаңыз, есеп жіберілмейді.",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage(
      "Келіспеймін және шығу",
    ),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("Жою"),
    "setupDone": MessageLookupByLibrary.simpleMessage("Дайын"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage(
      "Дайын және қосылу",
    ),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage(
      "Баптауларды тексеріңіз",
    ),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "Оны кейін баптаулардан өзгертуге болады",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Тілді таңдаңыз",
    ),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage(
      "Толық жауапкершіліктен бас тартуды оқу",
    ),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage(
      "Ашық код лицензиялары",
    ),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash трафикті бағыттау үшін жергілікті VPN қосылымын жасайды. Конфигурацияны не провайдерді өзіңіз таңдайсыз және оны пайдалануға өзіңіз жауаптысыз.",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage(
      "Жалғастырмас бұрын",
    ),
    "setupNext": MessageLookupByLibrary.simpleMessage("Келесі"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage(
      "Батареяны оңтайландыру",
    ),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash-қа VPN-ді фонда белсенді ұстауға рұқсат беріңіз",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage(
      "Тексерілуде…",
    ),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage(
      "Алғаш қосылғанда сұралады",
    ),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Рұқсат берілмеген",
    ),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage(
      "Тексеру мүмкін болмады",
    ),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage(
      "Рұқсат берілген",
    ),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage(
      "Хабарландырулар",
    ),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash жұмыс істеп тұрғанда қосылым күйін көрсетеді",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
      "Баптауларды ашу",
    ),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage(
      "Рұқсат беру",
    ),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Қолжетімсіз",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage("VPN рұқсаты"),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "Жүйе алғаш қосылғанда сұрайды",
    ),
    "setupPermissionsTitle": MessageLookupByLibrary.simpleMessage("Рұқсаттар"),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash VPN қызметін сатпайды. Сенімді провайдердің сілтемесін, QR кодын немесе конфигурация файлын пайдаланыңыз. Профиль сақталмас бұрын тексеріледі.",
    ),
    "setupProfilesReady": m81,
    "setupRawConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурация мәтіні",
    ),
    "setupRawConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash-пен үйлесімді YAML конфигурациясын қою",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Желі өңірін таңдаңыз. Ресей таңдалса, HWID қосылады; оны төменде өшіруге болады. Ақылды бағыттау бөлек қосылады.",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("Басқа"),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage(
      "Тіліңізге ұсынылады",
    ),
    "setupRegionSettings": MessageLookupByLibrary.simpleMessage(
      "Өңірдің жылдам баптаулары",
    ),
    "setupRegionSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Геодеректерді, бағыттау пресеттерін және қолданбалар қатынасын тексеріңіз. Ештеңе автоматты түрде қосылмайды.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі қай өңірде?",
    ),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "Жаңа профиль сәтті импортталып, тексерілгеннен кейін ғана ағымдағысы жойылады.",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage(
      "Бастапқы баптауды қайталау",
    ),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "Деректерді жоймай, тілді, профильді, бағыттауды және рұқсаттарды тексеру",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірмеден қалпына келтіру",
    ),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash, FlClashX немесе FlClash көшірмесінен баптаулар мен профильдерді қалпына келтіру",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("Профильсіз жалғастыру"),
    "setupStepProgress": m82,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "Профильде қосылуға қажет серверлер мен ережелер бар. Оны провайдерден не сақтық көшірмеден импорттаңыз.",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "Профиль дайын",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Қосылым профилін қосыңыз",
    ),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage(
      "Автоматты қосылу: өшірулі",
    ),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage(
      "Автоматты қосылу: қосулы",
    ),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "VPN профилі жоқ — VPN өшірулі қалады; тек ByeDPI режимі қолжетімді",
    ),
    "setupSummaryNoProfilePlain": MessageLookupByLibrary.simpleMessage(
      "VPN профилі жоқ — VPN өшірулі қалады",
    ),
    "setupSummaryProfile": m83,
    "setupSummaryRouting": m84,
    "setupSummarySystemProxyOff": MessageLookupByLibrary.simpleMessage(
      "Жүйелік прокси: өшірулі",
    ),
    "setupSummarySystemProxyOn": MessageLookupByLibrary.simpleMessage(
      "Жүйелік прокси: қосулы",
    ),
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage(
      "Баптау қорытындысы",
    ),
    "setupSummaryTunOff": MessageLookupByLibrary.simpleMessage("TUN: өшірулі"),
    "setupSummaryTunOn": MessageLookupByLibrary.simpleMessage("TUN: қосулы"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage("Жүйе тілі"),
    "setupSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Әкімші құқығынсыз қолдау көрсетілетін қолданбаларды ReClash арқылы бағыттайды",
    ),
    "setupTunDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғының бүкіл трафигін бағыттайды; қосылу кезінде жүйе әкімші құқығын сұрауы мүмкін",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "Бірнеше түсінікті қадамнан кейін бәрі дайын",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Көрсету"),
    "showLabels": MessageLookupByLibrary.simpleMessage(
      "Бүйірлік панель атауларын көрсету",
    ),
    "showLess": MessageLookupByLibrary.simpleMessage("Жию"),
    "showMore": MessageLookupByLibrary.simpleMessage("Жаю"),
    "showPassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді көрсету"),
    "shrink": MessageLookupByLibrary.simpleMessage("Ықшам"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Жасырын іске қосу"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Фондық режимде іске қосылады",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Өлшем"),
    "slide": MessageLookupByLibrary.simpleMessage("Жылжу"),
    "smartPause": MessageLookupByLibrary.simpleMessage("Смарт кідірту"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды жабу",
    ),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "Сенімді желілерде VPN автоматты түрде кідіртіледі",
    ),
    "smartPauseFullStop": MessageLookupByLibrary.simpleMessage("Толық тоқтату"),
    "smartPauseFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Сенімді желілерде кідіртудің орнына VPN-ді толық тоқтату",
    ),
    "smartPauseMatchedOn": m85,
    "smartPauseStrict": MessageLookupByLibrary.simpleMessage(
      "SSID мен ішкі желіні бірге талап ету",
    ),
    "smartPauseStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Екі түрлі ереже де болса, SSID пен ішкі желі сәйкес келгенде ғана кідірту",
    ),
    "smartRouting": MessageLookupByLibrary.simpleMessage("Смарт бағыттау"),
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "Уақытша шегерілген провайдерлер",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "Уақытша шегерілген тексерулер",
    ),
    "smartRoutingAdmittedYes": MessageLookupByLibrary.simpleMessage(
      "Жіберілген",
    ),
    "smartRoutingAliveCount": m86,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "Барлық серверлер",
    ),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік",
    ),
    "smartRoutingAvailabilityValue": m87,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "Орташа ауысу",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "Орташа қалпына келу",
    ),
    "smartRoutingAvoidCountries": MessageLookupByLibrary.simpleMessage(
      "Шығу елдерін болдырмау",
    ),
    "smartRoutingAvoidCountriesDesc": MessageLookupByLibrary.simpleMessage(
      "Шығуы осы елдерде өлшенген сервер арқылы ешқашан, тіпті амалсыздан да, бағыттамау",
    ),
    "smartRoutingAxisData": MessageLookupByLibrary.simpleMessage(
      "Трафикті үнемдеу",
    ),
    "smartRoutingAxisSpeed": MessageLookupByLibrary.simpleMessage("Жылдамдық"),
    "smartRoutingAxisStability": MessageLookupByLibrary.simpleMessage(
      "Тұрақтылық",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Автоматты режимге қайту",
    ),
    "smartRoutingBackup": MessageLookupByLibrary.simpleMessage(
      "Сақтық көшірме",
    ),
    "smartRoutingBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Бүкіл баптауды файлға сақтаңыз немесе қалпына келтіріңіз",
    ),
    "smartRoutingBandInvalid": MessageLookupByLibrary.simpleMessage(
      "Оң миллисекунд санын енгізіңіз",
    ),
    "smartRoutingBandLabel": m88,
    "smartRoutingBands": m89,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Іс-әрекет"),
    "smartRoutingBehaviourDesc": MessageLookupByLibrary.simpleMessage(
      "Қолмен таңдау мен диагностика кезінде қозғалтқыштың әрекеті",
    ),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы сервер тізімінде жоқ",
    ),
    "smartRoutingBlockAvoidExit": MessageLookupByLibrary.simpleMessage(
      "Болдырмайтын ел арқылы шығады",
    ),
    "smartRoutingBlockCooling": m90,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Мұндағы тексеруден өтпеді",
    ),
    "smartRoutingBlockIgnored": MessageLookupByLibrary.simpleMessage(
      "Ереже елемейді",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "Жергілікті сервер, бұл желіде тыйым салынған",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage(
      "UDP қолдауы жоқ",
    ),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "Тәуелсіз ақаулардан кейін провайдер уақытша шегерілді",
    ),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "Бұл желіде бағыттау әлі істемейді",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage(
      "Ақ тізім желілерінің маманы",
    ),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "Шектеулі желілер үшін сақталады, ашық желіде жұмсалмайды",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "Ақ тізімге арналған сервер атаулары",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "Серверді шектеулі желілерге арналған деп танытатын атау бөліктері",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage(
      "Канарейка адрестері",
    ),
    "smartRoutingCanariesAnswered": m91,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "Жергілікті канарейкалар",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Тікелей қолжетімді — ақ тізімдегі желі мен мүлде байланыссыз күйді айыру үшін",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "Шетелдік канарейкалар",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "Жай IP:порт тікелей қолжетімді — ашық желі мен мүлде өшірілген желіні айыру үшін",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage(
      "жергілікті",
    ),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage(
      "шетелдік",
    ),
    "smartRoutingCeiling": MessageLookupByLibrary.simpleMessage("Кідіріс шегі"),
    "smartRoutingCeilingDesc": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істеп тұрған серверді кідірісі осы шектен асқанда тастау",
    ),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage(
      "Цензура қолданатын елдер",
    ),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "Ондағы сервер жергілікті деп саналады, сондықтан өшіру басталғанға дейін ұсталып тұрады",
    ),
    "smartRoutingCensorSni": MessageLookupByLibrary.simpleMessage(
      "Цензураланатын SNI",
    ),
    "smartRoutingCensorSniDesc": MessageLookupByLibrary.simpleMessage(
      "Қолжетімді шетелдік IP-ге SNI ретінде жіберілетін бұғатталған домен; үзілген handshake атау бойынша сүзгілеуді әшкерелейді",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage(
      "Таңдалған сервер",
    ),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "Әлі сервер таңдалған жоқ",
    ),
    "smartRoutingCoolFor": m92,
    "smartRoutingCountryEchoes": MessageLookupByLibrary.simpleMessage(
      "Елді анықтау қызметтері",
    ),
    "smartRoutingCountryEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "Күдікті түйінді тексергенде сервердің нақты шығу елін хабарлайтын эндпоинттер",
    ),
    "smartRoutingCountryNoMatch": MessageLookupByLibrary.simpleMessage(
      "Сәйкес ел коды жоқ",
    ),
    "smartRoutingCountryPolicy": MessageLookupByLibrary.simpleMessage(
      "Ел саясаты",
    ),
    "smartRoutingCountryPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Қай елдер цензура қолданушы саналады және қайсысын шығыс ретінде болдырмау керек",
    ),
    "smartRoutingCountrySearch": MessageLookupByLibrary.simpleMessage(
      "Ел коды бойынша іздеу",
    ),
    "smartRoutingDecisionEngine": MessageLookupByLibrary.simpleMessage(
      "Шешім қозғалтқышы",
    ),
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage(
      "Әр серверді тексеру",
    ),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "Өлшеу бюджетіне мән бермейді, сондықтан трафик жұмсайды",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "Әр сервер тексерілуде…",
    ),
    "smartRoutingDegradeConfirm": MessageLookupByLibrary.simpleMessage(
      "Тежеуді растау уақыты",
    ),
    "smartRoutingDegradeConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "Серверді ауыстырғанға дейін трафик қанша уақыт нашарлауы керек",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("Тежелген"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Әр желі үшін жұмыс істейтін сервер дайын тұрады",
    ),
    "smartRoutingDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Диагностика журналы",
    ),
    "smartRoutingDiagnosticsDesc": MessageLookupByLibrary.simpleMessage(
      "Осы сеанстағы әрбір бағыттау шешімін, ауысуын және зондын жазу",
    ),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage(
      "Желі ажыратылғанда жергілікті серверлер",
    ),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Ақ тізім желісіндегі соңғы амал — жергілікті қызметтер істеп тұруы үшін",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "Жергілікті қызметтер тікелей өтеді",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "Жергілікті қызметтер таңдалған сервер арқылы өтеді",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage("Орнығу уақыты"),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "Істеп тұрған сервер жылдамырағы табылғанша қанша уақыт ұсталады",
    ),
    "smartRoutingEgress": MessageLookupByLibrary.simpleMessage(
      "Шығысты тексеру",
    ),
    "smartRoutingEgressDesc": MessageLookupByLibrary.simpleMessage(
      "Бүркемеленген сервердің шын мәнінде қайдан шығатынын ашатын қызметтер",
    ),
    "smartRoutingEgressEchoes": MessageLookupByLibrary.simpleMessage(
      "Шығыс эхо қызметтері",
    ),
    "smartRoutingEgressEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "Шақырушының мекенжайымен жауап беріп, бүркемеленген сервердің нақты шығысын ашатын нүктелер",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage(
      "Әлі ештеңе өлшенбеген",
    ),
    "smartRoutingEngineAvailable": MessageLookupByLibrary.simpleMessage(
      "Бағыт жұмыс істеген уақыт",
    ),
    "smartRoutingEngineDeepScan": MessageLookupByLibrary.simpleMessage(
      "Толық тексеру",
    ),
    "smartRoutingEngineLanes": MessageLookupByLibrary.simpleMessage(
      "Сервис жолақтары",
    ),
    "smartRoutingEngineLinkAge": MessageLookupByLibrary.simpleMessage(
      "Қосылым жасы",
    ),
    "smartRoutingEngineMode": MessageLookupByLibrary.simpleMessage(
      "Ядро режимі",
    ),
    "smartRoutingEnginePin": MessageLookupByLibrary.simpleMessage(
      "Бекітілген сервер",
    ),
    "smartRoutingEnginePreset": MessageLookupByLibrary.simpleMessage(
      "Аймақ баптауы",
    ),
    "smartRoutingEngineReportAge": MessageLookupByLibrary.simpleMessage(
      "Есептің жасы",
    ),
    "smartRoutingEngineTerrain": MessageLookupByLibrary.simpleMessage(
      "Желі коды",
    ),
    "smartRoutingEngineTransport": MessageLookupByLibrary.simpleMessage(
      "Қосылым түрі",
    ),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage(
      "Желі жадының кілті",
    ),
    "smartRoutingEpisodes": m93,
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "Ешбір жергілікті мекенжай жауап бермеді",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "Жергілікті мекенжай жауап берді",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "Ешбір шетелдік мекенжай жауап бермеді",
    ),
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "Қақпа құйма сертификатпен жауап берді",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "Шетелдік мекенжай сертификат тексерісінен өтті",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "Жақындағы тексерумен расталды",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "Өз трафигіңізбен расталды",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage(
      "Ешқашан расталмаған",
    ),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "Жүйе кіру бетін байқады",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "Соңғы рет біраз уақыт бұрын расталды",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "Жүйе интернет байланысы жоқ деп хабарлайды",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "Жүйе интернет байланысын растады",
    ),
    "smartRoutingExperimentalNotice": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау — тәжірибелік мүмкіндік әрі әлі әзірленуде. Ол күтпеген түрде жұмыс істеуі және әрдайым ең қолайлы серверді таңдай бермеуі мүмкін. Оны осыған дайын болсаңыз ғана қосыңыз.",
    ),
    "smartRoutingExport": MessageLookupByLibrary.simpleMessage(
      "Параметрлерді экспорттау",
    ),
    "smartRoutingExportDesc": MessageLookupByLibrary.simpleMessage(
      "Бүкіл смарт-бағдарлау параметрлерін файлға сақтау",
    ),
    "smartRoutingExported": MessageLookupByLibrary.simpleMessage(
      "Смарт-бағдарлау параметрлері экспортталды",
    ),
    "smartRoutingFails": m94,
    "smartRoutingFieldReset": MessageLookupByLibrary.simpleMessage(
      "Стратегия әдепкісіне қайтару",
    ),
    "smartRoutingFitNo": MessageLookupByLibrary.simpleMessage("Келмейді"),
    "smartRoutingFitYes": MessageLookupByLibrary.simpleMessage("Келеді"),
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage(
      "Байланыс жоқ",
    ),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "Жергілікті де, шетелдік те ештеңе жауап бермейді",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage(
      "Толық ашық",
    ),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Сіз бен ашық интернет арасында ештеңе бұғатталмаған",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage(
      "Кіру қажет",
    ),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "Желі трафикті өткізу үшін алдымен кіруді сұрайды",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage(
      "Шектеулі",
    ),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "Тек жергілікті қызметтер жауап береді, шетелдіктер жоқ",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "Әлі өлшенуде",
    ),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "Анықтау үшін әлі жауап жеткіліксіз",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage(
      "бұғатталған",
    ),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage(
      "тексерілмеген",
    ),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("жарамды"),
    "smartRoutingHeuristics": MessageLookupByLibrary.simpleMessage(
      "Түйін эвристикасы",
    ),
    "smartRoutingHeuristicsDesc": MessageLookupByLibrary.simpleMessage(
      "Серверлерді таңдауға әсер ететін атау белгілері мен ережелер",
    ),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage(
      "Соңғы ауысулар",
    ),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Әлі ауысу болған жоқ",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage(
      "кідіріс тестінен",
    ),
    "smartRoutingImport": MessageLookupByLibrary.simpleMessage(
      "Параметрлерді импорттау",
    ),
    "smartRoutingImportDesc": MessageLookupByLibrary.simpleMessage(
      "Смарт-бағдарлау параметрлерін файлдан алмастыру",
    ),
    "smartRoutingImportFailed": MessageLookupByLibrary.simpleMessage(
      "Бұл параметрлер файлын оқу мүмкін болмады",
    ),
    "smartRoutingImported": MessageLookupByLibrary.simpleMessage(
      "Смарт-бағдарлау параметрлері импортталды",
    ),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage(
      "Анықталған үзілістер",
    ),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage("Үміткер"),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage("Жұмыста"),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("ұсталды"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage(
      "Салыстыруға жіберілген",
    ),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage(
      "Кідіріс жолағы",
    ),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("Дәлелдер"),
    "smartRoutingKeyHomeRisk": MessageLookupByLibrary.simpleMessage(
      "Шетелге шығады",
    ),
    "smartRoutingKeyIncumbent": MessageLookupByLibrary.simpleMessage(
      "Қазір қолданылуда",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "Осы желіге сәйкестігі",
    ),
    "smartRoutingKeyTiebreak": MessageLookupByLibrary.simpleMessage(
      "Тұрақты тең түсуді шешу",
    ),
    "smartRoutingKeyUnproven": MessageLookupByLibrary.simpleMessage(
      "Трафик өткізген",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("Вердикт"),
    "smartRoutingLadderChangedDefault": m95,
    "smartRoutingLadderEditor": MessageLookupByLibrary.simpleMessage(
      "Салыстыру сатысы",
    ),
    "smartRoutingLadderEditorDesc": MessageLookupByLibrary.simpleMessage(
      "Салыстыру ретін өзгертіңіз, қадамдарды өшіріңіз және шектерін баптаңыз. Әр қадамның бағытын қозғалтқыш бекітеді.",
    ),
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "Екі сервер жол-жолмен салыстырылады. Олар алғаш өзгешеленген жол шешеді, одан төмендегілер мүлде оқылмайды.",
    ),
    "smartRoutingLadderReorderHint": MessageLookupByLibrary.simpleMessage(
      "Жылжыту үшін қадамды басып тұрыңыз. Екі сервер алғаш ерекшеленетін қадам жеңімпазды анықтайды.",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage(
      "Соңғы ауысу",
    ),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage(
      "Соңғы қалпына келу",
    ),
    "smartRoutingLatencyBands": MessageLookupByLibrary.simpleMessage(
      "Кідіріс сатылары",
    ),
    "smartRoutingLatencyBandsDesc": MessageLookupByLibrary.simpleMessage(
      "Серверлерді жылдамдық деңгейлеріне бөлетін миллисекундтық шекаралар; бос болса — стратегия әдепкісі",
    ),
    "smartRoutingLatencyStep": MessageLookupByLibrary.simpleMessage(
      "Кідірісті дөңгелектеу",
    ),
    "smartRoutingLatencyStepDesc": MessageLookupByLibrary.simpleMessage(
      "Салыстырудан бұрын кідіріс осы қадамға дөңгелектеледі, сондықтан шамалы айырма орынды өзгертпейді",
    ),
    "smartRoutingLatencyTolerance": MessageLookupByLibrary.simpleMessage(
      "Кідіріс төзімділігі",
    ),
    "smartRoutingLatencyToleranceDesc": MessageLookupByLibrary.simpleMessage(
      "Осы миллисекунд шегіндегі жылдамдық айырмасы тең деп есептеледі, келесі қадам шешеді",
    ),
    "smartRoutingLog": MessageLookupByLibrary.simpleMessage("Бағыттау журналы"),
    "smartRoutingLogAutoScroll": MessageLookupByLibrary.simpleMessage(
      "Автоайналдыру",
    ),
    "smartRoutingLogCandidates": MessageLookupByLibrary.simpleMessage(
      "Үміткерлер",
    ),
    "smartRoutingLogClear": MessageLookupByLibrary.simpleMessage(
      "Көріністі тазалау",
    ),
    "smartRoutingLogDesc": MessageLookupByLibrary.simpleMessage(
      "Механизм әрекетінің толық жазбасы",
    ),
    "smartRoutingLogDropped": m96,
    "smartRoutingLogEmpty": MessageLookupByLibrary.simpleMessage(
      "Бағыттау белсенділігі әзірге жазылмаған",
    ),
    "smartRoutingLogEnable": MessageLookupByLibrary.simpleMessage(
      "Журналды қосу",
    ),
    "smartRoutingLogExport": MessageLookupByLibrary.simpleMessage(
      "Журналды экспорттау",
    ),
    "smartRoutingLogFilter": MessageLookupByLibrary.simpleMessage("Түрлері"),
    "smartRoutingLogKindDecision": MessageLookupByLibrary.simpleMessage(
      "Шешім",
    ),
    "smartRoutingLogKindEvent": MessageLookupByLibrary.simpleMessage("Оқиға"),
    "smartRoutingLogKindProbe": MessageLookupByLibrary.simpleMessage("Зонд"),
    "smartRoutingLogKindSwitch": MessageLookupByLibrary.simpleMessage("Ауысу"),
    "smartRoutingLogOffHint": MessageLookupByLibrary.simpleMessage(
      "Бағыттау шешімдерін, ауысуларын және зондтарын жазу үшін оны қосыңыз.",
    ),
    "smartRoutingLogOffTitle": MessageLookupByLibrary.simpleMessage(
      "Диагностика журналы өшірулі",
    ),
    "smartRoutingLogRepeat": m97,
    "smartRoutingLogState": MessageLookupByLibrary.simpleMessage("Күй"),
    "smartRoutingLogWaiting": MessageLookupByLibrary.simpleMessage(
      "Механизм күтілуде…",
    ),
    "smartRoutingLostAt": m98,
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "Қолмен таңдағанды ұстану",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "Өзіңіз таңдаған сервер істен шыққанға дейін ұсталады",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "Істен шыққанға дейін ұсталады",
    ),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "Оқшауланған қызмет тексерулері",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "Қабылданатын статустар",
    ),
    "smartRoutingMarkerStatusesDesc": MessageLookupByLibrary.simpleMessage(
      "Осы тексеру сәтті деп саналатын HTTP кодтары",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "Үтірмен бөліп жазыңыз, мысалы 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "HTTP кодтарын үтірмен бөліп енгізіңіз",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkerUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Тексеруді растау үшін зонд сұрайтын толық URL",
    ),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage(
      "Сервис тексерулері",
    ),
    "smartRoutingMarkersDesc": MessageLookupByLibrary.simpleMessage(
      "Сервердің ашық интернетке немесе отандық қызметтерге жететінін дәлелдейтін URL мекенжайлары",
    ),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage(
      "Жергілікті тексерулер",
    ),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Өшіру кезінде жергілікті серверлер үшін қолданылады",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage(
      "Тексерулер бапталмаған",
    ),
    "smartRoutingMarkersLocal": MessageLookupByLibrary.simpleMessage(
      "Тек отандық тексерулер",
    ),
    "smartRoutingMarkersLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Серверді отандық деп таңбалаудан бұрын оның тек отаннан жауап беретінін растайды",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "Ашық интернеттегі тексерулер",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Дәлелденген деп есептелуі үшін сервер осы статустардың бірін қайтаруы керек",
    ),
    "smartRoutingMeasuredOver": m99,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage(
      "Тарифтелген желі",
    ),
    "smartRoutingMillis": m100,
    "smartRoutingMinutes": m101,
    "smartRoutingMore": MessageLookupByLibrary.simpleMessage("Тағы"),
    "smartRoutingNameHints": MessageLookupByLibrary.simpleMessage(
      "Отандық сервер атауының белгілері",
    ),
    "smartRoutingNameHintsDesc": MessageLookupByLibrary.simpleMessage(
      "Сервердің отанда тұрғанын меңзейтін атау бөліктері",
    ),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("Желі"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "Осы желіде әлі ауыспаған",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("жауап жоқ"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage(
      "Әзірге қалпына келтірілген үзіліс жоқ",
    ),
    "smartRoutingNoRivals": MessageLookupByLibrary.simpleMessage(
      "Салыстыратын басқа сервер жоқ",
    ),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "Қолжетімді серверлер жоқ",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage(
      "Серверлерді тексеру",
    ),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("UDP жоқ"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m102,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage(
      "Жалпы мақсаттағы",
    ),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттауды қосыңыз — ол серверлерді өзі таңдап береді",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау қосулы",
    ),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage(
      "Бағыттау шолуы",
    ),
    "smartRoutingPacing": MessageLookupByLibrary.simpleMessage("Қарқын"),
    "smartRoutingPacingDesc": MessageLookupByLibrary.simpleMessage(
      "Қозғалтқыштың реакция жылдамдығы және тексерулерге сенім мерзімі",
    ),
    "smartRoutingPercent": m103,
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желісіне кіру қажет",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage(
      "Дайын баптаулар",
    ),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("Қытай"),
    "smartRoutingPresetEdited": m104,
    "smartRoutingPresetEgypt": MessageLookupByLibrary.simpleMessage("Мысыр"),
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Басқа"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Ресей"),
    "smartRoutingProbeBudget": m105,
    "smartRoutingProbes": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік тексерулері",
    ),
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Өлшеу"),
    "smartRoutingProofTtl": MessageLookupByLibrary.simpleMessage(
      "Растаудың жарамдылық мерзімі",
    ),
    "smartRoutingProofTtlDesc": MessageLookupByLibrary.simpleMessage(
      "Қайта тексергенге дейін өткен тексеру серверді қанша уақыт расталған етіп сақтайды",
    ),
    "smartRoutingProvenNo": MessageLookupByLibrary.simpleMessage("Әзірге жоқ"),
    "smartRoutingProvenYes": MessageLookupByLibrary.simpleMessage("Иә"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "Провайдер қорғанысының іске қосылуы",
    ),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage(
      "Реттеу реті",
    ),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage("Реттеу"),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "Кідіріс жолақтары бекітілген: мұнда реттеу болса, миллисекунд сервердің жұмыс істеп тұрғанынан басым түсер еді",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "Бұл желідегі алғашқы таңдау",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы сервер трафик өткізбей қойды",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "Ауысу алдында орнығу уақыты күтілуде",
    ),
    "smartRoutingReasonHandoffRecovery": MessageLookupByLibrary.simpleMessage(
      "Желі ауысқаннан кейін байланыс қалпына келді",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істеп тұр, жақсырағы табылмады",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы сервер жауап беруді доғарды",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "Қайталанған тексерулер кідірістің төмен екенін растады",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "Сіз таңдаған сервер ұсталуда",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "Ауысу алдында жаңа сервер тексерілуде",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "Ешбір сервер тексеруден өтпеді",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "Сіз таңдаған сервер қайтадан жұмыс істеп тұр",
    ),
    "smartRoutingReasonQualityConfirming": MessageLookupByLibrary.simpleMessage(
      "Қайта салыстыру арқылы жақсаруды растап жатырмыз",
    ),
    "smartRoutingReasonReliabilityGain": MessageLookupByLibrary.simpleMessage(
      "Қайталанған тексерулер тұрақтырақ баламаны растады",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Қолжетімді ештеңе жоқ, ағымдағы сервер ұсталады",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "Желі өзгерді",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "Ашық интернетке шыға алатыны дәлелденген",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage(
      "Қазір тексеру",
    ),
    "smartRoutingRecurrenceFloor": MessageLookupByLibrary.simpleMessage(
      "Қайталану шегі",
    ),
    "smartRoutingRecurrenceFloorDesc": MessageLookupByLibrary.simpleMessage(
      "Осы эпизодтан аз сәтсіздіктер серверге әлі теріс әсер етпейді",
    ),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("Өңір"),
    "smartRoutingRegionCard": MessageLookupByLibrary.simpleMessage(
      "Бұл аймақ қалай жұмыс істейді",
    ),
    "smartRoutingRegionCardDesc": MessageLookupByLibrary.simpleMessage(
      "Аймақ нені орнатады және серверлерді қалай таңдайды",
    ),
    "smartRoutingRegionEditNote": MessageLookupByLibrary.simpleMessage(
      "Мұның бәрін кеңейтілген параметрлерде өзгертуге болады",
    ),
    "smartRoutingRegionHow": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау жұмыс істеп тұрған серверді ұстап, қалғандарын фонда тексереді әрі ашық интернетке жететін жылдамдарын артық көреді. Төмендегі аймақ осы тексерулерді орнатады; желіңіз өзгеше болмаса, өзгертпеңіз.",
    ),
    "smartRoutingRegionNote": MessageLookupByLibrary.simpleMessage(
      "Қолданбада таңдалған аймақ бойынша қойылған; тек желіңіз талап етсе өзгертіңіз",
    ),
    "smartRoutingRegionSeeds": MessageLookupByLibrary.simpleMessage(
      "Бұл аймақ нені орнатады",
    ),
    "smartRoutingRegionUnused": MessageLookupByLibrary.simpleMessage(
      "Бұл аймақта қолданылмайды",
    ),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "UDP қолдауын талап ету",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Қоңырау мен ойындарды көтере алмайтын серверлер ескерілмейді",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "Шектеулі желі · жергілікті қызметтер тікелей жұмыс істейді",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "Сервер жауап бермейді, басқасы ізделуде",
    ),
    "smartRoutingRuleAction": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "smartRoutingRuleAdd": MessageLookupByLibrary.simpleMessage("Ереже қосу"),
    "smartRoutingRuleCountry": MessageLookupByLibrary.simpleMessage("Шығу елі"),
    "smartRoutingRuleCountryDesc": MessageLookupByLibrary.simpleMessage(
      "Өлшенген шығу елі, екі әріптік код",
    ),
    "smartRoutingRuleGroup": MessageLookupByLibrary.simpleMessage("Топ"),
    "smartRoutingRuleGroupDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер жататын прокси тобы",
    ),
    "smartRoutingRuleIgnore": MessageLookupByLibrary.simpleMessage("Елемеу"),
    "smartRoutingRuleIgnoreDesc": MessageLookupByLibrary.simpleMessage(
      "Сәйкес серверлерді ешқашан пайдаланбау",
    ),
    "smartRoutingRuleLastResort": MessageLookupByLibrary.simpleMessage(
      "Амалсыздан",
    ),
    "smartRoutingRuleLastResortDesc": MessageLookupByLibrary.simpleMessage(
      "Басқа ешнәрсе жұмыс істемегенде ғана сәйкес серверлерді пайдалану",
    ),
    "smartRoutingRuleMatchAny": MessageLookupByLibrary.simpleMessage(
      "Кез келген серверге сәйкес",
    ),
    "smartRoutingRuleMatchHint": MessageLookupByLibrary.simpleMessage(
      "Ескермеу үшін өрісті бос қалдырыңыз; ереже барлық толтырылған өрістер сәйкес келгенде ғана іске қосылады",
    ),
    "smartRoutingRuleName": MessageLookupByLibrary.simpleMessage(
      "Атауы қамтиды",
    ),
    "smartRoutingRuleNameDesc": MessageLookupByLibrary.simpleMessage(
      "Атауында осы мәтін бар серверлерге сәйкес келу",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "Тек Ереже режимінде қолжетімді",
    ),
    "smartRoutingRulePrefer": MessageLookupByLibrary.simpleMessage(
      "Артық көру",
    ),
    "smartRoutingRulePreferDesc": MessageLookupByLibrary.simpleMessage(
      "Сәйкес серверлер сау болғанда оларға артықшылық беру",
    ),
    "smartRoutingRuleProvider": MessageLookupByLibrary.simpleMessage(
      "Провайдер",
    ),
    "smartRoutingRuleProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер алынған жазылым",
    ),
    "smartRoutingRules": MessageLookupByLibrary.simpleMessage(
      "Сервер ережелері",
    ),
    "smartRoutingRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Серверлерді атауы, провайдері немесе өлшенген елі бойынша елемеу, тежеу немесе артық көру",
    ),
    "smartRoutingRungOff": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "smartRoutingRungVersus": m106,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Сервер таңдалуда…",
    ),
    "smartRoutingSeconds": m107,
    "smartRoutingSectionEngine": MessageLookupByLibrary.simpleMessage(
      "Механизм",
    ),
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage(
      "Серверлер",
    ),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "Бұрынғы ауысулар",
    ),
    "smartRoutingSectionLadder": MessageLookupByLibrary.simpleMessage(
      "Серверлер қалай салыстырылады",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("Желі"),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "Сенімділік",
    ),
    "smartRoutingSectionRivals": MessageLookupByLibrary.simpleMessage(
      "Таңдалған серверге қарсы",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("Шешім"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("Серверлер"),
    "smartRoutingServersCount": m108,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "Кез келген провайдер",
    ),
    "smartRoutingServiceCandidates": m109,
    "smartRoutingServiceEnabled": MessageLookupByLibrary.simpleMessage(
      "Сервис бағытын пайдалану",
    ),
    "smartRoutingServiceEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "Сервисті сәйкес арнайы сервер арқылы жіберу",
    ),
    "smartRoutingServiceFallback": MessageLookupByLibrary.simpleMessage(
      "Арнайы сервер қолжетімсіз болса",
    ),
    "smartRoutingServiceFallbackActiveMain":
        MessageLookupByLibrary.simpleMessage(
          "Арнайы сервер дайын емес · негізгі маршрут",
        ),
    "smartRoutingServiceFallbackActiveReject":
        MessageLookupByLibrary.simpleMessage(
          "Арнайы сервер дайын емес · сервис бұғатталды",
        ),
    "smartRoutingServiceFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Арнайы серверлер жоқ кезде жасырын сервис тобы қолданатын бағыт",
    ),
    "smartRoutingServiceFallbackMain": MessageLookupByLibrary.simpleMessage(
      "Smart Routing негізгі серверін пайдалану",
    ),
    "smartRoutingServiceFallbackReject": MessageLookupByLibrary.simpleMessage(
      "Сервисті бұғаттау",
    ),
    "smartRoutingServiceGemini": MessageLookupByLibrary.simpleMessage(
      "Gemini қолжетімділігі",
    ),
    "smartRoutingServiceManual": MessageLookupByLibrary.simpleMessage(
      "Қолмен берілген белгілер",
    ),
    "smartRoutingServiceManualEmpty": MessageLookupByLibrary.simpleMessage(
      "Қолмен берілген белгілер жоқ",
    ),
    "smartRoutingServiceManualEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Атау бөлігін және қажет болса провайдерді қосыңыз",
    ),
    "smartRoutingServiceManualSelector": MessageLookupByLibrary.simpleMessage(
      "Арнайы сервердің қолмен берілген белгісі",
    ),
    "smartRoutingServiceMatchedNone": MessageLookupByLibrary.simpleMessage(
      "Әзірге сәйкес сервер жоқ",
    ),
    "smartRoutingServiceNameContains": MessageLookupByLibrary.simpleMessage(
      "Атау құрамында",
    ),
    "smartRoutingServiceNameContainsDesc": MessageLookupByLibrary.simpleMessage(
      "Регистрді ескеретін сервер атауының бөлігі",
    ),
    "smartRoutingServiceNoCandidates": MessageLookupByLibrary.simpleMessage(
      "Арнайы сервер белгілері жоқ",
    ),
    "smartRoutingServicePending": MessageLookupByLibrary.simpleMessage(
      "Движок күтілуде",
    ),
    "smartRoutingServiceProvider": m110,
    "smartRoutingServiceProviderCandidates": m111,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Провайдердің дәл атауы; кез келгені үшін бос қалдырыңыз",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "Провайдер (міндетті емес)",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "Жазылым манифесі",
    ),
    "smartRoutingServiceReady": m112,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("Бағыт"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage(
      "Сервис бағыттары",
    ),
    "smartRoutingServiceRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған қолданбаларға қозғалтқыш арқылы жеке жол беріңіз",
    ),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "Сервис бағыттары бапталмаған",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage(
      "Белгілер көздері",
    ),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage("Күй"),
    "smartRoutingServiceTokenTooLong": m113,
    "smartRoutingServiceVia": m114,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "Жарнамасыз YouTube",
    ),
    "smartRoutingSignals": MessageLookupByLibrary.simpleMessage("Сигналдар"),
    "smartRoutingSignalsDesc": MessageLookupByLibrary.simpleMessage(
      "Қозғалтқыш әр түйінді неге қарап бағалайды",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "Жылы резерв арқылы қалпына келтірілді",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Кім өтетінін шешті",
    ),
    "smartRoutingStepAdmitBody": m115,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage(
      "Осында тоқтады",
    ),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage(
      "Желіні анықтады",
    ),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage(
      "Қалғандарын реттеді",
    ),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "Екі сервер алғаш өзгешеленген жол шешеді",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage(
      "Қарапайым",
    ),
    "smartRoutingStrategyBalancedDesc": MessageLookupByLibrary.simpleMessage(
      "Бәріне жарайды — сенімді болмасаңыз, осыны қалдырыңыз",
    ),
    "smartRoutingStrategyEdited": m116,
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "Жылдамдық",
    ),
    "smartRoutingStrategyLowestLatencyDesc":
        MessageLookupByLibrary.simpleMessage(
          "Жұмыс істейтін серверлердің ішінен ең жылдамын таңдайды",
        ),
    "smartRoutingStrategyPace": MessageLookupByLibrary.simpleMessage(
      "Қарқынды белгілейді",
    ),
    "smartRoutingStrategySaver": MessageLookupByLibrary.simpleMessage(
      "Үнемдеу",
    ),
    "smartRoutingStrategySaverDesc": MessageLookupByLibrary.simpleMessage(
      "Серверлерді сирек тексереді, трафик пен батареяны үнемдейді",
    ),
    "smartRoutingStrategyStable": MessageLookupByLibrary.simpleMessage(
      "Тұрақтылық",
    ),
    "smartRoutingStrategyStableDesc": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істеп тұрған серверді сақтайды және оны сирек ауыстырады",
    ),
    "smartRoutingSwitchImproveMs": MessageLookupByLibrary.simpleMessage(
      "Кемінде осыншама жылдам",
    ),
    "smartRoutingSwitchImproveMsDesc": MessageLookupByLibrary.simpleMessage(
      "Бәсекелес жылдамдықпен жеңу үшін қолданыстағы серверден осынша миллисекунд озуы керек",
    ),
    "smartRoutingSwitchImprovePct": MessageLookupByLibrary.simpleMessage(
      "Кемінде осыншама жылдам (үлес)",
    ),
    "smartRoutingSwitchImprovePctDesc": MessageLookupByLibrary.simpleMessage(
      "Бәсекелес жылдамдықпен жеңу үшін қолданыстағы серверден осы үлеске де озуы керек",
    ),
    "smartRoutingSwitchLine": m117,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("ауыстырылды"),
    "smartRoutingSwitchedAgo": m118,
    "smartRoutingTabDetails": MessageLookupByLibrary.simpleMessage(
      "Толық мәлімет",
    ),
    "smartRoutingTabOverview": MessageLookupByLibrary.simpleMessage("Шолу"),
    "smartRoutingTabRanking": MessageLookupByLibrary.simpleMessage("Іріктеу"),
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage(
      "Техникалық мәлімет",
    ),
    "smartRoutingTiedAll": MessageLookupByLibrary.simpleMessage(
      "Барлық жолда бірдей",
    ),
    "smartRoutingTriggerAuto": MessageLookupByLibrary.simpleMessage(
      "Стратегия әдепкісі",
    ),
    "smartRoutingTriggers": MessageLookupByLibrary.simpleMessage(
      "Ауысу шарттары",
    ),
    "smartRoutingTriggersDesc": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істеп тұрған серверден кетер алдында бәсекелес қаншалық жақсы болуы керек",
    ),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage(
      "тексерілмеген",
    ),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "Соңғы амал",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "Ашық интернетке жетеді",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage(
      "Қолдануға жарамсыз",
    ),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage(
      "Қолдануға жарамды",
    ),
    "smartRoutingVocabBlockGroup": MessageLookupByLibrary.simpleMessage(
      "Қақпалар",
    ),
    "smartRoutingVocabDefault": m119,
    "smartRoutingVocabDuplicate": MessageLookupByLibrary.simpleMessage(
      "Басқа жазба осылай оқылып тұр",
    ),
    "smartRoutingVocabEmpty": MessageLookupByLibrary.simpleMessage(
      "Белгі бос болмайды",
    ),
    "smartRoutingVocabEvidenceGroup": MessageLookupByLibrary.simpleMessage(
      "Дәлел",
    ),
    "smartRoutingVocabOriginGroup": MessageLookupByLibrary.simpleMessage(
      "Шығу тегі",
    ),
    "smartRoutingVocabReasonGroup": MessageLookupByLibrary.simpleMessage(
      "Ауысу себептері",
    ),
    "smartRoutingVocabRename": MessageLookupByLibrary.simpleMessage(
      "Белгіні қайта атау",
    ),
    "smartRoutingVocabRungGroup": MessageLookupByLibrary.simpleMessage(
      "Салыстыру қадамдары",
    ),
    "smartRoutingVocabVerdictGroup": MessageLookupByLibrary.simpleMessage(
      "Шешімдер",
    ),
    "smartRoutingVocabulary": MessageLookupByLibrary.simpleMessage("Сөздік"),
    "smartRoutingVocabularyDesc": MessageLookupByLibrary.simpleMessage(
      "Студия себептер, қақпалар мен қадамдарға қолданатын сөздерді өзгертіңіз. Өзгеріс осы құрылғыда қалады және қозғалтқыштың сервер тәртібіне әсер етпейді.",
    ),
    "smartRoutingWaitingNetwork": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау желіні күтуде",
    ),
    "smartRoutingWaitingTunnel": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау қосулы · туннельді күтуде",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage(
      "Бір тексерудегі сервер саны",
    ),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "Бір фондық тексеру қанша серверді өлшейді",
    ),
    "smartRoutingWaveNodes": m120,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Байланыс тексерісі",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Неліктен"),
    "smartRoutingWinsAt": m121,
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS порты"),
    "sort": MessageLookupByLibrary.simpleMessage("Сұрыптау"),
    "source": MessageLookupByLibrary.simpleMessage("Дереккөз"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("Бастапқы код"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Бастапқы IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Арнайы прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Арнайы ережелер"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Жылдамдық статистикасы",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Бөлу стратегиясы"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Бөлу стратегиясы бос болмауы тиіс",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("Стек режимі"),
    "standard": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартты режим: негізгі конфигурацияны қайта жазады және қарапайым ережелер қосуға мүмкіндік береді",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Іске қосу"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN іске қосылуда…"),
    "status": MessageLookupByLibrary.simpleMessage("Күй"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Өшірілгенде жүйелік DNS қолданылады",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Тоқтату"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN тоқтатылуда…"),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Ішкі ереже"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Ішкі ереже бос"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Ішкі ереже бос болмауы тиіс",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Жіберу"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("Жазылыс"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("Авто"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("Қолмен"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданба жазылысты осы клиенттің пішімінде сұрайды",
    ),
    "subscriptionClientExperimentalLabel": MessageLookupByLibrary.simpleMessage(
      "Тәжірибелік",
    ),
    "subscriptionClientExperimentalTip": MessageLookupByLibrary.simpleMessage(
      "Басқа клиенттермен үйлесімділік — тәжірибелік мүмкіндік: провайдер таңдалған клиент пішімін береді, ReClash оны түрлендіреді.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage(
      "Клиент пішімі",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionConfigInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылымның конфигурациясы жарамсыз және қолданыла алмайды. Провайдердің қолдау қызметіне хабарласыңыз.",
    ),
    "subscriptionConfigurationSource": MessageLookupByLibrary.simpleMessage(
      "берілген конфигурация",
    ),
    "subscriptionDirectRetryConfirm": MessageLookupByLibrary.simpleMessage(
      "Тікелей қайталау",
    ),
    "subscriptionDirectRetryMessage": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы қосылым арқылы жазылымға қол жеткізу мүмкін болмады. VPN-ді өшірмей, осы жүктеуді тікелей қайталау керек пе? Панель желіңіздің IP мекенжайын көреді. Қалған трафиктің бағыты өзгермейді.",
    ),
    "subscriptionDirectRetryTitle": MessageLookupByLibrary.simpleMessage(
      "VPN-ді айналып өтіп қайталау керек пе?",
    ),
    "subscriptionDomainMoved": m122,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі аяқталды",
    ),
    "subscriptionExpiresInDays": m123,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі бүгін аяқталады",
    ),
    "subscriptionFaultClient": MessageLookupByLibrary.simpleMessage(
      "Мәселе осы құрылғыда",
    ),
    "subscriptionFaultClientDesc": MessageLookupByLibrary.simpleMessage(
      "VPN немесе туннель толық белсенді емес. Қайта қосылып, содан кейін есепті қайтадан жасаңыз.",
    ),
    "subscriptionFaultInconclusive": MessageLookupByLibrary.simpleMessage(
      "Бірыңғай себеп анық емес",
    ),
    "subscriptionFaultInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "Деректер бір жақты анық көрсетпейді. Бәрібір есепті сақтаңыз — жиынтық көрсеткіштер провайдерге көмектеседі.",
    ),
    "subscriptionFaultServer": MessageLookupByLibrary.simpleMessage(
      "Мәселе провайдерде сияқты",
    ),
    "subscriptionFaultServerDesc": MessageLookupByLibrary.simpleMessage(
      "Желіңіз дұрыс болса да, түйіндер жекелеген шығыстарда жаппай істен шығуда. Бұл есепті провайдеріңізге жіберіңіз.",
    ),
    "subscriptionFaultSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылым жаңартылмады",
    ),
    "subscriptionFaultSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны жүктеу немесе талдау мүмкін болмады. Бұл есепті провайдеріңізге жіберіңіз — ол жүктеу немесе панель жағын көрсетеді.",
    ),
    "subscriptionFaultUnknown": MessageLookupByLibrary.simpleMessage(
      "Әзірге дерек жеткіліксіз",
    ),
    "subscriptionFaultUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "Қосылымды біраз пайдаланып, содан кейін нақтырақ қорытынды үшін есепті қайтадан жасаңыз.",
    ),
    "subscriptionFaultYourNetwork": MessageLookupByLibrary.simpleMessage(
      "Мәселе сіздің желіңізде",
    ),
    "subscriptionFaultYourNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик провайдерге жетпей тұрып бұғатталуда немесе желі офлайн. Wi-Fi, мобильді интернет немесе captive-порталды тексеріңіз.",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Жазылыс туралы ақпарат",
    ),
    "subscriptionLoopbackWarning": MessageLookupByLibrary.simpleMessage(
      "Профиль мекенжайы ReClash қолданбасының өз прокси портына сілтейді. Жазылым сілтемесін тексеріңіз.",
    ),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылыс не трафик лимітін, не аяқталу мерзімін хабарламайды",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Жазылыс ескертулері",
    ),
    "subscriptionProviderInterval": m124,
    "subscriptionReport": MessageLookupByLibrary.simpleMessage("Жазылым есебі"),
    "subscriptionReportConfirm": MessageLookupByLibrary.simpleMessage(
      "Тек анонимдендірілген диагностика — жазылым URL мекенжайы, түйіндердің нақты атаулары мен мекенжайларынсыз. Ақау себебін анықтауға көмектесу үшін оны провайдеріңізбен бөлісіңіз.",
    ),
    "subscriptionReportCopied": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферіне көшірілді",
    ),
    "subscriptionReportCopyCode": MessageLookupByLibrary.simpleMessage(
      "R1 кодын көшіру",
    ),
    "subscriptionReportCopyLink": MessageLookupByLibrary.simpleMessage(
      "Есеп сілтемесін көшіру",
    ),
    "subscriptionReportFlaggedNodes": MessageLookupByLibrary.simpleMessage(
      "Проблемалы түйіндер",
    ),
    "subscriptionReportGenerating": MessageLookupByLibrary.simpleMessage(
      "Есеп жасалуда…",
    ),
    "subscriptionReportRuntimeDials": MessageLookupByLibrary.simpleMessage(
      "Қосылымдар",
    ),
    "subscriptionReportSave": MessageLookupByLibrary.simpleMessage(
      "JSON сақтау",
    ),
    "subscriptionReportSend": MessageLookupByLibrary.simpleMessage(
      "Провайдерге жіберу",
    ),
    "subscriptionReportUpdateFailures": MessageLookupByLibrary.simpleMessage(
      "Жаңарту ақаулары",
    ),
    "subscriptionTrafficLow": m125,
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "Жазылымда қалыпты түйін мекенжайлары табылмады. Панель уақытша бос конфигурация қайтарған болуы мүмкін. Серверлерге қосылу тексерілмеді.",
    ),
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("Жаңартылды"),
    "support": MessageLookupByLibrary.simpleMessage("Қолдау"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхрондау"),
    "system": MessageLookupByLibrary.simpleMessage("Жүйе"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Жүйелік қолданбалар"),
    "systemColor": MessageLookupByLibrary.simpleMessage("Жүйе түсін қолдану"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "Акцент түсін ОЖ-ден алу (Material You)",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Жүйелік прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Жүйелік прокси серверін орнату",
    ),
    "systemSeed": MessageLookupByLibrary.simpleMessage("Жүйе негізі"),
    "tab": MessageLookupByLibrary.simpleMessage("Қойынды"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Қойынды анимациясы"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Тек мобильдік көріністе жұмыс істейді",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Рұқсат беру үшін түртіңіз",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage(
      "Параллельді TCP қосылымдары",
    ),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Параллельді TCP қосылымдарына рұқсат беру",
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
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Қараңғы режимді қосу және түстерді реттеу",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Тақырып режимі"),
    "tight": MessageLookupByLibrary.simpleMessage("Тығыз"),
    "time": MessageLookupByLibrary.simpleMessage("Уақыт"),
    "timeout": MessageLookupByLibrary.simpleMessage("Күту уақыты"),
    "tip": MessageLookupByLibrary.simpleMessage("Кеңес"),
    "tk": MessageLookupByLibrary.simpleMessage("Түрікменше"),
    "toggle": MessageLookupByLibrary.simpleMessage("Қосу/Өшіру"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("Жазуларды ауыстыру"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тоналды"),
    "tools": MessageLookupByLibrary.simpleMessage("Құралдар"),
    "toolsCategoryApplication": MessageLookupByLibrary.simpleMessage(
      "Қолданба баптаулары",
    ),
    "toolsCategoryConfiguration": MessageLookupByLibrary.simpleMessage(
      "Конфигурация",
    ),
    "toolsCategoryDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Диагностика",
    ),
    "toolsCategoryInfo": MessageLookupByLibrary.simpleMessage(
      "Мәлімет және жөндеу",
    ),
    "toolsNoResults": MessageLookupByLibrary.simpleMessage("Ештеңе табылмады"),
    "toolsOverview": MessageLookupByLibrary.simpleMessage("Шолу"),
    "toolsSearchHint": MessageLookupByLibrary.simpleMessage("Құралдарды іздеу"),
    "toolsSearchResultsCount": m126,
    "toolsSelectPanePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Оны осы жерде көру үшін параметрді таңдаңыз.",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Трафикті толтыру"),
    "torch": MessageLookupByLibrary.simpleMessage("Қолшам"),
    "total": MessageLookupByLibrary.simpleMessage("Барлығы"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Жалпы трафик"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy порты"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficFreeOfTotal": m127,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Трафик шығыны"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash әртүрлі елдердің адамдары пайдалана алатындай сіздің тіліңізде сөйлейді. Қандай да бір сөз тіркесі көзге оғаш көрінсе — жазыңыз, түзетеміз.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Аударма түзетуін ұсыну",
    ),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Сенімді желілер"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "Осы желілердің кез келгеніне қосылғанда VPN кідіртіледі",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі сенімді — VPN кідірілген",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Тек әкімші режимінде ғана қолданылады",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Өшіру"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Қосу"),
    "undo": MessageLookupByLibrary.simpleMessage("Кері қайтару"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Бірыңғай кідіріс"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Қол алысу сияқты қосымша кідірістерді алып тастау",
    ),
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
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Жаңартуды жүктеу мүмкін болмады",
    ),
    "updateSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылымды жаңарту",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Жүктелген файл зақымдалған",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Жүктеп салу"),
    "upstream": MessageLookupByLibrary.simpleMessage("Апстрим"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URL арқылы профиль алу"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL-сұлбасы"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Жазылыс қосу"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Жазылыс URL-ы, растағаннан кейін қосылады",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Жабу"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Трейге жасырады, бапталған болса шығады",
    ),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage(
      "Автоматтандыру командалары",
    ),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Tasker, скрипттер, жарлықтар және автоматтандыру үшін",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Қосу"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Туннельді іске қосып, байланысты орнатады",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Ажырату"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Туннельді тоқтатады",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны импорттау",
    ),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "base64-пен кодталған конфигурация файлы, профиль ретінде импортталады",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "Импортталатын деректер base64 пішіміне сәйкес емес",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Профильді орнату",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash пен FlClash түймелері қолданатын үйлесімділік сілтемесі",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Ашу"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Терезені алға шығарады",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Профильдер"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Тоқтатылған болса қосады, істеп тұрса ажыратады",
    ),
    "urlTip": m128,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hosts файлын қолдану"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Жүйелік hosts файлын қолдану",
    ),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Жұмсалған трафик"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "uz": MessageLookupByLibrary.simpleMessage("Өзбекше"),
    "value": MessageLookupByLibrary.simpleMessage("Мән"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Жанды"),
    "view": MessageLookupByLibrary.simpleMessage("Көру"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN баптауларының өзгергені анықталды",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Барлық жүйелік трафикті VpnService арқылы автоматты түрде бағыттау",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер VPN қайта іске қосылғаннан кейін күшіне енеді",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Бұлыңғырлау"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Карточкалардың мөлдір еместігі",
    ),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("Суретті таңдау"),
    "wallpaperDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдалған сурет жазылым фонының орнына қолданылады. Жазылым фонын қайтару үшін жеке фонды өшіріңіз.",
    ),
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
    "wallpaperHeroOpacity": MessageLookupByLibrary.simpleMessage(
      "Басты экран панельдерінің мөлдір еместігі",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Көлденең орналасуы",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG немесе WebP пішіміндегі жарамды суретті таңдаңыз.",
    ),
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрлау"),
    "wallpaperLibraryFull": m129,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Суреттің мөлдір еместігі",
    ),
    "wallpaperOrbOpacity": MessageLookupByLibrary.simpleMessage(
      "Орбтың мөлдір еместігі",
    ),
    "wallpaperProviderPriority": MessageLookupByLibrary.simpleMessage(
      "Провайдер фонына басымдық беру",
    ),
    "wallpaperProviderPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Жеке фон тек провайдер фоны жоқ жазылымдарда көрсетіледі.",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage(
      "Оқуға ыңғайлылық",
    ),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("Суретті жою"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Баптауларды қалпына келтіру",
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
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Тік орналасуы",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV баптаулары",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Веб-бақылау тақтасы"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "zashboard — ядроның өзі қызмет ететін бақылау тақтасы",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "zashboard алғаш рет ашылғанда жүктеледі",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage(
      "Бақылау тақтасын ашу",
    ),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "Веб-бақылау тақтасы ашық тұрғанда сыртқы контроллер қосулы болады",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Ядро әлі бақылау тақтасын қызмет етпей тұр",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Ақ тізім режимі"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Жүйеге жазу"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Алынған уақытты жүйелік сағатпен синхрондау",
    ),
    "yearsAgo": m130,
    "zhCN": MessageLookupByLibrary.simpleMessage("Қытайша (жеңілдетілген)"),
  };
}
