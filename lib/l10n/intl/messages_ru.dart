// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(count, skipped) =>
      "Будет добавлено: ${count}, пропущено (уже есть): ${skipped}";

  static String m1(detail) => "Не удалось очистить данные: ${detail}";

  static String m2(code) =>
      "Windows отказалась запускать ReClashCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите ReClash в этой политике или отключите её и повторите попытку.";

  static String m3(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, профиль ${name} снят с выбора, а автоматическая настройка пропущена. Вы можете выбрать его снова в любой момент.";

  static String m4(url) => "Создать профиль по ссылке ${url}?";

  static String m5(groups) =>
      "У групп прокси ${groups} отброшен include-all; добавьте прокси или провайдеры прокси, которые они используют";

  static String m6(count, label) =>
      "${Intl.plural(count, one: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правило SUB-RULE', few: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правила SUB-RULE', many: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правил SUB-RULE', other: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правила SUB-RULE')}";

  static String m7(message) =>
      "Ядро не может разобрать этот прокси: ${message}";

  static String m8(proxy, target) =>
      "${proxy} подключается через ${target}, а ${target} снова ведёт к ${proxy}, поэтому подключение зацикливается";

  static String m9(name) =>
      "Имя ${name} уже занято другим прокси или группой прокси";

  static String m10(path) =>
      "Группы прокси ссылаются друг на друга по кругу: ${path}";

  static String m11(name) =>
      "Резервом для пустой группы может быть только прокси, а ${name} не существует или является группой прокси";

  static String m12(name, message) =>
      "${name}: недопустимое регулярное выражение: ${message}";

  static String m13(name) => "Прокси для подключения ${name} не существует";

  static String m14(names) => "Эти провайдеры прокси не существуют: ${names}";

  static String m15(names) => "Эти прокси или политики не существуют: ${names}";

  static String m16(name) =>
      "${name} — встроенное имя политики, его нельзя использовать";

  static String m17(count) =>
      "Проблем: ${count}, применение профиля может завершиться ошибкой";

  static String m18(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m19(count) => "${count} дн. назад";

  static String m20(label) =>
      "Вы уверены, что хотите удалить выбранные элементы (${label})?";

  static String m21(label) => "Вы уверены, что хотите удалить «${label}»?";

  static String m22(label) => "Сведения: ${label}";

  static String m23(name) =>
      "Подключение через ${name} ведёт обратно к прокси, который его использует, поэтому соединение остановлено";

  static String m24(label) => "Поле «${label}» не может быть пустым";

  static String m25(label) => "«${label}» уже существует";

  static String m26(count) => "Ошибок: ${count}";

  static String m27(label, message) => "${label}: ${message}";

  static String m28(name) => "${name}: уже последняя версия";

  static String m29(name) => "${name}: обновлено";

  static String m30(count) => "Групп: ${count}";

  static String m31(count) => "Тайм-аут: ${count}";

  static String m32(action) =>
      "Уже используется для «${action}». При сохранении будет перенесено сюда.";

  static String m33(actions) => "Не экспортировано: ${actions}";

  static String m34(modifiers) =>
      "Добавьте хотя бы одну из клавиш: ${modifiers}";

  static String m35(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m36(count) => "${count} ч назад";

  static String m37(target) => "${target} — недопустимая политика";

  static String m38(proxyName) => "${proxyName} — недопустимый прокси";

  static String m39(providerName) =>
      "${providerName} — недопустимый провайдер прокси";

  static String m40(ruleSet) => "${ruleSet} — недопустимый набор правил";

  static String m41(subRule) => "${subRule} — недопустимый SUB_RULE";

  static String m42(count) =>
      "${Intl.plural(count, one: '${count} элемент', few: '${count} элемента', many: '${count} элементов', other: '${count} элемента')}";

  static String m43(line, message) => "Строка ${line}: ${message}";

  static String m44(appName) =>
      "1. Откройте Системные настройки > Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nПосле настройки вернитесь в приложение и продолжайте работу. Спасибо за сотрудничество.";

  static String m45(label, max) => "«${label}» — не более ${max} символов";

  static String m46(size) => "Освобождено ${size}";

  static String m47(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m48(count) => "${count} мин назад";

  static String m49(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m50(count) => "${count} мес. назад";

  static String m51(code) =>
      "Сервер запретил доступ (HTTP ${code}). Возможно, ссылка устарела или учётные данные неверны";

  static String m52(code) => "Сервер отклонил запрос (HTTP ${code})";

  static String m53(code) =>
      "По этому адресу ничего не найдено (HTTP ${code}). Проверьте правильность URL";

  static String m54(detail) => "Сетевой запрос не выполнен: ${detail}";

  static String m55(code) =>
      "На сервере произошла ошибка (HTTP ${code}). Повторите попытку позже";

  static String m56(label) => "Пока нет: ${label}";

  static String m57(label, min, max) =>
      "Значение «${label}» должно быть от ${min} до ${max}";

  static String m58(label) => "Значение «${label}» должно быть числом";

  static String m59(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m60(port) => "Порт ${port}";

  static String m61(added, skipped, failed) =>
      "Добавлено: ${added}; пропущено: ${skipped}; ошибок: ${failed}.";

  static String m62(days) => "Осталось дней: ${days}";

  static String m63(date, days) => "Истекает ${date}, осталось дней: ${days}";

  static String m64(time) => "Обновлено ${time}";

  static String m65(label, profiles) =>
      "«${label}» всё ещё используется профилями: ${profiles}. После удаления они будут работать неправильно. Вы уверены, что хотите удалить его?";

  static String m66(count, label) =>
      "${Intl.plural(count, other: '${label} прокси')}";

  static String m67(name, count) => "${name} и другие (${count} прокси)";

  static String m68(removed) =>
      "Будут удалены прокси: ${removed}. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?";

  static String m69(removed, added) =>
      "Будут удалены прокси: ${removed}. Будут добавлены: ${added}. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?";

  static String m70(label) =>
      "На «${label}» всё ещё ссылаются правила, группы прокси, прокси для подключения, DNS или NTP этого профиля, и после удаления эти ссылки перестанут работать. Вы уверены, что хотите удалить её?";

  static String m71(count, label) =>
      "${Intl.plural(count, one: '${label} группа прокси', few: '${label} группы прокси', many: '${label} групп прокси', other: '${label} группы прокси')}";

  static String m72(region, bypassed, proxied) =>
      "${region}: в список обхода VPN попадут ${bypassed} приложений, в список VPN — ${proxied}. Оба списка будут заменены; режим и остальные параметры не изменятся. Совпадения пакетов и SDK — лишь подсказки: проверьте результат после применения.";

  static String m73(region, value) =>
      "Регион ${region}: список обхода — ${value}. Ручной список заменяет региональные значения.";

  static String m74(region, source) => "Рекомендуется: ${region} · ${source}";

  static String m75(region, value) =>
      "Регион ${region}: базовые DNS — ${value}. Ручные переопределения на этом экране имеют приоритет.";

  static String m76(region) => "Профиль страны: ${region}";

  static String m77(value) => "MTU TUN: ${value}";

  static String m78(value) => "Проверки сервисов по умолчанию: ${value}";

  static String m79(region, value) =>
      "Регион ${region}: MTU ${value}. Добавьте переопределение MTU, чтобы задать своё значение.";

  static String m80(count, label) =>
      "${Intl.plural(count, one: '${label} правило', few: '${label} правила', many: '${label} правил', other: '${label} правила')}";

  static String m81(appName) => "${appName} (Безопасный режим)";

  static String m82(count) =>
      "${Intl.plural(count, one: '${count} секунда', few: '${count} секунды', many: '${count} секунд', other: '${count} секунды')}";

  static String m83(count) => "Действуют: ${count}";

  static String m84(count) => "Проблем: ${count}";

  static String m85(time) => "Проверено в ${time}";

  static String m86(count) =>
      "${Intl.plural(count, one: '${count} настройка', few: '${count} настройки', many: '${count} настроек', other: '${count} настройки')}";

  static String m87(count) => "Доступно профилей: ${count}";

  static String m88(step, total) => "${step} из ${total}";

  static String m89(server) => "Попробовать ${server}";

  static String m90(link) => "Не удалось прочитать прокси из ${link}";

  static String m91(label) => "«${label}» — только одно значение";

  static String m92(client, format, count) =>
      "Получено как ${client}: ${format}, узлов: ${count}.";

  static String m93(sections) =>
      "Не будут перенесены разделы исходной конфигурации: ${sections}.";

  static String m94(count, format) =>
      "Из формата ${format} можно импортировать узлов: ${count}.";

  static String m95(count) => "Не удалось преобразовать узлов: ${count}.";

  static String m96(count) => "Результатов: ${count}";

  static String m97(value) => "Пик ${value}";

  static String m98(value) => "Всего ${value}";

  static String m99(version) => "Установлена версия ${version}";

  static String m100(count) => "${count} мин";

  static String m101(time) => "Осталось ${time}";

  static String m102(count) => "${count} с";

  static String m103(speed) => "${speed}/с";

  static String m104(nodes, groups, providers) =>
      "Прокси: ${nodes}, группы: ${groups}, удалённые провайдеры: ${providers}";

  static String m105(action) =>
      "Ссылка запрашивает действие «${action}». Разрешить ReClash выполнить его?";

  static String m106(name, source) =>
      "Импортировать «${name}» из ${source}? После согласия выполнятся проверка профиля и рассмотрение преобразований.";

  static String m107(label) => "Значение «${label}» должно быть URL";

  static String m108(index) => "Фон ${index}";

  static String m109(count) =>
      "Можно хранить до ${count} фонов. Удалите один, чтобы добавить новый.";

  static String m110(version) => "Установленная версия: ${version}";

  static String m111(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  static String m112(count) =>
      "${Intl.plural(count, one: '${count} г. назад', few: '${count} г. назад', many: '${count} л. назад', other: '${count} г. назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN проходят только выбранные приложения",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа выбирает приложения, использующие прокси.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений отключён",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения исключаются из VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки контроля доступа",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Проверить все задержки",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Прямой режим"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage(
      "Глобальный режим",
    ),
    "actionMode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Режим правил"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Старт/Стоп"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Обновить профили",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Добавить прокси"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Добавить фильтры"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Добавить узлы"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Добавить параметр",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Добавить группу прокси",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage(
      "Добавить параметр",
    ),
    "addSsid": MessageLookupByLibrary.simpleMessage("Добавить SSID"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Добавленные правила"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Дополнительные параметры",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Префикс имени"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Суффикс имени"),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес WebDAV",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Расширенная конфигурация",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Расширенная конфигурация включает сеть, DNS, добавленные правила и скрипты.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Зашифрованный профиль",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Секретный ключ age"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Профиль зашифрован с помощью age, для расшифровки нужен секретный ключ age",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Все используемые прокси",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Все используемые провайдеры прокси",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Разрешить LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Разрешённые IP"),
    "answers": MessageLookupByLibrary.simpleMessage("Ответы"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Дизайн значка приложения",
    ),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Нет локальных прокси",
    ),
    "appRegion": MessageLookupByLibrary.simpleMessage("Регион приложения"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Фон"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Интерфейс"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Тема"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Добавлять системный DNS",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки приложения",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Аутентификация требует логин и пароль для локального порта прокси.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Пока включена аутентификация, системный прокси не применяется.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "authorized": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Автопроверка обновлений",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Автозакрытие соединений",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Автозакрытие соединений обрывает открытые соединения при смене прокси.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage(
      "Автоматическое включение",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автовключение"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Автовключение запускает прокси при открытии приложения.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автонастройка системного DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана более новой версией приложения. Обновите приложение перед восстановлением",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Основная информация"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Базовые политики"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Массовое добавление"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Массовый импорт"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "По одной ссылке на строку",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "По одному значению на строку или через запятую",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "По одной записи на строку: ключ, пробел, значение",
    ),
    "batchPreviewTip": m0,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "По одному URL на строку",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Игнорирование оптимизации батареи позволяет приложению работать в фоне.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим чёрного списка",
    ),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Заблокировать соединение",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Яркость"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключённые домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Исключённые домены действуют только при включённом системном прокси.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Обходить частные адреса",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "При обходе частных адресов адреса LAN, loopback и multicast идут в обход TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Кэш"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Алгоритм кэша"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить его?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Размер кэша"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешите доступ к камере в системных настройках, чтобы сканировать QR-коды, или выберите изображение QR-кода из галереи.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется доступ к камере",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Камера недоступна",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Снять выделение"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Не удалось сохранить"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось переключить прокси; восстановлен предыдущий выбор",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Важные изменения",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Новые функции"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Исправления"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage(
      "Производительность",
    ),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Откаты"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Проверять TLS-сертификаты",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Без проверки TLS-сертификатов подписки и резервные копии уязвимы для атаки «человек посередине».",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "У вас уже последняя версия",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Шифр"),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Все профили, настройки и локальные данные будут удалены, после чего приложение закроется. Откройте его снова, чтобы начать заново.",
    ),
    "clearDataFailed": m1,
    "clearSearch": MessageLookupByLibrary.simpleMessage("Очистить поиск"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Отпечаток клиента",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт в буфер обмена",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Импорт из буфера обмена",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось скопировать в буфер обмена. Возможно, выделение слишком велико",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Закрыть соединения",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Стиль палитры"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "compact": MessageLookupByLibrary.simpleMessage("Компактный"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить все данные?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить эту группу прокси?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите закрыть текущее окно?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно завершить ядро со сбоем?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Управление перегрузкой",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Управление перегрузкой TCP",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Управление перегрузкой TCP действует только со стеком mips.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Статистика подключений",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Подключения, запросы и DNS-запросы",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение: "),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Содержимое не может быть пустым",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Управление глобальными добавленными правилами",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Архитектура"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control в Windows заблокировал неподписанный ReClashCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите ReClash. Повторно включить Smart App Control без переустановки Windows нельзя.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("Флаги сборки"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("Время сборки"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Среда"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("Файл ядра"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить сведения о ядре",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Способ запуска"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Расположение"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Управляемый процесс с повышенными правами",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Процесс через Helper",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "Встроенная библиотека",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Управляемый процесс через подписанный Helper",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage(
      "Отдельный процесс",
    ),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Открыть runtime-конфиг",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Платформа"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Работает"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage("Runtime-конфиг"),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Итоговая конфигурация после настроек и скриптов. Только просмотр.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать runtime-конфиг",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Запускается…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Остановлено"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Каталог данных",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Обнаружен сбой"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("Обход DPI"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Основа приложения"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Дополнительные функции",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Функции и идеи для провайдеров",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Прокси-ядро"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Содержит кнопку запуска, удалить нельзя",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "customColor": MessageLookupByLibrary.simpleMessage("Свой цвет"),
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "Имя не задано",
    ),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Не выбраны ни прокси, ни провайдеры прокси, поэтому ядро отклонит эту группу",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Группы прокси и правила из прокси приложения и других профилей",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Ресурсы пользовательских профилей",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Ресурсы пользовательских профилей включают прокси, провайдеры правил, фильтры и наборы значков.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Можно добавить",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить изменение; оно отменено",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Выбор по умолчанию",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "Конфигурация должна быть YAML-словарём с полями name и type",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Сбой"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Многоплатформенный прокси-клиент на основе ClashMeta: простой и удобный, с открытым исходным кодом и без рекламы.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Графический агент авторизации недоступен. Запустите его в текущем сеансе рабочего стола и повторите попытку.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Авторизация отменена. TUN не запущен.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "Разрешение не предоставлено. TUN не запущен.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Для TUN нужна авторизация. Запустите подключение или включите TUN, чтобы предоставить разрешение.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Время ожидания авторизации истекло. Повторите попытку кнопкой подключения.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "Авторизованный Core не смог завершить проверенный запуск. Проверьте пакет и системные журналы.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core или Helper не прошёл проверку целостности. Переустановите полный пакет ReClash.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Разрешите Helper ReClash в «Системных настройках» → «Основные» → «Объекты входа и расширения», затем повторите попытку.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "Установленный Helper использует другой протокол. Проверьте другую установку или переопределение службы и переустановите полный пакет.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "Существующую регистрацию Linux Helper нельзя безопасно заменить. Проверьте принадлежность службы и регистрацию: повторная авторизация не устранит конфликт.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd не смог запустить Helper для TUN. Проверьте журнал службы: установщик попытался восстановить предыдущую установку.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "Для TUN необходим сеанс Linux под управлением systemd. Эта система не может запустить сетевой Helper.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Helper для TUN недоступен. Проверьте установленный пакет и службу, затем повторите попытку.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "Предыдущая авторизация или остановка Core ещё не завершена. Дождитесь завершения и повторите попытку.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "Для TUN необходимы корректно подписанные приложение ReClash и Helper. Сборку без подписи или с подписью ad-hoc авторизовать нельзя.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core запущен, но адаптер TUN не готов. Перед использованием TUN проверьте журнал Core.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN IP назначения",
    ),
    "details": m22,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Использует сторонний API; только для справки",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage(
      "Прокси для подключения",
    ),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Прокси для подключения — исход, через который идёт обращение к NTP-серверу.",
    ),
    "dialerProxyLoopStopped": m23,
    "direct": MessageLookupByLibrary.simpleMessage("Прямой"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Отключить пересылку ICMP",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "При отключённой пересылке ICMP TUN сам отвечает на ping, поэтому ping больше не показывает реальную задержку.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Отключить TCP keep-alive",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Отключить UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Выключено"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Отменить изменения?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Отказ от ответственности",
    ),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "Устанавливая, копируя или используя Программу, вы подтверждаете, что прочитали и приняли это заявление полностью. Если вы не согласны с каким-либо его условием, немедленно прекратите использование и удалите Программу.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage(
      "Принятие условий",
    ),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "Я прочитал(а) и понимаю это заявление",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Чтобы подтвердить, что вы ознакомились с ним, прочитайте следующее заявление и отметьте пункт ниже:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Подтвердите заявление",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Разработчики могут изменять это заявление в любом выпуске; изменения вступают в силу с момента публикации выпуска. Продолжая пользоваться Программой после обновления, вы принимаете изменённое заявление.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Изменения заявления",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Перед использованием ReClash (далее — «Программа») внимательно прочитайте это заявление и убедитесь, что понимаете его полностью. Нажимая «Согласен», вы подтверждаете, что прочитали, поняли и принимаете все приведённые ниже условия. Если вы не согласны, нажмите «Выход» и прекратите использование Программы.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "В максимальной степени, допустимой применимым законодательством, ни разработчики, ни участники проекта не несут ответственности за любой прямой, косвенный, случайный, особый, штрафной или последующий ущерб, возникший в результате использования или невозможности использования Программы, включая, помимо прочего, потерю данных, повреждение устройства, сбои сети, прерывание деятельности, упущенную выгоду или связанные с этим правовые споры, даже если они были предупреждены о возможности такого ущерба.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Ограничение ответственности",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Программа распространяется с открытым исходным кодом по лицензии GPL-3.0. Вы можете свободно использовать, изменять и распространять её при соблюдении этой лицензии: производные работы также должны распространяться по GPL-3.0 с сохранением уведомлений об авторских правах.\n\nСторонние компоненты Программы, включая ядро Clash.Meta, распространяются по своим собственным лицензиям. Авторы оригинала не несут ответственности за проблемы, возникшие в изменённых или распространяемых третьими лицами версиях.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Лицензия с открытым исходным кодом",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Сама Программа не предоставляет прокси-серверы, узлы, подписки или услуги доступа к сети и не состоит в партнёрских, агентских или гарантийных отношениях с поставщиками таких услуг.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Программа не собирает и не отправляет адреса ваших подписок, сведения об узлах, содержимое конфигураций, посещённые сайты, записи о подключениях, содержимое трафика и журналы. Эти данные хранятся только на вашем устройстве, и у разработчиков нет к ним доступа.\n\nПрограмма обращается к сети только при использовании соответствующих функций, например загружает указанный вами адрес подписки при обновлении профиля или обращается к GitHub при проверке обновлений.\n\nПрограмма не содержит никаких сервисов статистики или отчётов о сбоях ни на одной платформе.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Сбор данных и конфиденциальность",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Дочитайте до конца",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Вы самостоятельно убеждаетесь, что использование Программы законно в вашей стране или регионе, и единолично несёте юридическую ответственность за все действия с ней и их последствия.\n\nПодписки, узлы и конфигурации, которые вы импортируете, выбираете вы сами. Законность их источника, безопасность содержимого и надёжность сервиса — вопрос между вами и их поставщиками.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Ваша ответственность",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Введите заявление выше",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Не совпадает с текстом заявления",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Чтобы подтвердить, что вы ознакомились с ним, полностью введите следующее заявление в поле ниже:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Повторите заявление",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Программа — это клиент сетевого прокси с открытым исходным кодом на основе ядра Clash.Meta (mihomo). Она предоставляет только локальные инструменты: управление конфигурациями, маршрутизацию по правилам и пересылку трафика.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Характер программы",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Ссылки на подписки, файлы конфигурации, наборы правил, скрипты, внешние ресурсы и внешние ссылки предоставляются третьими лицами. Разработчики не могут проверять и не проверяют их законность, точность, безопасность и доступность и не дают на них никаких гарантий.\n\nУтечка данных, финансовые потери, блокировка аккаунта или иной ущерб, вызванные сторонним контентом, урегулируются между вами и третьим лицом; разработчики не несут за это никакой ответственности.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Сторонний контент",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Программа предназначена только для некоммерческого использования: обучения, обмена опытом и технических исследований. Любое коммерческое использование строго запрещено, включая, помимо прочего, платное распространение, продажу в комплекте, использование в составе коммерческого сервиса или ведение деятельности от имени Программы. Любая коммерческая деятельность не имеет отношения к Программе и её разработчикам.\n\nСтрого запрещено использовать Программу для действий, нарушающих законы вашей страны или региона, включая, помимо прочего, обход законно установленных ограничений доступа к сети, распространение незаконной информации, сетевые атаки и нарушение законных прав других лиц.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Ограничения использования",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Программа предоставляется «как есть» и «по мере доступности», без каких-либо явных или подразумеваемых гарантий, включая, помимо прочего, гарантии товарной пригодности, пригодности для определённой цели, ненарушения прав, бесперебойной работы, отсутствия ошибок и уязвимостей.\n\nРазработчики не гарантируют, что Программа будет соответствовать вашим потребностям или работать без сбоев и ошибок.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Отсутствие гарантий",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Без этого параметра TUN перехватывает все DNS-запросы на порт 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Добавленные здесь параметры заменяют DNS всех профилей из URL и файлов; остальные остаются такими, как в профиле. DNS пользовательского профиля задаётся в его содержимом.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS-запросы"),
    "docked": MessageLookupByLibrary.simpleMessage("Закреплённая"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "done": MessageLookupByLibrary.simpleMessage("Готово"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Скорость загрузки",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Загрузка обновления",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Длительность"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("Изменить панель"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Редактировать глобальные правила",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Редактировать прокси"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Редактировать группу прокси",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Редактировать правило"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Изменить SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Редактор недоступен",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Время"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage(
      "Резерв для пустой группы",
    ),
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enabled": MessageLookupByLibrary.simpleMessage("Включено"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Подробности ошибки"),
    "es": MessageLookupByLibrary.simpleMessage("Испанский"),
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Исключённые порты назначения",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик на исключённые порты назначения идёт в обход TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Фильтр исключения"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Исключённые интерфейсы",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик с исключённых интерфейсов, например с docker0, идёт в обход TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Исключённые исходные порты",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик с исключённых исходных портов идёт в обход TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Исключённые SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "При подключении к Wi-Fi с исключённым SSID состояние работы приложения переключается автоматически.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage(
      "Исключённые ID пользователей",
    ),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик процессов исключённых ID пользователей идёт в обход TUN.",
    ),
    "existsTip": m25,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Выйти из полноэкранного режима",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Выходные узлы"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Ожидаемый статус"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт выполнен"),
    "extend": MessageLookupByLibrary.simpleMessage("Расширение"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Режим расширения"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Скрипт расширения"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер позволяет управлять ядром через порт 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Секрет внешнего контроллера",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Очень крупный"),
    "fade": MessageLookupByLibrary.simpleMessage("Растворение"),
    "failedCount": m26,
    "failedItem": m27,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр Fake-IP"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Режим фильтра Fake-IP",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "В режиме фильтра Fake-IP blacklist исключает совпадения, whitelist применяется только к ним, rule — по правилам.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон Fake-IP"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Диапазон Fake-IP (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("TTL Fake-IP"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Фильтр fallback"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузить файл профиля напрямую",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл изменён. Сохранить изменения?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
    "filters": MessageLookupByLibrary.simpleMessage("Фильтры"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Поиск процесса"),
    "floating": MessageLookupByLibrary.simpleMessage("Плавающая"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Как в профиле"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Как в системе"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Размер"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Принудительно для DNS-сопоставлений",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "«Принудительно для DNS-сопоставлений» анализирует и соединения, домен которых получен из DNS-сопоставления.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage(
      "Принудительные домены",
    ),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Принудительные домены тоже анализируются; остальные соединения с доменом не затрагиваются.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно перезапустить ядро?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Французский"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo: экономия памяти",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Перейти к настройке добавленных правил",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Перейти к настройке скрипта",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Благодарности"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash существует благодаря их работе",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Сетка"),
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("групп"),
    "groupTimeoutCount": m31,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Кэшировать изменения?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Хешировать по пользователю входящего подключения",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Проверка состояния"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите ReClash.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Скрыть из списка"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Скрыть IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Скрыть пароль"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Скрывать прокси с таймаутом",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Не показывать прокси, у которых последний тест задержки завершился таймаутом",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Интервал перескока"),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostname": MessageLookupByLibrary.simpleMessage("Имя хоста"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Очистить все"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Удалить все комбинации горячих клавиш?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурация композитора",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Можно также добавить строку подключения в конфигурацию композитора. Файлы синхронизируются с сочетаниями ReClash и временно очищаются во время записи клавиш. Конфигурация рабочего стола не меняется автоматически; конфликты привязок нужно устранить в ней.",
    ),
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Глобальные горячие клавиши работают, даже когда окно скрыто. Нажмите на действие, чтобы записать сочетание клавиш.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Хоткеи рабочего стола",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Назначьте команду на сочетание клавиш в настройках рабочего стола. ReClash должен быть запущен, но окно может оставаться скрытым. Эти глобальные привязки настраиваются средствами рабочего стола.",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Файлы конфигурации композитора недоступны. Можно использовать команды рабочего стола выше.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Эти сочетания работают, когда окно приложения в фокусе. Для глобальных сочетаний подключите команды рабочего стола ниже.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "hotkeyNeedsModifier": m34,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Не задано"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Стандартные",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Заменить все комбинации стандартными?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "В безопасном режиме действия по сочетаниям отключены; привязки можно редактировать.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не зарегистрировано: сочетание может быть занято другим приложением",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursAgo": m35,
    "hoursAgoShort": m36,
    "hue": MessageLookupByLibrary.simpleMessage("Оттенок"),
    "icon": MessageLookupByLibrary.simpleMessage("Значок"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("История значков"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Наборы значков"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Наборов значков пока нет. Добавьте их в разделе «Ресурсы пользовательских профилей → Наборы значков»",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль значков"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("С подложкой"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Скрыто"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Без подложки"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL значка"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Игнорировать оптимизацию батареи",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Этот файл не является конфигурацией, которую можно импортировать",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Импорт заменит текущие группы прокси, правила и настройки этого профиля",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("Импорт по ссылке"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Импорт по URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Входящие"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Включённые интерфейсы",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Через TUN идёт только трафик с включённых интерфейсов, а исключённые интерфейсы больше не действуют.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage(
      "Включённые ID пользователей",
    ),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Через TUN идёт только трафик процессов включённых ID пользователей.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочно"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Не удалось запустить"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "При запуске ReClash произошла ошибка, и работа не может быть продолжена. Скопируйте подробности, чтобы сообщить о проблеме. Если ошибка повторяется, очистка данных обычно позволяет снова запустить приложение.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Инициатор"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("Источник"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Введите название группы прокси",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Введите содержимое правила",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage(
      "Установить обновление",
    ),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "Разрешение на список приложений отклонено, поэтому установленные приложения недоступны. Предоставьте его вручную в системных настройках.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Эта система не выдаёт список установленных приложений без разрешения. Предоставьте его, чтобы настроить прокси для отдельных приложений.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на список приложений",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Установленные шрифты",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Имя интерфейса"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Имя интерфейса задаёт сетевой интерфейс для исходящих соединений.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Исходящий интерфейс",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Как в конфигурации",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Внутренний IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Недопустимый файл резервной копии",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Введите диапазон IP в формате CIDR, например 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "Метка DSCP не может превышать 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Введите домен или IP-адрес",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Это не набор значков",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Это не ссылка на подписку и не ссылка на прокси",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Введите адрес и порт, например 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Поддерживаются только tcp и udp",
    ),
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Введите порт или диапазон, например 443 или 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Этот QR-код не содержит ссылку на профиль",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Введите числа или диапазоны, например 80 или 8000-9000, через /",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP-адрес"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Злоупотребления"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Метки"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Организация"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить тип IP",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Хороший"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Уровень"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Обычный"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Проверить снова"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Рискованный"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Качество"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Источник ответа"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Источники"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Другой исходящий IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Тип не определён"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Лимит запросов",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Тип"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Бизнес"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Дата-центр"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Мобильная сеть"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Домашний"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Тип неизвестен"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("Версия IP"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Трафик IPv6 принимается, только когда IPv6 включён.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "При включённом IPv6 VPN принимает входящий IPv6.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("Тайм-аут IPv6 (мс)"),
    "itemsCount": m42,
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "Простой TCP keep-alive",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал TCP keep-alive",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "kk": MessageLookupByLibrary.simpleMessage("Казахский"),
    "ko": MessageLookupByLibrary.simpleMessage("Корейский"),
    "label": MessageLookupByLibrary.simpleMessage("Метка"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "large": MessageLookupByLibrary.simpleMessage("Крупный"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Последнее обновление"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Запуск не завершён",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена; вы можете запустить её вручную.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "license": MessageLookupByLibrary.simpleMessage("Лицензия"),
    "licenses": MessageLookupByLibrary.simpleMessage("Лицензии"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Пакеты, входящие в приложение",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Перенос строк"),
    "link": MessageLookupByLibrary.simpleMessage("Ссылка"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Получить профиль по ссылке на подписку или на прокси",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Жидкое стекло"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Метка маршрутизации",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Метка маршрутизации действует только в Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Активные соединения",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "local": MessageLookupByLibrary.simpleMessage("Локально"),
    "localImage": MessageLookupByLibrary.simpleMessage("Локальное изображение"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Доступ к локальной сети запрещён: используется стек gvisor, локальная сеть недоступна.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Локальные прокси"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию отклонено, поэтому невозможно получить имя текущей сети Wi-Fi. Включите разрешение на геолокацию вручную в системных настройках.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "По требованию системы для получения имени сети Wi-Fi необходимо разрешение на геолокацию. На Android выберите «Разрешить всегда», иначе имя сети Wi-Fi нельзя получить, пока приложение в фоне.",
    ),
    "locationPermissionGuide": m44,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на геолокацию",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Захват логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "При отключении захвата логов раздел логов скрывается.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Логи и диагностика",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Снятие ограничения loopback для UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Мейнтейнер"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Учитывать регистр"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Сопоставлять IP источника",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. число неудач",
    ),
    "maxLengthTip": m45,
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Резидентная память",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage(
      "Приложение и общая",
    ),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage(
      "Свободная куча",
    ),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage(
      "Используемая куча",
    ),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Ядро не запущено",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Накладные расходы среды",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Стеки горутин"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Оценка по резидентной памяти процессов; может отличаться от данных системы.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Ядро работает в процессе приложения. Его доля оценивается по статистике среды выполнения, остальное относится к приложению и общей памяти.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Память приложения и ядра",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage(
      "Память освобождена",
    ),
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Нижняя панель"),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Запрос отменён",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться к серверу. Проверьте подключение к сети или настройки прокси",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить адрес сервера. Проверьте правильность URL и работу DNS",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Имя сети"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Слишком много запросов (HTTP 429). Подождите немного и повторите попытку",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Секрет сети"),
    "networkServerError": m55,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("Перехват трафика"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Время ожидания запроса истекло. Проверьте сеть или прокси и повторите попытку",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Не удалось установить защищённое соединение. Сертификат сервера может быть недействителен, или соединение перехватывается",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Следующее совпадение"),
    "no": MessageLookupByLibrary.simpleMessage("Нет"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Больше не напоминать",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не разрешать IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Не разрешать имя хоста",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Ничего не найдено",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Узлы"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Этот внешний ресурс не является текстовым файлом",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Не запущено"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущую группу прокси нельзя выбрать",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал синхронизации (минуты)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP берёт время с NTP-сервера, а не из системных часов.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль, чтобы начать",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
    "obfs": MessageLookupByLibrary.simpleMessage("Обфускация"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Хост обфускации"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Режим обфускации"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Параметр обфускации"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Пароль обфускации"),
    "onDemand": MessageLookupByLibrary.simpleMessage("По условию"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "«По условию» приостанавливает прокси в исключённых сетях Wi-Fi.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Учитывать только трафик прокси",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Исходящие"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Выход"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Исходящий IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Подменять адрес назначения",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "«Подменять адрес назначения» подключается к обнаруженному домену вместо исходного адреса.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Переопределяемые параметры",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Разбирать чистые IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "«Разбирать чистые IP» анализирует соединения, у которых есть только IP-адрес.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "peers": MessageLookupByLibrary.simpleMessage("Пиры"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Выбрать из галереи"),
    "pinWindow": MessageLookupByLibrary.simpleMessage(
      "Закрепить поверх всех окон",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Введите название скрипта",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Загрузите корректный QR-код",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Плагин"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Хост плагина"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Режим плагина"),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Перескок портов"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("Порты"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Общий ключ"),
    "prerequisites": MessageLookupByLibrary.simpleMessage(
      "Предварительные условия",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Нажмите сочетание клавиш",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Запрет дубликатов подписок",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Отклонять ссылку подписки, которую уже использует существующий профиль",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "previousMatch": MessageLookupByLibrary.simpleMessage(
      "Предыдущее совпадение",
    ),
    "privateKey": MessageLookupByLibrary.simpleMessage("Закрытый ключ"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Пароль закрытого ключа",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите корректный интервал"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileBatchResult": m61,
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль изменён. Отключить автообновление?",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Профиль с этим URL подписки уже добавлен",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите название профиля",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только для этого профиля; не добавленные параметры используют значения по умолчанию.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только для этого профиля и имеет приоритет над переопределяемыми параметрами TUN в настройках сети.",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "protocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Параметр протокола"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("Версия протокола"),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Поддерживаются только удалённые ресурсы",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Группа прокси пуста",
    ),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Группы появятся здесь после запуска ядра",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "proxyType": MessageLookupByLibrary.simpleMessage("Тип прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Открытый ключ"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Чисто чёрный"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто чёрный режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код, чтобы получить профиль",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Быстрые действия"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Быстрое редактирование"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Последние запросы"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Рекомендуемые"),
    "recordType": MessageLookupByLibrary.simpleMessage("Тип записи"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Порт Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "regex": MessageLookupByLibrary.simpleMessage("Регулярное выражение"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Применить регион"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "Регион или списки приложений изменились. Повторите подбор для актуальных настроек.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "Приложения для этого региона не найдены. Ваши списки не изменены.",
    ),
    "regionAppsPreview": m72,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр подбора",
    ),
    "regionBypassSettings": m73,
    "regionChina": MessageLookupByLibrary.simpleMessage("Китай"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("Выберите страну"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("Текущий регион"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Ручные DNS и MTU, список обхода, правила маршрутизации и выбор сервисов сохраняются.",
    ),
    "regionDetected": m74,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage(
      "Подсказка устройства",
    ),
    "regionDnsSettings": m75,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Египет"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Базовые сетевые параметры и проверки сервисов для региона — независимо от языка интерфейса.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Сетевые значения и набор проверок не изменятся.",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "Подходящая подсказка не найдена. Используются только часовой пояс и системная локаль.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Проверки сервисов отключены",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Отключён"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Другой / общий"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "На Android изменения MTU или обхода могут потребовать подтверждённого перезапуска VPN. Подбор приложений запускается отдельно.",
    ),
    "regionPreviewBase": m76,
    "regionPreviewMtu": m77,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "Выбор прокси и ваши правила маршрутизации не изменятся.",
    ),
    "regionPreviewServices": m78,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage(
      "Настройки профиля",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Россия"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Подбор приложений по региону",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Сначала выберите поддерживаемый регион, чтобы использовать региональный подбор приложений.",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "страна системной локали",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "язык системы",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage(
      "часовой пояс",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Региональный профиль"),
    "regionTunSettings": m79,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage(
      "Выбрать определённый регион",
    ),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "Выбор страны обновляет только предпросмотр. Региональные значения изменятся после применения.",
    ),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Региональная адаптация",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Освободить память"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось освободить память",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённо"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Удалённое разрешение DNS",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Убрать"),
    "rename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "replace": MessageLookupByLibrary.simpleMessage("Заменить"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Заменить все"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Запросы и обновления",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Обязательно"),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На этой странице есть изменения. Вы уверены, что хотите выполнить сброс?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выполнить сброс?",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления должен быть больше 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Соблюдать правила"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "«Соблюдать правила» направляет DNS-соединения по правилам; нужен Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Код ответа"),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите перезапустить ядро?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Восстановить только профили",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия восстановления",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Совместимость",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Перезапись",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление выполнено",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Результат"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Адреса маршрутов"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Исключённые адреса маршрутов",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Метка маршрутизации"),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правило"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить полный домен",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ключевое слово в домене",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению домена",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить суффикс домена",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставление по маске; поддерживаются только * и ?",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить метку DSCP (только для входящих tproxy UDP)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон портов назначения",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить код страны IP-адреса",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить домены из Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя входящего подключения",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить входящий порт",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить тип входящего подключения",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя пользователя входящего подключения; несколько имён разделяются /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ASN, которой принадлежит IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов; IP-CIDR6 — просто псевдоним",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон суффиксов IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставляет все запросы, условия не нужны",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить TCP или UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило OR",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по имени процесса; на Android соответствует имени пакета",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению имени процесса; на Android соответствует имени пакета",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по маске имени процесса; поддерживаются только * и ?",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по полному пути процесса",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению пути процесса",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по маске пути процесса; поддерживаются только * и ?",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя повторного сопоставления; несколько имён разделяются /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Ссылка на набор правил; требуется настроить rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить код страны IP источника",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ASN IP источника",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов источника",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон суффиксов IP источника",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон портов источника",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Переход к подправилу; обратите внимание на скобки",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Правило пусто"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Правила должны быть YAML-списком, по одному правилу в элементе, например - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent напрямую",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Блокировать DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Защита от петли прокси",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage(
      "Блокировать QUIC",
    ),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage(
      "Блокировать STUN",
    ),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "Локальная сеть напрямую",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple и Microsoft напрямую",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Набор правил"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "В наборе правил нет пригодных записей",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Не удаётся прочитать этот файл mrs",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Набор правил смешивает домены и диапазоны IP, поэтому его тип не определить",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "Правило должно начинаться с поддерживаемого типа, например DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Правила"),
    "rulesCount": m80,
    "runTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "running": MessageLookupByLibrary.simpleMessage("Работает"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурация выполнения",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Безопасный режим"),
    "safeModeAppTitle": m81,
    "saturation": MessageLookupByLibrary.simpleMessage("Насыщенность"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Режим скрипта: переписывает весь профиль скриптом расширения",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Прокрутить к выбранному",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m82,
    "secretKey": MessageLookupByLibrary.simpleMessage("Ключ"),
    "sectionsInEffect": m83,
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Выберите набор правил",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Выберите стратегию распределения",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serviceAbnormalCount": m84,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("Все доступны"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Доступен"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Заблокировано"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Проверить"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Проверить все"),
    "serviceCheckedAt": m85,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Скоро появится"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Недопустимый провайдер",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Ошибка проверки"),
    "serviceManage": MessageLookupByLibrary.simpleMessage(
      "Управление сервисами",
    ),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Только оригиналы",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Не проверено"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Доступ ограничен",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Показан на панели",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Состояние сервисов"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Недоступен"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Регион не поддерживается",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("параметры"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "settingsCount": m86,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "Этот профиль зашифрован. Укажите ключ age, чтобы продолжить.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "Этот сервер ответил на отдельную пробу. Переключитесь и проверьте весь маршрут снова.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "Подключаться при открытии ReClash",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Включать это подключение вместе с приложением.",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Проверить подключение",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "Результат относится к этому маршруту, а не ко всем приложениям и сайтам.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Проверяем один выбранный маршрут. Системные запросы разрешений открываются отдельно.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Подключаемся и проверяем",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Подтверждено"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "Выбранный маршрут ответил. Трафик следует правилам профиля.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "Подключение работает",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Скопировать адрес прокси",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("Все приложения"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN перехватывает трафик устройства. Система может запросить разрешение.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android запросит разрешение на VPN-подключение. Выбор приложений доступен в настройках доступа.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "Выберите охват. Какие соединения идут через сервер, решают правила профиля.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "Настрою приложения вручную",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Укажите адрес локального прокси в каждом приложении, которое хотите подключить.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Перехват всего трафика не означает отправку всего через сервер. Прямые маршруты сохраняются.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage(
      "Системный прокси",
    ),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Приложения без поддержки системного прокси идут напрямую.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Какие приложения подключать?",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Подробности"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "Любой выбор можно изменить в настройках.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Выберите язык, чтобы прочитать соглашение. Позже его можно изменить.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "Настройка не завершена; подключение не проверено.",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Укажите этот адрес в нужных приложениях. Проверка не подтверждает, что приложения уже настроены.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Локальный прокси готов",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Не проверено"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "Маршрут ответил, но часть проверок не удалось подтвердить.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Подключение работает с ограничениями",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Разрешите подключение в системном окне, повторите проверку или выберите другой охват.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Нужно разрешение системы",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Поиск другого сервера",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Запуск подключения",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("Запуск ядра"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Подтверждение выхода",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Применение профиля",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Проверка маршрута",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Проверка сервисов",
    ),
    "setupProfileCount": m87,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash не предоставляет серверы. Добавьте подписку или конфигурацию вашего провайдера.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Импортировать профиль",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Ссылка подписки или подключения",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Профиль готов"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("Настроить позже"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль подключения",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Ваше подключение"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Проверка"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Охват"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage(
      "Применить настройки региона",
    ),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "Регион предложен по данным устройства, а не по выбранному языку интерфейса. Примените его, если он соответствует вашей сети.",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Оставить настройки профиля",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Проверить ещё раз"),
    "setupReport": MessageLookupByLibrary.simpleMessage("Отчёт проверки"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Разрешить подключение",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage(
      "Настроить подключение",
    ),
    "setupResume": MessageLookupByLibrary.simpleMessage("Продолжить настройку"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "Маршрут изменился во время проверки. Проверьте текущее подключение ещё раз.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "В безопасном режиме реальное подключение не запускается. Сохраните настройку или проверьте её в обычной сборке.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить выбор. Попробуйте ещё раз.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Сохранить без подключения",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Ваш выбор сохранён. Подключение можно включить с главной страницы, когда будете готовы.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Подключимся позже",
    ),
    "setupStepStatus": m88,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Ваш выбор сохранён. Прежнее подключение не остановлено.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка остановлена",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Первое подключение"),
    "setupTryServer": m89,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("Нет ответа"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "Подключение запущено, но выбранный маршрут не дал достаточных результатов.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Подключение не подтверждено",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "Операция не завершилась. Повторите попытку или откройте подробности.",
    ),
    "shareLinkUnreadable": m90,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать прокси из ссылок",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Кнопка остановки в уведомлении",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Показать пароль"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Размытие боковой панели",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать сквозь боковую панель размытый рабочий стол за окном",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Тихий запуск не показывает окно.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("По одному"),
    "singleImport": MessageLookupByLibrary.simpleMessage("По одному"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Здесь укажите одну ссылку, несколько можно задать в быстром редактировании списка",
    ),
    "singleValueTip": m91,
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Пропускать проверку сертификата",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Пропускаемые домены"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Обнаруженный домен из пропускаемых доменов не используется.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Пропускаемые адреса назначения",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Пропускаемые адреса источника",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Сдвиг"),
    "sliders": MessageLookupByLibrary.simpleMessage("Ползунки"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Протоколы"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Сниффер"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Сниффер определяет домен по трафику TLS, HTTP и QUIC, чтобы правила могли его сопоставить.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Порт SOCKS"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Мягкий"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP источника"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Спектр"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Статистика скорости",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения не может быть пустой",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("Список SSID пуст"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Трассировка стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартный режим: добавляет правила поверх профиля",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Старт"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("С нуля"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Запуск и фоновая работа",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "При отключённом DNS используется системный DNS.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "strictRoute": MessageLookupByLibrary.simpleMessage(
      "Строгая маршрутизация",
    ),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Строгая маршрутизация не даёт трафику вроде DNS обходить TUN, но другие устройства перестают видеть это устройство.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage(
      "Автоматически",
    ),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Свой User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Укажите корректный User-Agent без управляющих символов.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Выбор клиента не отправляет идентификаторы устройства.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Запрашивать как",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "Эти параметры действуют для URL подписок. Ссылки прокси импортируются локально.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Укажите ключ AGE для проверки этой подписки.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Применить проверенный результат"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "Сервер отклонил авторизацию. Подбор клиентов остановлен.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Проверить",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Не удалось получить совместимую подписку. Прежняя конфигурация не изменена.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Проверяет текущие значения формы без сохранения и перезапуска VPN. Проверяется разбор, а не доступность узлов.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage(
          "Снова спрашивать о потерях при импорте",
        ),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Скрыть URL подписки",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Последний успешный клиент"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "При импорте часть исходных данных не переносится. Проверьте потери перед применением.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Использовать этот клиент"),
    "subscriptionCompatibilityPrepared": m92,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core разобрал результат. Он ещё не сохранён и не применён.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "Сервер ограничил запросы. Повторите позже.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Показать URL подписки",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "Форма или профиль изменились. Проверьте подписку ещё раз.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "Время проверки подписки истекло.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Совместимость",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться. Подбор клиентов остановлен.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "Для этой подписки не осталось свободных мест для устройств. Удалите устройство в аккаунте провайдера и повторите попытку.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "Для этой подписки требуется зарегистрировать устройство. Следуйте инструкциям провайдера.",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Также отправлять ОС и модель устройства",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "Вместе с идентификатором будут отправляться версия ОС и модель устройства.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "Этому источнику подписки будет отправляться стабильный псевдонимный идентификатор устройства. Это не аппаратная аттестация; согласие хранится только на этом устройстве.",
    ),
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "Если включено, идентификатор устройства отправляется в запросах всех URL-подписок, кроме профилей с переопределением. Отправка ОС и сведений об устройстве отдельно включается для каждой подписки.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Идентификатор устройства",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "Отправлять HWID",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Как в настройках",
    ),
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "Принять и импортировать",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Понимаю, что часть исходных данных не сохранится.",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "Продолжить только с поддерживаемыми узлами.",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "Понимаю, что параметры исходного клиента не будут перенесены.",
    ),
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "конфигурация Clash",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "зашифрованная подписка",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "ссылки прокси",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "неизвестный формат",
    ),
    "subscriptionImportIgnoredSections": m93,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Нет поддерживаемых прокси-узлов для импорта.",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Запомнить это согласие для подписки",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Действует только для этого источника, формата и принятых видов потерь. Новые потери требуют повторного согласия.",
        ),
    "subscriptionImportReviewSummary": m94,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка импорта подписки",
    ),
    "subscriptionImportSkippedNodes": m95,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Информация о подписке",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("Подписка"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Аккаунт",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Купить тариф",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Купить трафик",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "Ссылка на логотип",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Поддержка",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage("Сайт"),
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Использовать интервал провайдера",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Введите пароль для sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Приостановлено…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Сменить профиль"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Нажмите на значок, чтобы повторить",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы разрешить",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Цель"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("Параллельный TCP"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть Telegram на этом устройстве.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Открыть Telegram"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Открыть в браузере",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал тестирования",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL для теста"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Тестировать при использовании",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Так будет выглядеть текст в приложении",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "tight": MessageLookupByLibrary.simpleMessage("Плотный"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "timeout": MessageLookupByLibrary.simpleMessage("Тайм-аут"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Тонированный"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "tk": MessageLookupByLibrary.simpleMessage("Туркменский"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Допуск"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Действие"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Выберите раздел или найдите настройку",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "Все активные соединения будут закрыты. Продолжить?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage(
      "Действие выполнено",
    ),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Конфигурация"),
    "toolsData": MessageLookupByLibrary.simpleMessage("Ресурсы и данные"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "Настройки и действия не найдены",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Сведения и отладка",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage(
      "Недавно использованные",
    ),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Сначала включите аутентификацию",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Сначала включите внешний контроллер",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Для этого действия запустите ядро",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Сначала выберите пользовательский сетевой интерфейс",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Сначала выберите сетевой стек MIPS",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Сначала добавьте это переопределение на странице DNS",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Сначала настройте WebDAV",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Диагностика"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Закрепить"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Закреплённое"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage(
      "Перезапустить ядро",
    ),
    "toolsResults": m96,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Выполнить"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Раздел"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Настройка"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Открепить"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Обновить ресурсы",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Обновление правил и скриптов может повторно применить конфигурацию и повлиять на соединения. Продолжить?",
    ),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "total": MessageLookupByLibrary.simpleMessage("Всего"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Загружено"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Отдано"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficPeak": m97,
    "trafficTotal": m98,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash говорит на вашем языке, чтобы им могли пользоваться люди из разных стран. Если какая-то формулировка режет глаз — напишите, поправим.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Предложить правку перевода",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить права для TUN, поэтому он выключен.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN работает только в режиме администратора.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Добавленные здесь параметры заменяют настройки TUN всех профилей; остальные остаются такими, как в профиле. Параметры, добавленные в самом пользовательском профиле, имеют приоритет.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Выключить"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage(
      "Режим ретрансляции UDP",
    ),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("Тайм-аут UDP"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут UDP задаётся в секундах и действует только со стеками gvisor, system и mixed.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Максимум"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Единая задержка"),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Свернуть в окно"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без названия"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Открепить окно"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Разрешить автоустановку",
    ),
    "updateAndroidAutoNote": MessageLookupByLibrary.simpleMessage(
      "Эти настройки не дают системного разрешения на установку приложений. Их можно изменить в любой момент.",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash сможет устанавливать проверенные стабильные обновления без нового запроса каждый раз. Ваш VPN не будет отключён. Android всё ещё может попросить подтвердить установку.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Разрешить автоматическую установку?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Устанавливать автоматически",
    ),
    "updateAutoInstallDescription": MessageLookupByLibrary.simpleMessage(
      "Устанавливать подходящие стабильные обновления только при выключенном VPN. Важные изменения всегда ждут вашего решения.",
    ),
    "updateBackgroundNote": MessageLookupByLibrary.simpleMessage(
      "Закрытие окна не остановит загрузку.",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Отменить загрузку",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Канал обновлений"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Предрелиз"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage("Релиз"),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Проверять автоматически",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить обновления.",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Проверьте соединение и попробуйте ещё раз.",
    ),
    "updateCheckQuietly": MessageLookupByLibrary.simpleMessage(
      "Периодически проверять, пока ReClash работает. Обновление появится на главной странице, без открытия окна.",
    ),
    "updateCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Ищем новую версию в выбранном канале.",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("Закрыть окно"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android требуется ваше согласие. Продолжите, чтобы открыть системное подтверждение.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Подтвердите в Android",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Продолжить в фоне",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Продолжить установку",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "У вас последняя версия",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "На этой платформе ReClash открывает страницу релиза. Загрузите и установите обновление самостоятельно.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "Проверенная загрузка для этого устройства недоступна. Выберите пакет на странице релиза.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Отключить и установить",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Оставить ручную установку",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Загрузить обновление",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Загрузить заново",
    ),
    "updateDownloadDescription": MessageLookupByLibrary.simpleMessage(
      "Окно можно закрыть. Прогресс останется на главной странице.",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить обновление.",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Загруженная часть сохранена. Проверьте соединение и продолжите загрузку.",
    ),
    "updateExistingVersionSafe": MessageLookupByLibrary.simpleMessage(
      "Установленная версия остаётся без изменений.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Понятно"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить установщик пакетов.",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android не завершил установку. Попробуйте ещё раз, когда будет удобно.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage(
      "Установить сейчас",
    ),
    "updateInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash уже использует новую версию.",
    ),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Обновление установлено",
    ),
    "updateInstalledVersion": m99,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android завершает установку. На этом этапе ReClash может закрыться.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Устанавливаем обновление",
    ),
    "updateMinutes": m100,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage(
      "У вас уже установлена последняя версия.",
    ),
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage("Что нового"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Описание изменений не опубликовано.",
    ),
    "updateOfferDownloadNote": MessageLookupByLibrary.simpleMessage(
      "Загрузка не устанавливает обновление и не прерывает VPN.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "Доступно обновление",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Открыть настройки Android",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage(
      "Сборка для устройства",
    ),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage(
      "Размер загрузки",
    ),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Проверка пакета",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Проверим после загрузки, до установки",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Целостность, приложение и подпись проверены",
    ),
    "updatePackageVersion": MessageLookupByLibrary.simpleMessage("Версия"),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Пауза"),
    "updatePausedDescription": MessageLookupByLibrary.simpleMessage(
      "Загруженная часть сохранена. Продолжите, когда будет удобно.",
    ),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Загрузка на паузе",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Разрешите ReClash устанавливать приложения из этого источника и вернитесь, чтобы продолжить.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Нужно разрешение Android",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Настройте проверку, загрузку и установку независимо друг от друга.",
    ),
    "updatePreferencesIntro": MessageLookupByLibrary.simpleMessage(
      "Обновления по вашим правилам",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Настройки не сохранены. Попробуйте ещё раз; автоустановка не включена.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Настройки обновлений",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage("Загружать по Wi-Fi"),
    "updatePreloadDescription": MessageLookupByLibrary.simpleMessage(
      "Загружать доступные обновления по Wi-Fi. При смене сети автоматическая загрузка приостанавливается.",
    ),
    "updateReadyDescription": MessageLookupByLibrary.simpleMessage(
      "Пакет прошёл все проверки. Установите сейчас или оставьте на потом.",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Готово к установке",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Подробности релиза",
    ),
    "updateRemainingTime": m101,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Продолжить загрузку",
    ),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Проверить ещё раз",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Повторить установку",
    ),
    "updateSeconds": m102,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Все примечания к релизу",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Показать все изменения",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Обновления"),
    "updateTransferSpeed": m103,
    "updateVerificationGuard": MessageLookupByLibrary.simpleMessage(
      "Пакет, не прошедший проверку, никогда не будет установлен.",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить целостность загруженного обновления.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Файл, версия или подпись не прошли проверку. Загрузите новую копию и попробуйте ещё раз.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Этот пакет нельзя установить",
    ),
    "updateVerifyingDescription": MessageLookupByLibrary.simpleMessage(
      "Перед установкой проверяем файл, версию приложения и сертификат подписи.",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Проверяем обновление",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Для установки ReClash ненадолго закроется. Отключайте VPN, только если готовы прервать соединение.",
    ),
    "updateVpnInstallNote": MessageLookupByLibrary.simpleMessage(
      "При установке приложение ненадолго закроется. VPN не отключится без вашего подтверждения.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "Ваш VPN ещё работает",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Отдача"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("Скорость отдачи"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL-схема"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Действие"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Добавить подписку"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Создать профиль по HTTP- или HTTPS-ссылке подписки с необязательным именем.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось подтвердить подлинность зашифрованной ссылки. Она может быть повреждена или использовать другой ключ.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Создать ссылку"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "В ссылку входят только поля выбранного действия. Ссылка конфигурации содержит все её данные и не позволяет обойти подтверждение.",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage(
      "Закрыть приложение",
    ),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Следовать настройке закрытия: скрыть окно или выйти из ReClash. На Android используется обычное поведение закрытия приложения.",
    ),
    "urlSchemeConfigCounts": m104,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте конфигурацию YAML или JSON",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Состав конфигурации",
    ),
    "urlSchemeConfirmMessage": m105,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Внешняя команда приложения",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Внешние команды подключения и закрытия требуют подтверждения. Сначала завершите настройку подключения.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Подключить"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Запустить подключение с выбранным профилем и текущими настройками охвата.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Подключение"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Формат содержимого",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "При преобразовании часть содержимого пропускается. Проверьте и подтвердите изменения во время импорта.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось скопировать ссылку. Повторите попытку.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage(
      "Скопировать ссылку",
    ),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Не удалось доставить ссылку или очередь заполнена. Повторите попытку после завершения текущего действия.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Отключить"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Остановить подключение, не меняя выбранный профиль.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Встроенная конфигурация",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Пример профиля",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Импортировать конфигурацию",
    ),
    "urlSchemeImportConfirm": m106,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Импортировать встроенную в ссылку UTF-8-конфигурацию в Base64 с необязательным именем.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage(
      "Проверить ссылку",
    ),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте ссылку приложения или профиля",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "Проверка выполняется на устройстве. Она не открывает ссылку, не скачивает подписку и не импортирует профиль.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "Структура ссылки корректна. Доступность подписки и проверка ядром выполняются только при импорте.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Результат проверки",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Установить конфигурацию",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Импортировать подписку через формат install-config, поддерживаемый клиентами Clash.",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "Свяжите ReClash с ярлыками, сайтами и другими приложениями. Создайте готовую ссылку или проверьте её перед открытием.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "Встроенная конфигурация не является корректными UTF-8-данными в Base64.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "Ссылка некорректна. Проверьте её структуру и percent encoding.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Имя профиля должно содержать не более 64 символов и не иметь управляющих символов.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Укажите корректный HTTP- или HTTPS-адрес подписки.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "В ссылке отсутствует URL подписки или конфигурация.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "Никакие действия не выполнялись.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage(
      "Показать приложение",
    ),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Вывести ReClash на передний план, не меняя подключение.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Параметры"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать буфер обмена. Вставьте ссылку вручную.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр ссылки",
    ),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Заполните обязательные поля, чтобы увидеть ссылку.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Ссылка может содержать токены доступа и учётные данные прокси. Делитесь ею только с теми, кому доверяете; ReClash не хранит историю ссылок.",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "Команды профилей открывают конструктор. Входящий импорт требует согласия и проходит обычные проверки и преобразование.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Ссылки на прокси",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Ссылка распознана",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Завершите настройку подключения перед использованием внешних команд подключения.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Поддерживаемые ссылки импорта",
    ),
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Ссылки Clash, обёртки INCY и Happ и ссылки на прокси работают также при ручном импорте и сканировании QR. Неизвестные версии шифрования отклоняются.",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Переключить подключение",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Подключить, если остановлено; отключить, если запущено. В подтверждении указано фактическое действие.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "В ссылке слишком много вложенных обёрток.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "Ссылка превышает 4 МБ или встроенная конфигурация превышает 2 МБ.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "Эта команда ссылки не поддерживается.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "Эта версия шифрования не поддерживается. Запросите обычную ссылку подписки.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage(
      "Подставить пример",
    ),
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "Ссылки подписок, встроенные конфигурации и INCY crypt1",
    ),
    "urlTip": m107,
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системный hosts",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("использовано"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage(
      "Использованный трафик",
    ),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
    "uz": MessageLookupByLibrary.simpleMessage("Узбекский"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Виртуальный IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Яркий"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено изменение настроек VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN автоматически направляет весь системный трафик через VpnService.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Размытие"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Непрозрачность карточек",
    ),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage(
      "Выбрать изображение",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Затемнение"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Настройки изображения",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Использовать свой фон",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage(
      "Размещение изображения",
    ),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Вписать"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Заполнить"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Растянуть"),
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "Нажмите на сохранённый фон, чтобы применить его, или добавьте новый.",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Положение по горизонтали",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Выберите корректное изображение PNG, JPEG или WebP.",
    ),
    "wallpaperImageLabel": m108,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрирование"),
    "wallpaperLibraryFull": m109,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Непрозрачность изображения",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("Читаемость"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage(
      "Удалить изображение",
    ),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("Сбросить эффекты"),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Сбросить кадрирование",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить фон. Прежний фон сохранён.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Масштаб"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG или WebP · до 20 МБ",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage(
      "Пользовательский фон",
    ),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Выберите изображение размером до 20 МБ и 50 мегапикселей.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Изображение недоступно",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Положение по вертикали",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка WebDAV",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Веб-панель"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Доступ к панели завершён",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Доступ локальный и защищён секретом. Открытие панели не меняет сохранённые настройки внешнего контроллера. Завершите доступ здесь, когда закончите работу в браузере.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось применить конфигурацию панели.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "Загруженный файл не является корректным архивом панели.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Ядро отклонило секрет доступа. Откройте панель заново.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ из браузера действует до его завершения здесь или выхода из ReClash",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Уже выполняется другая операция с панелью.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Операция с панелью отменена.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "Контрольная сумма панели не совпадает с закреплённым релизом.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ядро ещё не готово.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Локальные веб-панели управления ядром",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить панель. Повторите попытку.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Загрузка панели",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ завершится при закрытии панели",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "Завершить доступ к панели",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Распаковка панели",
    ),
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage("Файлы панели"),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Панель"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Установить панель",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Выбранная панель загрузится при первом открытии. Используется закреплённый релиз с проверкой SHA-256.",
    ),
    "webDashboardInstalledVersion": m110,
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть браузер.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "Нет активной сессии панели",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Выберите профиль перед открытием панели.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Не установлена",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Открыть панель"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Открыть в браузере",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Перезагрузить"),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "В безопасном режиме доступ к панели отключён.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось безопасно прочитать или заменить файлы панели.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "Архив панели превышает допустимый размер.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Ядро не отдаёт выбранную панель.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Проверка загрузки",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Записывать в систему",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "«Записывать в систему» также устанавливает системные часы; Android это игнорирует.",
    ),
    "yearsAgo": m111,
    "yearsAgoShort": m112,
    "yes": MessageLookupByLibrary.simpleMessage("Да"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
  };
}
