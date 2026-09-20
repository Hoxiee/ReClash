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

  static String m2(time) => "Қосылғаны: ${time}";

  static String m3(code) =>
      "Windows ReClashCore.exe файлын іске қосудан бас тартты (${code} қатесі). Smart App Control немесе AppLocker сияқты қолданба бақылау саясаты қолтаңбасы жоқ қолданбаларды блоктайды; сол саясатта ReClash-ке рұқсат беріңіз немесе саясатты өшіріңіз де, қайталап көріңіз.";

  static String m4(name) =>
      "Қолданба қатарынан екі рет іске қосылуын аяқтай алмады. Циклді тоқтату үшін ${name} профилі таңдаудан алынып тасталды, автоматты баптау жасалмады. Профильді кез келген уақытта қайта таңдай аласыз.";

  static String m5(url) => "${url} сілтемесінен профиль жасағыңыз келе ме?";

  static String m6(date, days) => "${date} бастап · ${days} күн қамту";

  static String m7(count) =>
      "${Intl.plural(count, one: '1 күн бұрын', other: '${count} күн бұрын')}";

  static String m8(count) =>
      "${Intl.plural(count, one: '1 күн қалды', other: '${count} күн қалды')}";

  static String m9(label) => "Таңдалған ${label} жойылсын ба?";

  static String m10(label) => "Бұл ${label} жойылсын ба?";

  static String m11(token) => "${token} қолданба орнатады, алынып тасталады";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'аргумент жоқ', other: '${count} аргумент')}";

  static String m13(token) => "${token} мән қажет";

  static String m14(token) => "${token} опция емес";

  static String m15(token) => "Белгісіз опция ${token}";

  static String m16(count) =>
      "ByeDPI движогын ${count} бағыттау санаты қолданады";

  static String m17(passed, total) => "Саты нәтижесі: ${passed}/${total}";

  static String m18(presets, groups, domains) =>
      "${presets} пресет · ${groups} топ · ${domains} хост";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 домен', other: '${count} домен')}";

  static String m20(count) => "Дайын: ${count} стратегия сынаалды";

  static String m21(count) =>
      "Барлық белгілі стратегияны движок арқылы ${count} хостқа жеке сынаайды; аяқталғаннан кейін ағымдағы стратегия қалпына келеді";

  static String m22(index, total) => "Тестіленуде ${index}, барлығы ${total}";

  static String m23(passed, total) => "${total} хосттың ${passed} жауап береді";

  static String m24(label) => "${label} туралы мәліметтер";

  static String m25(days) => "${days} тәулік";

  static String m26(name) => "${name} орнатылды";

  static String m27(count) =>
      "${count} evidence events were dropped under load; confidence was not increased.";

  static String m28(completed, total) =>
      "Checking connection: ${completed}/${total}";

  static String m29(layer) => "Connection issue: ${layer}";

  static String m30(completed, total) => "Step ${completed} of ${total}";

  static String m31(label) => "${label} бос болмауы керек";

  static String m32(count) =>
      "${Intl.plural(count, one: '1 жазба', other: '${count} жазба')}";

  static String m33(label) => "${label} бұрыннан бар";

  static String m34(action) =>
      "Сыртқы сілтемеге «${action}» әрекетін орындауға рұқсат берілсін бе?";

  static String m35(date) => "${date} табылды";

  static String m36(found, total) => "${total} ішінен ${found} ашылды";

  static String m37(count) => "Тағы ${count} табылмады";

  static String m38(days) => "Келесі белгіге дейін ${days} күн";

  static String m39(name) => "${name} ең соңғы нұсқада тұр";

  static String m40(name) => "${name} жаңартылды";

  static String m41(time) => "${time} бұрын";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 сағат бұрын', other: '${count} сағат бұрын')}";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 сағат', other: '${count} сағат')}";

  static String m44(target) => "${target} — жарамсыз саясат";

  static String m45(proxyName) => "${proxyName} — жарамсыз прокси";

  static String m46(providerName) =>
      "${providerName} — жарамсыз прокси провайдері";

  static String m47(subRule) => "${subRule} — жарамсыз SUB_RULE";

  static String m48(address) =>
      "Немесе телефон браузерінде ${address} мекенжайын ашыңыз";

  static String m49(appName) =>
      "1. Жүйелік баптауларды ашып, «Жекелік және қауіпсіздік» бөліміне өтіңіз\n2. Орналасу қызметтерін таңдаңыз\n3. Тізімнен ${appName} қолданбасын тауып, құсбелгі қойыңыз\n\nДайын болған соң қолданбаға оралыңыз. Ынтымақтастығыңыз үшін рахмет.";

  static String m50(label, max) =>
      "${label} ең көбі ${max} таңбадан аспауы керек";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 минут бұрын', other: '${count} минут бұрын')}";

  static String m52(count) =>
      "${Intl.plural(count, one: '1 ай бұрын', other: '${count} ай бұрын')}";

  static String m53(label) => "Әзірге ${label} жоқ";

  static String m54(label) => "${label} сан болуы керек";

  static String m55(settings) =>
      "Бұл жазылым қолданбаның мына жалпы баптауларын сұрайды:\n${settings}";

  static String m56(label) => "${label} 1024 пен 49151 аралығында болуы керек";

  static String m57(count) =>
      "Профиль импортталды; қолдау көрсетілмейтін ${count} түйін өткізіп жіберілді";

  static String m58(format, client, nodes, groups) =>
      "Импортталды: ${format} · ${client} · ${nodes} түйін · ${groups} топ";

  static String m59(days) => "${days} күн қолданылмады";

  static String m60(months) => "${months} ай қолданылмады";

  static String m61(count) =>
      "${Intl.plural(count, one: '1 прокси', other: '${count} прокси')}";

  static String m62(count) => "Профильдер: ${count}";

  static String m63(count) => "Прокси топтары: ${count}";

  static String m64(count) => "Ережелер: ${count}";

  static String m65(count) => "Сценарийлер: ${count}";

  static String m66(count) =>
      "${Intl.plural(count, one: '1 ереже', other: '${count} ереже')}";

  static String m67(darkAt, lightAt) => "Қараңғы режим: ${darkAt} — ${lightAt}";

  static String m68(count) =>
      "${Intl.plural(count, one: '1 секунд', other: '${count} секунд')}";

  static String m69(count) => "${count} таңдалды";

  static String m70(count) => "${count} профиль дайын";

  static String m71(step, count) => "${count} қадамның ${step}-қадамы";

  static String m72(name) => "Профиль: ${name}";

  static String m73(value) => "Ақылды бағыттау: ${value}";

  static String m74(alive, total) =>
      "Қазір қолжетімді серверлер: ${alive}/${total}";

  static String m75(percent, duration) => "${duration} ішінде ${percent}%";

  static String m76(band) => "жолақ ${band}";

  static String m77(bands) => "Жолақтар: ${bands}";

  static String m78(count) => "${count} сәтсіздіктен кейін салқындап тұр";

  static String m79(answered, total) => "${answered} / ${total} жауап берді";

  static String m80(seconds) => "${seconds} с қалды";

  static String m81(count) => "Қатар келген ${count} сәтсіздік";

  static String m82(step) => "Ұтылған жол: ${step}";

  static String m83(duration) => "${duration} ішінде өлшенді";

  static String m84(measured, total) => "өлшенді: ${measured} / ${total}";

  static String m85(preset) => "${preset} · өзгертілді";

  static String m86(left, cap) =>
      "Осы сағатта қалған өлшеулер: ${left} / ${cap}";

  static String m87(value, against) => "${value} — ${against}";

  static String m88(seconds) => "${seconds} с";

  static String m89(eligible, total) =>
      "${eligible} / ${total} қолдануға жарамды";

  static String m90(count) => "Арнайы сервер белгілері: ${count}";

  static String m91(provider) => "Провайдер: ${provider}";

  static String m92(count) => "Провайдер берген белгілер: ${count}";

  static String m93(eligible, total) => "${total} серверден ${eligible} дайын";

  static String m94(label) => "«${label}» UTF-8 бойынша 64 байттан аспауы тиіс";

  static String m95(node) => "${node} арқылы";

  static String m96(eligible, total, blocked) =>
      "${total} сервердің ішінен ${eligible} өтті, ${blocked} ұсталды";

  static String m97(strategy) => "${strategy} · өзгертілген";

  static String m98(from, to) => "${from} → ${to}";

  static String m99(time) => "${time} бұрын ауыстырылды";

  static String m100(count) => "${count} сервер";

  static String m101(step) => "Жоғары тұрған жол: ${step}";

  static String m102(host) => "Провайдер ${host} мекенжайына көшкен";

  static String m103(count) =>
      "${Intl.plural(count, one: 'Жазылыс мерзімі ертең аяқталады', other: 'Жазылыс мерзімі ${count} күннен кейін аяқталады')}";

  static String m104(value) => "Провайдер ${value} ұсынады";

  static String m105(total) => "${total} ішінен бос";

  static String m106(label) => "${label} URL болуы керек";

  static String m107(count) =>
      "Ең көбі ${count} фон сақтауға болады. Жаңасын қосу үшін біреуін жойыңыз.";

  static String m108(count) =>
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
    "actionMode": MessageLookupByLibrary.simpleMessage("Режимді ауыстыру"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Жүйелік прокси"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Іске қосу/Тоқтату"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("Көрсету/Жасыру"),
    "add": MessageLookupByLibrary.simpleMessage("Қосу"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Желі қосу"),
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
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "LAN арқылы проксиге қосылуға рұқсат беру",
    ),
    "animations": MessageLookupByLibrary.simpleMessage("Анимациялар"),
    "announce": MessageLookupByLibrary.simpleMessage("Хабарландырулар"),
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
    "appIconFacet": MessageLookupByLibrary.simpleMessage("Қыр"),
    "appIconFractal": MessageLookupByLibrary.simpleMessage("Фрактал"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Сия"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("Орнату"),
    "appIconMesh": MessageLookupByLibrary.simpleMessage("Тор"),
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
    "appIconVigil": MessageLookupByLibrary.simpleMessage("Күзет"),
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
    "connectedFor": m2,
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
    "coreBlockedByPolicyTip": m3,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control ReClashCore.exe файлын қолтаңбасы жоқ болғандықтан блоктады. Windows қауіпсіздігі → «Қолданбалар мен браузерді бақылау» → Smart App Control баптауларына өтіп, «Өшірулі» опциясын таңдаңыз да, ReClash-ті қайта іске қосыңыз. Smart App Control-ті қайта қосу үшін Windows-ты қайта орнату керек.",
    ),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Жұмыс істеп тұр"),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Іске қосылуда…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Ядро күйі"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Тоқтатылған"),
    "country": MessageLookupByLibrary.simpleMessage("Өңір"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Құлау анықталды"),
    "crashDetectedTip": m4,
    "crashTest": MessageLookupByLibrary.simpleMessage("Құлау тесті"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Құлау аналитикасы"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "Қосулы болса, қолданба құлағанда сезімтал деректерсіз құлау журналдары автоматты түрде жүктеп жіберіледі",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Жасау"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Профиль жасау"),
    "createProfileFromUrlTip": m5,
    "creationTime": MessageLookupByLibrary.simpleMessage("Жасалу уақыты"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — осы қолданбаның негізі",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — провайдер мүмкіндіктері мен идеялары",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage(
      "mihomo — прокси ядросы",
    ),
    "crownHistory": m6,
    "custom": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("Қиып алу"),
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
    "daysAgo": m7,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("күн"),
    "daysLeft": m8,
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
    "deleteMultipTip": m9,
    "deleteTip": m10,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Бірнеше платформада жұмыс істейтін mihomo клиенті: қайта жасалған бақылау тақтасы, ақылды бағыттау және жазылыстарға толық қолдау. Ашық код, жарнама да, телеметрия да жоқ.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Нысан"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Нысан GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("Нысан IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPI айналып өту"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage(
      "Белсенді стратегия",
    ),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Движок аргументтері"),
    "desyncArgsAppOwnedFlag": m11,
    "desyncArgsCount": m12,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m13,
    "desyncArgsPositional": m14,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "Жабылмаған тырнақша",
    ),
    "desyncArgsUnknownFlag": m15,
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
    "desyncEngineSummary": m16,
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("TCP-ні мәжбүрлеу"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Жоғарыдағы санаттар үшін QUIC блокталады; десинхронизация UDP-ге жетпейді",
    ),
    "desyncLadderResult": m17,
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
    "desyncTestBatterySummary": m18,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("Тест domenдері"),
    "desyncTestDomainsCount": m19,
    "desyncTestDone": m20,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "Движок осы стратегияда құлады",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "Движок істемейді — алдымен DPI айналып өтуді қосып қосылыңыз",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Бұл стратегиядан өтпеген хосттар",
    ),
    "desyncTestHint": m21,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Төменнен кемінде бір домен тізімін таңдаңыз",
    ),
    "desyncTestProgress": m22,
    "desyncTestScore": m23,
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
    "details": m24,
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
    "developerPatinaDays": m25,
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
    "developerSubscriptionInstalled": m26,
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
    "direct": MessageLookupByLibrary.simpleMessage("Тікелей"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP-ні өшіру"),
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
    "doctorEvidenceDropped": m27,
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
    "doctorFresh": MessageLookupByLibrary.simpleMessage("Өзекті"),
    "doctorGenericDesc": MessageLookupByLibrary.simpleMessage(
      "Тексеру қосылым мәселесін тапты, бірақ нақты себебін анықтай алмады.",
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
    "doctorHeroExamining": m28,
    "doctorHeroIssue": m29,
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
    "doctorLimitations": MessageLookupByLibrary.simpleMessage(
      "Бұл нені білдіреді",
    ),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("Deep"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage(
      "No usable evidence yet",
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
    "doctorPassiveHint": MessageLookupByLibrary.simpleMessage(
      "Бұл экранды ашқанда бір тексеру орындалады. Қалған уақытта Дәрігер тек нақты трафикті бақылайды және қосымша желілік әрекет жасамайды.",
    ),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("Қолданба"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("Тексерілуде"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы мәселеден кейін тексерілмеді",
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
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("Қосылым жолы"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("Тексерілмеді"),
    "doctorPortalDesc": MessageLookupByLibrary.simpleMessage(
      "Желіге кірмейінше, интернетке кіру бұғатталады.",
    ),
    "doctorPortalTitle": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желісіне кіру қажет",
    ),
    "doctorProgress": m30,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("Қорғаныс"),
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
    "doctorUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "Update Core to use connection diagnosis.",
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
    "emptyTip": m31,
    "en": MessageLookupByLibrary.simpleMessage("Ағылшынша"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Қолмен енгізу"),
    "entries": MessageLookupByLibrary.simpleMessage(" жазба"),
    "entriesCount": m32,
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
    "existsTip": m33,
    "exit": MessageLookupByLibrary.simpleMessage("Шығу"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Толық экраннан шығу",
    ),
    "expand": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Күтілетін күй"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Жарамдылық мерзімі"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Файлды экспорттау"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "Журналдарды экспорттау",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Экспорт сәтті аяқталды",
    ),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивті"),
    "externalActionConfirmMessage": m34,
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
    "findingDiscoveredOn": m35,
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
    "findingTurn": MessageLookupByLibrary.simpleMessage("Айналым"),
    "findingTurnDesc": MessageLookupByLibrary.simpleMessage(
      "Сеанс Жаңа жыл түн ортасынан өтті.",
    ),
    "findingVigil": MessageLookupByLibrary.simpleMessage("Күзет"),
    "findings": MessageLookupByLibrary.simpleMessage("Табылғандар"),
    "findingsCount": m36,
    "findingsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданылғанда тыныш ашылған бөлшектер",
    ),
    "findingsLocked": m37,
    "findingsMoments": MessageLookupByLibrary.simpleMessage("Сәттер"),
    "findingsNextMilestone": m38,
    "findingsRelics": MessageLookupByLibrary.simpleMessage("Жәдігерлер"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Профиль бойынша"),
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
    "geoSkipped": m39,
    "geoUpdated": m40,
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
    "heroRoutingAgo": m41,
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
    "hidePassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді жасыру"),
    "highPriorityAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Жоғары басымдықпен автоқосу",
    ),
    "highPriorityAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Ертерек іске қосу үшін Windows жоспарлағыш тапсырмасын пайдалану",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Хост жазбаларын қосу"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Пернелер тіркесімі қақтығысы",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Перне тіркесімдерін басқару",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаны пернетақтамен басқару",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("сағат"),
    "hours": MessageLookupByLibrary.simpleMessage("сағат"),
    "hoursAgo": m42,
    "hoursCount": m43,
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
    "invalidPolicy": m44,
    "invalidProxy": m45,
    "invalidProxyProvider": m46,
    "invalidSubRule": m47,
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
    "lanProfileImportAddress": m48,
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
    "locationPermissionGuide": m49,
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
    "maxLengthTip": m50,
    "maximize": MessageLookupByLibrary.simpleMessage("Үлкейту"),
    "memory": MessageLookupByLibrary.simpleMessage("Memory"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Жад ақпараты"),
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
    "minutesAgo": m51,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("минут"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Аралас порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m52,
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
    "none": MessageLookupByLibrary.simpleMessage("Жоқ"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы прокси тобын таңдау мүмкін емес",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі сенімді емес",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Хабарлама"),
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
    "notificationCollapsedLine": MessageLookupByLibrary.simpleMessage(
      "Хабарландыру жиналғанда көрінеді",
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
    "notificationControls": MessageLookupByLibrary.simpleMessage("Басқару"),
    "notificationControlsDesc": MessageLookupByLibrary.simpleMessage(
      "Хабарламадан тікелей қолжетімді әрекеттерді таңдаңыз.",
    ),
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
      "Қызмет хабарламасы ReClash ішінде өшірілген",
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
      "Шымылдықтың төменінде бір тыныш жол қалады, күй жолағында белгіше болмайды",
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
    "notificationOffDesc": MessageLookupByLibrary.simpleMessage(
      "Шымылдықта ештеңе жоқ. Қорғаныс жұмысын жалғастырады, еске салғыштар келеді",
    ),
    "notificationPauseAction": MessageLookupByLibrary.simpleMessage(
      "Кідірту немесе жалғастыру",
    ),
    "notificationPauseActionDesc": MessageLookupByLibrary.simpleMessage(
      "VPN-ді кідірту немесе жалғастыру әрекетін көрсету",
    ),
    "notificationPreviewDoctor": MessageLookupByLibrary.simpleMessage(
      "Қосылым диагностикасы: мәселе жоқ",
    ),
    "notificationPreviewHidden": MessageLookupByLibrary.simpleMessage(
      "Шымылдық бос қалады",
    ),
    "notificationPreviewLocked": MessageLookupByLibrary.simpleMessage(
      "ReClash · Қорғалған мәліметтер жасырылған",
    ),
    "notificationPreviewNetwork": MessageLookupByLibrary.simpleMessage(
      "Желі · Қалыпты",
    ),
    "notificationPreviewPaused": MessageLookupByLibrary.simpleMessage(
      "ReClash · Қорғау кідіртілді",
    ),
    "notificationPreviewProblem": MessageLookupByLibrary.simpleMessage(
      "Қосылым диагностикасы: мәселе анықталды",
    ),
    "notificationPreviewProfile": MessageLookupByLibrary.simpleMessage(
      "ReClash · Ағымдағы профиль",
    ),
    "notificationPreviewRoute": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау · Автоматты бағыт",
    ),
    "notificationPreviewScenario": MessageLookupByLibrary.simpleMessage(
      "Алдын ала көру сценарийі",
    ),
    "notificationPreviewServer": MessageLookupByLibrary.simpleMessage(
      "Сервер · Токио 01",
    ),
    "notificationPreviewSession": MessageLookupByLibrary.simpleMessage(
      "Сеанс · ↓ 1,2 ГБ  ↑ 184 МБ",
    ),
    "notificationPreviewSpeed": MessageLookupByLibrary.simpleMessage(
      "↓ 12,4 МБ/с  ↑ 1,8 МБ/с",
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
    "notificationScenarioLockScreen": MessageLookupByLibrary.simpleMessage(
      "Құлып экраны",
    ),
    "notificationScenarioNormal": MessageLookupByLibrary.simpleMessage(
      "Қалыпты",
    ),
    "notificationScenarioPaused": MessageLookupByLibrary.simpleMessage(
      "Кідіртілді",
    ),
    "notificationScenarioProblem": MessageLookupByLibrary.simpleMessage(
      "Мәселе",
    ),
    "notificationScenarioRouting": MessageLookupByLibrary.simpleMessage(
      "Бағыттау",
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
    "notificationVisibilityOff": MessageLookupByLibrary.simpleMessage(
      "Өшірулі",
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
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Әзірге профильдер жоқ. Алдымен профиль қосыңыз.",
    ),
    "nullTip": m53,
    "numberTip": m54,
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
    "outboundMode": MessageLookupByLibrary.simpleMessage("Шығыс режимі"),
    "override": MessageLookupByLibrary.simpleMessage("Әдепкіні ауыстыру"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS-ті алмастыру"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Қосылғанда профильдегі DNS баптауларының орнына қолданба мәндері қолданылады",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Қайта жазу режимі"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Желі баптауларын алмастыру",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мәндерінің орнына қолданба портын, IPv6, allow-lan, find-process-mode және TUN стегін қолдану",
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
    "panelSettingsConfirmMessage": m55,
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
    "portTip": m56,
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
    "profileImportSkippedNodes": m57,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль импортталды",
    ),
    "profileImportSuccessSummary": m58,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "Импорт сілтемесі зақымдалған немесе қолдау көрсетілмейді",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Профиль атауын енгізіңіз.",
    ),
    "profileUnusedForDays": m59,
    "profileUnusedForMonths": m60,
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
    "proxiesCount": m61,
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
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Таза қара режим"),
    "qrScanUnsupported": MessageLookupByLibrary.simpleMessage(
      "Бұл құрылғыда QR-кодтарды сканерлеуге қолдау көрсетілмейді.",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR коды"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QR кодын сканерлеу арқылы профиль алу",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Жылдам толтыру"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Кемпірқосақ"),
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
    "restoreProfilesCount": m62,
    "restoreProxyGroupsCount": m63,
    "restoreRulesCount": m64,
    "restoreScriptsCount": m65,
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
    "ruleSet": MessageLookupByLibrary.simpleMessage("Ереже жинағы"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Ереже нысаны"),
    "rules": MessageLookupByLibrary.simpleMessage("Ережелер"),
    "rulesCount": m66,
    "save": MessageLookupByLibrary.simpleMessage("Сақтау"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістер сақталсын ба?",
    ),
    "schedule": MessageLookupByLibrary.simpleMessage("Кесте бойынша"),
    "scheduleDesc": m67,
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
    "secondsCount": m68,
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
    "selectedCountTitle": m69,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage(
      "Құрылғы идентификаторын жіберу",
    ),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Құрылғы идентификаторын, қолданба нұсқасын және құрылғы атауын провайдер серверіне жіберу",
    ),
    "sendDeviceIdentityDisableWarning": MessageLookupByLibrary.simpleMessage(
      "HWID жіберуді өшірсеңіз, жазылымдардың көпшілігі жұмыс істемей қалады. Жалғастырасыз ба?",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Сервис"),
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
    "setupProfilesReady": m70,
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
    "setupStepProgress": m71,
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
    "setupSummaryProfile": m72,
    "setupSummaryRouting": m73,
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
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Хабарламадағы тоқтату түймесі",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "Тұрақты хабарламада тоқтату түймесін көрсетеді. Жүйеңіз оның себебінен хабарламаны жайылған күйде ұстап тұрса, өшіріп қойыңыз",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Құпия сөзді көрсету"),
    "shrink": MessageLookupByLibrary.simpleMessage("Ықшам"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Жасырын іске қосу"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Фондық режимде іске қосылады",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Өлшем"),
    "smartPause": MessageLookupByLibrary.simpleMessage("Смарт кідірту"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды жабу",
    ),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "Сенімді желілерде VPN автоматты түрде кідіртіледі",
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
    "smartRoutingAliveCount": m74,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "Барлық серверлер",
    ),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік",
    ),
    "smartRoutingAvailabilityValue": m75,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "Орташа ауысу",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "Орташа қалпына келу",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Автоматты режимге қайту",
    ),
    "smartRoutingBandLabel": m76,
    "smartRoutingBands": m77,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Іс-әрекет"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы сервер тізімінде жоқ",
    ),
    "smartRoutingBlockCooling": m78,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Мұндағы тексеруден өтпеді",
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
    "smartRoutingCanariesAnswered": m79,
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
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage(
      "Цензура қолданатын елдер",
    ),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "Ондағы сервер жергілікті деп саналады, сондықтан өшіру басталғанға дейін ұсталып тұрады",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage(
      "Таңдалған сервер",
    ),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "Әлі сервер таңдалған жоқ",
    ),
    "smartRoutingCoolFor": m80,
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage(
      "Әр серверді тексеру",
    ),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "Өлшеу бюджетіне мән бермейді, сондықтан трафик жұмсайды",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "Әр сервер тексерілуде…",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("Тежелген"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Қолданбаны ашпай-ақ, әр желі үшін жұмыс істейтін сервер дайын тұрады",
    ),
    "smartRoutingDetection": MessageLookupByLibrary.simpleMessage("Анықтау"),
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
    "smartRoutingFails": m81,
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
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage(
      "Соңғы ауысулар",
    ),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Әлі ауысу болған жоқ",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage(
      "кідіріс тестінен",
    ),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage(
      "Анықталған үзілістер",
    ),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage("Үміткер"),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage("Жұмыста"),
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "Смарт бағыттау ағымдағы желіде жұмыс істейтін серверді ұстап тұрады да, желі өзгергенде өз бетінше ауыстырады. Алдымен аймақтық дайын баптаулардан бастаңыз, содан кейін төменде стратегияны, тексерулерді және белгілерді нақтылаңыз.",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("ұсталды"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage(
      "Салыстыруға жіберілген",
    ),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage(
      "Кідіріс жолағы",
    ),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("Дәлелдер"),
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
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "Екі сервер жол-жолмен салыстырылады. Олар алғаш өзгешеленген жол шешеді, одан төмендегілер мүлде оқылмайды.",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage(
      "Соңғы ауысу",
    ),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage(
      "Соңғы қалпына келу",
    ),
    "smartRoutingLostAt": m82,
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
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "Үтірмен бөліп жазыңыз, мысалы 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "HTTP кодтарын үтірмен бөліп енгізіңіз",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage(
      "Сервис тексерулері",
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
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "Ашық интернеттегі тексерулер",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Дәлелденген деп есептелуі үшін сервер осы статустардың бірін қайтаруы керек",
    ),
    "smartRoutingMeasuredOver": m83,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage(
      "Тарифтелген желі",
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
    "smartRoutingNodesMeasured": m84,
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
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желісіне кіру қажет",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage(
      "Дайын баптаулар",
    ),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("Қытай"),
    "smartRoutingPresetEdited": m85,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Басқа"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Ресей"),
    "smartRoutingProbeBudget": m86,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Өлшеу"),
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
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("Өңір"),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "UDP қолдауын талап ету",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Қоңырау мен ойындарды көтере алмайтын серверлер ескерілмейді",
    ),
    "smartRoutingResetSection": MessageLookupByLibrary.simpleMessage(
      "Дайын баптауға қайтару",
    ),
    "smartRoutingResetSectionDesc": MessageLookupByLibrary.simpleMessage(
      "Өңір әдепкілерін қалпына келтіреді және ақылды бағыттауды қосулы қалдырады",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "Шектеулі желі · жергілікті қызметтер тікелей жұмыс істейді",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "Сервер жауап бермейді, басқасы ізделуде",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "Тек Ереже режимінде қолжетімді",
    ),
    "smartRoutingRungVersus": m87,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Сервер таңдалуда…",
    ),
    "smartRoutingSeconds": m88,
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
    "smartRoutingServersCount": m89,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "Кез келген провайдер",
    ),
    "smartRoutingServiceCandidates": m90,
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
    "smartRoutingServiceProvider": m91,
    "smartRoutingServiceProviderCandidates": m92,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Провайдердің дәл атауы; кез келгені үшін бос қалдырыңыз",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "Провайдер (міндетті емес)",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "Жазылым манифесі",
    ),
    "smartRoutingServiceReady": m93,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("Бағыт"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage(
      "Сервис бағыттары",
    ),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "Сервис бағыттары бапталмаған",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage(
      "Белгілер көздері",
    ),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage("Күй"),
    "smartRoutingServiceTokenTooLong": m94,
    "smartRoutingServiceVia": m95,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "Жарнамасыз YouTube",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "Жылы резерв арқылы қалпына келтірілді",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Кім өтетінін шешті",
    ),
    "smartRoutingStepAdmitBody": m96,
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
    "smartRoutingStrategyEdited": m97,
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "Жылдамдық",
    ),
    "smartRoutingStrategyLowestLatencyDesc":
        MessageLookupByLibrary.simpleMessage(
          "Жұмыс істейтін серверлердің ішінен ең жылдамын таңдайды",
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
    "smartRoutingSwitchLine": m98,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("ауыстырылды"),
    "smartRoutingSwitchedAgo": m99,
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
    "smartRoutingWaveNodes": m100,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Байланыс тексерісі",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Неліктен"),
    "smartRoutingWinsAt": m101,
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
    "subscriptionDomainMoved": m102,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі аяқталды",
    ),
    "subscriptionExpiresInDays": m103,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі бүгін аяқталады",
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
    "subscriptionProviderInterval": m104,
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
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Трафикті толтыру"),
    "torch": MessageLookupByLibrary.simpleMessage("Қолшам"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Жалпы трафик"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy порты"),
    "trafficFreeOfTotal": m105,
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
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Жүктелген файл зақымдалған",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Жүктеп салу"),
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
    "urlTip": m106,
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
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Көлденең орналасуы",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG немесе WebP пішіміндегі жарамды суретті таңдаңыз.",
    ),
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрлау"),
    "wallpaperLibraryFull": m107,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Суреттің мөлдір еместігі",
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
    "yearsAgo": m108,
    "zhCN": MessageLookupByLibrary.simpleMessage("Қытайша (жеңілдетілген)"),
  };
}
