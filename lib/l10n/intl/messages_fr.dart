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

  static String m0(count, skipped) =>
      "${count} à ajouter, ${skipped} ignorés car déjà présents";

  static String m1(detail) => "Impossible d’effacer les données : ${detail}";

  static String m2(code) =>
      "Windows a refusé d’exécuter ReClashCore.exe (erreur ${code}). Une stratégie de contrôle des applications, telle que Smart App Control ou AppLocker, bloque les programmes non signés ; autorisez ReClash dans cette stratégie ou désactivez-la, puis réessayez.";

  static String m3(name) =>
      "L’app n’a pas réussi à finir de démarrer deux fois de suite. Pour sortir de cette boucle, le profil ${name} a été désélectionné et la configuration automatique a été ignorée. Vous pouvez le sélectionner de nouveau à tout moment.";

  static String m4(url) => "Créer un profil à partir de ${url} ?";

  static String m5(groups) =>
      "include-all a été retiré des groupes de proxys ${groups} ; ajoutez les proxys ou fournisseurs de proxys qu’ils utilisent";

  static String m6(count, label) =>
      "${Intl.plural(count, one: '1 règle SUB-RULE a été abandonnée, car les profils personnalisés ne prennent pas en charge les sous-règles', other: '${label} règles SUB-RULE ont été abandonnées, car les profils personnalisés ne prennent pas en charge les sous-règles')}";

  static String m7(message) =>
      "Le cœur ne peut pas analyser ce proxy : ${message}";

  static String m8(proxy, target) =>
      "${proxy} se connecte via ${target}, qui renvoie à ${proxy} ; la connexion boucle";

  static String m9(name) =>
      "Le nom ${name} est déjà utilisé par un autre proxy ou groupe de proxys";

  static String m10(path) =>
      "Les groupes de proxys se référencent mutuellement en boucle : ${path}";

  static String m11(name) =>
      "Le repli si vide doit être un proxy, mais ${name} n’existe pas ou est un groupe de proxys";

  static String m12(name, message) =>
      "${name} n’est pas une regex valide : ${message}";

  static String m13(name) => "Le proxy de connexion ${name} n’existe pas";

  static String m14(names) =>
      "Ces fournisseurs de proxys n’existent pas : ${names}";

  static String m15(names) =>
      "Ces proxys ou stratégies n’existent pas : ${names}";

  static String m16(name) =>
      "${name} est un nom de stratégie intégré et ne peut pas être utilisé ici";

  static String m17(count) =>
      "${count} éléments posent problème, et l’application de ce profil peut échouer";

  static String m18(count) =>
      "${Intl.plural(count, one: 'il y a 1 jour', other: 'il y a ${count} jours')}";

  static String m19(count) =>
      "${Intl.plural(count, other: 'il y a ${count} j')}";

  static String m20(label) =>
      "Voulez-vous vraiment supprimer les éléments sélectionnés (${label}) ?";

  static String m21(label) =>
      "Voulez-vous vraiment supprimer cet élément (${label}) ?";

  static String m22(label) => "Détails de ${label}";

  static String m23(name) =>
      "La connexion via ${name} renvoie au proxy qui l’utilise ; la connexion a donc été arrêtée";

  static String m24(label) => "${label} ne peut pas être vide";

  static String m25(label) => "${label} existe déjà";

  static String m26(count) => "${count} éléments en échec";

  static String m27(label, message) => "${label} : ${message}";

  static String m28(name) => "${name} est déjà à jour";

  static String m29(name) => "${name} mis à jour";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 groupe', other: '${count} groupes')}";

  static String m31(count) => "${count} expirés";

  static String m32(action) =>
      "Déjà utilisé par « ${action} ». L’enregistrer le déplace ici.";

  static String m33(actions) => "Non exporté : ${actions}";

  static String m34(modifiers) =>
      "Incluez au moins l’une de ces touches : ${modifiers}";

  static String m35(count) =>
      "${Intl.plural(count, one: 'il y a 1 heure', other: 'il y a ${count} heures')}";

  static String m36(count) =>
      "${Intl.plural(count, other: 'il y a ${count} h')}";

  static String m37(target) => "${target} n’est pas une stratégie valide";

  static String m38(proxyName) => "${proxyName} n’est pas un proxy valide";

  static String m39(providerName) =>
      "${providerName} n’est pas un fournisseur de proxys valide";

  static String m40(ruleSet) => "${ruleSet} n’est pas un jeu de règles valide";

  static String m41(subRule) => "${subRule} n’est pas un SUB_RULE valide";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 élément', other: '${count} éléments')}";

  static String m43(line, message) => "Ligne ${line} : ${message}";

  static String m44(appName) =>
      "1. Ouvrez Réglages système > Confidentialité et sécurité\n2. Choisissez Service de localisation\n3. Trouvez ${appName} dans la liste et cochez-le\n\nUne fois terminé, revenez dans l’app pour continuer. Merci de votre coopération.";

  static String m45(label, max) =>
      "${label} ne doit pas dépasser ${max} caractères";

  static String m46(size) => "${size} libérés";

  static String m47(count) =>
      "${Intl.plural(count, one: 'il y a 1 minute', other: 'il y a ${count} minutes')}";

  static String m48(count) =>
      "${Intl.plural(count, other: 'il y a ${count} min')}";

  static String m49(count) =>
      "${Intl.plural(count, one: 'il y a 1 mois', other: 'il y a ${count} mois')}";

  static String m50(count) =>
      "${Intl.plural(count, other: 'il y a ${count} m')}";

  static String m51(code) =>
      "Le serveur a refusé l’accès (HTTP ${code}). Le lien a peut-être expiré, ou les identifiants sont incorrects";

  static String m52(code) => "Le serveur a rejeté la requête (HTTP ${code})";

  static String m53(code) =>
      "Rien n’a été trouvé à cette adresse (HTTP ${code}). Vérifiez que l’URL est correcte";

  static String m54(detail) => "Échec de la requête réseau : ${detail}";

  static String m55(code) =>
      "Le serveur a rencontré un problème (HTTP ${code}). Réessayez plus tard";

  static String m56(label) => "Aucun élément (${label}) pour le moment";

  static String m57(label, min, max) =>
      "${label} doit être compris entre ${min} et ${max}";

  static String m58(label) => "${label} doit être un nombre";

  static String m59(label) => "${label} doit être compris entre 1024 et 49151";

  static String m60(port) => "Port ${port}";

  static String m61(added, skipped, failed) =>
      "Ajoutés : ${added} ; ignorés : ${skipped} ; échecs : ${failed}.";

  static String m62(days) =>
      "${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m63(date, days) =>
      "Expire le ${date}, ${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m64(time) => "Mis à jour ${time}";

  static String m65(label, profiles) =>
      "${label} est encore utilisé par ${profiles}, qui ne fonctionneront plus correctement s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m66(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxys')}";

  static String m67(name, count) => "${name} et autres (${count} proxys)";

  static String m68(removed) =>
      "Ces proxys seront supprimés : ${removed}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m69(removed, added) =>
      "Ces proxys seront supprimés : ${removed}. Ceux-ci seront ajoutés : ${added}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m70(label) =>
      "${label} est encore nommé par des règles, des groupes de proxys, des proxys de connexion, le DNS ou le NTP de ce profil, qui cesseront de fonctionner s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m71(count, label) =>
      "${Intl.plural(count, one: '1 groupe de proxys', other: '${label} groupes de proxys')}";

  static String m72(region, bypassed, proxied) =>
      "${region} : ${bypassed} applications dans la liste d’exclusion du VPN, ${proxied} dans la liste VPN. Les deux listes seront remplacées ; le mode et les autres réglages restent inchangés. Les correspondances de paquets et SDK sont des suggestions : vérifiez le résultat après application.";

  static String m73(region, value) =>
      "La région ${region} utilise : ${value}. Une liste personnalisée remplace les valeurs régionales.";

  static String m74(region, source) => "Suggestion : ${region} · ${source}";

  static String m75(region, value) =>
      "La région ${region} fournit ces DNS : ${value}. Les réglages manuels ici sont prioritaires.";

  static String m76(region) => "Profil du pays : ${region}";

  static String m77(value) => "MTU du TUN : ${value}";

  static String m78(value) => "Vérifications de services par défaut : ${value}";

  static String m79(region, value) =>
      "La région ${region} fournit le MTU ${value}. Ajoutez un réglage MTU pour utiliser votre propre valeur.";

  static String m80(count, label) =>
      "${Intl.plural(count, one: '1 règle', other: '${label} règles')}";

  static String m81(appName) => "${appName} (mode sans échec)";

  static String m82(count) =>
      "${Intl.plural(count, one: '1 seconde', other: '${count} secondes')}";

  static String m83(count) => "${count} actifs";

  static String m84(count) =>
      "${Intl.plural(count, one: '1 problème', other: '${count} problèmes')}";

  static String m85(time) => "Vérifié à ${time}";

  static String m86(count) =>
      "${Intl.plural(count, one: '1 réglage', other: '${count} réglages')}";

  static String m87(count) => "${count} profils disponibles";

  static String m88(step, total) => "${step} sur ${total}";

  static String m89(server) => "Essayer ${server}";

  static String m90(link) => "Aucun proxy n’a pu être lu dans ${link}";

  static String m91(label) => "${label} doit être un seul élément";

  static String m92(client, format, count) =>
      "Reçu comme ${client} : ${format}, ${count} nœuds proxy.";

  static String m93(sections) =>
      "Ces sections source ne seront pas transférées : ${sections}.";

  static String m94(count, format) =>
      "${count} nœuds proxy peuvent être importés depuis ${format}.";

  static String m95(count) => "${count} nœuds ne peuvent pas être convertis.";

  static String m96(count) => "${count} résultats";

  static String m97(value) => "Pic ${value}";

  static String m98(value) => "Total ${value}";

  static String m99(version) => "Version installée : ${version}";

  static String m100(count) => "${count} min";

  static String m101(time) => "Encore ${time}";

  static String m102(count) => "${count} s";

  static String m103(speed) => "${speed}/s";

  static String m104(nodes, groups, providers) =>
      "${nodes} proxys, ${groups} groupes, ${providers} fournisseurs distants";

  static String m105(action) =>
      "Ce lien demande « ${action} ». Autoriser ReClash à effectuer cette action ?";

  static String m106(name, source) =>
      "Importer « ${name} » depuis ${source} ? La validation du profil et la vérification des conversions suivront votre confirmation.";

  static String m107(label) => "${label} doit être une URL";

  static String m108(index) => "Fond ${index}";

  static String m109(count) =>
      "Vous pouvez conserver jusqu’à ${count} fonds. Supprimez-en un pour en ajouter un autre.";

  static String m110(version) => "Version installée : ${version}";

  static String m111(count) =>
      "${Intl.plural(count, one: 'il y a 1 an', other: 'il y a ${count} ans')}";

  static String m112(count) =>
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
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Réglages du contrôle d’accès",
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
    "addedRules": MessageLookupByLibrary.simpleMessage("Règles ajoutées"),
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
    "answers": MessageLookupByLibrary.simpleMessage("Réponses"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle d’accès des apps",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Conception de l’icône de l’app",
    ),
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
    "batchPreviewTip": m0,
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
    "clearDataFailed": m1,
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
    "color": MessageLookupByLibrary.simpleMessage("Couleur"),
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
    "coreBlockedByPolicyTip": m2,
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
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Test de plantage"),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createProfileFromUrlTip": m4,
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
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "Le nom est vide",
    ),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy ni fournisseur de proxys n’est sélectionné ; le cœur rejette donc ce groupe",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Assembler des groupes de proxys et des règles à partir des proxys de l’app et d’autres profils",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Ressources des profils personnalisés",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Les ressources des profils personnalisés regroupent des proxys, des fournisseurs de règles, des filtres et des jeux d’icônes.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Couper"),
    "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Tableau de bord"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Disponibles à l’ajout",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Échec de l’enregistrement de la modification ; elle a été annulée",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
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
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
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
    "details": m22,
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
    "dialerProxyLoopStopped": m23,
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
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Sans cette entrée, TUN détourne toutes les requêtes DNS vers le port 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Détournement DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Mode DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent le DNS de tous les profils URL et fichier ; tout ce qui n’est pas ajouté garde le réglage du profil. Les profils personnalisés définissent leur DNS dans leur contenu.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("Requêtes DNS"),
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
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("Anglais"),
    "enabled": MessageLookupByLibrary.simpleMessage("Activé"),
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
    "existsTip": m25,
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
    "extraLarge": MessageLookupByLibrary.simpleMessage("Très grande"),
    "fade": MessageLookupByLibrary.simpleMessage("Fondu"),
    "failedCount": m26,
    "failedItem": m27,
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
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Importer directement un fichier de profil",
    ),
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
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
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
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groupes"),
    "groupTimeoutCount": m31,
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
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Les raccourcis globaux fonctionnent même lorsque la fenêtre est masquée. Appuyez sur une action pour enregistrer sa combinaison de touches.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Raccourcis du bureau",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Associez une commande à un raccourci personnalisé dans les paramètres du bureau. ReClash doit être en cours d’exécution, mais sa fenêtre peut rester masquée. Gérez ces raccourcis globaux dans les paramètres du bureau.",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Les fichiers de configuration du compositeur ne sont pas disponibles. Vous pouvez toujours utiliser les commandes du bureau ci-dessus.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Ces combinaisons fonctionnent lorsque la fenêtre de l’application est active. Pour les raccourcis globaux, associez les commandes du bureau ci-dessous.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Gestion des raccourcis",
    ),
    "hotkeyNeedsModifier": m34,
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
    "hoursAgo": m35,
    "hoursAgoShort": m36,
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
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez un port ou une plage, par exemple 443 ou 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Ce code QR ne contient pas de lien de profil",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez des nombres ou des plages tels que 80 ou 8000-9000, séparés par /",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
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
    "itemsCount": m42,
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
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Retour à la ligne"),
    "link": MessageLookupByLibrary.simpleMessage("Lien"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Obtenir un profil depuis un lien d’abonnement ou un lien de partage de proxy",
    ),
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
    "locationPermissionGuide": m44,
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
    "maxLengthTip": m45,
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
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("Test de message"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Ceci est un message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Réduire"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Réduire à la fermeture",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Port mixte"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("Plus"),
    "name": MessageLookupByLibrary.simpleMessage("Nom"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Barre inférieure",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Réseau"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "La requête a été annulée",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Impossible de se connecter au serveur. Vérifiez votre connexion réseau ou vos réglages de proxy",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Impossible de résoudre l’adresse du serveur. Vérifiez que l’URL est correcte et que le DNS fonctionne",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Nom du réseau"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Trop de requêtes (HTTP 429). Patientez un instant puis réessayez",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Secret du réseau"),
    "networkServerError": m55,
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
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de synchronisation (minutes)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP récupère l’heure auprès d’un serveur NTP au lieu de l’horloge système.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Ajoutez un profil pour commencer",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
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
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "À la demande met le proxy en pause sur les Wi-Fi exclus.",
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
    "pluginHost": MessageLookupByLibrary.simpleMessage("Hôte du plugin"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Mode du plugin"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un autre port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Saut de port"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Clé prépartagée"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prérequis"),
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
    "profileBatchResult": m61,
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Le profil a été modifié. Désactiver la mise à jour automatique ?",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Un profil avec cette URL d\'abonnement existe déjà",
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
    "profileUpdatedAt": m64,
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
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Seuls les fournisseurs distants sont pris en charge",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Ressources externes"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxys"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Chaîne de proxys"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Groupe de proxys"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Le groupe de proxys est vide",
    ),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Les groupes s’affichent ici une fois le cœur démarré",
    ),
    "proxyGroupsCount": m71,
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
    "quickActions": MessageLookupByLibrary.simpleMessage("Actions rapides"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Modification rapide"),
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
    "regionAppsPreview": m72,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Aperçu de la sélection",
    ),
    "regionBypassSettings": m73,
    "regionChina": MessageLookupByLibrary.simpleMessage("Chine"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("Choisir un pays"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("Région actuelle"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Vos DNS et MTU manuels, exclusions, règles de routage et choix de services sont conservés.",
    ),
    "regionDetected": m74,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage(
      "Suggestion de l’appareil",
    ),
    "regionDnsSettings": m75,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Égypte"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Paramètres réseau et vérifications des services régionaux, indépendants de la langue de l’interface.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Les paramètres réseau et les vérifications restent inchangés.",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "Aucune suggestion correspondante. Seuls le fuseau horaire et les paramètres régionaux du système sont utilisés.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Vérifications des services désactivées",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Désactivée"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Autre / général"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "Sur Android, modifier le MTU ou les exclusions peut nécessiter un redémarrage confirmé du VPN. Les applications se sélectionnent séparément.",
    ),
    "regionPreviewBase": m76,
    "regionPreviewMtu": m77,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "Le choix du proxy et vos règles de routage restent inchangés.",
    ),
    "regionPreviewServices": m78,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage("Aperçu"),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage(
      "Paramètres du profil",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Russie"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Sélectionner les applications par région",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Choisissez une région prise en charge avant d’utiliser les suggestions d’applications régionales.",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "pays de la langue du système",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "langue du système",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage(
      "fuseau horaire",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Profil régional"),
    "regionTunSettings": m79,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage(
      "Utiliser la région détectée",
    ),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "Choisir un pays ne modifie que l’aperçu. Les paramètres régionaux changent après application.",
    ),
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
    "replace": MessageLookupByLibrary.simpleMessage("Remplacer"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Tout remplacer"),
    "request": MessageLookupByLibrary.simpleMessage("Requête"),
    "requests": MessageLookupByLibrary.simpleMessage("Requêtes"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requêtes et mises à jour",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Obligatoire"),
    "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Cette page contient des modifications. Voulez-vous vraiment réinitialiser ?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment réinitialiser ?",
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
    "rulesCount": m80,
    "runTime": MessageLookupByLibrary.simpleMessage("Durée d’exécution"),
    "running": MessageLookupByLibrary.simpleMessage("En cours d’exécution"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration d’exécution",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Mode sans échec"),
    "safeModeAppTitle": m81,
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
    "secondsCount": m82,
    "secretKey": MessageLookupByLibrary.simpleMessage("Clé"),
    "sectionsInEffect": m83,
    "selectAll": MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un jeu de règles",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une stratégie de répartition",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Sélectionné"),
    "server": MessageLookupByLibrary.simpleMessage("Serveur"),
    "serviceAbnormalCount": m84,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Tout est disponible",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Disponible"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloqué"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Tout vérifier"),
    "serviceCheckedAt": m85,
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
    "settingsCount": m86,
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
    "setupProfileCount": m87,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash ne fournit pas de serveurs. Importez un abonnement ou une configuration de votre fournisseur.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Importer un profil",
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
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage(
      "Utiliser ces paramètres régionaux",
    ),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "La région suggérée provient de cet appareil, et non de la langue de l’interface. Appliquez-la uniquement si elle correspond à votre réseau.",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Conserver les valeurs du profil",
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
    "setupStepStatus": m88,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Vos choix sont enregistrés. La connexion précédente n’a pas été arrêtée.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Vérification arrêtée",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Première connexion"),
    "setupTryServer": m89,
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
    "shareLinkUnreadable": m90,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy n’a pu être lu dans les liens",
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
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Flou de la barre latérale",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Afficher le bureau flouté derrière la fenêtre à travers la barre latérale",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage(
      "Lancement silencieux",
    ),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Le lancement silencieux démarre l’app sans afficher la fenêtre.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Ajout unique"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Importation unique"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Saisissez un seul lien ici ; pour en modifier plusieurs, utilisez la modification rapide de la liste",
    ),
    "singleValueTip": m91,
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
      "La route stricte empêche le trafic tel que le DNS de contourner TUN, et les autres appareils ne peuvent plus joindre celui-ci.",
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
    "subscriptionCompatibilityPrepared": m92,
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
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "Si cette option est activée, l’identifiant de l’appareil est envoyé avec les requêtes de tous les abonnements URL, sauf si un profil remplace ce réglage. Le système et les informations de l’appareil restent activés séparément pour chaque abonnement.",
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
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "Accepter et importer",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Je comprends que certaines données source ne seront pas conservées.",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "Continuer uniquement avec les nœuds compatibles.",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "Je comprends que les paramètres source seront omis.",
    ),
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
    "subscriptionImportIgnoredSections": m93,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Aucun nœud proxy compatible ne peut être importé.",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Mémoriser ce consentement pour l’abonnement",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "S’applique uniquement à cette source, à ce format et aux pertes acceptées. De nouvelles pertes nécessitent un nouveau consentement.",
        ),
    "subscriptionImportReviewSummary": m94,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Vérifier l’importation de l’abonnement",
    ),
    "subscriptionImportSkippedNodes": m95,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Infos d’abonnement",
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
    "toolsResults": m96,
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
    "torch": MessageLookupByLibrary.simpleMessage("Lampe torche"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Reçu"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Trafic total"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Envoyé"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Port TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafic"),
    "trafficPeak": m97,
    "trafficTotal": m98,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafic utilisé"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash parle votre langue pour que personne ne soit mis de côté. Si une formulation sonne mal à l\'oreille d\'un natif, signalez-la et nous la corrigerons.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Proposer une correction de traduction",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
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
    "updateAndroidAutoNote": MessageLookupByLibrary.simpleMessage(
      "Ces préférences n’accordent pas l’autorisation Android d’installer des apps. Vous pouvez les modifier à tout moment.",
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
    "updateAutoInstallDescription": MessageLookupByLibrary.simpleMessage(
      "Installer les mises à jour stables admissibles uniquement lorsque le VPN est désactivé. Les changements importants attendent toujours votre décision.",
    ),
    "updateBackgroundNote": MessageLookupByLibrary.simpleMessage(
      "Fermer cette fenêtre n’arrête pas le téléchargement.",
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
      "Impossible de rechercher des mises à jour.",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre connexion et réessayez.",
    ),
    "updateCheckQuietly": MessageLookupByLibrary.simpleMessage(
      "Vérifier régulièrement tant que ReClash fonctionne. La mise à jour apparaît dans le tableau de bord sans ouvrir de fenêtre.",
    ),
    "updateCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Recherche d’une version plus récente dans le canal choisi.",
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
    "updateDownloadDescription": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez fermer cette fenêtre. La progression reste dans le tableau de bord.",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de télécharger la mise à jour.",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "La partie téléchargée est conservée. Vérifiez votre connexion puis reprenez.",
    ),
    "updateExistingVersionSafe": MessageLookupByLibrary.simpleMessage(
      "Votre version installée reste inchangée.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Compris"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de démarrer l’installateur de paquets.",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android n’a pas terminé l’installation. Réessayez quand vous le souhaitez.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage(
      "Installer maintenant",
    ),
    "updateInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash utilise désormais la nouvelle version.",
    ),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Mise à jour installée",
    ),
    "updateInstalledVersion": m99,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android termine l’installation. ReClash peut se fermer pendant cette étape.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Installation de la mise à jour",
    ),
    "updateMinutes": m100,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage(
      "Vous utilisez déjà la dernière version.",
    ),
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Pas maintenant"),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage("Nouveautés"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Aucune note de version disponible.",
    ),
    "updateOfferDownloadNote": MessageLookupByLibrary.simpleMessage(
      "Le téléchargement n’installe pas la mise à jour et n’interrompt pas votre VPN.",
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
    "updatePackageVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage(
      "Mettre en pause",
    ),
    "updatePausedDescription": MessageLookupByLibrary.simpleMessage(
      "La partie téléchargée est conservée. Reprenez quand vous le souhaitez.",
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
    "updatePreferencesIntro": MessageLookupByLibrary.simpleMessage(
      "Les mises à jour à votre rythme",
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
    "updatePreloadDescription": MessageLookupByLibrary.simpleMessage(
      "Télécharger les mises à jour disponibles par Wi-Fi. Les téléchargements automatiques se mettent en pause hors Wi-Fi.",
    ),
    "updateReadyDescription": MessageLookupByLibrary.simpleMessage(
      "Le paquet a passé toutes les vérifications. Installez-le maintenant ou gardez-le pour plus tard.",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Prête à être installée",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Détails de la version",
    ),
    "updateRemainingTime": m101,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Reprendre le téléchargement",
    ),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Vérifier à nouveau",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Réessayer l’installation",
    ),
    "updateSeconds": m102,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Voir toutes les notes de version",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Afficher toutes les modifications",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Mises à jour"),
    "updateTransferSpeed": m103,
    "updateVerificationGuard": MessageLookupByLibrary.simpleMessage(
      "Un paquet qui échoue à la vérification ne sera jamais installé.",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "L’intégrité de la mise à jour téléchargée n’a pas pu être vérifiée.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Le fichier, la version ou la signature n’a pas passé la vérification. Téléchargez une nouvelle copie pour réessayer.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Ce paquet ne peut pas être installé",
    ),
    "updateVerifyingDescription": MessageLookupByLibrary.simpleMessage(
      "Vérification du fichier, de la version et du certificat de signature avant l’installation.",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Vérification de la mise à jour",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "L’installation fermera brièvement ReClash. Déconnectez-vous uniquement si vous pouvez interrompre la connexion.",
    ),
    "updateVpnInstallNote": MessageLookupByLibrary.simpleMessage(
      "L’installation fermera brièvement l’app. Votre VPN ne sera pas arrêté sans votre confirmation.",
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
      "Crée un profil à partir d’une URL d’abonnement HTTP ou HTTPS, avec un nom facultatif.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d’authentifier le lien chiffré. Il peut être endommagé ou utiliser une autre clé.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Créer un lien"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "Seuls les champs de cette action sont inclus. Un lien de configuration contient toutes les données et ne contourne jamais la confirmation.",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage(
      "Fermer l’application",
    ),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Suit votre choix de fermeture : masquer la fenêtre ou quitter ReClash. Android utilise son comportement habituel de fermeture.",
    ),
    "urlSchemeConfigCounts": m104,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Collez une configuration YAML ou JSON",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Contenu de la configuration",
    ),
    "urlSchemeConfirmMessage": m105,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Commande externe de l’application",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Les commandes externes de connexion et de fermeture demandent confirmation. Terminez la configuration avant d’utiliser les commandes de connexion.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Connecter"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Démarre la connexion avec le profil sélectionné et vos paramètres de couverture actuels.",
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
      "Arrête la connexion sans changer le profil sélectionné.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration intégrée",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Profil d’exemple",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Importer une configuration",
    ),
    "urlSchemeImportConfirm": m106,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Importe une configuration UTF-8 intégrée au lien en Base64, avec un nom facultatif.",
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
      "Importe un abonnement au format de lien install-config pris en charge par les clients Clash.",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "Reliez ReClash à des raccourcis, des sites et d’autres applications. Créez un lien prêt à l’emploi ou vérifiez-le avant de l’ouvrir.",
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
      "Place ReClash au premier plan sans modifier la connexion.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire le presse-papiers. Collez le lien manuellement.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Aperçu du lien"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Remplissez les champs obligatoires pour voir le lien.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Un lien peut contenir des jetons d’accès ou des identifiants de proxy. Partagez-le uniquement avec des personnes de confiance ; ReClash ne conserve aucun historique.",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "Les commandes de profil ouvrent le générateur. Chaque importation entrante demande confirmation et conserve les contrôles de validation et de conversion.",
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
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Les liens Clash, les enveloppes INCY et Happ et les liens de proxy fonctionnent aussi lors d’un import manuel et d’un scan QR. Les versions de chiffrement inconnues sont refusées.",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Basculer la connexion",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Connecte si elle est arrêtée, déconnecte si elle est active. La confirmation indique l’action réelle.",
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
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "Liens d’abonnement, configurations intégrées et INCY crypt1",
    ),
    "urlTip": m107,
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
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage(
      "Choisir une image",
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
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "Touchez un fond enregistré pour l’utiliser ou ajoutez-en un nouveau.",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Position horizontale",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Choisissez une image PNG, JPEG ou WebP valide.",
    ),
    "wallpaperImageLabel": m108,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Cadrage"),
    "wallpaperLibraryFull": m109,
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
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Accès à l’interface terminé",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "L’accès est local et authentifié. L’ouverture ne modifie pas les réglages enregistrés du contrôleur externe. Terminez l’accès ici après utilisation du navigateur.",
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
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage(
      "Fichiers de l’interface",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Interface"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Installer l’interface",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "L’interface sélectionnée est téléchargée à la première ouverture. La version est fixée et vérifiée par SHA-256.",
    ),
    "webDashboardInstalledVersion": m110,
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
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Mode liste blanche"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système règle aussi l’horloge système ; Android l’ignore.",
    ),
    "yearsAgo": m111,
    "yearsAgoShort": m112,
    "yes": MessageLookupByLibrary.simpleMessage("Oui"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Chinois simplifié"),
  };
}
