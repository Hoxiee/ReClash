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

  static String m0(time) => "Подключено ${time}";

  static String m1(code) =>
      "Windows отказалась запускать ReClashCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите ReClash в этой политике или отключите её и повторите попытку.";

  static String m2(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, выбор профиля ${name} сброшен, а автоматическая настройка пропущена. Вы можете снова выбрать его в любой момент.";

  static String m3(url) => "Создать профиль по ссылке ${url}?";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дней')}";

  static String m6(label) => "Удалить выбранные элементы (${label})?";

  static String m7(label) => "Удалить «${label}»?";

  static String m8(token) => "${token} задаётся приложением и будет отброшен";

  static String m9(count) =>
      "${Intl.plural(count, zero: 'нет аргументов', one: '1 аргумент', few: '${count} аргумента', other: '${count} аргументов')}";

  static String m10(token) => "${token} требует значение";

  static String m11(token) => "${token} — не опция";

  static String m12(token) => "Неизвестная опция ${token}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 домен', few: '${count} домена', other: '${count} доменов')}";

  static String m14(count) => "Готово: протестировано ${count} стратегий";

  static String m15(count) =>
      "Прогоняет все известные стратегии по ${count} хостам через движок; текущая стратегия возвращается по окончании";

  static String m16(index, total) => "Тестируется ${index} из ${total}";

  static String m17(passed, total) => "Отвечают ${passed} из ${total} хостов";

  static String m18(label) => "Сведения: ${label}";

  static String m19(label) => "Поле «${label}» не может быть пустым";

  static String m20(count) =>
      "${Intl.plural(count, one: '${count} запись', few: '${count} записи', many: '${count} записей', other: '${count} записи')}";

  static String m21(label) => "«${label}» уже существует";

  static String m22(name) => "${name}: уже последняя версия";

  static String m23(name) => "${name}: обновлено";

  static String m24(time) => "${time} назад";

  static String m25(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m26(count) =>
      "${Intl.plural(count, one: '${count} час', few: '${count} часа', many: '${count} часов', other: '${count} часа')}";

  static String m27(target) => "${target} — недопустимая политика";

  static String m28(proxyName) => "${proxyName} — недопустимый прокси";

  static String m29(providerName) =>
      "${providerName} — недопустимый провайдер прокси";

  static String m30(subRule) => "${subRule} — недопустимый SUB_RULE";

  static String m31(appName) =>
      "1. Откройте Системные настройки → Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nКогда закончите, вернитесь в приложение и продолжите.";

  static String m32(label, max) => "«${label}» — не более ${max} символов";

  static String m33(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m34(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m35(label) => "${label}: пока ничего нет";

  static String m36(label) => "Значение «${label}» должно быть числом";

  static String m37(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m38(count) => "${count} прокси";

  static String m39(count) =>
      "${Intl.plural(count, one: '${count} правило', few: '${count} правила', many: '${count} правил', other: '${count} правила')}";

  static String m40(darkAt, lightAt) => "Тёмная с ${darkAt} до ${lightAt}";

  static String m41(count) =>
      "${Intl.plural(count, one: '${count} секунда', few: '${count} секунды', many: '${count} секунд', other: '${count} секунды')}";

  static String m42(count) => "Выбрано: ${count}";

  static String m43(alive, total) =>
      "Сейчас доступны ${alive} из ${total} серверов";

  static String m44(band) => "полоса ${band}";

  static String m45(bands) => "Полосы: ${bands}";

  static String m46(count) => "Остывает после ${count} отказов";

  static String m47(answered, total) => "ответили ${answered} из ${total}";

  static String m48(seconds) => "осталось ${seconds} сек";

  static String m49(count) => "${count} отказов подряд";

  static String m50(measured, total) => "измерено ${measured} из ${total}";

  static String m51(preset) => "${preset} · изменён";

  static String m52(left, cap) =>
      "Осталось проб в этом часе: ${left} из ${cap}";

  static String m53(seconds) => "${seconds} с";

  static String m54(eligible, total) => "${eligible} из ${total} пригодны";

  static String m55(eligible, total, blocked) =>
      "прошли ${eligible} из ${total}, отсеяно ${blocked}";

  static String m56(from, to) => "${from} → ${to}";

  static String m57(time) => "Смена сервера ${time} назад";

  static String m58(count) => "${count} серверов";

  static String m59(host) => "Провайдер переехал на ${host}";

  static String m60(count) =>
      "${Intl.plural(count, one: 'Подписка истекает через ${count} день', few: 'Подписка истекает через ${count} дня', many: 'Подписка истекает через ${count} дней', other: 'Подписка истекает через ${count} дней')}";

  static String m61(value) => "Провайдер предлагает ${value}";

  static String m62(total) => "свободно из ${total}";

  static String m63(label) => "Значение «${label}» должно быть URL";

  static String m64(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN проходят только выбранные приложения",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Выбор приложений, использующих прокси",
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
    "actionMode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Старт/Стоп"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Добавить сеть"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Добавить прокси"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Добавить группу прокси",
    ),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Добавить провайдеров прокси",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Добавить виджет"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Добавленные правила"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Дополнительные параметры",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес WebDAV",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Расширенная конфигурация",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Прочие параметры конфигурации",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Если включить, некоторые приложения смогут обходить VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage(
      "Доступ из локальной сети",
    ),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Другие устройства смогут подключаться к прокси",
    ),
    "announce": MessageLookupByLibrary.simpleMessage("Анонсы"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Иконка приложения"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Лаунчер перерисует иконку через несколько секунд. На некоторых лаунчерах закреплённый ярлык может пропасть.",
    ),
    "appIconCool": MessageLookupByLibrary.simpleMessage("Холодная"),
    "appIconDarkMono": MessageLookupByLibrary.simpleMessage("Тёмный монохром"),
    "appIconInverted": MessageLookupByLibrary.simpleMessage("Инверсия"),
    "appIconMono": MessageLookupByLibrary.simpleMessage("Монохромная"),
    "appIconSepia": MessageLookupByLibrary.simpleMessage("Сепия"),
    "appearance": MessageLookupByLibrary.simpleMessage("Оформление"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Тема, цвета, иконки и вид панели",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("Иконка"),
    "appearanceLayout": MessageLookupByLibrary.simpleMessage("Макет"),
    "appearanceMotion": MessageLookupByLibrary.simpleMessage("Движение"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Тема"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Добавлять системный DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Принудительно добавлять системный DNS в конфигурацию",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки самого приложения",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Требовать учётные данные на локальном порту прокси, чтобы другие приложения не могли им воспользоваться",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Не применяется, пока включена аутентификация",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "authorized": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Автопроверка обновлений",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически проверять обновления при запуске приложения",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Автозакрытие соединений",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически закрывать соединения после смены узла",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться автоматически при старте системы",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автовключение"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Включаться автоматически при открытии приложения",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Настраивать системный DNS автоматически",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (в минутах)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана",
    ),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Базовая конфигурация"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Изменения базовой конфигурации применяются глобально",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Основная информация"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Базовые стратегии"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Чтобы приложение работало в фоне, отключите для него оптимизацию батареи. Нажмите, чтобы перейти к настройкам.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Из-за ограничений системы статус оптимизации заряда батареи не удаётся корректно прочитать, пока приложение работает",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим чёрного списка",
    ),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Заблокировать соединение",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключённые домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только при включённом системном прокси",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить его?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Снять выделение"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось переключить прокси; восстановлен предыдущий выбор",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("Сменить сервер"),
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
      "Отклонять недоверенные сертификаты. Если отключить проверку, подписки и резервные копии уязвимы для атаки «человек посередине».",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "У вас уже последняя версия",
    ),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("Классическая"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Сетка плиток и кнопка запуска",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Очистить поиск"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage(
      "Клиент не поддерживается",
    ),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "Провайдер не поддерживает этот клиент.",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт в буфер обмена",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Импорт из буфера обмена",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Закрыть соединения",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Разрывать все открытые соединения, когда VPN на паузе",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "В конфигурации уже есть данные",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Удалить все данные?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить эту группу прокси?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите закрыть текущее окно?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Вызвать сбой ядра?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "После подтверждения существующие данные будут перезаписаны",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "connectedFor": m0,
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Текущие соединения и их состояние",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение: "),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Содержимое не может быть пустым",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная"),
    "contrast": MessageLookupByLibrary.simpleMessage("Контраст"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "На чистом чёрном контраст +0,3 обычно читается лучше",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Глобальные правила",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Скопировать данные о версии",
    ),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control в Windows заблокировал неподписанный ReClashCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите ReClash. Повторно включить Smart App Control без переустановки Windows нельзя.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Обнаружен сбой"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Аналитика сбоев"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "Если включить, логи сбоев без конфиденциальных данных будут отправляться автоматически",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Создать профиль"),
    "createProfileFromUrlTip": m3,
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — клиент, на котором всё построено",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — функции и идеи для работы с провайдерами",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage(
      "mihomo — прокси-ядро",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "darkAt": MessageLookupByLibrary.simpleMessage("Тёмная в"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель"),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Вид панели"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Данные изменились. Сохранить?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "Приложение использует Firebase Crashlytics для сбора сведений о сбоях — это помогает повышать стабильность.\nСобираются данные об устройстве и подробности сбоев. Личные данные не собираются.\nЭту функцию можно отключить в настройках.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage("Сбор данных"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить изменение; оно отменено",
    ),
    "day": MessageLookupByLibrary.simpleMessage("день"),
    "days": MessageLookupByLibrary.simpleMessage("дней"),
    "daysAgo": m4,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("дня"),
    "daysLeft": m5,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS-сервер по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения адресов DNS-серверов",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteMultipTip": m6,
    "deleteTip": m7,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Кроссплатформенный клиент mihomo: переработанный дашборд, умная маршрутизация и полноценная поддержка подписок. Открытый исходный код, без рекламы и телеметрии.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN IP назначения",
    ),
    "desync": MessageLookupByLibrary.simpleMessage("Обход DPI"),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Аргументы движка"),
    "desyncArgsAppOwnedFlag": m8,
    "desyncArgsCount": m9,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m10,
    "desyncArgsPositional": m11,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "Не закрыта кавычка",
    ),
    "desyncArgsUnknownFlag": m12,
    "desyncCache": MessageLookupByLibrary.simpleMessage("Кэш стратегий"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Подобранные стратегии хранятся по сетям",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("Срок хранения"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage(
      "Лестница по умолчанию",
    ),
    "desyncDesc": MessageLookupByLibrary.simpleMessage(
      "Стратегии десинхронизации ByeDPI",
    ),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("Движок"),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("Переводить на TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Блокирует QUIC для категорий выше; десинк не работает с UDP",
    ),
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage(
      "Режим подключения",
    ),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("Маршрутизация"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage(
      "Сохранить текущую",
    ),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage(
      "Имя стратегии",
    ),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "Прервано: стратегии перестали доходить до движка",
    ),
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage(
      "Домены для теста",
    ),
    "desyncTestDomainsCount": m13,
    "desyncTestDone": m14,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "Движок упал на этой стратегии",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "Движок не запущен — сначала подключитесь с включённым обходом DPI",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Хосты, не прошедшие стратегию",
    ),
    "desyncTestHint": m15,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Выберите хотя бы один список доменов ниже",
    ),
    "desyncTestProgress": m16,
    "desyncTestScore": m17,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("Тест стратегий"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("Старт"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage(
      "Прогнать все пресеты",
    ),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 часов"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 часов"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 час"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 дней"),
    "details": m18,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Использует сторонний API; результат ориентировочный",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("Определяем IP…"),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage(
      "Достигнут лимит устройств",
    ),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "Провайдер сообщает, что лимит устройств для этой подписки достигнут. Подписка всё равно обновлена.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Прямой"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Отключить UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Отказ от ответственности",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Это программное обеспечение предназначено только для некоммерческого использования: обучения, обмена опытом и научных исследований. Коммерческое использование строго запрещено; любая коммерческая деятельность никак не связана с этим приложением.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("Настройки DNS"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Загрузка обновления",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Редактировать глобальные правила",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Изменить сеть"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Редактировать прокси"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Редактировать группу прокси",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Редактировать правило"),
    "emptyTip": m19,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Ввести вручную"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "entriesCount": m20,
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать приложение из недавних задач, когда оно в фоне",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Исключающий фильтр",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Исключаемые типы"),
    "existsTip": m21,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "expand": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Ожидаемый статус"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспортировано"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивная"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Если включить, ядром Clash можно управлять через порт 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("Загрузить извне"),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "extra": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр Fake-IP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон Fake-IP"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Обычно зарубежный DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Фильтр fallback"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Точная передача"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузить профиль из файла",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл изменён. Сохранить изменения?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Поиск процесса"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Может немного снизить производительность",
    ),
    "followProfile": MessageLookupByLibrary.simpleMessage("Как в профиле"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Принудительно перезапустить ядро?",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления должен быть больше 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Настройки Geo"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Ресурсы Geo"),
    "geoSkipped": m22,
    "geoUpdated": m23,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Экономия памяти при загрузке Geo",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Использует загрузчик Geo, который расходует меньше памяти",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Код GeoIP"),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Перейти к настройке скрипта",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Благодарности"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash существует благодаря их работе",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Кэшировать изменения?",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите ReClash.",
    ),
    "heroChecking": MessageLookupByLibrary.simpleMessage("Проверка сети…"),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage(
      "Измеряем выбранный узел",
    ),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("только что"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage(
      "Соединение не работает",
    ),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage("Узел не отвечает"),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage(
      "Трафик на паузе, защита ждёт",
    ),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage(
      "Узел отвечает медленно",
    ),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage(
      "Ждём подключения к сети",
    ),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("Вы не защищены"),
    "heroPaused": MessageLookupByLibrary.simpleMessage(
      "Пауза — доверенная сеть",
    ),
    "heroProtected": MessageLookupByLibrary.simpleMessage("Вы защищены"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage(
      "Переподключение…",
    ),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage(
      "Восстанавливаем туннель",
    ),
    "heroRoutingAgo": m24,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация отключена",
    ),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы включить защиту",
    ),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы возобновить защиту",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Скрыть из списка"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Скрыть пароль"),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "Добавить записи в файл hosts",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Конфликт горячих клавиш",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление приложением с клавиатуры",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("час"),
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursAgo": m25,
    "hoursCount": m26,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("часа"),
    "icon": MessageLookupByLibrary.simpleMessage("Значок"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("История значков"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль значков"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL значка"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Игнорировать оптимизацию батареи",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Импорт по URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Входящие"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Включить все прокси",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Включает все прокси вне групп; ниже можно добавить дополнительные группы прокси",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Включить всех провайдеров прокси",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "Если включить, выбранные провайдеры прокси будут переопределены",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочно"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Введите правильную горячую клавишу",
    ),
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
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Имя интерфейса"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сетевой интерфейс для исходящих соединений",
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
    "invalidPolicy": m27,
    "invalidProxy": m28,
    "invalidProxyProvider": m29,
    "invalidSubRule": m30,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Если включить, приложение сможет принимать трафик IPv6",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящие соединения IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал TCP keep-alive",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "kk": MessageLookupByLibrary.simpleMessage("Казахский"),
    "ko": MessageLookupByLibrary.simpleMessage("Корейский"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Запуск не завершён",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена — при необходимости запустите её вручную.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "license": MessageLookupByLibrary.simpleMessage("Лицензия"),
    "licenses": MessageLookupByLibrary.simpleMessage("Лицензии"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Пакеты, входящие в приложение",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "lightAt": MessageLookupByLibrary.simpleMessage("Светлая в"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "local": MessageLookupByLibrary.simpleMessage("Локально"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование на устройстве",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию отклонено, поэтому имя текущей сети Wi-Fi недоступно. Включите разрешение вручную в системных настройках.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Система требует разрешение на геолокацию, чтобы показать имя сети Wi-Fi. На Android выберите «Разрешить всегда», иначе имя сети не будет доступно, пока приложение в фоне.",
    ),
    "locationPermissionGuide": m31,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на геолокацию",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Захват логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Если отключить, раздел логов будет скрыт",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Собранные логи"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage("Разблокировка loopback"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Снимает ограничение loopback для приложений UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "madeBy": MessageLookupByLibrary.simpleMessage("Автор"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Сопоставлять IP источника",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "Куда направляются правила с целью MATCH-TARGET. По умолчанию — цель последнего правила MATCH в этом профиле.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("Цель MATCH"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. число ошибок",
    ),
    "maxLengthTip": m32,
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "metaInfo": MessageLookupByLibrary.simpleMessage("Подписка"),
    "min": MessageLookupByLibrary.simpleMessage("Минимальный"),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменяет стандартное поведение при выходе",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("минута"),
    "minutesAgo": m33,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("минуты"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m34,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "Разделяйте несколько значений запятыми",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "nameserver": MessageLookupByLibrary.simpleMessage("DNS-сервер"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика DNS-серверов",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Задать политику DNS-серверов для доменов",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("Сетевые настройки"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Проверка сети"),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Home Wi-Fi) или подсеть (192.168.1.0/24)",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети. Проверьте подключение и повторите попытку.",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока нет доверенных сетей",
    ),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральная"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("Обновлённый вид"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Кольцо подключения и трафик под ним",
    ),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("Новая"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Следующее совпадение"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("Нет анонсов"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Горячих клавиш пока нет"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Больше не напоминать",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noRecords": MessageLookupByLibrary.simpleMessage("Записей пока нет"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не определять IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Не преобразовывать домен в IP",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущую группу прокси нельзя выбрать",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Текущая сеть не из доверенных",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Профилей пока нет. Сначала добавьте профиль.",
    ),
    "nullTip": m35,
    "numberTip": m36,
    "off": MessageLookupByLibrary.simpleMessage("Выключено"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только значок"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Учитывать только прокси-трафик",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Если включить, учитывается только трафик через прокси",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("Открыть в браузере"),
    "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "override": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределить DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Если включить, настройки DNS из профиля будут переопределяться",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage(
      "Режим переопределения",
    ),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Переопределить сетевые настройки",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Применять порты, IPv6, allow-lan, find-process-mode и стек TUN из приложения вместо значений подписки",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage(
      "Скрипт переопределения",
    ),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage(
      "Пользовательский",
    ),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Пользовательский режим: полная настройка групп прокси и правил",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("Анимация страниц"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Анимировать переключение между страницами",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("Приостановка VPN…"),
    "paused": MessageLookupByLibrary.simpleMessage("На паузе"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage(
      "Бессрочная подписка",
    ),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Выбрать из галереи"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Выбор сети"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Сети Wi-Fi поблизости",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Сети Wi-Fi не найдены",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Чтобы увидеть сети Wi-Fi поблизости, нужно разрешение на геолокацию",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Поиск сетей Wi-Fi поблизости…",
    ),
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
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portTip": m37,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Предпочитать HTTP/3 для DoH",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Требования"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Нажмите клавишу"),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "previousMatch": MessageLookupByLibrary.simpleMessage(
      "Предыдущее совпадение",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите корректный интервал"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль изменён. Отключить автообновление?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите название профиля",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providerView": MessageLookupByLibrary.simpleMessage(
      "Оформление от провайдера",
    ),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "Провайдер подписки может оформить страницу прокси по-своему. Ваши изменения сохраняются.",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m38,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Список прокси пуст"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "В выбранных прокси обнаружены ошибки",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Фильтр узлов"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "В текущей группе прокси обнаружены ошибки",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Группа прокси пуста",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Название группы прокси уже используется",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Название группы прокси не может быть пустым",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS-сервер для прокси",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов прокси-узлов",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "В выбранных провайдерах прокси обнаружены ошибки",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Список провайдеров прокси пуст",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Провайдеры прокси не могут быть пустыми",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Тип прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage(
      "Истинно чёрный режим",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код, чтобы получить профиль",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Быстрое заполнение"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радуга"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Порт Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("Меньше движения"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить декоративные анимации",
    ),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage(
      "Уже включено в настройках системы",
    ),
    "reload": MessageLookupByLibrary.simpleMessage("Перезагрузить"),
    "remaining": MessageLookupByLibrary.simpleMessage("Осталось"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("Осталось"),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённо"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование в WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Убрать"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Продлить подписку",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("Недавние запросы"),
    "reset": MessageLookupByLibrary.simpleMessage("Сбросить"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На странице есть изменения. Сбросить их?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите сбросить настройки?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Внешние ресурсы и их состояние",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Учитывать правила"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-соединения следуют правилам; требуется настроить proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Перезапустить ядро?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Ошибка восстановления",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные из файла",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные из WebDAV",
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
      "Данные восстановлены",
    ),
    "resume": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage(
      "Автор и сопровождающий",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage(
      "Адреса для маршрутизации",
    ),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить адреса, маршрутизируемые через туннель",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Режим маршрутизации"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Обходить частные адреса",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage(
      "Использовать конфигурацию",
    ),
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
      "Сопоставить по маске; поддерживаются только * и ?",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить суффикс домена",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить метку DSCP (только для входящего UDP через tproxy)",
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
      "Сопоставить имя пользователя для входящих подключений; несколько имён разделяйте через /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ASN IP-адреса",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов; IP-CIDR6 — просто другое название",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон суффиксов IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить все запросы; условия не нужны",
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
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по полному пути процесса",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению пути процесса",
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
      "Переход к подправилу; не ошибитесь со скобками",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить идентификатор пользователя Linux",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Правило пусто"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Название правила"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Набор правил"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "rules": MessageLookupByLibrary.simpleMessage("Правила"),
    "rulesCount": m39,
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "schedule": MessageLookupByLibrary.simpleMessage("По расписанию"),
    "scheduleDesc": m40,
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Режим скрипта: переопределяет конфигурацию внешними скриптами-расширениями",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Прокрутить к выбранному",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m41,
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "Выбрать MATCH-TARGET",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Выбрать прокси"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Выбрать провайдеров прокси",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Выберите набор правил",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Выберите стратегию распределения",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Выберите подправило",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m42,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage(
      "Отправлять HWID",
    ),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Отправлять идентификатор и название устройства, а также версию приложения на сервер провайдера",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Сервис"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage(
      "Подключаться при запуске",
    ),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Туннель поднимается сразу после открытия приложения",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "Отправлять отчёты о сбоях",
    ),
    "setupDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("Почти готово"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "Позже его можно сменить в настройках",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage(
      "Прежде чем начать",
    ),
    "setupNext": MessageLookupByLibrary.simpleMessage("Далее"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage(
      "Уведомления",
    ),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "Показывают состояние подключения, пока приложение работает",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage(
      "Разрешение на VPN",
    ),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "Система спросит при первом подключении",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Задаёт стартовую точку для выбора серверов",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("Не выбирать"),
    "setupRestore": MessageLookupByLibrary.simpleMessage(
      "Восстановить из копии",
    ),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Переносит всё из копии ReClash, FlClashX или FlClash",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "Ссылка от провайдера, QR-код или файл конфигурации",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "Подписка добавлена",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Добавьте подписку",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "Всё настроим за минуту",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLabels": MessageLookupByLibrary.simpleMessage(
      "Подписи в боковой панели",
    ),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Кнопка остановки в уведомлении",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать кнопку остановки в постоянном уведомлении. Отключите, если из-за неё система всегда разворачивает уведомление.",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Показать пароль"),
    "shrink": MessageLookupByLibrary.simpleMessage("Компактный"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Запуск в фоне"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться без открытия окна",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "smartPause": MessageLookupByLibrary.simpleMessage("Умная пауза"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Закрывать соединения",
    ),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически ставит VPN на паузу в доверенных сетях",
    ),
    "smartRouting": MessageLookupByLibrary.simpleMessage("Умная маршрутизация"),
    "smartRoutingAliveCount": m43,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "Все серверы",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Вернуть автовыбор",
    ),
    "smartRoutingBandLabel": m44,
    "smartRoutingBands": m45,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Поведение"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Нет в текущем списке серверов",
    ),
    "smartRoutingBlockCooling": m46,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Не прошёл проверки в этой сети",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "Местный сервер, в этой сети под запретом",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage(
      "Без поддержки UDP",
    ),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "Через эту сеть пока ничего не ходит",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage(
      "Пробойный узел",
    ),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "Бережём для ограниченных сетей — не тратим в открытых",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "Названия пробойных серверов",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "Фрагменты названий, по которым сервер считается запасным для ограниченных сетей",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage("Канарейки"),
    "smartRoutingCanariesAnswered": m47,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "Местные канарейки",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Напрямую, чтобы отличить белый список от полного отсутствия связи",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "Зарубежные канарейки",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "IP:порт напрямую, чтобы отличить открытую сеть от шатдауна",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage(
      "Местная",
    ),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage(
      "Зарубежная",
    ),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage(
      "Страны с цензурой",
    ),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер из такой страны считается местным, поэтому его берегут до шатдауна",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage(
      "Выбранный сервер",
    ),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "Сервер ещё не выбран",
    ),
    "smartRoutingCoolFor": m48,
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage(
      "Проверить все серверы",
    ),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "Не считается с лимитом проб, поэтому трафика уходит больше",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "Проверяем все серверы…",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("Тормозит"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически подбирает рабочий сервер для каждой сети — приложение можно не открывать",
    ),
    "smartRoutingDetection": MessageLookupByLibrary.simpleMessage(
      "Определение сети",
    ),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage(
      "Домашние узлы при блокировке интернета",
    ),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Запасной вариант для сетей с белым списком, чтобы местные сервисы продолжали работать",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "Местные сервисы идут напрямую",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "Местные сервисы идут через выбранный сервер",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage(
      "Время удержания",
    ),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "Сколько держать рабочий сервер, прежде чем победит более быстрый",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока ничего не измерено",
    ),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage(
      "Ключ сетевой памяти",
    ),
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "Ни один местный адрес не ответил",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "Местный адрес ответил",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "Ни один зарубежный адрес не ответил",
    ),
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "Шлюз ответил подделанным сертификатом",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "Зарубежный адрес прошёл проверку сертификата",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "Подтверждён недавней проверкой",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "Подтверждён вашим же трафиком",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage(
      "Ни разу не подтверждался",
    ),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "Система обнаружила страницу входа",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "Подтверждался давно",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "Система сообщает, что интернета нет",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "Система подтвердила доступ в интернет",
    ),
    "smartRoutingFails": m49,
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage(
      "Нет связи",
    ),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "Не отвечает ничего — ни местное, ни зарубежное",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage(
      "Полностью открытая",
    ),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Между вами и открытым интернетом ничего не блокируется",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage(
      "Нужен вход в сеть",
    ),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "Сеть требует авторизации, прежде чем пропустит трафик",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage(
      "Ограниченная",
    ),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "Отвечают только местные сервисы, зарубежные — нет",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "Ещё измеряется",
    ),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "Пока слишком мало ответов, чтобы судить",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage(
      "отсеяны",
    ),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage(
      "не проверены",
    ),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("годны"),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage(
      "Последние переключения",
    ),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Переключений ещё не было",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage(
      "из проверки задержки",
    ),
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация выбирает сервер, который работает в текущей сети, и сама переключается при её смене. Начните с регионального пресета, затем настройте стратегию, проверки и маркеры ниже.",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("оставлен"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage(
      "Полоса задержки",
    ),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage(
      "Доказательства",
    ),
    "smartRoutingKeyHistory": MessageLookupByLibrary.simpleMessage(
      "История в этой сети",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "Пригодность для сети",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("Вердикт"),
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "Учитывать ручной выбор",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "Держать выбранный вами сервер, пока он работает",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "Держится, пока работает",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "Допустимые статусы",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "Через запятую, например 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "Укажите коды HTTP через запятую",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage(
      "Проверки сервисов",
    ),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage(
      "Местные проверки",
    ),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Для местных серверов во время шатдауна",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage(
      "Проверок нет",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "Проверки открытого интернета",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер считается проверенным, только если вернул один из этих статусов",
    ),
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage(
      "Лимитная сеть",
    ),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("Сеть"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "В этой сети сервер ещё не менялся",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("нет ответа"),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "Нет доступных серверов",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage(
      "Проверка серверов",
    ),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("Без UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m50,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage("Обычный"),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "Включите умную маршрутизацию — она будет подбирать серверы за вас",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация включена",
    ),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage(
      "Обзор маршрутизации",
    ),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Требуется вход в Wi-Fi",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("Пресет"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("Китай"),
    "smartRoutingPresetEdited": m51,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Отключено"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Россия"),
    "smartRoutingProbeBudget": m52,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Пробы"),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage(
      "Порядок сравнения",
    ),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage(
      "Порядок выбора",
    ),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "Полосы задержки не настраиваются: иначе миллисекунды могли бы перевесить работоспособность сервера",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "Первый выбор в этой сети",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "Прежний сервер перестал пропускать трафик",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "Перед переключением ждём время удержания",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "Работает, ничего лучше не нашлось",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "Прежний сервер перестал отвечать",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "Этот на целую полосу быстрее",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "Вы выбрали его вручную",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "Проверяем кандидата перед переключением",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "Ни один сервер не прошёл проверки",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "Выбранный вами сервер снова работает",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Ни один сервер недоступен, остаёмся на текущем",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "Сеть изменилась",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "У этого подтверждён выход в открытый интернет",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage(
      "Проверить сейчас",
    ),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("Регион"),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "Требовать поддержку UDP",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Отсеивать серверы, через которые не пойдут звонки и игры",
    ),
    "smartRoutingResetSection": MessageLookupByLibrary.simpleMessage(
      "Сбросить настройки",
    ),
    "smartRoutingResetSectionDesc": MessageLookupByLibrary.simpleMessage(
      "Вернуть настройки региона и не выключать маршрутизацию",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "Ограниченная сеть · домашние сервисы напрямую",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "Сервер не отвечает, ищем замену",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "Доступна только в режиме «Правила»",
    ),
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Подбор сервера…",
    ),
    "smartRoutingSeconds": m53,
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage(
      "Серверы",
    ),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "Предыдущие переключения",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("Решение"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("Серверы"),
    "smartRoutingServersCount": m54,
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Решил, кого пропускать",
    ),
    "smartRoutingStepAdmitBody": m55,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage(
      "Остановился на этом",
    ),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage(
      "Определил сеть",
    ),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage(
      "Выстроил оставшихся по порядку",
    ),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "Сначала вердикт, потом пригодность для сети, доказательства и полоса задержки, история — в самом конце",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage(
      "Сбалансированная",
    ),
    "smartRoutingStrategyDesc": MessageLookupByLibrary.simpleMessage(
      "Как движок балансирует задержку и стабильность",
    ),
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "Минимальная задержка",
    ),
    "smartRoutingSwitchLine": m56,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("сменён"),
    "smartRoutingSwitchedAgo": m57,
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage(
      "Технические подробности",
    ),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage(
      "не проверялся",
    ),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "На крайний случай",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "Выходит в открытый интернет",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage(
      "Непригоден",
    ),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage(
      "Пригоден",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage(
      "Серверов за проверку",
    ),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "Сколько серверов измеряет одна фоновая проверка",
    ),
    "smartRoutingWaveNodes": m58,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Проверка связи",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Почему"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Порт SOCKS"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("Исходный код"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP источника"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Статистика скорости",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения не может быть пустой",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартный режим: переопределяет базовую конфигурацию и позволяет добавлять правила",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Старт"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Если отключить, используется системный DNS",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Подправило пусто"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Подправило не может быть пустым",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("Подписка"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("Авто"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("Свой"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "Приложение запросит подписку в формате этого клиента",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage(
      "Формат подписки",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionDomainMoved": m59,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Подписка истекла",
    ),
    "subscriptionExpiresInDays": m60,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Подписка истекает сегодня",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("О подписке"),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "Подписка не сообщает ни лимит трафика, ни срок действия",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Напоминания о подписке",
    ),
    "subscriptionProviderInterval": m61,
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "Ни один узел подписки не дозванивается — попробуйте другой формат клиента",
    ),
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("Обновлено"),
    "support": MessageLookupByLibrary.simpleMessage("Поддержка"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemColor": MessageLookupByLibrary.simpleMessage("Системный цвет"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "Брать акцентный цвет из системы (Material You)",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить системный прокси",
    ),
    "systemSeed": MessageLookupByLibrary.simpleMessage("Цвет ОС"),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только в мобильном интерфейсе",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы разрешить",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("Параллельный TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешает параллельные TCP-соединения",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал тестирования",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Тестовый URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Тестировать при использовании",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Тёмный режим и настройка цветов",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "tight": MessageLookupByLibrary.simpleMessage("Плотный"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "timeout": MessageLookupByLibrary.simpleMessage("Тайм-аут"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "tk": MessageLookupByLibrary.simpleMessage("Туркменский"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("Переключить подписи"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Докупить трафик"),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Всего"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт TProxy"),
    "trafficFreeOfTotal": m62,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Доверенные сети"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "В этих сетях VPN ставится на паузу",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Текущая сеть доверенная — VPN на паузе",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Доступно только с правами администратора",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Отключить"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Единая задержка"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Убирает лишние задержки, например рукопожатие",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Восстановить окно"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без названия"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Открепить окно"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить обновление",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Загруженный файл повреждён",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Отдача"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Получить профиль по URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL-схема"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Добавить подписку"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "URL подписки, добавляется после подтверждения",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Свернуть в трей или выйти, если так настроено",
    ),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage(
      "Команды автоматизации",
    ),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Для таскеров, скриптов, ярлыков и автоматизации",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Подключить"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Запустить туннель и подключиться",
    ),
    "urlSchemeDesc": MessageLookupByLibrary.simpleMessage(
      "Deep links, которые ReClash регистрирует и открывает",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Отключить"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Остановить туннель",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("Импорт конфига"),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Конфиг в base64, импортируется как профиль",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "Некорректный base64 в данных импорта",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Установить профиль",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Совместимая ссылка, которую уже используют кнопки Clash и FlClash",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Открыть"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Вывести окно на передний план",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Подключить, если остановлено; отключить, если работает",
    ),
    "urlTip": m63,
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системный hosts",
    ),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Использовано"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "uz": MessageLookupByLibrary.simpleMessage("Узбекский"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркая"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено изменение настроек VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически направляет весь системный трафик через VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Изменения вступят в силу после перезапуска VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройки WebDAV",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Веб-панель"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "zashboard — его отдаёт само ядро",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "zashboard загрузится при первом открытии",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Открыть панель"),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер включён, пока панель открыта",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "Ядро пока не отдаёт панель",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "yearsAgo": m64,
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
  };
}
