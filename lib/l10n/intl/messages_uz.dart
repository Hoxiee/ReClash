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

  static String m0(count, skipped) =>
      "Qoʻshiladi: ${count}; allaqachon mavjudligi bois oʻtkazib yuborildi: ${skipped}";

  static String m1(detail) => "Maʼlumotlarni tozalab boʻlmadi: ${detail}";

  static String m2(code) =>
      "Windows ReClashCore.exe dasturini ishga tushirishni rad etdi (xato kodi ${code}). Smart App Control yoki AppLocker kabi dasturlarni boshqarish siyosati imzosiz dasturlarni bloklaydi. ReClashga oʻsha siyosatda ruxsat bering yoki siyosatni oʻchirib qoʻying, soʻng qayta urinib koʻring.";

  static String m3(name) =>
      "Ilova ketma-ket ikki marta ishga tushmadi. Bunga chek qoʻyish uchun ${name} profili tanlovdan chiqarildi va avtomatik sozlash oʻtkazib yuborildi. Uni istalgan paytda qayta tanlashingiz mumkin.";

  static String m4(url) => "${url} manzilidan profil yaratilsinmi?";

  static String m5(groups) =>
      "${groups} proksi guruhlaridan include-all tashlab yuborilgan; ular foydalanadigan proksilar yoki proksi provayderlarni qoʻshing";

  static String m6(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE qoidasi tashlab yuborilgan — maxsus profillar sub-rulesni qoʻllab-quvvatlamaydi', other: '${label} SUB-RULE qoidasi tashlab yuborilgan — maxsus profillar sub-rulesni qoʻllab-quvvatlamaydi')}";

  static String m7(message) => "Yadro bu proksini tahlil qilolmadi: ${message}";

  static String m8(proxy, target) =>
      "${proxy} ${target} orqali ulanadi; u yana ${proxy}ga qaytib keladi, shu sababli ulanish halqa boʻlib qoladi";

  static String m9(name) =>
      "${name} nomi allaqachon boshqa proksi yoki proksi guruhda ishlatilgan";

  static String m10(path) =>
      "Proksi guruhlar bir-biriga halqasimon murojaat qiladi: ${path}";

  static String m11(name) =>
      "Boʻsh zaxira proksi boʻlishi kerak; lekin ${name} mavjud emas yoki proksi guruh";

  static String m12(name, message) => "${name} yaroqli regex emas: ${message}";

  static String m13(name) => "Dialer proksi ${name} mavjud emas";

  static String m14(names) => "Bu proksi provayderlar mavjud emas: ${names}";

  static String m15(names) =>
      "Bu proksilar yoki siyosatlar mavjud emas: ${names}";

  static String m16(name) =>
      "${name} ichki siyosat nomi va bu yerda ishlatib boʻlmaydi";

  static String m17(count) =>
      "${count} ta yozuvda muammo bor; bu profilni qoʻllasangiz xatolik yuz berishi mumkin";

  static String m18(count) =>
      "${Intl.plural(count, one: '1 kun oldin', other: '${count} kun oldin')}";

  static String m19(count) =>
      "${Intl.plural(count, other: '${count} kun oldin')}";

  static String m20(label) => "Tanlangan ${label} oʻchirilsinmi?";

  static String m21(label) => "Bu ${label} oʻchirilsinmi?";

  static String m22(label) => "${label} tafsilotlari";

  static String m23(name) =>
      "${name} orqali ulanish uni ishlatayotgan proxiga qaytib keladi, shu sababli ulanish toʻxtatildi";

  static String m24(label) => "${label} boʻsh boʻlishi mumkin emas";

  static String m25(label) => "${label} allaqachon mavjud";

  static String m26(count) => "${count} ta yozuv amalga oshmadi";

  static String m27(label, message) => "${label}: ${message}";

  static String m28(name) => "${name} allaqachon yangilangan";

  static String m29(name) => "${name} yangilandi";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 guruh', other: '${count} guruh')}";

  static String m31(count) => "${count} ta kutish vaqti tugadi";

  static String m32(action) =>
      "«${action}» uchun ishlatilmoqda. Saqlansa, shu yerga koʿchiriladi.";

  static String m33(actions) => "Eksport qilinmadi: ${actions}";

  static String m34(modifiers) => "Kamida ${modifiers} dan birini qoʿshing";

  static String m35(count) =>
      "${Intl.plural(count, one: '1 soat oldin', other: '${count} soat oldin')}";

  static String m36(count) =>
      "${Intl.plural(count, other: '${count} soat oldin')}";

  static String m37(target) => "${target} — yaroqsiz yoʻnalish";

  static String m38(proxyName) => "${proxyName} — yaroqsiz proksi";

  static String m39(providerName) =>
      "${providerName} — yaroqsiz proksi provayder";

  static String m40(ruleSet) => "${ruleSet} — yaroqsiz qoida toʻplami";

  static String m41(subRule) => "${subRule} — yaroqsiz SUB_RULE";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 yozuv', other: '${count} yozuv')}";

  static String m43(line, message) => "${line}-qator: ${message}";

  static String m44(appName) =>
      "1. Tizim sozlamalaridagi Maxfiylik va xavfsizlik boʻlimini oching\n2. Joylashuv xizmatlarini tanlang\n3. Roʻyxatdan ${appName}ni topib, belgilang\n\nTugagach, ilovaga qaytib davom eting. Tushunganingiz uchun rahmat.";

  static String m45(label, max) => "${label} ${max} belgidan oshmasligi kerak";

  static String m46(size) => "${size} boʻshatildi";

  static String m47(count) =>
      "${Intl.plural(count, one: '1 daqiqa oldin', other: '${count} daqiqa oldin')}";

  static String m48(count) =>
      "${Intl.plural(count, other: '${count} daqiqa oldin')}";

  static String m49(count) =>
      "${Intl.plural(count, one: '1 oy oldin', other: '${count} oy oldin')}";

  static String m50(count) =>
      "${Intl.plural(count, other: '${count} oy oldin')}";

  static String m51(code) =>
      "Server kirishni rad etdi (HTTP ${code}). Havola muddati tugagan yoki hisob maʼlumotlari xato boʻlishi mumkin";

  static String m52(code) => "Server soʻrovni rad etdi (HTTP ${code})";

  static String m53(code) =>
      "Bu manzilda hech narsa topilmadi (HTTP ${code}). URL toʻgʻriligini tekshiring";

  static String m54(detail) => "Tarmoq soʻrovi bajarilmadi: ${detail}";

  static String m55(code) =>
      "Serverda muammo yuz berdi (HTTP ${code}). Keyinroq qayta urinib koʻring";

  static String m56(label) => "Hozircha ${label} yoʻq";

  static String m57(label, min, max) =>
      "${label} ${min} va ${max} oraligʻida boʻlishi kerak";

  static String m58(label) => "${label} raqam boʻlishi kerak";

  static String m59(label) =>
      "${label} 1024 va 49151 oraligʻida boʻlishi kerak";

  static String m60(port) => "${port} port";

  static String m61(days) =>
      "${Intl.plural(days, one: '1 kun qoldi', other: '${days} kun qoldi')}";

  static String m62(date, days) =>
      "Tugash vaqti ${date}, ${Intl.plural(days, one: '1 kun', other: '${days} kun')} qoldi";

  static String m63(time) => "Yangilandi: ${time}";

  static String m64(label, profiles) =>
      "${label} hali ${profiles} tomonidan ishlatilmoqda; uni oʻchirsangiz ular toʻgʻri ishlamaydi. Oʻchirishni tasdiqlaysizmi?";

  static String m65(count, label) =>
      "${Intl.plural(count, one: '1 proksi', other: '${label} proksi')}";

  static String m66(name, count) => "${name} va boshqalar (${count} proksi)";

  static String m67(removed) =>
      "Bu proksilar oʻchiriladi: ${removed}. Nomi oʻzgargan qator yangi proksi hisoblanadi; oʻchirilganlarni nomlaydigan maxsus profillar ularni mavjud emas sifatida koʻrsatadi. Baribir qoʻllansinmi?";

  static String m68(removed, added) =>
      "Bu proksilar oʻchiriladi: ${removed}. Bu yerga qoʻshiladi: ${added}. Nomi oʻzgargan qator yangi proksi hisoblanadi; oʻchirilganlarni nomlaydigan maxsus profillar ularni mavjud emas sifatida koʻrsatadi. Baribir qoʻllansinmi?";

  static String m69(label) =>
      "${label} hali shu profildagi qoidalar, proksi guruhlar, dialer proksilar, DNS yoki NTP tomonidan nomlanmoqda; uni oʻchirsangiz ular ishlamay qoladi. Oʻchirishni tasdiqlaysizmi?";

  static String m70(count, label) =>
      "${Intl.plural(count, one: '1 proksi guruh', other: '${label} proksi guruh')}";

  static String m71(region, bypassed, proxied) =>
      "${region}: VPNni chetlab o‘tish ro‘yxatiga ${bypassed} ta, VPN ro‘yxatiga ${proxied} ta ilova kiradi. Ikkala ro‘yxat almashtiriladi; rejim va boshqa sozlamalar o‘zgarmaydi. Paket va SDK mosligi faqat tavsiya: qo‘llagandan keyin natijani tekshiring.";

  static String m72(region, value) =>
      "${region} hududining ro‘yxati: ${value}. Maxsus ro‘yxat hududiy qiymatlarni almashtiradi.";

  static String m73(region, source) => "Tavsiya: ${region} · ${source}";

  static String m74(region, value) =>
      "${region} hududining DNS qiymatlari: ${value}. Bu ekrandagi qo‘lda kiritilgan qiymatlar ustun.";

  static String m75(region) => "Mamlakat profili: ${region}";

  static String m76(value) => "TUN MTU: ${value}";

  static String m77(value) => "Standart xizmat tekshiruvlari: ${value}";

  static String m78(region, value) =>
      "${region} hududining MTU qiymati: ${value}. O‘z qiymatingizni ishlatish uchun MTU sozlamasini qo‘shing.";

  static String m79(count, label) =>
      "${Intl.plural(count, one: '1 qoida', other: '${label} qoida')}";

  static String m80(appName) => "${appName} (Xavfsiz rejim)";

  static String m81(count) =>
      "${Intl.plural(count, one: '1 soniya', other: '${count} soniya')}";

  static String m82(count) => "${count} ta faol";

  static String m83(count) =>
      "${Intl.plural(count, one: '1 nosozlik', other: '${count} nosozlik')}";

  static String m84(time) => "${time} da tekshirildi";

  static String m85(count) =>
      "${Intl.plural(count, one: '1 sozlama', other: '${count} sozlama')}";

  static String m86(count) => "Mavjud profillar: ${count}";

  static String m87(step, total) => "${total} tadan ${step}-qadam";

  static String m88(server) => "${server}ni sinash";

  static String m89(link) => "${link} havolasidan proksi oʻqib boʻlmadi";

  static String m90(label) => "${label} bitta yozuv boʻlishi kerak";

  static String m91(client, format, count) =>
      "${client} sifatida olindi: ${format}, proksi tugunlari: ${count}.";

  static String m92(sections) =>
      "Quyidagi manba bo‘limlari ko‘chirilmaydi: ${sections}.";

  static String m93(count, format) =>
      "${format} formatidan ${count} ta proksi tugunini import qilish mumkin.";

  static String m94(count) => "O‘zgartirib bo‘lmaydigan tugunlar: ${count}.";

  static String m95(count) => "${count} ta natija";

  static String m96(value) => "Eng yuqori ${value}";

  static String m97(value) => "Jami ${value}";

  static String m98(version) => "Oʻrnatilgan versiya: ${version}";

  static String m99(nodes, groups, providers) =>
      "Proksilar: ${nodes}, guruhlar: ${groups}, masofaviy provayderlar: ${providers}";

  static String m100(action) =>
      "Bu havola «${action}» amalini so‘raydi. ReClash’ga uni bajarishga ruxsat berilsinmi?";

  static String m101(name, source) =>
      "${source} manbasidan «${name}» import qilinsinmi? Tasdiqlashdan so‘ng profil va o‘girishlar tekshiriladi.";

  static String m102(label) => "${label} URL boʻlishi kerak";

  static String m103(version) => "Oʻrnatilgan versiya: ${version}";

  static String m104(count) =>
      "${Intl.plural(count, one: '1 yil oldin', other: '${count} yil oldin')}";

  static String m105(count) =>
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
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Kirish nazorati sozlamalari",
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
    "addedRules": MessageLookupByLibrary.simpleMessage("Qoʻshilgan qoidalar"),
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
    "answers": MessageLookupByLibrary.simpleMessage("Javoblar"),
    "app": MessageLookupByLibrary.simpleMessage("Ilova"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Ilovalar uchun kirish nazorati",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Ilova belgisi dizayni",
    ),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Mahalliy proksilar yoʻq",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage("Ilova hududi"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Tizim DNSini qoʻshish",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Ilova sozlamalari",
    ),
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
    "batchPreviewTip": m0,
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
    "clearDataFailed": m1,
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
    "color": MessageLookupByLibrary.simpleMessage("Rang"),
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
    "coreBlockedByPolicyTip": m2,
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
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Helper orqali jarayon",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Jarayon ichidagi kutubxona",
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
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Qulash testi"),
    "create": MessageLookupByLibrary.simpleMessage("Yaratish"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("Yaratilgan vaqt"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage(
      "ByeDPI — DPI chetlab oʻtish vositasi",
    ),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — ilova shu mijoz asosida qurilgan",
    ),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "FlClash-Patched — qoʻshimcha funksiyalar",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — provayder funksiyalari va gʻoyalari",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage(
      "mihomo — proksi yadrosi",
    ),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Ishga tushirish tugmasini oʻz ichiga oladi; uni olib tashlab boʻlmaydi",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "customColor": MessageLookupByLibrary.simpleMessage("Maxsus rang"),
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("Nomi boʻsh"),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Proksilar yoki proksi provayderlar tanlanmagan, shu sababli yadro bu guruhni rad etadi",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("Maxsus"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Ilova proksilari va boshqa profillardan proksi guruhlar hamda qoidalar yigʻadi",
    ),
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
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishni saqlab boʻlmadi. Oldingi holatga qaytarildi.",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("Standart tanlov"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Standart"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya nomi va turini oʻz ichiga olgan YAML lugʻati boʻlishi kerak",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Kechikish"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Muvaffaqiyatsiz"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Kechikish testi"),
    "delete": MessageLookupByLibrary.simpleMessage("Oʻchirish"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta yadrosi asosida qurilgan koʻp platformali proksi ilova. Sodda va oson foydalanish, ochiq kodli, reklamasiz.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Manzil"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Manzil GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("Manzil IP ASN"),
    "details": m22,
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
    "dialerProxyLoopStopped": m23,
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
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yozuv boʻlmasa, TUN har bir DNS soʻrovini 53 portga (any:53) oʻgʻirlab boradi.",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS oʻgʻirlash"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS rejimi"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu yerga qoʻshilgan yozuvlar har bir URL va fayl profilining DNSini almashtiradi; qoʻshilmaganlar profilning oʻz sozlamasini saqlaydi. Maxsus profillar DNSini oʻz tarkibida belgilaydi.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS soʻrovlari"),
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
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("Ingliz tili"),
    "enabled": MessageLookupByLibrary.simpleMessage("Yoqilgan"),
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
    "existsTip": m25,
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
    "extraLarge": MessageLookupByLibrary.simpleMessage("Juda katta"),
    "fade": MessageLookupByLibrary.simpleMessage("Soʻnish"),
    "failedCount": m26,
    "failedItem": m27,
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
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Profil faylini toʻgʻridan-toʻgʻri yuklash",
    ),
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
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
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
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("guruh"),
    "groupTimeoutCount": m31,
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
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global tezkor tugmalar oyna yashirilganda ham ishlaydi. Tugmalar birikmasini yozib olish uchun amalni bosing.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Ish stoli tezkor tugmalari",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Ish stoli sozlamalarida buyruqni maxsus tugmalar birikmasiga tayinlang. ReClash ishlayotgan boʻlishi kerak, lekin oynasi yashirin qolishi mumkin. Bu global birikmalar ish stoli sozlamalarida boshqariladi.",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Kompozitor konfiguratsiyasi fayllari mavjud emas. Yuqoridagi ish stoli buyruqlaridan foydalanishingiz mumkin.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Bu birikmalar ilova oynasi fokusda boʻlganda ishlaydi. Global tezkor tugmalar uchun quyidagi boʻlimda ish stoli buyruqlarini sozlang.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Tezkor tugmalarni boshqarish",
    ),
    "hotkeyNeedsModifier": m34,
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
    "hoursAgo": m35,
    "hoursAgoShort": m36,
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
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 yoki 8000-9000 kabi port yoki oraligʻ kiriting",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Bu QR kod profil havolasini oʻz ichiga olmaydi",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 yoki 8000-9000 kabi raqam yoki oraliqlarni / bilan ajratib kiriting",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
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
    "itemsCount": m42,
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
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Qatorlarni koʻchirish"),
    "link": MessageLookupByLibrary.simpleMessage("Havola"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Profilni obuna havolasi yoki proksi ulashish havolasi orqali olish",
    ),
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
    "locationPermissionGuide": m44,
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
    "madeBy": MessageLookupByLibrary.simpleMessage("Muallif"),
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
    "maxLengthTip": m45,
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
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("Xabar testi"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Bu xabar."),
    "minimize": MessageLookupByLibrary.simpleMessage("Kichraytirish"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Chiqishda kichraytirish",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("daqiqa"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Aralash port"),
    "mode": MessageLookupByLibrary.simpleMessage("Rejim"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monoxrom"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("Yana"),
    "name": MessageLookupByLibrary.simpleMessage("Nomi"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Pastki panel"),
    "network": MessageLookupByLibrary.simpleMessage("Tarmoq"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Soʻrov bekor qilindi",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Serverga ulanib boʻlmadi. Tarmoq ulanishingiz yoki proksi sozlamalarini tekshiring",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Server manzilini aniqlab boʻlmadi. URL toʻgʻriligini va DNS ishlayotganini tekshiring",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Tarmoq nomi"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Soʻrovlar juda koʻp (HTTP 429). Bir oz kuting va qayta urinib koʻring",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage(
      "Tarmoq maxfiy kaliti",
    ),
    "networkServerError": m55,
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
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Sinxronlash oraligʻi (daqiqa)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP vaqtni tizim soatidan emas, NTP serveridan oladi.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Profillar hali yoʻq. Avval profil qoʻshing",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuskatsiya"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfuskatsiya hosti"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfuskatsiya rejimi"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfuskatsiya parametri"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Obfuskatsiya paroli"),
    "onDemand": MessageLookupByLibrary.simpleMessage("Talab boʻyicha"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Talab boʻyicha rejim chiqarilgan Wi-Fida proksini toʻxtatadi.",
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
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plagin hosti"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plagin rejimi"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Boshqa port kiriting",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port sakrashi"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("Portlar"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage(
      "Oldindan boʻlishilgan kalit",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Talablar"),
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
    "profileDaysLeft": m61,
    "profileExpiresIn": m62,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Profil oʻzgartirildi. Avtomatik yangilash oʻchirilsinmi?",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Bu obuna havolasiga ega profil allaqachon mavjud",
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
    "profileUpdatedAt": m63,
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
    "providerInUse": m64,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Faqat masofaviy provayderlar qoʻllab-quvvatlanadi",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Tashqi resurslar"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proksilar"),
    "proxiesCount": m65,
    "proxiesProfileLabel": m66,
    "proxiesRemovedTip": m67,
    "proxiesReplacedTip": m68,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proksi zanjiri"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proksi guruh"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proksi guruhi boʻsh",
    ),
    "proxyGroupInUse": m69,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Yadro ishga tushgach guruhlar bu yerda paydo boʻladi",
    ),
    "proxyGroupsCount": m70,
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
    "quickActions": MessageLookupByLibrary.simpleMessage("Tezkor amallar"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Tezkor tahrirlash"),
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
    "regionAppsPreview": m71,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Ilova tanlovini oldindan ko‘rish",
    ),
    "regionBypassSettings": m72,
    "regionChina": MessageLookupByLibrary.simpleMessage("Xitoy"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("Mamlakatni tanlang"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("Joriy hudud"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Qo‘lda kiritilgan DNS va MTU, chetlab o‘tish ro‘yxati, marshrutlash qoidalari va xizmat tanlovi saqlanadi.",
    ),
    "regionDetected": m73,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage(
      "Qurilma tavsiyasi",
    ),
    "regionDnsSettings": m74,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Misr"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Interfeys tilidan mustaqil hududiy tarmoq sozlamalari va xizmat tekshiruvlari.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Eron"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Tarmoq qiymatlari va xizmat tekshiruvlari o‘zgarmaydi.",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "Mos tavsiya topilmadi. Faqat vaqt mintaqasi va tizim lokali ishlatiladi.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Xizmat tekshiruvlari o‘chirilgan",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("O‘chirilgan"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Boshqa / umumiy"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "Android tizimida MTU yoki chetlab o‘tish o‘zgarishlari VPN qayta ishga tushirilishini tasdiqlashni talab qilishi mumkin. Ilovalar alohida tanlanadi.",
    ),
    "regionPreviewBase": m75,
    "regionPreviewMtu": m76,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "Proksi tanlovi va marshrutlash qoidalaringiz o‘zgarmaydi.",
    ),
    "regionPreviewServices": m77,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Ko‘rib chiqish",
    ),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage(
      "Profil qiymatlari",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Rossiya"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Ilovalarni hudud bo‘yicha tanlash",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Hududiy ilova tavsiyalaridan foydalanish uchun avval qo‘llab-quvvatlanadigan hududni tanlang.",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "tizim tili sozlamasidagi mamlakat",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "tizim tili",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage("vaqt zonasi"),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Hudud profili"),
    "regionTunSettings": m78,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage(
      "Aniqlangan hududni tanlash",
    ),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "Mamlakatni tanlash faqat oldindan ko‘rishni yangilaydi. Hududiy qiymatlar qo‘llangandan keyin o‘zgaradi.",
    ),
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
    "replace": MessageLookupByLibrary.simpleMessage("Almashtirish"),
    "replaceAll": MessageLookupByLibrary.simpleMessage(
      "Hammasini almashtirish",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Soʻrov"),
    "requests": MessageLookupByLibrary.simpleMessage("Soʻrovlar"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Soʻrovlar va yangilanishlar",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Majburiy"),
    "reset": MessageLookupByLibrary.simpleMessage("Qayta tiklash"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Bu sahifada oʻzgarishlar bor. Asliga qaytarilsinmi?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Qayta tiklansinmi?"),
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
    "roleAuthor": MessageLookupByLibrary.simpleMessage("Muallif va meynteyner"),
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
    "rulesCount": m79,
    "runTime": MessageLookupByLibrary.simpleMessage("Ishlash vaqti"),
    "running": MessageLookupByLibrary.simpleMessage("Ishlamoqda"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Ishlash konfiguratsiyasi",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Xavfsiz rejim"),
    "safeModeAppTitle": m80,
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
    "secondsCount": m81,
    "secretKey": MessageLookupByLibrary.simpleMessage("Kalit"),
    "sectionsInEffect": m82,
    "selectAll": MessageLookupByLibrary.simpleMessage("Barchasini tanlash"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Qoida toʻplamini tanlang",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Ajratish strategiyasini tanlang",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Tanlangan"),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serviceAbnormalCount": m83,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Barchasi mavjud",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Mavjud"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloklangan"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Tekshirish"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage(
      "Hammasini tekshirish",
    ),
    "serviceCheckedAt": m84,
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
    "settingsCount": m85,
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
    "setupProfileCount": m86,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash serverlarni taqdim etmaydi. Provayderingiz obunasini yoki konfiguratsiyasini import qiling.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Profilni import qilish",
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
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage(
      "Ushbu hudud sozlamalaridan foydalanish",
    ),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "Tavsiya etilgan hudud interfeys tilidan emas, qurilmadan olinadi. Faqat tarmog‘ingizga mos bo‘lsa qo‘llang.",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Profil standartlarini saqlash",
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
    "setupStepStatus": m87,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Tanlovlaringiz saqlandi. Avvalgi ulanish to‘xtatilmadi.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Tekshiruv to‘xtatildi",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Birinchi ulanish"),
    "setupTryServer": m88,
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
    "shareLinkUnreadable": m89,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Havolalardan proksi oʻqib boʻlmadi",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Koʻrsatish"),
    "showLess": MessageLookupByLibrary.simpleMessage("Yigʻish"),
    "showMore": MessageLookupByLibrary.simpleMessage("Yoyish"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Bildirishnomadagi «Toʻxtatish» tugmasi",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Parolni koʻrsatish"),
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
    "singleAdd": MessageLookupByLibrary.simpleMessage("Alohida qoʻshish"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Alohida import"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Bu yerga bitta havola kiriting; bir nechtasini roʻyxatning tez tahrir orqali tahrirlang",
    ),
    "singleValueTip": m90,
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
    "subscriptionCompatibilityPrepared": m91,
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
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "Yoqilganda, profil bu sozlamani bekor qilmasa, qurilma identifikatori barcha URL obunalari so‘rovlarida yuboriladi. Operatsion tizim va qurilma tafsilotlari har bir obuna uchun alohida yoqiladi.",
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
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "Qabul qilish va import qilish",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Manba ma’lumotlarining bir qismi saqlanmasligini tushunaman.",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "Faqat qo‘llab-quvvatlanadigan tugunlar bilan davom etish.",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "Manba mijoz sozlamalari ko‘chirilmasligini tushunaman.",
    ),
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
    "subscriptionImportIgnoredSections": m92,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Import qilinadigan qo‘llab-quvvatlangan proksi tugunlari yo‘q.",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Bu obuna uchun rozilikni eslab qolish",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Faqat shu manba, format va qabul qilingan yo‘qotish turlariga tegishli. Yangi yo‘qotishlar qayta rozilik talab qiladi.",
        ),
    "subscriptionImportReviewSummary": m93,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Obuna importini ko‘rib chiqish",
    ),
    "subscriptionImportSkippedNodes": m94,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Obuna ma’lumotlari",
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
    "toolsResults": m95,
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
    "torch": MessageLookupByLibrary.simpleMessage("Fonar"),
    "total": MessageLookupByLibrary.simpleMessage("Jami"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Yuklab olingan"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Jami trafik"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Yuklab yuborilgan"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafik"),
    "trafficPeak": m96,
    "trafficTotal": m97,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafik sarfi"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash turli mamlakatlardagi odamlar foydalana olishi uchun sizning tilingizda gaplashadi. Biror ibora g‘aliz ko‘rinsa — yozing, tuzatamiz.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Tarjima tuzatishni taklif qilish",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
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
    "updateChannel": MessageLookupByLibrary.simpleMessage("Yangilanish kanali"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Dastlabki reliz"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Barqaror reliz",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Yangilanishlarni tekshirib bo‘lmadi.",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Yangilanishni yuklab bo‘lmadi.",
    ),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Paket o‘rnatuvchisini ishga tushirib bo‘lmadi.",
    ),
    "updateInstalledVersion": m98,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage(
      "Sizda allaqachon eng yangi versiya o‘rnatilgan.",
    ),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage(
      "Nimalar yangilandi",
    ),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Reliz qaydlari mavjud emas.",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash’ga ushbu manbadan ilovalarni o‘rnatishga ruxsat bering va davom etish uchun qayting.",
    ),
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "To‘liq reliz qaydlarini ko‘rish",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Barcha oʻzgarishlarni koʻrsatish",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Yuklab olingan yangilanish yaxlitligini tekshirib bo‘lmadi.",
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
      "HTTP yoki HTTPS obuna URL manzilidan profil yaratish. Nom ixtiyoriy.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Shifrlangan havolaning haqiqiyligi tasdiqlanmadi. U buzilgan yoki boshqa kalitdan foydalanayotgan bo‘lishi mumkin.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Havola yaratish"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "Faqat ushbu amal uchun zarur maydonlar qo‘shiladi. Konfiguratsiya havolasi to‘liq tarkibni saqlaydi va tasdiqlashni chetlab o‘tmaydi.",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Ilovani yopish"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Yopish sozlamasiga rioya qilish: oynani yashirish yoki ReClash’dan chiqish. Android odatiy ilova yopish xatti-harakatini ishlatadi.",
    ),
    "urlSchemeConfigCounts": m99,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML yoki JSON konfiguratsiyasini joylashtiring",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiya tarkibi",
    ),
    "urlSchemeConfirmMessage": m100,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Ilovaning tashqi buyrug‘i",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Tashqi ulanish va yopish buyruqlari tasdiqlashni talab qiladi. Ulanish buyruqlaridan oldin dastlabki sozlashni tugating.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Ulash"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Tanlangan profil va joriy qamrov sozlamalari bilan ulanishni boshlash.",
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
      "Tanlangan profilni o‘zgartirmasdan ulanishni to‘xtatish.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Ichki konfiguratsiya",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Namuna profil",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Konfiguratsiyani import qilish",
    ),
    "urlSchemeImportConfirm": m101,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Havolaga Base64 sifatida joylangan UTF-8 konfiguratsiyasini import qilish. Nom ixtiyoriy.",
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
      "Clash mijozlari qo‘llaydigan install-config havola formati orqali obunani import qilish.",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "ReClash’ni yorliqlar, saytlar va boshqa ilovalar bilan bog‘lang. Tayyor havola yarating yoki ochishdan oldin tekshiring.",
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
      "Ulanishni o‘zgartirmasdan ReClash’ni oldingi planga chiqarish.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parametrlar"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Buferni o‘qib bo‘lmadi. Havolani qo‘lda joylashtiring.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage(
      "Havolani oldindan ko‘rish",
    ),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Havolani ko‘rish uchun majburiy maydonlarni to‘ldiring.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Havolada kirish tokenlari yoki proksi hisob ma’lumotlari bo‘lishi mumkin. Uni faqat ishonchli odamlar bilan ulashing; ReClash havolalar tarixini saqlamaydi.",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "Profil buyruqlari havola yaratuvchisini ochadi. Tashqi import rozilik so‘raydi va odatiy tekshirish hamda o‘girishni saqlaydi.",
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
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Clash havolalari, INCY va Happ o‘ramlari hamda proksi havolalari qo‘lda import va QR skanerlashda ham ishlaydi. Noma’lum shifrlash versiyalari rad etiladi.",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Ulanishni almashtirish",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "To‘xtagan bo‘lsa ulash, ishlayotgan bo‘lsa uzish. Tasdiqlash oynasi haqiqiy amalni ko‘rsatadi.",
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
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "Obuna havolalari, ichki konfiguratsiyalar va INCY crypt1",
    ),
    "urlTip": m102,
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
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV sozlamalari",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Veb panel"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Panelga kirish yakunlandi",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Kirish mahalliy va autentifikatsiya bilan himoyalangan. Saqlangan tashqi kontroller sozlamalari oʻzgarmaydi. Brauzerda ishni tugatgach, kirishni shu yerda yakunlang.",
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
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage("Panel fayllari"),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Panel"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Panelni oʻrnatish",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Tanlangan panel birinchi ochishda yuklab olinadi. Belgilangan reliz SHA-256 orqali tekshiriladi.",
    ),
    "webDashboardInstalledVersion": m103,
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
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Oq roʻyxat rejimi"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Tizimga yozish"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Tizimga yozish tizim soatini ham oʻrnatadi; Android bunga eʼtibor bermaydi.",
    ),
    "yearsAgo": m104,
    "yearsAgoShort": m105,
    "yes": MessageLookupByLibrary.simpleMessage("Ha"),
    "zhCN": MessageLookupByLibrary.simpleMessage(
      "Soddalashtirilgan xitoy tili",
    ),
  };
}
