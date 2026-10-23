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

  static String m0(count) =>
      "Провайдер VPN-нен тыс қалдыратын қолданбалар: ${count}. Тізімді өзгерту үшін қолжетімділікті басқаруды қосыңыз.";

  static String m1(count, skipped) =>
      "Қосуға ${count} жазба, бұрыннан бар болғандықтан ${skipped} өткізілді";

  static String m2(detail) => "Деректерді тазалау мүмкін болмады: ${detail}";

  static String m3(code) =>
      "Windows ReClashCore.exe файлын іске қосудан бас тартты (${code} қатесі). Smart App Control немесе AppLocker сияқты қолданба бақылау саясаты қолтаңбасы жоқ қолданбаларды блоктайды; сол саясатта ReClash-ке рұқсат беріңіз немесе саясатты өшіріңіз де, қайталап көріңіз.";

  static String m4(name) =>
      "Қолданба қатарынан екі рет іске қосылуын аяқтай алмады. Циклді тоқтату үшін ${name} профилі таңдаудан алынып тасталды, автоматты баптау жасалмады. Профильді кез келген уақытта қайта таңдай аласыз.";

  static String m5(url) => "${url} сілтемесінен профиль жасағыңыз келе ме?";

  static String m6(groups) =>
      "${groups} прокси топтарынан include-all алынып тасталды; олардың қолданатын проксилерін немесе прокси провайдерлерін қосыңыз";

  static String m7(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE ережесі алынып тасталды, өйткені арнайы профильдер ішкі ережелерді қолдамайды', other: '${label} SUB-RULE ережесі алынып тасталды, өйткені арнайы профильдер ішкі ережелерді қолдамайды')}";

  static String m8(message) => "Ядро бұл проксиді талдай алмады: ${message}";

  static String m9(proxy, target) =>
      "${proxy} ${target} арқылы қосылады, бірақ ол жол қайта ${proxy} арқылы өтеді, сондықтан қосылу циклге айналады";

  static String m10(name) =>
      "${name} атауын басқа прокси немесе прокси тобы бұрыннан қолданып жүр";

  static String m11(path) => "Прокси топтары циклде бір-бірін атайды: ${path}";

  static String m12(name) =>
      "Бос қосалқы прокси болуы керек, бірақ ${name} жоқ немесе ол прокси тобы";

  static String m13(name, message) =>
      "${name} — жарамды тұрақты өрнек емес: ${message}";

  static String m14(name) => "Dialer proxy ${name} жоқ";

  static String m15(names) => "Бұл прокси провайдерлері жоқ: ${names}";

  static String m16(names) => "Бұл проксилер немесе саясаттар жоқ: ${names}";

  static String m17(name) =>
      "${name} — кірістірілген саясат атауы, бұл жерде қолданылуы мүмкін емес";

  static String m18(count) =>
      "${count} жазбада мәселе бар, бұл профильді қолдану сәтсіз аяқталуы мүмкін";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 күн бұрын', other: '${count} күн бұрын')}";

  static String m20(count) =>
      "${Intl.plural(count, other: '${count} күн бұрын')}";

  static String m21(label) => "Таңдалған ${label} жойылсын ба?";

  static String m22(label) => "Бұл ${label} жойылсын ба?";

  static String m23(label) => "${label} туралы мәліметтер";

  static String m24(name) =>
      "${name} арқылы қосылу оны қолданған проксиге қайтып оралады, сондықтан байланыс тоқтатылды";

  static String m25(label) => "${label} бос болмауы керек";

  static String m26(label) => "${label} бұрыннан бар";

  static String m27(count) => "${count} жазба сәтсіз аяқталды";

  static String m28(label, message) => "${label}: ${message}";

  static String m29(name) => "${name} ең соңғы нұсқада тұр";

  static String m30(name) => "${name} жаңартылды";

  static String m31(count) =>
      "${Intl.plural(count, one: '1 топ', other: '${count} топ')}";

  static String m32(count) => "${count} уақыты өткен";

  static String m33(action) =>
      "«${action}» үшін қолданылып жүр. Сақтасаңыз, осында ауысады.";

  static String m34(actions) => "Экспортталмады: ${actions}";

  static String m35(modifiers) => "Кемінде ${modifiers} біреуін қосыңыз";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 сағат бұрын', other: '${count} сағат бұрын')}";

  static String m37(count) =>
      "${Intl.plural(count, other: '${count} сағат бұрын')}";

  static String m38(target) => "${target} — жарамсыз саясат";

  static String m39(proxyName) => "${proxyName} — жарамсыз прокси";

  static String m40(providerName) =>
      "${providerName} — жарамсыз прокси провайдері";

  static String m41(ruleSet) => "${ruleSet} — жарамсыз ереже жинағы";

  static String m42(subRule) => "${subRule} — жарамсыз SUB_RULE";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 жазба', other: '${count} жазба')}";

  static String m44(line, message) => "${line}-жол: ${message}";

  static String m45(appName) =>
      "1. Жүйелік баптауларды ашып, «Жекелік және қауіпсіздік» бөліміне өтіңіз\n2. Орналасу қызметтерін таңдаңыз\n3. Тізімнен ${appName} қолданбасын тауып, құсбелгі қойыңыз\n\nДайын болған соң қолданбаға оралыңыз. Ынтымақтастығыңыз үшін рахмет.";

  static String m46(label, max) =>
      "${label} ең көбі ${max} таңбадан аспауы керек";

  static String m47(size) => "${size} босатылды";

  static String m48(count) =>
      "${Intl.plural(count, one: '1 минут бұрын', other: '${count} минут бұрын')}";

  static String m49(count) =>
      "${Intl.plural(count, other: '${count} минут бұрын')}";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 ай бұрын', other: '${count} ай бұрын')}";

  static String m51(count) =>
      "${Intl.plural(count, other: '${count} ай бұрын')}";

  static String m52(code) =>
      "Сервер рұқсат бермеді (HTTP ${code}). Сілтеменің мерзімі біткен немесе деректемелер дұрыс емес болуы мүмкін";

  static String m53(code) => "Сервер сұрауды қабылдамады (HTTP ${code})";

  static String m54(code) =>
      "Бұл мекенжайда ештеңе табылмады (HTTP ${code}). URL дұрыс екенін тексеріңіз";

  static String m55(detail) => "Желі сұрауы сәтсіз аяқталды: ${detail}";

  static String m56(code) =>
      "Серверде ақау шықты (HTTP ${code}). Кейінірек қайталап көріңіз";

  static String m57(label) => "Әзірге ${label} жоқ";

  static String m58(label, min, max) =>
      "${label} ${min} мен ${max} аралығында болуы керек";

  static String m59(label) => "${label} сан болуы керек";

  static String m60(label) => "${label} 1024 пен 49151 аралығында болуы керек";

  static String m61(port) => "Порт ${port}";

  static String m62(added, skipped, failed) =>
      "Қосылды: ${added}; өткізілді: ${skipped}; сәтсіз: ${failed}.";

  static String m63(days) =>
      "${Intl.plural(days, one: '1 күн қалды', other: '${days} күн қалды')}";

  static String m64(date, days) =>
      "Мерзімі бітеді: ${date}, ${Intl.plural(days, one: '1 күн', other: '${days} күн')} қалды";

  static String m65(name) => "«${name}» ретінде қосылған";

  static String m66(client) => "${client} қолданбасы алатындай";

  static String m67(count) => "${Intl.plural(count, other: '${count} сервер')}";

  static String m68(time) => "Жаңартылды: ${time}";

  static String m69(label, profiles) =>
      "${label} әлі де ${profiles} пайдалануда, ол жойылғанда олар дұрыс жұмыс істемей қалады. Шынымен жойғыңыз келе ме?";

  static String m70(count, label) =>
      "${Intl.plural(count, one: '1 прокси', other: '${label} прокси')}";

  static String m71(name, count) => "${name} және басқалары (${count} прокси)";

  static String m72(removed) =>
      "Бұл проксилер жойылады: ${removed}. Атауы өзгерген жол жаңа прокси саналады, ал жойылғандарын атап өтетін арнайы профильдер оларды жоқ деп белгілейді. Бәрібір қолдану керек пе?";

  static String m73(removed, added) =>
      "Бұл проксилер жойылады: ${removed}. Осы қосылады: ${added}. Атауы өзгерген жол жаңа прокси саналады, ал жойылғандарын атап өтетін арнайы профильдер оларды жоқ деп белгілейді. Бәрібір қолдану керек пе?";

  static String m74(label) =>
      "Осы профильдегі ережелер, прокси топтары, dialer проксилер, DNS немесе NTP ${label} атауын әлі қолданады; ол жойылғанда олар тоқтап қалады. Шынымен жойғыңыз келе ме?";

  static String m75(count, label) =>
      "${Intl.plural(count, one: '1 прокси тобы', other: '${label} прокси тобы')}";

  static String m76(pick, now) => "${now} орнына ${pick} таңдайды";

  static String m77(group) => "${group} тексеруі";

  static String m78(pick) => "${pick} қалдырады";

  static String m79(number) => "Шарт ${number}";

  static String m80(profile) => "«${profile}» осы сайттарды тексергісі келеді";

  static String m81(profile) => "«${profile}» жою керек пе?";

  static String m82(requests, used, cap) =>
      "Бүгінгі тексерулер: ${requests} · ${cap} ішінен ${used}";

  static String m83(condition) => "${condition} қоспағанда";

  static String m84(country) => "шығыс ${country}";

  static String m85(member) => "${member} арқылы";

  static String m86(profile) => "«${profile}» қосылды";

  static String m87(node) => "${node} жұмысын тоқтатты";

  static String m88(from, to) => "Режим ${from} → ${to}";

  static String m89(line, text) => "${line}-жол: ${text}";

  static String m90(check) =>
      "${check} тексеруі ешқайда қолданылмайды, сондықтан орындалмайды";

  static String m91(hosts) => "Үшінші тарап сайттарына қосылады: ${hosts}";

  static String m92(group) => "Бұл конфигурацияда ${group} тобы жоқ";

  static String m93(group) =>
      "${group} тобындағы бірде-бір сервер сүзгіден өтпейді";

  static String m94(tag) => "${tag} тегі ешқайда қолданылмайды";

  static String m95(tier, group) =>
      "Қазір ${group} тобындағы бірде-бір сервер «${tier}» ішінде емес";

  static String m96(tier, after) =>
      "«${tier}» «${after}» шартын қайталайды, сондықтан оған ештеңе түспейді";

  static String m97(keys) =>
      "Көшірілді; мыналарды өзіңіз де өзгерткен, сондықтан сіздікі сақталды: ${keys}";

  static String m98(mode) => "Режим: ${mode}";

  static String m99(kind) => "Желі: ${kind}";

  static String m100(tier) =>
      "тексеруден кейін «${tier}» деңгейіне өтуі мүмкін";

  static String m101(node) => "Бекітілген: ${node}";

  static String m102(error) => "Профиль қатесі: ${error}";

  static String m103(profile) =>
      "${profile} профилі табылмады; әдепкісі қолданылады";

  static String m104(error) => "Маршрут күйін сақтау мүмкін болмады: ${error}";

  static String m105(tier) => "«${tier}» серверіне ауысты";

  static String m106(from) =>
      "Сервер ауыстырылды; ${from} 15 минутқа өткізіледі";

  static String m107(from) =>
      "${from} жұмысын тоқтатты; ең жақсы қосалқыға ауысты";

  static String m108(from, gain) =>
      "${from} серверінен ауысты: ${gain} мс жылдамырақ";

  static String m109(node) => "Сценарий ${node} элементін ұстап тұр";

  static String m110(node) => "${node} бұл топта жоқ";

  static String m111(limit) => "Ауыстыру шегіне жетті (сағатына ${limit})";

  static String m112(mode) => "Қолданылмайды: ${mode} режимі";

  static String m113(from) => "${from} енді тізімде жоқ";

  static String m114(kind) =>
      "Желі «${kind}» болғанда кідіртілген: ештеңе тексерілмейді және ауыстырылмайды";

  static String m115(node) => "Сценарий ${node} элементіне ауыстырады";

  static String m116(node) => "Бекітілген ${node} серверіне ауысты";

  static String m117(node) => "Жұмыс істейтін сервер жоқ; ${node} қолданылады";

  static String m118(scenario) =>
      "Қазір бұл топты «${scenario}» сценарийі басқарады.";

  static String m119(count, total) => "${total} ішінен ${count} сәйкес";

  static String m120(node) => "Тексеру растаса, ${node} серверіне ауысады";

  static String m121(node, gain) =>
      "${gain} мс жылдам болып қалса, ${node} серверіне ауысады";

  static String m122(node, minutes) =>
      "${minutes} мин кейін ${node} серверіне ауысуы мүмкін";

  static String m123(name) => "${name} тексеруі";

  static String m124(name) => "${name} желі диагностикасы";

  static String m125(region, bypassed, proxied) =>
      "${region}: VPN айналып өту тізіміне ${bypassed} қолданба, VPN тізіміне ${proxied} қолданба кіреді. Екі тізім де ауыстырылады; режим мен басқа параметрлер өзгермейді. Пакет пен SDK сәйкестігі — тек ұсыныс: қолданғаннан кейін нәтижені тексеріңіз.";

  static String m126(seconds) => "${seconds} секундтан кейін растауға болады";

  static String m127(count, label) =>
      "${Intl.plural(count, one: '1 ереже', other: '${label} ереже')}";

  static String m128(appName) => "${appName} (Қауіпсіз режим)";

  static String m129(count) =>
      "${Intl.plural(count, one: '1 секунд', other: '${count} секунд')}";

  static String m130(count) => "${count} күшіне еніп тұр";

  static String m131(count) =>
      "${Intl.plural(count, one: '1 мәселе', other: '${count} мәселе')}";

  static String m132(time) => "${time} тексерілді";

  static String m133(count) =>
      "${Intl.plural(count, one: '1 баптау', other: '${count} баптау')}";

  static String m134(count) => "VPN-ді айналып өтетін қолданбалар: ${count}";

  static String m135(count) => "Қолжетімді профильдер: ${count}";

  static String m136(step, total) => "${step} / ${total}";

  static String m137(server) => "${server} серверін көру";

  static String m138(link) => "${link} сілтемесінен прокси оқу мүмкін болмады";

  static String m139(label) => "${label} жалғыз жазба болуы керек";

  static String m140(client, format, count) =>
      "${client} ретінде алынды: ${format}, прокси түйіндер саны: ${count}.";

  static String m141(count) =>
      "${Intl.plural(count, one: 'Жазылыс мерзімі ертең аяқталады', other: 'Жазылыс мерзімі ${count} күннен кейін аяқталады')}";

  static String m142(sections) =>
      "Мына бастапқы бөлімдер тасымалданбайды: ${sections}.";

  static String m143(count, format) =>
      "${format} пішімінен ${count} прокси түйінін импорттауға болады.";

  static String m144(count) => "Түрлендірілмейтін түйіндер саны: ${count}.";

  static String m145(percent) => "Трафиктің ${percent}% жұмсалды";

  static String m146(count) => "${count} нәтиже";

  static String m147(value) => "Шың: ${value}";

  static String m148(value) => "Барлығы: ${value}";

  static String m149(version) => "Орнатылған нұсқа: ${version}";

  static String m150(count) => "${count} мин";

  static String m151(time) => "${time} қалды";

  static String m152(count) => "${count} с";

  static String m153(speed) => "${speed}/с";

  static String m154(nodes, groups, providers) =>
      "Прокси: ${nodes}, топтар: ${groups}, қашықтағы провайдерлер: ${providers}";

  static String m155(action) =>
      "Сілтеме «${action}» әрекетін сұрайды. ReClash қолданбасына орындауға рұқсат бересіз бе?";

  static String m156(name, source) =>
      "${source} көзінен «${name}» импортталсын ба? Растаудан кейін профиль мен түрлендіру тексеріледі.";

  static String m157(label) => "${label} URL болуы керек";

  static String m158(index) => "Фон ${index}";

  static String m159(count) =>
      "Ең көбі ${count} фон сақтауға болады. Жаңасын қосу үшін біреуін жойыңыз.";

  static String m160(count) =>
      "${Intl.plural(count, one: '1 жыл бұрын', other: '${count} жыл бұрын')}";

  static String m161(count) =>
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
    "accessProviderDisabledDesc": m0,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды провайдерге қайтару",
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
    "addNetwork": MessageLookupByLibrary.simpleMessage("Желі қосу"),
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
    "appIcon": MessageLookupByLibrary.simpleMessage("Қолданба таңбашасы"),
    "appIconApply": MessageLookupByLibrary.simpleMessage(
      "Осы таңбашаны қолдану",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Сызба"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Басты экранда жаңа таңбаша бірнеше секундтан кейін көрінуі мүмкін. Кейбір лаунчерлер жарлықты жояды — оны қолданбалар тізімінен қайта қосыңыз.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Схема"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Қолданба таңбашасының дизайны",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Жаңғырық"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Сия"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Сынық"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Күн"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Ұшқын"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Қалыпты"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Қабаттар"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Рельеф"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Із"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Барқыт"),
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
    "batchPreviewTip": m1,
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
    "clearDataFailed": m2,
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
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN кідіртілгенде ашық қосылымдардың бәрі үзіледі",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Түс"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Контраст"),
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
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Жоғары"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Орташа"),
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
    "coreBlockedByPolicyTip": m3,
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
    "crashDetectedTip": m4,
    "crashTest": MessageLookupByLibrary.simpleMessage("Құлау тесті"),
    "create": MessageLookupByLibrary.simpleMessage("Жасау"),
    "createProfileFromUrlTip": m5,
    "creationTime": MessageLookupByLibrary.simpleMessage("Жасалу уақыты"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI айналып өту"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Қолданбаның негізі"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Қосымша мүмкіндіктер",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Провайдер мүмкіндіктері мен идеялары",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Прокси ядросы"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Бастау түймесін ұстайды және алынып тасталмайды",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Арнайы"),
    "customColor": MessageLookupByLibrary.simpleMessage("Арнайы түс"),
    "customImportDroppedIncludeAll": m6,
    "customImportDroppedSubRules": m7,
    "customIssueCoreRejected": m8,
    "customIssueDialerLoop": m9,
    "customIssueDuplicateName": m10,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("Атау бос"),
    "customIssueGroupLoop": m11,
    "customIssueInvalidEmptyFallback": m12,
    "customIssueInvalidFilter": m13,
    "customIssueMissingDialer": m14,
    "customIssueMissingProviders": m15,
    "customIssueMissingProxies": m16,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Прокси немесе прокси провайдері таңдалмады, сондықтан ядро осы топты қабылдамайды",
    ),
    "customIssueReservedName": m17,
    "customIssuesSummary": m18,
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
    "daysAgo": m19,
    "daysAgoShort": m20,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("Әдепкі таңдау"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Әдепкі"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Конфигурация атауы мен түрі бар YAML сөздігі болуы керек",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Кідіріс"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Сәтсіз"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Кідіріс сынағы"),
    "delete": MessageLookupByLibrary.simpleMessage("Жою"),
    "deleteMultipTip": m21,
    "deleteTip": m22,
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
    "details": m23,
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
    "dialerProxyLoopStopped": m24,
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
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Барлық DNS қайта анықтаулары жойылып, таңдалған аймақтың DNS серверлері қайта орнатылады.",
    ),
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
    "editNetwork": MessageLookupByLibrary.simpleMessage("Желіні өңдеу"),
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
    "emptyTip": m25,
    "en": MessageLookupByLibrary.simpleMessage("Ағылшынша"),
    "enabled": MessageLookupByLibrary.simpleMessage("Қосулы"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Қолмен енгізу"),
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
    "existsTip": m26,
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
    "extra": MessageLookupByLibrary.simpleMessage("Қосымша"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Өте үлкен"),
    "fade": MessageLookupByLibrary.simpleMessage("Еру"),
    "failedCount": m27,
    "failedItem": m28,
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
    "geoSkipped": m29,
    "geoUpdated": m30,
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
    "groupCount": m31,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("топ"),
    "groupTimeoutCount": m32,
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
    "hotkeyConflictWith": m33,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Жаһандық жылдам пернелер терезе жасырылған кезде де жұмыс істейді. Перне тіркесімін жазу үшін әрекетті түртіңіз.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Жұмыс үстелінің перне тіркесімдері",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Жұмыс үстелінің баптауларында команданы перне тіркесіміне тағайындаңыз. ReClash іске қосулы болуы керек, бірақ терезесі жасырын бола алады. Бұл жаһандық тіркесімдер жұмыс үстелінің баптауларында басқарылады.",
    ),
    "hotkeyExportSkipped": m34,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Композитор конфигурациясының файлдары қолжетімсіз. Жоғарыдағы жұмыс үстелі командаларын қолдана аласыз.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Бұл тіркесімдер қолданба терезесі фокуста болғанда жұмыс істейді. Жаһандық перне тіркесімдері үшін төмендегі бөлімде жұмыс үстелі командаларын баптаңыз.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Перне тіркесімдерін басқару",
    ),
    "hotkeyNeedsModifier": m35,
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
    "hoursAgo": m36,
    "hoursAgoShort": m37,
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
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 немесе 8000-9000 сияқты порт немесе ауқым енгізіңіз",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Бұл QR кодында профиль сілтемесі жоқ",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 немесе 8000-9000 сияқты сандар мен ауқымдарды / арқылы ажыратып енгізіңіз",
    ),
    "invalidRuleSet": m41,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID UTF-8 бойынша 32 байттан аспауы керек",
    ),
    "invalidSubRule": m42,
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
    "itemsCount": m43,
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
    "lineIssueTip": m44,
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
    "locationPermissionGuide": m45,
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
    "maintainer": MessageLookupByLibrary.simpleMessage("Мейнтейнер"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Регистрді ескеру"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Бастапқы IP-ді сәйкестендіру",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. сәтсіздік саны",
    ),
    "maxLengthTip": m46,
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
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("Хабарлама тесті"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Бұл — хабарлама."),
    "minimize": MessageLookupByLibrary.simpleMessage("Кішірейту"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Шығу кезінде кішірейту",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Аралас порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("Тағы"),
    "name": MessageLookupByLibrary.simpleMessage("Атауы"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Төменгі панель",
    ),
    "navigationLabels": MessageLookupByLibrary.simpleMessage(
      "Қойынды белгілері",
    ),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Әрқашан"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Ешқашан"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage(
      "Таңдалған",
    ),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Навигация"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Қойынды тақтасы",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Бүйірлік панель",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Желі"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Сұрау тоқтатылды",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Серверге қосылу мүмкін болмады. Желі байланысыңызды немесе прокси баптауларын тексеріңіз",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Үй Wi-Fi) немесе желі ауқымы (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Сервер мекенжайы анықталмады. URL дұрыс және DNS жұмыс істеп тұрғанын тексеріңіз",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Желі атауы"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Сұраулар тым көп (HTTP 429). Бір сәт күтіп, қайталап көріңіз",
    ),
    "networkRequestFailed": m55,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Айналып өту тізімі мен TUN MTU таңдалған аймақтың әдепкі мәндеріне оралады.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Желі құпиясы"),
    "networkServerError": m56,
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
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі сенімді емес",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Хабарлама"),
    "notificationActive": MessageLookupByLibrary.simpleMessage(
      "Қорғаныс қосулы",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Компонент қосу",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Автоматты топ",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Сервер тобы анықталмаған, сондықтан бұл жол көрсетілмейді",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Хабарлама компоненттері",
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
    "notificationContent": MessageLookupByLibrary.simpleMessage("Мазмұн"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы сервер",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android хабарламасын жеткізу",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android хабарлама рұқсатын тексеру",
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
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Бос кезде жылдамдықты жасыру",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Құлып экранында құпия мәліметтерді жасыру",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Қызмет хабарламалары мен еске салғыштар Android құлып экранының құпиялылық параметрлеріне бағынады. Құлып ашылғанда мәліметтер көрінеді.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Толық режимде ағымдағы ақпарат пен тоқтату түймесі көрсетіледі. Ең аз режимде тек қорғаныс күйі көрсетіледі.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Желі жылдамдығы",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Құпиялылық"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Еске салғыштар",
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
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Толық",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Ең аз",
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
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("Бүркемелеу"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Бүркемелеу хосты"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Бүркемелеу режимі"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Бүркемелеу параметрі"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Бүркемелеу құпиясөзі",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("Қажет болғанда"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Бұл ішкі желі көптеген желілерді сенімді деп санайды",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Қосылымдарды жабу",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Қажет болғанда елемеу Wi-Fi-да проксиді кідіртеді.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("Толық тоқтату"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Кідірту кезінде TUN өшіріліп, жергілікті прокси порттары жабылады. Автоматты жалғастыру үшін желіні бақылау жалғасады.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Кідірту"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Жалғастыру"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi желілерін оқу мүмкін болмады. Қайталаңыз немесе желіні қолмен енгізіңіз.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "SSID мен ішкі желіні бірге талап ету",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Екі түрлі ереже де болса, SSID пен ішкі желі сәйкес келгенде ғана кідірту",
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
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Маңайдағы Wi-Fi желілерін көру үшін геолокацияға рұқсат беріңіз немесе желіні қолмен енгізіңіз.",
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
    "plugin": MessageLookupByLibrary.simpleMessage("Плагин"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Плагин хосты"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Плагин режимі"),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Басқа порт енгізіңіз",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Порт ауысуы"),
    "portTip": m60,
    "portValue": m61,
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
    "profileBatchResult": m62,
    "profileDaysLeft": m63,
    "profileExpiresIn": m64,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль өзгертілді. Автоматты жаңарту өшірілсін бе?",
    ),
    "profileImportAlreadyAdded": m65,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Жазылым тексерілуде…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылым сілтемесі бар профиль қазірдің өзінде бар",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "Жазылым шифрланған — кілт қосу кезінде сұралады.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage(
      "Мерзімі өтті",
    ),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Жазылым форматы",
    ),
    "profileImportFormatClient": m66,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash үшін ең жақсы формат, автоматты түрде таңдалады",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "Провайдерден",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Кейбір бөліктерге қолдау жоқ — қосар алдында оларды көрсетеміз.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Жазылым мазмұнын көру мүмкін болмады. Оны бәрібір қосуға болады.",
    ),
    "profileImportServerCount": m67,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Серверлер"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Бір сервер",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage("Жаңа жазылым"),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Шексіз"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Жарамды мерзімі",
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
    "profileUpdatedAt": m68,
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
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage(
      "Хабарландыру",
    ),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Толығырақ",
    ),
    "providerInUse": m69,
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "Провайдерден",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Провайдерге қайтару",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Баптауларды провайдерге қайтару",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Сіз өзгерткен баптаулар қайтадан жазылымға бағынады",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Тек қашықтағы провайдерлерге қолдау көрсетіледі",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Сыртқы ресурстар"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m70,
    "proxiesProfileLabel": m71,
    "proxiesRemovedTip": m72,
    "proxiesReplacedTip": m73,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Прокси тізбегі"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Прокси тобы"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("Прокси тобы бос"),
    "proxyGroupInUse": m74,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Ядро іске қосылғанда топтар осы жерде пайда болады",
    ),
    "proxyGroupsCount": m75,
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
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Топ қосу"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("Желі түрін қосу"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Үлгі қосу"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Тег қосу"),
    "rcxAddTier": MessageLookupByLibrary.simpleMessage("Басымдық қосу"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Қосымша"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Бұл бөліктер YAML арқылы өңделеді.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Барлық топ"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Кез келген"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("Авто басқару"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Сценарий бүкіл қосылымды басқарады: әр желі түріндегі режимді және әр топтың әрекетін. Сценарий атамаған топтар өз профилі бойынша жұмыс істейді.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("Автоға оралу"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Теңгерімді"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Негізі"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Мінез-құлық"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Өзгерістерді көшіру",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Өз өзгерістеріңіз сақталады",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage(
      "Серверді ауыстыру",
    ),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Тексеру"),
    "rcxCheckDifferent": m76,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Топта"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("Сервер таппайды"),
    "rcxCheckOn": m77,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("бұғатталғанды ашады"),
    "rcxCheckSame": m78,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Тексерулер"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік тексерулері",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Шарт қосу"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Барлық шарттар"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Әрқашан"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Кез келген шарт"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage(
      "Кез келген сервер",
    ),
    "rcxCondClause": m79,
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Өріс"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Регистрді ескермеу",
    ),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Сәйкестік"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Көрсетілмеген"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("емес"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Оператор"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Үлгі"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("Мәтін ретінде"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Бұл шартта топтар кірістірілген, сондықтан мәтін ретінде өңделеді.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Мән"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage("Мәндер үтір арқылы"),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Рұқсат ету"),
    "rcxConsentAsk": m80,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Рұқсат бермейінше, топ «Қарапайым» профилімен жұмыс істейді. Сайттарға тек сіздің серверлеріңіз арқылы немесе желіні тексеру үшін қосылады.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("Рұқсат қажет"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Қосылатын сайттар"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Үшінші тарап сайттары провайдеріңізге де, кірістірілген профильдерге де тиесілі емес.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Басқару"),
    "rcxDeleteProfile": m81,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Желі диагностикасы",
    ),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Тікелей сайттар осы топ арқылы",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage(
      "Қазір қосулы",
    ),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Ережелер тікелей жіберетін сайттар ашылмай қалса, олар осы топ арқылы өтеді. Жергілікті мекенжайлар әрқашан тікелей қалады.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "Күтуде: тікелей сайттар әлі ашылады",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("Көшіріп өңдеу"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Үнемді"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Дәл"),
    "rcxEnergyToday": m82,
    "rcxExcept": m83,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Профильмен шығарылған",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "«Серверді ауыстыру» кейін өткізілген",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage("Тізімде жоқ"),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Ешбір басымдыққа сәйкес емес",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Әлі тексерілмеген",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage(
      "Сервер емес",
    ),
    "rcxExit": m84,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage("Шығу елін тексеру"),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Экспорттау"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Сирек"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Жиі"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Жұмыс істейді"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("Қолданылуда"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Жұмыс істемейді"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Желі диагностикасы"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Кіру елі"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Шығу елі"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage("Тексеруден өтпейді"),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Желі түрі"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Кідіріс, мс"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Өлшенген"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("Лимитті желі"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Атауы"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("Тексеруден өтеді"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Кіру беті"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Провайдер"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("Сервер мекенжайы"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Тег"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage("Байланыс түрі"),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Протокол"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("UDP қолдайды"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Бүкіл топ сервер іздеусіз осы элемент арқылы өтеді; барлығын тапсыру үшін жүктеме тепе-теңдеушісін немесе кірістірілген топты таңдаңыз.",
    ),
    "rcxFixedOn": m85,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("Жалпы"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage("Топ профильдері"),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Смарт-топ серверді қалай таңдайды. Өзіңіздікін өңдеу үшін, басқасының көшірмесін өңдеу үшін түртіңіз.",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Жұмыс істейді"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Жұмыс істемейді"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage(
      "Бұрын жұмыс істеген",
    ),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Тексерілмеген"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("Тарих"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Алдыңғы нұсқалар",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Менің профильдеріме қосу",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Бұл профильді тексеру үшін қолданба ядросын іске қосыңыз.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Маршрутизация профилін импорттау",
    ),
    "rcxImported": m86,
    "rcxJournalFailure": m87,
    "rcxJournalMode": m88,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("тексерілуде"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Бұл желіде олар сценарийдегі аттас топтарды ауыстырады; қалғандары барлық желідегідей жұмыс істейді.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Атауы"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Кіші латын әріптері, сандар және сызықшалар, 24 символға дейін",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("ашық интернет"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("кіру беті"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Анықталады, егер"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Түрлер жоғарыдан төмен қарай тексеріледі; желі орындалған алғашқысын алады.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage("тек ақ тізімдер"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Соңғы мүмкіндік"),
    "rcxLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Соңғы мүмкіндік басымдығы жақсырақ басымдықтарда сервер болмағанда ғана қолданылады.",
    ),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Деңгей"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Кеңейтілген"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Қарапайым"),
    "rcxLine": m89,
    "rcxLintCheckUnused": m90,
    "rcxLintConsent": m91,
    "rcxLintGroupMissing": m92,
    "rcxLintPoolEmpty": m93,
    "rcxLintTagUnused": m94,
    "rcxLintTierEmpty": m95,
    "rcxLintTierUnreachable": m96,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Негізгі топ"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Бұл топты ақылды ету",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash бұл топта жұмыс істейтін серверді таңдап ұстайды және ол істен шыққанда ауыстырады. Тексерулер тек желіні пайдаланған кезде жүреді.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Профильдер мен сценарийлер «Кеңейтілген конфигурация» → «Авто-маршрут» бөлімінде жасалады және өңделеді.",
    ),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "Өзгерістерді көшіру мүмкін болмады",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Өзгерістер көшірілді"),
    "rcxMergedConflicts": m97,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Авто"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Серверлерді профиль бойынша таңдайды және ауыстырады",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Режимді сценарийге қайтару",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "Бұл желідегі режимді сценарий белгілейді",
    ),
    "rcxModeIs": m98,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("Өзгертпеу"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Қолмен"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Сіз таңдайсыз; авто-маршрут ештеңені ауыстырмайды",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Режимді өзіңіз таңдадыңыз; сценарий сіз «Авто» таңдағанша күтеді",
    ),
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "Бұл желіде режим сіздікі",
    ),
    "rcxMoveDown": MessageLookupByLibrary.simpleMessage("Төмен жылжыту"),
    "rcxMoveUp": MessageLookupByLibrary.simpleMessage("Жоғары жылжыту"),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Сіздің рұқсатыңыз қажет",
    ),
    "rcxNetwork": m99,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Желі түрлері"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Жаңа профиль"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Жаңа сценарий"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("Осы желіде"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("өтпейді"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("мыналардың бірі"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("тең"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("тең емес"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("сәйкес келеді"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("сәтті өтеді"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage(
      "Желі бойынша өзгерістер",
    ),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage("Топтың өз профилі"),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "Үлгі дұрыс тұрақты өрнек емес",
    ),
    "rcxPendingTier": m100,
    "rcxPinned": m101,
    "rcxPinnedHint": MessageLookupByLibrary.simpleMessage(
      "Тек істен шыққанда ауысады, қалпына келгенде қайтады",
    ),
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Бекітілген"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Шығару"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Қолдану"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Топта сервер жоқ",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы конфигурацияда бұл топ таңдаушы емес",
    ),
    "rcxProblemProfileInvalid": m102,
    "rcxProblemProfileMissing": m103,
    "rcxProblemStoreFailed": m104,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Атауы"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "Топ пул қалдырған серверлердің ішінен осы профиль бойынша сервер таңдайды.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Бір элементке тапсыру",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Элемент"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Сервер таңдау"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage(
      "Бұл ең жақсы сервер",
    ),
    "rcxReasonBetterTier": m105,
    "rcxReasonChangeServer": m106,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Жақсырақ үміткер тексерілуде",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Жылдамырақ серверді тағы өлшеу керек",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Жақында ауысты; келесісіне дейін күтеді",
    ),
    "rcxReasonFailover": m107,
    "rcxReasonFaster": m108,
    "rcxReasonFixed": m109,
    "rcxReasonFixedMissing": m110,
    "rcxReasonFlapLimit": m111,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Бекітілген сервер сақталады",
    ),
    "rcxReasonIdle": m112,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Ең жақсы қолжетімді сервер таңдалды",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage(
      "Қолмен басқарылады",
    ),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Желі өзгерді",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "Желі істемейтін сияқты; серверлер кінәланбайды",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "Ауысатын басқа жұмыс істейтін сервер жоқ",
    ),
    "rcxReasonOutOfPool": m113,
    "rcxReasonPaused": m114,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Серверді таңдау мүмкін болмады",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Тікелей сайттар қайтадан тікелей өтеді",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Тікелей сайттар енді осы топ арқылы өтеді",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істейтін сервер жоқ; ағымдағысы сақталады",
    ),
    "rcxReasonSwitchFixed": m115,
    "rcxReasonSwitchPinned": m116,
    "rcxReasonSwitchStranded": m117,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Жұмыс істейді; істен шыққанша сақталады",
    ),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Сценарий"),
    "rcxScenarioDrives": m118,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Топтар"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Негізгі топ — соңғы ереже трафикті жіберетін топ; «Барлық топ» осында аталмаған таңдау топтарын қамтиды.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Желілерді тікелей диагностика арқылы анықтап, әрқайсысында режим мен топтарды өзгертіңіз.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("Қосылым режимі"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Сценарийлер"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Сценарий бүкіл қосылымды басқарады. Өзіңіздікін өңдеу үшін, басқасының көшірмесін өңдеу үшін түртіңіз.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Серверлер"),
    "rcxServersMatch": m119,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("Атау үлгісі"),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("Смарт-топтар"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Кіріктірілген"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "Бастапқы профиль өзгерді",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Не өзгерді"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("Провайдерден"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Менікі"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Сервер сәйкес келмесе",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("Тікелей өту"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы серверді сақтау",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Тег атауы"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Тек латын әріптері, сандар, - және _, 24 символға дейін",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Тегтер"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Тег серверлер жиынына бір рет ат береді, оны басымдықтарда tag(name) ретінде қолдануға болады.",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("үшінші тарап"),
    "rcxTier": MessageLookupByLibrary.simpleMessage("Басымдық"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Белгі"),
    "rcxTierWhen": MessageLookupByLibrary.simpleMessage(
      "Осы басымдықтағы серверлер",
    ),
    "rcxTiers": MessageLookupByLibrary.simpleMessage("Басымдық реті"),
    "rcxTiersHint": MessageLookupByLibrary.simpleMessage(
      "Сервер өзіне сәйкес келетін бірінші басымдыққа түседі; сервері бар ең жақсы басымдық таңдалады. Ретін өзгерту үшін ұзақ басыңыз.",
    ),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Авто-маршрут"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Аудармалар"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage("Авто-маршрутты өшіру"),
    "rcxUntilCheck": m120,
    "rcxUntilConfirm": m121,
    "rcxUntilDwell": m122,
    "rcxUseCheck": m123,
    "rcxUseDiagnostic": m124,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage("шығу елін тексеру"),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Ескертулер"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Неге бұл сервер"),
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
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
    "regionAppsPreview": m125,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Қолданба таңдауының алдын ала қарауы",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS серверлері"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Қызмет тексерістері",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("Не өзгереді"),
    "regionChina": MessageLookupByLibrary.simpleMessage("Қытай"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Өзіңіз өзгерткен мәндер сол күйінде қалады.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Мысыр"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Еліңізге сай DNS серверлерін, TUN MTU мәнін, айналып өту тізімін және қызмет тексерістерін таңдайды. Интерфейс тілі өзгермейді.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Баптаулар өзгермейді.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Қызмет тексерістері өшірулі",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Таңдалмаған"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Басқа ел"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Осы құрылғы үшін ұсынылады",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Ресей"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Қолданбаларды аймақ бойынша таңдау",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Аймақтық қолданба ұсыныстарын пайдалану үшін алдымен қолдау көрсетілетін аймақты таңдаңыз.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Аймақ профилі"),
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
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Жазылысты ұзарту",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Ауыстыру"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Барлығын ауыстыру"),
    "request": MessageLookupByLibrary.simpleMessage("Сұрау"),
    "requests": MessageLookupByLibrary.simpleMessage("Сұраулар"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Сұраулар және жаңартулар",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Міндетті"),
    "reset": MessageLookupByLibrary.simpleMessage("Ысыру"),
    "resetAllData": MessageLookupByLibrary.simpleMessage(
      "Барлық деректерді қалпына келтіру",
    ),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage("Барлығын жою"),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Барлық профильдер, параметрлер, скрипттер, тұсқағаздар және кэштелген деректер біржола жойылады. Сақтық көшірме мұрағаттары сақталады. Содан кейін қолданба жабылады. Бұл әрекетті қайтару мүмкін емес.",
    ),
    "resetAllDataWait": m126,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Бұл бетте өзгерістер бар. Олар бастапқы күйіне қайтарылсын ба?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Ысырылсын ба?"),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Деректер жойылуда…",
    ),
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
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Әдепкі мәндерді қалпына келтіру",
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
    "rulesCount": m127,
    "runTime": MessageLookupByLibrary.simpleMessage("Жұмыс уақыты"),
    "running": MessageLookupByLibrary.simpleMessage("Жұмыс істеп тұр"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Орындалу конфигурациясы",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Қауіпсіз режим"),
    "safeModeAppTitle": m128,
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
    "secondsCount": m129,
    "secretKey": MessageLookupByLibrary.simpleMessage("Кілт"),
    "sectionsInEffect": m130,
    "selectAll": MessageLookupByLibrary.simpleMessage("Барлығын таңдау"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Ереже жинағын таңдаңыз",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Бөлу стратегиясын таңдаңыз",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Таңдалған"),
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serviceAbnormalCount": m131,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Барлығы қолжетімді",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Қолжетімді"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Бұғатталған"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Тексеру"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Барлығын тексеру"),
    "serviceCheckedAt": m132,
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
    "settingsCount": m133,
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
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Баптауларды өзгерту",
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
    "setupDirectApps": m134,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "Жергілікті қолданбалар табылмады. Сайттар бәрібір тікелей ашылады.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Олар VPN-сіз жұмыс істейді. Тізімді кейін қолжетімділікті басқаруда өзгертуге болады.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Жергілікті қолданбаларды іздеп жатырмыз…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Еліңіздің сервистері серверсіз ашылады: жылдамырақ, әрі банктер мен мемлекеттік сайттар сізді бұғаттамайды. Жалпы ережелерге мыналар қосылады:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Жергілікті сайттар мен қолданбалар — тікелей",
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
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash жабылады. Таңдауыңыз сақталады, баптау келесі іске қосқанда жалғасады.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Баптаудан шығасыз ба?",
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
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Жалғастыру үшін профиль қосыңыз немесе таңдаңыз.",
    ),
    "setupProfileCount": m135,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash серверлер ұсынбайды. Провайдеріңіздің жазылымын немесе конфигурациясын импорттаңыз.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Профильді импорттау",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Басқа профиль қосу",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Провайдердің хатынан, ботынан немесе жеке кабинетінен сілтемені қойыңыз не файл немесе QR-кодты таңдаңыз.",
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
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Аймақ"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Ұсынылады"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Профильдің әдепкі мәндерін сақтау",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Аймақтық баптаулар өзгермейді.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash DNS, MTU және тікелей бағыттарды еліңіздің желілеріне бейімдейді. Интерфейс тілі өзгермейді.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Қай жерден қосыласыз?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Ештеңе таңдамасаңыз, қазіргі аймақтық баптаулар сол күйінде қалады.",
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
    "setupStepStatus": m136,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Таңдауларыңыз сақталды. Алдыңғы қосылым тоқтатылған жоқ.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Тексеру тоқтатылды",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Басқа қамтуды таңдаңыз: кейбір желілер VPN-ді бұғаттайды.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Интернет ReClash-сыз жұмыс істейтініне көз жеткізіңіз.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Профильді жаңартыңыз немесе баптаудан кейін басқа серверді таңдаңыз.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage(
      "Не істеп көруге болады",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Алғашқы қосылым"),
    "setupTryServer": m137,
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
    "shareLinkUnreadable": m138,
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
    "singleValueTip": m139,
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
    "subscriptionCompatibilityPrepared": m140,
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
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылымда бос құрылғы орны жоқ. Провайдер тіркелгісінен құрылғыны өшіріп, қайта көріңіз.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Бұл жазылым құрылғыны тіркеуді талап етеді. Провайдердің нұсқауларын орындаңыз.",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі аяқталды",
    ),
    "subscriptionExpiresInDays": m141,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Жазылыс мерзімі бүгін аяқталады",
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
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "HWID жіберуді өшірсеңіз, көптеген жазылымдар жұмыс істемей қалады.",
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
    "subscriptionImportIgnoredSections": m142,
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
    "subscriptionImportReviewSummary": m143,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Жазылым импортын тексеру",
    ),
    "subscriptionImportSkippedNodes": m144,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Жазылыс туралы ақпарат",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Жазылыс ескертулері",
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
    "subscriptionTrafficLow": m145,
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
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Бұл құрылғыда Telegram ашылмады.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Telegram ашу"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Браузерде ашу",
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
    "toolsResults": m146,
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
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Трафикті толтыру"),
    "torch": MessageLookupByLibrary.simpleMessage("Қолшам"),
    "total": MessageLookupByLibrary.simpleMessage("Барлығы"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Жүктелген"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Жалпы трафик"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Жүктеп салынған"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy порты"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficPeak": m147,
    "trafficTotal": m148,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Трафик шығыны"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash әртүрлі елдердің адамдары пайдалана алатындай сіздің тіліңізде сөйлейді. Қандай да бір сөз тіркесі көзге оғаш көрінсе — жазыңыз, түзетеміз.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Аударма түзетуін ұсыну",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Тасымал"),
    "trayIcon": MessageLookupByLibrary.simpleMessage("Трей таңбашасы"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Түрлі"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Қара"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Ақ"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Сенімді желілер"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "Осы желілердің кез келгеніне қосылғанда VPN кідіртіледі",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Ағымдағы желі сенімді — VPN кідірілген",
    ),
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
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Автоматты орнатуға рұқсат беру",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash тексерілген, талаптарға сай тұрақты жаңартуларды әр жолы сұрамай орната алады. VPN ешқашан ажыратылмайды. Android орнатуды растауды сұрауы мүмкін.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Автоматты орнатуға рұқсат бересіз бе?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Автоматты орнату",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Жүктеуден бас тарту",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Жаңарту арнасы"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage(
      "Алдын ала шығарылым",
    ),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Тұрақты релиз",
    ),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Автоматты тексеру",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Жаңартуларды тексеру мүмкін болмады",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Байланысты тексеріп, қайталап көріңіз.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңартулар тексерілуде…",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("Терезені жабу"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android сіздің келісіміңізді сұрайды. Жүйелік растауды ашу үшін жалғастырыңыз.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Android жүйесінде растаңыз",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Фонда жалғастыру",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Орнатуды жалғастыру",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "Соңғы нұсқа орнатылған",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "Бұл платформада ReClash шығарылым бетін ашады. Жаңартуды өзіңіз жүктеп, орнатыңыз.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "Бұл құрылғыға тексерілген жүктеу қолжетімсіз. Шығарылым бетінен пакетті таңдаңыз.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Ажыратып, орнату",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Қолмен орнатуды сақтау",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Жаңартуды жүктеу",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage("Қайта жүктеу"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Жаңартуды жүктеу мүмкін болмады",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Жүктелген бөлігі сақталды. Байланысты тексеріп, жүктеуді жалғастырыңыз.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Түсінікті"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Пакет орнатқышын іске қосу мүмкін болмады",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android орнатуды аяқтамады. Дайын болғанда қайталап көріңіз.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Қазір орнату"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңарту орнатылды",
    ),
    "updateInstalledVersion": m149,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android орнатуды аяқтауда. Осы кезде ReClash жабылуы мүмкін.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңарту орнатылуда",
    ),
    "updateMinutes": m150,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Қазір емес"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Релиз ескертпелері қолжетімсіз.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңарту қолжетімді",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Android параметрлерін ашу",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Құрылғыға арналған жинақ",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("Жүктеу өлшемі"),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Пакетті тексеру",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Жүктелгеннен кейін, орнату алдында тексеріледі",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Тұтастық, қолданба сәйкестігі және қолтаңба тексерілді",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Кідірту"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Жүктеу кідіртілді",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash қолданбасына осы көзден қолданбалар орнатуға рұқсат беріп, жалғастыру үшін қайта оралыңыз.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Android рұқсаты қажет",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Тексеруді, жүктеуді және орнатуды бөлек реттеңіз.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Параметрлер сақталмады. Қайта сақтап көріңіз; автоматты орнату қосылған жоқ.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңарту параметрлері",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi арқылы алдын ала жүктеу",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage("Орнатуға дайын"),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Шығарылым туралы мәлімет",
    ),
    "updateRemainingTime": m151,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Жүктеуді жалғастыру",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Жалғастыру"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("Қайта тексеру"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Орнатуды қайталау",
    ),
    "updateSeconds": m152,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Толық релиз ескертпелерін көру",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Барлық өзгерістерді көрсету",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Жаңартулар"),
    "updateTransferSpeed": m153,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Жүктелген жаңартудың тұтастығын тексеру мүмкін болмады.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Файл, нұсқа немесе қолтаңба тексеруден өтпеді. Жаңа көшірмені жүктеп, қайталап көріңіз.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Бұл пакетті орнату мүмкін емес",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Жаңарту тексерілуде",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Орнату кезінде ReClash қысқа уақытқа жабылады. Байланысты үзуге дайын болсаңыз ғана ажыратыңыз.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage("VPN әлі қосулы"),
    "upload": MessageLookupByLibrary.simpleMessage("Жүктеп салу"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Жүктеп салу жолағы",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL схемасы"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Әрекет"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Жазылым қосу"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Жазылым URL мекенжайын қосу; атау міндетті емес.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Шифрланған сілтеменің түпнұсқалығы расталмады. Ол бүлінген немесе басқа кілтті қолдануы мүмкін.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Сілтеме жасау"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Қолданбаны жабу"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Бапталған жабу әрекетін қолдану.",
    ),
    "urlSchemeConfigCounts": m154,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML немесе JSON конфигурациясын қойыңыз",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Конфигурация құрамы",
    ),
    "urlSchemeConfirmMessage": m155,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Қолданбаның сыртқы пәрмені",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Сыртқы қосылу және жабу пәрмендері растауды сұрайды.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Қосылу"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Таңдалған профильмен қосылу.",
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
      "Профильді өзгертпей қосылымды тоқтату.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Ендірілген конфигурация",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Профиль мысалы",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Пішімдер"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Сілтеме пішімдері. Толтырғыштарды URL не деректермен ауыстырыңыз.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Конфигурацияны импорттау",
    ),
    "urlSchemeImportConfirm": m156,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Сілтемеге YAML не JSON конфигурациясын ендіру.",
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
      "Clash клиенттерінің ортақ жазылым сілтемесі пішімін қолдану.",
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
      "ReClash қолданбасын алдыңғы қатарға шығару.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Параметрлер"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Алмасу буферін оқу мүмкін болмады. Сілтемені қолмен қойыңыз.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Сілтеме"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Сілтеме жасау үшін URL не конфигурацияны енгізіңіз.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Сілтемеде токендер не тіркелгі деректері болуы мүмкін. Абайлап бөлісіңіз.",
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
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Қосылымды ауыстыру",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Тоқтап тұрса қосылу, жұмыс істесе ажырату.",
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
    "urlTip": m157,
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
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Қараңғылату"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("Суретті реттеу"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Жеке фонды пайдалану",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("Суретті орналастыру"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Сыйдыру"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Толтыру"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Созу"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Көлденең орналасуы",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG немесе WebP пішіміндегі жарамды суретті таңдаңыз.",
    ),
    "wallpaperImageLabel": m158,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрлау"),
    "wallpaperLibraryFull": m159,
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
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Қолжетімділік"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Панельге қолжетімділік тоқтатылды",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "Қолданбада",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "Браузерде",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("Өшірулі"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Қолжетімділік жергілікті және құпия кілтпен қорғалған. Панельді ашу сақталған сыртқы контроллер параметрлерін өзгертпейді.",
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
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Панель"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Панельді орнату",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Таңдалған панель алғаш ашылғанда жүктеледі. Бекітілген шығарылым SHA-256 арқылы тексеріледі.",
    ),
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
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "Панельге қолжетімділікті провайдер өшірген.",
    ),
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
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Нұсқа"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Ақ тізім режимі"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Жүйеге жазу"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Write to system жүйелік сағатты да орнатады; Android оны елемейді.",
    ),
    "yearsAgo": m160,
    "yearsAgoShort": m161,
    "yes": MessageLookupByLibrary.simpleMessage("Иә"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Қытайша (жеңілдетілген)"),
  };
}
