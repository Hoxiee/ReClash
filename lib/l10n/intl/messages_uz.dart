// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uz locale. All the
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
  String get localeName => 'uz';

  static String m0(count) =>
      "${Intl.plural(count, other: '${count} ta tanlandi')}";

  static String m1(count) =>
      "Provayder VPN’dan tashqarida qoldiradigan ilovalar: ${count}. Ro‘yxatni o‘zgartirish uchun kirishni boshqarishni yoqing.";

  static String m2(name) => "${name} mahalliy proksilarga qoʻshildi";

  static String m3(name) => "${name} allaqachon mahalliy proksilarda mavjud";

  static String m4(count, skipped) =>
      "Qoʻshiladi: ${count}; allaqachon mavjudligi bois oʻtkazib yuborildi: ${skipped}";

  static String m5(detail) => "Maʼlumotlarni tozalab boʻlmadi: ${detail}";

  static String m6(code) =>
      "Windows ReClashCore.exe dasturini ishga tushirishni rad etdi (xato kodi ${code}). Smart App Control yoki AppLocker kabi dasturlarni boshqarish siyosati imzosiz dasturlarni bloklaydi. ReClashga oʻsha siyosatda ruxsat bering yoki siyosatni oʻchirib qoʻying, soʻng qayta urinib koʻring.";

  static String m7(name) =>
      "Ilova ketma-ket ikki marta ishga tushmadi. Bunga chek qoʻyish uchun ${name} profili tanlovdan chiqarildi va avtomatik sozlash oʻtkazib yuborildi. Uni istalgan paytda qayta tanlashingiz mumkin.";

  static String m8(url) => "${url} manzilidan profil yaratilsinmi?";

  static String m9(groups) =>
      "${groups} proksi guruhlaridan include-all tashlab yuborilgan; ular foydalanadigan proksilar yoki proksi provayderlarni qoʻshing";

  static String m10(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE qoidasi tashlab yuborilgan — maxsus profillar sub-rulesni qoʻllab-quvvatlamaydi', other: '${label} SUB-RULE qoidasi tashlab yuborilgan — maxsus profillar sub-rulesni qoʻllab-quvvatlamaydi')}";

  static String m11(message) =>
      "Yadro bu proksini tahlil qilolmadi: ${message}";

  static String m12(proxy, target) =>
      "${proxy} ${target} orqali ulanadi; u yana ${proxy}ga qaytib keladi, shu sababli ulanish halqa boʻlib qoladi";

  static String m13(name) =>
      "${name} nomi allaqachon boshqa proksi yoki proksi guruhda ishlatilgan";

  static String m14(path) =>
      "Proksi guruhlar bir-biriga halqasimon murojaat qiladi: ${path}";

  static String m15(name) =>
      "Boʻsh zaxira proksi boʻlishi kerak; lekin ${name} mavjud emas yoki proksi guruh";

  static String m16(name, message) => "${name} yaroqli regex emas: ${message}";

  static String m17(name) => "Dialer proksi ${name} mavjud emas";

  static String m18(names) => "Bu proksi provayderlar mavjud emas: ${names}";

  static String m19(names) =>
      "Bu proksilar yoki siyosatlar mavjud emas: ${names}";

  static String m20(name) =>
      "${name} ichki siyosat nomi va bu yerda ishlatib boʻlmaydi";

  static String m21(count) =>
      "${count} ta yozuvda muammo bor; bu profilni qoʻllasangiz xatolik yuz berishi mumkin";

  static String m22(count) =>
      "${Intl.plural(count, one: '1 kun oldin', other: '${count} kun oldin')}";

  static String m23(count) =>
      "${Intl.plural(count, other: '${count} kun oldin')}";

  static String m24(label) => "Tanlangan ${label} oʻchirilsinmi?";

  static String m25(label) => "Bu ${label} oʻchirilsinmi?";

  static String m26(label) => "${label} tafsilotlari";

  static String m27(name) =>
      "${name} orqali ulanish uni ishlatayotgan proxiga qaytib keladi, shu sababli ulanish toʻxtatildi";

  static String m28(label) => "${label} boʻsh boʻlishi mumkin emas";

  static String m29(label) => "${label} allaqachon mavjud";

  static String m30(count) => "${count} ta yozuv amalga oshmadi";

  static String m31(label, message) => "${label}: ${message}";

  static String m32(name) => "${name} allaqachon yangilangan";

  static String m33(name) => "${name} yangilandi";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 guruh', other: '${count} guruh')}";

  static String m35(count) => "${count} ta kutish vaqti tugadi";

  static String m36(action) =>
      "«${action}» uchun ishlatilmoqda. Saqlansa, shu yerga koʿchiriladi.";

  static String m37(actions) => "Eksport qilinmadi: ${actions}";

  static String m38(modifiers) => "Kamida ${modifiers} dan birini qoʿshing";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 soat oldin', other: '${count} soat oldin')}";

  static String m40(count) =>
      "${Intl.plural(count, other: '${count} soat oldin')}";

  static String m41(target) => "${target} — yaroqsiz yoʻnalish";

  static String m42(proxyName) => "${proxyName} — yaroqsiz proksi";

  static String m43(providerName) =>
      "${providerName} — yaroqsiz proksi provayder";

  static String m44(ruleSet) => "${ruleSet} — yaroqsiz qoida toʻplami";

  static String m45(subRule) => "${subRule} — yaroqsiz SUB_RULE";

  static String m46(count) =>
      "${Intl.plural(count, one: '1 yozuv', other: '${count} yozuv')}";

  static String m47(line, message) => "${line}-qator: ${message}";

  static String m48(appName) =>
      "1. Tizim sozlamalaridagi Maxfiylik va xavfsizlik boʻlimini oching\n2. Joylashuv xizmatlarini tanlang\n3. Roʻyxatdan ${appName}ni topib, belgilang\n\nTugagach, ilovaga qaytib davom eting. Tushunganingiz uchun rahmat.";

  static String m49(label, max) => "${label} ${max} belgidan oshmasligi kerak";

  static String m50(size) => "${size} boʻshatildi";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 daqiqa oldin', other: '${count} daqiqa oldin')}";

  static String m52(count) =>
      "${Intl.plural(count, other: '${count} daqiqa oldin')}";

  static String m53(count) =>
      "${Intl.plural(count, one: '1 oy oldin', other: '${count} oy oldin')}";

  static String m54(count) =>
      "${Intl.plural(count, other: '${count} oy oldin')}";

  static String m55(code) =>
      "Server kirishni rad etdi (HTTP ${code}). Havola muddati tugagan yoki hisob maʼlumotlari xato boʻlishi mumkin";

  static String m56(code) => "Server soʻrovni rad etdi (HTTP ${code})";

  static String m57(code) =>
      "Bu manzilda hech narsa topilmadi (HTTP ${code}). URL toʻgʻriligini tekshiring";

  static String m58(detail) => "Tarmoq soʻrovi bajarilmadi: ${detail}";

  static String m59(code) =>
      "Serverda muammo yuz berdi (HTTP ${code}). Keyinroq qayta urinib koʻring";

  static String m60(label) => "Hozircha ${label} yoʻq";

  static String m61(label, min, max) =>
      "${label} ${min} va ${max} oraligʻida boʻlishi kerak";

  static String m62(label) => "${label} raqam boʻlishi kerak";

  static String m63(label) =>
      "${label} 1024 va 49151 oraligʻida boʻlishi kerak";

  static String m64(port) => "${port} port";

  static String m65(added, skipped, failed) =>
      "Qo‘shildi: ${added}; o‘tkazib yuborildi: ${skipped}; xatolar: ${failed}.";

  static String m66(days) =>
      "${Intl.plural(days, one: '1 kun qoldi', other: '${days} kun qoldi')}";

  static String m67(date, days) =>
      "Tugash vaqti ${date}, ${Intl.plural(days, one: '1 kun', other: '${days} kun')} qoldi";

  static String m68(name) => "Allaqachon «${name}» sifatida qoʻshilgan";

  static String m69(client) => "${client} ilovasi qabul qilgandek";

  static String m70(count) =>
      "${Intl.plural(count, other: '${count} ta server')}";

  static String m71(time) => "Yangilandi: ${time}";

  static String m72(label, profiles) =>
      "${label} hali ${profiles} tomonidan ishlatilmoqda; uni oʻchirsangiz ular toʻgʻri ishlamaydi. Oʻchirishni tasdiqlaysizmi?";

  static String m73(count, label) =>
      "${Intl.plural(count, one: '1 proksi', other: '${label} proksi')}";

  static String m74(name, count) => "${name} va boshqalar (${count} proksi)";

  static String m75(removed) =>
      "Bu proksilar oʻchiriladi: ${removed}. Nomi oʻzgargan qator yangi proksi hisoblanadi; oʻchirilganlarni nomlaydigan maxsus profillar ularni mavjud emas sifatida koʻrsatadi. Baribir qoʻllansinmi?";

  static String m76(removed, added) =>
      "Bu proksilar oʻchiriladi: ${removed}. Bu yerga qoʻshiladi: ${added}. Nomi oʻzgargan qator yangi proksi hisoblanadi; oʻchirilganlarni nomlaydigan maxsus profillar ularni mavjud emas sifatida koʻrsatadi. Baribir qoʻllansinmi?";

  static String m77(label) =>
      "${label} hali shu profildagi qoidalar, proksi guruhlar, dialer proksilar, DNS yoki NTP tomonidan nomlanmoqda; uni oʻchirsangiz ular ishlamay qoladi. Oʻchirishni tasdiqlaysizmi?";

  static String m78(count, label) =>
      "${Intl.plural(count, one: '1 proksi guruh', other: '${label} proksi guruh')}";

  static String m79(pick, now) => "${now} o‘rniga ${pick} ni tanlaydi";

  static String m80(group) => "${group} tekshiruvi";

  static String m81(pick) => "${pick} ni saqlaydi";

  static String m82(number) => "Shart ${number}";

  static String m83(profile) => "«${profile}» bu saytlarni tekshirmoqchi";

  static String m84(count) =>
      "${Intl.plural(count, other: '${count} ta server')}";

  static String m85(profile) => "«${profile}» o‘chirilsinmi?";

  static String m86(requests, used, cap) =>
      "Bugungi tekshiruvlar: ${requests} · ${cap} dan ${used}";

  static String m87(condition) => "${condition} bundan mustasno";

  static String m88(country) => "chiqish ${country}";

  static String m89(member) => "${member} orqali";

  static String m90(title) =>
      "«${title}» o‘zgartirib bo‘lmaydi. Tahrirlar nusxaga yoziladi va nusxa ishlayotgan ssenariyga aylanadi.";

  static String m91(mode) =>
      "Yo‘nalishlar qoida rejimida ishlaydi; hozir ulanish ${mode} rejimida.";

  static String m92(profile) => "«${profile}» qo‘shildi";

  static String m93(node) => "${node} ishlamay qoldi";

  static String m94(from, to) => "Rejim ${from} → ${to}";

  static String m95(count) =>
      "${Intl.plural(count, other: 'Hozir ${count} ta server mos')}";

  static String m96(ms) => "${ms} ms dan kam";

  static String m97(text) => "nomida ${text}";

  static String m98(what) => "${what} emas";

  static String m99(provider) => "${provider} dan";

  static String m100(number) => "${number}-qadam";

  static String m101(action) =>
      "Hech bir qadamda ishlaydigan server bo‘lmasa: ${action}";

  static String m102(tag) => "${tag} tegi";

  static String m103(line, text) => "${line}-qator: ${text}";

  static String m104(check) =>
      "${check} tekshiruvi hech qayerda ishlatilmaydi, shuning uchun bajarilmaydi";

  static String m105(hosts) => "Uchinchi tomon saytlariga ulanadi: ${hosts}";

  static String m106(group) => "Bu konfiguratsiyada ${group} guruhi yo‘q";

  static String m107(group) =>
      "${group} guruhidagi hech bir server filtrdan o‘tmaydi";

  static String m108(tag) => "${tag} tegi hech qayerda ishlatilmaydi";

  static String m109(tier, group) =>
      "Hozir ${group} guruhidagi hech bir server «${tier}» ichida emas";

  static String m110(tier, after) =>
      "«${tier}» «${after}» shartini takrorlaydi, shuning uchun unga hech narsa tushmaydi";

  static String m111(name, count) => "${name} va yana ${count}";

  static String m112(keys) =>
      "Olib o‘tildi; buni o‘zingiz ham o‘zgartirgansiz, shuning uchun sizniki saqlandi: ${keys}";

  static String m113(mode) => "Rejim: ${mode}";

  static String m114(node) =>
      "${node} serverida qoladi; undan faqat nosozlikda ketadi va u tiklanganda qaytadi.";

  static String m115(kind) => "Tarmoq: ${kind}";

  static String m116(tier) =>
      "tekshiruvdan so‘ng «${tier}» darajasiga chiqishi mumkin";

  static String m117(node) => "Biriktirilgan: ${node}";

  static String m118(error) => "Profil xatosi: ${error}";

  static String m119(profile) =>
      "${profile} profili topilmadi; standart ishlatiladi";

  static String m120(error) => "Marshrut holatini saqlab bo‘lmadi: ${error}";

  static String m121(tier) => "«${tier}» serveriga o‘tildi";

  static String m122(from) =>
      "Server almashtirildi; ${from} 15 daqiqa o‘tkazib yuboriladi";

  static String m123(from) =>
      "${from} ishlamay qoldi; eng yaxshi zaxiraga o‘tildi";

  static String m124(from, gain) => "${from} dan o‘tildi: ${gain} ms tezroq";

  static String m125(node) => "Ssenariy ${node} ni ushlab turibdi";

  static String m126(node) => "${node} bu guruhda yo‘q";

  static String m127(limit) =>
      "Almashtirish chegarasiga yetildi (soatiga ${limit})";

  static String m128(mode) => "Ishlatilmaydi: ${mode} rejimi";

  static String m129(from) => "${from} endi ro‘yxatda yo‘q";

  static String m130(kind) =>
      "Tarmoq «${kind}» bo‘lganda pauza: hech narsa tekshirilmaydi va almashtirilmaydi";

  static String m131(route, error) =>
      "«${route}» yo‘nalishini qo‘llab bo‘lmadi: ${error}";

  static String m132(route) =>
      "«${route}» yo‘nalishi o‘tkazib yuborildi: bunday nomli guruh allaqachon bor.";

  static String m133(route, to) =>
      "«${route}» yo‘nalishi trafikni profilda yo‘q «${to}» ga yuboradi.";

  static String m134(node) => "Ssenariy ${node} ga o‘tkazadi";

  static String m135(node) => "Biriktirilgan ${node} serveriga o‘tildi";

  static String m136(node) => "Ishlaydigan server yo‘q; ${node} ishlatilmoqda";

  static String m137(scenario) =>
      "Bu guruhni «${scenario}» ssenariysidagi yo‘nalish yaratgan. Uni o‘sha yerda tahrirlash yoki o‘chirish mumkin.";

  static String m138(scenario) =>
      "Hozir bu guruhni «${scenario}» ssenariysi boshqaryapti.";

  static String m139(count, total) => "${total} tadan ${count} tasi mos";

  static String m140(node) => "Tekshiruv tasdiqlasa, ${node} ga o‘tadi";

  static String m141(node, gain) =>
      "${gain} ms tezroq qolsa, ${node} ga o‘tadi";

  static String m142(node, minutes) =>
      "${minutes} daqiqadan keyin ${node} ga o‘tishi mumkin";

  static String m143(name) => "${name} tekshiruvi";

  static String m144(name) => "${name} tarmoq diagnostikasi";

  static String m145(count) =>
      "${Intl.plural(count, other: '${count} ta server solishtirildi')}";

  static String m146(count) =>
      "${Intl.plural(count, other: 'Bu guruhning ${count} ta serveri orasidan tanlaydi.')}";

  static String m147(region, bypassed, proxied) =>
      "${region}: VPNni chetlab o‘tish ro‘yxatiga ${bypassed} ta, VPN ro‘yxatiga ${proxied} ta ilova kiradi. Ikkala ro‘yxat almashtiriladi; rejim va boshqa sozlamalar o‘zgarmaydi. Paket va SDK mosligi faqat tavsiya: qo‘llagandan keyin natijani tekshiring.";

  static String m148(seconds) => "${seconds} soniyadan keyin tasdiqlash mumkin";

  static String m149(count, label) =>
      "${Intl.plural(count, one: '1 qoida', other: '${label} qoida')}";

  static String m150(appName) => "${appName} (Xavfsiz rejim)";

  static String m151(count) =>
      "${Intl.plural(count, one: '1 soniya', other: '${count} soniya')}";

  static String m152(count) => "${count} ta faol";

  static String m153(count) =>
      "${Intl.plural(count, one: '1 nosozlik', other: '${count} nosozlik')}";

  static String m154(count) =>
      "${Intl.plural(count, one: '1 sozlama', other: '${count} sozlama')}";

  static String m155(count) => "VPN’ni chetlab o‘tadigan ilovalar: ${count}";

  static String m156(count) => "Mavjud profillar: ${count}";

  static String m157(step, total) => "${total} tadan ${step}-qadam";

  static String m158(server) => "${server}ni sinash";

  static String m159(link) => "${link} havolasidan proksi oʻqib boʻlmadi";

  static String m160(count) => "${Intl.plural(count, other: '${count} kun')}";

  static String m161(delay) => "${delay} ms";

  static String m162(service) => "${service} bu manzilni bloklaydi";

  static String m163(service) => "${service} hali bu yerda mavjud emas";

  static String m164(service) =>
      "${service} bu yerda faqat o‘z asarlarini ko‘rsatadi";

  static String m165(service) => "${service} cheklovlar bilan ishlaydi";

  static String m166(service) => "${service} ochilmaydi";

  static String m167(service) => "${service} bu mamlakatda ishlamaydi";

  static String m168(size) =>
      "Faqat bosganingizda VPN siz taxminan ${size} yuklab oladi.";

  static String m169(size) =>
      "Faqat bosganingizda VPN orqali taxminan ${size} yuklab oladi.";

  static String m170(network) => "Ishonchli tarmoq «${network}»";

  static String m171(total) => "${total} dan qoldi";

  static String m172(date) => "${date} gacha";

  static String m173(label) => "${label} bitta yozuv boʻlishi kerak";

  static String m174(client, format, count) =>
      "${client} sifatida olindi: ${format}, proksi tugunlari: ${count}.";

  static String m175(count) =>
      "${Intl.plural(count, one: 'Obunangiz muddati ertaga tugaydi', other: 'Obunangiz muddati ${count} kundan soʻng tugaydi')}";

  static String m176(count) => "${count} ta serverni qo‘shish";

  static String m177(count) => "Barcha ${count} ta server qo‘shiladi";

  static String m178(count, total) =>
      "${total} ta serverdan ${count} tasi qo‘shiladi";

  static String m179(count) => "Hammasini ko‘rsatish (${count})";

  static String m180(format) => "Format: ${format}";

  static String m181(percent) => "Trafikning ${percent}% ishlatildi";

  static String m182(count) => "${count} ta natija";

  static String m183(value) => "Eng yuqori ${value}";

  static String m184(value) => "Jami ${value}";

  static String m185(transport) => "${transport} sarlavhalari";

  static String m186(version) => "Oʻrnatilgan versiya: ${version}";

  static String m187(count) => "${count} daq";

  static String m188(time) => "${time} qoldi";

  static String m189(count) => "${count} s";

  static String m190(speed) => "${speed}/s";

  static String m191(nodes, groups, providers) =>
      "Proksilar: ${nodes}, guruhlar: ${groups}, masofaviy provayderlar: ${providers}";

  static String m192(action) =>
      "Bu havola «${action}» amalini so‘raydi. ReClash’ga uni bajarishga ruxsat berilsinmi?";

  static String m193(name, source) =>
      "${source} manbasidan «${name}» import qilinsinmi? Tasdiqlashdan so‘ng profil va o‘girishlar tekshiriladi.";

  static String m194(label) => "${label} URL boʻlishi kerak";

  static String m195(index) => "Fon ${index}";

  static String m196(count) =>
      "Koʻpi bilan ${count} ta fon saqlash mumkin. Yangisini qoʻshish uchun bittasini oʻchiring.";

  static String m197(count) =>
      "${Intl.plural(count, one: '1 yil oldin', other: '${count} yil oldin')}";

  static String m198(count) =>
      "${Intl.plural(count, other: '${count} yil oldin')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Haqida"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Kirish nazorati"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat tanlangan ilovalar VPN orqali ishlaydi",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Kirish nazorati qaysi ilovalar proksidan foydalanishini tanlaydi.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Ilovalar uchun kirish nazorati oʻchirilgan",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Tanlangan ilovalar VPN tashqarisida qoladi",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Kirish nazorati sozlamalari",
    ),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Ilovalarni provayderga qaytarish",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Hisob"),
    "action": MessageLookupByLibrary.simpleMessage("Amal"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Barcha kechikishlarni tekshirish",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage(
      "Toʻgʻridan-toʻgʻri rejim",
    ),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Global rejim"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Rejimni almashtirish"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Tizim proksisi"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Qoida rejimi"),
    "actionStart": MessageLookupByLibrary.simpleMessage(
      "Ishga tushirish/Toʻxtatish",
    ),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Profillarni yangilash",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Koʻrsatish/Yashirish"),
    "add": MessageLookupByLibrary.simpleMessage("Qoʻshish"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Proksi qoʻshish"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Filtrlar qoʻshish"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Tarmoq qoʻshish"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Tugunlar qoʻshish"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Qayta belgilash yozuvini qoʻshish",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Profil qoʻshish"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Proksi guruhi qoʻshish",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Qoida qoʻshish"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Sozlama qoʻshish"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSID qoʻshish"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Mahalliy proksilarga qoʻshish",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Qoʻshilgan qoidalar"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimcha parametrlar",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Nom prefiksi"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Nom suffiksi"),
    "address": MessageLookupByLibrary.simpleMessage("Manzil"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server manzili",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Toʻgʻri WebDAV manzilini kiriting",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Kengaytirilgan konfiguratsiya",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Kengaytirilgan konfiguratsiya tarmoq, DNS, qoʻshilgan qoidalar va skriptlarni oʻz ichiga oladi.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Shifrlangan profil",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Age maxfiy kaliti"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Bu profil age bilan shifrlangan; uni ochish uchun age maxfiy kaliti kerak",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Rozi boʻlaman"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Murojaat qilingan barcha proksilar",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Murojaat qilingan barcha proksi provayderlar",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Ilovalarga VPNni chetlab oʻtishga ruxsat berish",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN-ga ruxsat berish"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Ruxsat etilgan IP-lar"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("Javoblar"),
    "app": MessageLookupByLibrary.simpleMessage("Ilova"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Ilovalar uchun kirish nazorati",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Ilova belgisi"),
    "appIconApply": MessageLookupByLibrary.simpleMessage(
      "Bu belgidan foydalanish",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Chizma"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Bosh ekranda yangi belgi chiqishi uchun bir necha soniya kerak bo‘lishi mumkin. Ba‘zi launcherlar yorliqni olib tashlaydi — uni ilovalar ro‘yxatidan qayta qo‘shing.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Sxema"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Ilova belgisi dizayni",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Aks-sado"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Siyoh"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Parchalar"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Quyosh"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Uchqun"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Standart"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Qatlamlar"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Relyef"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Iz"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Baxmal"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Mahalliy proksilar yoʻq",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage("Ilova hududi"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Fon"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Interfeys"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Mavzu"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Tizim DNSini qoʻshish",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Ilova sozlamalari",
    ),
    "applied": MessageLookupByLibrary.simpleMessage("Qoʻllandi"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Hozir qoʻllash"),
    "authentication": MessageLookupByLibrary.simpleMessage("Autentifikatsiya"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Autentifikatsiya mahalliy proksi portida foydalanuvchi nomi va parol soʻraydi.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Autentifikatsiya yoqilganda tizim proksisi qoʻllanmaydi.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Ruxsat berish"),
    "authorized": MessageLookupByLibrary.simpleMessage("Ruxsat berilgan"),
    "auto": MessageLookupByLibrary.simpleMessage("Avtomatik"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Yangilanishlarni avtomatik tekshirish",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Ulanishlarni avtomatik yopish",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Ulanishlarni avtomatik yopish proksilarni almashtirganda ochiq ulanishlarni yopadi.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("Avtomatik kiritish"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage(
      "Avtomatik ishga tushirish",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Avtomatik yoqilish"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yoqilish ilova ochilganda proksini yoqadi.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Tizim DNSini avtomatik belgilash",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Avtomatik yangilash"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yangilanish oraligʻi",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Orqaga"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage(
      "Fonni xiralashtirish",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Zaxira nusxa"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Zaxira olish va tiklash",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Bu zaxira ilovaning yangiroq versiyasidan olingan. Tiklashdan oldin ilovani yangilang",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Zaxira muvaffaqiyatli yaratildi",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Asosiy ma’lumot"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage(
      "Asosiy strategiyalar",
    ),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Toʻplab qoʻshish"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Toʻplab import"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Har qatorga bitta havola",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Har qatorga bitta yozuv yoki vergul bilan ajratilgan holda kiriting",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Har qatorga bitta yozuv: kalit, probel, soʻng qiymat",
    ),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Har qatorga bitta URL",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Batareya optimallashtirishiga eʼtibor bermaslik ilovani fonda ishlab turadi.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bogʻlash"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Qora roʻyxat rejimi",
    ),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Ulanishni bloklash",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Yorqinlik"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage(
      "Chetlab oʻtiladigan domenlar",
    ),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Chetlab oʻtiladigan domenlar faqat tizim proksisi yoqilganda kuchga kiradi.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Shaxsiy manzillarni chetlab oʻtish",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Shaxsiy manzillarni chetlab oʻtish yoqilganda LAN, loopback va multicast manzillar TUN orqali oʻtmaydi.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Kesh"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Kesh algoritmi"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Kesh buzilgan. Tozalansinmi?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Kesh oʻlchami"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QR kodlarni skanerlash uchun tizim sozlamalarida kameraga ruxsat bering yoki albomdan QR kod rasmini tanlang.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Kamera ruxsati talab qilinadi",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Kamera mavjud emas",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Tanlovni bekor qilish",
    ),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Saqlab boʻlmadi"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Proksini almashtirib boʻlmadi. Oldingi tanlov tiklandi.",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Jiddiy oʻzgarishlar",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage(
      "Yangi imkoniyatlar",
    ),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Tuzatishlar"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Unumdorlik"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage(
      "Qaytarilgan oʻzgarishlar",
    ),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "TLS sertifikatlarini tekshirish",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS tekshiruvi oʻchirilganda obuna va zaxiralar «oʻrtadagi odam» hujumlariga ochiq qoladi.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage(
      "Yangilanishlarni tekshirish",
    ),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Ilova allaqachon eng soʻnggi versiyada",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Shifr"),
    "clearData": MessageLookupByLibrary.simpleMessage("Ma’lumotlarni tozalash"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Bu barcha profillar, sozlamalar va mahalliy maʼlumotlarni oʻchirib tashlab, ilovani yopadi. Yana ochsangiz, hammasi noldan boshlanadi.",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage(
      "DNS keshini tozalash",
    ),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "DNS keshini tozalab boʻlmadi",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Qidiruvni tozalash"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Klient barmoq izi",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Klipbordga eksport qilish",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Klipborddan import qilish",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Almashish buferiga nusxalab boʻlmadi. Tanlangan matn juda katta boʻlishi mumkin",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Yopish"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Ulanishlarni yopish",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN toʻxtatilganda barcha ochiq ulanishlar uziladi",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Rang"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Kontrast"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Rang uslubi"),
    "columns": MessageLookupByLibrary.simpleMessage("Ustunlar"),
    "compact": MessageLookupByLibrary.simpleMessage("Ixcham"),
    "compatible": MessageLookupByLibrary.simpleMessage("Moslik rejimi"),
    "confirm": MessageLookupByLibrary.simpleMessage("Tasdiqlash"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Barcha ma’lumotlar tozalansinmi?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Bu proksi guruhi oʻchirilsinmi?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Bu oyna yopilsinmi?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Yadro majburan qulatilsinmi?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Tirbandlikni boshqarish",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "TCP tirbandligini boshqarish",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP tirbandligini boshqarish faqat mips steki bilan ishlaydi.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Ulangan"),
    "connecting": MessageLookupByLibrary.simpleMessage("Ulanmoqda…"),
    "connection": MessageLookupByLibrary.simpleMessage("Ulanish"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Ulanish statistikasi",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Jonli ulanishlar, oxirgi soʻrovlar va DNS soʻrovlari",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Ulanishlar"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Ulanish holati: "),
    "content": MessageLookupByLibrary.simpleMessage("Tarkib"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Mazmun boʻsh boʻlmasligi kerak",
    ),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Yuqori"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("O‘rtacha"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Global qoʻshilgan qoidalarni boshqarish",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Nusxalash"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Muhit oʻzgaruvchilarini nusxalash",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Havolani nusxalash"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Nusxa olindi"),
    "core": MessageLookupByLibrary.simpleMessage("Yadro"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Arxitektura"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control ReClashCore.exe dasturini imzo yoʻqligi sababli blokladi. Windows Security → App & browser control → Smart App Control sozlamalariga oʻting, Off ni tanlang va ReClashni qayta ishga tushiring. Smart App Controlni Windowsni qayta oʻrnatmasdan qayta yoqib boʻlmaydi.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("Yigʻish bayroqlari"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("Yigʻilgan vaqt"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Muhit"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("Yadro fayli"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Yadro maʼlumotlarini olib boʻlmadi",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage(
      "Ishga tushirish usuli",
    ),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Joylashuv"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Boshqariladigan yuqori huquqli jarayon",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Helper orqali jarayon",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Jarayon ichidagi kutubxona",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Imzolangan Helper orqali boshqariladigan jarayon",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("Alohida jarayon"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Ishlash konfiguratsiyasini ochish",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Platforma"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Ishlamoqda"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Ishlash konfiguratsiyasi",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Sozlamalar va skriptlardan keyingi yakuniy konfiguratsiya. Faqat oʻqish uchun.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Ishlash konfiguratsiyasini oʻqib boʻlmadi",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Ishga tushmoqda…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Yadro holati"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Toʻxtatilgan"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Maʼlumotlar katalogi",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Mintaqa"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Qulash aniqlandi"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("Qulash testi"),
    "create": MessageLookupByLibrary.simpleMessage("Yaratish"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("Yaratilgan vaqt"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI chetlab oʻtish"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Ilova asosi"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimcha funksiyalar",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Provayder funksiyalari va gʻoyalari",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Proksi yadrosi"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Ishga tushirish tugmasini oʻz ichiga oladi; uni olib tashlab boʻlmaydi",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "customColor": MessageLookupByLibrary.simpleMessage("Maxsus rang"),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("Nomi boʻsh"),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Proksilar yoki proksi provayderlar tanlanmagan, shu sababli yadro bu guruhni rad etadi",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Maxsus profil resurslari",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Maxsus profil resurslari proksilar, qoida provayderlar, filtrlar va belgi toʻplamlarini saqlaydi.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Kesish"),
    "dark": MessageLookupByLibrary.simpleMessage("Qorongʻi"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Boshqaruv paneli"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Qoʻshish mumkin boʻlganlar",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Boshqaruv paneli"),
    "dashboardStyleDetailed": MessageLookupByLibrary.simpleMessage("Batafsil"),
    "dashboardStyleSimple": MessageLookupByLibrary.simpleMessage("Oddiy"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishni saqlab boʻlmadi. Oldingi holatga qaytarildi.",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("Standart tanlov"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Standart"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya nomi va turini oʻz ichiga olgan YAML lugʻati boʻlishi kerak",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Kechikish"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Muvaffaqiyatsiz"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Kechikish testi"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Kechikish sinovining kutish vaqti",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Oʻchirish"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta yadrosi asosida qurilgan koʻp platformali proksi ilova. Sodda va oson foydalanish, ochiq kodli, reklamasiz.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Grafik ruxsat agenti mavjud emas. Uni joriy ish stoli seansida ishga tushiring va qayta urinib ko‘ring.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berish bekor qilindi. TUN ishga tushmadi.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berilmadi. TUN ishga tushmadi.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN uchun ruxsat kerak. Ruxsat berish uchun ulanishni boshlang yoki TUNni yoqing.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berishni kutish vaqti tugadi. Ulanish tugmasi orqali qayta urinib ko‘ring.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berilgan Core tekshirilgan ishga tushirishni yakunlay olmadi. Paket va tizim jurnallarini tekshiring.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core yoki Helper yaxlitlik tekshiruvidan o‘tmadi. To‘liq ReClash paketini qayta o‘rnating.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Tizim sozlamalari → Umumiy → Kirish elementlari va kengaytmalar bo‘limida ReClash Helperga ruxsat bering, so‘ng qayta urinib ko‘ring.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "O‘rnatilgan Helper boshqa protokoldan foydalanadi. Boshqa o‘rnatish yoki xizmat sozlamalarini qayta belgilash borligini tekshirib, to‘liq paketni qayta o‘rnating.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "Mavjud Linux Helper ro‘yxatini xavfsiz almashtirib bo‘lmaydi. Xizmat egasi va ro‘yxatini tekshiring: qayta avtorizatsiya ziddiyatni bartaraf etmaydi.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd TUN Helper’ni ishga tushira olmadi. Xizmat jurnalini tekshiring: o‘rnatuvchi avvalgi o‘rnatishni tiklashga urindi.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN uchun systemd boshqaradigan Linux seansi kerak. Bu tizim tarmoq Helper’ni ishga tushira olmaydi.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN Helper mavjud emas. O‘rnatilgan paket va xizmatni tekshiring, so‘ng qayta urinib ko‘ring.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "Oldingi ruxsat berish yoki Core to‘xtatilishi hali tugamadi. Tugashini kuting va qayta urinib ko‘ring.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN uchun to‘g‘ri imzolangan ReClash ilovasi va Helper kerak. Imzosiz yoki ad-hoc imzoli yig‘ilishga ruxsat berib bo‘lmaydi.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core ishga tushdi, ammo TUN adapteri tayyor emas. TUNdan foydalanishdan oldin Core jurnalini tekshiring.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Manzil"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Manzil GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("Manzil IP ASN"),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Uchinchi tomon API’ga tayanadi; faqat maʼlumot uchun",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Dasturchi rejimi"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Dasturchi rejimi yoqilgan.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Ulanish proksisi"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Dialer proksi — NTP serveriga yetib borishda ishlatiladigan chiqish.",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("Toʻgʻridan-toʻgʻri"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP uzatishni oʻchirish",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP uzatish oʻchirilganda TUN pinglarga oʻzi javob beradi, shu sababli ping endi haqiqiy kechikishni koʻrsatmaydi.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "TCP keep-aliveni oʻchirish",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDPni oʻchirish"),
    "disabled": MessageLookupByLibrary.simpleMessage("Oʻchirilgan"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishlar bekor qilinsinmi?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Ogohlantirish"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "Dasturni oʻrnatish, nusxalash yoki ishlatish siz ushbu bayonni toʻliq oʻqigan va rozi boʻlgan hisoblanadi. Shartlarining birortasiga rozi boʻlmasangiz, foydalanishni toʻxtatib, Dasturni darhol oʻchirib tashlang.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage(
      "Qabul qilish",
    ),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "Ushbu bayonni oʻqidim va tushundim",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Tushunganingizni tasdiqlash uchun quyidagi bayonni oʻqing va pastdagi belgini oʻrnatang:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Bayonni tasdiqlang",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Ishlab chiqaruvchilar istalgan reliz bilan ushbu bayonni yangilashi mumkin; oʻzgarish oʻsha reliz chop etilgan paytda kuchga kiradi. Dasturni yangilangandan soʻng foydalanishda davom etish tuzatilgan bayonni qabul qilganingizni anglatadi.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Bayonning oʻzgarishlari",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash («Dastur»)dan foydalanishdan avval ushbu bayonni sinchkovlik bilan oʻqing va barcha mazmunini tushunib yetganingizga ishonch hosil qiling. «Rozi boʻlaman»ni bosish — quyidagi barcha shartlarni oʻqiganingiz, tushunganingiz va qabul qilganingizni bildiradi. Agar rozi boʻlmasangiz, «Chiqish»ni bosing va Dasturdan foydalanishni toʻxtating.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "Amaldagi qonun ruxsat bergan eng katta darajada ishlab chiqaruvchilar hamda hech qanday hissa qoʻshuvchi Dasturdan foydalanish yoki foydalana olmaslik tufayli yuzaga kelgan bevosita, bevosita emas, tasodifiy, maxsus, jazoviy yoki natijaviy zararlar, jumladan maʼlumot yoʻqolishi, qurilma shikastlanishi, tarmoq ishlamay qolishi, tijoriy faoliyat uzilishi, foyda yoʻqolishi yoki bular natijasida kelib chiqqan har qanday huquqiy nizo uchun javobgar boʻlmaydi — bunday zararlar boʻlishi mumkinligi xabar qilinganda ham.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Javobgarlikning cheklovi",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Dastur GPL-3.0 litsenziyasi bilan ochiq kodli. Bu litsenziyaga amal qilgan holda uni erkin ishlatish, oʻzgartirish va tarqatish mumkin; litsenziya hosila ishlarni ham GPL-3.0 bilan chiqarishni va asl mualliflik yozuvlarini saqlashni talab qiladi.\n\nDasturdagi uchinchi tomon komponentlar, jumladan Clash.Meta yadrosi, oʻz litsenziyalariga amal qiladi. Asl mualliflar oʻzgartirilgan yoki qayta tarqatilgan versiyalarda yuz bergan muammalar uchun javobgar emas.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Ochiq kodli litsenziya",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Dasturning oʻzi proksi serveri, tugun, obuna yoki tarmoqqa kirish xizmatini taqdim etmaydi hamda bunday xizmatlar provayderlari bilan sheriklik, vakillik yoki kafolat munosabatida emas.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Dastur obuna URL manzillaringizni, tugun tafsilotlarini, konfiguratsiya tarkibini, kirilgan saytlarni, ulanish yozuvlarini, trafik tarkibini yoki jurnallarni yigʻmaydi va yuklab yubormaydi. Bu maʼlumotlar qurilmangizda qoladi; ishlab chiqaruvchilar bunga kirib bormaydi.\n\nDastur tarmoqqa faqat bu kerak boʻlgan imkoniyatni ishlatganingizda chiqadi: masalan profil yangilanishda siz bergan obuna URL manzilini olish yoki yangilanishlarni tekshirishda GitHubga ulanish.\n\nDastur istalgan platformada tahlil yoki qulash hisoboti xizmatiga ega emas.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Maʼlumot yigʻish va maxfiylik",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Oxirigacha oʻqing",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Dasturdan yashayotgan joyingizda qonunga mos ishlatilishini taʼminlash oʻzingiz zimmasida; undan qilgan barcha harakatlaringiz va ularning oqibatlari uchun qonuniy masʼuliyatni faqat siz oʻz zimmasiga olasiz.\n\nImport qilgan obunalar, tugunlar va konfiguratsiyalar — oʻz tanlovingiz. Ularning manbai qonuniymi, tarkibi xavfsizmi va xizmati ishonchlimi — bu siz bilan ularning provayderlari oʻrtasidagi masala.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Sizning masʼuliyatingiz",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Yuqoridagi bayonni kiriting",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Bayonga mos kelmadi",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Tushunganingizni tasdiqlash uchun quyidagi bayonni pastdagi maydonga toʻliq kiriting:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Bayonni takrorlang",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Dastur — Clash.Meta (mihomo) yadrosi asosida yaratilgan ochiq kodli tarmoq proksi mijozidir. U faqat konfiguratsiya boshqaruvi, qoidalar asosida marshrutlash va trafikni uzatish kabi mahalliy vositalarni taqdim etadi.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Dasturning tabiati",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Obuna havolalari, konfiguratsiya fayllari, qoida toʻplamlari, skriptlar, tashqi resurslar va tashqi havolalar uchinchi tomonlar tomonidan taqdim etiladi. Ishlab chiqaruvchilar ularning qonuniyligini, aniqiligini, xavfsizligini yoki mavjudligini tekshira olmaydi va kafolatlamaydi.\n\nUchinchi tomon tarkibi tufayli kelib chiqqan maʼlumot oqishi, moddiy yoʻqotish, hisob bloklanishi yoki boshqa yoʻqotishlar siz bilan uchinchi tomon oʻrtasida hal qilinadi; ishlab chiqaruvchilar bunga javobgar emas.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Uchinchi tomon tarkibi",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Dastur faqat oʻrganish, almashish va texnik tadqiqot kabi tijoriy boʻlmagan maqsadlar uchun moʻljallangan. Uni tijoriy maqsadda ishlatish qatʼiyan taqiqlangan; bunga pullik tarqatish, birga sotish, tijoriy xizmatning bir qismi sifatida foydalanish yoki Dastur nomidan tijorat qilish kiradi, ammo bular bilan cheklanmaydi. Har qanday tijoriy faoliyat Dastur va uning ishlab chiqaruvchilari bilan aloqasiz.\n\nDasturdan mamlakatingiz yoki mintaqangiz qonun qoidalarini buzish uchun foydalanish qatʼiyan taqiqlangan; bunga qonuniy oʻrnatilgan tarmoqqa kirish cheklovlarini chetlab oʻtish, qonunsiz tarkibni tarqatish, tarmoq hujumlarini uyushtirish yoki boshqalarning qonuniy huquqlarini buzish kiradi, ammo bular bilan cheklanmaydi.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Foydalanish cheklovlari",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Dastur «oʻz holicha» va «mavjud holatida» taqdim etiladi; aniq hamda nazarda tutilgan kafolatlar, jumladan savdogarlik, muayyan maqsadga moslik, huquqlarni buzmaslik, uzluksiz mavjudlik, xatolar hamda xavfsizlik zaifliklaridan holi boʻlish kabilari bilan cheklanmagan holatda hech qanday kafolat berilmaydi.\n\nIshlab chiqaruvchilar Dastur ehtiyojlaringizni qondirishini yoki uzluksiz va xatoliklarsiz ishlashini kafolatlamaydi.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Kafolat yoʻq",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Uzilgan"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Yangi versiya topildi",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "DNS keshi tozalandi",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yozuv boʻlmasa, TUN har bir DNS soʻrovini 53 portga (any:53) oʻgʻirlab boradi.",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS oʻgʻirlash"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS rejimi"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yerga qoʻshilgan yozuvlar har bir URL va fayl profilining DNSini almashtiradi; qoʻshilmaganlar profilning oʻz sozlamasini saqlaydi. Maxsus profillar DNSini oʻz tarkibida belgilaydi.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS soʻrovlari"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Barcha DNS qayta belgilashlari o‘chiriladi va tanlangan hududning DNS serverlari qayta o‘rnatiladi.",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Yopishtirilgan"),
    "domain": MessageLookupByLibrary.simpleMessage("Domen"),
    "done": MessageLookupByLibrary.simpleMessage("Tayyor"),
    "download": MessageLookupByLibrary.simpleMessage("Yuklab olish"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Yuklab olish oʻtkazish qobiliyati",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Yangilanish yuklanmoqda",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Davomiyligi"),
    "edit": MessageLookupByLibrary.simpleMessage("Tahrirlash"),
    "editDashboard": MessageLookupByLibrary.simpleMessage(
      "Boshqaruv panelini tahrirlash",
    ),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Global qoidalarni tahrirlash",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Tarmoqni tahrirlash"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Proksini tahrirlash"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Proksi guruhini tahrirlash",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Qoidani tahrirlash"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSIDni tahrirlash"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Tahrirchi mavjud emas",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Sarflangan vaqt"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Boʻsh zaxira"),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("Ingliz tili"),
    "enabled": MessageLookupByLibrary.simpleMessage("Yoqilgan"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Qoʻlda kiritish"),
    "entries": MessageLookupByLibrary.simpleMessage(" ta yozuv"),
    "error": MessageLookupByLibrary.simpleMessage("Xato"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Xato tafsilotlari"),
    "es": MessageLookupByLibrary.simpleMessage("Ispan tili"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Oxirgi ilovalar roʻyxatidan yashirish",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan maqsad portlari",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan maqsad portlariga yoʻnalgan trafik TUN orqali oʻtmaydi.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Istisno filtri"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan interfeyslar",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "docker0 kabi chiqarilgan interfeyslardan kelgan trafik TUN orqali oʻtmaydi.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan manba portlari",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan manba portlaridan kelgan trafik TUN orqali oʻtmaydi.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Chiqarilgan SSIDlar"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan SSIDli Wi-Figa ulanganda ilovaning ishlash holati avtomatik almashadi.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan foydalanuvchi IDlari",
    ),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Chiqarilgan foydalanuvchi IDlardagi jarayonlardan kelgan trafik TUN orqali oʻtmaydi.",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("Chiqish"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Toʻliq ekrandan chiqish",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Chiqish tugunlari"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Kutilgan status"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Tugash vaqti"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Faylni eksport qilish"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "Jurnallarni eksport qilish",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Eksport qilindi"),
    "extend": MessageLookupByLibrary.simpleMessage("Kengaytirish"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Kengaytirish rejimi"),
    "extendScript": MessageLookupByLibrary.simpleMessage(
      "Kengaytirish skripti",
    ),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Tashqi boshqaruv",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Tashqi boshqaruv yadroni 9090 port orqali boshqarish imkonini beradi.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Tashqi boshqaruv maxfiy kaliti",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Tashqi havola"),
    "extra": MessageLookupByLibrary.simpleMessage("Qo‘shimcha"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Juda katta"),
    "fade": MessageLookupByLibrary.simpleMessage("Soʻnish"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filtri"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Fake-IP filtri rejimi",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP filtri rejimida qora roʻyxat mosliklarni istisno qiladi, oq roʻyxat faqat moslarni soxtalashtiradi, «rule» esa ularni qoidalar sifatida moslaydi.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP diapazoni"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Fake-IP diapazoni (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Zaxira filtri"),
    "file": MessageLookupByLibrary.simpleMessage("Fayl"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Fayl oʻzgartirildi. Oʻzgarishlar saqlansinmi?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filtr"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtrlar"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Jarayonni topish"),
    "floating": MessageLookupByLibrary.simpleMessage("Suzuvchi"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Profildagidek"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Tizim boʻyicha"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Shrift turi"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Oʻlcham"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Majburiy DNS mapping",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Majburiy DNS mapping domeni DNS mappingdan kelgan ulanishlarni ham aniqlaydi.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Majburiy domenlar"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Majburiy domenlar ham aniqlanadi; allaqachon domeni bor boshqa ulanishlar oʻzicha qoladi.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Yadro majburan qayta ishga tushirilsinmi?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Fransuz tili"),
    "general": MessageLookupByLibrary.simpleMessage("Umumiy"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yerga qoʻshilgan sozlamalar barcha profillardagi sozlamalarni almashtiradi. Qoʻshilmaganlari profilning oʻz qiymatini saqlaydi; profilda qiymat boʻlmasa, yadroning standart qiymati ishlatiladi.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo uchun kam xotira rejimi",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Oʻtish"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Yuklab olish"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Qoʻshilgan qoidalar sozlamasiga oʻting",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Skript sozlashga oʻtish",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Minnatdorchilik"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash ularning mehnati tufayli mavjud",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Toʻr"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("guruh"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishlar keshga saqlansinmi?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Kirish foydalanuvchisi boʻyicha hash",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage(
      "Salomatlik tekshiruvi",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Yordamchi xizmat mavjud emas, TUN rejimini yoqib boʻlmaydi. Tiklash uchun ReClashni qayta oʻrnating.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage(
      "Roʻyxatdan yashirish",
    ),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP ni yashirish"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Parolni yashirish"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Vaqti tugagan proksilarni yashirish",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Oxirgi kechikish testida vaqti tugagan proksilarni tashlab ketish",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Sakrash oraligʻi"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostname": MessageLookupByLibrary.simpleMessage("Host nomi"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage(
      "Hammasini tozalash",
    ),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Barcha tezkor tugma birikmalari olib tashlansinmi?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Kompozitor konfiguratsiyasi",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Kompozitor konfiguratsiyasiga faylni ulash qatorini ham qoʻshishingiz mumkin. Bu fayllar ReClash birikmalari bilan birga yangilanadi va tugmalarni yozib olish paytida vaqtincha tozalanadi. Ish stoli konfiguratsiyasi avtomatik oʻzgartirilmaydi; birikmalar ziddiyatini oʻsha yerda hal qiling.",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global tezkor tugmalar oyna yashirilganda ham ishlaydi. Tugmalar birikmasini yozib olish uchun amalni bosing.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Ish stoli tezkor tugmalari",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Ish stoli sozlamalarida buyruqni maxsus tugmalar birikmasiga tayinlang. ReClash ishlayotgan boʻlishi kerak, lekin oynasi yashirin qolishi mumkin. Bu global birikmalar ish stoli sozlamalarida boshqariladi.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Kompozitor konfiguratsiyasi fayllari mavjud emas. Yuqoridagi ish stoli buyruqlaridan foydalanishingiz mumkin.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Bu birikmalar ilova oynasi fokusda boʻlganda ishlaydi. Global tezkor tugmalar uchun quyidagi boʻlimda ish stoli buyruqlarini sozlang.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Tezkor tugmalarni boshqarish",
    ),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Belgilanmagan"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Standartlarni tiklash",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Barcha birikmalar standartlar bilan almashtirilsinmi?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "Xavfsiz rejim tezkor tugma amallarini o‘chiradi, ammo birikmalarni tahrirlash mumkin.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Roʿyxatdan oʿtmadi, uni boshqa ilova band qilgan boʿlishi mumkin",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("soat"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("Rang ohangi"),
    "icon": MessageLookupByLibrary.simpleMessage("Belgi"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Belgi yozuvlari"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Belgi toʻplamlari"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Hozircha belgi toʻplamlari yoʻq. Maxsus profil resurslari → Belgi toʻplamlari boʻlimida qoʻshing",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Belgi uslubi"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Toʻldirilgan"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Yashirin"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Oddiy"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Belgi URLsi"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Batareya optimallashtirishidan chiqarish",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Bu fayl import qilinishi mumkin boʻlgan konfiguratsiya emas",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Import hozirgi profildagi proksi guruhlar, qoidalar va sozlamalarni almashtiradi",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Fayldan import"),
    "importFromLink": MessageLookupByLibrary.simpleMessage(
      "Havola orqali import qilish",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL orqali import"),
    "inbound": MessageLookupByLibrary.simpleMessage("Kiruvchi"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Kiritilgan interfeyslar",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat kiritilgan interfeyslardan kelgan trafik TUN orqali oʻtadi; chiqarilgan interfeyslar endi amal qilmaydi.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage(
      "Kiritilgan foydalanuvchi IDlari",
    ),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat kiritilgan foydalanuvchi IDlardagi jarayonlardan kelgan trafik TUN orqali oʻtadi.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "Hech qachon tugamaydi",
    ),
    "init": MessageLookupByLibrary.simpleMessage("Initsializatsiya"),
    "initFailed": MessageLookupByLibrary.simpleMessage(
      "Ishga tushish amalga oshmadi",
    ),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash ishga tushayotganda xatoga uchradi va davom etolmaydi. Muammoni xabar qilish uchun tafsilotlarni nusxalang. Agar bu takrorlansa, maʼlumotlarni tozalash odatda ilovani qayta ishga tushirish imkonini beradi.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Tashabbuskor"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("Manba"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Proksi guruh nomini kiriting",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Qoida matnini kiriting",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage(
      "Yangilanishni o‘rnatish",
    ),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "Ilovalar roʻyxati ruxsati rad etildi, shuning uchun oʻrnatilgan ilovalarni koʻrsatib boʻlmaydi. Ruxsatni tizim sozlamalaridan qoʻlda bering.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berilmaguncha tizim oʻrnatilgan ilovalar roʻyxatini yashiradi. Ilovalar boʻyicha proksini sozlash uchun ruxsat bering.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Ilovalar roʻyxati ruxsati kerak",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Oʻrnatilgan shriftlar",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Aqlli tanlov"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interfeys nomi"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Chiquvchi ulanishlar uchun ishlatiladigan tarmoq interfeysi.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Chiquvchi interfeys",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Tozalash"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiyaga mos",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Oraliq"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Ichki tarmoq IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Zaxira fayli yaroqsiz",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "192.168.0.0/16 kabi CIDR koʻrinishidagi IP oraligʻini kiriting",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP belgisi 63 dan oshmasligi kerak",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Domen yoki IP manzil kiriting",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Yaroqli belgi toʻplami emas",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Obuna havolasi ham, proksi ulashish havolasi ham emas",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053 kabi manzil va port kiriting",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Faqat tcp yoki udp qoʻllanadi",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 yoki 8000-9000 kabi port yoki oraligʻ kiriting",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Bu QR kod profil havolasini oʻz ichiga olmaydi",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 yoki 8000-9000 kabi raqam yoki oraliqlarni / bilan ajratib kiriting",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID 32 UTF-8 baytdan oshmasligi kerak",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP manzil"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Suiisteʼmol tarixi"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proksi"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Belgilar"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Tashkilot"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP turini aniqlab boʻlmadi",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Yaxshi"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Daraja"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Oddiy"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Qayta tekshirish"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Xavfli"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Sifat"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Javob berdi"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Manbalar"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Boshqa chiquvchi IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Tur yoʻq"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Soʻrovlar limiti",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Tur"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Korporativ"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Data-markaz"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Mobil tarmoq"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Uy tarmogʻi"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Nomaʼlum tur"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP versiyasi"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 yoqilganda faqat IPv6 trafigi qabul qilinadi.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6 yoqilganda VPN kiruvchi IPv6 trafigiga ruxsat beradi.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "IPv6 kutish vaqti (ms)",
    ),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("Yapon tili"),
    "justNow": MessageLookupByLibrary.simpleMessage("Hozirgina"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive boʻsh holati",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive oraligʻi",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Kalit"),
    "kk": MessageLookupByLibrary.simpleMessage("Qozoqcha"),
    "ko": MessageLookupByLibrary.simpleMessage("Koreyscha"),
    "label": MessageLookupByLibrary.simpleMessage("Yorliq"),
    "language": MessageLookupByLibrary.simpleMessage("Til"),
    "large": MessageLookupByLibrary.simpleMessage("Katta"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Oxirgi yangilanish"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Ishga tushish tugallanmadi",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "Oʻtgan safar ilova ishga tushayotganda kutilmaganda yopildi. Avtomatik sozlash oʻtkazib yuborildi; ilovani qoʻlda ishga tushirib koʻrishingiz mumkin.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Joylashuv"),
    "license": MessageLookupByLibrary.simpleMessage("Litsenziya"),
    "licenses": MessageLookupByLibrary.simpleMessage("Litsenziyalar"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Ilova tarkibidagi paketlar",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Yorugʻ"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Qatorlarni koʻchirish"),
    "link": MessageLookupByLibrary.simpleMessage("Havola"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("Roʻyxat"),
    "listen": MessageLookupByLibrary.simpleMessage("Tinglash"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Tinglash marshrut belgisi",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Tinglash marshrut belgisi faqat Linuxda ishlaydi.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("Jonli ulanishlar"),
    "loading": MessageLookupByLibrary.simpleMessage("Yuklanmoqda…"),
    "local": MessageLookupByLibrary.simpleMessage("Mahalliy"),
    "localImage": MessageLookupByLibrary.simpleMessage("Mahalliy rasm"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Mahalliy tarmoq ruxsati rad etildi: gvisor steki ishlatilganda LAN tarmogʻiga yetib boʻlmaydi.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Mahalliy proksilar"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Joylashuv ruxsati",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Joylashuv ruxsati rad etildi, shuning uchun hozirgi Wi-Fi nomini oʻqib boʻlmaydi. Ruxsatni tizim sozlamalaridan qoʻlda bering.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Tizim Wi-Fi nomini oʻqish uchun joylashuv ruxsatini talab qiladi. Androidda \"Har doim ruxsat berish\"ni tanlang, aks holda ilova fonda ishlayotganda Wi-Fi nomini oʻqib boʻlmaydi.",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Joylashuv ruxsati talab qilinadi",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Jurnal"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log darajasi"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Logcatni oʻchirish loglar yozuvini yashiradi.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Loglar"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Loglar va diagnostika",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Jurnal testi"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback istisnosi"),
    "loose": MessageLookupByLibrary.simpleMessage("Keng"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Meynteyner"),
    "matchCase": MessageLookupByLibrary.simpleMessage(
      "Katta-kichik harflarni hisobga olish",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Manba IP boʻyicha mos kelish",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Maksimal xatolar soni",
    ),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("Kattalashtirish"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Rezident xotira",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("Ilova va umumiy"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Boʻsh uyum"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage(
      "Foydalanilayotgan uyum",
    ),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Yadro ishlamayapti",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Muhit qoʻshimcha xarajatlari",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage(
      "Gorutina steklari",
    ),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayonning rezident xotirasi asosida baholangan; tizim koʻrsatadigan qiymatdan farq qilishi mumkin.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Yadro ilova jarayoni ichida ishlaydi. Uning ulushi ijro muhiti statistikasi boʻyicha baholanadi, qolgani esa ilova va umumiy xotira sifatida hisoblanadi.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Xotira ma’lumotlari"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Ilova va yadro ishlatib turadigan xotira",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage(
      "Xotira boʻshatildi",
    ),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("Xabar testi"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Bu xabar."),
    "minimize": MessageLookupByLibrary.simpleMessage("Kichraytirish"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Chiqishda kichraytirish",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("daqiqa"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Aralash port"),
    "mode": MessageLookupByLibrary.simpleMessage("Rejim"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Bir rangli belgi"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monoxrom"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("Yana"),
    "name": MessageLookupByLibrary.simpleMessage("Nomi"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Pastki panel"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("Tab yorliqlari"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Doim"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage(
      "Hech qachon",
    ),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage(
      "Tanlangan",
    ),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Navigatsiya"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Varaqlar paneli",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Yon panel",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Tarmoq"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Soʻrov bekor qilindi",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Serverga ulanib boʻlmadi. Tarmoq ulanishingiz yoki proksi sozlamalarini tekshiring",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Uy Wi-Fi) yoki pastki tarmoq (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Server manzilini aniqlab boʻlmadi. URL toʻgʻriligini va DNS ishlayotganini tekshiring",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Tarmoq nomi"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Soʻrovlar juda koʻp (HTTP 429). Bir oz kuting va qayta urinib koʻring",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Chetlab o‘tish ro‘yxati va TUN MTU tanlangan hududning standart qiymatlariga qaytadi.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage(
      "Tarmoq maxfiy kaliti",
    ),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Tarmoq tezligi"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Trafikni oʻz zimmasiga olish",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Soʻrov kutish vaqti tugadi. Tarmoq yoki proksini tekshirib, qayta urinib koʻring",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Xavfsiz ulanish amalga oshmadi. Serverning sertifikati yaroqsiz boʻlishi yoki ulanish biror tomondan ushlab olinayotgan boʻlishi mumkin",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Tarmoq turi"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Keyingi moslik"),
    "no": MessageLookupByLibrary.simpleMessage("Yoʻq"),
    "noData": MessageLookupByLibrary.simpleMessage("Ma’lumot yoʻq"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Ma’lumot yoʻq"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Boshqa eslatmaslik",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Tarmoq yoʻq"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Tarmoqsiz ilovalar"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP aniqlanmasin"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Host nomi aniqlanmasin",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Mos natija topilmadi",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Tugunlar"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Bu tashqi resurs matn fayli emas",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Yoʻq"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Ishlamayapti"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Joriy proksi guruhini tanlab boʻlmaydi.",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Hozirgi tarmoq ishonchli emas",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Bildirishnoma"),
    "notificationActive": MessageLookupByLibrary.simpleMessage("Himoya faol"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Komponent qo‘shish",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Avtomatik guruh",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Server guruhi aniqlanmagan, shuning uchun bu qator ko‘rsatilmaydi",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Bildirishnoma komponentlari",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Bildirishnomani jonli holat komponentlaridan tuzing.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Komponentlar qo‘shilmagan",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Komponentlarsiz bildirishnoma faqat himoya holatini ko‘rsatadi.",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Tarkib"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Joriy server",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android bildirishnomasini yetkazish",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android bildirishnoma ruxsati tekshirilmoqda",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "ReClash bildirishnomalari bloklangan",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Bildirishnomalarni yetkazish mumkin",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash xizmat kanali o‘chirilgan",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Obuna eslatmalari kanali o‘chirilgan",
        ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Bo‘sh holatda tezlikni yashirish",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Qulf ekranida maxfiy ma’lumotlarni yashirish",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Xizmat bildirishnomalari va eslatmalar Android qulf ekranining maxfiylik sozlamalariga amal qiladi. Qulf ochilganda tafsilotlar ko‘rinadi.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Batafsil rejim jonli ma’lumot va to‘xtatish tugmasini ko‘rsatadi. Minimal rejim faqat himoya holatini ko‘rsatadi.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Tarmoq tezligi",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Maxfiylik"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("Eslatmalar"),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "Tanlangan guruh profilda yo‘q",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Xizmat kanali",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Seans trafigi",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Obuna eslatmalari kanali",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Obuna eslatmalari",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Obunaga e’tibor kerak bo‘lganda xabar berish",
        ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Bildirishnoma darajasi",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Batafsil",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Minimal",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Sinxronlash oraligʻi (daqiqa)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP vaqtni tizim soatidan emas, NTP serveridan oladi.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Profillar hali yoʻq. Avval profil qoʻshing",
    ),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuskatsiya"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfuskatsiya hosti"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfuskatsiya rejimi"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfuskatsiya parametri"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Obfuskatsiya paroli"),
    "onDemand": MessageLookupByLibrary.simpleMessage("Talab boʻyicha"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Bu quyi tarmoq keng tarmoq oraligʻiga ishonadi",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Ulanishlarni yopish",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Talab boʻyicha rejim chiqarilgan Wi-Fida proksini toʻxtatadi.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage(
      "To‘liq to‘xtatish",
    ),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Pauzada TUN o‘chiriladi va mahalliy proksi portlari yopiladi. Avtomatik davom ettirish uchun tarmoq kuzatuvi davom etadi.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Toʻxtatib turish"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Davom ettirish"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi tarmoqlarini oʻqib boʻlmadi. Qayta urinib koʻring yoki qoʻlda kiriting.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "SSID va quyi tarmoqni birga talab qilish",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Ikkala turdagi qoidalar bo‘lsa, faqat SSID va quyi tarmoq mos kelsa to‘xtatish",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Faqat proksi trafikini hisoblash",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Ixtiyoriy"),
    "options": MessageLookupByLibrary.simpleMessage("Tanlovlar"),
    "other": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Boshqa hissa qoʻshuvchilar",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Chiqish"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Chiqish"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Chiquvchi IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Chiqish rejimi"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Manzilni qayta belgilash",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Manzilni qayta belgilash yoqilganda ulanish asl manzil oʻrniga aniqlangan domenga ulanadi.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Qayta belgilashlar",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Sof IPni aniqlash"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Sof IPni aniqlash faqat IP manzilni oʻzida saqlagan ulanishlarni ham aniqlaydi.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Parol"),
    "paste": MessageLookupByLibrary.simpleMessage("Qoʻyish"),
    "peers": MessageLookupByLibrary.simpleMessage("Peerlar"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Albomdan tanlash"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Tarmoqni tanlash"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Atrofingizdagi Wi-Fi tarmoqlari",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi tarmoqlari topilmadi",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Yaqindagi Wi-Fi tarmoqlarini koʻrsatish uchun joylashuv ruxsati kerak",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Yaqin atrofdagi Wi-Fi tarmoqlarini koʻrish uchun joylashuvga ruxsat bering yoki tarmoqni qoʻlda kiriting.",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Yangilash"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Yaqindagi Wi-Fi tarmoqlari qidirilmoqda…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage(
      "Oynani doim yuqorida tutish",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Avval WebDAVni bogʻlang",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Skript nomini kiriting",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Yaroqli QR kod yuklang.",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Plagin"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage(
      "Plaginning shifrlash algoritmi",
    ),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plagin hosti"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plagin rejimi"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("Plagin paroli"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Plagin yoʻli"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Plagin foydalanuvchi nomi",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Boshqa port kiriting",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port sakrashi"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("Portlar"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage(
      "Oldindan boʻlishilgan kalit",
    ),
    "preferred": MessageLookupByLibrary.simpleMessage("Afzal"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Talablar"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Chiqish uchun orqaga tugmasini yana bir marta bosing",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Biror tugmani bosing",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Obuna takrorlanishining oldini olish",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Mavjud profil ishlatayotgan obuna havolasini rad etish",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Oldindan koʻrish"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Oldingi moslik"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Shaxsiy kalit"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Shaxsiy kalit parol iborasi",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Jarayon"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Yaroqli oraliq qiymatini kiriting.",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Avtomatik yangilanish oraligʻini kiriting.",
        ),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Profil oʻzgartirildi. Avtomatik yangilash oʻchirilsinmi?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Obuna sahifasi yuklanmoqda…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "Obuna yuklanmoqda…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Bu obuna havolasiga ega profil allaqachon mavjud",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "Obuna shifrlangan — kalit qoʻshishda soʻraladi.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage(
      "Muddati tugagan",
    ),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Obuna formati",
    ),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash uchun eng yaxshi format, avtomatik tanlanadi",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "Provayderdan",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Baʼzi qismlar qoʻllab-quvvatlanmaydi — qoʻshishdan oldin ularni koʻrsatamiz.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Obuna sahifasini yuklab bo‘lmadi. Uni baribir qo‘shishingiz mumkin.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Serverlar"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Bitta server",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage("Yangi obuna"),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "Hech narsa qo‘shilmadi. Boshqa formatni tanlab, qayta urinib ko‘rishingiz mumkin.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Cheksiz"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Amal qilish muddati",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Profil nomini kiriting.",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat shu profilga qoʻllanadi; qoʻshilmaganlar standart qiymati bilan ishlaydi.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat shu profilga qoʻllanadi va tarmoq sozlamalaridagi TUN qayta belgilash yozuvlaridan ustun turadi.",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Yaroqli profil URL manzilini kiriting.",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Profil URL manzilini kiriting.",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profillar"),
    "profilesSort": MessageLookupByLibrary.simpleMessage(
      "Profillarni tartiblash",
    ),
    "project": MessageLookupByLibrary.simpleMessage("Loyiha"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protokol"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Protokol parametri"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage(
      "Protokol versiyasi",
    ),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("E’lon"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Batafsil",
    ),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("O‘qish"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Bildirishnoma"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "Provayderdan",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Provayderga qaytarish",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Sozlamalarni provayderga qaytarish",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Siz o‘zgartirgan sozlamalar yana obunaga bo‘ysunadi",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Faqat masofaviy provayderlar qoʻllab-quvvatlanadi",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Tashqi resurslar"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proksilar"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proksi zanjiri"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proksi guruh"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proksi guruhi boʻsh",
    ),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Yadro ishga tushgach guruhlar bu yerda paydo boʻladi",
    ),
    "proxyGroupsCount": m78,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Proksi provayderlar",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proksi turi"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Keshni tozalash"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Ommaviy kalit"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Toʻliq qora"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Toʻliq qora rejim"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR kod"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Profil olish uchun QR kodni skanerlang",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Bu havola QR-kod uchun juda uzun. Uning oʻrniga havolani nusxalang.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Tezkor amallar"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Tezkor tahrirlash"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Guruh qo‘shish"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage(
      "Tarmoq turini qo‘shish",
    ),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Andoza qo‘shish"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Teg qo‘shish"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Qo‘shimcha"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Bu qismlar YAML orqali tahrirlanadi.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Barcha guruhlar"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Istalgan"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("Avto boshqaruv"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Ssenariy butun ulanishni boshqaradi: har bir tarmoq turidagi rejimni va har bir guruh nima qilishini. U tilga olmagan guruhlar o‘z profili bo‘yicha ishlaydi.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("Avtoga qaytish"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Muvozanatli"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Asosi"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Xatti-harakat"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "O‘zgarishlarni olib o‘tish",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "O‘zingizning tahrirlaringiz o‘zgarishsiz qoladi",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage(
      "Serverni almashtirish",
    ),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Almashtirish"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Tekshiruv"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Guruhda"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("Server topolmaydi"),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("bloklanganni ochadi"),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Tekshiruvlar"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Mavjudlik tekshiruvlari",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Shart qo‘shish"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Barcha shartlar"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Doim"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Istalgan shart"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("Istalgan server"),
    "rcxCondAtLeast": MessageLookupByLibrary.simpleMessage("kamida"),
    "rcxCondAtMost": MessageLookupByLibrary.simpleMessage("ko‘pi bilan"),
    "rcxCondClause": m82,
    "rcxCondCountry": MessageLookupByLibrary.simpleMessage("Mamlakat"),
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Maydon"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Katta-kichik harfni farqlamaslik",
    ),
    "rcxCondLess": MessageLookupByLibrary.simpleMessage("kam"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Moslik"),
    "rcxCondMore": MessageLookupByLibrary.simpleMessage("ko‘p"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Ko‘rsatilmagan"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("emas"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Operator"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Andoza"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("Matn sifatida"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Bu shartda guruhlar ichma-ich joylashgan, shuning uchun matn sifatida tahrirlanadi.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Qiymat"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Qiymatlar vergul bilan",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Ruxsat berish"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Ruxsat bermaguningizcha, guruh «Oddiy» profili bilan ishlaydi. Saytlarga faqat serverlaringiz orqali yoki tarmoqni sinash uchun ulaniladi.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("Ruxsat kerak"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Ulanadigan saytlar"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Uchinchi tomon saytlari na provayderingizga, na o‘rnatilgan profillarga tegishli.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Boshqaruv"),
    "rcxCountryAll": MessageLookupByLibrary.simpleMessage("Barcha mamlakatlar"),
    "rcxCountryOnServers": MessageLookupByLibrary.simpleMessage(
      "Serverlaringizda",
    ),
    "rcxCountryPickMany": MessageLookupByLibrary.simpleMessage(
      "Mamlakatlarni tanlang",
    ),
    "rcxCountryPickOne": MessageLookupByLibrary.simpleMessage(
      "Mamlakatni tanlang",
    ),
    "rcxCountryServers": m84,
    "rcxCountryVerified": MessageLookupByLibrary.simpleMessage("tekshirilgan"),
    "rcxDeleteProfile": m85,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Tarmoq diagnostikasi",
    ),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ridan-to‘g‘ri saytlar shu guruh orqali",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage(
      "Hozir yoqilgan",
    ),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Qoidalar to‘g‘ridan-to‘g‘ri yuboradigan saytlar ochilmay qolsa, ular shu guruh orqali o‘tadi. Mahalliy manzillar doim to‘g‘ridan-to‘g‘ri qoladi.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "Kutmoqda: to‘g‘ridan-to‘g‘ri saytlar hali ochiladi",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("Nusxalab tahrirlash"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Tejamkor"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Aniq"),
    "rcxEnergyToday": m86,
    "rcxExcept": m87,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Profil tomonidan chiqarilgan",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "«Serverni almashtirish» dan keyin o‘tkazildi",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage(
      "Ro‘yxatda yo‘q",
    ),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Hech bir afzallikka mos emas",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Hali tekshirilmagan",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage(
      "Server emas",
    ),
    "rcxExit": m88,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage(
      "Chiqish mamlakatini tekshirish",
    ),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Eksport"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Kamdan-kam"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Tez-tez"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Ishlayapti"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("Ishlatilmoqda"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Ishlamayapti"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage(
      "Tarmoq diagnostikasi",
    ),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Kirish mamlakati"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Chiqish mamlakati"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage(
      "Tekshiruvdan o‘tmaydi",
    ),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Tarmoq turi"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Kechikish, ms"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("O‘lchangan"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage(
      "Cheklangan tarmoq",
    ),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage(
      "Tekshiruvdan o‘tadi",
    ),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Kirish sahifasi"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Provayder"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("Server manzili"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Teg"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage("Ulanish turi"),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Protokol"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("UDP ni qo‘llaydi"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Butun guruh serverni qidirmasdan shu element orqali o‘tadi; hammasini topshirish uchun yuklama balanslagichni yoki ichki guruhni tanlang.",
    ),
    "rcxFixedOn": m89,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("Umumiy"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage(
      "Guruh profillari",
    ),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Aqlli guruh serverni qanday tanlaydi. O‘zingiznikini tahrirlash uchun, boshqasining nusxasini tahrirlash uchun bosing.",
    ),
    "rcxGroupSettings": MessageLookupByLibrary.simpleMessage(
      "Guruh sozlamalari",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Ishlayapti"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Ishlamayapti"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("Avval ishlagan"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Tekshirilmagan"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("Tarix"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Oldingi versiyalar",
    ),
    "rcxHubAuto": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yo‘naltirish",
    ),
    "rcxHubBundle": MessageLookupByLibrary.simpleMessage("Bu faylda"),
    "rcxHubChange": MessageLookupByLibrary.simpleMessage("O‘zgartirish"),
    "rcxHubCopyConfirm": MessageLookupByLibrary.simpleMessage("Nusxa yaratish"),
    "rcxHubCopyMessage": m90,
    "rcxHubCopyTitle": MessageLookupByLibrary.simpleMessage(
      "O‘z nusxangizni yaratasizmi?",
    ),
    "rcxHubDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Bu ssenariy nima qiladi",
    ),
    "rcxHubEverythingElse": MessageLookupByLibrary.simpleMessage(
      "Qolgan trafik",
    ),
    "rcxHubEverythingElseHint": MessageLookupByLibrary.simpleMessage(
      "Hech bir yo‘nalishga mos kelmagan trafik obunaning asosiy guruhi orqali o‘tadi.",
    ),
    "rcxHubGroupsEmpty": MessageLookupByLibrary.simpleMessage(
      "Hozircha birorta guruh avtomatik yo‘naltirish bilan boshqarilmaydi.",
    ),
    "rcxHubLibrary": MessageLookupByLibrary.simpleMessage("Kutubxona"),
    "rcxHubNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yo‘naltirishni ko‘rish uchun ulanishni boshlang",
    ),
    "rcxHubNetworks": MessageLookupByLibrary.simpleMessage("Tarmoqlar"),
    "rcxHubNetworksTitle": MessageLookupByLibrary.simpleMessage(
      "Rejim va tarmoqlar",
    ),
    "rcxHubNoProfile": MessageLookupByLibrary.simpleMessage("Obuna yo‘q"),
    "rcxHubNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Avval obuna qo‘shing: avtomatik yo‘naltirish uning guruhlari bilan ishlaydi.",
    ),
    "rcxHubOffHint": MessageLookupByLibrary.simpleMessage(
      "Yoqsangiz, ssenariy guruhlar va yo‘nalishlar uchun serverlarni tanlaydi.",
    ),
    "rcxHubOtherGroups": MessageLookupByLibrary.simpleMessage(
      "Boshqa guruhlar",
    ),
    "rcxHubOtherGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Bu ssenariy ham boshqaradigan obuna guruhlari.",
    ),
    "rcxHubOverview": MessageLookupByLibrary.simpleMessage("Umumiy"),
    "rcxHubRoutes": MessageLookupByLibrary.simpleMessage("Yo‘nalishlar"),
    "rcxHubRoutesHint": MessageLookupByLibrary.simpleMessage(
      "Trafik yuqoridan pastga birinchi mos yo‘nalish bo‘yicha o‘tadi.",
    ),
    "rcxHubRoutesOff": MessageLookupByLibrary.simpleMessage(
      "Ishlayotgan ssenariy yo‘q",
    ),
    "rcxHubRoutesOffHint": MessageLookupByLibrary.simpleMessage(
      "Yo‘nalishlar tanlangan trafikni, masalan bitta xizmatni, o‘z serverlari orqali yuboradi.",
    ),
    "rcxHubRoutesRuleOnly": m91,
    "rcxHubStartScenario": MessageLookupByLibrary.simpleMessage(
      "Ssenariy yaratish",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Profillarimga qo‘shish",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Bu profilni tekshirish uchun ilovaning yadrosini ishga tushiring.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Marshrutlash profilini import qilish",
    ),
    "rcxImported": m92,
    "rcxJournalFailure": m93,
    "rcxJournalMode": m94,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("tekshirilmoqda"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoqda ular ssenariydagi bir xil nomli guruhlarni almashtiradi; qolganlari barcha tarmoqlardagidek ishlaydi.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Kichik lotin harflari, raqamlar va defislar, 24 tagacha",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("ochiq internet"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("kirish sahifasi"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage(
      "Quyidagi holatda aniqlanadi",
    ),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Turlar yuqoridan pastga tekshiriladi; tarmoq birinchi mos kelganini oladi.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage(
      "faqat oq ro‘yxatlar",
    ),
    "rcxLadderAdd": MessageLookupByLibrary.simpleMessage("Qadam qo‘shish"),
    "rcxLadderAdvanced": MessageLookupByLibrary.simpleMessage(
      "Kengaytirilgan shart…",
    ),
    "rcxLadderAnyWorking": MessageLookupByLibrary.simpleMessage(
      "Istalgan ishlaydigan server",
    ),
    "rcxLadderCountry": MessageLookupByLibrary.simpleMessage("Mamlakat"),
    "rcxLadderEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Ayrim serverlarni ustun qo‘yish uchun qadam qo‘shing",
    ),
    "rcxLadderExceptCountries": MessageLookupByLibrary.simpleMessage(
      "Bu mamlakatlardan boshqasi",
    ),
    "rcxLadderFallThrough": MessageLookupByLibrary.simpleMessage(
      "hech biri ishlamasa",
    ),
    "rcxLadderFits": m95,
    "rcxLadderGroupHint": MessageLookupByLibrary.simpleMessage(
      "Bu tartib faqat shu guruh uchun. Profil tartibiga amal qilish uchun bo‘sh qoldiring.",
    ),
    "rcxLadderInherited": MessageLookupByLibrary.simpleMessage(
      "Xatti-harakatdan olingan — o‘z tartibingizni berish uchun qadamni tahrirlang",
    ),
    "rcxLadderLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Oxirgi chora qadamidagi serverlar boshqa hech bir qadamda, hatto pastdagisida ham, ishlaydigan server bo‘lmagandagina ishlatiladi.",
    ),
    "rcxLadderLatency": m96,
    "rcxLadderLatencyUnder": MessageLookupByLibrary.simpleMessage(
      "Kechikish chegarasi, ms",
    ),
    "rcxLadderNameContains": MessageLookupByLibrary.simpleMessage("Nomida bor"),
    "rcxLadderNameHas": m97,
    "rcxLadderNot": m98,
    "rcxLadderOther": MessageLookupByLibrary.simpleMessage("Boshqa shartlar"),
    "rcxLadderProvider": m99,
    "rcxLadderScenarioFirst": MessageLookupByLibrary.simpleMessage(
      "Hozir bu guruhni ssenariy boshqaryapti: ssenariy bergan serverlar tartibi bu tartibdan ustun turadi.",
    ),
    "rcxLadderServersIn": MessageLookupByLibrary.simpleMessage(
      "Bu qadamdagi serverlar",
    ),
    "rcxLadderStep": m100,
    "rcxLadderStranded": m101,
    "rcxLadderTag": m102,
    "rcxLadderTitle": MessageLookupByLibrary.simpleMessage("Serverlar tartibi"),
    "rcxLadderUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Oxirgi chora"),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Daraja"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Kengaytirilgan"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Oddiy"),
    "rcxLine": m103,
    "rcxLintCheckUnused": m104,
    "rcxLintConsent": m105,
    "rcxLintGroupMissing": m106,
    "rcxLintPoolEmpty": m107,
    "rcxLintTagUnused": m108,
    "rcxLintTierEmpty": m109,
    "rcxLintTierUnreachable": m110,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Asosiy guruh"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Avto-marshrutni yoqish",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash bu guruhda ishlaydigan serverni tanlab turadi va u ishlamay qolsa almashtiradi. Tekshiruvlar faqat tarmoqdan foydalanayotganingizda o‘tkaziladi.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Profillar va ssenariylar «Kengaytirilgan konfiguratsiya» → «Avto-marshrut» bo‘limida yaratiladi va tahrirlanadi.",
    ),
    "rcxMatchAdd": MessageLookupByLibrary.simpleMessage("Yozuv qo‘shish"),
    "rcxMatchCidr": MessageLookupByLibrary.simpleMessage("IP diapazoni"),
    "rcxMatchCustom": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "rcxMatchDomain": MessageLookupByLibrary.simpleMessage("Domen"),
    "rcxMatchGeoip": MessageLookupByLibrary.simpleMessage("IP toifasi"),
    "rcxMatchGeosite": MessageLookupByLibrary.simpleMessage("Sayt toifasi"),
    "rcxMatchHint": MessageLookupByLibrary.simpleMessage(
      "Bu yo‘nalish qo‘shimcha oladigan domenlar, IP diapazonlari, ilovalar yoki qoida to‘plamlari.",
    ),
    "rcxMatchInvalid": MessageLookupByLibrary.simpleMessage("Noto‘g‘ri qiymat"),
    "rcxMatchKeyword": MessageLookupByLibrary.simpleMessage(
      "Domen kalit so‘zi",
    ),
    "rcxMatchMore": m111,
    "rcxMatchNext": MessageLookupByLibrary.simpleMessage("Keyingi"),
    "rcxMatchNoResolve": MessageLookupByLibrary.simpleMessage(
      "Domenlarni aniqlamaslik",
    ),
    "rcxMatchNone": MessageLookupByLibrary.simpleMessage("Trafik tanlanmagan"),
    "rcxMatchPickHint": MessageLookupByLibrary.simpleMessage(
      "Bu yo‘nalish oladigan xizmatlarni tanlang; o‘z yozuvlaringizni ham qo‘shishingiz mumkin.",
    ),
    "rcxMatchProcess": MessageLookupByLibrary.simpleMessage("Ilova"),
    "rcxMatchRuleSet": MessageLookupByLibrary.simpleMessage(
      "Qoidalar to‘plami",
    ),
    "rcxMatchServices": MessageLookupByLibrary.simpleMessage("Xizmatlar"),
    "rcxMatchSuffix": MessageLookupByLibrary.simpleMessage(
      "Domen va subdomenlar",
    ),
    "rcxMatchType": MessageLookupByLibrary.simpleMessage("Turi"),
    "rcxMatchTypeHint": MessageLookupByLibrary.simpleMessage(
      "Domen qo‘shimchasi barcha subdomenlarni ham qamraydi.",
    ),
    "rcxMatchValue": MessageLookupByLibrary.simpleMessage("Qiymat"),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "O‘zgarishlarni olib o‘tib bo‘lmadi",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage(
      "O‘zgarishlar olib o‘tildi",
    ),
    "rcxMergedConflicts": m112,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Avto"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Serverlar tartibi bo‘yicha eng yaxshi ishlayotgan serverni tanlaydi va u ishdan chiqqanda almashtiradi.",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Rejimni ssenariyga qaytarish",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoqda rejimni ssenariy belgilaydi",
    ),
    "rcxModeIs": m113,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("O‘zgartirmaslik"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Qo‘lda"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Serverni proksi ro‘yxatida o‘zingiz tanlaysiz; avto-marshrut uni hech qachon almashtirmaydi.",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Rejimni o‘zingiz tanlagansiz; ssenariy siz «Avto» ni tanlamaguncha kutadi",
    ),
    "rcxModePinnedHint": m114,
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoqda rejim sizniki",
    ),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Sizning ruxsatingiz kerak",
    ),
    "rcxNetwork": m115,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Tarmoq turlari"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Yangi profil"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Yangi ssenariy"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("Bu tarmoqda"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("o‘tmaydi"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("quyidagilardan biri"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("teng"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("teng emas"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("mos keladi"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("muvaffaqiyatli o‘tadi"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage(
      "Tarmoq bo‘yicha o‘zgarishlar",
    ),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage(
      "Guruhning o‘z profili",
    ),
    "rcxOwnProfileHint": MessageLookupByLibrary.simpleMessage(
      "Guruh o‘z sozlamalaridagi xatti-harakatni saqlaydi.",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "Shablon to‘g‘ri muntazam ifoda emas",
    ),
    "rcxPendingTier": m116,
    "rcxPinned": m117,
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Biriktirilgan"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Chiqarib tashlash"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Ishlatish"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Guruhda server yo‘q",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "Joriy sozlamada bu guruh selektor emas",
    ),
    "rcxProblemProfileInvalid": m118,
    "rcxProblemProfileMissing": m119,
    "rcxProblemStoreFailed": m120,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "rcxProfileDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Bu profil nima qiladi",
    ),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "Guruh poolda qoldirilgan serverlar orasidan shu profil bo‘yicha server tanlaydi.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Amal"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Bitta elementga topshirish",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Element"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Server tanlash"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage(
      "Bu eng yaxshi server",
    ),
    "rcxReasonBetterTier": m121,
    "rcxReasonChangeServer": m122,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Yaxshiroq nomzod tekshirilmoqda",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Tezroq serverni yana o‘lchash kerak",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Yaqinda almashtirildi; keyingisigacha kutmoqda",
    ),
    "rcxReasonFailover": m123,
    "rcxReasonFaster": m124,
    "rcxReasonFixed": m125,
    "rcxReasonFixedMissing": m126,
    "rcxReasonFlapLimit": m127,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Biriktirilgan server saqlanmoqda",
    ),
    "rcxReasonIdle": m128,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Mavjud eng yaxshi server tanlandi",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage(
      "Qo‘lda boshqariladi",
    ),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Tarmoq o‘zgardi",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "Tarmoq ishlamayotganga o‘xshaydi; serverlar ayblanmaydi",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "Almashtirish uchun boshqa ishlaydigan server yo‘q",
    ),
    "rcxReasonOutOfPool": m129,
    "rcxReasonPaused": m130,
    "rcxReasonRouteInvalid": m131,
    "rcxReasonRouteNameTaken": m132,
    "rcxReasonRouteToMissing": m133,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Serverni tanlab bo‘lmadi",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ridan-to‘g‘ri saytlar yana to‘g‘ridan-to‘g‘ri o‘tadi",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ridan-to‘g‘ri saytlar endi shu guruh orqali o‘tadi",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Ishlaydigan server yo‘q; joriysi saqlanmoqda",
    ),
    "rcxReasonSwitchFixed": m134,
    "rcxReasonSwitchPinned": m135,
    "rcxReasonSwitchStranded": m136,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Ishlayapti; nosozlikkacha saqlanadi",
    ),
    "rcxRouteAdd": MessageLookupByLibrary.simpleMessage("Yo‘nalish qo‘shish"),
    "rcxRouteChoose": MessageLookupByLibrary.simpleMessage("Tanlash"),
    "rcxRouteEdit": MessageLookupByLibrary.simpleMessage(
      "Yo‘nalishni tahrirlash",
    ),
    "rcxRouteGroup": MessageLookupByLibrary.simpleMessage("Yo‘nalish yaratgan"),
    "rcxRouteGroupHint": m137,
    "rcxRouteName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "rcxRouteNameLong": MessageLookupByLibrary.simpleMessage("Nom juda uzun"),
    "rcxRouteNameReserved": MessageLookupByLibrary.simpleMessage(
      "Bu nom band qilingan",
    ),
    "rcxRouteNew": MessageLookupByLibrary.simpleMessage("Yangi yo‘nalish"),
    "rcxRouteSend": MessageLookupByLibrary.simpleMessage("Yuborish yo‘li"),
    "rcxRouteSendAutoHint": MessageLookupByLibrary.simpleMessage(
      "Yo‘nalishning o‘z guruhi quyidagi tartibda eng yaxshi serverni tanlaydi.",
    ),
    "rcxRouteSendDirectHint": MessageLookupByLibrary.simpleMessage(
      "Bu trafik proksidan o‘tmaydi.",
    ),
    "rcxRouteSendFixed": MessageLookupByLibrary.simpleMessage("Bitta server"),
    "rcxRouteSendFixedHint": MessageLookupByLibrary.simpleMessage(
      "Bu trafik doim tanlangan server yoki guruh orqali o‘tadi.",
    ),
    "rcxRouteTarget": MessageLookupByLibrary.simpleMessage("Server"),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Ssenariy"),
    "rcxScenarioDrives": m138,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Guruhlar"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Asosiy guruh — oxirgi qoida trafikni yuboradigan guruh; «Barcha guruhlar» bu yerda ko‘rsatilmagan tanlov guruhlarini qamrab oladi.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Tarmoqlarni to‘g‘ridan-to‘g‘ri diagnostika orqali aniqlang va har birida rejim hamda guruhlarni o‘zgartiring.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("Ulanish rejimi"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("O‘chiq"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Ssenariylar"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Ssenariy butun ulanishni boshqaradi. O‘zingiznikini tahrirlash uchun, boshqasining nusxasini tahrirlash uchun bosing.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Serverlar"),
    "rcxServersMatch": m139,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("Nom shabloni"),
    "rcxSettingsLink": MessageLookupByLibrary.simpleMessage(
      "Avto-marshrut sozlamalari",
    ),
    "rcxSettingsLinkHint": MessageLookupByLibrary.simpleMessage(
      "Profillar, ssenariylar va yo‘nalishlar",
    ),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("Aqlli guruhlar"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("O‘rnatilgan"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "Asl profil o‘zgardi",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Nima o‘zgardi"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("Provayderdan"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Meniki"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Hech bir server mos kelmasa",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ridan-to‘g‘ri o‘tish",
    ),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Joriy serverni saqlash",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Almashtirish"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Teg nomi"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Faqat lotin harflari, raqamlar, - va _, 24 tagacha belgi",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Teglar"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Teg serverlar to‘plamiga bir marta nom beradi, uni afzalliklarda tag(name) ko‘rinishida ishlatish mumkin.",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("uchinchi tomon"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Yorliq"),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Avto-marshrut"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Tarjimalar"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage(
      "Bu guruh uchun avto-marshrutni o‘chirish",
    ),
    "rcxTurnOffHint": MessageLookupByLibrary.simpleMessage(
      "Guruh joriy serverini saqlab qoladi va o‘zi almashtirishni to‘xtatadi.",
    ),
    "rcxUntilCheck": m140,
    "rcxUntilConfirm": m141,
    "rcxUntilDwell": m142,
    "rcxUseCheck": m143,
    "rcxUseDiagnostic": m144,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage(
      "chiqish mamlakatini tekshirish",
    ),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Ogohlantirishlar"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Nega bu server"),
    "rcxWhyCount": m145,
    "rcxWouldDo": MessageLookupByLibrary.simpleMessage("Avto-marshrut yoqilsa"),
    "rcxWouldServers": m146,
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Oxirgi soʻrovlar"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Tavsiya etilgan"),
    "recordType": MessageLookupByLibrary.simpleMessage("Yozuv turi"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir port"),
    "redo": MessageLookupByLibrary.simpleMessage("Qayta qilish"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Hududni qo‘llash"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "Hudud yoki ilova ro‘yxatlari o‘zgardi. Joriy sozlamalar bilan tanlovni takrorlang.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu hududga mos ilovalar topilmadi. Ro‘yxatlaringiz o‘zgarmadi.",
    ),
    "regionAppsPreview": m147,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Ilova tanlovini oldindan ko‘rish",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS serverlari"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Xizmat tekshiruvlari",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Nima o‘zgaradi",
    ),
    "regionChina": MessageLookupByLibrary.simpleMessage("Xitoy"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "O‘zingiz o‘zgartirgan qiymatlar o‘z holicha qoladi.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Misr"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Mamlakatingiz uchun DNS serverlari, TUN MTU, chetlab o‘tish ro‘yxati va xizmat tekshiruvlarini tanlaydi. Interfeys tili o‘zgarmaydi.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Eron"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Sozlamalar o‘zgarmaydi.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Xizmat tekshiruvlari o‘chirilgan",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Tanlanmagan"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Boshqa mamlakat"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Ushbu qurilma uchun tavsiya etiladi",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Rossiya"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Ilovalarni hudud bo‘yicha tanlash",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Hududiy ilova tavsiyalaridan foydalanish uchun avval qo‘llab-quvvatlanadigan hududni tanlang.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Hudud profili"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Hududiy moslashuv",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage(
      "Xotirani boʻshatish",
    ),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Xotirani boʻshatib boʻlmadi",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Masofaviy"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Masofaviy manzil",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Masofaviy DNS aniqlash",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Olib tashlash"),
    "rename": MessageLookupByLibrary.simpleMessage("Nomini oʻzgartirish"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Obunani yangilash",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Almashtirish"),
    "replaceAll": MessageLookupByLibrary.simpleMessage(
      "Hammasini almashtirish",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Soʻrov"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage(
      "Soʻrov sarlavhalari",
    ),
    "requests": MessageLookupByLibrary.simpleMessage("Soʻrovlar"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Soʻrovlar va yangilanishlar",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Majburiy"),
    "reset": MessageLookupByLibrary.simpleMessage("Qayta tiklash"),
    "resetAllData": MessageLookupByLibrary.simpleMessage(
      "Barcha maʼlumotlarni tiklash",
    ),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage(
      "Hammasini oʻchirish",
    ),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Barcha profillar, sozlamalar, skriptlar, fon rasmlari va kesh butunlay oʻchiriladi. Zaxira nusxa arxivlari saqlanadi. Shundan soʻng ilova yopiladi. Bu amalni bekor qilib boʻlmaydi.",
    ),
    "resetAllDataWait": m148,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Bu sahifada oʻzgarishlar bor. Asliga qaytarilsinmi?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Qayta tiklansinmi?"),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Maʼlumotlar oʻchirilmoqda…",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yangilanish oraligʻi",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yangilanish oraligʻi 0 dan katta boʻlishi kerak",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resurslar"),
    "respectRules": MessageLookupByLibrary.simpleMessage(
      "Qoidalarga amal qilish",
    ),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Qoidalarga amal qilish DNS ulanishlarini qoidalar boʻyicha yoʻnaltiradi; Proxy Server Nameserver kerak.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Javob kodi"),
    "restart": MessageLookupByLibrary.simpleMessage("Qayta ishga tushirish"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Yadro qayta ishga tushirilsinmi?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Tiklash"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Barcha ma’lumotlarni tiklash",
    ),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Standart qiymatlarni tiklash",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Faqat profillarni tiklash",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Tiklash strategiyasi",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("Mos"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Qayta belgilash",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Muvaffaqiyatli tiklandi",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Natija"),
    "retry": MessageLookupByLibrary.simpleMessage("Qayta urinish"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Marshrut manzillari"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Marshrutdan chiqarilgan manzillar",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Marshrut belgisi"),
    "ru": MessageLookupByLibrary.simpleMessage("Rus tili"),
    "rule": MessageLookupByLibrary.simpleMessage("Qoida"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Mantiqiy AND qoidasi",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Toʻliq domenga mos keladi",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Domen kalit soʻziga mos keladi",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Domen muntazam ifodasi boʻyicha mos keladi",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Domen oxirgi qismiga mos keladi",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Yulduzcha belgilar bilan mos keladi; faqat * va ? ishlatiladi",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP belgisiga mos keladi (faqat tproxy UDP kirishida)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Manzil port oraligʻiga mos keladi",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "IPning mamlakat kodiga mos keladi",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite ichidagi domenga mos keladi",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Kirish nomiga mos keladi",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Kirish portiga mos keladi",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Kirish turiga mos keladi",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Kirish foydalanuvchi nomiga mos keladi; bir nechta nomni / bilan ajratib yozing",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IPning ASNiga mos keladi",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP manzil oraligʻiga mos keladi; IP-CIDR6 shunchaki boshqa nom",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IP manzil oraligʻiga mos keladi",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IPning oxirgi qismiga mos keladi",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Barcha soʻrovlarga mos keladi, hech qanday shart kerak emas",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP yoki UDPga mos keladi",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Mantiqiy NOT qoidasi",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Mantiqiy OR qoidasi",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayon nomi boʻyicha mos keladi; Androidda paket nomiga mos tushadi",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayon nomi muntazam ifodasi boʻyicha mos keladi; Androidda paket nomiga mos tushadi",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayon nomi yulduzcha belgilari boʻyicha mos keladi; faqat * va ? ishlatiladi",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Toʻliq jarayon yoʻli boʻyicha mos keladi",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayon yoʻli muntazam ifodasi boʻyicha mos keladi",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Jarayon yoʻli yulduzcha belgilari boʻyicha mos keladi; faqat * va ? ishlatiladi",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Qayta moslash nomiga mos keladi; bir nechta nomni / bilan ajratib yozing",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Qoida toʻplamini nazarda tutadi; rule-providers talab qilinadi",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Manba IPning mamlakat kodiga mos keladi",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Manba IPning ASNiga mos keladi",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Manba IP manzil oraligʻiga mos keladi",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Manba IPning oxirgi qismiga mos keladi",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Manba port oraligʻiga mos keladi",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Ichki qoidaga yoʻnaltiradi; qavslarga e’tibor bering",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux foydalanuvchi IDsiga mos keladi",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Qoida boʻsh"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Qoidalar har biri alohida qoida boʻlgan YAML roʻyxati boʻlishi kerak, masalan - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent toʻgʻridan-toʻgʻri",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS ni bloklash",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Proksi loopbackini bloklash",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage(
      "QUIC ni bloklash",
    ),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage(
      "STUN ni bloklash",
    ),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "LAN toʻgʻridan-toʻgʻri",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple va Microsoft toʻgʻridan-toʻgʻri",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Qoida provayderlar"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Qoida toʻplami"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Qoida toʻplamida ishlatib boʻladigan yozuvlar yoʻq",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Bu mrs faylini oʻqib boʻlmaydi",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Qoida toʻplamida domenlar bilan IP oraligʻi aralashgan, shu sababli uning turini aniqlab boʻlmaydi",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Qoida moʻljali"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "Qoida qoʻllab-quvvatlanadigan tur bilan boshlanishi kerak, masalan DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Qoidalar"),
    "rulesCount": m149,
    "runTime": MessageLookupByLibrary.simpleMessage("Ishlash vaqti"),
    "running": MessageLookupByLibrary.simpleMessage("Ishlamoqda"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Ishlash konfiguratsiyasi",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Xavfsiz rejim"),
    "safeModeAppTitle": m150,
    "saturation": MessageLookupByLibrary.simpleMessage("Toʻyinganlik"),
    "save": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishlar saqlansinmi?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Skript"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Skript rejimi: butun profilni kengaytirish skripti bilan qayta yozadi",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Tanlanganga oʻtish",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Qidirish"),
    "seconds": MessageLookupByLibrary.simpleMessage("soniya"),
    "secondsCount": m151,
    "secretKey": MessageLookupByLibrary.simpleMessage("Kalit"),
    "sectionsInEffect": m152,
    "select": MessageLookupByLibrary.simpleMessage("Tanlash"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Barchasini tanlash"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Qoida toʻplamini tanlang",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Ajratish strategiyasini tanlang",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Tanlangan"),
    "send": MessageLookupByLibrary.simpleMessage("Yuborish"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Telefondan yuborish",
    ),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Telefondagi havola import qilinsinmi?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Bu qurilma mahalliy tarmoqqa ulanmagan",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Obuna havolasi yoki proksini ulashish havolasi",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Yuborildi. Boshqa qurilmada importni tasdiqlang.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "ReClash ilovasiga havola yuborish",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Telefondan havola olish uchun ReClash ilovasiga mahalliy tarmoqqa kirish imkonini beruvchi «Yaqin-atrofdagi qurilmalar» ruxsati kerak. Uni ilova sozlamalarida yoqing.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Kodni telefon kamerasi bilan skanerlang va ochilgan sahifaga havolani joylang. Ikkala qurilma ham bir tarmoqqa ulangan boʻlishi kerak.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serviceAbnormalCount": m153,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Barchasi mavjud",
    ),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Faol xizmatlarni avtomatik tekshirish",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Barcha xizmatlarni tekshirish",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Mavjud"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloklangan"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage(
      "Hammasini tekshirish",
    ),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "Faqat ulanganda tekshirish",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Tez orada"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Provayder bloklangan",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Tekshirib boʻlmadi"),
    "serviceManage": MessageLookupByLibrary.simpleMessage(
      "Xizmatlarni sozlash",
    ),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Faqat originallar",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Tekshirilmagan"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Kirish cheklangan",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Boshqaruv panelida koʻrinadi",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Xizmatlar holati"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Mavjud emas"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Region qoʻllab-quvvatlanmaydi",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("sozlamalar"),
    "settings": MessageLookupByLibrary.simpleMessage("Sozlamalar"),
    "settingsCount": m154,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Bu profil shifrlangan. Davom etish uchun age kalitini kiriting.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Bu server alohida tekshiruvga javob berdi. Unga o‘ting va to‘liq yo‘nalishni qayta tekshiring.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "ReClash ochilganda ulanish",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Bu ulanishni ilova bilan birga boshlash.",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Sozlamalarni o‘zgartirish",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Ulanishni tekshirish",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "Natija barcha ilova yoki saytlarga emas, shu yo‘nalishga tegishli.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Tanlangan bitta yo‘nalishni tekshiramiz. Tizim ruxsat so‘rovlari alohida ochiladi.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanish va tekshirish",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Tasdiqlandi"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "Tanlangan yo‘nalish javob berdi. Trafik profil qoidalariga amal qiladi.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanish ishlayapti",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Proksi manzilini nusxalash",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("Barcha ilovalar"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN qurilma trafigini ushlaydi. Tizim ruxsat so‘rashi mumkin.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android VPN ulanishini yaratish uchun ruxsat so‘raydi. Ilovalarni kirish sozlamalarida tanlash mumkin.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash’dan foydalanadigan ilovalarni tanlang. Qaysi ulanishlar serverdan foydalanishini profil qoidalari belgilaydi.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Ilovalarni o‘zim sozlayman",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Ulamoqchi bo‘lgan har bir ilovada mahalliy proksi manzilini belgilang.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Barcha trafikni ushlash uni server orqali yuborish degani emas. To‘g‘ridan-to‘g‘ri yo‘nalishlar saqlanadi.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Tizim proksisi",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Tizim proksisini qo‘llamaydigan ilovalar to‘g‘ridan-to‘g‘ri ulanadi.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Qaysi ilovalar ulansin?",
    ),
    "setupDirectApps": m155,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "Mahalliy ilovalar topilmadi. Saytlar baribir to‘g‘ridan-to‘g‘ri ochiladi.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Ular VPN’siz ishlaydi. Ro‘yxatni keyinroq kirish nazoratida o‘zgartirishingiz mumkin.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Mahalliy ilovalar qidirilmoqda…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Mamlakatingiz xizmatlari serversiz ochiladi: tezroq, banklar va davlat saytlari sizni bloklamaydi. Umumiy qoidalarga quyidagilar qo‘shiladi:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Mahalliy saytlar va ilovalar — to‘g‘ridan-to‘g‘ri",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Tafsilotlar"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanish e’tibor talab qiladi",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Har qanday tanlovni sozlamalarda o‘zgartirishingiz mumkin.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage(
      "Davom etish",
    ),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Shartlarni o‘qishdan oldin tilni tanlang. Uni keyin o‘zgartirishingiz mumkin.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("Tilni tanlang"),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "Sozlash tugallanmagan; ulanish tekshirilmagan.",
    ),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash yopiladi. Tanlovingiz saqlanadi va sozlash keyingi ishga tushirishda davom etadi.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Sozlashdan chiqasizmi?",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Ulamoqchi bo‘lgan ilovalarda ushbu manzilni belgilang. Bu tekshiruv ilovalar sozlanganini tasdiqlamaydi.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Mahalliy proksi tayyor",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Tekshirilmagan"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "Yo‘nalish javob berdi, ammo ayrim tekshiruvlar tasdiqlanmadi.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Ulandi, cheklovlar bor",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Tizim oynasida ulanishga ruxsat bering, qayta urinib ko‘ring yoki boshqa qamrovni tanlang.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Ruxsat kerak",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Boshqa server qidirilmoqda",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Ulanish ishga tushmoqda",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage(
      "Yadro ishga tushmoqda",
    ),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Chiqish nuqtasi tasdiqlanmoqda",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Profil qo‘llanmoqda",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Yo‘nalish tekshirilmoqda",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Xizmatlar tekshirilmoqda",
    ),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Davom etish uchun profil qo‘shing yoki tanlang.",
    ),
    "setupProfileCount": m156,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash serverlarni taqdim etmaydi. Provayderingiz obunasini yoki konfiguratsiyasini import qiling.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Profilni import qilish",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Boshqa profil qo‘shish",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Provayder xati, boti yoki shaxsiy kabinetidagi havolani qo‘ying yoki fayl yoxud QR-kod tanlang.",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Obuna yoki ulashish havolasi",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Profil tayyor"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage(
      "Keyinroq sozlash",
    ),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanish profilini qo‘shish",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Ulanishingiz"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Tekshiruv"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Qamrov"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Hudud"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Tavsiya etiladi"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Profil standartlarini saqlash",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Hududiy sozlamalar o‘zgarmaydi.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash DNS, MTU va to‘g‘ridan-to‘g‘ri yo‘nalishlarni mamlakatingiz tarmoqlariga moslaydi. Interfeys tili o‘zgarmaydi.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Qayerdan ulanasiz?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Hech narsa tanlamasangiz, joriy hududiy sozlamalar o‘zgarmaydi.",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Qayta tekshirish"),
    "setupReport": MessageLookupByLibrary.simpleMessage("Tekshiruv hisoboti"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Ulanishga ruxsat berish",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage("Ulanishni sozlash"),
    "setupResume": MessageLookupByLibrary.simpleMessage(
      "Sozlashni davom ettirish",
    ),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "Tekshiruv vaqtida yo‘nalish o‘zgardi. Joriy ulanishni qayta tekshiring.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "Xavfsiz rejim haqiqiy ulanishni boshlamaydi. Sozlamani saqlang yoki oddiy yig‘ilmada sinab ko‘ring.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Tanlovlaringizni saqlab bo‘lmadi. Qayta urinib ko‘ring.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Ulanmasdan saqlash",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Tanlovlaringiz saqlandi. Tayyor bo‘lganda boshqaruv panelidan ulanishingiz mumkin.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("Keyinroq ulanish"),
    "setupStepStatus": m157,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Tanlovlaringiz saqlandi. Avvalgi ulanish to‘xtatilmadi.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Tekshiruv to‘xtatildi",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Boshqa qamrovni tanlang: ba’zi tarmoqlar VPN’ni bloklaydi.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Internet ReClash’siz ishlayotganiga ishonch hosil qiling.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Profilni yangilang yoki sozlashdan keyin boshqa serverni tanlang.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage(
      "Nimalarni sinab ko‘rish mumkin",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Birinchi ulanish"),
    "setupTryServer": m158,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Javob yo‘q"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "Ulanish boshlandi, ammo tanlangan yo‘nalish yetarli natija bermadi.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanish tasdiqlanmadi",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "Amal yakunlanmadi. Qayta urinib ko‘ring yoki tafsilotlarni oching.",
    ),
    "shareLinkUnreadable": m159,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Havolalardan proksi oʻqib boʻlmadi",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Bu profilni import qilish uchun kodni boshqa qurilmadagi ReClash orqali skanerlang.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Koʻrsatish"),
    "showLess": MessageLookupByLibrary.simpleMessage("Yigʻish"),
    "showMore": MessageLookupByLibrary.simpleMessage("Yoyish"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Bildirishnomadagi «Toʻxtatish» tugmasi",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Parolni koʻrsatish"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Yon panel"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Yon panelni xiralashtirish",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Oyna ortidagi xiralashgan ish stolini yon panel orqali koʻrsatish",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage(
      "Yashirin ishga tushirish",
    ),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Yashirin ishga tushirish oynani koʻrsatmasdan ishga tushiradi.",
    ),
    "simpleDashboardDetailed": MessageLookupByLibrary.simpleMessage(
      "Batafsil boshqaruv paneli",
    ),
    "simpleDashboardEditWidgets": MessageLookupByLibrary.simpleMessage(
      "Vidjetlarni tahrirlash",
    ),
    "simpleDashboardEmpty": MessageLookupByLibrary.simpleMessage(
      "Hozircha vidjetlar yo‘q. Ularni tahrirlovchida qo‘shing.",
    ),
    "simpleDashboardHome": MessageLookupByLibrary.simpleMessage("Bosh sahifa"),
    "simpleDashboardSimple": MessageLookupByLibrary.simpleMessage(
      "Oddiy boshqaruv paneli",
    ),
    "simpleDashboardWidgets": MessageLookupByLibrary.simpleMessage("Vidjetlar"),
    "simpleDaysCount": m160,
    "simpleIpBusiness": MessageLookupByLibrary.simpleMessage(
      "Tashkilot manzili",
    ),
    "simpleIpGoodDesc": MessageLookupByLibrary.simpleMessage(
      "CAPTCHA va «VPN» bloklari kamdan-kam uchraydi.",
    ),
    "simpleIpHosting": MessageLookupByLibrary.simpleMessage(
      "Ma‘lumot markazi manzili",
    ),
    "simpleIpLevelClean": MessageLookupByLibrary.simpleMessage("Toza"),
    "simpleIpLevelNormal": MessageLookupByLibrary.simpleMessage("Oddiy"),
    "simpleIpLevelRisky": MessageLookupByLibrary.simpleMessage("Xavf"),
    "simpleIpMobile": MessageLookupByLibrary.simpleMessage(
      "Mobil tarmoq manzili",
    ),
    "simpleIpNormalDesc": MessageLookupByLibrary.simpleMessage(
      "Ba‘zi saytlar CAPTCHA so‘rashi mumkin.",
    ),
    "simpleIpReal": MessageLookupByLibrary.simpleMessage("Haqiqiy manzilingiz"),
    "simpleIpRealDesc": MessageLookupByLibrary.simpleMessage(
      "Provayderingiz va saytlar qayerdaligingizni va nimani ochayotganingizni ko‘radi.",
    ),
    "simpleIpResidential": MessageLookupByLibrary.simpleMessage(
      "Oddiy uy manzili",
    ),
    "simpleIpRiskyDesc": MessageLookupByLibrary.simpleMessage(
      "Saytlar sizni tez-tez bloklashi yoki tekshirishi mumkin.",
    ),
    "simpleIpTitle": MessageLookupByLibrary.simpleMessage(
      "Saytlar sizni qanday ko‘radi",
    ),
    "simpleIpUnknown": MessageLookupByLibrary.simpleMessage(
      "Manzilni tekshirib bo‘lmadi",
    ),
    "simpleLatency": m161,
    "simpleLocationAll": MessageLookupByLibrary.simpleMessage("Barchasi"),
    "simpleLocationAuto": MessageLookupByLibrary.simpleMessage(
      "avtomatik tanlandi",
    ),
    "simpleLocationManual": MessageLookupByLibrary.simpleMessage(
      "siz tomonidan tanlandi",
    ),
    "simpleLocationNone": MessageLookupByLibrary.simpleMessage(
      "Hali server yo‘q",
    ),
    "simpleLocationNoneHint": MessageLookupByLibrary.simpleMessage(
      "Serverlar ulanganidan keyin chiqadi",
    ),
    "simpleModeAuto": MessageLookupByLibrary.simpleMessage("Avto"),
    "simpleModeAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Rejimni tarmoq stsenariysi tanlaydi",
    ),
    "simpleModeDirect": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ridan-to‘g‘ri",
    ),
    "simpleModeDirectDesc": MessageLookupByLibrary.simpleMessage(
      "Trafik VPN‘siz o‘tadi",
    ),
    "simpleModeGlobal": MessageLookupByLibrary.simpleMessage(
      "Hammasi VPN orqali",
    ),
    "simpleModeGlobalDesc": MessageLookupByLibrary.simpleMessage(
      "Barcha trafik server orqali o‘tadi",
    ),
    "simpleModeRule": MessageLookupByLibrary.simpleMessage("Aqlli"),
    "simpleModeRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Faqat ochilmaydiganlari VPN orqali o‘tadi",
    ),
    "simpleModeTitle": MessageLookupByLibrary.simpleMessage("Rejim"),
    "simpleNoExpiry": MessageLookupByLibrary.simpleMessage("Muddatsiz"),
    "simpleProviderAnnouncement": MessageLookupByLibrary.simpleMessage(
      "Provayderning e’loni",
    ),
    "simpleServiceBlocked": m162,
    "simpleServiceComingSoon": m163,
    "simpleServiceOriginalsOnly": m164,
    "simpleServiceRestricted": m165,
    "simpleServiceUnavailable": m166,
    "simpleServiceUnsupportedRegion": m167,
    "simpleServicesAfterConnect": MessageLookupByLibrary.simpleMessage(
      "Ulangandan keyin",
    ),
    "simpleServicesAllGood": MessageLookupByLibrary.simpleMessage(
      "Hammasi joyida",
    ),
    "simpleServicesDirect": MessageLookupByLibrary.simpleMessage(
      "VPN‘siz kabi, to‘g‘ridan-to‘g‘ri",
    ),
    "simpleServicesManual": MessageLookupByLibrary.simpleMessage("Qo‘lda"),
    "simpleServicesTitle": MessageLookupByLibrary.simpleMessage("Xizmatlar"),
    "simpleServicesViaVpn": MessageLookupByLibrary.simpleMessage("VPN orqali"),
    "simpleSpeed4k": MessageLookupByLibrary.simpleMessage(
      "4K video uchun yetarli",
    ),
    "simpleSpeedAgain": MessageLookupByLibrary.simpleMessage("Yana"),
    "simpleSpeedAll": MessageLookupByLibrary.simpleMessage(
      "Tez: hammasiga bir vaqtda yetarli",
    ),
    "simpleSpeedChat": MessageLookupByLibrary.simpleMessage(
      "Xabarlar va musiqa uchun yetarli",
    ),
    "simpleSpeedDirectIdleDesc": m168,
    "simpleSpeedDirectTag": MessageLookupByLibrary.simpleMessage("VPN siz"),
    "simpleSpeedFailed": MessageLookupByLibrary.simpleMessage(
      "O‘lchab bo‘lmadi. Yana urinib ko‘ring.",
    ),
    "simpleSpeedHd": MessageLookupByLibrary.simpleMessage(
      "HD video uchun yetarli",
    ),
    "simpleSpeedIdleDesc": m169,
    "simpleSpeedLevel4k": MessageLookupByLibrary.simpleMessage("4K"),
    "simpleSpeedLevelAll": MessageLookupByLibrary.simpleMessage(
      "Hammasi birga",
    ),
    "simpleSpeedLevelChat": MessageLookupByLibrary.simpleMessage("Chatlar"),
    "simpleSpeedLevelHd": MessageLookupByLibrary.simpleMessage("HD"),
    "simpleSpeedMeasure": MessageLookupByLibrary.simpleMessage("O‘lchash"),
    "simpleSpeedMeasuring": MessageLookupByLibrary.simpleMessage(
      "O‘lchanmoqda…",
    ),
    "simpleSpeedSlow": MessageLookupByLibrary.simpleMessage(
      "Sekin: sahifalar ham uzoq yuklanadi",
    ),
    "simpleSpeedTitle": MessageLookupByLibrary.simpleMessage("Tezlik"),
    "simpleSpeedUnit": MessageLookupByLibrary.simpleMessage("Mbit/s"),
    "simpleStatusConnecting": MessageLookupByLibrary.simpleMessage(
      "Ulanmoqda…",
    ),
    "simpleStatusConnectingHint": MessageLookupByLibrary.simpleMessage(
      "Eng yaxshi serverni tanlamoqda",
    ),
    "simpleStatusNoProfile": MessageLookupByLibrary.simpleMessage("Obuna yo‘q"),
    "simpleStatusNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Ulanish uchun obuna qo‘shing",
    ),
    "simpleStatusOff": MessageLookupByLibrary.simpleMessage("Himoyalanmagan"),
    "simpleStatusOffHint": MessageLookupByLibrary.simpleMessage(
      "Ulanish uchun bosing",
    ),
    "simpleStatusOn": MessageLookupByLibrary.simpleMessage("Himoyalangan"),
    "simpleStatusPaused": MessageLookupByLibrary.simpleMessage("Pauza"),
    "simpleStatusPausedHint": MessageLookupByLibrary.simpleMessage(
      "Ishonchli tarmoq",
    ),
    "simpleStatusPausedOn": m170,
    "simpleTrafficLeft": m171,
    "simpleTrafficUnlimited": MessageLookupByLibrary.simpleMessage(
      "cheksiz trafik",
    ),
    "simpleTrustedDesc": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoqlarda VPN o‘zi pauzaga o‘tadi va siz chiqib ketganingizda qayta yoqiladi.",
    ),
    "simpleTrustedEmpty": MessageLookupByLibrary.simpleMessage(
      "Hali tarmoq yo‘q",
    ),
    "simpleTrustedThisNetwork": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoq",
    ),
    "simpleTrustedTitle": MessageLookupByLibrary.simpleMessage(
      "O‘z tarmoqlarimda pauza",
    ),
    "simpleUntilDate": m172,
    "singleAdd": MessageLookupByLibrary.simpleMessage("Alohida qoʻshish"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Alohida import"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Bu yerga bitta havola kiriting; bir nechtasini roʻyxatning tez tahrir orqali tahrirlang",
    ),
    "singleValueTip": m173,
    "size": MessageLookupByLibrary.simpleMessage("Oʻlcham"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Sertifikat tekshiruvini oʻtkazib yuborish",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage(
      "Oʻtkazib yuboriladigan domenlar",
    ),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Oʻtkazib yuboriladigan domenlar roʻyxatidagi aniqlangan domen ishlatilmaydi.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Oʻtkazib yuboriladigan maqsad manzillar",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Oʻtkazib yuboriladigan manba manzillar",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Siljish"),
    "sliders": MessageLookupByLibrary.simpleMessage("Slayderlar"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protokollar"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Sniffer TLS, HTTP va QUIC trafigidagi domenni oʻqiydi, shunda qoidalar shu domenga mos keladi.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS port"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Yumshoq"),
    "sort": MessageLookupByLibrary.simpleMessage("Tartiblash"),
    "source": MessageLookupByLibrary.simpleMessage("Manba"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Manba IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Maxsus proksi"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Maxsus qoidalar"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spektr"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Tezlik statistikasi",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Ajratish strategiyasi",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Ajratish strategiyasi boʻsh boʻlmasligi kerak",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDlar boʻsh"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stek rejimi"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Stek izi"),
    "standard": MessageLookupByLibrary.simpleMessage("Standart"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standart rejim: profil ustiga qoidalar qoʻshadi",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Ishga tushirish"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("Noldan boshlash"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN ishga tushmoqda…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Ishga tushish va fon",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Holat"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS oʻchirilganda tizim DNS ishlatiladi.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Toʻxtatish"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN oʻchirilmoqda…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Strategiya"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Qatʼiy marshrutlash"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Qatʼiy marshrutlash DNS kabi trafikning TUNni chetlab oʻtishiga yoʻl qoʻymaydi; boshqa qurilmalar bu qurilmaga endi yetib bormaydi.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Uslub"),
    "submit": MessageLookupByLibrary.simpleMessage("Yuborish"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("Avtomatik"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Maxsus User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Boshqaruv belgilarisiz to‘g‘ri User-Agent kiriting.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Mijozni tanlash qurilma identifikatorini yubormaydi.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "So‘rov mijozi",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Bu sozlamalar obuna URL manzillariga tegishli. Proksi havolalari mahalliy import qilinadi.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Bu obunani tekshirish uchun AGE kalitini kiriting.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Tekshirilgan natijani qo‘llash"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "Server ruxsatni rad etdi. Mijoz tanlash to‘xtatildi.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Tekshirish",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Mos obunani olib bo‘lmadi. Avvalgi sozlama o‘zgarmadi.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Joriy qiymatlarni saqlamasdan yoki VPNni qayta ishga tushirmasdan tekshiradi. Tugunlar mavjudligi emas, sozlamaning tahlili tekshiriladi.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Import yo‘qotishlari haqida yana so‘rash",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Obuna URL manzilini yashirish",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Oxirgi muvaffaqiyatli mijoz"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "Importda asl ma’lumotlarning bir qismi o‘tkazilmaydi. Qo‘llashdan oldin yo‘qotishlarni tekshiring.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Shu mijozdan foydalanish"),
    "subscriptionCompatibilityPrepared": m174,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core bu natijani tahlil qildi. U hali saqlanmagan yoki qo‘llanmagan.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "Server so‘rovlarni chekladi. Keyinroq qayta urining.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Obuna URL manzilini ko‘rsatish",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "Shakl yoki profil o‘zgardi. Obunani yana tekshiring.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "Obunani tekshirish vaqti tugadi.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Moslik",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Ulanib bo‘lmadi. Mijoz tanlash to‘xtatildi.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Bu obuna uchun bo‘sh qurilma joyi qolmagan. Provayder hisobidan qurilmani olib tashlab, qayta urinib ko‘ring.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Bu obuna qurilmani ro‘yxatdan o‘tkazishni talab qiladi. Provayder ko‘rsatmalariga amal qiling.",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Obunangiz muddati tugagan",
    ),
    "subscriptionExpiresInDays": m175,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Obunangiz muddati bugun tugaydi",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Operatsion tizim va qurilma modelini ham yuborish",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "Identifikator bilan birga operatsion tizim versiyasi va qurilma modeli yuboriladi.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Ushbu obuna manziliga barqaror taxallusli qurilma identifikatori yuboriladi. Bu apparat attestatsiyasi emas; rozilik faqat shu qurilmada saqlanadi.",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "HWID yuborish o‘chirilsa, ko‘plab obunalar ishlamay qoladi.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Obuna identifikatori",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "HWID yuborish",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Umumiy sozlamadan foydalanish",
    ),
    "subscriptionImportAdd": m176,
    "subscriptionImportAllAdded": m177,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash konfiguratsiyasi",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "shifrlangan obuna",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "proksi havolalari",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "nomaʼlum format",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya bo‘limlari",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "Manbaning bu qismlari o‘rniga ReClash o‘z sozlamalarini qo‘llaydi.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "Ko‘chirilmaydi",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Serverlarning hech biri qo‘llab-quvvatlanmaydi",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Ba’zi server sozlamalari qo‘llab-quvvatlanmaydi va tashlab yuboriladi",
    ),
    "subscriptionImportPartial": m178,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "Yuklash va yuborish tezligi ko‘rsatilmagan",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "Protokol qo‘llab-quvvatlanmaydi",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "Transport qo‘llab-quvvatlanmaydi",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Bu obuna uchun boshqa so‘ramaslik",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Yana biror narsa ko‘chirilmay qolsa, qayta so‘raladi.",
        ),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Hammasi ko‘chirilmaydi",
    ),
    "subscriptionImportShowAll": m179,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "Qo‘shilmaydi",
    ),
    "subscriptionImportSourceFormat": m180,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Obuna ma’lumotlari",
    ),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("Ishlanma"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("Promo"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("Sinov"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Obuna eslatmalari",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Obuna"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Hisob",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Tarifni sotib olish",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Trafik sotib olish",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "Logotip havolasi",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Yordam",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Veb-sayt",
    ),
    "subscriptionTrafficLow": m181,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Provayder yangilash intervalidan foydalanish",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "sudo uchun parolingizni kiriting",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Toʻxtatilmoqda…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage(
      "Profilni almashtirish",
    ),
    "sync": MessageLookupByLibrary.simpleMessage("Sinxronlash"),
    "system": MessageLookupByLibrary.simpleMessage("Tizim"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Tizim ilovalari"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Tizim proksisi"),
    "tab": MessageLookupByLibrary.simpleMessage("Varaq"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Varaq animatsiyasi"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Qayta urinish uchun belgi ustiga bosing",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Ruxsat berish uchun bosing",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Moʻljal"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage(
      "Parallel TCP ulanishlari",
    ),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Bu qurilmada Telegramni ochib bo‘lmadi.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Telegramni ochish"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Brauzerda ochish",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test oraligʻi"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Sinov URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Ishlatilganda sinash",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Matn oʻlchami"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Matn shunday koʻrinadi",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Mavzu"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Mavzu rangi"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Mavzu rejimi"),
    "tight": MessageLookupByLibrary.simpleMessage("Zich"),
    "time": MessageLookupByLibrary.simpleMessage("Vaqt"),
    "timeout": MessageLookupByLibrary.simpleMessage("Kutish vaqti"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Ohangdor"),
    "tip": MessageLookupByLibrary.simpleMessage("Maslahat"),
    "tk": MessageLookupByLibrary.simpleMessage("Turkmancha"),
    "toggle": MessageLookupByLibrary.simpleMessage("Almashtirish"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Bagʻrikenglik"),
    "tools": MessageLookupByLibrary.simpleMessage("Vositalar"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Amal"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Boʻlim tanlang yoki sozlama qidiring",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Bu barcha faol ulanishlarni yopadi. Davom etasizmi?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("Amal bajarildi"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya",
    ),
    "toolsData": MessageLookupByLibrary.simpleMessage(
      "Resurslar va maʼlumotlar",
    ),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "Mos sozlama yoki amal topilmadi",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Maʼlumot va nosozliklarni izlash",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage(
      "Yaqinda ishlatilgan",
    ),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Avval autentifikatsiyani yoqing",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Avval tashqi boshqaruvni yoqing",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Bu amal uchun yadroni ishga tushiring",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Avval maxsus tarmoq interfeysini tanlang",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Avval MIPS tarmoq stekini tanlang",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Bu DNS qayta belgilashni avval DNS sahifasida qoʻshing",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Avval WebDAVni sozlang",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Diagnostika"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Mahkamlash"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Mahkamlangan"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Yadroni qayta ishga tushirish",
    ),
    "toolsResults": m182,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Ishga tushirish"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Boʻlim"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Sozlama"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage(
      "Mahkamlashni olib tashlash",
    ),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Resurslarni yangilash",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Qoidalar va skriptlarni yangilash konfiguratsiyani qayta qoʻllashi va ulanishlarga taʼsir koʻrsatishi mumkin. Davom etasizmi?",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Trafikni toʻldirish"),
    "torch": MessageLookupByLibrary.simpleMessage("Fonar"),
    "total": MessageLookupByLibrary.simpleMessage("Jami"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Yuklab olingan"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Jami trafik"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Yuklab yuborilgan"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafik"),
    "trafficPeak": m183,
    "trafficTotal": m184,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafik sarfi"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Tarjima tuzatishni taklif qilish",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportHeaders": m185,
    "trayIcon": MessageLookupByLibrary.simpleMessage("Tray belgisi"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Rangli"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Qora"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Oq"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage(
      "Ishonchli tarmoqlar",
    ),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "Bu tarmoqlardan biriga ulanganda VPN toʻxtatiladi",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Hozirgi tarmoq ishonchli — VPN shu yerda toʻxtatilgan",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUNga ruxsat berib boʻlmadi, shu sababli u oʻchirildi.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN faqat administrator rejimida ishlaydi.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yerga qoʻshilgan yozuvlar har bir profilning TUN sozlamalarini almashtiradi; qoʻshilmaganlar profilning oʻz sozlamasini saqlaydi. Maxsus profilning oʻzi qoʻshgan yozuvlar ustunlik qiladi.",
    ),
    "tunSetupApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helperga ruxsat bering",
    ),
    "tunSetupConfirm": MessageLookupByLibrary.simpleMessage("Sozlash"),
    "tunSetupDone": MessageLookupByLibrary.simpleMessage("TUN yoqilgan"),
    "tunSetupInstallTitle": MessageLookupByLibrary.simpleMessage(
      "TUN ni sozlash",
    ),
    "tunSetupInstantStart": MessageLookupByLibrary.simpleMessage(
      "Shundan so‘ng TUN, tizimga kirganda ham, darhol ishga tushadi",
    ),
    "tunSetupLater": MessageLookupByLibrary.simpleMessage("Hozir emas"),
    "tunSetupLinuxInstall": MessageLookupByLibrary.simpleMessage(
      "Tizimning barcha trafigini ReClash orqali yo‘naltirish uchun TUN’ga tizim Helper’i kerak: u Core’ni faqat tarmoq ruxsatlari bilan ishga tushiruvchi systemd xizmati.",
    ),
    "tunSetupLinuxScope": MessageLookupByLibrary.simpleMessage(
      "Helper faqat tekshirilgan ReClash Core’ni ishga tushiradi va unga faqat tarmoq huquqlarini beradi",
    ),
    "tunSetupLinuxUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash yangilandi, shu sababli ishlashda davom etish uchun TUN Helper ham u bilan birga yangilanishi kerak.",
    ),
    "tunSetupMacosInstall": MessageLookupByLibrary.simpleMessage(
      "TUN uchun ReClash Helper kerak. macOS uni bir marta ruxsat berishingizni so‘raydi.",
    ),
    "tunSetupOnceConfirm": MessageLookupByLibrary.simpleMessage(
      "Bu versiya uchun Windows bir marta tasdiqlashni so‘raydi",
    ),
    "tunSetupOncePassword": MessageLookupByLibrary.simpleMessage(
      "Bu versiya uchun administrator paroli bir marta kerak bo‘ladi",
    ),
    "tunSetupPasswordPrivacy": MessageLookupByLibrary.simpleMessage(
      "Parolni faqat tizim oynasida kiriting: ReClash uni hech qachon ko‘rmaydi.",
    ),
    "tunSetupUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "TUN mavjud emas",
    ),
    "tunSetupUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helperni yangilash",
    ),
    "tunSetupWaiting": MessageLookupByLibrary.simpleMessage(
      "Tizim oynasida tasdiqlashni kutilmoqda…",
    ),
    "tunSetupWindowsInstall": MessageLookupByLibrary.simpleMessage(
      "Tizimning barcha trafigini ReClash orqali yo‘naltirish uchun TUN’ga ReClash Service kerak — bu Core’ni tarmoq adapteri talab qiladigan huquqlar bilan ishga tushiradigan Windows xizmati.",
    ),
    "tunSetupWindowsScope": MessageLookupByLibrary.simpleMessage(
      "Xizmat faqat tekshirilgan ReClash Core’ni ishga tushiradi va faqat sizning hisobingizni qabul qiladi",
    ),
    "tunSetupWindowsUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash yangilandi, shu sababli TUN ishlashda davom etishi uchun ReClash Service ham u bilan birga yangilanishi kerak.",
    ),
    "tunSetupWithoutTun": MessageLookupByLibrary.simpleMessage("TUNsiz"),
    "turnOff": MessageLookupByLibrary.simpleMessage("Oʻchirish"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Yoqish"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP uzatish rejimi"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP kutish vaqti"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP kutish vaqti soniyalar bilan belgilanadi va faqat gvisor, tizim va aralash steklar bilan ishlaydi.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Qaytarish"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Yagona kechikish"),
    "unknown": MessageLookupByLibrary.simpleMessage("Noma’lum"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Noma’lum tarmoq xatosi",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage(
      "Oynani asliga qaytarish",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Nomsiz"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage(
      "Oynani doim yuqorida tutishni oʻchirish",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Yangilash"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Avtomatik o‘rnatishga ruxsat berish",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash tekshirilgan, mos barqaror yangilanishlarni har safar so‘ramasdan o‘rnata oladi. VPN hech qachon uzilmaydi. Android o‘rnatishni tasdiqlashingizni so‘rashi mumkin.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Avtomatik o‘rnatishga ruxsat berilsinmi?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Avtomatik o‘rnatish",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Yuklashni bekor qilish",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Yangilanish kanali"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Dastlabki reliz"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Barqaror reliz",
    ),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Avtomatik tekshirish",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Yangilanishlarni tekshirib bo‘lmadi",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Ulanishni tekshirib, qayta urinib ko‘ring.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanishlar tekshirilmoqda…",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("Oynani yopish"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android tasdig‘ingizni talab qiladi. Tizim tasdiqlash oynasini ochish uchun davom eting.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Android’da tasdiqlang",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Fonda davom etish",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "O‘rnatishni davom ettirish",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "Sizda eng yangi versiya",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "Bu platformada ReClash reliz sahifasini ochadi. Yangilanishni o‘zingiz yuklab, o‘rnating.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "Bu qurilma uchun tekshirilgan yuklash mavjud emas. Reliz sahifasidan paket tanlang.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Uzish va o‘rnatish",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Qo‘lda o‘rnatishni saqlash",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Yangilanishni yuklash",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Qayta yuklash",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Yangilanishni yuklab bo‘lmadi",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Yuklangan qism saqlandi. Ulanishni tekshiring va yuklashni davom ettiring.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Tushunarli"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Paket o‘rnatuvchisini ishga tushirib bo‘lmadi",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android o‘rnatishni yakunlamadi. Tayyor bo‘lganingizda qayta urinib ko‘ring.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Hozir o‘rnatish"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanish o‘rnatildi",
    ),
    "updateInstalledVersion": m186,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android o‘rnatishni yakunlamoqda. Bu bosqichda ReClash yopilishi mumkin.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanish o‘rnatilmoqda",
    ),
    "updateMinutes": m187,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Hozir emas"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Reliz qaydlari mavjud emas.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanish mavjud",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Android sozlamalarini ochish",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Qurilma uchun yig‘ilma",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("Yuklash hajmi"),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Paket tekshiruvi",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Yuklangandan keyin, o‘rnatishdan oldin tekshiriladi",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Yaxlitlik, ilova identifikatori va imzo tekshirildi",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Pauza"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Yuklash pauzada",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash’ga ushbu manbadan ilovalarni o‘rnatishga ruxsat bering va davom etish uchun qayting.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Android ruxsati kerak",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Tekshirish, yuklash va o‘rnatishni alohida sozlang.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Sozlamalar saqlanmadi. Qayta urinib ko‘ring; avtomatik o‘rnatish yoqilmadi.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanish sozlamalari",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi orqali oldindan yuklash",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "O‘rnatishga tayyor",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Reliz tafsilotlari",
    ),
    "updateRemainingTime": m188,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Yuklashni davom ettirish",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Davom ettirish"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Qayta tekshirish",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "O‘rnatishni qayta urinish",
    ),
    "updateSeconds": m189,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "To‘liq reliz qaydlarini ko‘rish",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Barcha oʻzgarishlarni koʻrsatish",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Yangilanishlar"),
    "updateTransferSpeed": m190,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Yuklab olingan yangilanish yaxlitligini tekshirib bo‘lmadi.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Fayl, versiya yoki imzo tekshiruvdan o‘tmadi. Yangi nusxani yuklab, qayta urinib ko‘ring.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Bu paketni o‘rnatib bo‘lmaydi",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Yangilanish tekshirilmoqda",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "O‘rnatish ReClash’ni qisqa vaqtga yopadi. Ulanishni uzishga tayyor bo‘lsangizgina uzing.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "VPN hali ishlayapti",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Yuklab yuborish"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Yuklab yuborish oʻtkazish qobiliyati",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL sxemasi"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Amal"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Obuna qo‘shish"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Obuna URL manzilini qo‘shish. Nom ixtiyoriy.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Shifrlangan havolaning haqiqiyligi tasdiqlanmadi. U buzilgan yoki boshqa kalitdan foydalanayotgan bo‘lishi mumkin.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Havola yaratish"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Ilovani yopish"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Sozlangan yopish amalini bajarish.",
    ),
    "urlSchemeConfigCounts": m191,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML yoki JSON konfiguratsiyasini joylashtiring",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya tarkibi",
    ),
    "urlSchemeConfirmMessage": m192,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Ilovaning tashqi buyrug‘i",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Tashqi ulanish va yopish buyruqlari tasdiqlashni so‘raydi.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Ulash"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Tanlangan profil bilan ulanish.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Ulanish"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Tarkib formati",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "O‘girishda ayrim tarkib tushirib qoldiriladi. Import paytida o‘zgarishlarni ko‘rib chiqing va tasdiqlang.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Havolani nusxalab bo‘lmadi. Qayta urinib ko‘ring.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage(
      "Havolani nusxalash",
    ),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Havolani yetkazib bo‘lmadi yoki navbat to‘la. Joriy amal tugaganidan keyin qayta urinib ko‘ring.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Uzish"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Profilni o‘zgartirmay ulanishni to‘xtatish.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Ichki konfiguratsiya",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Namuna profil",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Formatlar"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Havola formatlari. Belgilangan joylarni URL yoki ma’lumotlaringiz bilan almashtiring.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiyani import qilish",
    ),
    "urlSchemeImportConfirm": m193,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Havolaga YAML yoki JSON konfiguratsiyasini joylash.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Havolani tekshirish",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Ilova yoki profil havolasini joylashtiring",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "Tekshiruv shu qurilmada bajariladi. U havolani ochmaydi, obunani yuklamaydi va profilni import qilmaydi.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "Havola tuzilishi to‘g‘ri. Obuna mavjudligi va yadro tekshiruvi faqat import paytida tekshiriladi.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Tekshiruv natijasi",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiyani o‘rnatish",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash mijozlarining umumiy obuna havolasi formatidan foydalanish.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "Ichki konfiguratsiya to‘g‘ri UTF-8 Base64 ma’lumotlari emas.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "Havola noto‘g‘ri. Uning tuzilishi va foizli kodlanishini tekshiring.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Profil nomi boshqaruv belgilarisiz 64 ta belgidan oshmasligi kerak.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "To‘g‘ri HTTP yoki HTTPS obuna URL manzilini kiriting.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "Havolada obuna URL manzili yoki konfiguratsiya yo‘q.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "Hech qanday amal bajarilmadi.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Ilovani ko‘rsatish"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash oynasini oldinga chiqarish.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parametrlar"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Buferni o‘qib bo‘lmadi. Havolani qo‘lda joylashtiring.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Havola"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Havola yaratish uchun URL yoki konfiguratsiya kiriting.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Havolalarda token yoki kirish ma’lumotlari bo‘lishi mumkin. Ehtiyotkorlik bilan ulashing.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Profillar"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Proksi ulashish havolalari",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Havola aniqlandi",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Tashqi ulanish buyruqlaridan oldin ulanish sozlashini tugating.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Qo‘llab-quvvatlanadigan import havolalari",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Ulanishni almashtirish",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "To‘xtagan bo‘lsa ulanish, ishlayotgan bo‘lsa uzish.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "Havolada ichma-ich o‘ramlar juda ko‘p.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "Havola 4 MB yoki ichki konfiguratsiya 2 MB chegarasidan oshadi.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Bu havola buyrug‘i qo‘llab-quvvatlanmaydi.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Bu shifrlash versiyasi qo‘llab-quvvatlanmaydi. Oddiy obuna havolasini so‘rang.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage(
      "Misoldan foydalanish",
    ),
    "urlTip": m194,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostlardan foydalanish"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Tizim hostlaridan foydalanish",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("ishlatilgan"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Sarflangan trafik"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Foydalanuvchi nomi"),
    "uz": MessageLookupByLibrary.simpleMessage("Oʻzbekcha"),
    "value": MessageLookupByLibrary.simpleMessage("Qiymat"),
    "view": MessageLookupByLibrary.simpleMessage("Koʻrish"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Virtual IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Yorqin"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN konfiguratsiyasida oʻzgarish aniqlandi",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN butun tizim trafigini VpnService orqali avtomatik yoʻnaltiradi.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Xiralashtirish"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Kartochkalarning noshaffofligi",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Qoraytirish"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Rasm sozlamalari",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Maxsus fondan foydalanish",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage(
      "Rasmni joylashtirish",
    ),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Sigʻdirish"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Toʻldirish"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Choʻzish"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Gorizontal joylashuv",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG, WebP yoki SVG formatidagi yaroqli rasmni tanlang.",
    ),
    "wallpaperImageLabel": m195,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Kadrlash"),
    "wallpaperLibraryFull": m196,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Rasmning noshaffofligi",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage(
      "Oʻqish qulayligi",
    ),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage(
      "Rasmni olib tashlash",
    ),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Effektlarni asliga qaytarish",
    ),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Kadrlashni asliga qaytarish",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Fonni saqlab boʻlmadi. Oldingi fon saqlab qolindi.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Masshtab"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG yoki WebP · 20 MB gacha",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("Maxsus fon"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Hajmi 20 MB dan, aniqligi 50 megapikseldan oshmaydigan rasmni tanlang.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Rasm mavjud emas",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Vertikal joylashuv",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV sozlamalari",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Veb panel"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Kirish"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Panelga kirish yakunlandi",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage("Ilovada"),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "Brauzerda",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage(
      "Oʻchirilgan",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Kirish mahalliy va maxfiy kalit bilan himoyalangan. Panelni ochish saqlangan tashqi kontroller sozlamalarini oʻzgartirmaydi.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Panel konfiguratsiyasini qoʻllab boʻlmadi.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "Yuklangan fayl yaroqli panel arxivi emas.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Yadro kirish maʼlumotlarini rad etdi. Panelni qayta oching.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "Brauzer kirishi yakunlanguncha yoki ReClash yopilguncha faol qoladi",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Boshqa panel amali bajarilmoqda.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Panel amali bekor qilindi.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "Panel nazorat summasi belgilangan relizga mos emas.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Yadro tayyor emas.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Yadroni boshqarish uchun mahalliy veb panellar",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Panelni yuklab boʻlmadi. Qayta urinib koʻring.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Panel yuklab olinmoqda",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "Panel yopilganda kirish tugaydi",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Panelga kirishni yakunlash",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Panel arxivi ochilmoqda",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Panel"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Panelni oʻrnatish",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Tanlangan panel birinchi ochishda yuklab olinadi. Belgilangan reliz SHA-256 orqali tekshiriladi.",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Brauzerni ochib boʻlmadi.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Faol panel seansi yoʻq",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Panelni ochishdan oldin profilni tanlang.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Oʻrnatilmagan",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Panelni ochish"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Brauzerda ochish",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Qayta yuklash"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "Panelga kirish provayderingiz tomonidan o‘chirilgan.",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "Xavfsiz rejimda panelga kirish oʻchirilgan.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Panel fayllarini xavfsiz oʻqish yoki almashtirish imkonsiz.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "Panel arxivi ruxsat etilgan hajmdan oshdi.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Yadro bu panelni taqdim etmayapti.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Yuklama tekshirilmoqda",
    ),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Versiya"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Oq roʻyxat rejimi"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Tizimga yozish"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Tizimga yozish tizim soatini ham oʻrnatadi; Android bunga eʼtibor bermaydi.",
    ),
    "yearsAgo": m197,
    "yearsAgoShort": m198,
    "yes": MessageLookupByLibrary.simpleMessage("Ha"),
    "zhCN": MessageLookupByLibrary.simpleMessage(
      "Soddalashtirilgan xitoy tili",
    ),
  };
}
