// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tk locale. All the
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
  String get localeName => 'tk';

  static String m0(count) =>
      "${Intl.plural(count, other: '${count} saýlandy')}";

  static String m1(count) =>
      "Üpjün edijiňiziň VPN-den daşarda goýýan programmalary: ${count}. Sanawy üýtgetmek üçin elýeterlilik dolandyryşyny açyň.";

  static String m2(name) => "${name} ýerli proksilere goşuldy";

  static String m3(name) => "${name} eýýäm ýerli proksilerde bar";

  static String m4(count, skipped) =>
      "${count} goşulýar, ${skipped} eýýäm bar bolandygy sebäpli geçerildi";

  static String m5(detail) => "Maglumatlary arassalap bolmady: ${detail}";

  static String m6(code) =>
      "Windows ReClashCore.exe-i işletmedi (ýalňyşlyk kody: ${code}). Smart App Control ýa-da AppLocker ýaly programmalar gözegçiliginiň syýasaty gol çekilmedik programmalary bogýar; şol syýasatda ReClash-a rugsat beriň ýa-da ony öçüriň, soňra täzeden synanyşyň.";

  static String m7(name) =>
      "Programmanyň açylyşy yzly-yzyna iki gezek tamamlanmady. Aýlawy kesmek üçin ${name} profili saýlawdan çykaryldy, awtomatiki düzüm ýerine ýetirilmedi. Ony islänleriňizde gaýtadan saýlap bilersiňiz.";

  static String m8(url) => "${url} adresinden profil döretmek isleýärsiňizmi?";

  static String m9(groups) =>
      "${groups} proksi toparlaryndan ähli goşulanlar (include-all) aýryldy; şol toparyň ulanýan proksilerini ýa-da proksi üpjün edijilerini goşuň";

  static String m10(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE düzgüni taşlandy, sebäbi özbaşdak profiller içki düzgünleri goldamaýar', other: '${label} SUB-RULE düzgüni taşlandy, sebäbi özbaşdak profiller içki düzgünleri goldamaýar')}";

  static String m11(message) =>
      "Çekirdek bu proksini çözip bilmedi: ${message}";

  static String m12(proxy, target) =>
      "${proxy} ${target} arkaly jaň edýär, emma şol ýol ${proxy}-e dolanýar, şonuň üçin jaň aýlaw emele getirýär";

  static String m13(name) =>
      "${name} ady eýýäm başga proksi ýa-da proksi topar tarapyndan ulanylýar";

  static String m14(path) =>
      "Proksi toparlary bir-birini aýlaw bilen salgylanýar: ${path}";

  static String m15(name) =>
      "Boş ätiýaçlyk proksi bolmaly, emma ${name} ýok ýa-da proksi topar";

  static String m16(name, message) => "${name} dogry regex däl: ${message}";

  static String m17(name) => "Birikme proksisi ${name} ýok";

  static String m18(names) => "Şu proksi üpjün edijileri ýok: ${names}";

  static String m19(names) => "Şu proksiler ýa-da syýasatlar ýok: ${names}";

  static String m20(name) =>
      "${name} programmada öz içine gurulan syýasat ady, şu ýerde ulanylyp bilinmez";

  static String m21(count) =>
      "${count} bentde näsazlyk bar; şu profili ulanmak şowsuz bolup biler";

  static String m22(count) =>
      "${Intl.plural(count, one: '1 gün öň', other: '${count} gün öň')}";

  static String m23(count) => "${Intl.plural(count, other: '${count} g öň')}";

  static String m24(label) => "Saýlanan ${label} ýoklamak isleýärsiňizmi?";

  static String m25(label) => "Bu ${label} ýoklamak isleýärsiňizmi?";

  static String m26(label) => "${label} barada jikme-jik maglumat";

  static String m27(name) =>
      "${name} arkaly jaň etmek ony ulanýan proksiniň üstüne dolanýar, şonuň üçin jaň ýatyryldy";

  static String m28(label) => "${label} boş bolup bilmez";

  static String m29(label) => "${label} eýýäm bar";

  static String m30(count) => "${count} bent şowsuz boldy";

  static String m31(label, message) => "${label}: ${message}";

  static String m32(name) => "${name} eýýäm täze";

  static String m33(name) => "${name} täzelendi";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 topar', other: '${count} topar')}";

  static String m35(count) => "${count} wagty çykdy";

  static String m36(action) =>
      "«${action}» üçin ulanylýär. Ýatda saklasaňyz, şu ýere geçer.";

  static String m37(actions) => "Eksport edilmedi: ${actions}";

  static String m38(modifiers) => "Iň bolmanda ${modifiers} birini goşuň";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 sagat öň', other: '${count} sagat öň')}";

  static String m40(count) => "${Intl.plural(count, other: '${count} s öň')}";

  static String m41(target) => "«${target}» nädogry syýasat";

  static String m42(proxyName) => "«${proxyName}» nädogry proksi";

  static String m43(providerName) =>
      "«${providerName}» nädogry proksi üpjün edijisi";

  static String m44(ruleSet) => "${ruleSet} nädogry düzgünler toplumy";

  static String m45(subRule) => "«${subRule}» nädogry SUB_RULE";

  static String m46(count) =>
      "${Intl.plural(count, one: '1 bent', other: '${count} bent')}";

  static String m47(line, message) => "Setir ${line}: ${message}";

  static String m48(appName) =>
      "1. Ulgam sazlamalaryny açyň > Gizlinlik we howpsuzlyk\n2. Ýerleşýän ýer hyzmatlaryny saýlaň\n3. Sanawdan ${appName} atly programmany tapyp saýlaň\n\nGutaranyňyzdan soň programmaga gaýdyp geliň we dowam ediň. Golduşyňyz üçin sag boluň.";

  static String m49(label, max) => "${label} ${max} belgiden geçmeli däl";

  static String m50(size) => "${size} boşadyldy";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 minut öň', other: '${count} minut öň')}";

  static String m52(count) => "${Intl.plural(count, other: '${count} m öň')}";

  static String m53(count) =>
      "${Intl.plural(count, one: '1 aý öň', other: '${count} aý öň')}";

  static String m54(count) => "${Intl.plural(count, other: '${count} aý öň')}";

  static String m55(code) =>
      "Serwer girişi ret etdi (HTTP ${code}). Salgy möhleti gutaran bolup biler ýa-da giriş maglumatlary nädogry";

  static String m56(code) => "Serwer haýyşy ret etdi (HTTP ${code})";

  static String m57(code) =>
      "Bu salgyda hiç zat tapylmady (HTTP ${code}). URL-iň dogrulygyny barlaň";

  static String m58(detail) => "Tor haýyşy şowsuz boldy: ${detail}";

  static String m59(code) =>
      "Serwede näsazlyk ýüze çykdy (HTTP ${code}). Soňra gaýtadan synanyşyň";

  static String m60(label) => "Häzir ${label} ýok";

  static String m61(label, min, max) =>
      "${label} ${min} we ${max} aralygynda bolmaly";

  static String m62(label) => "${label} san bolmaly";

  static String m63(label) => "${label} 1024 bilen 49151 arasynda bolmaly";

  static String m64(port) => "Port ${port}";

  static String m65(added, skipped, failed) =>
      "Goşuldy: ${added}; geçirildi: ${skipped}; şowsuz: ${failed}.";

  static String m66(days) =>
      "${Intl.plural(days, one: '1 gün galdy', other: '${days} gün galdy')}";

  static String m67(date, days) =>
      "Gutaryş senesi ${date}, ${Intl.plural(days, one: '1 gün', other: '${days} gün')} galýar";

  static String m68(name) => "Eýýäm «${name}» hökmünde goşuldy";

  static String m69(client) => "${client} programmasy alşy ýaly";

  static String m70(count) => "${Intl.plural(count, other: '${count} serwer')}";

  static String m71(time) => "${time} täzelendi";

  static String m72(label, profiles) =>
      "${label} ${profiles} tarapyndan entek ulanylýar; ony ýok etseňiz, olar doly işlemeýär. Ony ýoklamak isleýärsiňizmi?";

  static String m73(count, label) =>
      "${Intl.plural(count, one: '1 proksi', other: '${label} proksi')}";

  static String m74(name, count) => "${name} we başgalar (${count} proksi)";

  static String m75(removed) =>
      "Şu proksiler ýok ediljek: ${removed}. Ady üýtgelen setir täze proksi hasaplanýar, ýok edilýänleri atalýan özbaşdak profiller bolsa olary ýok diýip bellär. Barybir ulanmaly?";

  static String m76(removed, added) =>
      "Şu proksiler ýok ediljek: ${removed}. Şular goşuljak: ${added}. Ady üýtgelen setir täze proksi hasaplanýar, ýok edilýänleri atalýan özbaşdak profiller bolsa olary ýok diýip bellär. Barybir ulanmaly?";

  static String m77(label) =>
      "${label} şu profiliň düzgünleri, proksi toparlary, birikme proksileri, DNS ýa-da NTP tarapyndan entek atalýar; ony ýok etseňiz, olar işlemez. Ony ýoklamak isleýärsiňizmi?";

  static String m78(count, label) =>
      "${Intl.plural(count, one: '1 proksi topary', other: '${label} proksi topary')}";

  static String m79(pick, now) => "${now} ýerine ${pick} saýlardy";

  static String m80(group) => "${group} barlagy";

  static String m81(pick) => "${pick} saklardy";

  static String m82(number) => "Şert ${number}";

  static String m83(profile) => "«${profile}» şu saýtlary barlamak isleýär";

  static String m84(count) => "${Intl.plural(count, other: '${count} serwer')}";

  static String m85(profile) => "«${profile}» pozulsynmy?";

  static String m86(requests, used, cap) =>
      "Şu günki barlaglar: ${requests} · ${cap}-den ${used}";

  static String m87(condition) => "${condition} bolmasa";

  static String m88(country) => "çykyş ${country}";

  static String m89(member) => "${member} arkaly";

  static String m90(title) =>
      "«${title}» üýtgedip bolmaýar. Üýtgetmeler nusga ýazylar we nusga işleýän ssenariý bolar.";

  static String m91(mode) =>
      "Ugurlar düzgün tertibinde işleýär; häzir birikme ${mode} tertibinde.";

  static String m92(profile) => "«${profile}» goşuldy";

  static String m93(node) => "${node} işlemesini bes etdi";

  static String m94(from, to) => "Režim ${from} → ${to}";

  static String m95(count) =>
      "${Intl.plural(count, other: 'Häzir ${count} serwer gabat gelýär')}";

  static String m96(ms) => "${ms} ms-dan az";

  static String m97(text) => "adynda ${text}";

  static String m98(what) => "${what} däl";

  static String m99(provider) => "${provider} üpjünçisinden";

  static String m100(number) => "Ädim ${number}";

  static String m101(action) =>
      "Hiç bir ädimde işleýän serwer bolmasa: ${action}";

  static String m102(tag) => "${tag} tegi";

  static String m103(line, text) => "${line}-nji setir: ${text}";

  static String m104(check) =>
      "${check} barlagy hiç ýerde ulanylmaýar, şonuň üçin işlemeýär";

  static String m105(hosts) => "Üçünji tarap saýtlaryna birigýär: ${hosts}";

  static String m106(group) => "Bu konfigurasiýada ${group} topary ýok";

  static String m107(group) =>
      "${group} toparynyň hiç bir serweri süzgüçden geçmeýär";

  static String m108(tag) => "${tag} tegi hiç ýerde ulanylmaýar";

  static String m109(tier, group) =>
      "Häzir ${group} toparynyň hiç bir serweri «${tier}» içinde däl";

  static String m110(tier, after) =>
      "«${tier}» «${after}» şertini gaýtalaýar, şonuň üçin oňa hiç zat düşmeýär";

  static String m111(name, count) => "${name} we ýene ${count}";

  static String m112(keys) =>
      "Geçirildi; muny siz hem üýtgetdiňiz, şonuň üçin siziňki saklandy: ${keys}";

  static String m113(mode) => "Režim: ${mode}";

  static String m114(node) =>
      "${node} serwerinde galýar; ondan diňe näsazlykda gidýär we ol dikelende yzyna gaýdýar.";

  static String m115(kind) => "Tor: ${kind}";

  static String m116(tier) => "barlagdan soň «${tier}» derejesine geçip biler";

  static String m117(node) => "Berkidilen: ${node}";

  static String m118(error) => "Profil ýalňyşlygy: ${error}";

  static String m119(profile) =>
      "${profile} profili tapylmady; adaty ulanylýar";

  static String m120(error) => "Ugur ýagdaýyny saklap bolmady: ${error}";

  static String m121(tier) => "«${tier}» serwerine geçildi";

  static String m122(from) => "Serwer çalşyldy; ${from} 15 minut geçirilýär";

  static String m123(from) =>
      "${from} işlemesini bes etdi; iň gowy ätiýaçlyga geçildi";

  static String m124(from, gain) => "${from}-den geçildi: ${gain} ms çaltrak";

  static String m125(node) => "Senari ${node} saklaýar";

  static String m126(node) => "${node} bu topar-da ýok";

  static String m127(limit) => "Çalyşma çägine ýetildi (sagatda ${limit})";

  static String m128(mode) => "Ulanylmaýar: ${mode} režimi";

  static String m129(from) => "${from} indi sanawda ýok";

  static String m130(kind) =>
      "Tor «${kind}» bolanda togtadyldy: hiç zat barlanmaýar we çalşylmaýar";

  static String m131(route, error) =>
      "«${route}» ugruny ulanyp bolmady: ${error}";

  static String m132(route) =>
      "«${route}» ugry geçildi: şeýle atly topar eýýäm bar.";

  static String m133(route, to) =>
      "«${route}» ugry trafigi profilde ýok «${to}» toparyna iberýär.";

  static String m134(node) => "Senari ${node} geçirýär";

  static String m135(node) => "Berkidilen ${node} serwere geçildi";

  static String m136(node) => "Işleýän serwer ýok; ${node} ulanylýar";

  static String m137(scenario) =>
      "Bu topary «${scenario}» ssenariýsiniň ugry döretdi. Ony şol ýerde üýtgedip ýa-da pozup bilersiňiz.";

  static String m138(scenario) =>
      "Häzir bu topary «${scenario}» senarisi dolandyrýar.";

  static String m139(count, total) => "${total}-den ${count} gabat gelýär";

  static String m140(node) => "Barlag tassyklasa, ${node} serwere geçer";

  static String m141(node, gain) =>
      "${gain} ms çaltrak galsa, ${node} serwere geçer";

  static String m142(node, minutes) =>
      "${minutes} minutdan ${node} serwere geçip biler";

  static String m143(name) => "${name} barlagy";

  static String m144(name) => "${name} tor diagnostikasy";

  static String m145(count) =>
      "${Intl.plural(count, other: '${count} serwer deňeşdirildi')}";

  static String m146(count) =>
      "${Intl.plural(count, other: 'Bu toparyň ${count} serwerinden saýlaýar.')}";

  static String m147(region, bypassed, proxied) =>
      "${region}: VPN-den aýlanyp geçiş sanawyna ${bypassed} programma, VPN sanawyna ${proxied} programma girer. Iki sanaw hem çalşylar; iş tertibi we beýleki sazlamalar üýtgemez. Paket we SDK gabat gelmeleri diňe teklipdir: ulananyňyzdan soň netijäni barlaň.";

  static String m148(seconds) => "${seconds} sekuntdan tassyklap bilersiňiz";

  static String m149(count, label) =>
      "${Intl.plural(count, one: '1 düzgün', other: '${label} düzgün')}";

  static String m150(appName) => "${appName} (Howpsuz režim)";

  static String m151(count) =>
      "${Intl.plural(count, one: '1 sekunt', other: '${count} sekunt')}";

  static String m152(count) => "${count} bölim işleýär";

  static String m153(count) =>
      "${Intl.plural(count, one: '1 mesele', other: '${count} mesele')}";

  static String m154(count) =>
      "${Intl.plural(count, one: '1 sazlama', other: '${count} sazlama')}";

  static String m155(count) => "VPN-den daşary programmalar: ${count}";

  static String m156(count) => "Elýeterli profiller: ${count}";

  static String m157(step, total) => "${step} / ${total}";

  static String m158(server) => "${server} serwerini syna";

  static String m159(link) =>
      "${link} salgysyndan hiç bir proksi okalyp bilmedi";

  static String m160(count) => "${Intl.plural(count, other: '${count} gün')}";

  static String m161(delay) => "${delay} ms";

  static String m162(service) => "${service} bu salgyny blokirleýär";

  static String m163(service) => "${service} entek bu ýerde elýeterli däl";

  static String m164(service) =>
      "${service} bu ýerde diňe öz eserlerini görkezýär";

  static String m165(service) => "${service} çäklendirmeler bilen işleýär";

  static String m166(service) => "${service} açylmaýar";

  static String m167(service) => "${service} bu ýurtda işlemeýär";

  static String m168(size) =>
      "Diňe basanyňyzda VPN-siz takmynan ${size} ýükleýär.";

  static String m169(size) =>
      "Diňe basanyňyzda VPN arkaly takmynan ${size} ýükleýär.";

  static String m170(network) => "Ynamly tor «${network}»";

  static String m171(total) => "${total} içinden galdy";

  static String m172(date) => "${date} çenli";

  static String m173(label) => "${label} tek bent bolmaly";

  static String m174(client, format, count) =>
      "${client} hökmünde alyndy: ${format}, proksi düwünleri: ${count}.";

  static String m175(count) =>
      "${Intl.plural(count, one: 'Abunaňyz ertir gutarýar', other: 'Abunaňyz ${count} günden soň gutarýar')}";

  static String m176(count) => "${count} serwer goş";

  static String m177(count) => "Ähli ${count} serwer goşular";

  static String m178(count, total) =>
      "${total} serwerden ${count} serwer goşular";

  static String m179(count) => "Hemmesini görkez (${count})";

  static String m180(format) => "Format: ${format}";

  static String m181(percent) => "Trafigiň ${percent}%-i ulanyldy";

  static String m182(count) => "${count} netije";

  static String m183(value) => "Ýokarky nokat ${value}";

  static String m184(value) => "Jemi ${value}";

  static String m185(transport) => "${transport} sözbaşylary";

  static String m186(version) => "Gurnalan wersiýa: ${version}";

  static String m187(count) => "${count} min";

  static String m188(time) => "${time} galdy";

  static String m189(count) => "${count} s";

  static String m190(speed) => "${speed}/s";

  static String m191(nodes, groups, providers) =>
      "Proksiler: ${nodes}, toparlar: ${groups}, uzakdaky üpjün edijiler: ${providers}";

  static String m192(action) =>
      "Bu salgylanma «${action}» hereketini soraýar. ReClash-a ony ýerine ýetirmäge rugsat berilsinmi?";

  static String m193(name, source) =>
      "${source} çeşmesinden «${name}» import edilsinmi? Tassyklamadan soň profil we öwürmeler barlanar.";

  static String m194(label) => "${label} URL bolmaly";

  static String m195(index) => "Fon ${index}";

  static String m196(count) =>
      "Iň köp ${count} fon saklap bolýar. Täzesini goşmak üçin birini aýyryň.";

  static String m197(count) =>
      "${Intl.plural(count, one: '1 ýyl öň', other: '${count} ýyl öň')}";

  static String m198(count) => "${Intl.plural(count, other: '${count} ý öň')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Barada"),
    "accessControl": MessageLookupByLibrary.simpleMessage(
      "Elýetmäge gözegçilik",
    ),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe saýlanan programmalar VPN arkaly geçýär",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Elýetmäge gözegçilik haýsy programmalaryň proksini ulanýandygyny kesgitleýär.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Programmalaryň elýetmäsine gözegçilik öçürilen",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Saýlanan programmalar VPN-den çykarylýar",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Elyetmäge gözegçiligiň sazlamalary",
    ),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Programmalary üpjün edijä gaýtar",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Hasap"),
    "action": MessageLookupByLibrary.simpleMessage("Hereket"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Ähli gijikmeleri syna",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Göni usul"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Global usul"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Usuly çalyş"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Ulgam proksisi"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Düzgün usuly"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Başlat/Bes et"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Profilleri täzele",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Görkez/Gizle"),
    "add": MessageLookupByLibrary.simpleMessage("Goş"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Proksi goş"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Süzgüçleri goş"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Tor goş"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Düwünleri goş"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Ýazyp geçirme ýazgysyny goşmak",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Profil goş"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Proksiler toparyny goş",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Düzgün goş"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Sazlama goş"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSID goş"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Ýerli proksilere goş",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Goşulan düzgünler"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Goşmaça parametrler",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage(
      "Adynyň öňki goşundysy",
    ),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage(
      "Adynyň soňki goşundysy",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Salgy"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV serweriniň salgysy",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Dogry WebDAV salgysyny giriziň",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin sazlamalar",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin sazlamalar tor, DNS, goşulan düzgünler we skriptleri saklaýar.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Sifrlenen profil",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Age gizli açar"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Bu profil age bilen sifrlenen, açmak üçin age gizli açary gerek",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Razy"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Salgylanýan ähli proksiler",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Salgylanýan ähli proksi üpjün edijileri",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Programmalara VPN-iň daşyndan geçmäge rugsat ber",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN-a rugsat bermek"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Rugsat berilen IP-lar"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("Jogaplar"),
    "app": MessageLookupByLibrary.simpleMessage("Programma"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Programmalaryň elýetmäsine gözegçilik",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Programma nyşany"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("Bu nyşany ulan"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Çyzgy"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Baş ekrana täze nyşany görkezmek üçin birnäçe sekunt gerek bolup biler. Käbir launcherler gysgaltmany aýyrýar — ony programmalar sanawyndan ýene goşuň.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Zynjyr"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Programma nyşanynyň görnüşi",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Ýañrama"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Siýa"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Böleklär"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Günüş"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Uçgun"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Standart"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Gatlaklar"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Relýef"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Yzy"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Barhat"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("Ýerli proksi ýok"),
    "appRegion": MessageLookupByLibrary.simpleMessage("Programma sebiti"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Fon"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Interfeýs"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Tema"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Ulgam DNS-ini goşmak",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Programma sazlamalary",
    ),
    "applied": MessageLookupByLibrary.simpleMessage("Ulanyldy"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Häzir ulan"),
    "authentication": MessageLookupByLibrary.simpleMessage("Şahsyýet tanamak"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Şahsyýet tanamak ýerli proksi portunda ulanyjy adyny we parolyny talap edýär.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Şahsyýet tanamak açyk bolanda ulgam proksisi ulanylmaýar.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Rugsat ber"),
    "authorized": MessageLookupByLibrary.simpleMessage("Rugsat berlen"),
    "auto": MessageLookupByLibrary.simpleMessage("Awtomatiki"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Täzelenmeleri awtomatiki barlamak",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyklary awtomatik ýap",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyklary awtomatiki ýapmak proksileri çalyşanda açyk baglanyşyklary ýapýar.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("Awtomatik goş"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki işe girizmek",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Awtomatiki işletmek"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki işletmek programma açylanda proksini başlaýar.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Ulgam DNS-ini awtomatiki düzmek",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Awtomatiki täzelenme"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki täzelenme aralygy",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Yza"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("Fon bulanyklygy"),
    "backup": MessageLookupByLibrary.simpleMessage("Ätiýaçlyk nusgasy"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Nusga almak we dikeltmek",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Bu ätiýaçlyk nusgasy programmanyň has täze wersiýasyndan gelýär. Ony dikeltmezden öň programmany täzeleniň",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Ätiýaçlyk nusgasy alyndy",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Esasy maglumatlar"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage(
      "Esasy strategiýalar",
    ),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Sanap goşmak"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Sanap import"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Bir setirde bir salgy",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Bir setirde bir baha, ýa-da wergul bilen aýryp ýazyň",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Bir setirde bir ýazgy: açar, bir bosluk, soň bahasy",
    ),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Bir setirde bir URL",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Batareýa optimizasiýasyny äsgermezlik etmegi programma fonda işläp galmagyny üpjün edýär.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bagla"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Gara sanaw usuly"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Baglanyşygy blokirle",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Ýagtylyk"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage(
      "Göni geçirilýän domenler",
    ),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Göni geçirilýän domenler diňe ulgam proksisi açyk bolanda güýje girer.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Hususy salgylary geç",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Hususy salgylary geç açyk bolanda LAN, loopback we multicast salgylar TUN-dan geçýär.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Keş"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Keş algoritmi"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Keş bozuldy. Arassalamak isleýärsiňizmi?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Keş ölçegi"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QR kodlary skanerlemek üçin ulgam sazlamalarynda kamera girişine rugsat beriň ýa-da galereýadan QR kod suratyny saýlaň.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Kamera rugsady gerek",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Kamera elýeterli däl",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Ýatyr"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Ählisini aýyr"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Saklap bolmady"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Proksini çalyşyp bolmady; öňki saýlaw dikeldildi",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Utgaşygy bozýan üýtgeşmeler",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage(
      "Täze funksiýalar",
    ),
    "changelogFixes": MessageLookupByLibrary.simpleMessage(
      "Säwlik düzetmeleri",
    ),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Netijelilik"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage(
      "Gaýtarylan üýtgeşmeler",
    ),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "TLS şaýatnamalaryny barlamak",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS barlagy öçürilende abunalyklar we ätiýaçlyk nusgalary aradaky adam hüjümlerine duçar bolýar.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Täzelenmeleri barla"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Programma eýýäm iň täze wersiýada",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Şifre"),
    "clearData": MessageLookupByLibrary.simpleMessage("Maglumatlary arassala"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Bu hereket ähli profilleri, sazlamalary we ýerli maglumatlary ýok edýär, soň programmany ýapýar. Täzeden başlamak üçin ony ýene-de açyň.",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage(
      "DNS keşini arassala",
    ),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "DNS keşini arassalap bolmady",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Gözlegi arassala"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Müşderi barma izi",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Göçüriş buferine çykar",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Göçüriş buferinden giriz",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Çalyşma buferine göçürip bolmady. Saýlanan bölek aşa uly bolup biler",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Ýap"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyklary ýap",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN bes edilende ähli açyk baglanyşyklar ýapylýar",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Reňk"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Kontrast"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Reňk stili"),
    "columns": MessageLookupByLibrary.simpleMessage("Sütünler"),
    "compact": MessageLookupByLibrary.simpleMessage("Kompakt"),
    "compatible": MessageLookupByLibrary.simpleMessage("Utgaşyk usuly"),
    "confirm": MessageLookupByLibrary.simpleMessage("Tassykla"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Ähli maglumatlary arassalamak isleýärsiňizmi?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Bu proksiler toparyny ýoklamak isledýärsiňizmi?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Häzirki penjireden çykmak isledýärsiňizmi?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Çekirdegi meýletin dargatmak isleýärsiňizmi?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Dyknyşygyny dolandyrmak",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "TCP trafik dyknyşygyny dolandyrmak",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP trafik dyknyşygyny dolandyrmak diňe mips steginde işleýär.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Bagly"),
    "connecting": MessageLookupByLibrary.simpleMessage("Baglanylýar…"),
    "connection": MessageLookupByLibrary.simpleMessage("Baglanyşyk"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyk statistikasy",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Janly baglanyşyklar, soňky soraglar we DNS soraglary",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Baglanyşyklar"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Baglanyşyk: "),
    "content": MessageLookupByLibrary.simpleMessage("Mazmun"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Mazmun boş bolmaly däl",
    ),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Ýokary"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Orta"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Global goşulan düzgünleri dolandyrmak",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Göçür"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Gurşaw üýtgeýjilerini göçürip al",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("URL-i göçürip al"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Göçürildi"),
    "core": MessageLookupByLibrary.simpleMessage("Çekirdek"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Arhitektura"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows-yň Smart App Control-y ReClashCore.exe gol çekilmedikligi sebäpli ony bogýar. Windows Howpsuzlygy → Programmalar we brauzer gözegçiligi → Smart App Control sazlamalaryna giriň, «Öçürilen» görnüşini saýlaň, soňra ReClash-y täzeden açyň. Windows-y täzeden gurmadan Smart App Control-y gaýtadan işledip bolmaýar.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("Ýygnama baýdaklary"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("Ýygnalan wagty"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Gurşaw"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("Ýadro faýly"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ýadro maglumatlaryny okap bolmady",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Işlediş usuly"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Ýerleşiş"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Dolandyrylýan ýokary ygtyýarly proses",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Helper arkaly proses",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Prosesiň içindäki kitaphana",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Gol çekilen Helper arkaly dolandyrylýan proses",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("Aýratyn proses"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Iş wagty konfigurasiýasyny açmak",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Platforma"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Çekirdek işleýär"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Iş wagty konfigurasiýasy",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Sazlamalar we skriptler ulanylandan soňky jemleýji konfigurasiýa. Diňe okamak üçin.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Iş wagty konfigurasiýasyny okap bolmady",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Işe başlaýar…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Çekirdegiň ýagdaýy"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Saklandy"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Maglumat katalogy",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Sebit"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Dargamak anyklandy"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("Dargamak synagy"),
    "create": MessageLookupByLibrary.simpleMessage("Döret"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("Döredilen wagt"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI böwüsme"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "Programmanyň binýady",
    ),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Goşmaça funksiýalar",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijilere degişli funksiýalar we pikirler",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Proksi çekirdegi"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Başlat düwmesini saklaýar, ýok edip bolmaýar",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Özbaşdak"),
    "customColor": MessageLookupByLibrary.simpleMessage("Özbaşdak reňk"),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("Ady boş"),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Hiç bir proksi ýa-da proksi üpjün edijisi saýlanmady, şonuň üçin çekirdek bu topary ret edýär",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("Özbaşdak"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Özbaşdak profil serişdeleri",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Özbaşdak profil serişdeleri proksileri, düzgünler üpjün edijilerini, süzgüçleri we nyşan toplumlaryny saklaýar.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Kes"),
    "dark": MessageLookupByLibrary.simpleMessage("Garaňky"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Panel"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Goşulmaga elýeterli",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Panel"),
    "dashboardStyleDetailed": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin",
    ),
    "dashboardStyleSimple": MessageLookupByLibrary.simpleMessage("Ýönekeý"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmäni ýatda saklap bolmady; yza alnyp alyndy",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("Deslapky saýlaw"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Standart"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýa ady we görnüşi bolan YAML kartasy bolmaly",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Saklanma"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Şowsuz"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Gijikme synagy"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Gijikme synagynyň garaşma wagty",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Ýokla"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta esasynda gurlan köp platformaly proksi müşderisi: peýdalanmagy aňsat, açyk kodly we reklamasyz.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Grafiki rugsat agenti elýeterli däl. Ony şu iş stoly sessiýasynda başladyň we gaýtadan synanyşyň.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Rugsat bermek ýatyryldy. TUN başlamady.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "Rugsat berilmedi. TUN başlamady.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN üçin rugsat gerek. Rugsat bermek üçin birikmäni başladyň ýa-da TUN-y açyň.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Rugsat garaşma wagty gutardy. Birikme düwmesi arkaly gaýtadan synanyşyň.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "Rugsat berlen Core barlanan başlangyjy tamamlap bilmedi. Paketi we ulgam ýazgylaryny barlaň.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core ýa-da Helper bitewilik barlagyndan geçmedi. Doly ReClash paketini gaýtadan guruň.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Ulgam sazlamalary → Umumy → Giriş elementleri we giňeltmeler bölüminde ReClash Helper-e rugsat beriň, soň gaýtadan synanyşyň.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "Gurnalan Helper başga protokoly ulanýar. Başga gurnamany ýa-da hyzmatyň üýtgedilen sazlamalaryny barlap, doly bukjany täzeden guruň.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "Bar bolan Linux Helper bellige alyşyny howpsuz çalşyp bolmaýar. Hyzmatyň eýesini we bellige alyşyny barlaň: gaýtadan ygtyýarlandyrmak bu gapma-garşylygy çözmez.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd TUN Helper-i işe girizip bilmedi. Hyzmatyň žurnalyny barlaň: gurnaýjy öňki gurnamany dikeltmäge synanyşdy.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN üçin systemd tarapyndan dolandyrylýan Linux sessiýasy gerek. Bu ulgam tor Helper-i işe girizip bilmeýär.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN Helper elýeterli däl. Gurnalan paketi we hyzmaty barlaň, soň gaýtadan synanyşyň.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "Öňki rugsat bermek ýa-da Core-i duruzmak entek tamamlanmady. Tamamlanmagyna garaşyň we gaýtadan synanyşyň.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN üçin dogry gol çekilen ReClash programmasy we Helper gerek. Golsuz ýa-da ad-hoc golly ýygynda rugsat berip bolmaýar.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core başlady, emma TUN adapteri taýýar däl. TUN-y ulanmazdan öň Core ýazgysyny barlaň.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Nyşan"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("Nyşanyň GeoIP-i"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Nyşanyň IP ASN-i",
    ),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Üçünji tarap API-e esaslanýar; netijeler diňe salgylanma üçin",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Dörediji usuly"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Dörediji usuly açyk.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Birikme proksisi"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Birikme proksisi NTP serwerine ýetmek üçin ulanylýan çykýandyr.",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("Göni"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP geçirmegi öçürmek",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP geçirmegi öçürilende TUN pingi özi jogap berýär, şonuň üçin ping hakyky gijikmäge gaýdyp gelmeýär.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive-i öçür",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP-ni öçür"),
    "disabled": MessageLookupByLibrary.simpleMessage("Ýapyk"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmeler ýatyrylsynmy?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Jogapkärçilikden el çekmek",
    ),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "Programmany guruňyzda, göçürip alanyňyzda ýa-da ulanyňyzda, şu bildirişiň ählisini okap, razy bolanyňyz hasaplanýar. Onuň islendik şertine razy bolmasaňyz, Programmany ulanmagy derrew bes edip, programmany aýyryň.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("Razýlyk"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "Şu bildirişi okadym we aňladym",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Aňýandygyňyzy tassyklamak üçin aşakdaky bildirişi okap, aşakdaky kutyny belläň:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Bildirişi tassyklaň",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Döredijiler bu bildirişi islendik çykaryş bilen gözden geçirip biler we üýtgeşme şol çykaryş çykanda güýje girýär. Täzelenenden soň Programmany ulanmagy dowam etmek gözden geçirilen bildirişi kabul edýändigiňizi aňladýar.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Şu bildirişiň üýtgeşmeleri",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash-y («Programma») ulanmazdan öň, şu bildirişi diqqet bilen okap, onuň ähli mazmunyny gowy aňlandygyňyzy anyklaň. «Razy» düwmesine basmak bildirişi okadyňyzy, aňlandygyňyzy we aşakdaky ähli şertleri kabul edýändigiňizi aňladýar. Razy bolmasaňyz, «Çyk» düwmesine basyp, Programmany ulanmagy bes ediň.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "Degişli kanunyň rugsat berýän iň uly çäginde, döredijiler hem, islendik goşant goşujy hem Programmany ulanmakdan ýa-da ulana bilmezlikden döreýän islendik göni, bagdysyz, beýni, aýratyn, jezalandyryjy ýa-da yzaralýan zaralar üçin — maglumat ýitgisini, enjam zyýanyny, tor näsazlyklaryny, işiň bölinmegini, ýitirilen peýdany ýa-da anyk hukuk dawalaryny öz içine alýar, emma şeýle zaralaryň mümkinligi barada duýdurylanda hem — jogapkär bolmaýar.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Jogapkärçiligi çäklendirmek",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Programma GPL-3.0 ygtyýarnama esasynda açyk kodlydyr. Şol ygtyýarnamany berjaý etdigiňizdelik, ony erkin ulanyp, üýtgedip we paýlaşyp bilersiňiz; şol ygtyýarnama täze işleri hem GPL-3.0 esasynda çykarmany we asyl awtorlyk duýduryşlaryny saklamany talap edýär.\n\nProgrammadaky üçünji tarap komponentler, şol içindäki Clash.Meta çekirdegi hem, öz ygtyýarnamalaryna eýerýär. Üýtgedilen ýa-da täzeden paýlaşylan wersiýalardan ýüze çykan islendik mesele üçin asyl awtorlar jogapkär däl.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Açyk kodly ygtyýarnama",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Programma özi hiç bir proksi serwerini, düwüni, abunalygy ýa-da tora giriş hyzmatyny hödürlemeýär we şundayar gulluklaryň islendik üpjünçisi bilen ortaçlyk, wekilçilik ýa-da kepillik gatnaşygyna eýe däl.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Programma siziň abunalyk URL-leriňizi, düwün jikme-jiklikleriňizi, konfigurasiýa mazmunyňyzy, barlan saýtlaryňyzy, baglanyşyk ýazgylaryňyzy, trafik mazmunyňyzy ýa-da loglaryňyzy ýygnamaýar hem-de ibermeýär. Bu maglumat enjamyňyzda galýar we döredijileriň oňa girişi ýok.\n\nProgramma diňe zerur bolan aýratynlygy ulananyňyzda tora ýüz tutýar: profil täzelelende siziň berlen abunalyk URL-iňizi almak ýa-da täzelenmeleri barlanyňyzda GitHub-a ýüz tutmak ýaly.\n\nProgramma islendik platformada analitika ýa-da dargamak hasabat gullugyny öz içine almaýar.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Maglumat ýygnamak we gizlinlik",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Soňuna çenli okamak",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Programmany ýaşaýan ýeriňizde ulanmagyň kanuny bolýandygyny anyklamak siziň jogapkärçiligiňiz; ulanyp etýän ähli işleriňiziň we olaryň netijeleriniň hukuk jogapkärçiligi diňe siziň üstüňizde.\n\nImport edýän abunalyklaryňyz, düwünleriňiz we konfigurasiýalaryňyz öz saýlawyňyzdyr. Olaryň çeşmesiniň kanunylygy, mazmunynyň howpsuzlygy we hyzmatynyň ygtybarlygy — siz we olaryň üpjünçileri arasyndaky mesele.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Siziň jogapkärçiligiňiz",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Ýokardaky bildirişi giriziň",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Bildirişe gabat gelmeýär",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Aňýandygyňyzy tassyklamak üçin aşakdaky meýdana şu bildirişi başyny-aşakyna giriziň:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Bildirişi gaýtadan beýan et",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Programma — Clash.Meta (mihomo) çekirdegi esasynda gurlan açyk kodly tor proksi müşderisi. Ol diňe konfigurasiýa dolandyryşy, düzgünlere esaslanan ugurlama we trafik geçirmegi ýaly ýerli gulluklary hödürleýär.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Programmanyň mahiýeti",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Abunalyk salgylary, konfigurasiýa faýllary, düzgünler toplumlary, skriptler, daşarky serişdeler we daşarky salgylaryň ählisi üçünji tarap tarapyndan berlen. Döredijiler olaryň kanunylygyny, dogrulygyny, howpsuzlygyny ýa-da elýeterliligini gözden geçirip bilmeýär hem-de kepillik etmeýär.\n\nÜçünji tarapyň mazmuny sebäpli emele gelýän islendik maglumat sızgysy, maddy ýitgi, hasap ýapylmasy ýa-da başga ýitgi siz we üçünji tarap arasynda çözilýär; döredijiler üçin jogapkärçilik çekmeýär.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Üçünji tarapyň mazmuny",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Programma diňe okuw, çalşyk we tehniki barlag ýaly tijara däl maksatlar üçin niýetlenendir. Ony islendik tijari maksatda ulanmak berk gadagandyr: tölegli paýlaşmak, goşulyp satmak, tijari hyzmatyň bölegi hökmünde ulanmak ýa-da Programmanyň adyndan iş ýöretmek däl-de, olaryň ählisi degişli. Islendik tijari iş Programmany we onuň döredijileri bilen baglanyşyksyzdyr.\n\nProgrammany öz ýurtuňyz ýa-da sebitiňiziň kanunlaryny we düzgünnamalaryny bozýan islendik iş üçin ulanmak berk gadagandyr: kanuny bilen goýulan tor girişiniň çäklendirmelerinden aýlanyp geçmek, kanun dışy mazmuny ýaýratmak, tor hüjümlerini başlamak ýa-da başgalaryň kanuny hukuklaryny bozmak ýaly, emma olar bilen çäklendirilmeýän islendik iş.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Ulanmagyň çäklendirilmeleri",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Programma \"bolşy ýaly\" we \"elýeterli bolşy ýaly\" hödürledilýär: islendik görnüşdäki, açyk ýa-da aňdalmadyk kepillikleriň ýoklugu bilen — satuwdaky harydyň hiline, aýratyn maksatda ýaramlylygyna, başgalaryň hukuklaryny bozmazlygyna, kesilsiz elýeterlilige, ýalňyşlyksyzlyga ýa-da howpsuzlyk näsazlyklarynyň ýoklugyna degişli kepillikleri öz içine almaýar.\n\nDöredijiler Programmanyň zerurlyklaryňyzy kanagatlandyrýandygyny ýa-da kesilsiz ýa-da ýalňyşlyksyz işleýändigini kepillik etmeýär.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Kepillik ýok",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Bagly däl"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Täze wersiýa tapyldy",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "DNS keşi arassalandy",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Bu ýazgy bolmasa, TUN her DNS soragyny 53 porta ele geçirýär (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS-i ele geçirmek"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS usuly"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu ýerde goşulan ýazgylar ähli URL we faýl profilleriniň DNS-ini üstünden ýazýar; goşulmaganlar profiliň öz sazlamasyny ulanýar. Özbaşdak profiller öz DNS-ini öz mazmunynda düzýär.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS soraglary"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Ähli DNS çalyşmalary aýrylýar we saýlanan sebitiň DNS serwerleri täzeden bellenilýär.",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Berkitlen"),
    "domain": MessageLookupByLibrary.simpleMessage("Domen"),
    "done": MessageLookupByLibrary.simpleMessage("Taýýar"),
    "download": MessageLookupByLibrary.simpleMessage("Göçürip al"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Göçürme kuwwaty",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Täzelenme ýüklenýär",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Möhlet"),
    "edit": MessageLookupByLibrary.simpleMessage("Düzet"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("Paneli düzet"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Global düzgünleri düzet",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Tory düzet"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Proksini düzet"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Proksiler toparyny düzet",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Düzgüni düzet"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSID-i düzet"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Redaktor elýeterli däl",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Wagt"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Boş ätiýaçlyk"),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("Iňlis dili"),
    "enabled": MessageLookupByLibrary.simpleMessage("Açyk"),
    "enterManually": MessageLookupByLibrary.simpleMessage("El bilen giriz"),
    "entries": MessageLookupByLibrary.simpleMessage(" ýazgy"),
    "error": MessageLookupByLibrary.simpleMessage("Ýalňyşlyk"),
    "errorDetails": MessageLookupByLibrary.simpleMessage(
      "Ýalňyşlyk jikme-jiklikleri",
    ),
    "es": MessageLookupByLibrary.simpleMessage("Ispan dili"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Soňky tapsyryklardan gizle",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Çykarylan nişan portlary",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Çykarylan nişan portlaryna barýan trafik TUN-dan geçmeýär.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Çykaryş süzgüji"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Çykarylan interfeýsler",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Çykarylan interfeýslerden, docker0 ýaly, gelýän trafik TUN-dan geçýär.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Çykarylan çeşme portlary",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Çykarylan çeşme portlaryndan gelen trafik TUN-dan geçmeýär.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Çykarylan SSID-lar"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Çykarylan SSID-li Wi-Fi-da birikende programmanyň işleýän ýagdaýy awtomatiki çalyşýar.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage(
      "Çykarylan ulanyjy ID-lar",
    ),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Çykarylan ulanyjy ID-laryň proseslerinden gelen trafik TUN-dan geçmeýär.",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("Çyk"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Doly ekrandan çyk"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Çykýan düwünler"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Çaklanýan ýagdaý"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Gutaryş wagty"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Faýly eksport et"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "Hasaba alyşlary eksport et",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Eksport edildi"),
    "extend": MessageLookupByLibrary.simpleMessage("Giňeltme"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Giňeltme usuly"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Giňeltme skripti"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Daşarky dolandyryjy",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Daşarky dolandyryjy çekirdegi 9090 porty arkaly dolandyrmaga mümkin berýär.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Daşarky dolandyryjynyň gizlin açary",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Daşarky salgy"),
    "extra": MessageLookupByLibrary.simpleMessage("Goşmaça"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Örän uly"),
    "fade": MessageLookupByLibrary.simpleMessage("Solma"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filtri"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Fake-IP süzgüç usuly",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP süzgüç usulynda gara sanaw gabat gelýänleri aýyrýar, ak sanaw diňe gabat gelýänlere Fake-IP berýär, düzgün bolsa düzgünlere görä gabat getirýär.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP aralygy"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Fake-IP aralygy (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Ätiýaçlyk filtri"),
    "file": MessageLookupByLibrary.simpleMessage("Faýl"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Faýl üýtgedildi. Üýtgeşmeleri ýatda saklamak isleýärsiňizmi?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Süzgüç"),
    "filters": MessageLookupByLibrary.simpleMessage("Süzgüçler"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Prosesi tap"),
    "floating": MessageLookupByLibrary.simpleMessage("Ýüzýän"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Profile laýyk"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Ulgama görä"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Şrift maşgalasy"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Ölçeg"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "DNS deňeşdirmesini mejbur et",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNS deňeşdirmesini mejbur etmek domeni DNS deňeşdirmesinden alnan baglanyşyklary hem sniffirläýär.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Domenleri mejbur et"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Domenleri mejbur et dizimindäki domenler hem sniffirlenýär; domeni eýýäm bolan beýleki baglanyşyklara duş gelmeýär.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Çekirdegi zorlap täzeden işletmek isleýärsiňizmi?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Fransuz dili"),
    "general": MessageLookupByLibrary.simpleMessage("Umumy"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu ýerde goşulan sazlamalar ähli profilleriň sazlamalaryny çalyşýar. Goşulmadyk sazlamalar profiliň öz bahasyny saklaýar; profilde baha bolmasa, ýadronyň deslapky bahasy ulanylýar.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "GeoIP az ýatly usuly",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Aç"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Göçürip al"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Goşulan düzgünleriň sazlamasyna geç",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Skript sazlamanyna geç",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Minnetdarlyk"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash olaryň zähmeti sebäpli bar",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Tor"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("toparlar"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmeleri keşde saklamak isleýärsiňizmi?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Girýän ulanyjy boýunça hash",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Ýagdaý synagy"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper hyzmaty elýeterli däl; TUN usulyny işledip bolmaýar. Ony dikeltmek üçin ReClash-y täzeden guruň.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Sanawdan gizle"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP-ni gizle"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Paroly gizle"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Wagty çykan proksileri gizle",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Soňky gijikme synagy wagty çykan proksileri goýup geçiň",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Aýlaw aralygy"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostname": MessageLookupByLibrary.simpleMessage("Host ady"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Ählisini arassala"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Ähli gysga ýol düwme utgaşmalary aýrylsynmy?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Kompozitoryň konfigurasiýasy",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Kompozitoryň konfigurasiýasyna faýly birikdirýän setiri hem goşup bilersiňiz. Bu faýllar ReClash utgaşmalary bilen bile täzelenýär we düwmeler ýazga alynýarka wagtlaýyn arassalanýar. Iş stolunyň konfigurasiýasy awtomatik üýtgedilmeýär; utgaşma gapma-garşylyklaryny şol ýerde çözüň.",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global çalt klawişalar penjire gizlenende hem işleýär. Düýme utgaşmasyny ýazmak üçin amala basyň.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Iş stolunyň çalt klawişalary",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Iş stolunyň sazlamalarynda buýrugy ýörite düýme utgaşmasyna belläň. ReClash işleýän bolmaly, ýöne penjiresi gizlin bolup biler. Bu global utgaşmalar iş stolunyň sazlamalarynda dolandyrylýar.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Kompozitoryň konfigurasiýa faýllary elýeterli däl. Ýokardaky iş stoly buýruklaryny ulanyp bilersiňiz.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Bu utgaşmalar programmanyň penjiresi fokusda wagty işleýär. Global çalt klawişalar üçin aşakdaky bölümde iş stoly buýruklaryny sazlaň.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Çalt klawişalar"),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Bellenmedik"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Deslapkylary dikelt",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Ähli utgaşmalar deslapkylar bilen çalşyrylsynmy?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "Howpsuz tertip gysga ýol hereketlerini öçürýär, emma utgaşmalary üýtgedip bolýar.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Hasaba alynmady, ony başga programma eýelän bolmagy mümkin",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("sagat"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("Ton"),
    "icon": MessageLookupByLibrary.simpleMessage("Nyşan"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Nyşan ýazgylary"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Nyşan toplumlary"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Heniz nyşan toplumy ýok. Özbaşdak profil serişdeleri → Nyşan toplumlary bölüminden goşuň",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Nyşan stili"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Doly"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Gizlen"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Adaty"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Nyşanyň URL-y"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Batareýa optimizasiýasyndan çykar",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Bu faýl import edip bilýan konfigurasiýa däl",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Import ediş şu profiliň häzirki proksi toparlaryny, düzgünlerini we sazlamalaryny üstünden ýazýar",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Faýldan import"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("Salgydan import"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL-dan import"),
    "inbound": MessageLookupByLibrary.simpleMessage("Girýän"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Içerilen interfeýsler",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe içerilen interfeýslerden gelýän trafik TUN arkaly geçýär, çykarylan interfeýsler bolsa hasaplanmaýar.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage(
      "Içerilen ulanyjy ID-lar",
    ),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe içerilen ulanyjy ID-laryň proseslerinden gelen trafik TUN arkaly geçýär.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Hiç wagt gutarmaýar"),
    "init": MessageLookupByLibrary.simpleMessage("Başlangyçlaşdyrma"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Işe giriş şowsuz"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash işe girizende ýalňyşlyga duçar boldy we dowam edip bilmeýär. Mesele barada habar bermek üçin jikme-jiklikleri göçürip alyň. Mesele gaýtalansa, maglumatlary arassalamak programmany derrew başlamagyny üpjün edýär.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Başladyjy"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("Başladyjy"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Proksiler toparynyň adyny giriziň",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Düzgüniň mazmunyny giriziň",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage(
      "Täzelenmäni gurnamak",
    ),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "Programma sanawy rugsaty ret edildi, şonuň üçin gurnalýan programmalary görkezip bolmaýar. Ony ulgam sazlamalarynda el bilen beriň.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Bu ulgam rugsat berilmese, gurnalýan programmalaryň sanawyny gizleýär. Rugsat beriň, şonda her programma üçin wekil sazlap bilersiňiz.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Programma sanawy rugsaty gerek",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("Gurulan şriftler"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Akylly saýlaw",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interfeýsiň ady"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Interfeýs ady — çykýan baglanyşyklar ulanýan tor interfeýsidir.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Çykýan interfeýs",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Arassala"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Özbaşdak"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýa laýyk",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Aralyk"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Içki tor IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Nädogry nusga faýly",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "CIDR görnüşinde IP aralygyny giriziň, mysal üçin 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP belgisi 63-den geçmeli däl",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Domen ýa-da IP salgysyny giriziň",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Dogry nyşan toplumy däl",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Abunalyk salgysy hem, proksi paýlaşma salgysy hem däl",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053 ýaly salgy we porty giriziň",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Diňe tcp ýa-da udp goldanýar",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 ýa-da 8000-9000 ýaly porty ýa-da aralygy giriziň",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Bu QR kodda profil salgysy ýok",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 ýa-da 8000-9000 ýaly sanlary ýa-da aralyklary / bilen aýryp giriziň",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID 32 UTF-8 baýtdan uzyn bolup bilmez",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP salgy"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Hyýanatçylyk taryhy"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proksi"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Bellikler"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Gurama"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP görnüşini kesgitläp bolmady",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Gowy"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Dereje"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Adaty"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Ýene barla"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Töwekgelçilikli"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Hili"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Jogap beren"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Çeşmeler"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Başga çykyş IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Görnüş ýok"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("Sorag çägi"),
    "ipType": MessageLookupByLibrary.simpleMessage("Görnüş"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Korporatiw"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Maglumat merkezi"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Mobil tor"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Öý ulanyjy"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Näbelli görnüş"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP wersýasy"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 açyk bolanda diňe IPv6 trafigi kabul edilýär.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6 açyk bolanda VPN IPv6 girişine rugsat berýär.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "IPv6 gözlama möhleti (ms)",
    ),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("Ýapon dili"),
    "justNow": MessageLookupByLibrary.simpleMessage("Häzir"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive bos wagty",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive wagt aralygy",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Açar"),
    "kk": MessageLookupByLibrary.simpleMessage("Gazakça"),
    "ko": MessageLookupByLibrary.simpleMessage("Koreýçe"),
    "label": MessageLookupByLibrary.simpleMessage("Bellik"),
    "language": MessageLookupByLibrary.simpleMessage("Dil"),
    "large": MessageLookupByLibrary.simpleMessage("Uly"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Soňky täzelenme"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Açylyş tamamlanmadygy anyklandy",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "Programma geçen gezek açylanda garaşylmadyk halatda ýapyldy. Şu açylyşda awtomatiki düzüm ýerine ýetirilmedi; gaýtadan synamak üçin ony el bilen başlap bilersiňiz.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Dizilim"),
    "license": MessageLookupByLibrary.simpleMessage("Ygtyýarnama"),
    "licenses": MessageLookupByLibrary.simpleMessage("Ygtyýarnamalar"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Programmä goşulan paketler",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Ýagty"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Setirleri geçirmek"),
    "link": MessageLookupByLibrary.simpleMessage("Salgy"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Suwly aýna"),
    "list": MessageLookupByLibrary.simpleMessage("Sanaw"),
    "listen": MessageLookupByLibrary.simpleMessage("Diňleýiş"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Diňleýiş ugurlama belgisi",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Diňleýiş ugurlama belgisi diňe Linux-da işleýär.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Janly baglanyşyklar",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Ýüklenýär…"),
    "local": MessageLookupByLibrary.simpleMessage("Ýerli"),
    "localImage": MessageLookupByLibrary.simpleMessage("Ýerli surat"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Ýerli tor rugsady ret edildi: gvisor stegini ulanýar, LAN-a ýetip bolmaýar.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Ýerli proksiler"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("Ýer rugsaty"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Ýer rugsaty ret edildi, şonuň üçin häzirki Wi-Fi adyny okap bolmaýar. Ýer rugsatyny ulgam sazlamalarynda el bilen beriň.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Ulgam Wi-Fi adyny okamak üçin ýer rugsaty gerek. Android-de \"Ähli wagt rugsat ber\" wariantyny saýlaň, ýogsam programma fonda işleýände Wi-Fi adyny okap bolmaýar.",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Ýerleşýän ýer rugsaty gerek",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Hasaba alyş"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Hasaba alyşyň derejesi"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Logcat öçürilende hasaba alyşyň girişi gizlenýär.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Hasaba alyş"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Hasaba alyş we diagnostika",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Hasaba alyş synagy"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback aýrylmasy"),
    "loose": MessageLookupByLibrary.simpleMessage("Giň"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Meýnteýner"),
    "matchCase": MessageLookupByLibrary.simpleMessage(
      "Registr tapawudyny sakla",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Çeşme IP-ni gabat getir",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Iň köp şowsuzlyk sany",
    ),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("Ulalt"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("Rezident ýat"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage(
      "Programma we umumy",
    ),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Boş heap"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage(
      "Ulanylýan heap",
    ),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Çekirdek işlemeýär",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Işleýiş çykdajylary",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Gorutin stekleri"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Prosesiň rezident ýadyndan çaklanýar; ulgamyň habar berýäninden tapawutlanyp biler.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Çekirdek programmanyň prosesiniň içinde işleýär. Onuň paýy işleýiş statistikasyndan çaklanýar, galanysy programma we umumy ýat hökmünde hasaplanýar.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Ýat maglumaty"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Programmanyň we çekirdegiň ulanýan ýady",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Ýat boşadyldy"),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("Habar synagy"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Bu bir habar."),
    "minimize": MessageLookupByLibrary.simpleMessage("Kiçelt"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Çykanda kiçeltmek"),
    "minutes": MessageLookupByLibrary.simpleMessage("minutlar"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Garyşyk port"),
    "mode": MessageLookupByLibrary.simpleMessage("Usul"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Bir reňkli nyşan"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Birreňk"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("Giňişleýin"),
    "name": MessageLookupByLibrary.simpleMessage("Ad"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Aşaky panel"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("Tab etiketleri"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Hemişe"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Hiç haçan"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage(
      "Saýlanan",
    ),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Nawigasiýa"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Bellikler paneli",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Gapdal panel",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Tor"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Haýyş ýatyryldy",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Serwere birigip bolmady. Tor baglanyşygyny ýa-da proksi sazlamalaryny barlaň",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (öý Wi-Fi) ýa-da tor segmenti (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Serwer salgysyny çözülmedi. URL-iň dogrulygyny we DNS-iň işleýändigini barlaň",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Tor ady"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Haýyşlar köp (HTTP 429). Azajyk garaşyp, gaýtadan synanyşyň",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Aýlanyp geçiş sanawy we TUN MTU saýlanan sebitiň deslapky bahalaryna gaýdýar.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Tor açary"),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Tor tizligi"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Trafigi ele geçirmek",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Soragyň möhleti gutardy. Toryňyzy ýa-da proksiňizi barlap, gaýtadan synanyşyň",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Howpsuz birikme şowsuz boldy. Serweriň şaýatnamasy nädogry bolup biler ýa-da birikme ele alynýar",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Toryň görnüşi"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Indiki gabat gelme"),
    "no": MessageLookupByLibrary.simpleMessage("Ýok"),
    "noData": MessageLookupByLibrary.simpleMessage("Maglumat ýok"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Maglumat ýok"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Indiden soň ýatlatma",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Tor ýok"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Torsuz programmalar"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP-i çözme"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Host adyny çözme",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Gabat gelýän netije tapylmady",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Düwünler"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Bu daşarky serişde tekst faýly däl",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Hiç biri"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Işlemeýär"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Häzirki proksi toparyny saýlap bolmaýar",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Häzirki tor ynamly däl",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Duýduryş"),
    "notificationActive": MessageLookupByLibrary.simpleMessage("Gorag işjeň"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Komponent goş",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki topar",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Serwer topary kesgitlenmedik, şonuň üçin bu setir görkezilmeýär",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Duýduryş komponentleri",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Duýduryşy göni ýagdaý komponentlerinden düzüň.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Komponent goşulmady",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Komponentler bolmasa, bildiriş diňe goragyň ýagdaýyny görkezýär.",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Mazmun"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Häzirki serwer",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android duýduryşynyň eltilmegi",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android duýduryş rugsady barlanýar",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "ReClash duýduryşlary petiklenendir",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Duýduryşlary eltmek bolýar",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash hyzmat kanaly öçürilendir",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Ýazylma ýatlatmalary kanaly öçürilendir",
        ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Boş wagty tizligi gizlemek",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Gulp ekranynda gizlin maglumatlary gizlemek",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Hyzmat duýduryşlary we ýatlatmalar Android-iň gulp ekranynyň gizlinlik sazlamalaryna eýerýär. Gulp açylanda jikme-jiklikler görünýär.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Jikme-jik tertip janly maglumatlary we duruzmak düwmesini görkezýär. Iň az tertip diňe gorag ýagdaýyny görkezýär.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Tor tizligi",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Gizlinlik"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Ýatlatmalar",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "Saýlanan topar profilde ýok",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Hyzmat kanaly",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Sessiýa trafigi",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Ýazylma ýatlatmalary kanaly",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Ýazylma ýatlatmalary",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Ýazylma üns talap edende habar bermek",
        ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Duýduryş derejesi",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Jikme-jik",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Minimal",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Sinhronlaşdyrma aralygy (minut)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP ulgamyň sagadyň deregine NTP serwerinden wagt alýar.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Häzirçe profil ýok, ilki bilen bir profil goşuň",
    ),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfs"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfs hosty"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfs usuly"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfs parametri"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Obfs paroly"),
    "onDemand": MessageLookupByLibrary.simpleMessage("Gerek bolanda"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Bu kiçi tor giň tor aralygyna ynanýar",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyklary ýap",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Gerek bolanda çykarylan Wi-Fi-ýa proksini wagtlaýyn bes edýär.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("Doly bes etmek"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Säginilende TUN aýrylýar we ýerli proksi portlary ýapylýar. Awtomatik dowam etmek üçin tor gözegçiligi dowam edýär.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Säginmek"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Dowam etmek"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi torlaryny okap bolmady. Gaýtadan synanyşyň ýa-da el bilen giriziň.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "SSID we tor segmentini bilelikde talap et",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Iki görnüşli düzgün bar bolsa, diňe SSID we tor segmenti gabat gelse bes et",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Diňe proksi trafikini hasaba al",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Hökmany däl"),
    "options": MessageLookupByLibrary.simpleMessage("Wariantlar"),
    "other": MessageLookupByLibrary.simpleMessage("Beýleki"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Beýleki goşant goşanlar",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Çykýan"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Çykyş"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Çykyş IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Çykyş usuly"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Nyşany ýazyp geçirmek",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Nyşany ýazyp geçirmek asyl salgynyň deregine sniffirlän domene biriger.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("Ýazyp geçirmeler"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Pak IP-i çözmek"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Pak IP-i çözmek diňe IP salgysy bolan baglanyşyklary sniffirläýär.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Parol"),
    "paste": MessageLookupByLibrary.simpleMessage("Goý"),
    "peers": MessageLookupByLibrary.simpleMessage("Pirler"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Galereýadan saýla"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Tor saýla"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Golaýdaky Wi-Fi torlary",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi tor tapylmady",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Golaýdaky Wi-Fi torlary görkezmek üçin ýer rugsaty gerek",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Golaýdaky Wi-Fi torlaryny görmek üçin ýerleşişe rugsat beriň ýa-da tory el bilen giriziň.",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Täzele"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Golaýdaky Wi-Fi torlary gözlenýär…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Penjireni berkitle"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Ilki WebDAV-y baglaň",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Skriptiň adyny giriziň",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Dogry QR kod ýükläň",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage(
      "Plaginiň şifrleme algoritmi",
    ),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plugin hosty"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plugin usuly"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("Plaginiň paroly"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Plaginiň ýoly"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Plaginiň ulanyjy ady",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Başga port giriziň",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port aýlaw"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("Portlar"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Pre-shared açar"),
    "preferred": MessageLookupByLibrary.simpleMessage("Ileri tutulýan"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Öň şertler"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Çykmak üçin yza ýene bir gezek basyň",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Bir düwme utgaşmasyna basyň",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Abunalaryň gaýtalanmagynyň öňüni al",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Bar bolan profiliň ulanýan abuna salgysyny ret et",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Deslapky görnüş"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Öňki gabat gelme"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Hususy açar"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Hususy açar paroly",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Proses"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Dogry aralyk giriziň"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Awtomatiki täzelenme aralygyny giriziň",
        ),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Profil üýtgedildi. Awtomatiki täzelenmäni öçürmek isleýärsiňizmi?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Abuna sahypasy ýüklenýär…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "Abuna ýüklenýär…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Bu abuna URL-li profil eýýäm bar",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "Abunalyk şifrlenen; açar goşulanda soralar.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage(
      "Möhleti geçdi",
    ),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Abunalygyň formaty",
    ),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash üçin iň gowy format, awtomatik saýlanýar",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijiden",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Käbir bölekler goldanmaýar; goşmazdan öň olary görkezeris.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Abuna sahypasyny ýükläp bolmady. Ony şonda-da goşup bilersiňiz.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Serwerler"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Bir serwer",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage("Täze abunalyk"),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "Hiç zat goşulmady. Başga format saýlap, täzeden synanyşyp bilersiňiz.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Çäksiz"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage("Möhleti"),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Profil adyny giriziň",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe şu profile degişli; goşulmaganlar öz başlagyç bahasyny ulanýar.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe şu profile degişli we tor sazlamalaryndaky TUN üstünden geçiriş ýazgylaryndan ön göstärýär.",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Dogry profil URL-yny giriziň",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Profil URL-yny giriziň",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiller"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Profilleri tertiple"),
    "project": MessageLookupByLibrary.simpleMessage("Proýekt"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protokol"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Protokol parametri"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage(
      "Protokol wersýasy",
    ),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("Bildiriş"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin",
    ),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("Oka"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Bildiriş"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijiden",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijä gaýtar",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Sazlamalary üpjün edijä gaýtar",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Üýtgeden sazlamalaryňyz ýene abuna eýerer",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Diňe uzak üpjün edijiler goldanýar",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Daşarky çeşmeler"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proksiler"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proksi zynjyry"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proksi topary"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proksiler topary boş",
    ),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Çekirdek başlananyndan soň toparlar şu ýerde peýda bolýar",
    ),
    "proxyGroupsCount": m78,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Proksi üpjün edijiler",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proksiniň görnüşi"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Keşi arassala"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Açyk açar"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Doly gara"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Doly gara usuly"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR kod"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Profil almak üçin QR kody skanerläň",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Bu baglanyşyk QR kody üçin aşa uzyn. Onuň ýerine baglanyşygy göçüriň.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Çalt hereketler"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Çalt redaktirlemek"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Topar goş"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("Tor görnüşini goş"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Nusga goşmak"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Teg goş"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Goşmaça"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Bu bölekler YAML arkaly üýtgedilýär.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Ähli toparlar"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Islendik"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage(
      "Awtomatik dolandyryş",
    ),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Senarri tutuş birikmäni dolandyrýar: her tor görnüşindäki režimi we her toparyň näme edýändigini. Ol adyny tutmaýan toparlar öz profili boýunça işleýär.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("Awtomatika gaýtmak"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Deňagramly"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Esasy"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Hereket"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmeleri geçir",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Öz üýtgeşmeleriňiz şol bolşuna galýar",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("Serweri çalyşmak"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Çalyşmak"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Barlag"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Topar boýunça"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("Serwer tapylmazdy"),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage(
      "petiklenenleri açýar",
    ),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Barlaglar"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Elýeterlilik barlaglary",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Şert goş"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Ähli şertler"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Hemişe"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Islendik şert"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("Islendik serwer"),
    "rcxCondAtLeast": MessageLookupByLibrary.simpleMessage("az däl"),
    "rcxCondAtMost": MessageLookupByLibrary.simpleMessage("köp däl"),
    "rcxCondClause": m82,
    "rcxCondCountry": MessageLookupByLibrary.simpleMessage("Ýurt"),
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Meýdan"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Harp ýagdaýyny hasaba almaz",
    ),
    "rcxCondLess": MessageLookupByLibrary.simpleMessage("az"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Gabat gelme"),
    "rcxCondMore": MessageLookupByLibrary.simpleMessage("köp"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Görkezilmedik"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("däl"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Operator"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Nusga"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("Tekst hökmünde"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Bu şertde içme-iç toparlar bar, şonuň üçin tekst hökmünde üýtgedilýär.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Baha"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Bahalar otur bilen aýrylýar",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Rugsat ber"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Rugsat bermeseňiz, topar «Ýönekeý» profili bilen işleýär. Saýtlara diňe serwerleriňiz arkaly ýa-da tory barlamak üçin birigilýär.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("Rugsat gerek"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Birigýän saýtlary"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Üçünji tarap saýtlary ne üpjünçiňize, ne-de içerki profillere degişli.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Dolandyryş"),
    "rcxCountryAll": MessageLookupByLibrary.simpleMessage("Ähli ýurtlar"),
    "rcxCountryOnServers": MessageLookupByLibrary.simpleMessage(
      "Serwerleriňizde",
    ),
    "rcxCountryPickMany": MessageLookupByLibrary.simpleMessage(
      "Ýurtlary saýlaň",
    ),
    "rcxCountryPickOne": MessageLookupByLibrary.simpleMessage("Ýurdy saýlaň"),
    "rcxCountryServers": m84,
    "rcxCountryVerified": MessageLookupByLibrary.simpleMessage("barlanan"),
    "rcxDeleteProfile": m85,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage("Tor diagnostikasy"),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Göni saýtlar şu topar arkaly",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage("Häzir açyk"),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Düzgünleriň göni iberýän saýtlary açylmasa, olar şu topar arkaly geçer. Ýerli salgylar hemişe göni galýar.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "Garaşýar: göni saýtlar entek açylýar",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage(
      "Nusgasyny alyp üýtget",
    ),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Tygşytly"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Takyk"),
    "rcxEnergyToday": m86,
    "rcxExcept": m87,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Profil tarapyndan aýryldy",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "«Serweri çalyşmak» soň geçirildi",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage("Sanawda ýok"),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Hiç bir islege gabat gelmeýär",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Entek barlanmadyk",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage("Serwer däl"),
    "rcxExit": m88,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage("Çykyş ýurdy barlagy"),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Eksport"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Seýrek"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Ýygy"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Işleýär"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("Ulanylýar"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Işlemeýär"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Tor diagnostikasy"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Giriş ýurdy"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Çykyş ýurdy"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage("Barlagdan geçmeýär"),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Tor görnüşi"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Gijikme, ms"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Ölçenen"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("Çäkli tor"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Ady"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("Barlagdan geçýär"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Giriş sahypasy"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Üpjünçi"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("Serwer salgysy"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Teg"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyk görnüşi",
    ),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Protokol"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("UDP goldaýar"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Tutuş topar serwer gözlemezden şu element arkaly geçýär; hemmesini tabşyrmak üçin ýük deňleýjini ýa-da içindäki topary saýlaň.",
    ),
    "rcxFixedOn": m89,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("Umumy"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage(
      "Topar profilleri",
    ),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Akylly toparyň serweri nähili saýlaýandygy. Öz profiliňizi üýtgetmek üçin, başgasynyň nusgasyny üýtgetmek üçin basyň.",
    ),
    "rcxGroupSettings": MessageLookupByLibrary.simpleMessage(
      "Toparyň sazlamalary",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Işleýär"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Işlemeýär"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("Öň işleýärdi"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Barlanmadyk"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("Taryh"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Öňki wersiýalar",
    ),
    "rcxHubAuto": MessageLookupByLibrary.simpleMessage("Awtomatik ugrukdyrma"),
    "rcxHubBundle": MessageLookupByLibrary.simpleMessage("Bu faýlda"),
    "rcxHubChange": MessageLookupByLibrary.simpleMessage("Üýtget"),
    "rcxHubCopyConfirm": MessageLookupByLibrary.simpleMessage("Nusga döret"),
    "rcxHubCopyMessage": m90,
    "rcxHubCopyTitle": MessageLookupByLibrary.simpleMessage(
      "Öz nusgaňyzy döretmelimi?",
    ),
    "rcxHubDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Bu ssenariý näme edýär",
    ),
    "rcxHubEverythingElse": MessageLookupByLibrary.simpleMessage(
      "Galan trafik",
    ),
    "rcxHubEverythingElseHint": MessageLookupByLibrary.simpleMessage(
      "Hiç bir ugra gabat gelmedik trafik abunanyň esasy topary arkaly gidýär.",
    ),
    "rcxHubGroupsEmpty": MessageLookupByLibrary.simpleMessage(
      "Häzirlikçe hiç bir topary awtomatik ugrukdyrma dolandyrmaýar.",
    ),
    "rcxHubLibrary": MessageLookupByLibrary.simpleMessage("Kitaphana"),
    "rcxHubNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Awtomatik ugrukdyrmany görmek üçin birikmäni başlady",
    ),
    "rcxHubNetworks": MessageLookupByLibrary.simpleMessage("Torlar"),
    "rcxHubNetworksTitle": MessageLookupByLibrary.simpleMessage(
      "Tertip we torlar",
    ),
    "rcxHubNoProfile": MessageLookupByLibrary.simpleMessage("Abuna ýok"),
    "rcxHubNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Ilki abuna goşuň: awtomatik ugrukdyrma onuň toparlary bilen işleýär.",
    ),
    "rcxHubOffHint": MessageLookupByLibrary.simpleMessage(
      "Açsaňyz, ssenariý toparlaryňyz we ugurlaryňyz üçin serwer saýlar.",
    ),
    "rcxHubOtherGroups": MessageLookupByLibrary.simpleMessage(
      "Beýleki toparlar",
    ),
    "rcxHubOtherGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Bu ssenariýiň hem dolandyrýan abuna toparlary.",
    ),
    "rcxHubOverview": MessageLookupByLibrary.simpleMessage("Umumy"),
    "rcxHubRoutes": MessageLookupByLibrary.simpleMessage("Ugurlar"),
    "rcxHubRoutesHint": MessageLookupByLibrary.simpleMessage(
      "Trafik ýokardan aşak ilkinji gabat gelýän ugur bilen gidýär.",
    ),
    "rcxHubRoutesOff": MessageLookupByLibrary.simpleMessage(
      "Işleýän ssenariý ýok",
    ),
    "rcxHubRoutesOffHint": MessageLookupByLibrary.simpleMessage(
      "Ugurlar saýlanan trafigi, meselem bir hyzmaty, öz serwerleri arkaly iberýär.",
    ),
    "rcxHubRoutesRuleOnly": m91,
    "rcxHubStartScenario": MessageLookupByLibrary.simpleMessage(
      "Ssenariý döret",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Meniň profillerime goş",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Bu profili barlamak üçin programmanyň ýadrosyny işlediň.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Ugurlama profilini import et",
    ),
    "rcxImported": m92,
    "rcxJournalFailure": m93,
    "rcxJournalMode": m94,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("barlanýar"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Bu torda olar senarideki şol bir atly toparlary çalyşýar; galanlary ähli torlardaky ýaly işleýär.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Ady"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Kiçi latyn harplary, sanlar we defisler, 24 belgä çenli",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("açyk internet"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("giriş sahypasy"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Şu wagt tanalýar"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Görnüşler ýokardan aşaklygyna barlanýar; tor ilkinji gabat gelenini alýar.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage(
      "diňe ak sanawlar",
    ),
    "rcxLadderAdd": MessageLookupByLibrary.simpleMessage("Ädim goş"),
    "rcxLadderAdvanced": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin şert…",
    ),
    "rcxLadderAnyWorking": MessageLookupByLibrary.simpleMessage(
      "Islendik işleýän serwer",
    ),
    "rcxLadderCountry": MessageLookupByLibrary.simpleMessage("Ýurt"),
    "rcxLadderEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Käbir serwerleri öňe goýmak üçin ädim goşuň",
    ),
    "rcxLadderExceptCountries": MessageLookupByLibrary.simpleMessage(
      "Bu ýurtlardan başgasy",
    ),
    "rcxLadderFallThrough": MessageLookupByLibrary.simpleMessage(
      "hiç biri işlemese",
    ),
    "rcxLadderFits": m95,
    "rcxLadderGroupHint": MessageLookupByLibrary.simpleMessage(
      "Bu tertip diňe şu topar üçin. Profiliň tertibine eýermek üçin boş goýuň.",
    ),
    "rcxLadderInherited": MessageLookupByLibrary.simpleMessage(
      "Hereketden alnan — öz tertibiňizi düzmek üçin ädimi üýtgediň",
    ),
    "rcxLadderLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Iň soňky çäre ädiminiň serwerleri diňe beýleki hiç bir ädimde, hatda aşakdakyda-da, işleýän serwer bolmasa ulanylýar.",
    ),
    "rcxLadderLatency": m96,
    "rcxLadderLatencyUnder": MessageLookupByLibrary.simpleMessage(
      "Gijikme çägi, ms",
    ),
    "rcxLadderNameContains": MessageLookupByLibrary.simpleMessage("Adynda bar"),
    "rcxLadderNameHas": m97,
    "rcxLadderNot": m98,
    "rcxLadderOther": MessageLookupByLibrary.simpleMessage("Beýleki şertler"),
    "rcxLadderProvider": m99,
    "rcxLadderScenarioFirst": MessageLookupByLibrary.simpleMessage(
      "Häzir bu topary ssenariý dolandyrýar: ssenariýniň berýän serwer tertibi bu tertipden öňde durýar.",
    ),
    "rcxLadderServersIn": MessageLookupByLibrary.simpleMessage(
      "Bu ädimdäki serwerler",
    ),
    "rcxLadderStep": m100,
    "rcxLadderStranded": m101,
    "rcxLadderTag": m102,
    "rcxLadderTitle": MessageLookupByLibrary.simpleMessage(
      "Serwerleriň tertibi",
    ),
    "rcxLadderUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Iň soňky çäre"),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Derejesi"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Giňişleýin"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Ýönekeý"),
    "rcxLine": m103,
    "rcxLintCheckUnused": m104,
    "rcxLintConsent": m105,
    "rcxLintGroupMissing": m106,
    "rcxLintPoolEmpty": m107,
    "rcxLintTagUnused": m108,
    "rcxLintTierEmpty": m109,
    "rcxLintTierUnreachable": m110,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Esasy topar"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Awtomatik ugry açmak",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash bu toparda işleýän serweri saklaýar we ol işlemesini bes etse çalşýar. Barlaglar diňe tory ulanýan wagtyňyz geçirilýär.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Profiller we senariler «Giňişleýin sazlamalar» → «Awtomatik ugur» bölüminde döredilýär we üýtgedilýär.",
    ),
    "rcxMatchAdd": MessageLookupByLibrary.simpleMessage("Ýazgy goş"),
    "rcxMatchCidr": MessageLookupByLibrary.simpleMessage("IP aralygy"),
    "rcxMatchCustom": MessageLookupByLibrary.simpleMessage("Öz düzgünler"),
    "rcxMatchDomain": MessageLookupByLibrary.simpleMessage("Domen"),
    "rcxMatchGeoip": MessageLookupByLibrary.simpleMessage("IP kategoriýasy"),
    "rcxMatchGeosite": MessageLookupByLibrary.simpleMessage(
      "Saýt kategoriýasy",
    ),
    "rcxMatchHint": MessageLookupByLibrary.simpleMessage(
      "Bu ugruň hem alýan domenleri, IP aralyklary, programmalary ýa-da düzgün toplumlary.",
    ),
    "rcxMatchInvalid": MessageLookupByLibrary.simpleMessage("Nädogry baha"),
    "rcxMatchKeyword": MessageLookupByLibrary.simpleMessage(
      "Domendäki açar söz",
    ),
    "rcxMatchMore": m111,
    "rcxMatchNext": MessageLookupByLibrary.simpleMessage("Indiki"),
    "rcxMatchNoResolve": MessageLookupByLibrary.simpleMessage(
      "Domenleri çözmezlik",
    ),
    "rcxMatchNone": MessageLookupByLibrary.simpleMessage("Trafik saýlanmady"),
    "rcxMatchPickHint": MessageLookupByLibrary.simpleMessage(
      "Bu ugruň alýan hyzmatlaryny saýlaň; öz ýazgylaryňyzy hem goşup bilersiňiz.",
    ),
    "rcxMatchProcess": MessageLookupByLibrary.simpleMessage("Programma"),
    "rcxMatchRuleSet": MessageLookupByLibrary.simpleMessage("Düzgün toplumy"),
    "rcxMatchServices": MessageLookupByLibrary.simpleMessage("Hyzmatlar"),
    "rcxMatchSuffix": MessageLookupByLibrary.simpleMessage(
      "Domen we subdomenler",
    ),
    "rcxMatchType": MessageLookupByLibrary.simpleMessage("Görnüşi"),
    "rcxMatchTypeHint": MessageLookupByLibrary.simpleMessage(
      "Domen goşulmasy ähli subdomenleri hem öz içine alýar.",
    ),
    "rcxMatchValue": MessageLookupByLibrary.simpleMessage("Bahasy"),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmeleri geçirip bolmady",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Üýtgeşmeler geçirildi"),
    "rcxMergedConflicts": m112,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Awto"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Serwerleriň tertibi boýunça iň gowy işleýän serweri saýlaýar we ol işlemän galanda çalşýar.",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Režimi senarä gaýtar",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "Bu torda režimi senari kesgitleýär",
    ),
    "rcxModeIs": m113,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("Üýtgetme"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("El bilen"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Serweri proksi sanawynda özüňiz saýlaýarsyňyz; awtomatik ugur ony hiç haçan çalşmaýar.",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Režimi özüňiz saýladyňyz; senari siz «Awto» saýlaýança garaşýar",
    ),
    "rcxModePinnedHint": m114,
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "Bu torda režim siziňki",
    ),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Siziň rugsadyňyz gerek",
    ),
    "rcxNetwork": m115,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Tor görnüşleri"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Täze profil"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Täze senari"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("Bu torda"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("geçmeýär"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("şulardan biri"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("deňdir"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("deň däl"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("gabat gelýär"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("üstünlikli geçýär"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage(
      "Tor boýunça üýtgeşmeler",
    ),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage("Toparyň öz profili"),
    "rcxOwnProfileHint": MessageLookupByLibrary.simpleMessage(
      "Topar öz sazlamalaryndaky hereketini saklaýar.",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "Nusga dogry regulýar aňlatma däl",
    ),
    "rcxPendingTier": m116,
    "rcxPinned": m117,
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Berkidilen"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Çykar"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Ulan"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Toparda serwer ýok",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "Häzirki sazlamada bu topar saýlaýjy däl",
    ),
    "rcxProblemProfileInvalid": m118,
    "rcxProblemProfileMissing": m119,
    "rcxProblemStoreFailed": m120,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "rcxProfileDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Bu profil näme edýär",
    ),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Ady"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "Topar pulyň saklaýan serwerleriniň arasyndan şu profil boýunça serwer saýlaýar.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Hereket"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Bir elemente tabşyr",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Element"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Serwer saýla"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage("Bu iň gowy serwer"),
    "rcxReasonBetterTier": m121,
    "rcxReasonChangeServer": m122,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Has gowy dalaşgär barlanýar",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Has çalt serwere ýene bir ölçeg gerek",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Ýakynda çalşyldy; indikisinden öň garaşýar",
    ),
    "rcxReasonFailover": m123,
    "rcxReasonFaster": m124,
    "rcxReasonFixed": m125,
    "rcxReasonFixedMissing": m126,
    "rcxReasonFlapLimit": m127,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Berkidilen serwer saklanýar",
    ),
    "rcxReasonIdle": m128,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Elýeterli iň gowy serwer saýlandy",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage(
      "El bilen dolandyrylýar",
    ),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Tor üýtgedi",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "Tor işlemeýän ýaly; serwerler günäkär edilmeýär",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "Çalyşmak üçin başga işleýän serwer ýok",
    ),
    "rcxReasonOutOfPool": m129,
    "rcxReasonPaused": m130,
    "rcxReasonRouteInvalid": m131,
    "rcxReasonRouteNameTaken": m132,
    "rcxReasonRouteToMissing": m133,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Serweri saýlap bolmady",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Göni saýtlar ýene göni geçýär",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Göni saýtlar indi şu topar arkaly geçýär",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Işleýän serwer ýok; häzirkisi saklanýar",
    ),
    "rcxReasonSwitchFixed": m134,
    "rcxReasonSwitchPinned": m135,
    "rcxReasonSwitchStranded": m136,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Işleýär; näsazlyga çenli saklanýar",
    ),
    "rcxRouteAdd": MessageLookupByLibrary.simpleMessage("Ugur goş"),
    "rcxRouteChoose": MessageLookupByLibrary.simpleMessage("Saýla"),
    "rcxRouteEdit": MessageLookupByLibrary.simpleMessage("Ugry üýtgetmek"),
    "rcxRouteGroup": MessageLookupByLibrary.simpleMessage(
      "Ugur tarapyndan döredildi",
    ),
    "rcxRouteGroupHint": m137,
    "rcxRouteName": MessageLookupByLibrary.simpleMessage("Ady"),
    "rcxRouteNameLong": MessageLookupByLibrary.simpleMessage("Ady gaty uzyn"),
    "rcxRouteNameReserved": MessageLookupByLibrary.simpleMessage(
      "Bu at eýýäm bellenen",
    ),
    "rcxRouteNew": MessageLookupByLibrary.simpleMessage("Täze ugur"),
    "rcxRouteSend": MessageLookupByLibrary.simpleMessage("Iberiş ýoly"),
    "rcxRouteSendAutoHint": MessageLookupByLibrary.simpleMessage(
      "Ugruň öz topary aşakdaky tertipde iň gowy serweri saýlaýar.",
    ),
    "rcxRouteSendDirectHint": MessageLookupByLibrary.simpleMessage(
      "Bu trafik proksiden geçmeýär.",
    ),
    "rcxRouteSendFixed": MessageLookupByLibrary.simpleMessage("Bir serwer"),
    "rcxRouteSendFixedHint": MessageLookupByLibrary.simpleMessage(
      "Bu trafik hemişe saýlanan serwer ýa-da topar arkaly gidýär.",
    ),
    "rcxRouteTarget": MessageLookupByLibrary.simpleMessage("Serwer"),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Senari"),
    "rcxScenarioDrives": m138,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Toparlar"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Esasy topar — soňky düzgüniň trafigi iberýän topary; «Ähli toparlar» bu ýerde görkezilmedik saýlaw toparlaryny öz içine alýar.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Torlary göni diagnostika arkaly tanaň we her birinde režimi hem-de toparlary üýtgediň.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("Birikme režimi"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Öçük"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Senariler"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Senari tutuş birikmäni dolandyrýar. Öz senariňizi üýtgetmek üçin, başgasynyň nusgasyny üýtgetmek üçin basyň.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Serwerler"),
    "rcxServersMatch": m139,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("At nusgasy"),
    "rcxSettingsLink": MessageLookupByLibrary.simpleMessage(
      "Awtomatik ugruň sazlamalary",
    ),
    "rcxSettingsLinkHint": MessageLookupByLibrary.simpleMessage(
      "Profiller, ssenariýler we ugurlar",
    ),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("Akylly toparlar"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Içerki"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "Asyl profil üýtgedi",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Näme üýtgedi"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("Üpjün edijiden"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Meniňki"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Hiç bir serwer laýyk gelmese",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("Göni git"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Häzirki serweri sakla",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Çalyşmalar"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Teg ady"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Diňe latyn harplary, sanlar, - we _, iň köp 24 nyşan",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Tegler"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Teg serwerler toplumyna bir gezek at berýär, ony isleglerde tag(name) görnüşinde ulanyp bolýar.",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("üçünji tarap"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Bellik"),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Awtomatik ugur"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Terjimeler"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage(
      "Bu topar üçin awtomatik ugry öçürmek",
    ),
    "rcxTurnOffHint": MessageLookupByLibrary.simpleMessage(
      "Topar häzirki serwerini saklaýar we özbaşdak çalşmagyny bes edýär.",
    ),
    "rcxUntilCheck": m140,
    "rcxUntilConfirm": m141,
    "rcxUntilDwell": m142,
    "rcxUseCheck": m143,
    "rcxUseDiagnostic": m144,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage("çykyş ýurdy barlagy"),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Duýduryşlar"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Näme üçin bu serwer"),
    "rcxWhyCount": m145,
    "rcxWouldDo": MessageLookupByLibrary.simpleMessage("Awtomatik ugur açylsa"),
    "rcxWouldServers": m146,
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Soňky soraglar"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Teklip edilen"),
    "recordType": MessageLookupByLibrary.simpleMessage("Ýazgy görnüşi"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir porty"),
    "redo": MessageLookupByLibrary.simpleMessage("Täzeden et"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Sebiti ulan"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "Sebit ýa-da programma sanawlary üýtgedi. Häzirki sazlamalar bilen saýlawy gaýtalaň.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu sebite gabat gelýän programma tapylmady. Sanawlaryňyz üýtgemedi.",
    ),
    "regionAppsPreview": m147,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Programma saýlawynyň deslapky syny",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS serwerleri"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Hyzmat barlaglary",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("Näme üýtgeýär"),
    "regionChina": MessageLookupByLibrary.simpleMessage("Hytaý"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Özüňiz üýtgeden bahalar şol durşuna galýar.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Müsür"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Ýurduňyz üçin DNS serwerlerini, TUN MTU-ny, aýlanyp geçiş sanawyny we hyzmat barlaglaryny saýlaýar. Interfeýsiň dili üýtgemeýär.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Eýran"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Sazlamalar üýtgemeýär.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Hyzmat barlaglary öçürilen",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Saýlanmadyk"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Başga ýurt"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Bu enjam üçin maslahat berilýär",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Russiýa"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Programmalary sebit boýunça saýlamak",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Sebit programma tekliplerini ulanmak üçin ilki goldanylýan sebiti saýlaň.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Sebit profili"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Sebitleýin uýgunlaşma",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Ýady boşat"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Ýady boşadyp bolmady",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Uzak"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("Daşarky nyşan"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Uzak DNS çözülişi",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Aýyr"),
    "rename": MessageLookupByLibrary.simpleMessage("Adyny üýtgetmek"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("Abunany uzalt"),
    "replace": MessageLookupByLibrary.simpleMessage("Çalyşmak"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Hemmesini çalyşmak"),
    "request": MessageLookupByLibrary.simpleMessage("Haýyş"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("Talap sözbaşylary"),
    "requests": MessageLookupByLibrary.simpleMessage("Soraglar"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Soraglar we täzelenmeler",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Hökmany"),
    "reset": MessageLookupByLibrary.simpleMessage("Başlangyça getir"),
    "resetAllData": MessageLookupByLibrary.simpleMessage(
      "Ähli maglumatlary arassalamak",
    ),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage(
      "Ählisini öçürmek",
    ),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Ähli profiller, sazlamalar, skriptler, diwar kagyzlary we keş maglumatlary hemişelik öçüriler. Ätiýaçlyk nusga arhiwleri saklanar. Soňra programma ýapylar. Bu amaly yzyna gaýtaryp bolmaýar.",
    ),
    "resetAllDataWait": m148,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Bu sahypada üýtgeşmeler bar. Sahypany dikeltmek isleýärsiňizmi?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Hakykatdanam başlangyça getirmek isleýärsiňizmi?",
    ),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Maglumatlar öçürilýär…",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki täzelenme aralygy",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki täzelenme aralygy 0-dan uly bolmaly",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Serişdeler"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Düzgünlere laýyklyk"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Düzgünlere laýyklyk DNS baglanyşyklaryny düzgünlere laýyk ugrukdyrýar; Proxy Server Nameserver gerek.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Jogap kody"),
    "restart": MessageLookupByLibrary.simpleMessage("Täzeden işlet"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Çekirdegi täzeden işletmek isleýärsiňizmi?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Dikelt"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Ähli maglumatlary dikelt",
    ),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Deslapky bahalary dikelt",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Diňe profilleri dikelt",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Dikeldiş usuly"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Utgaşykly",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Üstünden ýazmak",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("Dikeltildi"),
    "result": MessageLookupByLibrary.simpleMessage("Netije"),
    "retry": MessageLookupByLibrary.simpleMessage("Gaýtadan synanyş"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Marşrut salgylary"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Ugurlamadan çykarylan salgylar",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Ugurlama belgisi"),
    "ru": MessageLookupByLibrary.simpleMessage("Rus dili"),
    "rule": MessageLookupByLibrary.simpleMessage("Düzgün"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logiki AND düzgüni",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Doly domeni gabat getirýär",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Domeniň açar sözüni gabat getirýär",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Domeni regex boýunça gabat getirýär",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Domeniň goşundysyna gabat getirýär",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard boýunça gabat getirme; diňe * we ? goldanylýar",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP nyşanyny gabat getirýär (diňe tproxy girýän UDP trafigi üçin)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Maksat portynyň aralygyny gabat getirýär",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "IP-niň ýurt kodyny gabat getirýär",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite-däki domenleri gabat getirýär",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Girýäniň adyny gabat getirýär",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Girýän porty gabat getirýär",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Girýän trafigiň görnüşini gabat getirýär",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Girýän ulanyjynyň adyny gabat getirýär; birnäçe ulanyjy adyny / bilen aýraň",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IP-niň ASN-i gabat getirýär",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP-adresiň aralygyny gabat getirýär; IP-CIDR6 diňe bir alternativ at",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IP-adresiň aralygyny gabat getirýär",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IP-niň soňky bölegini gabat getirýär",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Ähli haýyşlary gabat getirýär; şert gerek däl",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP ýa-da UDP trafigini gabat getirýär",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logiki NOT düzgüni",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Logiki OR düzgüni",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Prosesiň ady boýunça gabat getirýär; Android-da paketiň ady gabat gelýär",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Proses adyny regex boýunça gabat getirýär; Android-da paketiň ady gabat gelýär",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Proses adyny wildcard boýunça gabat getirýär; diňe * we ? goldanylýar",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Prosesiň doly ýoly boýunça gabat getirýär",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Proses ýolyny regex boýunça gabat getirýär",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Proses ýolyny wildcard boýunça gabat getirýär; diňe * we ? goldanylýar",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Qayta gabat getirmaniň adyny gabat getirýär; birnäçe ady / bilen aýraň",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Düzgünler toplumyna salgylanýar; rule-providers gerek",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Çeşme IP-niň ýurt kodyny gabat getirýär",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Çeşme IP-niň ASN-i gabat getirýär",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Çeşme IP-adresiň aralygyny gabat getirýär",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Çeşme IP-niň soňky bölegini gabat getirýär",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Çeşme portynyň aralygyny gabat getirýär",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Içki düzgüne görä gabat getirýär; parantezlere üns beriň",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux ulanyjy ID-sini gabat getirýär",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Düzgün boş"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Düzgünler her bentde bir düzgün bolan YAML sanawy bolmaly, mysal üçin - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent göni",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS petiklemek",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Proksi loopbackini petiklemek",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage(
      "QUIC petiklemek",
    ),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage(
      "STUN petiklemek",
    ),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "Ýerli tor göni",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple we Microsoft göni",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "Düzgünler üpjün edijileri",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Düzgünler toplumy"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Düzgünler toplumynda ulanylýan ýazgy ýok",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Bu mrs faýly okalmaýar",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Düzgünler toplumy domenleri we IP aralyklary garyşdyrýar, şonuň üçin onuň görnüşi kesgitlenemeýär",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Düzgüniň nyşany"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "Düzgün goldanylýan görnüşden başlamaly, mysal üçin DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Düzgünler"),
    "rulesCount": m149,
    "runTime": MessageLookupByLibrary.simpleMessage("Iş wagty"),
    "running": MessageLookupByLibrary.simpleMessage("Işleýär"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Iş wagty konfigurasiýasy",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Howpsuz režim"),
    "safeModeAppTitle": m150,
    "saturation": MessageLookupByLibrary.simpleMessage("Doýgunlyk"),
    "save": MessageLookupByLibrary.simpleMessage("Ýatda sakla"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Üýtgeşmeleri ýatda saklamak isleýärsiňizmi?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Skript"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Skript usuly: giňeltme skripti bilen profili doly täzeden ýazýar",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Saýlanylana çenli aýla",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Gözle"),
    "seconds": MessageLookupByLibrary.simpleMessage("sekunt"),
    "secondsCount": m151,
    "secretKey": MessageLookupByLibrary.simpleMessage("Açar"),
    "sectionsInEffect": m152,
    "select": MessageLookupByLibrary.simpleMessage("Saýla"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Ählisini saýla"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Düzgünler toplumyny saýlaň",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Bölmek strategiýasyny saýlaň",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Saýlanan"),
    "send": MessageLookupByLibrary.simpleMessage("Iber"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("Telefondan iber"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Telefondaky baglanyşyk import edilsinmi?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Bu enjam ýerli tora birikdirilmedik",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Abuna baglanyşygy ýa-da proksi paýlaşma baglanyşygy",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Iberildi. Beýleki enjamda importy tassyklaň.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "ReClash üçin baglanyşyk iber",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Telefondan baglanyşyk almak üçin ReClash programmasyna ýerli tora girmäge mümkinçilik berýän «Golaýdaky enjamlar» rugsady gerek. Ony programmanyň sazlamalarynda işjeňleşdiriň.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Kody telefonyňyzyň kamerasy bilen skanirläň we açylan sahypa baglanyşygy goýuň. Iki enjam hem şol bir tora birikdirilen bolmaly.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Serwer"),
    "serviceAbnormalCount": m153,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Ählisi elýeterli",
    ),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Işjeň hyzmatlary awtomatik barla",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Ähli hyzmatlary barla",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Elýeterli"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloklanan"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Ählisini barla"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "Diňe birikdirilende barla",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Ýakynda"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Rugsat berilmedik ISP",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Barlag şowsuz"),
    "serviceManage": MessageLookupByLibrary.simpleMessage(
      "Hyzmatlary dolandyr",
    ),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Diňe asyl nusgalar",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Barlanmadyk"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Giriş çäklendirilen",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Panelde görkezilen",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage(
      "Hyzmatlaryň ýagdaýy",
    ),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Elýeterli däl"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Sebit goldanmaýar",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("sazlamalar"),
    "settings": MessageLookupByLibrary.simpleMessage("Sazlamalar"),
    "settingsCount": m154,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Bu profil şifrlenen. Dowam etmek üçin age açaryny giriziň.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Bu serwer aýratyn synaga jogap berdi. Oňa geçip, tutuş ugry täzeden barlaň.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "ReClash açylanda birik",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Bu birikmäni programma bilen bile işe giriz.",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Sazlamalary üýtget",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage("Birikmäni barla"),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "Netije ähli programma ýa-da web sahypasyna däl-de, şu ugra degişlidir.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Saýlanan bir ugry barlaýarys. Ulgamyň rugsat soraglary aýratyn açylýar.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Birikme barlanýar",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Tassyklanyldy"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "Saýlanan ugur jogap berdi. Traffik profil düzgünlerine eýerýär.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "Birikme işleýär",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Proksi salgysyny göçür",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage(
      "Ähli programmalar",
    ),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN enjamyň traffigini tutýar. Ulgam rugsat sorap biler.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android VPN birikmesini döretmäge rugsat sorar. Programmalary elýeterlilik sazlamalarynda saýlap bolýar.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash ulanýan programmalaryňyzy saýlaň. Haýsy birikmeleriň serwerden geçýändigini profil düzgünleri kesgitleýär.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Programmalary özüm el bilen sazlaryn",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Birikdirmek isleýän her programmaňyzda ýerli proksi salgysyny görkeziň.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Ähli traffigi tutmak onuň hemmesini serwer arkaly ibermek diýmek däldir. Göni ugurlar saklanýar.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Ulgam proksisi",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Ulgam proksisini goldamaýan programmalar göni birigýär.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Haýsy programmalar birikmeli?",
    ),
    "setupDirectApps": m155,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "Ýerli programmalar tapylmady. Saýtlar barybir göni açylar.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Olar VPN-siz işlär. Sanawy soňra elýeterlilik dolandyryşynda üýtgedip bilersiňiz.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Ýerli programmalary gözleýäris…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Ýurduňyzyň hyzmatlary serwersiz açylar: has çalt, banklar we döwlet saýtlary sizi petiklemez. Umumy düzgünlere şular goşular:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Ýerli saýtlar we programmalar — göni",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Maglumatlar"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Birikmä üns bermeli",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Islendik saýlawy sazlamalarda üýtgedip bilersiňiz.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Dowam et"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Şertleri okamazdan öň dil saýlaň. Ony soňra üýtgedip bilersiňiz.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Diliňizi saýlaň",
    ),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "Sazlama tamamlanmady; birikme barlanmady.",
    ),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash ýapylar. Saýlawyňyz saklanar we sazlama indiki gezek açylanda dowam eder.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Sazlamadan çykmalymy?",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Bu salgyny birikdirmek isleýän programmalaryňyzda belläň. Bu barlag programmalaryň sazlanandygyny tassyklamaýar.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Ýerli proksi taýýar",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Barlanmady"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "Ugur jogap berdi, ýöne käbir barlaglary tassyklap bolmady.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Birigen, ýöne çäklendirmeler bar",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Ulgamyň soragynda birikmä rugsat beriň, gaýtadan synanyşyň ýa-da başga çäk saýlaň.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Rugsat gerek",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Başga serwer gözlenýär",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Birikme işe girizilýär",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage(
      "Esasy modul işe girizilýär",
    ),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Çykyş tassyklanýar",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Profil ulanylýar",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage("Ugur barlanýar"),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Hyzmatlar barlanýar",
    ),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Dowam etmek üçin profil goşuň ýa-da saýlaň.",
    ),
    "setupProfileCount": m156,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash serwerleri üpjün etmeýär. Üpjün edijiňiziň abunasyny ýa-da konfigurasiýasyny import ediň.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Profili import et",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Başga profil goş",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijiň hatyndan, botundan ýa-da şahsy otagyndan salgyny goýuň ýa-da faýl ýa QR-kod saýlaň.",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Abuna ýa-da paýlaşma baglanyşygy",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Profil taýýar"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("Soňra sazla"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Birikme profilini goşuň",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Birikmäňiz"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Barlag"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Örtük"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Sebit"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage(
      "Maslahat berilýär",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Profiliň başlangyç sazlamalaryny sakla",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Sebit sazlamalary üýtgemeýär.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash DNS-i, MTU-ny we göni ugurlary ýurduňyzyň torlaryna laýyklaşdyrýar. Interfeýsiň dili üýtgemeýär.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Nireden birikýärsiňiz?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Hiç zat saýlamasaňyz, häzirki sebit sazlamalary öňküsi ýaly galar.",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Gaýtadan barla"),
    "setupReport": MessageLookupByLibrary.simpleMessage("Barlag hasabaty"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Birikmä rugsat ber",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage("Birikmäni sazla"),
    "setupResume": MessageLookupByLibrary.simpleMessage("Sazlamagy dowam et"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "Barlag wagtynda ugur üýtgedi. Häzirki birikmäni täzeden barlaň.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "Howpsuz tertip hakyky birikmäni başlatmaýar. Sazlamany saklaň ýa-da adaty ýygyndyda synaň.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Saýlawlaryňyzy saklap bolmady. Gaýtadan synanyşyň.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Birikmän sakla",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Saýlawlaryňyz saklandy. Taýýar bolanyňyzda dolandyryş panelinden birigip bilersiňiz.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("Soňra birik"),
    "setupStepStatus": m157,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Saýlawlaryňyz saklandy. Öňki birikme saklanmady.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Barlag saklandy",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Başga gerimi saýlaň: käbir torlar VPN-i petikleýär.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Internetiň ReClash-syz işleýändigine göz ýetiriň.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Profili täzeläň ýa-da sazlamadan soň başga serwer saýlaň.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage(
      "Näme synap görüp bolar",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Ilkinji birikme"),
    "setupTryServer": m158,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Jogap ýok"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "Birikme başlady, ýöne saýlanan ugur ýeterlik netije bermedi.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Birikme tassyklanmady",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "Amal tamamlanmady. Gaýtadan synanyşyň ýa-da maglumatlary açyň.",
    ),
    "shareLinkUnreadable": m159,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Salgylardan hiç bir proksi okalyp bilmedi",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Bu profili import etmek üçin kody başga enjamdaky ReClash bilen skanirläň.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Görkez"),
    "showLess": MessageLookupByLibrary.simpleMessage("Daralt"),
    "showMore": MessageLookupByLibrary.simpleMessage("Giňelt"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Duýduryşdaky bes düwmesi",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Paroly görkez"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Gapdal panel"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Gapdal paneliň bulaňňylamasy",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Gapdal panel arkaly penjireň arkasyndaky bulaňňylan iş stolyny görkezmek",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Sessiz işe girizmek"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Sessiz işe girizmek penjireni görkezmän başlaýar.",
    ),
    "simpleDashboardDetailed": MessageLookupByLibrary.simpleMessage(
      "Giňişleýin panel",
    ),
    "simpleDashboardEditWidgets": MessageLookupByLibrary.simpleMessage(
      "Widgetleri düzet",
    ),
    "simpleDashboardEmpty": MessageLookupByLibrary.simpleMessage(
      "Heniz widget ýok. Olary redaktorda goşuň.",
    ),
    "simpleDashboardHome": MessageLookupByLibrary.simpleMessage("Baş sahypa"),
    "simpleDashboardSimple": MessageLookupByLibrary.simpleMessage(
      "Ýönekeý panel",
    ),
    "simpleDashboardWidgets": MessageLookupByLibrary.simpleMessage("Widgetler"),
    "simpleDaysCount": m160,
    "simpleIpBusiness": MessageLookupByLibrary.simpleMessage(
      "Guramanyň salgysy",
    ),
    "simpleIpGoodDesc": MessageLookupByLibrary.simpleMessage(
      "CAPTCHA we «VPN» bloklary ähtimal däl.",
    ),
    "simpleIpHosting": MessageLookupByLibrary.simpleMessage(
      "Maglumat merkezi salgysy",
    ),
    "simpleIpLevelClean": MessageLookupByLibrary.simpleMessage("Arassa"),
    "simpleIpLevelNormal": MessageLookupByLibrary.simpleMessage("Adaty"),
    "simpleIpLevelRisky": MessageLookupByLibrary.simpleMessage("Töwekgel"),
    "simpleIpMobile": MessageLookupByLibrary.simpleMessage("Mobil tor salgysy"),
    "simpleIpNormalDesc": MessageLookupByLibrary.simpleMessage(
      "Käbir saýtlar CAPTCHA sorap biler.",
    ),
    "simpleIpReal": MessageLookupByLibrary.simpleMessage("Hakyky salgyňyz"),
    "simpleIpRealDesc": MessageLookupByLibrary.simpleMessage(
      "Provaýderiňiz we saýtlar nirede bolanyňyzy we näme açanyňyzy görýär.",
    ),
    "simpleIpResidential": MessageLookupByLibrary.simpleMessage(
      "Adaty öý salgysy",
    ),
    "simpleIpRiskyDesc": MessageLookupByLibrary.simpleMessage(
      "Saýtlar sizi has ýygy bloklap ýa-da barlap biler.",
    ),
    "simpleIpTitle": MessageLookupByLibrary.simpleMessage(
      "Saýtlar sizi nähili görýär",
    ),
    "simpleIpUnknown": MessageLookupByLibrary.simpleMessage(
      "Salgyny barlap bolmady",
    ),
    "simpleLatency": m161,
    "simpleLocationAll": MessageLookupByLibrary.simpleMessage("Hemmesi"),
    "simpleLocationAuto": MessageLookupByLibrary.simpleMessage(
      "awtomatiki saýlandy",
    ),
    "simpleLocationManual": MessageLookupByLibrary.simpleMessage(
      "siz tarapyndan saýlandy",
    ),
    "simpleLocationNone": MessageLookupByLibrary.simpleMessage(
      "Entek serwer ýok",
    ),
    "simpleLocationNoneHint": MessageLookupByLibrary.simpleMessage(
      "Serwerler birikdirilenden soň peýda bolar",
    ),
    "simpleModeAuto": MessageLookupByLibrary.simpleMessage("Awto"),
    "simpleModeAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Režimi tor senariýi saýlaýar",
    ),
    "simpleModeDirect": MessageLookupByLibrary.simpleMessage("Göni"),
    "simpleModeDirectDesc": MessageLookupByLibrary.simpleMessage(
      "Trafik VPN-siz geçýär",
    ),
    "simpleModeGlobal": MessageLookupByLibrary.simpleMessage(
      "Hemmesi VPN arkaly",
    ),
    "simpleModeGlobalDesc": MessageLookupByLibrary.simpleMessage(
      "Ähli trafik serwerden geçýär",
    ),
    "simpleModeRule": MessageLookupByLibrary.simpleMessage("Akylly"),
    "simpleModeRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Diňe açylmaýanlar VPN arkaly geçýär",
    ),
    "simpleModeTitle": MessageLookupByLibrary.simpleMessage("Režim"),
    "simpleNoExpiry": MessageLookupByLibrary.simpleMessage("Möhletsiz"),
    "simpleProviderAnnouncement": MessageLookupByLibrary.simpleMessage(
      "Üpjün edijiniň bildirişi",
    ),
    "simpleServiceBlocked": m162,
    "simpleServiceComingSoon": m163,
    "simpleServiceOriginalsOnly": m164,
    "simpleServiceRestricted": m165,
    "simpleServiceUnavailable": m166,
    "simpleServiceUnsupportedRegion": m167,
    "simpleServicesAfterConnect": MessageLookupByLibrary.simpleMessage(
      "Birikdirilenden soň",
    ),
    "simpleServicesAllGood": MessageLookupByLibrary.simpleMessage(
      "Hemmesi ýerinde",
    ),
    "simpleServicesDirect": MessageLookupByLibrary.simpleMessage(
      "VPN-siz ýaly, göni",
    ),
    "simpleServicesManual": MessageLookupByLibrary.simpleMessage("Elde"),
    "simpleServicesTitle": MessageLookupByLibrary.simpleMessage("Hyzmatlar"),
    "simpleServicesViaVpn": MessageLookupByLibrary.simpleMessage("VPN arkaly"),
    "simpleSpeed4k": MessageLookupByLibrary.simpleMessage(
      "4K wideo üçin ýeterlik",
    ),
    "simpleSpeedAgain": MessageLookupByLibrary.simpleMessage("Ýene"),
    "simpleSpeedAll": MessageLookupByLibrary.simpleMessage(
      "Çalt: hemme zady bir wagtda ýeterlik",
    ),
    "simpleSpeedChat": MessageLookupByLibrary.simpleMessage(
      "Ýazyşmak we aýdym-saz üçin ýeterlik",
    ),
    "simpleSpeedDirectIdleDesc": m168,
    "simpleSpeedDirectTag": MessageLookupByLibrary.simpleMessage("VPN-siz"),
    "simpleSpeedFailed": MessageLookupByLibrary.simpleMessage(
      "Ölçüp bolmady. Ýene synanyşyň.",
    ),
    "simpleSpeedHd": MessageLookupByLibrary.simpleMessage(
      "HD wideo üçin ýeterlik",
    ),
    "simpleSpeedIdleDesc": m169,
    "simpleSpeedLevel4k": MessageLookupByLibrary.simpleMessage("4K"),
    "simpleSpeedLevelAll": MessageLookupByLibrary.simpleMessage(
      "Hemmesi birden",
    ),
    "simpleSpeedLevelChat": MessageLookupByLibrary.simpleMessage("Çatlar"),
    "simpleSpeedLevelHd": MessageLookupByLibrary.simpleMessage("HD"),
    "simpleSpeedMeasure": MessageLookupByLibrary.simpleMessage("Ölçemek"),
    "simpleSpeedMeasuring": MessageLookupByLibrary.simpleMessage("Ölçülýär…"),
    "simpleSpeedSlow": MessageLookupByLibrary.simpleMessage(
      "Haýal: sahypalar hem uzak ýüklenýär",
    ),
    "simpleSpeedTitle": MessageLookupByLibrary.simpleMessage("Tizlik"),
    "simpleSpeedUnit": MessageLookupByLibrary.simpleMessage("Mbit/s"),
    "simpleStatusConnecting": MessageLookupByLibrary.simpleMessage(
      "Birikdirilýär…",
    ),
    "simpleStatusConnectingHint": MessageLookupByLibrary.simpleMessage(
      "Iň oňat serweri saýlaýar",
    ),
    "simpleStatusNoProfile": MessageLookupByLibrary.simpleMessage(
      "Abunalyk ýok",
    ),
    "simpleStatusNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Birikmek üçin abunalyk goşuň",
    ),
    "simpleStatusOff": MessageLookupByLibrary.simpleMessage("Goralmaýar"),
    "simpleStatusOffHint": MessageLookupByLibrary.simpleMessage(
      "Birikmek üçin basyň",
    ),
    "simpleStatusOn": MessageLookupByLibrary.simpleMessage("Goralýar"),
    "simpleStatusPaused": MessageLookupByLibrary.simpleMessage("Pauza"),
    "simpleStatusPausedHint": MessageLookupByLibrary.simpleMessage(
      "Ynamly tor",
    ),
    "simpleStatusPausedOn": m170,
    "simpleTrafficLeft": m171,
    "simpleTrafficUnlimited": MessageLookupByLibrary.simpleMessage(
      "çäksiz trafik",
    ),
    "simpleTrustedDesc": MessageLookupByLibrary.simpleMessage(
      "Bu torlarda VPN özbaşdak pauzada durýar we siz gidende ýene açylýar.",
    ),
    "simpleTrustedEmpty": MessageLookupByLibrary.simpleMessage("Entek tor ýok"),
    "simpleTrustedThisNetwork": MessageLookupByLibrary.simpleMessage("Bu tor"),
    "simpleTrustedTitle": MessageLookupByLibrary.simpleMessage(
      "Öz torlarymda pauza",
    ),
    "simpleUntilDate": m172,
    "singleAdd": MessageLookupByLibrary.simpleMessage("Tek goşmak"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Tek import"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Bu ýerde bir salgy giriziň; birnäçesini sanawyň çalt redaktirlemeginden düzet",
    ),
    "singleValueTip": m173,
    "size": MessageLookupByLibrary.simpleMessage("Ölçeg"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Sertifikat barlagyny geç",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Domenleri geç"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Domenleri geç diziminden tapylan domen ulanylmaýar.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Nişan salgylaryny geç",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Çeşme salgylaryny geç",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Süýşme"),
    "sliders": MessageLookupByLibrary.simpleMessage("Süýşüjiler"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protokollar"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Sniffer TLS, HTTP we QUIC trafiginden domeni aýryp alýar; şonuň üçin düzgünler ony gabat getire biler.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS porty"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Ýumşak"),
    "sort": MessageLookupByLibrary.simpleMessage("Tertipleme"),
    "source": MessageLookupByLibrary.simpleMessage("Çeşme"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Çeşme IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Ýörite proksi"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Ýörite düzgünler"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spektr"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Tizlik statistikasy",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Bölmek strategiýasy",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Bölmek strategiýasy boş bolmaly däl",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSID-lar boş"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stek usuly"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Stek izi"),
    "standard": MessageLookupByLibrary.simpleMessage("Standart"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standart usul: profiliň üstüne düzgünleri goşýar",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Başla"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("Noldan başlamak"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN başlanýar…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Işe giriş we fon",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Ýagdaý"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS öçürilende ulgamyň DNS-i ulanylýar.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Bes et"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN bes edilýär…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Strategiýa"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Berk ugurlama"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Berk ugurlama DNS ýaly trafikniň TUN-dan sowlup geçmeginiň öňüni alýar we beýleki enjamlar bu enjama ýetmekden galýar.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Stil"),
    "submit": MessageLookupByLibrary.simpleMessage("Tabşyr"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage(
      "Awtomatiki",
    ),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Ýörite User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Dolandyryş nyşanlary bolmadyk dogry User-Agent giriziň.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Müşderini saýlamak enjam şahsyýetini ibermeýär.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Soragyň müşderisi",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Bu sazlamalar abunalyk URL salgylaryna degişli. Proksi baglanyşyklary ýerli usulda import edilýär.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Bu abunany barlamak üçin AGE açaryny giriziň.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Barlanan netijäni ulanmak"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "Serwer ygtyýarnamany ret etdi. Müşderi saýlamak duruzyldy.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Barlamak",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Utgaşyk abunany alyp bolmady. Öňki sazlama üýtgedilmedi.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Häzirki bahalary saklamazdan we VPN-i täzeden açmazdan barlaýar. Düwünleriň elýeterliligi däl, sazlamanyň seljermesi barlanýar.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Import ýitgileri barada täzeden soramak",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Abunanyň URL salgysyny gizle",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Soňky üstünlikli müşderi"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "Importda başlangyç maglumatlaryň bir bölegi geçirilmeýär. Ulanmazdan öň ýitgileri barlaň.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Şu müşderini ulanmak"),
    "subscriptionCompatibilityPrepared": m174,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core bu netijäni seljerdi. Ol entek saklanmady ýa-da ulanylmady.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "Serwer haýyşlary çäklendirdi. Soňrak gaýtalaň.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Abunanyň URL salgysyny görkez",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "Forma ýa-da profil üýtgedi. Abunany täzeden barlaň.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "Abunany barlamagyň wagty gutardy.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Utgaşyklyk",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Birikdirip bolmady. Müşderi saýlamak duruzyldy.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Bu abuna ýazgysy üçin boş enjam ýeri ýok. Üpjin edijiniň hasabyndan bir enjamy aýryp, gaýtadan synanyşyň.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Bu abuna ýazgysy enjamy hasaba almagy talap edýär. Üpjin edijiniň görkezmelerine eýeriň.",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Abunaňyz möhleti gutardy",
    ),
    "subscriptionExpiresInDays": m175,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Abunaňyz şu gün gutarýar",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Operasiýa ulgamyny we enjam modelini hem iber",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "ID bilen bilelikde operasiýa ulgamynyň wersiýasy we enjam modeli iberiler.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Şu abunalyk çeşmesine durnukly lakam enjam ID-si iberiler. Bu enjam kepillendirmesi däl; razylyk diňe şu enjamda saklanýar.",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "HWID iberişi öçürilse, köp abunalar işlemez.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Abunalyk şahsyýet maglumatlary",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "HWID-i iber",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Umumy sazlamany ulan",
    ),
    "subscriptionImportAdd": m176,
    "subscriptionImportAllAdded": m177,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash sazlamasy",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "şifrlenen abunalyk",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "proksi baglanyşyklary",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "näbelli format",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýa bölümleri",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "Çeşmäniň bu bölekleriniň ýerine ReClash öz sazlamalaryny ulanýar.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "Geçirilmeýär",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Serwerleriň hiç biri goldanylmaýar",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Serwerleriň käbir sazlamalary goldanylmaýar we taşlanýar",
    ),
    "subscriptionImportPartial": m178,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "Ýükleme we iberme tizligi görkezilmedik",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "Protokol goldanylmaýar",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "Transport goldanylmaýar",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Bu abuna üçin indi soramaň",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Başga bir zat geçirilmese, ýene soralar.",
        ),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Hemmesi geçirilmeýär",
    ),
    "subscriptionImportShowAll": m179,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "Goşulmaz",
    ),
    "subscriptionImportSourceFormat": m180,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("Abuna maglumaty"),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("Ösüş"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("Promo"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("Synag"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Abuna ýatlatmalary",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Abunalyk"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Hasap",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Meýilnama satyn al",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Trafik satyn al",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "Logotip salgysy",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Goldaw",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Web sahypasy",
    ),
    "subscriptionTrafficLow": m181,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Üp üpjün edijiniň täzelenme aralygyny ulan",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "sudo üçin parolyňyzy giriziň",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Wagtlaýyn bes edilen…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Profili çalyş"),
    "sync": MessageLookupByLibrary.simpleMessage("Sinhronlaşdyr"),
    "system": MessageLookupByLibrary.simpleMessage("Ulgam"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Ulgam programmalary"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Ulgam proksisi"),
    "tab": MessageLookupByLibrary.simpleMessage("Waraq"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Waraq animasiýasy"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Gaýtadan synanyşmak üçin nyşana basyň",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Rugsat bermek üçin basyň",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Nişan"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP paralelligi"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Bu enjamda Telegram-y açyp bolmady.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Telegram-y aç"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage("Brauzerde aç"),
    "testInterval": MessageLookupByLibrary.simpleMessage("Synag aralygy"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Synag URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Ulananda synag"),
    "textScale": MessageLookupByLibrary.simpleMessage("Tekstiň ululygy"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Tekst şeýle görner",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Tema"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Tema reňki"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Tema usuly"),
    "tight": MessageLookupByLibrary.simpleMessage("Dykyz"),
    "time": MessageLookupByLibrary.simpleMessage("Wagt"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Boýaldy"),
    "tip": MessageLookupByLibrary.simpleMessage("Maslahat"),
    "tk": MessageLookupByLibrary.simpleMessage("Türkmençe"),
    "toggle": MessageLookupByLibrary.simpleMessage("Çalyş"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Çydamlylyk"),
    "tools": MessageLookupByLibrary.simpleMessage("Gurallar"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Hereket"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Bölümü saýlaň ýa-da sazlamany gözleň",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Bu hereket ähli işleýän baglanyşyklary ýapar. Dowam edilsinmi?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage(
      "Hereket tamamlandy",
    ),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Konfigurasiýa"),
    "toolsData": MessageLookupByLibrary.simpleMessage(
      "Serişdeler we maglumatlar",
    ),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "Gabat gelýän sazlamalar ýa-da hereketler ýok",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Maglumat we otladka",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("Soňky ulanylýanlar"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Ilki şahsyýet tanamany açyň",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Ilki daşarky dolandyryjyny açyň",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Bu hereketi işletmek üçin çekirdegi başlaň",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Ilki özbaşdak tor interfeýsini saýlaň",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Ilki MIPS tor stegini saýlaň",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Ilki DNS sahypasynda şu DNS üstünden geçirişini goşuň",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Ilki WebDAV-y sazlaň",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Diagnostika"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Berkit"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Berkitilen"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Çekirdegi täzeden işlet",
    ),
    "toolsResults": m182,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Işlet"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Bölüm"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Sazlama"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Berkitmegi aýyr"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Serişdeleri täzele",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Düzgünleriň we skriptleriň täzelenmegi konfigurasiýany ýene-de ulanyp, baglanyşyklara täsir edip biler. Dowam edilsinmi?",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Trafigi doldur"),
    "torch": MessageLookupByLibrary.simpleMessage("Fonar"),
    "total": MessageLookupByLibrary.simpleMessage("Jemi"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Göçürip alnan"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Jemi trafik"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Ýüklenen"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy porty"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafik"),
    "trafficPeak": m183,
    "trafficTotal": m184,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafik ulanylyşy"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Terjime düzedişini teklip et",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportHeaders": m185,
    "trayIcon": MessageLookupByLibrary.simpleMessage("Tray nyşany"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Reňkli"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Gara"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Ak"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Ynamly torlar"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "Bu torlaryň birine baglanylanda VPN awtomatiki bes edilýär",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Häzirki tor ynamly — VPN şu ýerde bes edilen",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN rugsatlandyrylyp bilmedi, şonuň üçin öçürüldi.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN diňe administrator usulynda işleýär.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Bu ýerde goşulan ýazgylar ähli profilleriň TUN sazlamalaryny üstünden ýazýar; goşulmaganlar profiliň öz sazlamasy ulanýar. Özbaşdak profil özi goşan ýazgylar üste çykýar.",
    ),
    "tunSetupApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helper-e rugsat ber",
    ),
    "tunSetupConfirm": MessageLookupByLibrary.simpleMessage("Sazla"),
    "tunSetupDone": MessageLookupByLibrary.simpleMessage("TUN açykdyr"),
    "tunSetupInstallTitle": MessageLookupByLibrary.simpleMessage("TUN-y sazla"),
    "tunSetupInstantStart": MessageLookupByLibrary.simpleMessage(
      "Ondan soň TUN, ulgama girende-de, derrew işe başlaýar",
    ),
    "tunSetupLater": MessageLookupByLibrary.simpleMessage("Häzir däl"),
    "tunSetupLinuxInstall": MessageLookupByLibrary.simpleMessage(
      "Ulgamyň ähli trafigini ReClash arkaly ugrukdyrmak üçin TUN-a ulgam Helper-i gerek: ol Core-ny diňe tor rugsatlary bilen başlaýan systemd hyzmatydyr.",
    ),
    "tunSetupLinuxScope": MessageLookupByLibrary.simpleMessage(
      "Helper diňe barlanan ReClash Core-ny işledýär we oňa diňe tor hukuklaryny berýär",
    ),
    "tunSetupLinuxUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash täzelendi, şonuň üçin dowam etmek üçin TUN Helper hem onuň bilen bile täzelenmeli.",
    ),
    "tunSetupMacosInstall": MessageLookupByLibrary.simpleMessage(
      "TUN üçin ReClash Helper gerek. macOS ony bir gezek rugsat bermegiňizi soraýar.",
    ),
    "tunSetupOnceConfirm": MessageLookupByLibrary.simpleMessage(
      "Bu wersiýa üçin Windows bir gezek tassyklamagy soraýar",
    ),
    "tunSetupOncePassword": MessageLookupByLibrary.simpleMessage(
      "Bu wersiýa üçin administrator paroly bir gezek gerek",
    ),
    "tunSetupPasswordPrivacy": MessageLookupByLibrary.simpleMessage(
      "Paroly diňe ulgam penjiresinde giriziň: ReClash ony hiç haçan görmeýär.",
    ),
    "tunSetupUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "TUN elýeterli däl",
    ),
    "tunSetupUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helper-i täzele",
    ),
    "tunSetupWaiting": MessageLookupByLibrary.simpleMessage(
      "Ulgam penjiresinde tassyklamagyna garaşylýar…",
    ),
    "tunSetupWindowsInstall": MessageLookupByLibrary.simpleMessage(
      "Ulgamyň ähli trafigini ReClash arkaly ugrukdyrmak üçin TUN-a ReClash Service gerek — ol Core-ny tor adapteriniň talap edýän hukuklary bilen işledýän Windows hyzmatydyr.",
    ),
    "tunSetupWindowsScope": MessageLookupByLibrary.simpleMessage(
      "Hyzmat diňe barlanan ReClash Core-ny işledýär we diňe siziň hasabyňyzy kabul edýär",
    ),
    "tunSetupWindowsUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash täzelendi, şonuň üçin TUN-yň işlemegini dowam etdirmek üçin ReClash Service hem onuň bilen bile täzelenmeli.",
    ),
    "tunSetupWithoutTun": MessageLookupByLibrary.simpleMessage("TUN-syz"),
    "turnOff": MessageLookupByLibrary.simpleMessage("Ýap"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Aç"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP relýed usuly"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP gözlama möhleti"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP gözlama möhleti sekuntlarda ölçülýär we diňe gvisor, ulgam we garyşyk stekler bilen işleýär.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Yzyna al"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage(
      "Birleşdirilen saklanma",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Näbelli"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Näbelli tor ýalňyşlygy",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Adaty ölçegine gaýtar"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Adsyz"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage(
      "Penjireni berkitmegi aýyr",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Täzele"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Awtomatik gurnamaga rugsat bermek",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash barlanan, laýyk durnukly täzelenmeleri her gezek soramazdan gurup biler. VPN hiç wagt kesilmez. Android gurnamany tassyklamagyňyzy sorap biler.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Awtomatik gurnamaga rugsat berilsinmi?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Awtomatik gurmak",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Ýüklemäni ýatyrmak",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Täzelenme kanaly"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Deslapky reliz"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Durnukly reliz",
    ),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Awtomatik barlamak",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Täzelenmeleri barlap bolmady",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Baglanyşygy barlap, täzeden synanyşyň.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenmeler barlanýar…",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage(
      "Penjiräni ýapmak",
    ),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android siziň razylygyňyzy talap edýär. Ulgam tassyklamasyny açmak üçin dowam ediň.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Android-de tassyklaň",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Fonda dowam etmek",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Gurnamany dowam etmek",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "Iň soňky wersiýa gurnalan",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "Bu platformada ReClash neşiriň sahypasyny açýar. Täzelenmäni özüňiz ýükläp guruň.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "Bu enjam üçin barlanan ýükleme elýeterli däl. Neşiriň sahypasyndan bukja saýlaň.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Kesip gurmak",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "El bilen gurnamagy saklamak",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Täzelenmäni ýüklemek",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Täzeden ýüklemek",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Täzelenmäni ýükläp bolmady",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Ýüklenen bölek saklandy. Baglanyşygy barlap, ýüklemäni dowam ediň.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Düşnükli"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Bukja gurnaýjysyny başlap bolmady",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android gurnamany tamamlamady. Taýýar bolanyňyzda täzeden synanyşyň.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Häzir gurmak"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenme guruldy",
    ),
    "updateInstalledVersion": m186,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android gurnamany tamamlaýar. Bu ädimde ReClash ýapylyp biler.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenme gurulýar",
    ),
    "updateMinutes": m187,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Häzir däl"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Reliz bellikleri ýok.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenme elýeterli",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Android sazlamalaryny açmak",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Enjam üçin gurluş",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage(
      "Ýüklemegiň möçberi",
    ),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Bukjany barlamak",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Ýüklenenden soň, gurulmazdan öň barlanýar",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Bütewilik, programmanyň şahsyýeti we gol barlandy",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Säginmek"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Ýükleme säginýär",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash-a şu çeşmeden programmalar gurnamaga rugsat beriň we dowam etmek üçin gaýdyp geliň.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Android rugsady gerek",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Barlamagy, ýüklemegi we gurmagy aýratyn sazlaň.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Sazlamalar saklanmady. Täzeden synanyşyň; awtomatik gurnama açylmady.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenme sazlamalary",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi arkaly öňünden ýüklemek",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Gurnamaga taýýar",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Neşiriň jikme-jiklikleri",
    ),
    "updateRemainingTime": m188,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Ýüklemäni dowam etmek",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Dowam et"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Täzeden barlamak",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Gurnamany gaýtalamak",
    ),
    "updateSeconds": m189,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Doly reliz belliklerini gör",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Ähli üýtgeşmeleri görkez",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Täzelenmeler"),
    "updateTransferSpeed": m190,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Ýüklenen täzelenmäniň bitewüligini barlap bolmady.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Faýl, wersiýa ýa-da gol barlagdan geçmedi. Täze nusgany ýükläp, täzeden synanyşyň.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Bu bukjany gurup bolmaýar",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Täzelenme barlanýar",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Gurnama wagty ReClash gysga wagtlyk ýapylar. Baglanyşygy kesmäge taýýar bolsaňyz kesiň.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "VPN henizem işleýär",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Ýükle"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("Ýükleme kuwwaty"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL shemasy"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Hereket"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Abunalyk goş"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Abuna URL-ni goşmak; at hökmany däl.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Şifrlenen salgylanmanyň hakykylygyny barlap bolmady. Ol zaýalanan ýa-da başga açar ulanýan bolup biler.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Salgylanma döret"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Programmany ýap"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Sazlanan ýapmak hereketini ulanmak.",
    ),
    "urlSchemeConfigCounts": m191,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML ýa-da JSON konfigurasiýasyny goýuň",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýanyň mazmuny",
    ),
    "urlSchemeConfirmMessage": m192,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Daşarky programma buýrugy",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Daşarky birikme we ýapmak buýruklary tassyklama soraýar.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Birikdir"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Saýlanan profil bilen birikmek.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Birikme"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Mazmunyň görnüşi",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "Öwürme käbir mazmuny aýyrýar. Import wagtynda üýtgeşmeleri gözden geçiriň we tassyklaň.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Salgylanmany göçürip bolmady. Täzeden synanyşyň.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage(
      "Salgylanmany göçür",
    ),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Salgylanmany ýetirip bolmady ýa-da nobat doldy. Häzirki hereket tamamlanandan soň täzeden synanyşyň.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage(
      "Birikmäni kes",
    ),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Profili üýtgetmän birikmäni duruzmak.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Goşulan konfigurasiýa",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Mysal profil",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Formatlar"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyk formatlary. Ýer tutujylary URL ýa-da maglumatlaryňyz bilen çalşyň.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýany import et",
    ),
    "urlSchemeImportConfirm": m193,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyga YAML ýa-da JSON konfigurasiýasyny girizmek.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Salgylanmany barla",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Programma ýa-da profil salgylanmasyny goýuň",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "Barlag şu enjamda ýerine ýetirilýär. Ol salgylanmany açmaýar, abunalygy ýüklemeýär we profili import etmeýär.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "Salgylanmanyň gurluşy dogry. Abunalygyň elýeterliligi we ýadro barlagy diňe import wagtynda barlanýar.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Barlag netijesi",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Konfigurasiýany gur",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash müşderileriniň umumy abuna baglanyşyk formatyny ulanmak.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "Goşulan konfigurasiýa dogry UTF-8 Base64 maglumatlary däl.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "Salgylanma nädogry. Gurluşyny we göterim kodlamasyny barlaň.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Profil ady dolandyryş nyşanlary bolmazdan 64 nyşandan köp bolmaly däl.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Dogry HTTP ýa-da HTTPS abunalyk URL salgysyny giriziň.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "Salgylanmada abunalyk URL salgysy ýa-da konfigurasiýa ýok.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "Hiç bir hereket ýerine ýetirilmedi.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Programmany görkez"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash-y öňe çykarmak.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parametrler"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Alyş-çalyş buferini okap bolmady. Salgylanmany el bilen goýuň.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Baglanyşyk"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyk döretmek üçin URL ýa-da konfigurasiýa giriziň.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Baglanyşyklarda tokenler ýa-da giriş maglumatlary bolup biler. Seresap paýlaşyň.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Profiller"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Proksi paýlaşma salgylanmalary",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Salgylanma tanaldy",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Daşarky birikme buýruklaryny ulanmazdan öň birikme sazlamasyny tamamlaň.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Goldanylýan import salgylanmalary",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("Birikmäni çalyş"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Duran bolsa birikmek, işleýän bolsa aýyrmak.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "Salgylanmada iç-içe örtükler aşa köp.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "Salgylanma 4 MB-den ýa-da goşulan konfigurasiýa 2 MB-den uly.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Bu salgylanma buýrugy goldanylmaýar.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Bu şifrleme wersiýasy goldanylmaýar. Adaty abunalyk salgylanmasyny soraň.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("Mysaly ulan"),
    "urlTip": m194,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostlary ulanmak"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Ulgamyň hostlaryny ulanmak",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("ulanylan"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Ulanylan trafik"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Ulanyjy ady"),
    "uz": MessageLookupByLibrary.simpleMessage("Özbekçe"),
    "value": MessageLookupByLibrary.simpleMessage("Bahasy"),
    "view": MessageLookupByLibrary.simpleMessage("Gör"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Wirtual IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Janly"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-e degişli sazlama üýtgeşigi anyklandy",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN ulgamyň tutuş trafigini awtomatiki VpnService arkaly geçirýär.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Bulaňňylaşdyrmak"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Kartoçkalaryň dury dälligi",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Garaňkylatmak"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Surat sazlamalary",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Ýörite fony ulan",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("Suraty ýerleşdirmek"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Sygdyr"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Doldur"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Süýndür"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Keseligine ýerleşiş",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG, WebP ýa-da SVG formatyndaky dogry suraty saýlaň.",
    ),
    "wallpaperImageLabel": m195,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Kadr sazlamalary"),
    "wallpaperLibraryFull": m196,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Suratyň dury dälligi",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage(
      "Okamak aňsatlygy",
    ),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("Suraty aýyr"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Täsirleri başlangyja getir",
    ),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Kadry başlangyja getir",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Fony ýatda saklap bolmady. Öňki fon saklandy.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Masştab"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG ýa-da WebP · 20 MB-a çenli",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("Ýörite fon"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Ölçegi 20 MB-dan we piksel sany 50 milliondan geçmeýän suraty saýlaň.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Surat elýeterli däl",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Dikligine ýerleşiş",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV sazlamalary",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Web panel"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Giriş"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Panele giriş tamamlandy",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "Programmada",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "Brauzerde",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("Ýapyk"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Giriş ýerli we syry açar bilen goralýar. Paneli açmak, saklanan daşarky kontrolleýjiniň sazlamalaryny üýtgetmeýär.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Paneliň konfigurasiýasyny ulanyp bolmady.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "Ýüklenen faýl dogry panel arhiwi däl.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Ýadro giriş maglumatlaryny ret etdi. Paneli täzeden açyň.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "Brauzer girişi tamamlanýança ýa-da ReClash ýapylýança dowam edýär",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Başga panel amaly ýerine ýetirilýär.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Panel amaly ýatyryldy.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "Paneliň barlag jemi bellenen goýberilişe gabat gelenok.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ýadro taýýar däl.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Ýadrony dolandyrmak üçin ýerli web paneller",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Paneli ýükläp bolmady. Täzeden synanyşyň.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Panel ýüklenýär",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "Panel ýapylanda giriş tamamlanýar",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Panele girişi tamamla",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Panel arhiwi açylýar",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Panel"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage("Paneli gurna"),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Saýlanan panel ilkinji açylyşda ýüklenýär. Bellenen goýberiliş SHA-256 arkaly barlanýar.",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Brauzeri açyp bolmady.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Işjeň panel sessiýasy ýok",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Paneli açmazdan öň profili saýlaň.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Gurnalmadyk",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Paneli aç"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Brauzerde aç",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Täzeden ýükle"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "Paneli ulanmak üpjünçi tarapyndan öçürilen.",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "Howpsuz tertipde panele giriş öçürilen.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Panel faýllaryny howpsuz okap ýa-da çalşyp bolmady.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "Panel arhiwi rugsat berlen ölçegden uly.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Ýadro bu paneli hödürlänok.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Ýükleme barlanýar",
    ),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Wersiýa"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Ak sanaw usuly"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Ulgama ýazmak"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Ulgama ýazmak ulgam sagadyny hem düzýär; Android ony äsgermeýär.",
    ),
    "yearsAgo": m197,
    "yearsAgoShort": m198,
    "yes": MessageLookupByLibrary.simpleMessage("Hawa"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Ýeňilleşdirilen hytaý dili"),
  };
}
