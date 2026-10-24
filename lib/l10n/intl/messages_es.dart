// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(count) =>
      "${Intl.plural(count, one: '${count} seleccionada', other: '${count} seleccionadas')}";

  static String m1(count) =>
      "Apps que tu proveedor deja fuera de la VPN: ${count}. Activa el control de acceso para cambiar la lista.";

  static String m2(name) => "${name} añadido a proxies locales";

  static String m3(name) => "${name} ya está en proxies locales";

  static String m4(count, skipped) =>
      "${count} por añadir, ${skipped} omitidos por ya existir";

  static String m5(detail) => "No se pudieron borrar los datos: ${detail}";

  static String m6(code) =>
      "Windows se negó a ejecutar ReClashCore.exe (error ${code}). Una directiva de control de aplicaciones, como Smart App Control o AppLocker, bloquea los programas sin firmar; permite ReClash en esa directiva o desactívala e inténtalo de nuevo.";

  static String m7(name) =>
      "La app no pudo terminar de iniciarse dos veces seguidas. Para romper el ciclo, se ha deseleccionado el perfil ${name} y se ha omitido la configuración automática. Puedes volver a seleccionarlo en cualquier momento.";

  static String m8(url) => "¿Quieres crear un perfil a partir de ${url}?";

  static String m9(groups) =>
      "Se descartó include-all de los grupos de proxies ${groups}; añade los proxies o proveedores de proxies que usan";

  static String m10(count, label) =>
      "${Intl.plural(count, one: 'Se descartó 1 regla SUB-RULE, porque los perfiles personalizados no admiten subreglas', other: 'Se descartaron ${label} reglas SUB-RULE, porque los perfiles personalizados no admiten subreglas')}";

  static String m11(message) =>
      "El núcleo no puede interpretar este proxy: ${message}";

  static String m12(proxy, target) =>
      "${proxy} marca a través de ${target}, que lleva de vuelta a ${proxy}, por lo que la marcación entra en bucle";

  static String m13(name) =>
      "El nombre ${name} ya lo usa otro proxy o grupo de proxies";

  static String m14(path) =>
      "Los grupos de proxies se referencian entre sí en bucle: ${path}";

  static String m15(name) =>
      "El respaldo si está vacío debe ser un proxy, pero ${name} no existe o es un grupo de proxies";

  static String m16(name, message) =>
      "${name} no es una expresión regular válida: ${message}";

  static String m17(name) => "El proxy de marcación ${name} no existe";

  static String m18(names) =>
      "Estos proveedores de proxies no existen: ${names}";

  static String m19(names) => "Estos proxies o políticas no existen: ${names}";

  static String m20(name) =>
      "${name} es un nombre de política integrada y no se puede usar aquí";

  static String m21(count) =>
      "${count} elementos tienen problemas, y aplicar este perfil puede fallar";

  static String m22(count) =>
      "${Intl.plural(count, one: 'hace 1 día', other: 'hace ${count} días')}";

  static String m23(count) => "${Intl.plural(count, other: 'hace ${count} d')}";

  static String m24(label) =>
      "¿Seguro que quieres eliminar los elementos seleccionados (${label})?";

  static String m25(label) =>
      "¿Seguro que quieres eliminar este elemento (${label})?";

  static String m26(label) => "Detalles de ${label}";

  static String m27(name) =>
      "La marcación a través de ${name} lleva de vuelta al proxy que lo usa, por lo que se detuvo la conexión";

  static String m28(label) => "${label} no puede estar vacío";

  static String m29(label) => "${label} ya existe";

  static String m30(count) => "${count} elementos fallaron";

  static String m31(label, message) => "${label}: ${message}";

  static String m32(name) => "${name} ya está actualizado";

  static String m33(name) => "${name} actualizado";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 grupo', other: '${count} grupos')}";

  static String m35(count) => "${count} sin respuesta";

  static String m36(action) =>
      "Ya lo usa “${action}”. Al guardar, pasará a este.";

  static String m37(actions) => "No exportado: ${actions}";

  static String m38(modifiers) =>
      "Incluye al menos una de estas teclas: ${modifiers}";

  static String m39(count) =>
      "${Intl.plural(count, one: 'hace 1 hora', other: 'hace ${count} horas')}";

  static String m40(count) => "${Intl.plural(count, other: 'hace ${count} h')}";

  static String m41(target) => "${target} no es una política válida";

  static String m42(proxyName) => "${proxyName} no es un proxy válido";

  static String m43(providerName) =>
      "${providerName} no es un proveedor de proxies válido";

  static String m44(ruleSet) => "${ruleSet} no es un conjunto de reglas válido";

  static String m45(subRule) => "${subRule} no es una SUB_RULE válida";

  static String m46(count) =>
      "${Intl.plural(count, one: '1 elemento', other: '${count} elementos')}";

  static String m47(line, message) => "Línea ${line}: ${message}";

  static String m48(appName) =>
      "1. Abre Ajustes del sistema > Privacidad y seguridad\n2. Elige Servicios de localización\n3. Busca ${appName} en la lista y márcalo\n\nCuando termines, vuelve a la app para continuar. Gracias por tu colaboración.";

  static String m49(label, max) =>
      "${label} debe tener como máximo ${max} caracteres";

  static String m50(size) => "Liberado: ${size}";

  static String m51(count) =>
      "${Intl.plural(count, one: 'hace 1 minuto', other: 'hace ${count} minutos')}";

  static String m52(count) =>
      "${Intl.plural(count, other: 'hace ${count} min')}";

  static String m53(count) =>
      "${Intl.plural(count, one: 'hace 1 mes', other: 'hace ${count} meses')}";

  static String m54(count) => "${Intl.plural(count, other: 'hace ${count} m')}";

  static String m55(code) =>
      "El servidor denegó el acceso (HTTP ${code}). Puede que el enlace haya caducado o que las credenciales sean incorrectas";

  static String m56(code) => "El servidor rechazó la solicitud (HTTP ${code})";

  static String m57(code) =>
      "No se encontró nada en esta dirección (HTTP ${code}). Comprueba que la URL sea correcta";

  static String m58(detail) => "Falló la solicitud de red: ${detail}";

  static String m59(code) =>
      "El servidor tuvo un problema (HTTP ${code}). Inténtalo de nuevo más tarde";

  static String m60(label) => "Aún no hay ningún elemento (${label})";

  static String m61(label, min, max) =>
      "${label} debe estar entre ${min} y ${max}";

  static String m62(label) => "${label} debe ser un número";

  static String m63(label) => "${label} debe estar entre 1024 y 49151";

  static String m64(port) => "Puerto ${port}";

  static String m65(added, skipped, failed) =>
      "Añadidos: ${added}; omitidos: ${skipped}; errores: ${failed}.";

  static String m66(days) =>
      "${Intl.plural(days, one: 'Queda 1 día', other: 'Quedan ${days} días')}";

  static String m67(date, days) =>
      "Vence el ${date}, ${Intl.plural(days, one: 'queda 1 día', other: 'quedan ${days} días')}";

  static String m68(name) => "Ya añadida como «${name}»";

  static String m69(client) => "Tal como la recibe la app ${client}";

  static String m70(count) =>
      "${Intl.plural(count, one: '1 servidor', other: '${count} servidores')}";

  static String m71(time) => "Actualizado ${time}";

  static String m72(label, profiles) =>
      "${label} sigue en uso en ${profiles}, que dejarán de funcionar correctamente si se elimina. ¿Seguro que quieres eliminarlo?";

  static String m73(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxies')}";

  static String m74(name, count) => "${name} y otros (${count} proxies)";

  static String m75(removed) =>
      "Se eliminarán estos proxies: ${removed}. Una línea cuyo nombre cambió cuenta como un proxy nuevo, y los perfiles personalizados que mencionen los eliminados los marcarán como ausentes. ¿Aplicar de todos modos?";

  static String m76(removed, added) =>
      "Se eliminarán estos proxies: ${removed}. Se añadirán estos: ${added}. Una línea cuyo nombre cambió cuenta como un proxy nuevo, y los perfiles personalizados que mencionen los eliminados los marcarán como ausentes. ¿Aplicar de todos modos?";

  static String m77(label) =>
      "${label} sigue mencionado por reglas, grupos de proxies, proxies de marcación, DNS o NTP de este perfil, que dejarán de funcionar si se elimina. ¿Seguro que quieres eliminarlo?";

  static String m78(count, label) =>
      "${Intl.plural(count, one: '1 grupo de proxies', other: '${label} grupos de proxies')}";

  static String m79(pick, now) => "Elegiría ${pick} en lugar de ${now}";

  static String m80(group) => "Comprobación en ${group}";

  static String m81(pick) => "Mantendría ${pick}";

  static String m82(number) => "Condición ${number}";

  static String m83(profile) => "«${profile}» quiere comprobar estos sitios";

  static String m84(profile) => "¿Eliminar «${profile}»?";

  static String m85(requests, used, cap) =>
      "Comprobaciones hoy: ${requests} · ${used} de ${cap}";

  static String m86(condition) => "excepto ${condition}";

  static String m87(country) => "salida ${country}";

  static String m88(member) => "Vía ${member}";

  static String m89(profile) => "Se añadió «${profile}»";

  static String m90(node) => "${node} dejó de funcionar";

  static String m91(from, to) => "Modo ${from} → ${to}";

  static String m92(line, text) => "Línea ${line}: ${text}";

  static String m93(check) =>
      "La comprobación ${check} nunca se usa, así que nunca se ejecuta";

  static String m94(hosts) => "Contacta con sitios de terceros: ${hosts}";

  static String m95(group) => "Esta configuración no tiene el grupo ${group}";

  static String m96(group) => "Ningún servidor de ${group} pasa el filtro";

  static String m97(tag) => "La etiqueta ${tag} nunca se usa";

  static String m98(tier, group) =>
      "Ahora ningún servidor de ${group} está en «${tier}»";

  static String m99(tier, after) =>
      "«${tier}» repite la condición de «${after}», así que nada llega a ella";

  static String m100(keys) =>
      "Traído; también cambiaste esto, así que se conservaron tus valores: ${keys}";

  static String m101(mode) => "Modo: ${mode}";

  static String m102(kind) => "Red: ${kind}";

  static String m103(tier) => "puede llegar a «${tier}» tras una comprobación";

  static String m104(node) => "Fijado: ${node}";

  static String m105(error) => "Error del perfil: ${error}";

  static String m106(profile) =>
      "No se encontró el perfil ${profile}; se usa el predeterminado";

  static String m107(error) =>
      "No se pudo guardar el estado del enrutamiento: ${error}";

  static String m108(tier) => "Cambiado a un servidor de «${tier}»";

  static String m109(from) =>
      "Servidor cambiado; ${from} se omite durante 15 minutos";

  static String m110(from) =>
      "${from} dejó de funcionar; cambiado al mejor de reserva";

  static String m111(from, gain) =>
      "Cambiado desde ${from}: ${gain} ms más rápido";

  static String m112(node) => "El escenario mantiene ${node}";

  static String m113(node) => "${node} no está en este grupo";

  static String m114(limit) =>
      "Límite de cambios alcanzado (${limit} por hora)";

  static String m115(mode) => "No se usa: modo ${mode}";

  static String m116(from) => "${from} ya no está en el grupo de servidores";

  static String m117(kind) =>
      "En pausa mientras la red es «${kind}»: no se comprueba ni se cambia nada";

  static String m118(node) => "El escenario cambia a ${node}";

  static String m119(node) => "Cambiado al servidor fijado ${node}";

  static String m120(node) => "Ningún servidor funciona; se usa ${node}";

  static String m121(scenario) =>
      "Ahora el escenario «${scenario}» dirige este grupo.";

  static String m122(count, total) => "${count} de ${total} coinciden";

  static String m123(node) =>
      "Cambiará a ${node} cuando una comprobación lo confirme";

  static String m124(node, gain) =>
      "Cambiará a ${node} si sigue ${gain} ms más rápido";

  static String m125(node, minutes) =>
      "Podrá cambiar a ${node} en ${minutes} min";

  static String m126(name) => "comprobación ${name}";

  static String m127(name) => "diagnóstico de red ${name}";

  static String m128(region, bypassed, proxied) =>
      "${region}: ${bypassed} aplicaciones en la lista de exclusión de VPN y ${proxied} en la lista de VPN. Se sustituirán ambas listas; el modo y los demás ajustes no cambian. Las coincidencias de paquetes y SDK son sugerencias: revisa el resultado al aplicarlo.";

  static String m129(seconds) => "Podrás confirmar en ${seconds} s";

  static String m130(count, label) =>
      "${Intl.plural(count, one: '1 regla', other: '${label} reglas')}";

  static String m131(appName) => "${appName} (Modo seguro)";

  static String m132(count) =>
      "${Intl.plural(count, one: '1 segundo', other: '${count} segundos')}";

  static String m133(count) => "${count} en vigor";

  static String m134(count) =>
      "${Intl.plural(count, one: '1 problema', other: '${count} problemas')}";

  static String m135(count) =>
      "${Intl.plural(count, one: '1 ajuste', other: '${count} ajustes')}";

  static String m136(count) => "Apps que evitan la VPN: ${count}";

  static String m137(count) => "Perfiles disponibles: ${count}";

  static String m138(step, total) => "${step} de ${total}";

  static String m139(server) => "Probar ${server}";

  static String m140(link) => "No se pudo leer ningún proxy de ${link}";

  static String m141(label) => "${label} debe ser un solo elemento";

  static String m142(client, format, count) =>
      "Recibido como ${client}: ${format}, ${count} nodos proxy.";

  static String m143(count) =>
      "${Intl.plural(count, one: 'Su suscripción caduca mañana', other: 'Su suscripción caduca en ${count} días')}";

  static String m144(count) =>
      "${Intl.plural(count, one: 'Añadir 1 servidor', other: 'Añadir ${count} servidores')}";

  static String m145(count) =>
      "${Intl.plural(count, one: 'Se añadirá el servidor', other: 'Se añadirán los ${count} servidores')}";

  static String m146(count, total) =>
      "Se añadirán ${count} de ${Intl.plural(total, one: '1 servidor', other: '${total} servidores')}";

  static String m147(count) => "Mostrar todos (${count})";

  static String m148(format) => "Formato: ${format}";

  static String m149(percent) => "Ha utilizado el ${percent}% de su tráfico";

  static String m150(count) => "${count} resultados";

  static String m151(value) => "Pico: ${value}";

  static String m152(value) => "Total: ${value}";

  static String m153(transport) => "Encabezados ${transport}";

  static String m154(version) => "Versión instalada: ${version}";

  static String m155(count) => "${count} min";

  static String m156(time) => "Quedan ${time}";

  static String m157(count) => "${count} s";

  static String m158(speed) => "${speed}/s";

  static String m159(nodes, groups, providers) =>
      "${nodes} proxies, ${groups} grupos, ${providers} proveedores remotos";

  static String m160(action) =>
      "Este enlace solicita «${action}». ¿Permitir que ReClash realice esta acción?";

  static String m161(name, source) =>
      "¿Importar «${name}» desde ${source}? Tras la confirmación se validará el perfil y se revisarán las conversiones necesarias.";

  static String m162(label) => "${label} debe ser una URL";

  static String m163(index) => "Fondo ${index}";

  static String m164(count) =>
      "Puedes guardar hasta ${count} fondos. Elimina uno para añadir otro.";

  static String m165(count) =>
      "${Intl.plural(count, one: 'hace 1 año', other: 'hace ${count} años')}";

  static String m166(count) =>
      "${Intl.plural(count, other: 'hace ${count} a')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Control de acceso"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Solo las apps seleccionadas usan la VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "El control de acceso elige qué apps usan el proxy.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "El control de acceso de apps está desactivado",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Las apps seleccionadas quedan excluidas de la VPN",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Ajustes de control de acceso",
    ),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Devolver las apps al proveedor",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Cuenta"),
    "action": MessageLookupByLibrary.simpleMessage("Acción"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Probar la latencia de todos",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Modo directo"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Modo global"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Cambiar modo"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Proxy del sistema"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Modo regla"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Iniciar/Detener"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Actualizar perfiles",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Mostrar/Ocultar"),
    "add": MessageLookupByLibrary.simpleMessage("Añadir"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Añadir proxy"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Añadir filtros"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Añadir red"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Añadir nodos"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Añadir entrada de sobrescritura",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Añadir perfil"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Añadir grupo de proxies",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Añadir regla"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Añadir ajuste"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Añadir SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Añadir a proxies locales",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Reglas añadidas"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Parámetros adicionales",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage(
      "Prefijo del nombre",
    ),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage(
      "Sufijo del nombre",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Dirección"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "Dirección del servidor WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Introduce una dirección WebDAV válida",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuración avanzada",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "La configuración avanzada incluye la red, el DNS, las reglas añadidas y los scripts.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Perfil cifrado",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage(
      "Clave secreta de age",
    ),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Este perfil está cifrado con age y necesita una clave secreta de age para descifrarse",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Aceptar"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Todos los proxies referenciados",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Todos los proveedores de proxies referenciados",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Permitir que las apps eludan la VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Permitir LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("IP permitidas"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("Respuestas"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Control de acceso de apps",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Icono de la app"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("Usar este icono"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Plano"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "La pantalla de inicio puede tardar unos segundos en mostrar el nuevo icono, y algunos lanzadores eliminan el acceso directo; vuelve a añadirlo desde la lista de aplicaciones.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Circuito"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Diseño del icono de la app",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Eco"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Tinta"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Añicos"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Solar"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Chispa"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Estándar"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Estratos"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Topo"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Trazo"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Terciopelo"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "No hay proxies locales",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage(
      "Región de la aplicación",
    ),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Fondo"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Interfaz"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Tema"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Añadir DNS del sistema",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Ajustes de la aplicación",
    ),
    "applied": MessageLookupByLibrary.simpleMessage("Aplicado"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Aplicar ahora"),
    "authentication": MessageLookupByLibrary.simpleMessage("Autenticación"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "La autenticación pide usuario y contraseña en el puerto del proxy local.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "El proxy del sistema no se aplica mientras la autenticación esté activada.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Autorizar"),
    "authorized": MessageLookupByLibrary.simpleMessage("Autorizado"),
    "auto": MessageLookupByLibrary.simpleMessage("Automático"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Buscar actualizaciones automáticamente",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Cerrar conexiones automáticamente",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Cerrar conexiones automáticamente corta las conexiones abiertas al cambiar de proxy.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage(
      "Incluir automáticamente",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Inicio automático"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Ejecución automática"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "La ejecución automática inicia el proxy al abrir la app.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Configurar DNS del sistema automáticamente",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage(
      "Actualización automática",
    ),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalo de actualización automática",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Atrás"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage(
      "Desenfoque de fondo",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Copia de seguridad"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Copia de seguridad y restauración",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Esta copia de seguridad procede de una versión más reciente de la app. Actualiza la app antes de restaurarla",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Copia de seguridad completada",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Información básica"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage(
      "Estrategias básicas",
    ),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Añadir en lote"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Importar en lote"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Un enlace por línea",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Un elemento por línea, o separados por comas",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Una entrada por línea: clave, un espacio y el valor",
    ),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Una URL por línea",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Ignorar la optimización de batería mantiene la app en ejecución en segundo plano.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Vincular"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Modo lista negra"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Bloquear conexión",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Brillo"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Dominios excluidos"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Los dominios excluidos solo se aplican mientras el proxy del sistema esté activado.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Omitir direcciones privadas",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Con Omitir direcciones privadas activado, las direcciones de LAN, loopback y multidifusión no pasan por TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Caché"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage(
      "Algoritmo de caché",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "La caché está dañada. ¿Borrarla?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Tamaño de caché"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a la cámara en los ajustes del sistema para escanear códigos QR, o elige una imagen de código QR del álbum.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere permiso de cámara",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Cámara no disponible",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Deseleccionar todo",
    ),
    "cannotSave": MessageLookupByLibrary.simpleMessage("No se puede guardar"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "No se pudo cambiar de proxy; se ha restaurado la selección anterior",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Cambios incompatibles",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Novedades"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Correcciones"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Rendimiento"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Reversiones"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Verificar certificados TLS",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Con la verificación TLS desactivada, las suscripciones y las copias de seguridad quedan expuestas a ataques de intermediario.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage(
      "Buscar actualizaciones",
    ),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "La app ya está actualizada",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Cifrado"),
    "clearData": MessageLookupByLibrary.simpleMessage("Borrar datos"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Esto elimina todos los perfiles, ajustes y datos locales, y luego cierra la app. Ábrela de nuevo para empezar de cero.",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage(
      "Borrar la caché DNS",
    ),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo borrar la caché DNS",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Borrar búsqueda"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Huella del cliente",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Exportar al portapapeles",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Importar desde el portapapeles",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo copiar al portapapeles. Puede que la selección sea demasiado grande",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Cerrar conexiones",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Cerrar todas las conexiones al pausar la VPN",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Contraste"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Estilo de color"),
    "columns": MessageLookupByLibrary.simpleMessage("Columnas"),
    "compact": MessageLookupByLibrary.simpleMessage("Compacto"),
    "compatible": MessageLookupByLibrary.simpleMessage(
      "Modo de compatibilidad",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres borrar todos los datos?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres eliminar este grupo de proxies?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres salir de la ventana actual?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres forzar el fallo del núcleo?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Control de congestión",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Control de congestión TCP",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "El control de congestión TCP solo funciona con la pila mips.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Conectado"),
    "connecting": MessageLookupByLibrary.simpleMessage("Conectando…"),
    "connection": MessageLookupByLibrary.simpleMessage("Conexión"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Estadísticas de conexión",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Conexiones activas, solicitudes recientes y consultas DNS",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Conexiones"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Conectividad: "),
    "content": MessageLookupByLibrary.simpleMessage("Contenido"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "El contenido no puede estar vacío",
    ),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Alto"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Medio"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Controlar las reglas añadidas globales",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiar"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copiar variables de entorno",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copiar enlace"),
    "copySuccess": MessageLookupByLibrary.simpleMessage(
      "Copiado correctamente",
    ),
    "core": MessageLookupByLibrary.simpleMessage("Núcleo"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Arquitectura"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control de Windows bloqueó ReClashCore.exe porque no está firmado. Abre Seguridad de Windows → Control de aplicaciones y navegador → Configuración de Smart App Control, elige Desactivado y vuelve a iniciar ReClash. Smart App Control no se puede volver a activar sin reinstalar Windows.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage(
      "Etiquetas de compilación",
    ),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage(
      "Hora de compilación",
    ),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Entorno"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage(
      "Ejecutable del Core",
    ),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer la información del Core",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Modo de ejecución"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Ubicación"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Proceso elevado administrado",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Proceso mediante Helper",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Biblioteca en el proceso",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Proceso administrado mediante Helper firmado",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage(
      "Proceso independiente",
    ),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Abrir configuración en tiempo de ejecución",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Plataforma"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("En ejecución"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuración en tiempo de ejecución",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Configuración generada tras aplicar los ajustes y scripts. Solo lectura.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer la configuración en tiempo de ejecución",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Iniciando…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Estado del núcleo"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Detenido"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Directorio de datos",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Región"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Fallo detectado"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("Prueba de fallo"),
    "create": MessageLookupByLibrary.simpleMessage("Crear"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("Fecha de creación"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("Evasión de DPI"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Base del cliente"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Funciones adicionales",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Funciones e ideas para proveedores",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Núcleo proxy"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Contiene el botón de inicio y no se puede quitar",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "customColor": MessageLookupByLibrary.simpleMessage("Color personalizado"),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "El nombre está vacío",
    ),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "No hay proxies ni proveedores de proxies seleccionados, por lo que el núcleo rechaza este grupo",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Recursos de perfil personalizado",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Los recursos de perfil personalizado son los proxies, proveedores de reglas, filtros y conjuntos de iconos que añades tú para usarlos en perfiles personalizados.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Cortar"),
    "dark": MessageLookupByLibrary.simpleMessage("Oscuro"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Panel"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Disponibles para añadir",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "No se pudo guardar el cambio; se ha revertido",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Selección predeterminada",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Predeterminado"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "La configuración debe ser un mapa YAML con un nombre y un tipo",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Latencia"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Fallido"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Prueba de latencia"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Tiempo de espera de la prueba de latencia",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Un cliente proxy multiplataforma basado en ClashMeta, sencillo de usar, de código abierto y sin anuncios.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "No hay un agente de autorización gráfico disponible. Inícialo en esta sesión de escritorio y vuelve a intentarlo.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Se canceló la autorización. TUN no se ha iniciado.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "No se concedió la autorización. TUN no se ha iniciado.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN requiere autorización. Inicia la conexión o activa TUN para autorizarlo.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "La autorización agotó el tiempo de espera. Vuelve a intentarlo con el botón de conexión.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "El Core autorizado no pudo completar un inicio verificado. Comprueba el paquete y los registros del sistema.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core o Helper no superó la comprobación de integridad. Reinstala un paquete completo de ReClash.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Permite el Helper de ReClash en Ajustes del Sistema → General → Ítems de inicio y extensiones, y vuelve a intentarlo.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "El Helper instalado usa otro protocolo. Comprueba si hay otra instalación o una configuración que anule el servicio y reinstala el paquete completo.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "No se puede sustituir de forma segura el registro existente del Helper de Linux. Comprueba la propiedad del servicio y su registro; repetir la autorización no resolverá el conflicto.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd no pudo iniciar el Helper de TUN. Revisa el registro del servicio; el instalador intentó restaurar la instalación anterior.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN requiere una sesión de Linux gestionada por systemd. Este sistema no puede ejecutar el Helper de red.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "El Helper de TUN no está disponible. Comprueba el paquete instalado y el servicio, y vuelve a intentarlo.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "La autorización o el cierre anterior de Core sigue pendiente. Espera a que termine antes de volver a intentarlo.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN requiere una app ReClash y un Helper correctamente firmados. No se puede autorizar una compilación sin firma o con firma ad-hoc.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core se inició, pero el adaptador TUN no está listo. Comprueba el registro de Core antes de usar TUN.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destino"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP de destino",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN de la IP de destino",
    ),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Depende de una API de terceros; solo con fines informativos",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Modo desarrollador"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "El modo desarrollador está activado.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Proxy de marcación"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "El proxy de marcación es la salida que se usa para llegar al servidor NTP.",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("Directo"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Desactivar reenvío ICMP",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "Con el reenvío ICMP desactivado, TUN responde él mismo al ping, por lo que ping ya no muestra la latencia real.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Desactivar keep-alive TCP",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Desactivar UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Desactivado"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "¿Descartar los cambios?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Aviso legal"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "Al instalar, copiar o usar el Software, se considera que has leído y aceptado esta declaración en su totalidad. Si no estás de acuerdo con alguno de sus términos, deja de usar el Software y desinstálalo de inmediato.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("Aceptación"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "He leído y entiendo esta declaración",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Para confirmar que lo entiendes, lee la siguiente declaración y marca la casilla de abajo:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Confirma la declaración",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Los desarrolladores pueden revisar esta declaración con cualquier versión, y la revisión entra en vigor cuando se publique dicha versión. Seguir usando el Software después de actualizar implica que aceptas la declaración revisada.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Cambios en esta declaración",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Antes de usar ReClash (“el Software”), lee con atención esta declaración y asegúrate de entenderla por completo. Pulsar “Aceptar” significa que has leído, comprendido y aceptado todos los términos siguientes. Si no estás de acuerdo, pulsa “Salir” y deja de usar el Software.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "En la máxima medida permitida por la ley aplicable, ni los desarrolladores ni ningún colaborador serán responsables de ningún daño directo, indirecto, incidental, especial, punitivo o emergente derivado del uso o de la imposibilidad de usar el Software, incluidos, entre otros, la pérdida de datos, los daños al dispositivo, los fallos de red, la interrupción de la actividad, el lucro cesante o cualquier disputa legal resultante, incluso si se les hubiera advertido de la posibilidad de tales daños.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Limitación de responsabilidad",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "El Software es de código abierto bajo la licencia GPL-3.0. Puedes usarlo, modificarlo y distribuirlo libremente siempre que cumplas dicha licencia, que exige que las obras derivadas se publiquen también bajo GPL-3.0 y que se conserven los avisos de derechos de autor originales.\n\nLos componentes de terceros del Software, incluido el núcleo Clash.Meta, siguen sus propias licencias. Los autores originales no se hacen responsables de ningún problema derivado de versiones modificadas o redistribuidas.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Licencia de código abierto",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "El Software en sí no proporciona ningún servidor proxy, nodo, suscripción ni servicio de acceso a la red, y no mantiene ninguna relación de asociación, representación ni garantía con ningún proveedor de dichos servicios.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "El Software no recopila ni sube tus URL de suscripción, los detalles de los nodos, el contenido de las configuraciones, los sitios web visitados, los registros de conexión, el contenido del tráfico ni los registros. Estos datos permanecen en tu dispositivo y los desarrolladores no tienen acceso a ellos.\n\nEl Software solo accede a la red cuando usas una función que lo necesita, como obtener la URL de suscripción que indicaste al actualizar un perfil o conectarse a GitHub al buscar actualizaciones.\n\nEl Software no incluye ningún servicio de analítica ni de informes de fallos en ninguna plataforma.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Recopilación de datos y privacidad",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Leer hasta el final",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Eres responsable de asegurarte de que el uso del Software sea legal donde vives, y asumes tú solo la responsabilidad legal de todo lo que hagas con él y de sus consecuencias.\n\nLas suscripciones, los nodos y las configuraciones que importas son decisión tuya. Que su origen sea legal, su contenido seguro y su servicio fiable es un asunto entre tú y sus proveedores.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Tu responsabilidad",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Escribe la declaración anterior",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "No coincide con la declaración",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Para confirmar que lo entiendes, escribe la siguiente declaración completa en el campo de abajo:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Repite la declaración",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "El Software es un cliente proxy de red de código abierto basado en el núcleo Clash.Meta (mihomo). Solo ofrece herramientas locales como la gestión de configuración, el enrutamiento basado en reglas y el reenvío de tráfico.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Naturaleza del software",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Los enlaces de suscripción, los archivos de configuración, los conjuntos de reglas, los scripts, los recursos externos y los enlaces externos los proporcionan terceros. Los desarrolladores no pueden revisar ni garantizar, ni lo hacen, su legalidad, exactitud, seguridad o disponibilidad.\n\nCualquier fuga de datos, pérdida económica, bloqueo de cuenta u otra pérdida causada por contenido de terceros debe resolverse entre tú y el tercero; los desarrolladores no asumen ninguna responsabilidad por ello.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Contenido de terceros",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "El Software está destinado únicamente a usos no comerciales, como el aprendizaje, el intercambio y la investigación técnica. Queda estrictamente prohibido usarlo con cualquier fin comercial, incluidos, entre otros, la distribución de pago, la venta en paquete, su uso como parte de un servicio comercial o hacer negocio en nombre del Software. Cualquier actividad comercial no guarda relación con el Software ni con sus desarrolladores.\n\nQueda estrictamente prohibido usar el Software para cualquier fin que infrinja las leyes y normativas de tu país o región, incluidos, entre otros, eludir restricciones de acceso a la red impuestas legalmente, difundir contenido ilegal, lanzar ataques a la red o vulnerar los derechos legítimos de otras personas.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Restricciones de uso",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "El Software se proporciona “tal cual” y “según disponibilidad”, sin garantía de ningún tipo, expresa o implícita, incluidas, entre otras, las garantías de comerciabilidad, idoneidad para un fin concreto, no infracción, disponibilidad ininterrumpida, ausencia de errores o ausencia de vulnerabilidades de seguridad.\n\nLos desarrolladores no garantizan que el Software satisfaga tus necesidades ni que funcione sin interrupciones ni errores.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Sin garantía",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Desconectado"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Nueva versión disponible",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "Caché DNS borrada",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Sin esta entrada, TUN secuestra todas las consultas DNS al puerto 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Secuestro de DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Modo DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Las entradas añadidas aquí sustituyen el DNS de todos los perfiles de URL y de archivo; lo que no añadas conserva el ajuste del propio perfil. Los perfiles personalizados definen su DNS en su contenido.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("Consultas DNS"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Se eliminan todas las anulaciones de DNS y se vuelven a establecer los servidores DNS de la región seleccionada.",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Fija"),
    "domain": MessageLookupByLibrary.simpleMessage("Dominio"),
    "done": MessageLookupByLibrary.simpleMessage("Hecho"),
    "download": MessageLookupByLibrary.simpleMessage("Descarga"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Ancho de banda de descarga",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Descargando actualización",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Duración"),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("Editar panel"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Editar reglas globales",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Editar red"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Editar proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Editar grupo de proxies",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Editar regla"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Editar SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Editor no disponible",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Tardó"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage(
      "Respaldo si está vacío",
    ),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("Inglés"),
    "enabled": MessageLookupByLibrary.simpleMessage("Activado"),
    "enterManually": MessageLookupByLibrary.simpleMessage(
      "Introducir manualmente",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" entradas"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Detalles del error"),
    "es": MessageLookupByLibrary.simpleMessage("Español"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Ocultar de aplicaciones recientes",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Puertos de destino excluidos",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "El tráfico hacia los puertos de destino excluidos no pasa por TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage(
      "Filtro de exclusión",
    ),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces excluidas",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "El tráfico que llega por las interfaces excluidas, como docker0, no pasa por TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Puertos de origen excluidos",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "El tráfico desde los puertos de origen excluidos no pasa por TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Excluir SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Al conectarte a una red Wi-Fi con un SSID excluido, el estado de ejecución de la app cambia automáticamente.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage(
      "ID de usuario excluidos",
    ),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "El tráfico de los procesos de los ID de usuario excluidos no pasa por TUN.",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("Salir"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Salir de pantalla completa",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Nodos de salida"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Estado esperado"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Fecha de vencimiento"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Exportar archivo"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Exportar registros"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportación completada",
    ),
    "extend": MessageLookupByLibrary.simpleMessage("Extensión"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Modo de extensión"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Script de extensión"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Controlador externo",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "El controlador externo permite controlar el núcleo en el puerto 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Clave del controlador externo",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Enlace externo"),
    "extra": MessageLookupByLibrary.simpleMessage("Extra"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Muy grande"),
    "fade": MessageLookupByLibrary.simpleMessage("Fundido"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Filtro Fake-IP"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Modo de filtro Fake-IP",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "En el modo de filtro Fake-IP, la lista negra excluye las coincidencias, la lista blanca aplica Fake-IP solo a las coincidencias y rule coincide según las reglas.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Rango Fake-IP"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Rango Fake-IP (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("TTL de Fake-IP"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage(
      "Filtro de respaldo",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Archivo"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "El archivo se ha modificado. ¿Guardar los cambios?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filtro"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtros"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Buscar proceso"),
    "floating": MessageLookupByLibrary.simpleMessage("Flotante"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Seguir perfil"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Seguir el sistema"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Familia de fuente"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Tamaño"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("Forzar mapeo DNS"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Forzar mapeo DNS también analiza las conexiones cuyo dominio provino de un mapeo DNS.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Forzar dominios"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Los dominios forzados también se analizan; las demás conexiones que ya tienen dominio se dejan como están.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres forzar el reinicio del núcleo?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Francés"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Las entradas añadidas aquí sustituyen el ajuste correspondiente de todos los perfiles; lo que no añadas conserva el ajuste del propio perfil, o el valor predeterminado del núcleo si el perfil no lo define.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Modo geo de poca memoria",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Ir"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Descargar"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Ir a la configuración de las reglas añadidas",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Ir a la configuración del script",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Agradecimientos"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash existe gracias a su trabajo",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Cuadrícula"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("grupos"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "¿Guardar los cambios en la caché?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Hash por usuario de entrada",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage(
      "Comprobación de estado",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "El servicio auxiliar (Helper) no está disponible; no se puede activar el modo TUN. Reinstala ReClash para restaurarlo.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Ocultar de la lista"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Ocultar IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Ocultar contraseña"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Ocultar proxies sin respuesta",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Omite los proxies cuya última prueba de latencia superó el tiempo de espera",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Intervalo de salto"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostname": MessageLookupByLibrary.simpleMessage("Nombre de host"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Borrar todo"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar todas las combinaciones de teclas?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Configuración del compositor",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "También puedes añadir una línea include a la configuración del compositor. Estos archivos siguen los atajos configurados en ReClash y se vacían temporalmente durante la grabación. La configuración del escritorio nunca se modifica automáticamente; resuelve allí cualquier conflicto.",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Los atajos globales funcionan incluso con la ventana oculta. Toca una acción para grabar su combinación de teclas.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Atajos del escritorio",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Asigna un comando a un atajo personalizado en la configuración del escritorio. ReClash debe estar en ejecución, aunque la ventana puede permanecer oculta. Gestiona estos atajos globales desde la configuración del escritorio.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Los archivos de configuración del compositor no están disponibles. Aún puedes usar los comandos del escritorio anteriores.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "These combinations work while the app window is focused. For global shortcuts, connect desktop commands using the section below.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Gestión de atajos",
    ),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Sin asignar"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Restaurar valores predeterminados",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "¿Reemplazar todas las combinaciones por los valores predeterminados?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "El modo seguro desactiva las acciones de los atajos; las asignaciones se pueden editar.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "No registrado; puede que otra app lo esté usando",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("horas"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("Tono"),
    "icon": MessageLookupByLibrary.simpleMessage("Icono"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Registros de iconos"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Conjuntos de iconos"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Aún no hay conjuntos de iconos. Añádelos en Recursos de perfil personalizado → Conjuntos de iconos",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Estilo de icono"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Relleno"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Oculto"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Simple"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL del icono"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignorar optimización de batería",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importar"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Este archivo no es una configuración importable",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Al importar se reemplazan los grupos de proxies, las reglas y los ajustes que tiene ahora este perfil",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage(
      "Importar desde archivo",
    ),
    "importFromLink": MessageLookupByLibrary.simpleMessage(
      "Importar desde enlace",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("Importar desde URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Entrada"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces incluidas",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Solo el tráfico que llega por las interfaces incluidas pasa por TUN, y las interfaces excluidas dejan de aplicarse.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage(
      "ID de usuario incluidos",
    ),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Solo el tráfico de los procesos de los ID de usuario incluidos pasa por TUN.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("No caduca"),
    "init": MessageLookupByLibrary.simpleMessage("Inicio"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Error al iniciar"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash encontró un error al iniciarse y no puede continuar. Copia los detalles para informar del problema. Si sigue ocurriendo, borrar los datos suele permitir que la app vuelva a iniciarse.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Origen de la solicitud"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("De"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Introduce el nombre del grupo de proxies",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Introduce el contenido de la regla",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage(
      "Instalar actualización",
    ),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "Se denegó el permiso de lista de apps, por lo que no se pueden mostrar las apps instaladas. Concédelo manualmente en los ajustes del sistema.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Este sistema oculta la lista de apps instaladas hasta que se concede el permiso. Autorízalo para configurar el proxy por app.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere permiso de lista de apps",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Fuentes instaladas",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Selección inteligente",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Nombre de interfaz"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "El nombre de interfaz es la interfaz de red que usan las conexiones salientes.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Interfaz de salida",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Ninguna"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage(
      "Personalizada",
    ),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Seguir configuración",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Intervalo"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP de intranet"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Archivo de copia de seguridad no válido",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Introduce un rango de IP en formato CIDR, como 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "Una marca DSCP no puede superar 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Introduce un dominio o una dirección IP",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "No es un conjunto de iconos válido",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "No es un enlace de suscripción ni un enlace para compartir proxies",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Introduce una dirección y un puerto, como 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Solo se admite tcp o udp",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Introduce un puerto o un rango como 443 u 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Este código QR no contiene un enlace de perfil",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Introduce números o rangos como 80 u 8000-9000, separados por /",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "Un SSID no puede superar 32 bytes UTF-8",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("Dirección IP"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Historial de abusos"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Indicadores"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organización"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo determinar el tipo de IP",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Buena"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Nivel"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage(
      "Comprobar de nuevo",
    ),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Arriesgada"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Calidad"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Respondido por"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Fuentes"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "IP de salida distinta",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Sin tipo"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Límite de solicitudes",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Tipo"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Empresarial"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Centro de datos"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Red móvil"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Residencial"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Tipo desconocido"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("Versión de IP"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "El tráfico IPv6 solo se recibe mientras IPv6 esté activado.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Con IPv6 activado, la VPN permite el tráfico IPv6 entrante.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "Tiempo de espera IPv6 (ms)",
    ),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("Japonés"),
    "justNow": MessageLookupByLibrary.simpleMessage("Ahora mismo"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "Inactividad de keep-alive TCP",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Intervalo de keep-alive TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Clave"),
    "kk": MessageLookupByLibrary.simpleMessage("Kazajo"),
    "ko": MessageLookupByLibrary.simpleMessage("Coreano"),
    "label": MessageLookupByLibrary.simpleMessage("Etiqueta"),
    "language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "large": MessageLookupByLibrary.simpleMessage("Grande"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Última actualización"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "El inicio no se completó",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "La última vez, la app se cerró inesperadamente mientras se iniciaba. En este inicio se ha omitido la configuración automática; puedes iniciarla manualmente para reintentarlo.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Diseño"),
    "license": MessageLookupByLibrary.simpleMessage("Licencia"),
    "licenses": MessageLookupByLibrary.simpleMessage("Licencias"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Paquetes incluidos en la aplicación",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Claro"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Ajuste de línea"),
    "link": MessageLookupByLibrary.simpleMessage("Enlace"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("Lista"),
    "listen": MessageLookupByLibrary.simpleMessage("Escucha"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Marca de enrutamiento de escucha",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "La marca de enrutamiento de escucha solo funciona en Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Conexiones activas",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Cargando…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localImage": MessageLookupByLibrary.simpleMessage("Imagen local"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Permiso de red local denegado: con la pila gvisor, la LAN no es accesible.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Proxies locales"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Permiso de ubicación",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Se denegó el permiso de ubicación, por lo que no se puede leer el nombre de la red Wi-Fi actual. Activa el permiso de ubicación manualmente en los ajustes del sistema.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "El sistema requiere el permiso de ubicación para leer el nombre de la red Wi-Fi. En Android elige “Permitir todo el tiempo”; de lo contrario, no se podrá leer el nombre de la red Wi-Fi mientras la app esté en segundo plano.",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere permiso de ubicación",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Registro"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Nivel de registro"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Si desactivas Logcat, se oculta la entrada de registros.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Registros"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Registros y diagnóstico",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Prueba de registros"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Exención de loopback de UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Amplio"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Mantenedor"),
    "matchCase": MessageLookupByLibrary.simpleMessage(
      "Coincidir mayúsculas y minúsculas",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Coincidir con IP de origen",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Máximo de fallos"),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximizar"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Memoria residente",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App y compartida"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Heap inactivo"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Heap en uso"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "El núcleo no se está ejecutando",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Sobrecarga del runtime",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage(
      "Pilas de goroutines",
    ),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimado a partir de la memoria residente del proceso; puede diferir de lo que indica el sistema.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "El núcleo se ejecuta dentro del proceso de la app. Su parte se estima a partir de las estadísticas del runtime, y el resto cuenta como memoria de la app y compartida.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage(
      "Información de memoria",
    ),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Memoria que usan la app y el núcleo",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Memoria liberada"),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("Prueba de mensaje"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Esto es un mensaje.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimizar"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Minimizar al salir",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("minutos"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Puerto mixto"),
    "mode": MessageLookupByLibrary.simpleMessage("Modo"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Icono monocromo"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monocromo"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("Más"),
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Barra inferior",
    ),
    "navigationLabels": MessageLookupByLibrary.simpleMessage(
      "Etiquetas de pestañas",
    ),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Siempre"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Nunca"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage("Activa"),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Navegación"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Barra de pestañas",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Barra lateral",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Red"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Se canceló la solicitud",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "No se pudo conectar con el servidor. Comprueba tu conexión de red o los ajustes del proxy",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Wi-Fi de casa) o subred (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "No se pudo resolver la dirección del servidor. Comprueba que la URL sea correcta y que el DNS funcione",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Nombre de la red"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Demasiadas solicitudes (HTTP 429). Espera un momento e inténtalo de nuevo",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "La lista de exclusiones y el MTU de TUN vuelven a los valores de la región seleccionada.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Clave de la red"),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Velocidad de red"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Control del tráfico",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Se agotó el tiempo de espera de la solicitud. Comprueba tu red o el proxy e inténtalo de nuevo",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Falló la conexión segura. Puede que el certificado del servidor no sea válido o que la conexión esté siendo interceptada",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Tipo de red"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Coincidencia siguiente"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noData": MessageLookupByLibrary.simpleMessage("Sin datos"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Sin información"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "No volver a recordármelo",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Sin red"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Apps sin red"),
    "noResolve": MessageLookupByLibrary.simpleMessage("No resolver IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "No resolver nombre de host",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No hay resultados",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Nodos"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Este recurso externo no es un archivo de texto",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Ninguno"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Detenido"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "No se puede seleccionar el grupo de proxies actual",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "La red actual no es de confianza",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Notificaciones"),
    "notificationActive": MessageLookupByLibrary.simpleMessage(
      "Protección activa",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Añadir componente",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Grupo automático",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "No hay grupo de servidores disponible",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Componentes de notificación",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Componga la notificación con datos en tiempo real.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Sin componentes",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Añada componentes para mostrar datos en tiempo real.",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Contenido"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Servidor actual",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Entrega en Android",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Comprobando el acceso a notificaciones",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Las notificaciones de ReClash están bloqueadas",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Se pueden entregar notificaciones",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "El canal del servicio está desactivado",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "El canal de recordatorios está desactivado",
        ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Ocultar velocidad inactiva",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Ocultar detalles sensibles en la pantalla de bloqueo",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Utiliza la privacidad de Android para las notificaciones del servicio y los recordatorios. Los detalles permanecen visibles al desbloquear.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Detallado muestra información en tiempo real y el botón de detener. Mínimo solo muestra el estado de protección.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Velocidad de red",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Recordatorios",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "El grupo elegido ya no existe",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Canal del servicio",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Tráfico de la sesión",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de recordatorios de suscripción",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Recordatorios de suscripción",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Reciba avisos antes de que caduque su suscripción o se agote el tráfico.",
        ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Nivel de notificación",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Detallado",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Mínimo",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalo de sincronización (minutos)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP obtiene la hora de un servidor NTP en lugar del reloj del sistema.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Añade un perfil para empezar",
    ),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("Ofuscación"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Host de ofuscación"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Modo de ofuscación"),
    "obfsParam": MessageLookupByLibrary.simpleMessage(
      "Parámetro de ofuscación",
    ),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña de ofuscación",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("Bajo demanda"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Esta subred confía en muchas redes",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Cerrar conexiones",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Bajo demanda pausa el proxy en las redes Wi-Fi excluidas.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("Parada completa"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Quitar TUN y cerrar los puertos proxy locales durante la pausa. La aplicación sigue vigilando la red para reanudar automáticamente.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Pausar"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Reanudar"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron leer las redes Wi-Fi. Reintenta o introduce una red manualmente.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "Exigir SSID y subred",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Si hay reglas de ambos tipos, deben coincidir un SSID y una subred",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Contar solo el tráfico del proxy",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Opcional"),
    "options": MessageLookupByLibrary.simpleMessage("Opciones"),
    "other": MessageLookupByLibrary.simpleMessage("Otros"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Otros colaboradores",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Salida"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Salida"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("IP de salida"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Modo de salida"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Sobrescribir destino",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Sobrescribir destino se conecta al dominio detectado en lugar de a la dirección original.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Entradas de sobrescritura",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Analizar IP pura"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Analizar IP pura analiza las conexiones que solo llevan una dirección IP.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "paste": MessageLookupByLibrary.simpleMessage("Pegar"),
    "peers": MessageLookupByLibrary.simpleMessage("Pares"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Elegir del álbum"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Elegir una red"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Redes Wi-Fi cercanas",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "No se encontraron redes Wi-Fi",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Se requiere permiso de ubicación para listar redes Wi-Fi",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a la ubicación para ver las redes Wi-Fi cercanas o introduce una red manualmente.",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Buscando redes Wi-Fi…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Fijar ventana"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("Vincula WebDAV"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Introduce un nombre para el script",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Sube un código QR válido",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Complemento"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage(
      "Cifrado del complemento",
    ),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Host del complemento"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Modo del complemento"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña del complemento",
    ),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Ruta del complemento"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Usuario del complemento",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Puerto"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Introduce un puerto diferente",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Salto de puertos"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("Puertos"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Clave precompartida"),
    "preferred": MessageLookupByLibrary.simpleMessage("Preferido"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Requisitos previos"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Pulsa Atrás otra vez para salir",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Pulsa una combinación de teclas",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Evitar suscripciones duplicadas",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Rechazar un enlace de suscripción que ya usa un perfil existente",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Vista previa"),
    "previousMatch": MessageLookupByLibrary.simpleMessage(
      "Coincidencia anterior",
    ),
    "privateKey": MessageLookupByLibrary.simpleMessage("Clave privada"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Frase de contraseña de la clave privada",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Proceso"),
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Introduce un intervalo válido"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Introduce el intervalo de actualización automática",
        ),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "El perfil se ha modificado. ¿Desactivar la actualización automática?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Cargando la página de suscripción…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "Descargando la suscripción…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Ya existe un perfil con esta URL de suscripción",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "La suscripción está cifrada; se te pedirá la clave al añadirla.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("Caducada"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Formato de la suscripción",
    ),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "El mejor formato para ReClash, elegido automáticamente",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "Del proveedor",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Algunas partes no son compatibles; las revisarás antes de añadirla.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo cargar la página de suscripción. Aún puedes añadirla.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Servidores"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Un servidor",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Nueva suscripción",
    ),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "No se añadió nada. Puedes elegir otro formato e intentarlo de nuevo.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Ilimitado"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Válida hasta",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Introduce el nombre del perfil",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Se aplica solo a este perfil; lo que no añadas usa su valor predeterminado.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Se aplica solo a este perfil y tiene prioridad sobre las entradas de sobrescritura de TUN de los ajustes de red.",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Introduce una URL de perfil válida",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Introduce la URL del perfil",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Perfiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Ordenar perfiles"),
    "project": MessageLookupByLibrary.simpleMessage("Proyecto"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protocolo"),
    "protocolParam": MessageLookupByLibrary.simpleMessage(
      "Parámetro del protocolo",
    ),
    "protocolVersion": MessageLookupByLibrary.simpleMessage(
      "Versión del protocolo",
    ),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("Anuncio"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Más información",
    ),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("Leer"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Aviso"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "Del proveedor",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Devolver al proveedor",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Devolver los ajustes al proveedor",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Los ajustes que cambiaste vuelven a seguir la suscripción",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Solo se admiten proveedores remotos",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Recursos externos"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Cadena de proxies"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Grupo de proxies"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "El grupo de proxies está vacío",
    ),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Los grupos aparecen aquí cuando se inicia el núcleo",
    ),
    "proxyGroupsCount": m78,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Proveedores de proxies",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Tipo de proxy"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Depurar caché"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Clave pública"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Negro puro"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Modo negro puro"),
    "qrcode": MessageLookupByLibrary.simpleMessage("Código QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Escanea un código QR para obtener un perfil",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Este enlace es demasiado largo para un código QR. Usa Copiar enlace.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Acciones rápidas"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Edición rápida"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Añadir grupo"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("Añadir tipo de red"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Añadir un patrón"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Añadir etiqueta"),
    "rcxAddTier": MessageLookupByLibrary.simpleMessage("Añadir preferencia"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Estas partes se editan en YAML.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Todos los grupos"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Cualquiera"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage(
      "Control automático",
    ),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Un escenario dirige toda la conexión: el modo en cada tipo de red y lo que hace cada grupo. Los grupos que no nombra conservan su propio perfil.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Volver a automático",
    ),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Equilibrado"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Basado en"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Comportamiento"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Traer los cambios",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Tus cambios se conservan",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("Cambiar servidor"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Cambiar a"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Comprobación"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Sobre el grupo"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage(
      "No encontraría ningún servidor",
    ),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("abre lo bloqueado"),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Comprobaciones"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Comprobaciones de disponibilidad",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Añadir condición"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Todas las condiciones"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Siempre"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Cualquier condición"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage(
      "Cualquier servidor",
    ),
    "rcxCondClause": m82,
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Campo"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Ignorar mayúsculas",
    ),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Coincidencia"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Ninguno declarado"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("no"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Operador"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Patrón"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("Como texto"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Esta condición anida grupos, así que se edita como texto.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Valor"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Valores separados por comas",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Permitir"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Hasta que lo permitas, el grupo usa el perfil Simple. Los sitios solo se contactan a través de tus servidores o para probar la red.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Se necesita permiso",
    ),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Sitios que contacta"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Los sitios de terceros no pertenecen ni a tu proveedor ni a los perfiles integrados.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Control"),
    "rcxDeleteProfile": m84,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico de red",
    ),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Sitios directos por este grupo",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage(
      "Activo ahora",
    ),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Si los sitios que tus reglas envían directos dejan de abrirse, pasarán por este grupo. Las direcciones locales siempre van directas.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "En espera: los sitios directos aún abren",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("Duplicar y editar"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Económico"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Preciso"),
    "rcxEnergyToday": m85,
    "rcxExcept": m86,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Excluido por el perfil",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "Omitido tras «Cambiar servidor»",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage(
      "Fuera del grupo de servidores",
    ),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "No coincide con ninguna preferencia",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Aún sin comprobar",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage(
      "No es un servidor",
    ),
    "rcxExit": m87,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage(
      "Comprobación del país de salida",
    ),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Exportar"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Pocas veces"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("A menudo"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Funcionando"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("En uso"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("No funciona"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Diagnóstico de red"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("País de entrada"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("País de salida"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage(
      "Falla la comprobación",
    ),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Tipo de red"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Latencia, ms"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Medido"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage(
      "Red con tarifa limitada",
    ),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Nombre"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage(
      "Pasa la comprobación",
    ),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage(
      "Página de inicio de sesión",
    ),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Proveedor"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage(
      "Dirección del servidor",
    ),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Etiqueta"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage(
      "Tipo de conexión",
    ),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Protocolo"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("Admite UDP"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Todo el grupo pasa por este miembro sin buscar servidor; elige un balanceador o un grupo anidado para cederle todo.",
    ),
    "rcxFixedOn": m88,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("General"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage(
      "Perfiles de grupo",
    ),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Cómo elige servidor un grupo inteligente. Toca uno tuyo para editarlo, o cualquier otro para editar una copia.",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Funciona"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("No funciona"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("Funcionaba antes"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Sin comprobar"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("Historial"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Versiones anteriores",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Añadir a mis perfiles",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Inicia el núcleo de la app para comprobar este perfil.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Importar perfil de enrutamiento",
    ),
    "rcxImported": m89,
    "rcxJournalFailure": m90,
    "rcxJournalMode": m91,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("comprobando"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "En esta red sustituyen a los grupos del escenario con el mismo nombre; los demás funcionan como en cualquier red.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Nombre"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Letras latinas minúsculas, dígitos y guiones, hasta 24",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("internet abierto"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage(
      "página de inicio de sesión",
    ),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Se reconoce cuando"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Los tipos se prueban de arriba abajo; la red recibe el primero que se cumple.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage(
      "solo listas blancas",
    ),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Último recurso"),
    "rcxLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Una preferencia de último recurso solo se usa cuando ninguna preferencia mejor tiene servidores.",
    ),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Nivel"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Sencillo"),
    "rcxLine": m92,
    "rcxLintCheckUnused": m93,
    "rcxLintConsent": m94,
    "rcxLintGroupMissing": m95,
    "rcxLintPoolEmpty": m96,
    "rcxLintTagUnused": m97,
    "rcxLintTierEmpty": m98,
    "rcxLintTierUnreachable": m99,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Grupo principal"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Hacer inteligente este grupo",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash mantiene un servidor que funciona en este grupo y cambia cuando falla. Las comprobaciones solo se hacen mientras usas la red.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Los perfiles y escenarios se crean y editan en «Configuración avanzada» → «Enrutamiento automático».",
    ),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron traer los cambios",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Cambios traídos"),
    "rcxMergedConflicts": m100,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Automático"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Elige y cambia servidores según el perfil",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Devolver el modo al escenario",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "El escenario fija el modo en esta red",
    ),
    "rcxModeIs": m101,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("No cambiar"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Tú eliges; el enrutamiento automático no cambia nada",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Elegiste el modo tú mismo; el escenario espera hasta que elijas «Automático»",
    ),
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "En esta red el modo es tuyo",
    ),
    "rcxMoveDown": MessageLookupByLibrary.simpleMessage("Mover abajo"),
    "rcxMoveUp": MessageLookupByLibrary.simpleMessage("Mover arriba"),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Necesita tu permiso",
    ),
    "rcxNetwork": m102,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Tipos de red"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Perfil nuevo"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Nuevo escenario"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("En esta red"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("falla"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("es uno de"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("es"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("no es"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("coincide con"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("tiene éxito"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage("Cambios por red"),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage(
      "Perfil propio del grupo",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "El patrón no es una expresión regular válida",
    ),
    "rcxPendingTier": m103,
    "rcxPinned": m104,
    "rcxPinnedHint": MessageLookupByLibrary.simpleMessage(
      "Solo se abandona si falla y se vuelve a él al recuperarse",
    ),
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Fijado"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Excluir"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Usar"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "El grupo no tiene servidores",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "Este grupo no es un selector en la configuración actual",
    ),
    "rcxProblemProfileInvalid": m105,
    "rcxProblemProfileMissing": m106,
    "rcxProblemStoreFailed": m107,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Nombre"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "El grupo elige servidor con este perfil entre los que conserva el pool.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Acción"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Ceder a un miembro",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Miembro"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Elegir servidor"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage(
      "Este es el mejor servidor",
    ),
    "rcxReasonBetterTier": m108,
    "rcxReasonChangeServer": m109,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Comprobando un candidato mejor",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Un servidor más rápido necesita otra medición",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Cambiado hace poco; se espera antes del siguiente",
    ),
    "rcxReasonFailover": m110,
    "rcxReasonFaster": m111,
    "rcxReasonFixed": m112,
    "rcxReasonFixedMissing": m113,
    "rcxReasonFlapLimit": m114,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Se mantiene el servidor fijado",
    ),
    "rcxReasonIdle": m115,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Seleccionado el mejor servidor disponible",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage("Control manual"),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "La red cambió",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "La red parece caída; no se culpa a ningún servidor",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "No hay otro servidor que funcione",
    ),
    "rcxReasonOutOfPool": m116,
    "rcxReasonPaused": m117,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo seleccionar el servidor",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Los sitios directos vuelven a ir directos",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Los sitios directos ahora pasan por este grupo",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Ningún servidor del grupo funciona; se mantiene el actual",
    ),
    "rcxReasonSwitchFixed": m118,
    "rcxReasonSwitchPinned": m119,
    "rcxReasonSwitchStranded": m120,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Funciona; se mantiene hasta que falle",
    ),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Escenario"),
    "rcxScenarioDrives": m121,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Grupos"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "El grupo principal es adonde la regla final envía el tráfico; «Todos los grupos» abarca los grupos de selección no nombrados aquí.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Reconoce las redes mediante diagnóstico directo y cambia el modo y los grupos en cada una.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("Modo de conexión"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Desactivado"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Escenarios"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Un escenario dirige toda la conexión. Toca uno tuyo para editarlo, o cualquier otro para editar una copia.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Servidores"),
    "rcxServersMatch": m122,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage(
      "Patrón de nombre",
    ),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage(
      "Grupos inteligentes",
    ),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Integrado"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "El perfil original cambió",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Qué cambió"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("Del proveedor"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Míos"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Cuando ningún servidor encaja",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("Ir directo"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Mantener el servidor actual",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Cambios"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Nombre de la etiqueta"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Solo letras latinas, dígitos, - y _, hasta 24",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Etiquetas"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Una etiqueta da nombre a un conjunto de servidores una sola vez, para usarla en las preferencias como tag(name).",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("de terceros"),
    "rcxTier": MessageLookupByLibrary.simpleMessage("Preferencia"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Etiqueta"),
    "rcxTierWhen": MessageLookupByLibrary.simpleMessage(
      "Servidores en esta preferencia",
    ),
    "rcxTiers": MessageLookupByLibrary.simpleMessage("Orden de preferencia"),
    "rcxTiersHint": MessageLookupByLibrary.simpleMessage(
      "Un servidor cae en la primera preferencia que cumple; gana la mejor preferencia con servidores. Mantén pulsado para reordenar.",
    ),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Enrutamiento automático"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Traducciones"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage(
      "Desactivar el enrutamiento automático",
    ),
    "rcxUntilCheck": m123,
    "rcxUntilConfirm": m124,
    "rcxUntilDwell": m125,
    "rcxUseCheck": m126,
    "rcxUseDiagnostic": m127,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage(
      "comprobación del país de salida",
    ),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Advertencias"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Por qué este servidor"),
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage(
      "Solicitudes recientes",
    ),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Sugeridos"),
    "recordType": MessageLookupByLibrary.simpleMessage("Tipo de registro"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Puerto Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Rehacer"),
    "regex": MessageLookupByLibrary.simpleMessage("Expresión regular"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Aplicar región"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "La región o las listas cambiaron. Repite la selección con los ajustes actuales.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Ninguna aplicación coincide con esta región. Tus listas no cambian.",
    ),
    "regionAppsPreview": m128,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Vista previa de aplicaciones",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("Servidores DNS"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("MTU de TUN"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Comprobaciones de servicios",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("Qué cambia"),
    "regionChina": MessageLookupByLibrary.simpleMessage("China"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Los valores que cambiaste tú se mantienen.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Egipto"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Elige servidores DNS, MTU de TUN, lista de exclusiones y comprobaciones de servicios para tu país. El idioma de la interfaz no cambia.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Irán"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Tus ajustes no cambian.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Comprobaciones de servicios desactivadas",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Sin seleccionar"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Otro país"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Recomendado para este dispositivo",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Rusia"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Seleccionar aplicaciones por región",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Elige una región compatible antes de usar las sugerencias regionales de aplicaciones.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Perfil regional"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Adaptación regional",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Liberar memoria"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo liberar la memoria",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remoto"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("Destino remoto"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Resolución DNS remota",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Quitar"),
    "rename": MessageLookupByLibrary.simpleMessage("Renombrar"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Renovar suscripción",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Reemplazar"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Reemplazar todo"),
    "request": MessageLookupByLibrary.simpleMessage("Solicitud"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage(
      "Encabezados de solicitud",
    ),
    "requests": MessageLookupByLibrary.simpleMessage("Solicitudes"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Solicitudes y actualizaciones",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Obligatorio"),
    "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
    "resetAllData": MessageLookupByLibrary.simpleMessage(
      "Restablecer todos los datos",
    ),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage(
      "Eliminar todo",
    ),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Se eliminarán permanentemente todos los perfiles, ajustes, scripts, fondos de pantalla y datos en caché. Se conservarán los archivos de copia de seguridad. Después, la aplicación se cerrará. Esta acción no se puede deshacer.",
    ),
    "resetAllDataWait": m129,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Esta página tiene cambios. ¿Seguro que quieres restablecer?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres restablecer?",
    ),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Eliminando datos…",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalo de actualización automática",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "El intervalo de actualización automática debe ser mayor que 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Recursos"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respetar reglas"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respetar reglas enruta las conexiones DNS según las reglas y requiere un Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Código de respuesta"),
    "restart": MessageLookupByLibrary.simpleMessage("Reiniciar"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres reiniciar el núcleo?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Restaurar todos los datos",
    ),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Restaurar valores predeterminados",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restaurar solo los perfiles",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Estrategia de restauración",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Sobrescribir",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restauración completada",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Resultado"),
    "retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Direcciones de ruta"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Direcciones excluidas de la ruta",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage(
      "Marca de enrutamiento",
    ),
    "ru": MessageLookupByLibrary.simpleMessage("Ruso"),
    "rule": MessageLookupByLibrary.simpleMessage("Regla"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Regla lógica AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el dominio completo",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con una palabra clave del dominio",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con una expresión regular de dominio",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un sufijo de dominio",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Coincidencia con comodines; solo se admiten * y ?",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con la marca DSCP (solo entrada UDP de tproxy)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el rango de puertos de destino",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el código de país de la IP",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con los dominios de Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el nombre de la entrada",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el puerto de entrada",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el tipo de entrada",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el nombre de usuario de entrada; separa varios usuarios con /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el ASN de la IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un rango de direcciones IP; IP-CIDR6 es solo un alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un rango de direcciones IP",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un rango de sufijo de IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con todas las solicitudes, sin necesidad de condiciones",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con TCP o UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Regla lógica NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Regla lógica OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el nombre del proceso; en Android coincide con el nombre del paquete",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con una expresión regular del nombre del proceso; en Android coincide con el nombre del paquete",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con comodines en el nombre del proceso; solo se admiten * y ?",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con la ruta completa del proceso",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con una expresión regular de la ruta del proceso",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con comodines en la ruta del proceso; solo se admiten * y ?",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el nombre de rematch; separa varios nombres con /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Hace referencia a un conjunto de reglas; requiere rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el código de país de la IP de origen",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el ASN de la IP de origen",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un rango de direcciones IP de origen",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con un rango de sufijo de IP de origen",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el rango de puertos de origen",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con una subregla; cuidado con los paréntesis",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Coincide con el ID de usuario de Linux",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("La regla está vacía"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Las reglas deben ser una lista YAML con una regla por elemento, por ejemplo - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent directo",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Bloquear DNS sobre TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Bloquear bucle del proxy",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage(
      "Bloquear QUIC",
    ),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage(
      "Bloquear STUN",
    ),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN directa"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple y Microsoft directos",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "Proveedores de reglas",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Conjunto de reglas"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "El conjunto de reglas no tiene entradas utilizables",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "No se puede leer este archivo mrs",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "El conjunto de reglas mezcla dominios y rangos de IP, por lo que no se puede determinar su tipo",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Destino de la regla"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "La regla debe empezar con un tipo admitido, por ejemplo DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Reglas"),
    "rulesCount": m130,
    "runTime": MessageLookupByLibrary.simpleMessage("Tiempo de ejecución"),
    "running": MessageLookupByLibrary.simpleMessage("En ejecución"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuración de ejecución",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Modo seguro"),
    "safeModeAppTitle": m131,
    "saturation": MessageLookupByLibrary.simpleMessage("Saturación"),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "¿Guardar los cambios?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Modo script: reescribe todo el perfil con un script de extensión",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Ir a la selección",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "seconds": MessageLookupByLibrary.simpleMessage("segundos"),
    "secondsCount": m132,
    "secretKey": MessageLookupByLibrary.simpleMessage("Clave"),
    "sectionsInEffect": m133,
    "select": MessageLookupByLibrary.simpleMessage("Seleccionar"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Seleccionar todo"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Selecciona un conjunto de reglas",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Selecciona una estrategia de división",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Seleccionado"),
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Enviar desde el teléfono",
    ),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "¿Importar el enlace enviado desde el teléfono?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Este dispositivo no está conectado a una red local",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Enlace de suscripción o enlace para compartir un proxy",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Enviado. Confirma la importación en el otro dispositivo.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "Enviar un enlace a ReClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Para recibir un enlace desde el teléfono, ReClash necesita el permiso Dispositivos cercanos, que le da acceso a la red local. Actívalo en los ajustes de la aplicación.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Escanea el código con la cámara del teléfono y pega el enlace en la página que se abre. Ambos dispositivos deben estar en la misma red.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Servidor"),
    "serviceAbnormalCount": m134,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Todo disponible",
    ),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Comprobar automáticamente los servicios activos",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Comprobar todos los servicios",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Disponible"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloqueado"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Comprobar todo"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "Comprobar solo al conectar",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Próximamente"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "ISP no permitido",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage(
      "Error en la comprobación",
    ),
    "serviceManage": MessageLookupByLibrary.simpleMessage(
      "Gestionar servicios",
    ),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Solo originales",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Sin comprobar"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Acceso restringido",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Se muestra en el panel",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage(
      "Estado del servicio",
    ),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("No disponible"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Región no compatible",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("ajustes"),
    "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "settingsCount": m135,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Este perfil está cifrado. Introduce su clave age para continuar.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Este servidor respondió a una prueba independiente. Cambia a él y vuelve a comprobar la ruta completa.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "Conectar al abrir ReClash",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Iniciar esta conexión junto con la aplicación.",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Cambiar ajustes",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Comprobar conexión",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "El resultado corresponde a esta ruta, no a todas las aplicaciones o sitios web.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Comprobamos una ruta seleccionada. Las solicitudes de permiso del sistema se abren por separado.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Conectando y comprobando",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Confirmado"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "La ruta seleccionada respondió. El tráfico sigue las reglas de tu perfil.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "La conexión funciona",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Copiar dirección del proxy",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage(
      "Todas las aplicaciones",
    ),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN captura el tráfico del dispositivo. Es posible que el sistema solicite permiso.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android solicitará permiso para crear una conexión VPN. La selección de aplicaciones está en los ajustes de acceso.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "Elige qué aplicaciones usan ReClash. Las reglas de tu perfil determinan qué conexiones usan un servidor.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Configuraré las aplicaciones manualmente",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Configura la dirección del proxy local en cada aplicación que quieras conectar.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Capturar todo el tráfico no significa enviarlo todo a través de un servidor. Las rutas directas se mantienen.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Proxy del sistema",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Las aplicaciones que no admiten el proxy del sistema se conectan directamente.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "¿Qué aplicaciones deben conectarse?",
    ),
    "setupDirectApps": m136,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "No se encontraron apps locales. Los sitios siguen yendo directos.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Funcionarán sin la VPN. Puedes cambiar la lista más tarde en el control de acceso.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Buscando apps locales…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Los servicios de tu país se abren sin el servidor: más rápido, y los bancos o sitios oficiales no te bloquean. Se añaden estas reglas globales:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Sitios y apps locales en conexión directa",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Detalles"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "La conexión requiere atención",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Puedes cambiar cualquier opción en los ajustes.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Selecciona un idioma antes de leer las condiciones. Puedes cambiarlo más tarde.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Elige tu idioma",
    ),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "La configuración está incompleta; no se ha comprobado la conexión.",
    ),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash se cerrará. Tus elecciones se guardan y la configuración continuará la próxima vez que abras la app.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "¿Salir de la configuración?",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Configura esta dirección en las aplicaciones que quieras conectar. Esta comprobación no confirma que estén configuradas.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "El proxy local está listo",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Sin comprobar"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "La ruta respondió, pero no se pudieron confirmar algunas comprobaciones.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Conectado, con limitaciones",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Permite la conexión en el aviso del sistema, vuelve a intentarlo o elige otro alcance.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Se necesita permiso",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Buscando otro servidor",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Iniciando la conexión",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage(
      "Iniciando el núcleo",
    ),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Confirmando la salida",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Aplicando el perfil",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Comprobando la ruta",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Comprobando los servicios",
    ),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Añade o elige un perfil para continuar.",
    ),
    "setupProfileCount": m137,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash no proporciona servidores. Importa una suscripción o una configuración de tu proveedor.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Importar perfil",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Añadir otro perfil",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Pega el enlace del correo, bot o cuenta de tu proveedor, o elige un archivo o código QR.",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Enlace de suscripción o para compartir",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Perfil listo"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage(
      "Configurar más tarde",
    ),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Añadir un perfil de conexión",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Tu conexión"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Comprobación"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Cobertura"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Región"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Recomendado"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Mantener los valores del perfil",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "La configuración regional no cambia.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash ajusta el DNS, la MTU y las rutas directas a las redes de tu país. El idioma de la interfaz no cambia.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "¿Desde dónde te conectas?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Si no eliges, tu configuración regional actual se mantiene.",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Comprobar de nuevo"),
    "setupReport": MessageLookupByLibrary.simpleMessage(
      "Informe de comprobación",
    ),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Permitir conexión",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage("Configurar conexión"),
    "setupResume": MessageLookupByLibrary.simpleMessage(
      "Continuar configuración",
    ),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "La ruta cambió durante la comprobación. Vuelve a comprobar la conexión actual.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "El modo seguro no inicia una conexión real. Guarda la configuración o pruébala en una versión normal.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "No se pudieron guardar tus opciones. Inténtalo de nuevo.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Guardar sin conectarse",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Tus opciones están guardadas. Puedes conectarte desde el panel cuando quieras.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Conectar más tarde",
    ),
    "setupStepStatus": m138,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Tus opciones están guardadas. La conexión anterior no se ha detenido.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Comprobación detenida",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Elige otra cobertura: algunas redes bloquean las conexiones VPN.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Comprueba que internet funciona sin ReClash.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Actualiza el perfil o elige otro servidor después de configurar.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage("Qué puedes probar"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Primera conexión"),
    "setupTryServer": m139,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Sin respuesta"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "La conexión se inició, pero la ruta seleccionada no ofreció resultados suficientes.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "No se pudo confirmar la conexión",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "La operación no se completó. Inténtalo de nuevo o consulta los detalles.",
    ),
    "shareLinkUnreadable": m140,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer ningún proxy de los enlaces",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Escanea con ReClash en otro dispositivo para importar este perfil.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Mostrar"),
    "showLess": MessageLookupByLibrary.simpleMessage("Contraer"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expandir"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Botón de detener en la notificación",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Mostrar contraseña"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Barra lateral"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Desenfoque de la barra lateral",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "El desenfoque de fondo deja ver el escritorio detrás de la ventana a través de la barra lateral.",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Inicio silencioso"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "El inicio silencioso arranca sin mostrar la ventana.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Añadir uno"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Importar uno"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Introduce aquí un solo enlace; para varios, usa la edición rápida de la lista",
    ),
    "singleValueTip": m141,
    "size": MessageLookupByLibrary.simpleMessage("Tamaño"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Omitir verificación de certificado",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Omitir dominios"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Un dominio detectado que esté en la lista de dominios omitidos no se usa.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Omitir direcciones de destino",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Omitir direcciones de origen",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Deslizar"),
    "sliders": MessageLookupByLibrary.simpleMessage("Reguladores"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protocolos"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "El sniffer lee el dominio del tráfico TLS, HTTP y QUIC para que las reglas puedan aplicarse.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Puerto SOCKS"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Suave"),
    "sort": MessageLookupByLibrary.simpleMessage("Ordenar"),
    "source": MessageLookupByLibrary.simpleMessage("Origen"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP de origen"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Proxy especial"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Reglas especiales"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Espectro"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Estadísticas de velocidad",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Estrategia de división",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "La estrategia de división no puede estar vacía",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("No hay SSID"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Modo de pila"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Seguimiento de pila"),
    "standard": MessageLookupByLibrary.simpleMessage("Estándar"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Modo estándar: añade reglas sobre el perfil",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Iniciar"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage(
      "Empezar desde cero",
    ),
    "startVpn": MessageLookupByLibrary.simpleMessage("Iniciando VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Inicio y segundo plano",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Estado"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Con DNS desactivado, se usa el DNS del sistema.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Detener"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Deteniendo VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Estrategia"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Ruta estricta"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "La ruta estricta evita que el tráfico, como el DNS, eluda TUN y, con IPv6 desactivado, bloquea las conexiones IPv6 de este dispositivo.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Estilo"),
    "submit": MessageLookupByLibrary.simpleMessage("Enviar"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage(
      "Automáticamente",
    ),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Agente de usuario personalizado",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "Agente de usuario",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Introduce un agente de usuario válido sin caracteres de control.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "La selección del cliente no envía la identidad del dispositivo.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Solicitar como",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Estos ajustes se aplican a URL de suscripción. Los enlaces proxy se importan localmente.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Introduzca la clave AGE para comprobar esta suscripción.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Aplicar resultado comprobado"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "El servidor rechazó la autorización. Se detuvo la selección de clientes.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Comprobar",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "No se pudo obtener una suscripción compatible. La configuración anterior no cambió.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Comprueba los valores actuales sin guardar ni reiniciar la VPN. Verifica el análisis, no la disponibilidad de los nodos.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Volver a preguntar sobre pérdidas",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Ocultar URL de la suscripción",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Último cliente válido"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "La importación omite datos de origen. Revise las pérdidas antes de aplicar.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Usar este cliente"),
    "subscriptionCompatibilityPrepared": m142,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core analizó este resultado. Aún no se ha guardado ni aplicado.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "El servidor limitó las solicitudes. Inténtelo más tarde.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Mostrar URL de la suscripción",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "El formulario o el perfil cambió. Compruebe la suscripción de nuevo.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "La comprobación agotó el tiempo de espera.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Compatibilidad",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Error de conexión. Se detuvo la selección de clientes.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "No hay dispositivos disponibles para esta suscripción. Elimina uno de la cuenta del proveedor e inténtalo de nuevo.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Esta suscripción requiere registrar el dispositivo. Sigue las instrucciones del proveedor.",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Su suscripción ha caducado",
    ),
    "subscriptionExpiresInDays": m143,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Su suscripción caduca hoy",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Enviar también el sistema operativo y el modelo",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "Junto con el identificador se enviarán la versión del sistema operativo y el modelo del dispositivo.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Se enviará a este origen de suscripción un identificador seudónimo estable del dispositivo. No es una atestación de hardware y el consentimiento solo se guarda en este dispositivo.",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "Muchas suscripciones dejarán de funcionar si desactivas el envío de HWID.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Identidad de suscripción",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "Enviar HWID",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Usar ajuste global",
    ),
    "subscriptionImportAdd": m144,
    "subscriptionImportAllAdded": m145,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "configuración de Clash",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "suscripción cifrada",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "enlaces proxy",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "formato desconocido",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "Secciones de la configuración",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "ReClash aplica su propia configuración en lugar de estas partes del origen.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "Se omite",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Ninguno de los servidores es compatible",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Algunas opciones de los servidores no son compatibles y se omiten",
    ),
    "subscriptionImportPartial": m146,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "Faltan las velocidades de subida y bajada",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "El protocolo no es compatible",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "El transporte no es compatible",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "No volver a preguntar para esta suscripción",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Si algo más deja de transferirse, se te volverá a preguntar.",
        ),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "No todo se transfiere",
    ),
    "subscriptionImportShowAll": m147,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "No se añadirán",
    ),
    "subscriptionImportSourceFormat": m148,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Información de la suscripción",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Recordatorios de suscripción",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Suscripción"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Cuenta",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Comprar plan",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Comprar tráfico",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "URL del logotipo",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Soporte",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Sitio web",
    ),
    "subscriptionTrafficLow": m149,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Usar el intervalo del proveedor",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Introduce tu contraseña para sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspendido…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Cambiar de perfil"),
    "sync": MessageLookupByLibrary.simpleMessage("Sincronizar"),
    "system": MessageLookupByLibrary.simpleMessage("Sistema"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Apps del sistema"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Proxy del sistema"),
    "tab": MessageLookupByLibrary.simpleMessage("Pestaña"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage(
      "Animación de pestañas",
    ),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Toca el icono para reintentar",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Toca para autorizar",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Destino"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrente"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "No se pudo abrir Telegram en este dispositivo.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Abrir Telegram"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Abrir en el navegador",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Intervalo de prueba"),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL de prueba"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Probar al usarse"),
    "textScale": MessageLookupByLibrary.simpleMessage("Escala del texto"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Así se verá el texto en la app",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Tema"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Color del tema"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Modo del tema"),
    "tight": MessageLookupByLibrary.simpleMessage("Ajustado"),
    "time": MessageLookupByLibrary.simpleMessage("Hora"),
    "timeout": MessageLookupByLibrary.simpleMessage("Tiempo agotado"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Tintado"),
    "tip": MessageLookupByLibrary.simpleMessage("Consejo"),
    "tk": MessageLookupByLibrary.simpleMessage("Turcomano"),
    "toggle": MessageLookupByLibrary.simpleMessage("Alternar"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolerancia"),
    "tools": MessageLookupByLibrary.simpleMessage("Herramientas"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Acción"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Elige una sección o busca un ajuste",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Se cerrarán todas las conexiones activas. ¿Continuar?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("Acción completada"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Configuración"),
    "toolsData": MessageLookupByLibrary.simpleMessage("Recursos y datos"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "No se encontraron ajustes ni acciones",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Información y depuración",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage(
      "Usados recientemente",
    ),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Activa primero la autenticación",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Activa primero el controlador externo",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Inicia el núcleo para usar esta acción",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Selecciona primero una interfaz de red personalizada",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Selecciona primero la pila de red MIPS",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Añade primero esta opción en la página DNS",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Configura primero WebDAV",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Diagnóstico"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Fijar"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Fijados"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Reiniciar el núcleo",
    ),
    "toolsResults": m150,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Ejecutar"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Sección"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Ajuste"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Desfijar"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Actualizar recursos",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Actualizar reglas y scripts puede volver a aplicar la configuración y afectar a las conexiones. ¿Continuar?",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Ampliar tráfico"),
    "torch": MessageLookupByLibrary.simpleMessage("Linterna"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Descargado"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Tráfico total"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Subido"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Puerto TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Tráfico"),
    "trafficPeak": m151,
    "trafficTotal": m152,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Uso de tráfico"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Sugerir una corrección de traducción",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transporte"),
    "transportHeaders": m153,
    "trayIcon": MessageLookupByLibrary.simpleMessage("Icono de la bandeja"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Color"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Negro"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Blanco"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage(
      "Redes de confianza",
    ),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "La VPN se pausa en estas redes",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "La red actual es de confianza",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo autorizar TUN, por lo que se desactivó.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN solo funciona en modo administrador.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Las entradas añadidas aquí sustituyen los ajustes de TUN de todos los perfiles; lo que no añadas conserva el ajuste del propio perfil. Las entradas que añade un perfil personalizado tienen prioridad.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Desactivar"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Activar"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage(
      "Modo de retransmisión UDP",
    ),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("Tiempo de espera UDP"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "El tiempo de espera UDP se indica en segundos y solo funciona con las pilas gvisor, system y mixed.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Deshacer"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Latencia unificada"),
    "unknown": MessageLookupByLibrary.simpleMessage("Desconocido"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Error de red desconocido",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restaurar tamaño"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Sin nombre"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Desfijar ventana"),
    "update": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Permitir instalación automática",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash podrá instalar actualizaciones estables verificadas y aptas sin preguntar cada vez. Nunca desconectará tu VPN. Android aún puede pedirte que confirmes la instalación.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "¿Permitir la instalación automática?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Instalar automáticamente",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Cancelar descarga",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de actualización",
    ),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage(
      "Versión preliminar",
    ),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage(
      "Versión estable",
    ),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Buscar automáticamente",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron buscar actualizaciones",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Comprueba tu conexión y vuelve a intentarlo.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Buscando actualizaciones…",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("Cerrar ventana"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android necesita tu aprobación. Continúa para abrir la confirmación del sistema.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Confirma con Android",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Continuar en segundo plano",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Continuar instalación",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage("Estás al día"),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "En esta plataforma, ReClash abre la página de la versión. Descarga e instala la actualización por tu cuenta.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "No hay una descarga verificada para este dispositivo. Abre la página de la versión para elegir un paquete.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Desconectar e instalar",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Mantener instalación manual",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Descargar actualización",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Descargar de nuevo",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo descargar la actualización",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "La parte descargada está guardada. Comprueba tu conexión y continúa la descarga.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Entendido"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo iniciar el instalador de paquetes",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android no completó la instalación. Inténtalo de nuevo cuando quieras.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Instalar ahora"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Actualización instalada",
    ),
    "updateInstalledVersion": m154,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android está completando la instalación. ReClash puede cerrarse durante este paso.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Instalando la actualización",
    ),
    "updateMinutes": m155,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Ahora no"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "No hay notas de la versión disponibles.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Hay una actualización disponible",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Abrir ajustes de Android",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Compilación para el dispositivo",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage(
      "Tamaño de descarga",
    ),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Verificación del paquete",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Se verificará tras la descarga, antes de instalar",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Integridad, identidad de la app y firma verificadas",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Pausar"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Descarga en pausa",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Permite que ReClash instale aplicaciones desde esta fuente y vuelve para continuar.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Se necesita permiso de Android",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Configura por separado la búsqueda, la descarga y la instalación.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "No se guardaron las preferencias. Inténtalo de nuevo; la instalación automática no se ha activado.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Preferencias de actualización",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage(
      "Descargar por Wi-Fi",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Lista para instalar",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de la versión",
    ),
    "updateRemainingTime": m156,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Reanudar descarga",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Reanudar"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("Buscar de nuevo"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Reintentar instalación",
    ),
    "updateSeconds": m157,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Ver todas las notas de la versión",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Mostrar todos los cambios",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Actualizaciones"),
    "updateTransferSpeed": m158,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo verificar la integridad de la actualización descargada.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "El archivo, la versión o la firma no superaron la verificación. Descarga una copia nueva para intentarlo otra vez.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Este paquete no se puede instalar",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Verificando la actualización",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "La instalación cerrará ReClash brevemente. Desconecta solo si puedes interrumpir la conexión.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "Tu VPN sigue activa",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Subida"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Ancho de banda de subida",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("Esquema de URL"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Acción"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Añadir suscripción"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Añadir una URL de suscripción con un nombre opcional.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo autenticar el enlace cifrado. Puede estar dañado o usar otra clave.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Crear enlace"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Cerrar aplicación"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Usar el comportamiento de cierre configurado.",
    ),
    "urlSchemeConfigCounts": m159,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Pega una configuración YAML o JSON",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Contenido de la configuración",
    ),
    "urlSchemeConfirmMessage": m160,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Comando externo de aplicación",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Los comandos externos de conexión y cierre piden confirmación.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Conectar"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Conectar con el perfil seleccionado.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Conexión"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Formato del contenido",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "La conversión omite parte del contenido. Revisa y aprueba los cambios durante la importación.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo copiar el enlace. Inténtalo de nuevo.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("Copiar enlace"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "No se pudo entregar el enlace o la cola está llena. Inténtalo de nuevo cuando termine la acción actual.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Desconectar"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Detener la conexión sin cambiar el perfil.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuración integrada",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Perfil de ejemplo",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Formatos"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Formatos de enlace. Sustituye los marcadores por tu URL o datos.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Importar configuración",
    ),
    "urlSchemeImportConfirm": m161,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Incluir una configuración YAML o JSON en el enlace.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Comprobar enlace",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Pega un enlace de aplicación o perfil",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "La comprobación es local. No abre el enlace, descarga suscripciones ni importa perfiles.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "La estructura del enlace es válida. La disponibilidad de la suscripción y la validación del núcleo se comprueban durante la importación.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Resultado de la comprobación",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Instalar configuración",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Usar el formato de enlace de suscripción de los clientes Clash.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "La configuración integrada no contiene datos UTF-8 Base64 válidos.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "El enlace está mal formado. Comprueba su estructura y la codificación porcentual.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Usa un nombre de perfil de hasta 64 caracteres, sin caracteres de control.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Introduce una URL de suscripción HTTP o HTTPS válida.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "Falta una URL de suscripción o una configuración en el enlace.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "No se ha ejecutado ninguna acción.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Mostrar aplicación"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Traer ReClash al primer plano.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parámetros"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer el portapapeles. Pega el enlace manualmente.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Enlace"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Introduce una URL o configuración para crear el enlace.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Los enlaces pueden contener tokens o credenciales. Compártelos con cuidado.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Perfiles"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Enlaces de proxy",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Enlace reconocido",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Completa la configuración de conexión antes de usar comandos externos de conexión.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Enlaces de importación compatibles",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Alternar conexión",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Conectar si está detenido; desconectar si está activo.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "El enlace contiene demasiados envoltorios anidados.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "El enlace supera los 4 MB o la configuración integrada supera los 2 MB.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Este comando de enlace no es compatible.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Esta versión de cifrado no es compatible. Solicita un enlace de suscripción sin cifrar.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("Usar ejemplo"),
    "urlTip": m162,
    "useHosts": MessageLookupByLibrary.simpleMessage("Usar hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Usar hosts del sistema",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("usado"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Tráfico usado"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Usuario"),
    "uz": MessageLookupByLibrary.simpleMessage("Uzbeko"),
    "value": MessageLookupByLibrary.simpleMessage("Valor"),
    "view": MessageLookupByLibrary.simpleMessage("Ver"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("IPv4 virtual"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Vivo"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Se detectó un cambio en la configuración relacionada con la VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "La VPN enruta automáticamente todo el tráfico del sistema a través de VpnService.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Desenfoque"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Opacidad de tarjetas",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Oscurecimiento"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Ajustes de imagen",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Usar fondo personalizado",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("Ajuste de imagen"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Ajustar"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Rellenar"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Estirar"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Posición horizontal",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Elige una imagen PNG, JPEG o WebP válida.",
    ),
    "wallpaperImageLabel": m163,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Encuadre"),
    "wallpaperLibraryFull": m164,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Opacidad de imagen",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("Legibilidad"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("Eliminar imagen"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Restablecer efectos",
    ),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Restablecer encuadre",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "No se pudo guardar el fondo. Se ha conservado el anterior.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Escala"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG o WebP · hasta 20 MB",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage(
      "Fondo personalizado",
    ),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Elige una imagen de hasta 20 MB y 50 megapíxeles.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Imagen no disponible",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Posición vertical",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuración de WebDAV",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Panel web"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Acceso"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Acceso al panel finalizado",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "En la app",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "En el navegador",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage(
      "Desactivado",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "El acceso es local y está protegido por un secreto. Abrir el panel no cambia la configuración guardada del controlador externo.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo aplicar la configuración del panel.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "La descarga no es un archivo de panel válido.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "El núcleo rechazó las credenciales. Vuelve a abrir el panel.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "El acceso del navegador permanece hasta finalizarlo o salir de ReClash",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Hay otra operación del panel en curso.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Operación del panel cancelada.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "La suma de comprobación no coincide con la versión fijada.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "El núcleo no está listo.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Paneles web locales para administrar el núcleo",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo descargar el panel. Inténtalo de nuevo.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Descargando panel",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "El acceso termina al cerrar el panel",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Finalizar acceso al panel",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Extrayendo panel",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Panel"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Instalar panel",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "El panel seleccionado se descarga al abrirlo por primera vez. Se utiliza una versión fijada con verificación SHA-256.",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo abrir el navegador.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Sin sesión de panel",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Selecciona un perfil antes de abrir el panel.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "No instalado",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Abrir panel"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Abrir en el navegador",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Recargar"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "El acceso al panel está desactivado por tu proveedor.",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "El acceso al panel está desactivado en modo seguro.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron leer o reemplazar de forma segura los archivos del panel.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "El archivo del panel supera el tamaño permitido.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "El núcleo no sirve este panel.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Verificando descarga",
    ),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Versión"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Modo lista blanca"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Escribir en el sistema",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Escribir en el sistema también ajusta el reloj del sistema; Android lo ignora.",
    ),
    "yearsAgo": m165,
    "yearsAgoShort": m166,
    "yes": MessageLookupByLibrary.simpleMessage("Sí"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Chino simplificado"),
  };
}
