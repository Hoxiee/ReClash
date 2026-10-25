// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '${count} sélectionnée', other: '${count} sélectionnées')}";

  static String m1(count) =>
      "Applications que votre fournisseur laisse hors du VPN : ${count}. Activez le contrôle d’accès pour modifier la liste.";

  static String m2(name) => "${name} ajouté aux proxys locaux";

  static String m3(name) => "${name} est déjà dans les proxys locaux";

  static String m4(count, skipped) =>
      "${count} à ajouter, ${skipped} ignorés car déjà présents";

  static String m5(detail) => "Impossible d’effacer les données : ${detail}";

  static String m6(code) =>
      "Windows a refusé d’exécuter ReClashCore.exe (erreur ${code}). Une stratégie de contrôle des applications, telle que Smart App Control ou AppLocker, bloque les programmes non signés ; autorisez ReClash dans cette stratégie ou désactivez-la, puis réessayez.";

  static String m7(name) =>
      "L’app n’a pas réussi à finir de démarrer deux fois de suite. Pour sortir de cette boucle, le profil ${name} a été désélectionné et la configuration automatique a été ignorée. Vous pouvez le sélectionner de nouveau à tout moment.";

  static String m8(url) => "Créer un profil à partir de ${url} ?";

  static String m9(groups) =>
      "include-all a été retiré des groupes de proxys ${groups} ; ajoutez les proxys ou fournisseurs de proxys qu’ils utilisent";

  static String m10(count, label) =>
      "${Intl.plural(count, one: '1 règle SUB-RULE a été abandonnée, car les profils personnalisés ne prennent pas en charge les sous-règles', other: '${label} règles SUB-RULE ont été abandonnées, car les profils personnalisés ne prennent pas en charge les sous-règles')}";

  static String m11(message) =>
      "Le cœur ne peut pas analyser ce proxy : ${message}";

  static String m12(proxy, target) =>
      "${proxy} se connecte via ${target}, qui renvoie à ${proxy} ; la connexion boucle";

  static String m13(name) =>
      "Le nom ${name} est déjà utilisé par un autre proxy ou groupe de proxys";

  static String m14(path) =>
      "Les groupes de proxys se référencent mutuellement en boucle : ${path}";

  static String m15(name) =>
      "Le repli si vide doit être un proxy, mais ${name} n’existe pas ou est un groupe de proxys";

  static String m16(name, message) =>
      "${name} n’est pas une regex valide : ${message}";

  static String m17(name) => "Le proxy de connexion ${name} n’existe pas";

  static String m18(names) =>
      "Ces fournisseurs de proxys n’existent pas : ${names}";

  static String m19(names) =>
      "Ces proxys ou stratégies n’existent pas : ${names}";

  static String m20(name) =>
      "${name} est un nom de stratégie intégré et ne peut pas être utilisé ici";

  static String m21(count) =>
      "${count} éléments posent problème, et l’application de ce profil peut échouer";

  static String m22(count) =>
      "${Intl.plural(count, one: 'il y a 1 jour', other: 'il y a ${count} jours')}";

  static String m23(count) =>
      "${Intl.plural(count, other: 'il y a ${count} j')}";

  static String m24(label) =>
      "Voulez-vous vraiment supprimer les éléments sélectionnés (${label}) ?";

  static String m25(label) =>
      "Voulez-vous vraiment supprimer cet élément (${label}) ?";

  static String m26(label) => "Détails de ${label}";

  static String m27(name) =>
      "La connexion via ${name} renvoie au proxy qui l’utilise ; la connexion a donc été arrêtée";

  static String m28(label) => "${label} ne peut pas être vide";

  static String m29(label) => "${label} existe déjà";

  static String m30(count) => "${count} éléments en échec";

  static String m31(label, message) => "${label} : ${message}";

  static String m32(name) => "${name} est déjà à jour";

  static String m33(name) => "${name} mis à jour";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 groupe', other: '${count} groupes')}";

  static String m35(count) => "${count} expirés";

  static String m36(action) =>
      "Déjà utilisé par « ${action} ». L’enregistrer le déplace ici.";

  static String m37(actions) => "Non exporté : ${actions}";

  static String m38(modifiers) =>
      "Incluez au moins l’une de ces touches : ${modifiers}";

  static String m39(count) =>
      "${Intl.plural(count, one: 'il y a 1 heure', other: 'il y a ${count} heures')}";

  static String m40(count) =>
      "${Intl.plural(count, other: 'il y a ${count} h')}";

  static String m41(target) => "${target} n’est pas une stratégie valide";

  static String m42(proxyName) => "${proxyName} n’est pas un proxy valide";

  static String m43(providerName) =>
      "${providerName} n’est pas un fournisseur de proxys valide";

  static String m44(ruleSet) => "${ruleSet} n’est pas un jeu de règles valide";

  static String m45(subRule) => "${subRule} n’est pas un SUB_RULE valide";

  static String m46(count) =>
      "${Intl.plural(count, one: '1 élément', other: '${count} éléments')}";

  static String m47(line, message) => "Ligne ${line} : ${message}";

  static String m48(appName) =>
      "1. Ouvrez Réglages système > Confidentialité et sécurité\n2. Choisissez Service de localisation\n3. Trouvez ${appName} dans la liste et cochez-le\n\nUne fois terminé, revenez dans l’app pour continuer. Merci de votre coopération.";

  static String m49(label, max) =>
      "${label} ne doit pas dépasser ${max} caractères";

  static String m50(size) => "${size} libérés";

  static String m51(count) =>
      "${Intl.plural(count, one: 'il y a 1 minute', other: 'il y a ${count} minutes')}";

  static String m52(count) =>
      "${Intl.plural(count, other: 'il y a ${count} min')}";

  static String m53(count) =>
      "${Intl.plural(count, one: 'il y a 1 mois', other: 'il y a ${count} mois')}";

  static String m54(count) =>
      "${Intl.plural(count, other: 'il y a ${count} m')}";

  static String m55(code) =>
      "Le serveur a refusé l’accès (HTTP ${code}). Le lien a peut-être expiré, ou les identifiants sont incorrects";

  static String m56(code) => "Le serveur a rejeté la requête (HTTP ${code})";

  static String m57(code) =>
      "Rien n’a été trouvé à cette adresse (HTTP ${code}). Vérifiez que l’URL est correcte";

  static String m58(detail) => "Échec de la requête réseau : ${detail}";

  static String m59(code) =>
      "Le serveur a rencontré un problème (HTTP ${code}). Réessayez plus tard";

  static String m60(label) => "Aucun élément (${label}) pour le moment";

  static String m61(label, min, max) =>
      "${label} doit être compris entre ${min} et ${max}";

  static String m62(label) => "${label} doit être un nombre";

  static String m63(label) => "${label} doit être compris entre 1024 et 49151";

  static String m64(port) => "Port ${port}";

  static String m65(added, skipped, failed) =>
      "Ajoutés : ${added} ; ignorés : ${skipped} ; échecs : ${failed}.";

  static String m66(days) =>
      "${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m67(date, days) =>
      "Expire le ${date}, ${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m68(name) => "Déjà ajouté sous le nom « ${name} »";

  static String m69(client) => "Tel que l’application ${client} le reçoit";

  static String m70(count) =>
      "${Intl.plural(count, one: '${count} serveur', other: '${count} serveurs')}";

  static String m71(time) => "Mis à jour ${time}";

  static String m72(label, profiles) =>
      "${label} est encore utilisé par ${profiles}, qui ne fonctionneront plus correctement s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m73(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxys')}";

  static String m74(name, count) => "${name} et autres (${count} proxys)";

  static String m75(removed) =>
      "Ces proxys seront supprimés : ${removed}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m76(removed, added) =>
      "Ces proxys seront supprimés : ${removed}. Ceux-ci seront ajoutés : ${added}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m77(label) =>
      "${label} est encore nommé par des règles, des groupes de proxys, des proxys de connexion, le DNS ou le NTP de ce profil, qui cesseront de fonctionner s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m78(count, label) =>
      "${Intl.plural(count, one: '1 groupe de proxys', other: '${label} groupes de proxys')}";

  static String m79(pick, now) => "Choisirait ${pick} au lieu de ${now}";

  static String m80(group) => "Vérification sur ${group}";

  static String m81(pick) => "Garderait ${pick}";

  static String m82(number) => "Condition ${number}";

  static String m83(profile) => "« ${profile} » veut vérifier ces sites";

  static String m84(count) =>
      "${Intl.plural(count, one: '${count} serveur', other: '${count} serveurs')}";

  static String m85(profile) => "Supprimer « ${profile} » ?";

  static String m86(requests, used, cap) =>
      "Vérifications aujourd’hui : ${requests} · ${used} sur ${cap}";

  static String m87(condition) => "sauf ${condition}";

  static String m88(country) => "sortie ${country}";

  static String m89(member) => "Via ${member}";

  static String m90(title) =>
      "« ${title} » ne peut pas être modifié. Vos changements iront dans une copie, qui deviendra le scénario actif.";

  static String m91(mode) =>
      "Les routes s’appliquent en mode règle ; la connexion est en mode ${mode}.";

  static String m92(profile) => "« ${profile} » ajouté";

  static String m93(node) => "${node} ne fonctionne plus";

  static String m94(from, to) => "Mode ${from} → ${to}";

  static String m95(count) =>
      "${Intl.plural(count, one: '${count} serveur correspond', other: '${count} serveurs correspondent')}";

  static String m96(ms) => "moins de ${ms} ms";

  static String m97(text) => "${text} dans le nom";

  static String m98(what) => "pas ${what}";

  static String m99(provider) => "de ${provider}";

  static String m100(number) => "Étape ${number}";

  static String m101(action) =>
      "Si aucune étape n’a de serveur qui fonctionne : ${action}";

  static String m102(tag) => "tag ${tag}";

  static String m103(line, text) => "Ligne ${line} : ${text}";

  static String m104(check) =>
      "La vérification ${check} n’est jamais utilisée, donc elle ne s’exécute jamais";

  static String m105(hosts) => "Contacte des sites tiers : ${hosts}";

  static String m106(group) =>
      "Cette configuration n\'a pas de groupe ${group}";

  static String m107(group) => "Aucun serveur de ${group} ne passe le filtre";

  static String m108(tag) => "L’étiquette ${tag} n’est jamais utilisée";

  static String m109(tier, group) =>
      "Aucun serveur de ${group} n’est actuellement dans « ${tier} »";

  static String m110(tier, after) =>
      "« ${tier} » répète la condition de « ${after} » ; rien n’y arrive donc";

  static String m111(name, count) => "${name} et ${count} de plus";

  static String m112(keys) =>
      "Repris ; vous avez aussi modifié ces éléments, les vôtres ont donc été conservés : ${keys}";

  static String m113(mode) => "Mode : ${mode}";

  static String m114(node) =>
      "Reste sur ${node} ; ne le quitte qu’en cas de panne et y revient quand il fonctionne à nouveau.";

  static String m115(kind) => "Réseau : ${kind}";

  static String m116(tier) =>
      "peut atteindre « ${tier} » après une vérification";

  static String m117(node) => "Épinglé : ${node}";

  static String m118(error) => "Erreur de profil : ${error}";

  static String m119(profile) =>
      "Profil ${profile} introuvable ; le profil par défaut est utilisé";

  static String m120(error) =>
      "Impossible d’enregistrer l’état du routage : ${error}";

  static String m121(tier) => "Passé à un serveur de « ${tier} »";

  static String m122(from) =>
      "Serveur changé ; ${from} est ignoré pendant 15 minutes";

  static String m123(from) =>
      "${from} ne fonctionne plus ; passage au meilleur serveur de secours";

  static String m124(from, gain) => "Quitté ${from} : ${gain} ms plus rapide";

  static String m125(node) => "Le scénario maintient ${node}";

  static String m126(node) => "${node} n\'est pas dans ce groupe";

  static String m127(limit) =>
      "Limite de changements atteinte (${limit} par heure)";

  static String m128(mode) => "Inutilisé : mode ${mode}";

  static String m129(from) =>
      "${from} ne fait plus partie des serveurs retenus";

  static String m130(kind) =>
      "En pause tant que le réseau est « ${kind} » : rien n’est vérifié ni changé";

  static String m131(route, error) =>
      "Impossible d’appliquer la route « ${route} » : ${error}";

  static String m132(route) =>
      "La route « ${route} » a été ignorée : un groupe porte déjà ce nom.";

  static String m133(route, to) =>
      "La route « ${route} » envoie le trafic vers « ${to} », absent du profil.";

  static String m134(node) => "Le scénario bascule sur ${node}";

  static String m135(node) => "Passé au serveur épinglé ${node}";

  static String m136(node) => "Aucun serveur ne fonctionne ; repli sur ${node}";

  static String m137(scenario) =>
      "Une route du scénario « ${scenario} » a créé ce groupe. Modifiez-la ou supprimez-la là-bas.";

  static String m138(scenario) =>
      "Le scénario « ${scenario} » pilote ce groupe en ce moment.";

  static String m139(count, total) => "${count} sur ${total} correspondent";

  static String m140(node) =>
      "Passera à ${node} dès qu’une vérification le confirme";

  static String m141(node, gain) =>
      "Passera à ${node} s’il reste ${gain} ms plus rapide";

  static String m142(node, minutes) =>
      "Pourra passer à ${node} dans ${minutes} min";

  static String m143(name) => "vérification ${name}";

  static String m144(name) => "diagnostic réseau ${name}";

  static String m145(count) =>
      "${Intl.plural(count, one: '${count} serveur comparé', other: '${count} serveurs comparés')}";

  static String m146(count) =>
      "${Intl.plural(count, one: 'Il choisit parmi ${count} serveur de ce groupe.', other: 'Il choisit parmi les ${count} serveurs de ce groupe.')}";

  static String m147(region, bypassed, proxied) =>
      "${region} : ${bypassed} applications dans la liste d’exclusion du VPN, ${proxied} dans la liste VPN. Les deux listes seront remplacées ; le mode et les autres réglages restent inchangés. Les correspondances de paquets et SDK sont des suggestions : vérifiez le résultat après application.";

  static String m148(seconds) => "Confirmation possible dans ${seconds} s";

  static String m149(count, label) =>
      "${Intl.plural(count, one: '1 règle', other: '${label} règles')}";

  static String m150(appName) => "${appName} (mode sans échec)";

  static String m151(count) =>
      "${Intl.plural(count, one: '1 seconde', other: '${count} secondes')}";

  static String m152(count) => "${count} actifs";

  static String m153(count) =>
      "${Intl.plural(count, one: '1 problème', other: '${count} problèmes')}";

  static String m154(count) =>
      "${Intl.plural(count, one: '1 réglage', other: '${count} réglages')}";

  static String m155(count) => "Applications hors VPN : ${count}";

  static String m156(count) => "${count} profils disponibles";

  static String m157(step, total) => "${step} sur ${total}";

  static String m158(server) => "Essayer ${server}";

  static String m159(link) => "Aucun proxy n’a pu être lu dans ${link}";

  static String m160(count) =>
      "${Intl.plural(count, one: '1 jour', other: '${count} jours')}";

  static String m161(delay) => "${delay} ms";

  static String m162(service) => "${service} bloque cette adresse";

  static String m163(service) => "${service} n’est pas encore disponible ici";

  static String m164(service) =>
      "${service} n’affiche ici que ses propres titres";

  static String m165(service) => "${service} fonctionne avec des limites";

  static String m166(service) => "${service} ne s’ouvre pas";

  static String m167(service) => "${service} ne fonctionne pas dans ce pays";

  static String m168(size) =>
      "Télécharge environ ${size} sans le VPN, uniquement quand vous appuyez.";

  static String m169(size) =>
      "Télécharge environ ${size} via le VPN, uniquement quand vous appuyez.";

  static String m170(network) => "Réseau de confiance « ${network} »";

  static String m171(total) => "restants sur ${total}";

  static String m172(date) => "jusqu’au ${date}";

  static String m173(label) => "${label} doit être un seul élément";

  static String m174(client, format, count) =>
      "Reçu comme ${client} : ${format}, ${count} nœuds proxy.";

  static String m175(count) =>
      "${Intl.plural(count, one: 'Votre abonnement expire demain', other: 'Votre abonnement expire dans ${count} jours')}";

  static String m176(count) =>
      "${Intl.plural(count, one: 'Ajouter 1 serveur', other: 'Ajouter ${count} serveurs')}";

  static String m177(count) =>
      "${Intl.plural(count, one: 'Le serveur sera ajouté', other: 'Les ${count} serveurs seront ajoutés')}";

  static String m178(count, total) =>
      "${count} ${Intl.plural(total, one: 'serveur sur 1', other: 'serveurs sur ${total}')} seront ajoutés";

  static String m179(count) => "Tout afficher (${count})";

  static String m180(format) => "Format : ${format}";

  static String m181(percent) =>
      "Vous avez utilisé ${percent}% de votre trafic";

  static String m182(count) => "${count} résultats";

  static String m183(value) => "Pic ${value}";

  static String m184(value) => "Total ${value}";

  static String m185(transport) => "En-têtes ${transport}";

  static String m186(version) => "Version installée : ${version}";

  static String m187(count) => "${count} min";

  static String m188(time) => "Encore ${time}";

  static String m189(count) => "${count} s";

  static String m190(speed) => "${speed}/s";

  static String m191(nodes, groups, providers) =>
      "${nodes} proxys, ${groups} groupes, ${providers} fournisseurs distants";

  static String m192(action) =>
      "Ce lien demande « ${action} ». Autoriser ReClash à effectuer cette action ?";

  static String m193(name, source) =>
      "Importer « ${name} » depuis ${source} ? La validation du profil et la vérification des conversions suivront votre confirmation.";

  static String m194(label) => "${label} doit être une URL";

  static String m195(index) => "Fond ${index}";

  static String m196(count) =>
      "Vous pouvez conserver jusqu’à ${count} fonds. Supprimez-en un pour en ajouter un autre.";

  static String m197(count) =>
      "${Intl.plural(count, one: 'il y a 1 an', other: 'il y a ${count} ans')}";

  static String m198(count) =>
      "${Intl.plural(count, other: 'il y a ${count} a')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Contrôle d’accès"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Seules les apps sélectionnées passent par le VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle d’accès choisit les apps qui utilisent le proxy.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle d’accès des apps est désactivé",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Les apps sélectionnées sont exclues du VPN",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Réglages du contrôle d’accès",
    ),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Rendre les applications au fournisseur",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Compte"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Tester tous les délais",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Mode direct"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Mode global"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Changer de mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Proxy système"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Mode règles"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Démarrer/Arrêter"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour les profils",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Afficher/Masquer"),
    "add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Ajouter un proxy"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Ajouter des filtres"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Ajouter un réseau"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Ajouter des nœuds"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Ajouter une entrée de remplacement",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Ajouter un profil"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Ajouter un groupe de proxys",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Ajouter une règle"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage(
      "Ajouter un réglage",
    ),
    "addSsid": MessageLookupByLibrary.simpleMessage("Ajouter un SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Ajouter aux proxys locaux",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Règles ajoutées"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Paramètres supplémentaires",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Préfixe du nom"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Suffixe du nom"),
    "address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "Adresse du serveur WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une adresse WebDAV valide",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration avancée",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "La configuration avancée regroupe le réseau, le DNS, les règles ajoutées et les scripts.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Profil chiffré",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Clé secrète age"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Ce profil est chiffré avec age et nécessite une clé secrète age pour être déchiffré",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Accepter"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Tous les proxys référencés",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Tous les fournisseurs de proxys référencés",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Autoriser les apps à contourner le VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Autoriser le LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("IP autorisées"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("Réponses"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle d’accès des apps",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Icône de l’app"),
    "appIconApply": MessageLookupByLibrary.simpleMessage(
      "Utiliser cette icône",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Plan"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "L’écran d’accueil peut mettre quelques secondes à afficher la nouvelle icône, et certains lanceurs suppriment le raccourci : ajoutez-le de nouveau depuis la liste des applications.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Circuit"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Conception de l’icône de l’app",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Écho"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Encre"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Éclats"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Solaire"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Étincelle"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Strates"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Topo"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Trace"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Velours"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy local",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage(
      "Région de l’application",
    ),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Fond"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Interface"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Thème"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Ajouter le DNS du système",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de l’application",
    ),
    "applied": MessageLookupByLibrary.simpleMessage("Appliqué"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Appliquer maintenant"),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentification"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "L’authentification demande un nom d’utilisateur et un mot de passe sur le port du proxy local.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Le proxy système n’est pas appliqué tant que l’authentification est activée.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Autoriser"),
    "authorized": MessageLookupByLibrary.simpleMessage("Autorisé"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Rechercher les mises à jour automatiquement",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Fermer les connexions automatiquement",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "La fermeture automatique coupe les connexions ouvertes lorsque vous changez de proxy.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage(
      "Inclure automatiquement",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Lancement automatique"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Démarrage automatique"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Le démarrage automatique active le proxy à l’ouverture de l’app.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Définir automatiquement le DNS du système",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage(
      "Mise à jour automatique",
    ),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de mise à jour automatique",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Retour"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage(
      "Flou d’arrière-plan",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Sauvegarde"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Sauvegarde et restauration",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Cette sauvegarde provient d’une version plus récente de l’app. Mettez l’app à jour avant de la restaurer",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Sauvegarde réussie"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Infos de base"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Stratégies de base"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Ajout groupé"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Importation groupée"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Un lien par ligne",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Un élément par ligne, ou séparés par des virgules",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Une entrée par ligne : la clé, un espace, puis la valeur",
    ),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Une URL par ligne",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Ignorer l’optimisation de la batterie maintient l’app active en arrière-plan.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Lier"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Mode liste noire"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Bloquer la connexion",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Luminosité"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Domaines contournés"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Les domaines contournés ne s’appliquent que si le proxy système est activé.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Contourner les adresses privées",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Avec « Contourner les adresses privées » activé, les adresses LAN, de bouclage et multicast ne passent pas par TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage(
      "Algorithme de cache",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Le cache est corrompu. Le vider ?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Taille du cache"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Autorisez l’accès à l’appareil photo dans les réglages du système pour scanner des codes QR, ou choisissez une image de code QR dans l’album.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de l’appareil photo requise",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Appareil photo indisponible",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Tout désélectionner",
    ),
    "cannotSave": MessageLookupByLibrary.simpleMessage(
      "Enregistrement impossible",
    ),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Échec du changement de proxy ; la sélection précédente a été rétablie",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Changements majeurs",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Nouveautés"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage(
      "Corrections de bugs",
    ),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage(
      "Performances",
    ),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Annulations"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Vérifier les certificats TLS",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Sans vérification TLS, les abonnements et les sauvegardes sont exposés aux attaques de l’homme du milieu.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage(
      "Rechercher des mises à jour",
    ),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "L’app est déjà à jour",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Chiffrement"),
    "clearData": MessageLookupByLibrary.simpleMessage("Effacer les données"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Cela supprime tous les profils, réglages et données locales, puis ferme l’app. Rouvrez-la pour repartir de zéro.",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("Vider le cache DNS"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "Échec du vidage du cache DNS",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Effacer la recherche"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Empreinte client",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Exporter vers le presse-papiers",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Importer depuis le presse-papiers",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de copier dans le presse-papiers. La sélection est peut-être trop volumineuse",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Fermer"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Fermer les connexions",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Fermer toutes les connexions quand la VPN se met en pause",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Couleur"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Contraste"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Style de couleur"),
    "columns": MessageLookupByLibrary.simpleMessage("Colonnes"),
    "compact": MessageLookupByLibrary.simpleMessage("Compact"),
    "compatible": MessageLookupByLibrary.simpleMessage("Mode de compatibilité"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment effacer toutes les données ?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment supprimer ce groupe de proxys ?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment quitter la fenêtre actuelle ?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment forcer le plantage du cœur ?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle de congestion",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Contrôle de congestion TCP",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle de congestion TCP ne fonctionne qu’avec la pile mips.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connecté"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connexion…"),
    "connection": MessageLookupByLibrary.simpleMessage("Connexion"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Statistiques de connexion",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Connexions en direct, requêtes récentes et requêtes DNS",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connexions"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivité : "),
    "content": MessageLookupByLibrary.simpleMessage("Contenu"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Le contenu ne peut pas être vide",
    ),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Élevé"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Moyen"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Gérer les règles ajoutées globales",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copier les variables d’environnement",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copier le lien"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copié avec succès"),
    "core": MessageLookupByLibrary.simpleMessage("Cœur"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Architecture"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control a bloqué ReClashCore.exe car il n’est pas signé. Ouvrez Sécurité Windows → Contrôle des applications et du navigateur → Paramètres de Smart App Control, choisissez Désactivé, puis relancez ReClash. Smart App Control ne peut pas être réactivé sans réinstaller Windows.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage(
      "Options de compilation",
    ),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage(
      "Date de compilation",
    ),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Environnement"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage(
      "Exécutable du Core",
    ),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire les informations du Core",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Mode d’exécution"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Emplacement"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Processus élevé géré",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Processus via Helper",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Bibliothèque intégrée au processus",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Processus géré via un Helper signé",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("Processus séparé"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Ouvrir la configuration d’exécution",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Plateforme"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("En cours d’exécution"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration d’exécution",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Configuration générée après application des paramètres et scripts. Lecture seule.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire la configuration d’exécution",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Démarrage…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("État du cœur"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Arrêté"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Dossier de données",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Région"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Plantage détecté"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("Test de plantage"),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("Date de création"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("Contournement DPI"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Client de base"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Fonctions supplémentaires",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Fonctions et idées pour les fournisseurs",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Cœur du proxy"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Contient le bouton de démarrage et ne peut pas être retiré",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "customColor": MessageLookupByLibrary.simpleMessage(
      "Couleur personnalisée",
    ),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "Le nom est vide",
    ),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy ni fournisseur de proxys n’est sélectionné ; le cœur rejette donc ce groupe",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Ressources des profils personnalisés",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Les ressources des profils personnalisés sont les proxys, fournisseurs de règles, filtres et jeux d’icônes que vous ajoutez vous-même pour les profils personnalisés.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Couper"),
    "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Tableau de bord"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Disponibles à l’ajout",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Tableau de bord"),
    "dashboardStyleDetailed": MessageLookupByLibrary.simpleMessage("Détaillé"),
    "dashboardStyleSimple": MessageLookupByLibrary.simpleMessage("Simple"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Échec de l’enregistrement de la modification ; elle a été annulée",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Sélection par défaut",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Par défaut"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "La configuration doit être un mappage YAML avec un nom et un type",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Délai"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Test de délai"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Délai d’expiration du test de latence",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Un client proxy multiplateforme basé sur ClashMeta, simple d’utilisation, open source et sans publicité.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Aucun agent d’autorisation graphique n’est disponible. Démarrez-en un dans cette session de bureau, puis réessayez.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "L’autorisation a été annulée. TUN n’a pas démarré.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "L’autorisation n’a pas été accordée. TUN n’a pas démarré.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN nécessite une autorisation. Démarrez la connexion ou activez TUN pour l’autoriser.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Le délai d’autorisation a expiré. Réessayez avec le bouton de connexion.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "Le Core autorisé n’a pas pu terminer un démarrage vérifié. Vérifiez le paquet et les journaux système.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core ou Helper a échoué à la vérification d’intégrité. Réinstallez un paquet ReClash complet.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisez le Helper ReClash dans Réglages Système → Général → Ouverture et extensions, puis réessayez.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "Le Helper installé utilise un autre protocole. Vérifiez s’il existe une autre installation ou une surcharge du service, puis réinstallez le paquet complet.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "L’enregistrement existant du Helper Linux ne peut pas être remplacé en toute sécurité. Vérifiez l’appartenance du service et son enregistrement ; une nouvelle autorisation ne résoudra pas ce conflit.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd n’a pas pu démarrer le Helper TUN. Consultez le journal du service ; le programme d’installation a tenté de restaurer l’installation précédente.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN nécessite une session Linux gérée par systemd. Ce système ne peut pas exécuter le Helper réseau.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Le Helper TUN est indisponible. Vérifiez le paquet installé et le service, puis réessayez.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "L’autorisation ou l’arrêt précédent de Core est toujours en cours. Attendez sa fin avant de réessayer.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN nécessite une app ReClash et un Helper correctement signés. Une version non signée ou signée ad-hoc ne peut pas être autorisée.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core a démarré, mais l’adaptateur TUN n’est pas prêt. Vérifiez le journal Core avant d’utiliser TUN.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP de destination",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN de l’IP de destination",
    ),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Repose sur une API tierce ; à titre indicatif uniquement",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Mode développeur"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Le mode développeur est activé.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Proxy de connexion"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Le proxy de connexion est la sortie utilisée pour joindre le serveur NTP.",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Désactiver le transfert ICMP",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "Avec le transfert ICMP désactivé, TUN répond lui-même au ping, qui n’indique donc plus la latence réelle.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Désactiver le keep-alive TCP",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Désactiver UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Abandonner les modifications ?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Avertissement"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "En installant, copiant ou utilisant le Logiciel, vous êtes réputé avoir lu et accepté l’intégralité de cette déclaration. Si vous n’êtes pas d’accord avec l’une de ses conditions, cessez immédiatement d’utiliser le Logiciel et désinstallez-le.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage(
      "Acceptation",
    ),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "J\'ai lu et compris cette déclaration",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Pour confirmer que vous avez compris, lisez la déclaration suivante et cochez la case ci-dessous :",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Confirmer la déclaration",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Les développeurs peuvent réviser cette déclaration à chaque version, et la révision prend effet à la publication de cette version. Continuer à utiliser le Logiciel après une mise à jour signifie que vous acceptez la déclaration révisée.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Modifications de cette déclaration",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Avant d’utiliser ReClash (« le Logiciel »), veuillez lire attentivement cette déclaration et vous assurer de l’avoir comprise dans son intégralité. Appuyer sur « Accepter » signifie que vous avez lu, compris et accepté chacune des conditions ci-dessous. Si vous n’êtes pas d’accord, appuyez sur « Quitter » et cessez d’utiliser le Logiciel.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "Dans toute la mesure permise par la loi applicable, ni les développeurs ni aucun contributeur ne sauraient être tenus responsables de dommages directs, indirects, accessoires, spéciaux, punitifs ou consécutifs résultant de l’utilisation ou de l’impossibilité d’utiliser le Logiciel, y compris, sans s’y limiter, la perte de données, les dommages matériels, les pannes réseau, l’interruption d’activité, le manque à gagner ou tout litige qui en découlerait, même s’ils ont été avertis de la possibilité de tels dommages.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Limitation de responsabilité",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est open source sous licence GPL-3.0. Vous pouvez l’utiliser, le modifier et le distribuer librement tant que vous respectez cette licence, qui exige que les œuvres dérivées soient elles aussi publiées sous GPL-3.0 et que les mentions de droit d’auteur d’origine soient conservées.\n\nLes composants tiers du Logiciel, dont le cœur Clash.Meta, suivent leurs propres licences. Les auteurs d’origine ne sont pas responsables des problèmes liés aux versions modifiées ou redistribuées.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Licence open source",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel ne fournit lui-même aucun serveur proxy, nœud, abonnement ni service d’accès au réseau, et n’a aucun partenariat, mandat ni lien de garantie avec un quelconque fournisseur de tels services.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel ne collecte ni ne transmet vos URL d’abonnement, détails de nœuds, contenus de configuration, sites visités, historiques de connexion, contenus de trafic ou journaux. Ces données restent sur votre appareil et les développeurs n’y ont pas accès.\n\nLe Logiciel n’accède au réseau que lorsque vous utilisez une fonction qui en a besoin, par exemple pour récupérer l’URL d’abonnement que vous avez fournie lors de la mise à jour d’un profil, ou pour contacter GitHub lors de la recherche de mises à jour.\n\nLe Logiciel n’inclut aucun service d’analyse ni de rapport de plantage, sur aucune plateforme.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Collecte de données et confidentialité",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Lire jusqu’à la fin",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Il vous incombe de vous assurer que l’utilisation du Logiciel est licite là où vous vivez, et vous assumez seul la responsabilité juridique de tout ce que vous faites avec lui et de ses conséquences.\n\nLes abonnements, nœuds et configurations que vous importez relèvent de votre choix. La licéité de leur source, la sécurité de leur contenu et la fiabilité de leur service sont une affaire entre vous et leurs fournisseurs.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Votre responsabilité",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Saisissez la déclaration ci-dessus",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Ne correspond pas à la déclaration",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Pour confirmer que vous avez compris, saisissez la déclaration suivante en entier dans le champ ci-dessous :",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Recopier la déclaration",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est un client proxy réseau open source construit sur le cœur Clash.Meta (mihomo). Il se limite à fournir des outils locaux tels que la gestion de la configuration, le routage par règles et le transfert du trafic.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Nature du logiciel",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Les liens d’abonnement, fichiers de configuration, jeux de règles, scripts, ressources externes et liens externes sont tous fournis par des tiers. Les développeurs ne peuvent ni ne vont vérifier ou garantir leur légalité, leur exactitude, leur sécurité ou leur disponibilité.\n\nTout vol de données, perte financière, bannissement de compte ou autre dommage causé par un contenu tiers se règle entre vous et le tiers concerné ; les développeurs n’en assument aucune responsabilité.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Contenus tiers",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est destiné uniquement à des usages non commerciaux tels que l’apprentissage, les échanges et la recherche technique. Toute utilisation à des fins commerciales est strictement interdite, y compris, sans s’y limiter, la distribution payante, la vente groupée, l’intégration à un service commercial ou l’exercice d’une activité au nom du Logiciel. Toute activité commerciale est étrangère au Logiciel et à ses développeurs.\n\nIl est strictement interdit d’utiliser le Logiciel à des fins contraires aux lois et règlements de votre pays ou de votre région, y compris, sans s’y limiter, le contournement de restrictions d’accès au réseau légalement imposées, la diffusion de contenus illicites, le lancement d’attaques réseau ou l’atteinte aux droits légitimes d’autrui.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Restrictions d’utilisation",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est fourni « tel quel » et « selon disponibilité », sans garantie d’aucune sorte, expresse ou implicite, y compris, sans s’y limiter, les garanties de qualité marchande, d’adéquation à un usage particulier, d’absence de contrefaçon, de disponibilité ininterrompue, d’absence d’erreurs ou d’absence de failles de sécurité.\n\nLes développeurs ne garantissent pas que le Logiciel répondra à vos besoins ni qu’il fonctionnera sans interruption ni erreur.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Absence de garantie",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Déconnecté"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Nouvelle version disponible",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("Cache DNS vidé"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Sans cette entrée, TUN détourne toutes les requêtes DNS vers le port 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Détournement DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Mode DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent le DNS de tous les profils URL et fichier ; tout ce qui n’est pas ajouté garde le réglage du profil. Les profils personnalisés définissent leur DNS dans leur contenu.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("Requêtes DNS"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Toutes les substitutions DNS sont supprimées et les serveurs DNS de la région sélectionnée sont rétablis.",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Ancrée"),
    "domain": MessageLookupByLibrary.simpleMessage("Domaine"),
    "done": MessageLookupByLibrary.simpleMessage("Terminé"),
    "download": MessageLookupByLibrary.simpleMessage("Réception"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Bande passante de réception",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Téléchargement de la mise à jour",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Durée"),
    "edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "editDashboard": MessageLookupByLibrary.simpleMessage(
      "Modifier le tableau de bord",
    ),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Modifier les règles globales",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Modifier le réseau"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Modifier le proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Modifier le groupe de proxys",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Modifier la règle"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Modifier le SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Éditeur indisponible",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Durée"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Repli si vide"),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("Anglais"),
    "enabled": MessageLookupByLibrary.simpleMessage("Activé"),
    "enterManually": MessageLookupByLibrary.simpleMessage(
      "Saisir manuellement",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" entrées"),
    "error": MessageLookupByLibrary.simpleMessage("Erreur"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Détails de l’erreur"),
    "es": MessageLookupByLibrary.simpleMessage("Espagnol"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Masquer des tâches récentes",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Ports de destination exclus",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic vers les ports de destination exclus ne passe pas par TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Filtre d’exclusion"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces exclues",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic qui arrive sur les interfaces exclues, par exemple docker0, ne passe pas par TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Ports source exclus",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic issu des ports source exclus ne passe pas par TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("SSID exclus"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Lorsque vous êtes connecté à un Wi-Fi dont le SSID est exclu, l’état d’exécution de l’app change automatiquement.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("ID utilisateur exclus"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic des processus des ID utilisateur exclus ne passe pas par TUN.",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("Quitter"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Quitter le plein écran",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Nœuds de sortie"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Statut attendu"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Date d’expiration"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Exporter le fichier"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Exporter les journaux"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportation réussie",
    ),
    "extend": MessageLookupByLibrary.simpleMessage("Extension"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Mode d’extension"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Script d’extension"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Contrôleur externe",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôleur externe permet de piloter le cœur via le port 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Secret du contrôleur externe",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Lien externe"),
    "extra": MessageLookupByLibrary.simpleMessage("Supplémentaire"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Très grande"),
    "fade": MessageLookupByLibrary.simpleMessage("Fondu"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Filtre Fake-IP"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Mode du filtre Fake-IP",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "En mode filtre Fake-IP, la liste noire exclut les correspondances, la liste blanche ne falsifie que les correspondances, et « rule » les traite comme des règles.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Plage Fake-IP"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Plage Fake-IP (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("TTL Fake-IP"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Filtre de repli"),
    "file": MessageLookupByLibrary.simpleMessage("Fichier"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Le fichier a été modifié. Enregistrer les modifications ?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtres"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage(
      "Recherche de processus",
    ),
    "floating": MessageLookupByLibrary.simpleMessage("Flottante"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Suivre le profil"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Suivre le système"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Police"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Taille"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Forcer le mappage DNS",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Forcer le mappage DNS analyse aussi les connexions dont le domaine provient d’un mappage DNS.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Domaines forcés"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Les domaines forcés sont aussi analysés ; les autres connexions qui ont déjà un domaine sont laissées telles quelles.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment forcer le redémarrage du cœur ?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Français"),
    "general": MessageLookupByLibrary.simpleMessage("Général"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent le réglage correspondant de tous les profils ; tout ce qui n’est pas ajouté garde le réglage du profil, ou la valeur par défaut du cœur si le profil n’en a pas.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Mode Geo à faible mémoire",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Aller"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Télécharger"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Aller à la configuration des règles ajoutées",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Aller à la configuration du script",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Remerciements"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash existe grâce à leur travail",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Grille"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groupes"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Mettre les modifications en cache ?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Hachage par utilisateur entrant",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Contrôle d’état"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Service Helper indisponible ; le mode TUN ne peut pas être activé. Réinstallez ReClash pour le rétablir.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Masquer de la liste"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Masquer l’IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage(
      "Masquer le mot de passe",
    ),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Masquer les proxys expirés",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Ignorer les proxys dont le dernier test de délai a expiré",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Intervalle de saut"),
    "host": MessageLookupByLibrary.simpleMessage("Hôte"),
    "hostname": MessageLookupByLibrary.simpleMessage("Nom d’hôte"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Tout effacer"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Supprimer toutes les combinaisons de raccourcis ?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration du compositeur",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez aussi ajouter une ligne include à la configuration du compositeur. Ces fichiers suivent les combinaisons définies dans ReClash et sont temporairement vidés pendant l’enregistrement. La configuration du bureau n’est jamais modifiée automatiquement ; résolvez-y les conflits éventuels.",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Les raccourcis globaux fonctionnent même lorsque la fenêtre est masquée. Appuyez sur une action pour enregistrer sa combinaison de touches.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Raccourcis du bureau",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Associez une commande à un raccourci personnalisé dans les paramètres du bureau. ReClash doit être en cours d’exécution, mais sa fenêtre peut rester masquée. Gérez ces raccourcis globaux dans les paramètres du bureau.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Les fichiers de configuration du compositeur ne sont pas disponibles. Vous pouvez toujours utiliser les commandes du bureau ci-dessus.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Ces combinaisons fonctionnent lorsque la fenêtre de l’application est active. Pour les raccourcis globaux, associez les commandes du bureau ci-dessous.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Gestion des raccourcis",
    ),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Non défini"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Rétablir les valeurs par défaut",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Remplacer toutes les combinaisons par les valeurs par défaut ?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "Le mode sans échec désactive les actions des raccourcis ; les combinaisons restent modifiables.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Non enregistré, il est peut-être pris par une autre app",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("heures"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("Teinte"),
    "icon": MessageLookupByLibrary.simpleMessage("Icône"),
    "iconRecords": MessageLookupByLibrary.simpleMessage(
      "Historique des icônes",
    ),
    "iconSets": MessageLookupByLibrary.simpleMessage("Jeux d’icônes"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Aucun jeu d’icônes pour le moment. Ajoutez-en dans Ressources des profils personnalisés → Jeux d’icônes",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Style des icônes"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Pleines"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Masquées"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Simples"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL de l’icône"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignorer l’optimisation de la batterie",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importer"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Ce fichier n’est pas une configuration importable",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "L’importation remplace les groupes de proxys, les règles et les réglages actuels de ce profil",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage(
      "Importer depuis un fichier",
    ),
    "importFromLink": MessageLookupByLibrary.simpleMessage(
      "Importer depuis un lien",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage(
      "Importer depuis une URL",
    ),
    "inbound": MessageLookupByLibrary.simpleMessage("Entrant"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces incluses",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Seul le trafic arrivant sur les interfaces incluses passe par TUN, et les interfaces exclues ne s’appliquent plus.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("ID utilisateur inclus"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Seul le trafic des processus des ID utilisateur inclus passe par TUN.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("N’expire jamais"),
    "init": MessageLookupByLibrary.simpleMessage("Initialisation"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Échec du démarrage"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash a rencontré une erreur au démarrage et ne peut pas continuer. Copiez les détails pour signaler le problème. Si cela se reproduit, effacer les données permet généralement de relancer l’app.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Initiateur"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("De"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Saisissez le nom du groupe de proxys",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez le contenu de la règle",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage(
      "Installer la mise à jour",
    ),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "L’autorisation de la liste des apps a été refusée ; les apps installées ne peuvent donc pas être listées. Veuillez l’accorder manuellement dans les réglages du système.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Ce système masque la liste des apps installées tant que l’autorisation n’est pas accordée. Accordez-la pour configurer le proxy par app.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de la liste des apps requise",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Polices installées",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Sélection intelligente",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Nom de l’interface"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Le nom de l’interface est l’interface réseau utilisée par les connexions sortantes.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Interface sortante",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Aucune"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage(
      "Personnalisée",
    ),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Suivre la configuration",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Intervalle"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP du réseau local"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Fichier de sauvegarde non valide",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez une plage d’IP au format CIDR, par exemple 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "Une marque DSCP ne peut pas dépasser 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez un domaine ou une adresse IP",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Jeu d’icônes non valide",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Ce n’est ni un lien d’abonnement ni un lien de partage de proxy",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez une adresse et un port, par exemple 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Seuls tcp ou udp sont pris en charge",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez un port ou une plage, par exemple 443 ou 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Ce code QR ne contient pas de lien de profil",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez des nombres ou des plages tels que 80 ou 8000-9000, séparés par /",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "Un SSID ne peut dépasser 32 octets UTF-8",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("Adresse IP"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Antécédents d’abus"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Indicateurs"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organisation"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de déterminer le type de l’IP",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Bonne"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Niveau"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normale"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage(
      "Vérifier à nouveau",
    ),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("À risque"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Qualité"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Réponse de"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Sources"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "IP sortante différente",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Aucun type"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Limite de débit atteinte",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Type"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Entreprise"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Centre de données"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Réseau mobile"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Résidentielle"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Type inconnu"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("Version d’IP"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Le trafic IPv6 n’est reçu que si IPv6 est activé.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Avec IPv6 activé, le VPN autorise le trafic IPv6 entrant.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "Délai d’expiration IPv6 (ms)",
    ),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("Japonais"),
    "justNow": MessageLookupByLibrary.simpleMessage("À l’instant"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "Inactivité keep-alive TCP",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Intervalle keep-alive TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Clé"),
    "kk": MessageLookupByLibrary.simpleMessage("Kazakh"),
    "ko": MessageLookupByLibrary.simpleMessage("Coréen"),
    "label": MessageLookupByLibrary.simpleMessage("Libellé"),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "large": MessageLookupByLibrary.simpleMessage("Grande"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Dernière mise à jour"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Démarrage inachevé",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "L’app s’est arrêtée de façon inattendue lors de son dernier démarrage. La configuration automatique a été ignorée pour ce lancement ; vous pouvez la démarrer manuellement pour réessayer.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Disposition"),
    "license": MessageLookupByLibrary.simpleMessage("Licence"),
    "licenses": MessageLookupByLibrary.simpleMessage("Licences"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Paquets inclus dans l\'application",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Clair"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Retour à la ligne"),
    "link": MessageLookupByLibrary.simpleMessage("Lien"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("Liste"),
    "listen": MessageLookupByLibrary.simpleMessage("Écoute"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Marque de routage d’écoute",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "La marque de routage d’écoute ne fonctionne que sous Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Connexions en direct",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Chargement…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localImage": MessageLookupByLibrary.simpleMessage("Image locale"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Autorisation du réseau local refusée : la pile gvisor est utilisée, le LAN est inaccessible.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Proxys locaux"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Autorisation de localisation",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "L’autorisation de localisation a été refusée ; le nom du Wi-Fi actuel ne peut donc pas être lu. Veuillez l’activer manuellement dans les réglages du système.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Le système exige l’autorisation de localisation pour lire le nom du Wi-Fi. Sur Android, choisissez « Toujours autoriser », sinon le nom du Wi-Fi ne peut pas être lu lorsque l’app est en arrière-plan.",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de localisation requise",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Journal"),
    "logLevel": MessageLookupByLibrary.simpleMessage(
      "Niveau de journalisation",
    ),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Désactiver Logcat masque l’entrée Journaux.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Journaux"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Journaux et diagnostic",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Test des journaux"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Exemption de bouclage UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Aérée"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Mainteneur"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Respecter la casse"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Faire correspondre l’IP source",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Échecs maximum"),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("Agrandir"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Mémoire résidente",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App et partagée"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Tas inactif"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Tas utilisé"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Le cœur n’est pas en cours d’exécution",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Surcharge du runtime",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage(
      "Piles de goroutines",
    ),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimation d’après la mémoire résidente du processus ; elle peut différer de ce qu’indique le système.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Le cœur s’exécute dans le processus de l’app. Sa part est estimée à partir des statistiques du runtime, et le reste compte comme mémoire de l’app et partagée.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Infos mémoire"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Mémoire utilisée par l’app et le cœur",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Mémoire libérée"),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("Test de message"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Ceci est un message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Réduire"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Réduire à la fermeture",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Port mixte"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Icône monochrome"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("Plus"),
    "name": MessageLookupByLibrary.simpleMessage("Nom"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Barre inférieure",
    ),
    "navigationLabels": MessageLookupByLibrary.simpleMessage(
      "Libellés des onglets",
    ),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Toujours"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Jamais"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage("Active"),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Navigation"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Barre d’onglets",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Barre latérale",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Réseau"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "La requête a été annulée",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Impossible de se connecter au serveur. Vérifiez votre connexion réseau ou vos réglages de proxy",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Wi-Fi maison) ou sous-réseau (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Impossible de résoudre l’adresse du serveur. Vérifiez que l’URL est correcte et que le DNS fonctionne",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Nom du réseau"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Trop de requêtes (HTTP 429). Patientez un instant puis réessayez",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "La liste d’exclusions et le MTU TUN reviennent aux valeurs de la région sélectionnée.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Secret du réseau"),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Débit réseau"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Prise en charge du trafic",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "La requête a expiré. Vérifiez votre réseau ou votre proxy, puis réessayez",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Échec de la connexion sécurisée. Le certificat du serveur est peut-être invalide, ou la connexion est interceptée",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Type de réseau"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Résultat suivant"),
    "no": MessageLookupByLibrary.simpleMessage("Non"),
    "noData": MessageLookupByLibrary.simpleMessage("Aucune donnée"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Aucune information"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Ne plus me le rappeler",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Aucun réseau"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Apps sans réseau"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Ne pas résoudre l’IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Ne pas résoudre le nom d’hôte",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("Aucun résultat"),
    "nodes": MessageLookupByLibrary.simpleMessage("Nœuds"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Cette ressource externe n’est pas un fichier texte",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Aucun"),
    "notRunning": MessageLookupByLibrary.simpleMessage("À l’arrêt"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Le groupe de proxys actuel n’est pas sélectionnable",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Le réseau actuel ne fait pas partie des réseaux de confiance",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationActive": MessageLookupByLibrary.simpleMessage(
      "Protection active",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Ajouter un composant",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Groupe automatique",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Aucun groupe de serveurs disponible",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Composants de notification",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Composez la notification avec des données en direct.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun composant",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Ajoutez des composants pour afficher les données en direct.",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Contenu"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Serveur actuel",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Réception sur Android",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Vérification de l’accès aux notifications",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Les notifications ReClash sont bloquées",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Les notifications peuvent être reçues",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "Le canal du service est désactivé",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Le canal des rappels est désactivé",
        ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Masquer la vitesse à l’arrêt",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Masquer les détails sensibles sur l’écran verrouillé",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Utilise la confidentialité Android pour les notifications du service et les rappels. Les détails restent visibles une fois déverrouillé.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Détaillé affiche les informations en direct et le bouton Arrêter. Minimal affiche seulement l’état de protection.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Vitesse du réseau",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage(
      "Confidentialité",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("Rappels"),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "Le groupe choisi n’existe plus",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Canal du service",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Trafic de la session",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Canal des rappels d’abonnement",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Rappels d’abonnement",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Recevez un rappel avant l’expiration de votre abonnement ou l’épuisement du trafic.",
        ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Niveau de notification",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Détaillé",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Minimal",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de synchronisation (minutes)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP récupère l’heure auprès d’un serveur NTP au lieu de l’horloge système.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Ajoutez un profil pour commencer",
    ),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuscation"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Hôte d’obfuscation"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Mode d’obfuscation"),
    "obfsParam": MessageLookupByLibrary.simpleMessage(
      "Paramètre d’obfuscation",
    ),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe d’obfuscation",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("À la demande"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Ce sous-réseau couvre de nombreux réseaux",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Fermer les connexions",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "À la demande met le proxy en pause sur les Wi-Fi exclus.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("Arrêt complet"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Retirer TUN et fermer les ports proxy locaux pendant la pause. La surveillance du réseau continue pour reprendre automatiquement.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Mettre en pause"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Reprendre"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire les réseaux Wi-Fi. Réessayez ou saisissez un réseau.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "Exiger SSID et sous-réseau",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Si les deux types sont présents, un SSID et un sous-réseau doivent correspondre",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Ne compter que le trafic proxy",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Facultatif"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Autre"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Autres contributeurs",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Sortant"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Sortie"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("IP sortante"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Mode sortant"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Remplacer la destination",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Remplacer la destination se connecte au domaine détecté plutôt qu’à l’adresse d’origine.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Entrées de remplacement",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage(
      "Analyser les IP seules",
    ),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Analyser les IP seules inspecte les connexions qui ne portent qu’une adresse IP.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "paste": MessageLookupByLibrary.simpleMessage("Coller"),
    "peers": MessageLookupByLibrary.simpleMessage("Pairs"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage(
      "Choisir dans l’album",
    ),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Choisir un réseau"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Réseaux Wi-Fi à proximité",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun réseau Wi-Fi trouvé",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "La localisation est nécessaire pour lister les réseaux Wi-Fi",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Autorisez l’accès à la localisation pour voir les réseaux Wi-Fi à proximité, ou saisissez un réseau manuellement.",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Recherche de réseaux Wi-Fi…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Épingler la fenêtre"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Veuillez lier un WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un nom de script",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Veuillez importer un code QR valide",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage(
      "Chiffrement du plugin",
    ),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Hôte du plugin"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Mode du plugin"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe du plugin",
    ),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Chemin du plugin"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Nom d’utilisateur du plugin",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un autre port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Saut de port"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Clé prépartagée"),
    "preferred": MessageLookupByLibrary.simpleMessage("Préféré"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prérequis"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Appuyez à nouveau sur Retour pour quitter",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Appuyez sur une combinaison de touches",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Empêcher les abonnements en double",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Refuser un lien d\'abonnement déjà utilisé par un profil existant",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Aperçu"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Résultat précédent"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Clé privée"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Phrase secrète de la clé privée",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Processus"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Veuillez saisir un intervalle valide",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Veuillez saisir l’intervalle de mise à jour automatique",
        ),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Le profil a été modifié. Désactiver la mise à jour automatique ?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Chargement de la page d’abonnement…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "Téléchargement de l’abonnement…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Un profil avec cette URL d\'abonnement existe déjà",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "L’abonnement est chiffré ; la clé vous sera demandée lors de l’ajout.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Format de l’abonnement",
    ),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "Le meilleur format pour ReClash, choisi automatiquement",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "Du fournisseur",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Certaines parties ne sont pas prises en charge ; vous les examinerez avant l’ajout.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger la page d’abonnement. Vous pouvez quand même l’ajouter.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Serveurs"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Un seul serveur",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Nouvel abonnement",
    ),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "Rien n’a été ajouté. Vous pouvez choisir un autre format et réessayer.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Illimité"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Valable jusqu’au",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le nom du profil",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "S’applique uniquement à ce profil ; tout ce qui n’est pas ajouté utilise la valeur par défaut.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "S’applique uniquement à ce profil et prime sur les entrées de remplacement TUN des réglages réseau.",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une URL de profil valide",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir l’URL du profil",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profils"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Trier les profils"),
    "project": MessageLookupByLibrary.simpleMessage("Projet"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protocole"),
    "protocolParam": MessageLookupByLibrary.simpleMessage(
      "Paramètre du protocole",
    ),
    "protocolVersion": MessageLookupByLibrary.simpleMessage(
      "Version du protocole",
    ),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("Annonce"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "En savoir plus",
    ),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("Lire"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Avis"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "Du fournisseur",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Rendre au fournisseur",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Rendre les réglages au fournisseur",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Les réglages que vous avez modifiés suivent de nouveau l’abonnement",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Seuls les fournisseurs distants sont pris en charge",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Ressources externes"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxys"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Chaîne de proxys"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Groupe de proxys"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Le groupe de proxys est vide",
    ),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Les groupes s’affichent ici une fois le cœur démarré",
    ),
    "proxyGroupsCount": m78,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Fournisseurs de proxys",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Type de proxy"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Nettoyer le cache"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Clé publique"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Noir pur"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Mode noir pur"),
    "qrcode": MessageLookupByLibrary.simpleMessage("Code QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scannez un code QR pour obtenir un profil",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Ce lien est trop long pour un code QR. Utilisez Copier le lien.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Actions rapides"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Modification rapide"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Ajouter un groupe"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage(
      "Ajouter un type de réseau",
    ),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Ajouter un motif"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Ajouter une étiquette"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Avancé"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Ces parties s’éditent en YAML.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Tous les groupes"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("N’importe lequel"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle automatique",
    ),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Un scénario pilote toute la connexion : le mode sur chaque type de réseau et ce que fait chaque groupe. Les groupes qu\'il ne nomme pas gardent leur propre profil.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Revenir en automatique",
    ),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Équilibré"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Basé sur"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Comportement"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Reprendre les changements",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Vos modifications sont conservées",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage(
      "Changer de serveur",
    ),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Passer à"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Vérification"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Sur le groupe"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage(
      "Ne trouverait aucun serveur",
    ),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage(
      "ouvre les sites bloqués",
    ),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Vérifications"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Vérifications de disponibilité",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Ajouter une condition"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Toutes les conditions"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Toujours"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage(
      "N’importe quelle condition",
    ),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage(
      "N’importe quel serveur",
    ),
    "rcxCondAtLeast": MessageLookupByLibrary.simpleMessage("est au moins"),
    "rcxCondAtMost": MessageLookupByLibrary.simpleMessage("est au plus"),
    "rcxCondClause": m82,
    "rcxCondCountry": MessageLookupByLibrary.simpleMessage("Pays"),
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Champ"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Ignorer la casse",
    ),
    "rcxCondLess": MessageLookupByLibrary.simpleMessage("est inférieur à"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Correspondance"),
    "rcxCondMore": MessageLookupByLibrary.simpleMessage("est supérieur à"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Aucun déclaré"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("non"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Opérateur"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Motif"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("En texte"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Cette condition imbrique des groupes ; elle s’édite donc en texte.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Valeur"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Valeurs séparées par des virgules",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Autoriser"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Tant que vous ne l’autorisez pas, le groupe utilise le profil Simple. Les sites ne sont contactés que via vos serveurs ou pour tester le réseau.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Autorisation requise",
    ),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Sites contactés"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Les sites tiers n’appartiennent ni à votre fournisseur ni aux profils intégrés.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Contrôle"),
    "rcxCountryAll": MessageLookupByLibrary.simpleMessage("Tous les pays"),
    "rcxCountryOnServers": MessageLookupByLibrary.simpleMessage(
      "Sur vos serveurs",
    ),
    "rcxCountryPickMany": MessageLookupByLibrary.simpleMessage(
      "Choisir des pays",
    ),
    "rcxCountryPickOne": MessageLookupByLibrary.simpleMessage(
      "Choisir un pays",
    ),
    "rcxCountryServers": m84,
    "rcxCountryVerified": MessageLookupByLibrary.simpleMessage("vérifié"),
    "rcxDeleteProfile": m85,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage("Diagnostic réseau"),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Sites directs via ce groupe",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage(
      "Actif maintenant",
    ),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Si les sites que vos règles envoient en direct ne s’ouvrent plus, ils passeront par ce groupe. Les adresses locales restent toujours directes.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "En attente : les sites directs s’ouvrent encore",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage(
      "Dupliquer et modifier",
    ),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Économe"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Précis"),
    "rcxEnergyToday": m86,
    "rcxExcept": m87,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Exclu par le profil",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "Ignoré après « Changer de serveur »",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage(
      "Hors des serveurs retenus",
    ),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Ne correspond à aucune préférence",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Pas encore vérifié",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage(
      "Pas un serveur",
    ),
    "rcxExit": m88,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage(
      "Vérification du pays de sortie",
    ),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Exporter"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Rarement"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Souvent"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Fonctionne"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("Utilisé"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Ne fonctionne pas"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Diagnostic réseau"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Pays d’entrée"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Pays de sortie"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage(
      "Échoue à la vérification",
    ),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Type de réseau"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Latence, ms"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Mesuré"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("Réseau limité"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Nom"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage(
      "Réussit la vérification",
    ),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Page de connexion"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Fournisseur"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage(
      "Adresse du serveur",
    ),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Étiquette"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage(
      "Type de connexion",
    ),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Protocole"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("Prend en charge UDP"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Tout le groupe passe par ce membre sans recherche de serveur ; choisissez un répartiteur de charge ou un groupe imbriqué pour tout lui confier.",
    ),
    "rcxFixedOn": m89,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("Général"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage(
      "Profils de groupe",
    ),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Comment un groupe intelligent choisit son serveur. Touchez le vôtre pour le modifier, un autre pour en modifier une copie.",
    ),
    "rcxGroupSettings": MessageLookupByLibrary.simpleMessage(
      "Réglages du groupe",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Fonctionne"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Ne fonctionne pas"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage(
      "Fonctionnait auparavant",
    ),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Non vérifié"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("Historique"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Versions antérieures",
    ),
    "rcxHubAuto": MessageLookupByLibrary.simpleMessage("Routage automatique"),
    "rcxHubBundle": MessageLookupByLibrary.simpleMessage("Dans ce fichier"),
    "rcxHubChange": MessageLookupByLibrary.simpleMessage("Changer"),
    "rcxHubCopyConfirm": MessageLookupByLibrary.simpleMessage(
      "Créer une copie",
    ),
    "rcxHubCopyMessage": m90,
    "rcxHubCopyTitle": MessageLookupByLibrary.simpleMessage(
      "Créer votre propre copie ?",
    ),
    "rcxHubDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Ce que fait ce scénario",
    ),
    "rcxHubEverythingElse": MessageLookupByLibrary.simpleMessage(
      "Tout le reste",
    ),
    "rcxHubEverythingElseHint": MessageLookupByLibrary.simpleMessage(
      "Le trafic qu’aucune route ne prend passe par le groupe principal de l’abonnement.",
    ),
    "rcxHubGroupsEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun groupe n’est encore piloté par le routage automatique.",
    ),
    "rcxHubLibrary": MessageLookupByLibrary.simpleMessage("Bibliothèque"),
    "rcxHubNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Démarrez la connexion pour voir le routage automatique",
    ),
    "rcxHubNetworks": MessageLookupByLibrary.simpleMessage("Réseaux"),
    "rcxHubNetworksTitle": MessageLookupByLibrary.simpleMessage(
      "Mode et réseaux",
    ),
    "rcxHubNoProfile": MessageLookupByLibrary.simpleMessage("Aucun abonnement"),
    "rcxHubNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Ajoutez d’abord un abonnement ; le routage automatique utilise ses groupes.",
    ),
    "rcxHubOffHint": MessageLookupByLibrary.simpleMessage(
      "Activez-le pour qu’un scénario choisisse les serveurs de vos groupes et routes.",
    ),
    "rcxHubOtherGroups": MessageLookupByLibrary.simpleMessage("Autres groupes"),
    "rcxHubOtherGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Groupes de l’abonnement que ce scénario pilote aussi.",
    ),
    "rcxHubOverview": MessageLookupByLibrary.simpleMessage("Aperçu"),
    "rcxHubRoutes": MessageLookupByLibrary.simpleMessage("Routes"),
    "rcxHubRoutesHint": MessageLookupByLibrary.simpleMessage(
      "Le trafic prend la première route qui correspond, de haut en bas.",
    ),
    "rcxHubRoutesOff": MessageLookupByLibrary.simpleMessage(
      "Aucun scénario en cours",
    ),
    "rcxHubRoutesOffHint": MessageLookupByLibrary.simpleMessage(
      "Les routes font passer un trafic choisi, comme un service, par ses propres serveurs.",
    ),
    "rcxHubRoutesRuleOnly": m91,
    "rcxHubStartScenario": MessageLookupByLibrary.simpleMessage(
      "Créer un scénario",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Ajouter à mes profils",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Démarrez le noyau de l’app pour vérifier ce profil.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Importer un profil de routage",
    ),
    "rcxImported": m92,
    "rcxJournalFailure": m93,
    "rcxJournalMode": m94,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("vérification"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Sur ce réseau, ils remplacent les groupes du scénario de même nom ; les autres fonctionnent comme sur tous les réseaux.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Nom"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Lettres latines minuscules, chiffres et tirets, 24 au maximum",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("internet ouvert"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("page de connexion"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Reconnu lorsque"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Les types sont testés de haut en bas ; le réseau reçoit le premier qui correspond.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage(
      "listes blanches seulement",
    ),
    "rcxLadderAdd": MessageLookupByLibrary.simpleMessage("Ajouter une étape"),
    "rcxLadderAdvanced": MessageLookupByLibrary.simpleMessage(
      "Condition avancée…",
    ),
    "rcxLadderAnyWorking": MessageLookupByLibrary.simpleMessage(
      "Tout serveur qui fonctionne",
    ),
    "rcxLadderCountry": MessageLookupByLibrary.simpleMessage("Pays"),
    "rcxLadderEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Ajoutez des étapes pour préférer certains serveurs",
    ),
    "rcxLadderExceptCountries": MessageLookupByLibrary.simpleMessage(
      "Tous sauf ces pays",
    ),
    "rcxLadderFallThrough": MessageLookupByLibrary.simpleMessage(
      "si aucun ne fonctionne",
    ),
    "rcxLadderFits": m95,
    "rcxLadderGroupHint": MessageLookupByLibrary.simpleMessage(
      "Cet ordre ne vaut que pour ce groupe. Laissez-le vide pour suivre l’ordre du profil.",
    ),
    "rcxLadderInherited": MessageLookupByLibrary.simpleMessage(
      "Issu du comportement — modifiez une étape pour avoir votre propre ordre",
    ),
    "rcxLadderLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Les serveurs d’une étape de dernier recours ne servent que si aucune autre étape, même plus bas, n’a de serveur qui fonctionne.",
    ),
    "rcxLadderLatency": m96,
    "rcxLadderLatencyUnder": MessageLookupByLibrary.simpleMessage(
      "Latence inférieure à, ms",
    ),
    "rcxLadderNameContains": MessageLookupByLibrary.simpleMessage(
      "Le nom contient",
    ),
    "rcxLadderNameHas": m97,
    "rcxLadderNot": m98,
    "rcxLadderOther": MessageLookupByLibrary.simpleMessage("Autres conditions"),
    "rcxLadderProvider": m99,
    "rcxLadderScenarioFirst": MessageLookupByLibrary.simpleMessage(
      "Un scénario pilote ce groupe en ce moment : l’ordre des serveurs qu’il lui donne passe avant celui-ci.",
    ),
    "rcxLadderServersIn": MessageLookupByLibrary.simpleMessage(
      "Serveurs de cette étape",
    ),
    "rcxLadderStep": m100,
    "rcxLadderStranded": m101,
    "rcxLadderTag": m102,
    "rcxLadderTitle": MessageLookupByLibrary.simpleMessage(
      "Ordre des serveurs",
    ),
    "rcxLadderUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Dernier recours"),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Niveau"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Avancé"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Simple"),
    "rcxLine": m103,
    "rcxLintCheckUnused": m104,
    "rcxLintConsent": m105,
    "rcxLintGroupMissing": m106,
    "rcxLintPoolEmpty": m107,
    "rcxLintTagUnused": m108,
    "rcxLintTierEmpty": m109,
    "rcxLintTierUnreachable": m110,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Groupe principal"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Activer le routage automatique",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash garde un serveur fonctionnel dans ce groupe et change en cas de panne. Les vérifications n’ont lieu que pendant l’utilisation du réseau.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Les profils et scénarios se créent et se modifient dans « Configuration avancée » → « Routage automatique ».",
    ),
    "rcxMatchAdd": MessageLookupByLibrary.simpleMessage("Ajouter une entrée"),
    "rcxMatchCidr": MessageLookupByLibrary.simpleMessage("Plage IP"),
    "rcxMatchCustom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "rcxMatchDomain": MessageLookupByLibrary.simpleMessage("Domaine"),
    "rcxMatchGeoip": MessageLookupByLibrary.simpleMessage("Catégorie d’IP"),
    "rcxMatchGeosite": MessageLookupByLibrary.simpleMessage(
      "Catégorie de sites",
    ),
    "rcxMatchHint": MessageLookupByLibrary.simpleMessage(
      "Domaines, plages IP, apps ou ensembles de règles que cette route prend aussi.",
    ),
    "rcxMatchInvalid": MessageLookupByLibrary.simpleMessage(
      "Valeur non valide",
    ),
    "rcxMatchKeyword": MessageLookupByLibrary.simpleMessage(
      "Mot-clé de domaine",
    ),
    "rcxMatchMore": m111,
    "rcxMatchNext": MessageLookupByLibrary.simpleMessage("Suivant"),
    "rcxMatchNoResolve": MessageLookupByLibrary.simpleMessage(
      "Ne pas résoudre les domaines",
    ),
    "rcxMatchNone": MessageLookupByLibrary.simpleMessage("Aucun trafic choisi"),
    "rcxMatchPickHint": MessageLookupByLibrary.simpleMessage(
      "Choisissez les services que prend cette route ; vous pouvez aussi ajouter vos propres entrées.",
    ),
    "rcxMatchProcess": MessageLookupByLibrary.simpleMessage("Application"),
    "rcxMatchRuleSet": MessageLookupByLibrary.simpleMessage(
      "Ensemble de règles",
    ),
    "rcxMatchServices": MessageLookupByLibrary.simpleMessage("Services"),
    "rcxMatchSuffix": MessageLookupByLibrary.simpleMessage(
      "Domaine et sous-domaines",
    ),
    "rcxMatchType": MessageLookupByLibrary.simpleMessage("Type"),
    "rcxMatchTypeHint": MessageLookupByLibrary.simpleMessage(
      "Un suffixe de domaine couvre aussi tous les sous-domaines.",
    ),
    "rcxMatchValue": MessageLookupByLibrary.simpleMessage("Valeur"),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de reprendre les changements",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Changements repris"),
    "rcxMergedConflicts": m112,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Choisit le meilleur serveur fonctionnel selon l’ordre des serveurs et change quand il tombe en panne.",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Rendre le mode au scénario",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "Le scénario définit le mode sur ce réseau",
    ),
    "rcxModeIs": m113,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("Ne pas changer"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Manuel"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Vous choisissez le serveur dans la liste des proxys ; le routage automatique ne le change jamais.",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Vous avez choisi le mode vous-même ; le scénario attend que vous choisissiez « Auto »",
    ),
    "rcxModePinnedHint": m114,
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "Sur ce réseau, le mode est le vôtre",
    ),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Nécessite votre autorisation",
    ),
    "rcxNetwork": m115,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Types de réseau"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Nouveau profil"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Nouveau scénario"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("Sur ce réseau"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("échoue"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("est parmi"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("est"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("n’est pas"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("correspond à"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("réussit"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage(
      "Changements par réseau",
    ),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage(
      "Profil propre du groupe",
    ),
    "rcxOwnProfileHint": MessageLookupByLibrary.simpleMessage(
      "Le groupe garde le comportement réglé dans ses propres paramètres.",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "Le motif n’est pas une expression régulière valide",
    ),
    "rcxPendingTier": m116,
    "rcxPinned": m117,
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Épinglé"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Exclure"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Utiliser"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Le groupe n’a aucun serveur",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ce groupe n’est pas un sélecteur dans la configuration actuelle",
    ),
    "rcxProblemProfileInvalid": m118,
    "rcxProblemProfileMissing": m119,
    "rcxProblemStoreFailed": m120,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "rcxProfileDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Ce que fait ce profil",
    ),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Nom"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "Le groupe choisit un serveur avec ce profil parmi ceux que garde le pool.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Action"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Confier à un membre",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Membre"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage(
      "Choisir un serveur",
    ),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage(
      "C’est le meilleur serveur",
    ),
    "rcxReasonBetterTier": m121,
    "rcxReasonChangeServer": m122,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Vérification d’un meilleur candidat",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Un serveur plus rapide doit être mesuré à nouveau",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Changement récent ; attente avant le prochain",
    ),
    "rcxReasonFailover": m123,
    "rcxReasonFaster": m124,
    "rcxReasonFixed": m125,
    "rcxReasonFixedMissing": m126,
    "rcxReasonFlapLimit": m127,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Le serveur épinglé est conservé",
    ),
    "rcxReasonIdle": m128,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Meilleur serveur disponible sélectionné",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage("Contrôle manuel"),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Le réseau a changé",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "Le réseau semble coupé ; aucun serveur n’est mis en cause",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "Aucun autre serveur fonctionnel",
    ),
    "rcxReasonOutOfPool": m129,
    "rcxReasonPaused": m130,
    "rcxReasonRouteInvalid": m131,
    "rcxReasonRouteNameTaken": m132,
    "rcxReasonRouteToMissing": m133,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de sélectionner le serveur",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Les sites directs repassent en direct",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Les sites directs passent désormais par ce groupe",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Aucun serveur ne fonctionne ; le serveur actuel est conservé",
    ),
    "rcxReasonSwitchFixed": m134,
    "rcxReasonSwitchPinned": m135,
    "rcxReasonSwitchStranded": m136,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Fonctionne ; conservé jusqu’à une panne",
    ),
    "rcxRouteAdd": MessageLookupByLibrary.simpleMessage("Ajouter une route"),
    "rcxRouteChoose": MessageLookupByLibrary.simpleMessage("Choisir"),
    "rcxRouteEdit": MessageLookupByLibrary.simpleMessage("Modifier la route"),
    "rcxRouteGroup": MessageLookupByLibrary.simpleMessage("Créé par une route"),
    "rcxRouteGroupHint": m137,
    "rcxRouteName": MessageLookupByLibrary.simpleMessage("Nom"),
    "rcxRouteNameLong": MessageLookupByLibrary.simpleMessage(
      "Le nom est trop long",
    ),
    "rcxRouteNameReserved": MessageLookupByLibrary.simpleMessage(
      "Ce nom est réservé",
    ),
    "rcxRouteNew": MessageLookupByLibrary.simpleMessage("Nouvelle route"),
    "rcxRouteSend": MessageLookupByLibrary.simpleMessage("Envoyer par"),
    "rcxRouteSendAutoHint": MessageLookupByLibrary.simpleMessage(
      "Le groupe propre à la route choisit le meilleur serveur dans l’ordre ci-dessous.",
    ),
    "rcxRouteSendDirectHint": MessageLookupByLibrary.simpleMessage(
      "Ce trafic contourne le proxy.",
    ),
    "rcxRouteSendFixed": MessageLookupByLibrary.simpleMessage("Un serveur"),
    "rcxRouteSendFixedHint": MessageLookupByLibrary.simpleMessage(
      "Ce trafic passe toujours par le serveur ou le groupe choisi.",
    ),
    "rcxRouteTarget": MessageLookupByLibrary.simpleMessage("Serveur"),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Scénario"),
    "rcxScenarioDrives": m138,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Groupes"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Le groupe principal est celui où la règle finale envoie le trafic ; « Tous les groupes » couvre les groupes de sélection non nommés ici.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Reconnaissez les réseaux par diagnostic direct, puis changez le mode et les groupes sur chacun.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage(
      "Mode de connexion",
    ),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Scénarios"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Un scénario pilote toute la connexion. Touchez le vôtre pour le modifier, un autre pour en modifier une copie.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Serveurs"),
    "rcxServersMatch": m139,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("Motif du nom"),
    "rcxSettingsLink": MessageLookupByLibrary.simpleMessage(
      "Réglages du routage automatique",
    ),
    "rcxSettingsLinkHint": MessageLookupByLibrary.simpleMessage(
      "Profils, scénarios et routes",
    ),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage(
      "Groupes intelligents",
    ),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Intégré"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "Le profil d’origine a changé",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Ce qui a changé"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("Du fournisseur"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Les miens"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Quand aucun serveur ne convient",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage(
      "Passer en direct",
    ),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Garder le serveur actuel",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Changements"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Nom de l’étiquette"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Lettres latines, chiffres, - et _ uniquement, 24 au maximum",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Étiquettes"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Une étiquette nomme une fois un ensemble de serveurs, pour l’utiliser dans les préférences avec tag(name).",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("tiers"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Libellé"),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Routage automatique"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Traductions"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage(
      "Désactiver le routage automatique pour ce groupe",
    ),
    "rcxTurnOffHint": MessageLookupByLibrary.simpleMessage(
      "Le groupe garde son serveur actuel et cesse de changer de lui-même.",
    ),
    "rcxUntilCheck": m140,
    "rcxUntilConfirm": m141,
    "rcxUntilDwell": m142,
    "rcxUseCheck": m143,
    "rcxUseDiagnostic": m144,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage(
      "vérification du pays de sortie",
    ),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Avertissements"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Pourquoi ce serveur"),
    "rcxWhyCount": m145,
    "rcxWouldDo": MessageLookupByLibrary.simpleMessage(
      "Avec le routage automatique",
    ),
    "rcxWouldServers": m146,
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Requêtes récentes"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Suggestions"),
    "recordType": MessageLookupByLibrary.simpleMessage("Type d’enregistrement"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Port Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Rétablir"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Appliquer la région"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "La région ou les listes ont changé. Relancez la sélection avec les réglages actuels.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucune application ne correspond à cette région. Vos listes restent inchangées.",
    ),
    "regionAppsPreview": m147,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Aperçu de la sélection",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("Serveurs DNS"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("MTU TUN"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Vérifications des services",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("Ce qui change"),
    "regionChina": MessageLookupByLibrary.simpleMessage("Chine"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Les valeurs que vous avez modifiées vous-même sont conservées.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Égypte"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Choisit les serveurs DNS, le MTU TUN, la liste d’exclusions et les vérifications de services pour votre pays. La langue de l’interface ne change pas.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Vos réglages ne changent pas.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Vérifications des services désactivées",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Non sélectionnée"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Autre pays"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Recommandée pour cet appareil",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Russie"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Sélectionner les applications par région",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Choisissez une région prise en charge avant d’utiliser les suggestions d’applications régionales.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Profil régional"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Adaptation régionale",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Libérer la mémoire"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la libération de la mémoire",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Distant"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Destination distante",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Résolution DNS distante",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Retirer"),
    "rename": MessageLookupByLibrary.simpleMessage("Renommer"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Renouveler l’abonnement",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Remplacer"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Tout remplacer"),
    "request": MessageLookupByLibrary.simpleMessage("Requête"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage(
      "En-têtes de requête",
    ),
    "requests": MessageLookupByLibrary.simpleMessage("Requêtes"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requêtes et mises à jour",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Obligatoire"),
    "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "resetAllData": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser toutes les données",
    ),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage(
      "Tout supprimer",
    ),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Tous les profils, réglages, scripts, fonds d’écran et données en cache seront définitivement supprimés. Les archives de sauvegarde seront conservées. L’application se fermera ensuite. Cette action est irréversible.",
    ),
    "resetAllDataWait": m148,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Cette page contient des modifications. Voulez-vous vraiment réinitialiser ?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment réinitialiser ?",
    ),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Suppression des données…",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de mise à jour automatique",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "L’intervalle de mise à jour automatique doit être supérieur à 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ressources"),
    "respectRules": MessageLookupByLibrary.simpleMessage(
      "Respecter les règles",
    ),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respecter les règles fait passer les connexions DNS selon les règles et nécessite un Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Code de réponse"),
    "restart": MessageLookupByLibrary.simpleMessage("Redémarrer"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment redémarrer le cœur ?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restaurer"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Restaurer toutes les données",
    ),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Restaurer les valeurs par défaut",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restaurer uniquement les profils",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Stratégie de restauration",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Écraser"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restauration réussie",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Résultat"),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Adresses de route"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses de route exclues",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Marque de routage"),
    "ru": MessageLookupByLibrary.simpleMessage("Russe"),
    "rule": MessageLookupByLibrary.simpleMessage("Règle"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique ET",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au domaine complet",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à un mot-clé de domaine",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une regex de domaine",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à un suffixe de domaine",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspondance par caractères génériques ; seuls * et ? sont pris en charge",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la marque DSCP (entrant UDP tproxy uniquement)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la plage de ports de destination",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au code pays de l’IP",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond aux domaines de Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom entrant",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au port entrant",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au type entrant",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom d’utilisateur entrant ; séparez plusieurs noms par /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ASN de l’IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP ; IP-CIDR6 n’est qu’un alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage de suffixes d’IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à toutes les requêtes, sans condition",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à TCP ou UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique NON",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique OU",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom du processus ; correspond au nom du paquet sur Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par regex au nom du processus ; correspond au nom du paquet sur Android",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par caractères génériques au nom du processus ; seuls * et ? sont pris en charge",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au chemin complet du processus",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par regex au chemin du processus",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par caractères génériques au chemin du processus ; seuls * et ? sont pris en charge",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom de rematch ; séparez plusieurs noms par /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Référence un jeu de règles ; nécessite rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au code pays de l’IP source",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ASN de l’IP source",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP source",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage de suffixes d’IP source",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la plage de ports source",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond vers une sous-règle ; attention aux parenthèses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ID d’utilisateur Linux",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("La règle est vide"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Les règles doivent former une liste YAML avec une règle par élément, par exemple - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent en direct",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Bloquer DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Bloquer le bouclage du proxy",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("Bloquer QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("Bloquer STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "LAN en direct",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple et Microsoft en direct",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "Fournisseurs de règles",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Jeu de règles"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Le jeu de règles ne contient aucune entrée exploitable",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Ce fichier mrs est illisible",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Le jeu de règles mélange des domaines et des plages d’IP : son type est indéterminable",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Cible de la règle"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "La règle doit commencer par un type pris en charge, par exemple DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Règles"),
    "rulesCount": m149,
    "runTime": MessageLookupByLibrary.simpleMessage("Durée d’exécution"),
    "running": MessageLookupByLibrary.simpleMessage("En cours d’exécution"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration d’exécution",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Mode sans échec"),
    "safeModeAppTitle": m150,
    "saturation": MessageLookupByLibrary.simpleMessage("Saturation"),
    "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les modifications ?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Mode script : réécrit tout le profil avec un script d’extension",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Défiler jusqu’à la sélection",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "seconds": MessageLookupByLibrary.simpleMessage("secondes"),
    "secondsCount": m151,
    "secretKey": MessageLookupByLibrary.simpleMessage("Clé"),
    "sectionsInEffect": m152,
    "select": MessageLookupByLibrary.simpleMessage("Sélectionner"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un jeu de règles",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une stratégie de répartition",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Sélectionné"),
    "send": MessageLookupByLibrary.simpleMessage("Envoyer"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Envoyer depuis le téléphone",
    ),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Importer le lien envoyé depuis le téléphone ?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Cet appareil n\'est connecté à aucun réseau local",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Lien d\'abonnement ou lien de partage de proxy",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Envoyé. Confirmez l\'importation sur l\'autre appareil.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "Envoyer un lien à ReClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Pour recevoir un lien depuis le téléphone, ReClash a besoin de l\'autorisation Appareils à proximité, qui lui donne accès au réseau local. Activez-la dans les paramètres de l\'application.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Scannez le code avec l\'appareil photo du téléphone, puis collez le lien dans la page qui s\'ouvre. Les deux appareils doivent être sur le même réseau.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Serveur"),
    "serviceAbnormalCount": m153,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Tout est disponible",
    ),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Vérifier automatiquement les services actifs",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Vérifier tous les services",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Disponible"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloqué"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Tout vérifier"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "Vérifier uniquement en connexion",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage(
      "Bientôt disponible",
    ),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "FAI non autorisé",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la vérification",
    ),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Gérer les services"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Contenus originaux uniquement",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Non vérifié"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Accès restreint",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Affiché sur le tableau de bord",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("État des services"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Indisponible"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Région non prise en charge",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("réglages"),
    "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "settingsCount": m154,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Ce profil est chiffré. Saisissez sa clé age pour continuer.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Ce serveur a répondu à une sonde distincte. Basculez dessus et vérifiez à nouveau toute la route.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "Se connecter à l’ouverture de ReClash",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Démarrer cette connexion en même temps que l’application.",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Modifier les réglages",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Vérifier la connexion",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "Le résultat concerne cette route, pas toutes les applications ni tous les sites web.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Nous vérifions une route sélectionnée. Les demandes d’autorisation du système s’ouvrent séparément.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Connexion et vérification",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Confirmé"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "La route sélectionnée a répondu. Le trafic suit les règles de votre profil.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "La connexion fonctionne",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Copier l’adresse du proxy",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage(
      "Toutes les applications",
    ),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN intercepte le trafic de l’appareil. Le système peut demander une autorisation.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android demandera l’autorisation de créer une connexion VPN. La sélection des applications se trouve dans les paramètres d’accès.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "Choisissez les applications qui utilisent ReClash. Les règles de votre profil déterminent quelles connexions passent par un serveur.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Je configurerai les applications manuellement",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Indiquez l’adresse du proxy local dans chaque application que vous souhaitez connecter.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Intercepter tout le trafic ne signifie pas tout envoyer via un serveur. Les routes directes restent actives.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Proxy système",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Les applications qui ne prennent pas en charge le proxy système se connectent directement.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Quelles applications doivent se connecter ?",
    ),
    "setupDirectApps": m155,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "Aucune application locale trouvée. Les sites passent tout de même en direct.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Elles fonctionneront sans le VPN. Vous pourrez modifier la liste plus tard dans le contrôle d’accès.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Recherche des applications locales…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Les services de votre pays s’ouvrent sans le serveur : plus vite, et les banques ou sites publics ne vous bloquent pas. Ces règles globales sont ajoutées :",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Sites et applications locaux en direct",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Détails"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "La connexion nécessite votre attention",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez modifier chaque choix dans les paramètres.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Continuer"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Choisissez une langue avant de lire les conditions. Vous pourrez la modifier plus tard.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Choisissez votre langue",
    ),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "La configuration est incomplète ; la connexion n’a pas été vérifiée.",
    ),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash va se fermer. Vos choix sont enregistrés et la configuration reprendra à la prochaine ouverture.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Quitter la configuration ?",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Configurez cette adresse dans les applications que vous souhaitez connecter. Cette vérification ne confirme pas leur configuration.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Le proxy local est prêt",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Non vérifié"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "La route a répondu, mais certaines vérifications n’ont pas pu être confirmées.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Connecté, avec des limites",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Autorisez la connexion dans la demande du système, réessayez ou choisissez un autre périmètre.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Une autorisation est nécessaire",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Recherche d’un autre serveur",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Démarrage de la connexion",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("Démarrage du cœur"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Confirmation de la sortie",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Application du profil",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Vérification de la route",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Vérification des services",
    ),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Ajoutez ou choisissez un profil pour continuer.",
    ),
    "setupProfileCount": m156,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash ne fournit pas de serveurs. Importez un abonnement ou une configuration de votre fournisseur.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Importer un profil",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Ajouter un autre profil",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Collez le lien reçu par e-mail, bot ou espace client de votre fournisseur, ou choisissez un fichier ou un QR code.",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Lien d’abonnement ou de partage",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Profil prêt"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage(
      "Configurer plus tard",
    ),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Ajouter un profil de connexion",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Votre connexion"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Vérification"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Couverture"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Région"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Recommandé"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Conserver les valeurs du profil",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Les réglages régionaux ne changent pas.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash adapte le DNS, la MTU et les routes directes aux réseaux de votre pays. La langue de l’interface ne change pas.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "D’où vous connectez-vous ?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Sans choix, vos réglages régionaux actuels restent tels quels.",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Vérifier à nouveau"),
    "setupReport": MessageLookupByLibrary.simpleMessage(
      "Rapport de vérification",
    ),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Autoriser la connexion",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage(
      "Configurer la connexion",
    ),
    "setupResume": MessageLookupByLibrary.simpleMessage(
      "Reprendre la configuration",
    ),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "La route a changé pendant la vérification. Vérifiez à nouveau la connexion actuelle.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "Le mode sans échec ne démarre pas de connexion réelle. Enregistrez la configuration ou testez-la dans une version normale.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Impossible d’enregistrer vos choix. Réessayez.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Enregistrer sans se connecter",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Vos choix sont enregistrés. Vous pourrez vous connecter depuis le tableau de bord quand vous le souhaitez.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Se connecter plus tard",
    ),
    "setupStepStatus": m157,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Vos choix sont enregistrés. La connexion précédente n’a pas été arrêtée.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Vérification arrêtée",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Choisissez une autre portée : certains réseaux bloquent les connexions VPN.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Vérifiez qu’Internet fonctionne sans ReClash.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Mettez le profil à jour ou choisissez un autre serveur après la configuration.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage(
      "Ce que vous pouvez essayer",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Première connexion"),
    "setupTryServer": m158,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Aucune réponse"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "La connexion a démarré, mais la route sélectionnée n’a pas fourni suffisamment de résultats.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Connexion non confirmée",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "L’opération n’a pas abouti. Réessayez ou consultez les détails.",
    ),
    "shareLinkUnreadable": m159,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy n’a pu être lu dans les liens",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Scannez avec ReClash sur un autre appareil pour importer ce profil.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Afficher"),
    "showLess": MessageLookupByLibrary.simpleMessage("Réduire"),
    "showMore": MessageLookupByLibrary.simpleMessage("Développer"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Bouton Arrêter dans la notification",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage(
      "Afficher le mot de passe",
    ),
    "sidebar": MessageLookupByLibrary.simpleMessage("Barre latérale"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Flou de la barre latérale",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Le flou d’arrière-plan laisse voir le bureau derrière la fenêtre à travers la barre latérale.",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage(
      "Lancement silencieux",
    ),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Le lancement silencieux démarre l’app sans afficher la fenêtre.",
    ),
    "simpleDashboardDetailed": MessageLookupByLibrary.simpleMessage(
      "Tableau de bord détaillé",
    ),
    "simpleDashboardEditWidgets": MessageLookupByLibrary.simpleMessage(
      "Modifier les widgets",
    ),
    "simpleDashboardEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun widget pour l’instant. Ajoutez-les dans l’éditeur.",
    ),
    "simpleDashboardHome": MessageLookupByLibrary.simpleMessage("Accueil"),
    "simpleDashboardSimple": MessageLookupByLibrary.simpleMessage(
      "Tableau de bord simple",
    ),
    "simpleDashboardWidgets": MessageLookupByLibrary.simpleMessage("Widgets"),
    "simpleDaysCount": m160,
    "simpleIpBusiness": MessageLookupByLibrary.simpleMessage(
      "Adresse d’organisation",
    ),
    "simpleIpGoodDesc": MessageLookupByLibrary.simpleMessage(
      "Les CAPTCHA et les blocages « VPN » sont peu probables.",
    ),
    "simpleIpHosting": MessageLookupByLibrary.simpleMessage(
      "Adresse de centre de données",
    ),
    "simpleIpLevelClean": MessageLookupByLibrary.simpleMessage("Propre"),
    "simpleIpLevelNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "simpleIpLevelRisky": MessageLookupByLibrary.simpleMessage("Risque"),
    "simpleIpMobile": MessageLookupByLibrary.simpleMessage(
      "Adresse de réseau mobile",
    ),
    "simpleIpNormalDesc": MessageLookupByLibrary.simpleMessage(
      "Certains sites peuvent demander un CAPTCHA.",
    ),
    "simpleIpReal": MessageLookupByLibrary.simpleMessage(
      "Votre adresse réelle",
    ),
    "simpleIpRealDesc": MessageLookupByLibrary.simpleMessage(
      "Votre fournisseur d’accès et les sites voient où vous êtes et ce que vous ouvrez.",
    ),
    "simpleIpResidential": MessageLookupByLibrary.simpleMessage(
      "Adresse domestique ordinaire",
    ),
    "simpleIpRiskyDesc": MessageLookupByLibrary.simpleMessage(
      "Les sites peuvent vous bloquer ou vous vérifier plus souvent.",
    ),
    "simpleIpTitle": MessageLookupByLibrary.simpleMessage(
      "Comment les sites vous voient",
    ),
    "simpleIpUnknown": MessageLookupByLibrary.simpleMessage(
      "Impossible de vérifier l’adresse",
    ),
    "simpleLatency": m161,
    "simpleLocationAll": MessageLookupByLibrary.simpleMessage("Tous"),
    "simpleLocationAuto": MessageLookupByLibrary.simpleMessage(
      "choisi automatiquement",
    ),
    "simpleLocationManual": MessageLookupByLibrary.simpleMessage(
      "choisi par vous",
    ),
    "simpleLocationNone": MessageLookupByLibrary.simpleMessage(
      "Aucun serveur pour l’instant",
    ),
    "simpleLocationNoneHint": MessageLookupByLibrary.simpleMessage(
      "Les serveurs apparaissent après la connexion",
    ),
    "simpleModeAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "simpleModeAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Le scénario réseau choisit le mode",
    ),
    "simpleModeDirect": MessageLookupByLibrary.simpleMessage("Direct"),
    "simpleModeDirectDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic passe sans VPN",
    ),
    "simpleModeGlobal": MessageLookupByLibrary.simpleMessage("Tout par le VPN"),
    "simpleModeGlobalDesc": MessageLookupByLibrary.simpleMessage(
      "Tout le trafic passe par le serveur",
    ),
    "simpleModeRule": MessageLookupByLibrary.simpleMessage("Intelligent"),
    "simpleModeRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Passe par le VPN seulement ce qui ne s’ouvre pas",
    ),
    "simpleModeTitle": MessageLookupByLibrary.simpleMessage("Mode"),
    "simpleNoExpiry": MessageLookupByLibrary.simpleMessage("sans date de fin"),
    "simpleProviderAnnouncement": MessageLookupByLibrary.simpleMessage(
      "Annonce du fournisseur",
    ),
    "simpleServiceBlocked": m162,
    "simpleServiceComingSoon": m163,
    "simpleServiceOriginalsOnly": m164,
    "simpleServiceRestricted": m165,
    "simpleServiceUnavailable": m166,
    "simpleServiceUnsupportedRegion": m167,
    "simpleServicesAfterConnect": MessageLookupByLibrary.simpleMessage(
      "Après la connexion",
    ),
    "simpleServicesAllGood": MessageLookupByLibrary.simpleMessage(
      "Tout est en ordre",
    ),
    "simpleServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Direct, comme sans VPN",
    ),
    "simpleServicesManual": MessageLookupByLibrary.simpleMessage("Manuel"),
    "simpleServicesTitle": MessageLookupByLibrary.simpleMessage("Services"),
    "simpleServicesViaVpn": MessageLookupByLibrary.simpleMessage("Via le VPN"),
    "simpleSpeed4k": MessageLookupByLibrary.simpleMessage(
      "Suffisant pour la vidéo en 4K",
    ),
    "simpleSpeedAgain": MessageLookupByLibrary.simpleMessage("Relancer"),
    "simpleSpeedAll": MessageLookupByLibrary.simpleMessage(
      "Rapide : suffisant pour tout à la fois",
    ),
    "simpleSpeedChat": MessageLookupByLibrary.simpleMessage(
      "Suffisant pour les messages et la musique",
    ),
    "simpleSpeedDirectIdleDesc": m168,
    "simpleSpeedDirectTag": MessageLookupByLibrary.simpleMessage("sans VPN"),
    "simpleSpeedFailed": MessageLookupByLibrary.simpleMessage(
      "Mesure impossible. Réessayez.",
    ),
    "simpleSpeedHd": MessageLookupByLibrary.simpleMessage(
      "Suffisant pour la vidéo en HD",
    ),
    "simpleSpeedIdleDesc": m169,
    "simpleSpeedLevel4k": MessageLookupByLibrary.simpleMessage("4K"),
    "simpleSpeedLevelAll": MessageLookupByLibrary.simpleMessage(
      "Tout à la fois",
    ),
    "simpleSpeedLevelChat": MessageLookupByLibrary.simpleMessage("Messages"),
    "simpleSpeedLevelHd": MessageLookupByLibrary.simpleMessage("HD"),
    "simpleSpeedMeasure": MessageLookupByLibrary.simpleMessage("Mesurer"),
    "simpleSpeedMeasuring": MessageLookupByLibrary.simpleMessage(
      "Mesure en cours…",
    ),
    "simpleSpeedSlow": MessageLookupByLibrary.simpleMessage(
      "Lente : même les pages mettent du temps à charger",
    ),
    "simpleSpeedTitle": MessageLookupByLibrary.simpleMessage("Vitesse"),
    "simpleSpeedUnit": MessageLookupByLibrary.simpleMessage("Mbit/s"),
    "simpleStatusConnecting": MessageLookupByLibrary.simpleMessage(
      "Connexion…",
    ),
    "simpleStatusConnectingHint": MessageLookupByLibrary.simpleMessage(
      "Choix du meilleur serveur",
    ),
    "simpleStatusNoProfile": MessageLookupByLibrary.simpleMessage(
      "Aucun abonnement",
    ),
    "simpleStatusNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "Ajoutez un abonnement pour vous connecter",
    ),
    "simpleStatusOff": MessageLookupByLibrary.simpleMessage("Non protégé"),
    "simpleStatusOffHint": MessageLookupByLibrary.simpleMessage(
      "Touchez pour vous connecter",
    ),
    "simpleStatusOn": MessageLookupByLibrary.simpleMessage("Protégé"),
    "simpleStatusPaused": MessageLookupByLibrary.simpleMessage("En pause"),
    "simpleStatusPausedHint": MessageLookupByLibrary.simpleMessage(
      "Réseau de confiance",
    ),
    "simpleStatusPausedOn": m170,
    "simpleTrafficLeft": m171,
    "simpleTrafficUnlimited": MessageLookupByLibrary.simpleMessage(
      "trafic illimité",
    ),
    "simpleTrustedDesc": MessageLookupByLibrary.simpleMessage(
      "Sur ces réseaux, le VPN se met en pause tout seul et reprend quand vous partez.",
    ),
    "simpleTrustedEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun réseau pour l’instant",
    ),
    "simpleTrustedThisNetwork": MessageLookupByLibrary.simpleMessage(
      "Ce réseau",
    ),
    "simpleTrustedTitle": MessageLookupByLibrary.simpleMessage(
      "Pause sur mes réseaux",
    ),
    "simpleUntilDate": m172,
    "singleAdd": MessageLookupByLibrary.simpleMessage("Ajout unique"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Importation unique"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Saisissez un seul lien ici ; pour en modifier plusieurs, utilisez la modification rapide de la liste",
    ),
    "singleValueTip": m173,
    "size": MessageLookupByLibrary.simpleMessage("Taille"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Ignorer la vérification du certificat",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Domaines ignorés"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Un domaine détecté figurant dans la liste des domaines ignorés n’est pas utilisé.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses de destination ignorées",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses sources ignorées",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Glissement"),
    "sliders": MessageLookupByLibrary.simpleMessage("Curseurs"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protocoles"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Le sniffer lit le domaine dans le trafic TLS, HTTP et QUIC afin que les règles puissent le reconnaître.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Port SOCKS"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Doux"),
    "sort": MessageLookupByLibrary.simpleMessage("Trier"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP source"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Proxy spécial"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Règles spéciales"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spectre"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Statistiques de débit",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Stratégie de répartition",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "La stratégie de répartition ne peut pas être vide",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("Les SSID sont vides"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Mode de pile"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Trace de pile"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Mode standard : ajoute des règles par-dessus le profil",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Démarrer"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("Partir de zéro"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Démarrage du VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Démarrage et arrière-plan",
    ),
    "status": MessageLookupByLibrary.simpleMessage("État"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Si DNS est désactivé, le DNS du système est utilisé.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Arrêter"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Arrêt du VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Stratégie"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Route stricte"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "La route stricte empêche le trafic tel que le DNS de contourner TUN et, avec IPv6 désactivé, bloque les connexions IPv6 de cet appareil.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "submit": MessageLookupByLibrary.simpleMessage("Valider"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage(
      "Automatiquement",
    ),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "User-Agent personnalisé",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Saisissez un User-Agent valide, sans caractères de contrôle.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Le choix du client n’envoie pas l’identité de l’appareil.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Demander en tant que",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Ces paramètres s’appliquent aux URL d’abonnement. Les liens proxy sont importés localement.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Saisissez la clé AGE pour vérifier cet abonnement.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Appliquer le résultat vérifié"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "Le serveur a refusé l’autorisation. La sélection des clients est arrêtée.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Vérifier",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Impossible d’obtenir un abonnement compatible. La configuration précédente est inchangée.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Vérifie les valeurs actuelles sans enregistrer ni redémarrer le VPN. Vérifie l’analyse, pas la disponibilité des nœuds.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Redemander pour les pertes à l’importation",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Masquer l’URL de l’abonnement",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Dernier client réussi"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "L’importation omet des données d’origine. Vérifiez les pertes avant d’appliquer.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Utiliser ce client"),
    "subscriptionCompatibilityPrepared": m174,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core a analysé ce résultat. Il n’est pas encore enregistré ni appliqué.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "Le serveur a limité les requêtes. Réessayez plus tard.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Afficher l’URL de l’abonnement",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "Le formulaire ou le profil a changé. Vérifiez à nouveau l’abonnement.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "La vérification de l’abonnement a expiré.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Compatibilité",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Échec de connexion. La sélection des clients est arrêtée.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Aucun emplacement d’appareil n’est disponible pour cet abonnement. Supprimez un appareil du compte du fournisseur, puis réessayez.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Cet abonnement exige l’enregistrement de l’appareil. Suivez les instructions du fournisseur.",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Votre abonnement a expiré",
    ),
    "subscriptionExpiresInDays": m175,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Votre abonnement expire aujourd’hui",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Envoyer aussi le système et le modèle de l’appareil",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "La version du système et le modèle de l’appareil seront également envoyés avec l’identifiant.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Un identifiant pseudonyme stable sera envoyé à cette origine d’abonnement. Il ne s’agit pas d’une attestation matérielle et le consentement reste sur cet appareil.",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "De nombreux abonnements cesseront de fonctionner si l\'envoi du HWID est désactivé.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Identité des abonnements",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "Envoyer HWID",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Utiliser le réglage global",
    ),
    "subscriptionImportAdd": m176,
    "subscriptionImportAllAdded": m177,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "configuration Clash",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "abonnement chiffré",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "liens proxy",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "format inconnu",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "Sections de la configuration",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "ReClash applique ses propres réglages à la place de ces parties de la source.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "Non repris",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Aucun des serveurs n’est pris en charge",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Certaines options des serveurs ne sont pas prises en charge et sont ignorées",
    ),
    "subscriptionImportPartial": m178,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "Débits montant et descendant manquants",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "Protocole non pris en charge",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "Transport non pris en charge",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Ne plus demander pour cet abonnement",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Si autre chose cesse d’être transféré, la question vous sera reposée.",
        ),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Tout ne sera pas transféré",
    ),
    "subscriptionImportShowAll": m179,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "Ne seront pas ajoutés",
    ),
    "subscriptionImportSourceFormat": m180,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Infos d’abonnement",
    ),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("Dev"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("Promo"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("Test"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Rappels d’abonnement",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Abonnement"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Compte",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Acheter un forfait",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Acheter du trafic",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "URL du logo",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Assistance",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Site web",
    ),
    "subscriptionTrafficLow": m181,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Utiliser l’intervalle du fournisseur",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Saisissez votre mot de passe pour sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspendu…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Changer de profil"),
    "sync": MessageLookupByLibrary.simpleMessage("Synchroniser"),
    "system": MessageLookupByLibrary.simpleMessage("Système"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Apps système"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Proxy système"),
    "tab": MessageLookupByLibrary.simpleMessage("Onglet"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage(
      "Animation des onglets",
    ),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Appuyez sur l’icône pour réessayer",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour autoriser",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Cible"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP simultané"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Impossible d’ouvrir Telegram sur cet appareil.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Ouvrir Telegram"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Ouvrir dans le navigateur",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Intervalle de test"),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL de test"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Tester à l’utilisation",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Taille du texte"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Le texte de l’app ressemblera à ceci",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Thème"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Couleur du thème"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Mode du thème"),
    "tight": MessageLookupByLibrary.simpleMessage("Serrée"),
    "time": MessageLookupByLibrary.simpleMessage("Heure"),
    "timeout": MessageLookupByLibrary.simpleMessage("Expiré"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Teinté"),
    "tip": MessageLookupByLibrary.simpleMessage("Astuce"),
    "tk": MessageLookupByLibrary.simpleMessage("Turkmène"),
    "toggle": MessageLookupByLibrary.simpleMessage("Basculer"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolérance"),
    "tools": MessageLookupByLibrary.simpleMessage("Outils"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Action"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Choisissez une section ou recherchez un réglage",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Toutes les connexions actives seront fermées. Continuer ?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("Action terminée"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Configuration"),
    "toolsData": MessageLookupByLibrary.simpleMessage("Ressources et données"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun réglage ni aucune action correspondante",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Informations et dépannage",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("Utilisés récemment"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Activez d’abord l’authentification",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Activez d’abord le contrôleur externe",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Démarrez le noyau pour cette action",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez d’abord une interface réseau personnalisée",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez d’abord la pile réseau MIPS",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Ajoutez d’abord cette surcharge sur la page DNS",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Configurez d’abord WebDAV",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Diagnostic"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Épingler"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Épinglés"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Redémarrer le noyau",
    ),
    "toolsResults": m182,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Exécuter"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Section"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Réglage"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Désépingler"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour les ressources",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "La mise à jour des règles et scripts peut réappliquer la configuration et affecter les connexions. Continuer ?",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Ajouter du trafic"),
    "torch": MessageLookupByLibrary.simpleMessage("Lampe torche"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Reçu"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Trafic total"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Envoyé"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Port TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafic"),
    "trafficPeak": m183,
    "trafficTotal": m184,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafic utilisé"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Proposer une correction de traduction",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportHeaders": m185,
    "trayIcon": MessageLookupByLibrary.simpleMessage("Icône de notification"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Couleur"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Noir"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Blanc"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage(
      "Réseaux de confiance",
    ),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "La VPN se met en pause sur ces réseaux",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Le réseau actuel est de confiance",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN n’a pas pu être autorisé et a donc été désactivé.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN ne fonctionne qu’en mode administrateur.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent les réglages TUN de tous les profils ; tout ce qui n’est pas ajouté garde le réglage du profil. Les entrées qu’un profil personnalisé ajoute lui-même priment.",
    ),
    "tunSetupApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "Autorisez le Helper TUN",
    ),
    "tunSetupConfirm": MessageLookupByLibrary.simpleMessage("Configurer"),
    "tunSetupDone": MessageLookupByLibrary.simpleMessage("TUN est activé"),
    "tunSetupInstallTitle": MessageLookupByLibrary.simpleMessage(
      "Configurer TUN",
    ),
    "tunSetupInstantStart": MessageLookupByLibrary.simpleMessage(
      "Ensuite, TUN démarre aussitôt, y compris à la connexion",
    ),
    "tunSetupLater": MessageLookupByLibrary.simpleMessage("Pas maintenant"),
    "tunSetupLinuxInstall": MessageLookupByLibrary.simpleMessage(
      "Pour faire passer tout le trafic du système par ReClash, TUN a besoin d’un Helper système : un service systemd qui lance le Core uniquement avec les droits réseau.",
    ),
    "tunSetupLinuxScope": MessageLookupByLibrary.simpleMessage(
      "Le Helper ne lance que le Core ReClash vérifié et ne lui accorde que des droits réseau",
    ),
    "tunSetupLinuxUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash a été mis à jour, et le Helper TUN doit se mettre à jour avec lui pour continuer à fonctionner.",
    ),
    "tunSetupMacosInstall": MessageLookupByLibrary.simpleMessage(
      "TUN a besoin du Helper ReClash. macOS vous demandera de l’autoriser une seule fois.",
    ),
    "tunSetupOnceConfirm": MessageLookupByLibrary.simpleMessage(
      "Windows demande une confirmation une seule fois pour cette version",
    ),
    "tunSetupOncePassword": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe administrateur est demandé une seule fois pour cette version",
    ),
    "tunSetupPasswordPrivacy": MessageLookupByLibrary.simpleMessage(
      "Saisissez le mot de passe uniquement dans la fenêtre système : ReClash ne le voit jamais.",
    ),
    "tunSetupUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "TUN est indisponible",
    ),
    "tunSetupUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour le Helper TUN",
    ),
    "tunSetupWaiting": MessageLookupByLibrary.simpleMessage(
      "En attente de confirmation dans la fenêtre système…",
    ),
    "tunSetupWindowsInstall": MessageLookupByLibrary.simpleMessage(
      "Pour faire passer tout le trafic du système par ReClash, TUN a besoin de ReClash Service, un service Windows qui lance le Core avec les droits qu’exige l’adaptateur réseau.",
    ),
    "tunSetupWindowsScope": MessageLookupByLibrary.simpleMessage(
      "Le service ne lance que le Core ReClash vérifié et n’accepte que votre compte",
    ),
    "tunSetupWindowsUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash a été mis à jour, et ReClash Service doit se mettre à jour avec lui pour que TUN continue de fonctionner.",
    ),
    "tunSetupWithoutTun": MessageLookupByLibrary.simpleMessage("Sans TUN"),
    "turnOff": MessageLookupByLibrary.simpleMessage("Désactiver"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Activer"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("Mode de relais UDP"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("Délai UDP"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Le délai UDP est en secondes et ne fonctionne qu’avec les piles gvisor, system et mixed.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Annuler"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Délai unifié"),
    "unknown": MessageLookupByLibrary.simpleMessage("Inconnu"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Erreur réseau inconnue",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restaurer"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Sans nom"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage(
      "Désépingler la fenêtre",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Mettre à jour"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Autoriser l’installation automatique",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash pourra installer les mises à jour stables vérifiées et admissibles sans vous le demander à chaque fois. Votre VPN ne sera jamais déconnecté. Android peut encore demander une confirmation.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Autoriser l’installation automatique ?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Installer automatiquement",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Annuler le téléchargement",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de mise à jour",
    ),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Préversion"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Version stable",
    ),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Rechercher automatiquement",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de rechercher des mises à jour",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre connexion et réessayez.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Recherche de mises à jour…",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage(
      "Fermer la fenêtre",
    ),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android demande votre accord. Continuez pour ouvrir la confirmation du système.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Confirmez avec Android",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Continuer en arrière-plan",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Continuer l’installation",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "Vous êtes à jour",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "Sur cette plateforme, ReClash ouvre la page de la version. Téléchargez et installez la mise à jour vous-même.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "Aucun téléchargement vérifié n’est disponible pour cet appareil. Choisissez un paquet sur la page de la version.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Déconnecter et installer",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Garder l’installation manuelle",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Télécharger la mise à jour",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Télécharger à nouveau",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de télécharger la mise à jour",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "La partie téléchargée est conservée. Vérifiez votre connexion puis reprenez.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Compris"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de démarrer l’installateur de paquets",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android n’a pas terminé l’installation. Réessayez quand vous le souhaitez.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage(
      "Installer maintenant",
    ),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Mise à jour installée",
    ),
    "updateInstalledVersion": m186,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android termine l’installation. ReClash peut se fermer pendant cette étape.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Installation de la mise à jour",
    ),
    "updateMinutes": m187,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Pas maintenant"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Aucune note de version disponible.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Une mise à jour est disponible",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Ouvrir les paramètres Android",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Compilation pour l’appareil",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage(
      "Taille du téléchargement",
    ),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Vérification du paquet",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Vérifié après le téléchargement, avant l’installation",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Intégrité, identité de l’app et signature vérifiées",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage(
      "Mettre en pause",
    ),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Téléchargement en pause",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisez ReClash à installer des applications depuis cette source, puis revenez pour continuer.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Autorisation Android nécessaire",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Réglez séparément la recherche, le téléchargement et l’installation.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Les préférences n’ont pas été enregistrées. Réessayez ; l’installation automatique n’a pas été activée.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Préférences de mise à jour",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage(
      "Télécharger par Wi-Fi",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Prête à être installée",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Détails de la version",
    ),
    "updateRemainingTime": m188,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Reprendre le téléchargement",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Reprendre"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Vérifier à nouveau",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Réessayer l’installation",
    ),
    "updateSeconds": m189,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Voir toutes les notes de version",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Afficher toutes les modifications",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Mises à jour"),
    "updateTransferSpeed": m190,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "L’intégrité de la mise à jour téléchargée n’a pas pu être vérifiée.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Le fichier, la version ou la signature n’a pas passé la vérification. Téléchargez une nouvelle copie pour réessayer.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Ce paquet ne peut pas être installé",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Vérification de la mise à jour",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "L’installation fermera brièvement ReClash. Déconnectez-vous uniquement si vous pouvez interrompre la connexion.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "Votre VPN est encore actif",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Envoi"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Bande passante d’envoi",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("Schéma d’URL"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Action"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage(
      "Ajouter un abonnement",
    ),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Ajouter une URL d’abonnement et un nom facultatif.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d’authentifier le lien chiffré. Il peut être endommagé ou utiliser une autre clé.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Créer un lien"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage(
      "Fermer l’application",
    ),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Utiliser le comportement de fermeture configuré.",
    ),
    "urlSchemeConfigCounts": m191,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Collez une configuration YAML ou JSON",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Contenu de la configuration",
    ),
    "urlSchemeConfirmMessage": m192,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Commande externe de l’application",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Les commandes externes de connexion et de fermeture demandent confirmation.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Connecter"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec le profil sélectionné.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Connexion"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Format du contenu",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "La conversion omet une partie du contenu. Vérifiez et approuvez ces changements lors de l’importation.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de copier le lien. Réessayez.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("Copier le lien"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Impossible de transmettre le lien, ou la file est pleine. Réessayez après la fin de l’action en cours.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Déconnecter"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Arrêter la connexion sans changer de profil.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration intégrée",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Profil d’exemple",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Formats"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Formats de liens. Remplacez les espaces réservés par votre URL ou vos données.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Importer une configuration",
    ),
    "urlSchemeImportConfirm": m193,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Intégrer une configuration YAML ou JSON au lien.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Vérifier un lien",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Collez un lien d’application ou de profil",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "La vérification reste sur cet appareil. Elle n’ouvre aucun lien, ne télécharge aucun abonnement et n’importe aucun profil.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "La structure du lien est valide. La disponibilité de l’abonnement et la validation du noyau sont vérifiées uniquement lors de l’importation.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Résultat de la vérification",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Installer une configuration",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Utiliser le format de lien d’abonnement des clients Clash.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "La configuration intégrée n’est pas un contenu UTF-8 Base64 valide.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "Le lien est mal formé. Vérifiez sa structure et l’encodage des caractères en pourcentage.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Utilisez un nom de profil de 64 caractères maximum, sans caractères de contrôle.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Saisissez une URL d’abonnement HTTP ou HTTPS valide.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "Le lien ne contient pas d’URL d’abonnement ou de configuration.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "Aucune action n’a été exécutée.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage(
      "Afficher l’application",
    ),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Afficher ReClash au premier plan.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire le presse-papiers. Collez le lien manuellement.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Lien"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Saisissez une URL ou une configuration pour créer le lien.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Les liens peuvent contenir des jetons ou identifiants. Partagez-les avec prudence.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Profils"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Liens de proxy",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage("Lien reconnu"),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Terminez la configuration de connexion avant d’utiliser les commandes externes de connexion.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Liens d’importation pris en charge",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Basculer la connexion",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Se connecter à l’arrêt, se déconnecter si actif.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "Le lien contient trop d’enveloppes imbriquées.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "Le lien dépasse 4 Mo ou sa configuration intégrée dépasse 2 Mo.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Cette commande de lien n’est pas prise en charge.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Cette version de chiffrement n’est pas prise en charge. Demandez un lien d’abonnement non chiffré.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage(
      "Utiliser l’exemple",
    ),
    "urlTip": m194,
    "useHosts": MessageLookupByLibrary.simpleMessage("Utiliser hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Utiliser les hosts du système",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("utilisé"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Trafic utilisé"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Nom d’utilisateur"),
    "uz": MessageLookupByLibrary.simpleMessage("Ouzbek"),
    "value": MessageLookupByLibrary.simpleMessage("Valeur"),
    "view": MessageLookupByLibrary.simpleMessage("Afficher"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("IPv4 virtuelle"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Vif"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Modification de la configuration liée au VPN détectée",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Le VPN fait passer automatiquement tout le trafic du système par VpnService.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Flou"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Opacité des cartes",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Assombrissement"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Réglages de l’image",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Utiliser un fond personnalisé",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage(
      "Ajustement de l’image",
    ),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Adapter"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Remplir"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Étirer"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Position horizontale",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Choisissez une image PNG, JPEG ou WebP valide.",
    ),
    "wallpaperImageLabel": m195,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Cadrage"),
    "wallpaperLibraryFull": m196,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Opacité de l’image",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("Lisibilité"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage(
      "Supprimer l’image",
    ),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser les effets",
    ),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le cadrage",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Impossible d’enregistrer le fond. Le précédent a été conservé.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Échelle"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG ou WebP · 20 Mo maximum",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("Fond personnalisé"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Choisissez une image de 20 Mo et 50 mégapixels maximum.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Image indisponible",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Position verticale",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuration WebDAV",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Interface web"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Accès"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Accès à l’interface terminé",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "Dans l’app",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "Dans le navigateur",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "L’accès est local et protégé par un secret. L’ouverture d’une interface ne modifie pas les réglages enregistrés du contrôleur externe.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d’appliquer la configuration de l’interface.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "Le téléchargement n’est pas une archive d’interface valide.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Le cœur a refusé les identifiants. Rouvrez l’interface.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "L’accès du navigateur reste actif jusqu’à son arrêt ou la fermeture de ReClash",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Une autre opération est en cours.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Opération annulée.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "La somme de contrôle ne correspond pas à la version fixée.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Le cœur n’est pas prêt.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Interfaces web locales de gestion du cœur",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de télécharger l’interface. Réessayez.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Téléchargement de l’interface",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "L’accès se termine à la fermeture de l’interface",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Terminer l’accès à l’interface",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Extraction de l’interface",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Interface"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Installer l’interface",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "L’interface sélectionnée est téléchargée à la première ouverture. La version est fixée et vérifiée par SHA-256.",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d’ouvrir le navigateur.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Aucune session d’interface",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez un profil avant d’ouvrir l’interface.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Non installée",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage(
      "Ouvrir l’interface",
    ),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Ouvrir dans le navigateur",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Recharger"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "L\'accès au tableau de bord est désactivé par votre fournisseur.",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "L’accès à l’interface est désactivé en mode sans échec.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire ou remplacer les fichiers en toute sécurité.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "L’archive dépasse la taille autorisée.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Le cœur ne fournit pas cette interface.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Vérification du téléchargement",
    ),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Mode liste blanche"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système règle aussi l’horloge système ; Android l’ignore.",
    ),
    "yearsAgo": m197,
    "yearsAgoShort": m198,
    "yes": MessageLookupByLibrary.simpleMessage("Oui"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Chinois simplifié"),
  };
}
