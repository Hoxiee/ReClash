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

  static String m0(value) => "Выключено (рекомендуется ${value})";

  static String m1(time) => "Обход DPI активен ${time}";

  static String m2(time) => "Подключено ${time}";

  static String m3(code) =>
      "Windows отказалась запускать ReClashCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите ReClash в этой политике или отключите её и повторите попытку.";

  static String m4(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, выбор профиля ${name} сброшен, а автоматическая настройка пропущена. Вы можете снова выбрать его в любой момент.";

  static String m5(url) => "Создать профиль по ссылке ${url}?";

  static String m6(date, days) => "С ${date} · ${days} суток покрытия";

  static String m7(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m8(count) =>
      "${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дней')}";

  static String m9(label) => "Удалить выбранные элементы (${label})?";

  static String m10(label) => "Удалить «${label}»?";

  static String m11(token) => "${token} задаётся приложением и будет отброшен";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'нет аргументов', one: '1 аргумент', few: '${count} аргумента', other: '${count} аргументов')}";

  static String m13(token) => "${token} требует значение";

  static String m14(token) => "${token} — не опция";

  static String m15(token) => "Неизвестная опция ${token}";

  static String m16(count) => "Категорий через движок ByeDPI: ${count}";

  static String m17(passed, total) => "Результат ступени: ${passed}/${total}";

  static String m18(presets, groups, domains) =>
      "${presets} пресетов · ${groups} групп · ${domains} хостов";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 домен', few: '${count} домена', other: '${count} доменов')}";

  static String m20(count) => "Готово: протестировано ${count} стратегий";

  static String m21(count) =>
      "Прогоняет все известные стратегии по ${count} хостам через движок; текущая стратегия возвращается по окончании";

  static String m22(index, total) => "Тестируется ${index} из ${total}";

  static String m23(passed, total) => "Отвечают ${passed} из ${total} хостов";

  static String m24(label) => "Сведения: ${label}";

  static String m25(days) => "${days} суток";

  static String m26(name) => "«${name}» установлена";

  static String m27(count) =>
      "При нагрузке потеряно событий: ${count}. Достоверность диагноза не повышалась.";

  static String m28(completed, total) =>
      "Проверка соединения: ${completed}/${total}";

  static String m29(layer) => "Проблема соединения: ${layer}";

  static String m30(completed, total) => "Шаг ${completed} из ${total}";

  static String m31(label) => "Поле «${label}» не может быть пустым";

  static String m32(count) =>
      "${Intl.plural(count, one: '${count} запись', few: '${count} записи', many: '${count} записей', other: '${count} записи')}";

  static String m33(label) => "«${label}» уже существует";

  static String m34(action) =>
      "Разрешить внешней ссылке выполнить действие «${action}»?";

  static String m35(date) => "Найдено ${date}";

  static String m36(found, total) => "Открыто ${found} из ${total}";

  static String m37(count) => "Ещё ${count} не найдены";

  static String m38(days) => "До следующей насечки — ${days} суток";

  static String m39(name) => "${name}: уже последняя версия";

  static String m40(name) => "${name}: обновлено";

  static String m41(time) => "${time} назад";

  static String m42(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m43(count) =>
      "${Intl.plural(count, one: '${count} час', few: '${count} часа', many: '${count} часов', other: '${count} часа')}";

  static String m44(target) => "${target} — недопустимая политика";

  static String m45(proxyName) => "${proxyName} — недопустимый прокси";

  static String m46(providerName) =>
      "${providerName} — недопустимый провайдер прокси";

  static String m47(subRule) => "${subRule} — недопустимый SUB_RULE";

  static String m48(address) => "Или откройте ${address} в браузере телефона";

  static String m49(appName) =>
      "1. Откройте Системные настройки → Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nКогда закончите, вернитесь в приложение и продолжите.";

  static String m50(label, max) => "«${label}» — не более ${max} символов";

  static String m51(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m52(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m53(label) => "${label}: пока ничего нет";

  static String m54(label) => "Значение «${label}» должно быть числом";

  static String m55(settings) =>
      "Подписка запрашивает следующие общие настройки приложения:\n${settings}";

  static String m56(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m57(count) =>
      "Профиль импортирован; пропущено неподдерживаемых узлов: ${count}";

  static String m58(format, client, nodes, groups) =>
      "Импортировано: ${format} · ${client} · узлов: ${nodes} · групп: ${groups}";

  static String m59(days) => "Не использовался ${days} дн.";

  static String m60(months) => "Не использовался ${months} мес.";

  static String m61(count) => "${count} прокси";

  static String m62(count) => "Профили: ${count}";

  static String m63(count) => "Группы прокси: ${count}";

  static String m64(count) => "Правила: ${count}";

  static String m65(count) => "Сценарии: ${count}";

  static String m66(count) =>
      "${Intl.plural(count, one: '${count} правило', few: '${count} правила', many: '${count} правил', other: '${count} правила')}";

  static String m67(darkAt, lightAt) => "Тёмная с ${darkAt} до ${lightAt}";

  static String m68(count) =>
      "${Intl.plural(count, one: '${count} секунда', few: '${count} секунды', many: '${count} секунд', other: '${count} секунды')}";

  static String m69(count) => "Выбрано: ${count}";

  static String m70(count) =>
      "${Intl.plural(count, one: 'Готов 1 профиль', few: 'Готово ${count} профиля', many: 'Готово ${count} профилей', other: 'Готово ${count} профиля')}";

  static String m71(step, count) => "Шаг ${step} из ${count}";

  static String m72(name) => "Профиль: ${name}";

  static String m73(value) => "Умная маршрутизация: ${value}";

  static String m74(alive, total) =>
      "Сейчас доступны ${alive} из ${total} серверов";

  static String m75(percent, duration) => "${percent}% за ${duration}";

  static String m76(band) => "полоса ${band}";

  static String m77(bands) => "Полосы: ${bands}";

  static String m78(count) => "Остывает после ${count} отказов";

  static String m79(answered, total) => "ответили ${answered} из ${total}";

  static String m80(seconds) => "осталось ${seconds} сек";

  static String m81(count) => "${count} отказов подряд";

  static String m82(step) => "Проиграл на строке: ${step}";

  static String m83(duration) => "Измерено за ${duration}";

  static String m84(ms) => "${ms} мс";

  static String m85(minutes) => "${minutes} мин";

  static String m86(measured, total) => "измерено ${measured} из ${total}";

  static String m87(preset) => "${preset} · изменён";

  static String m88(left, cap) =>
      "Осталось проб в этом часе: ${left} из ${cap}";

  static String m89(value, against) => "${value} против ${against}";

  static String m90(seconds) => "${seconds} с";

  static String m91(eligible, total) => "${eligible} из ${total} пригодны";

  static String m92(count) => "Признаков специальных серверов: ${count}";

  static String m93(provider) => "Провайдер: ${provider}";

  static String m94(count) => "Признаков от провайдера: ${count}";

  static String m95(eligible, total) =>
      "Готовы ${eligible} из ${total} серверов";

  static String m96(label) =>
      "Поле «${label}» должно занимать не больше 64 байт UTF-8";

  static String m97(node) => "Через ${node}";

  static String m98(eligible, total, blocked) =>
      "прошли ${eligible} из ${total}, отсеяно ${blocked}";

  static String m99(strategy) => "${strategy} · изменено";

  static String m100(from, to) => "${from} → ${to}";

  static String m101(time) => "Смена сервера ${time} назад";

  static String m102(count) => "${count} серверов";

  static String m103(step) => "Стоит выше на строке: ${step}";

  static String m104(host) => "Провайдер переехал на ${host}";

  static String m105(count) =>
      "${Intl.plural(count, one: 'Подписка истекает через ${count} день', few: 'Подписка истекает через ${count} дня', many: 'Подписка истекает через ${count} дней', other: 'Подписка истекает через ${count} дней')}";

  static String m106(value) => "Провайдер предлагает ${value}";

  static String m107(total) => "свободно из ${total}";

  static String m108(label) => "Значение «${label}» должно быть URL";

  static String m109(count) =>
      "Можно хранить до ${count} фонов. Удалите один, чтобы добавить новый.";

  static String m110(count) =>
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
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "В обход VPN",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "Через VPN",
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
    "animations": MessageLookupByLibrary.simpleMessage("Анимации"),
    "announce": MessageLookupByLibrary.simpleMessage("Анонсы"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Чертёж"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Лаунчер перерисует иконку через несколько секунд. На некоторых лаунчерах закреплённый ярлык может пропасть.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Контур"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Эхо"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Тушь"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("Установить"),
    "appIconPreview": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр иконки",
    ),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Осколки"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Солнце"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Искра"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Слои"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Топография"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("След"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Бархат"),
    "appRegion": MessageLookupByLibrary.simpleMessage("Регион приложения"),
    "appRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Выберите регион сети. При выборе России включается HWID — его можно выключить ниже. Умная маршрутизация включается отдельно.",
    ),
    "appRegionOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "appearance": MessageLookupByLibrary.simpleMessage("Оформление"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Фон"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Тема, цвета, иконки и вид панели",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("Иконка"),
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
    "autoUpdateOffSuggested": m0,
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
    "byedpiActive": MessageLookupByLibrary.simpleMessage("Обход DPI активен"),
    "byedpiActiveFor": m1,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage(
      "Проверка DPI-движка",
    ),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage(
      "DPI-движок требует внимания",
    ),
    "byedpiOff": MessageLookupByLibrary.simpleMessage("Обход DPI выключен"),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage(
      "Обход DPI приостановлен",
    ),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage(
      "Перезапуск DPI-движка",
    ),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage("Запуск обхода DPI"),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы возобновить обход DPI",
    ),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы запустить локальный движок обхода",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключённые домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только при включённом системном прокси",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить его?",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Доступ к камере выключен. Включите его в настройках, чтобы отсканировать QR-код.",
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
    "connectedFor": m2,
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Доктор соединения",
    ),
    "connectionProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "connectionType": MessageLookupByLibrary.simpleMessage("Подключение"),
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
    "coreBlockedByPolicyTip": m3,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control в Windows заблокировал неподписанный ReClashCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите ReClash. Повторно включить Smart App Control без переустановки Windows нельзя.",
    ),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Работает"),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Запускается…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Остановлено"),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Обнаружен сбой"),
    "crashDetectedTip": m4,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Аналитика сбоев"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "Если включить, логи сбоев без конфиденциальных данных будут отправляться автоматически",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Создать профиль"),
    "createProfileFromUrlTip": m5,
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
    "crownHistory": m6,
    "custom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "darkAt": MessageLookupByLibrary.simpleMessage("Тёмная в"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "Используйте режим «Только ByeDPI» для обхода DPI без профиля VPN.",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage(
      "Нет VPN-провайдера?",
    ),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Профили сохранены, но ни один не выбран. Выберите профиль, чтобы стали доступны элементы управления VPN.",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Выберите профиль VPN",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль VPN от провайдера, которому доверяете. До этого VPN останется выключен.",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Настройте подключение",
    ),
    "dashboardProviderDetails": MessageLookupByLibrary.simpleMessage(
      "Подробнее",
    ),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage(
      "Выбрать профиль",
    ),
    "dashboardShowConnection": MessageLookupByLibrary.simpleMessage(
      "Вернуться к подключению",
    ),
    "dashboardShowProvider": MessageLookupByLibrary.simpleMessage(
      "Показать сведения о подписке",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Вид панели"),
    "dashboardSubscriptionAttention": MessageLookupByLibrary.simpleMessage(
      "Требует внимания",
    ),
    "dashboardSubscriptionCurrent": MessageLookupByLibrary.simpleMessage(
      "Подписка активна",
    ),
    "dashboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Подписка истекла",
    ),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage(
      "Включить ByeDPI",
    ),
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
    "daysAgo": m7,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("дня"),
    "daysLeft": m8,
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
    "deleteMultipTip": m9,
    "deleteTip": m10,
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
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage(
      "Активная стратегия",
    ),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Аргументы движка"),
    "desyncArgsAppOwnedFlag": m11,
    "desyncArgsCount": m12,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m13,
    "desyncArgsPositional": m14,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "Не закрыта кавычка",
    ),
    "desyncArgsUnknownFlag": m15,
    "desyncCache": MessageLookupByLibrary.simpleMessage("Кэш стратегий"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Подобранные стратегии хранятся по сетям",
    ),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage(
      "Кеш стратегий выключен",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("Срок хранения"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage(
      "Лестница по умолчанию",
    ),
    "desyncDesc": MessageLookupByLibrary.simpleMessage(
      "Стратегии десинхронизации ByeDPI",
    ),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("Движок"),
    "desyncEngineSummary": m16,
    "desyncFeatureEnable": MessageLookupByLibrary.simpleMessage(
      "Включить ByeDPI",
    ),
    "desyncFeatureEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Включает движок обхода DPI и его режим на дашборде. Пока выключено, ByeDPI нигде не показывается.",
    ),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("Переводить на TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Блокирует QUIC для категорий выше; десинк не работает с UDP",
    ),
    "desyncLadderResult": m17,
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage(
      "Режим подключения",
    ),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("Маршрутизация"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Весь трафик вне выбранных категорий GEOSITE идёт напрямую",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "Состав категорий берётся из встроенной базы GEOSITE; списки тестовых доменов существуют отдельно",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "Категории обхода не выбраны",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "Сейчас ни один сервис не направляется через ByeDPI",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage(
      "Действующие правила",
    ),
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
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("Батарея тестов"),
    "desyncTestBatterySummary": m18,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage(
      "Домены для теста",
    ),
    "desyncTestDomainsCount": m19,
    "desyncTestDone": m20,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "Движок упал на этой стратегии",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "Движок не запущен — сначала подключитесь с включённым обходом DPI",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Хосты, не прошедшие стратегию",
    ),
    "desyncTestHint": m21,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Выберите хотя бы один список доменов ниже",
    ),
    "desyncTestProgress": m22,
    "desyncTestScore": m23,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("Тест стратегий"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("Старт"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage(
      "Прогнать все пресеты",
    ),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 часов"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 часов"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 час"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 дней"),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Использует сторонний API; результат ориентировочный",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("Определяем IP…"),
    "developerAllRewards": MessageLookupByLibrary.simpleMessage(
      "Показать все награды",
    ),
    "developerFindingEvents": MessageLookupByLibrary.simpleMessage(
      "Повторить находку",
    ),
    "developerFindingQueued": MessageLookupByLibrary.simpleMessage(
      "В очереди до открытия дашборда с исправным соединением. Находку можно повторить.",
    ),
    "developerFindings": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр находок",
    ),
    "developerFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "Только временный предпросмотр: счётчики, полученные находки и сетевые настройки не меняются. Сброс или выключение режима разработчика убирает предпросмотр. Эффекты ждут видимого дашборда с исправным соединением и учитывают настройки оформления. Выбор иконки или темы в оформлении по-прежнему сохраняется.",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "developerPatina": MessageLookupByLibrary.simpleMessage("Патина профилей"),
    "developerPatinaApply": MessageLookupByLibrary.simpleMessage(
      "Применить ко всему списку",
    ),
    "developerPatinaApplyDesc": MessageLookupByLibrary.simpleMessage(
      "Состарить все профили до этого возраста. Выключено — каждый остаётся на своей реальной дате последнего использования.",
    ),
    "developerPatinaDays": m25,
    "developerPatinaLab": MessageLookupByLibrary.simpleMessage(
      "Лаборатория патины",
    ),
    "developerPatinaSample": MessageLookupByLibrary.simpleMessage(
      "Заброшенная подписка",
    ),
    "developerPreviewAutomatic": MessageLookupByLibrary.simpleMessage(
      "Автоматически",
    ),
    "developerPreviewReset": MessageLookupByLibrary.simpleMessage(
      "Сбросить предпросмотр",
    ),
    "developerSeasonAnniversary": MessageLookupByLibrary.simpleMessage(
      "Годовщина первого запуска",
    ),
    "developerSeasonBirthday": MessageLookupByLibrary.simpleMessage(
      "День рождения ReClash",
    ),
    "developerSeasonDrift": MessageLookupByLibrary.simpleMessage(
      "Сезонный оттенок",
    ),
    "developerSeasonNewYear": MessageLookupByLibrary.simpleMessage("Новый год"),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "Виджеты провайдера, выбор сервера и вид прокси",
    ),
    "developerSubscriptionEmberDesc": MessageLookupByLibrary.simpleMessage(
      "Всё сразу: квота, виджеты, тема и локальный фон",
    ),
    "developerSubscriptionInstalled": m26,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "Квота, срок действия, объявления, смена домена и предложения",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "Цвета бренда, свой Hero Ring и локальный логотип",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Тестовые подписки",
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
    "discoveredFindings": MessageLookupByLibrary.simpleMessage("Открытое"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("Настройки DNS"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "doctorBrokenDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка нашла место, где соединение перестаёт работать.",
    ),
    "doctorBrokenTitle": MessageLookupByLibrary.simpleMessage(
      "Обнаружена проблема",
    ),
    "doctorByeDpiFailedDesc": MessageLookupByLibrary.simpleMessage(
      "Локальный прокси ByeDPI недоступен, поэтому трафик не может пройти через него.",
    ),
    "doctorByeDpiFailedTitle": MessageLookupByLibrary.simpleMessage(
      "ByeDPI не запустился",
    ),
    "doctorCancelExam": MessageLookupByLibrary.simpleMessage(
      "Отменить проверку",
    ),
    "doctorCancelledDesc": MessageLookupByLibrary.simpleMessage(
      "Диагноз не изменён. Можно запустить новую проверку.",
    ),
    "doctorCancelledTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка отменена",
    ),
    "doctorCaptureActive": MessageLookupByLibrary.simpleMessage("Активна"),
    "doctorCaptureInactive": MessageLookupByLibrary.simpleMessage("Неактивна"),
    "doctorCaptureNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Не применяется",
    ),
    "doctorConfidence": MessageLookupByLibrary.simpleMessage("Достоверность"),
    "doctorConfidenceConfirmed": MessageLookupByLibrary.simpleMessage(
      "Подтверждено",
    ),
    "doctorConfidenceInsufficient": MessageLookupByLibrary.simpleMessage(
      "Недостаточно данных",
    ),
    "doctorConfidenceProbable": MessageLookupByLibrary.simpleMessage(
      "Вероятно",
    ),
    "doctorDeepExam": MessageLookupByLibrary.simpleMessage("Глубокая проверка"),
    "doctorDegradedDesc": MessageLookupByLibrary.simpleMessage(
      "Доктор обнаружил вероятную проблему в сетевом пути.",
    ),
    "doctorDegradedTitle": MessageLookupByLibrary.simpleMessage(
      "Соединение нестабильно",
    ),
    "doctorDetails": MessageLookupByLibrary.simpleMessage("Диагноз"),
    "doctorDnsFailedDesc": MessageLookupByLibrary.simpleMessage(
      "Приложению не удалось определить адрес проверочного сайта.",
    ),
    "doctorDnsFailedTitle": MessageLookupByLibrary.simpleMessage(
      "DNS не работает",
    ),
    "doctorDnsStaleDesc": MessageLookupByLibrary.simpleMessage(
      "Сохранённый адрес больше не соответствует текущей сети.",
    ),
    "doctorDnsStaleTitle": MessageLookupByLibrary.simpleMessage(
      "Данные DNS устарели",
    ),
    "doctorEndpointReachableDesc": MessageLookupByLibrary.simpleMessage(
      "Core достиг проверочного адреса, но полный защищённый путь не подтверждён.",
    ),
    "doctorEndpointReachableTitle": MessageLookupByLibrary.simpleMessage(
      "Проверочный адрес доступен",
    ),
    "doctorEvidence": MessageLookupByLibrary.simpleMessage("Свидетельства"),
    "doctorEvidenceConsequence": MessageLookupByLibrary.simpleMessage(
      "Следствие более ранней неисправности",
    ),
    "doctorEvidenceDropped": m27,
    "doctorExaminingDesc": MessageLookupByLibrary.simpleMessage(
      "Проверяем каждый участок соединения. Обычно это занимает несколько секунд.",
    ),
    "doctorExaminingTitle": MessageLookupByLibrary.simpleMessage(
      "Проверяем соединение",
    ),
    "doctorExportConfirm": MessageLookupByLibrary.simpleMessage(
      "Отчёт содержит диагностические коды, интервалы времени, сведения о платформе и недавние обезличенные данные. В нём никогда нет адресов, имён хостов, профилей, узлов или приложений. Сохранить его в JSON?",
    ),
    "doctorExportReport": MessageLookupByLibrary.simpleMessage(
      "Экспортировать отчёт",
    ),
    "doctorFlushDns": MessageLookupByLibrary.simpleMessage("Очистить кэш DNS"),
    "doctorFresh": MessageLookupByLibrary.simpleMessage("Актуально"),
    "doctorGenericDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка обнаружила проблему с соединением, но не смогла точнее определить причину.",
    ),
    "doctorHealthyDesc": MessageLookupByLibrary.simpleMessage(
      "Приложение вышло в интернет по ожидаемому пути соединения.",
    ),
    "doctorHealthyEasterEgg": MessageLookupByLibrary.simpleMessage(
      "Пациент подозрительно здоров.",
    ),
    "doctorHealthyTitle": MessageLookupByLibrary.simpleMessage(
      "Соединение исправно",
    ),
    "doctorHeroExamining": m28,
    "doctorHeroIssue": m29,
    "doctorInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка не смогла доказать неисправность без догадок.",
    ),
    "doctorInconclusiveTitle": MessageLookupByLibrary.simpleMessage(
      "Недостаточно данных",
    ),
    "doctorIngressDesc": MessageLookupByLibrary.simpleMessage(
      "Приложение отправило трафик, но он не дошёл до входа VPN или локального прокси.",
    ),
    "doctorIngressTitle": MessageLookupByLibrary.simpleMessage(
      "Трафик не попал в туннель",
    ),
    "doctorIpUnavailable": MessageLookupByLibrary.simpleMessage(
      "Публичный IP не измерен",
    ),
    "doctorLayer": MessageLookupByLibrary.simpleMessage("Причинный слой"),
    "doctorLayerCapture": MessageLookupByLibrary.simpleMessage("Перехват"),
    "doctorLayerDial": MessageLookupByLibrary.simpleMessage(
      "Установка соединения",
    ),
    "doctorLayerDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "doctorLayerIngress": MessageLookupByLibrary.simpleMessage("Вход VPN"),
    "doctorLayerMarker": MessageLookupByLibrary.simpleMessage(
      "Ответ приложения",
    ),
    "doctorLayerRoute": MessageLookupByLibrary.simpleMessage("Маршрутизация"),
    "doctorLayerTransport": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "doctorLimitations": MessageLookupByLibrary.simpleMessage(
      "Как это понимать",
    ),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("Глубокая"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("Стандартная"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage(
      "Полезных данных пока нет",
    ),
    "doctorNoIncidents": MessageLookupByLibrary.simpleMessage(
      "Завершённых проверок пока нет",
    ),
    "doctorNoNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Устройство не подключено к Wi-Fi или мобильной сети.",
    ),
    "doctorNoNetworkTitle": MessageLookupByLibrary.simpleMessage(
      "Нет подключения к интернету",
    ),
    "doctorNoNodeDesc": MessageLookupByLibrary.simpleMessage(
      "Нет активного прокси-сервера для этого соединения.",
    ),
    "doctorNoNodeTitle": MessageLookupByLibrary.simpleMessage(
      "Прокси-сервер не выбран",
    ),
    "doctorNodeDownDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранный прокси-сервер не принял соединение или не ответил.",
    ),
    "doctorNodeDownTitle": MessageLookupByLibrary.simpleMessage(
      "Прокси-сервер недоступен",
    ),
    "doctorNodeRefusedDesc": MessageLookupByLibrary.simpleMessage(
      "Прокси подключился, но проверочный сайт не вернул ожидаемый ответ.",
    ),
    "doctorNodeRefusedTitle": MessageLookupByLibrary.simpleMessage(
      "Проверочный сайт отклонил запрос",
    ),
    "doctorObservingDesc": MessageLookupByLibrary.simpleMessage(
      "Запустите проверку сейчас или откройте нужное приложение, чтобы собрать данные из реального трафика.",
    ),
    "doctorObservingTitle": MessageLookupByLibrary.simpleMessage(
      "Наблюдение за трафиком",
    ),
    "doctorOutcomeDropped": MessageLookupByLibrary.simpleMessage("Потеряно"),
    "doctorOutcomeFailed": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "doctorOutcomeNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Неприменимо",
    ),
    "doctorOutcomeSeen": MessageLookupByLibrary.simpleMessage("Наблюдалось"),
    "doctorOutcomeSucceeded": MessageLookupByLibrary.simpleMessage("Успешно"),
    "doctorPassiveHint": MessageLookupByLibrary.simpleMessage(
      "При открытии этого экрана выполняется одна проверка. В остальное время Доктор только наблюдает за реальным трафиком и не создаёт дополнительной сетевой активности.",
    ),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("Приложение"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("Проверяется"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage(
      "Не проверялось после ранней ошибки",
    ),
    "doctorPathFailed": MessageLookupByLibrary.simpleMessage("Проблема здесь"),
    "doctorPathIngress": MessageLookupByLibrary.simpleMessage(
      "VPN / локальный вход",
    ),
    "doctorPathIngressByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "doctorPathIngressDirect": MessageLookupByLibrary.simpleMessage("Напрямую"),
    "doctorPathIngressLocalProxy": MessageLookupByLibrary.simpleMessage(
      "Локальный прокси",
    ),
    "doctorPathIngressTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "doctorPathIngressVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "doctorPathInternet": MessageLookupByLibrary.simpleMessage(
      "Прокси / Интернет",
    ),
    "doctorPathNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Не требуется",
    ),
    "doctorPathPassed": MessageLookupByLibrary.simpleMessage("Работает"),
    "doctorPathResponse": MessageLookupByLibrary.simpleMessage("Ответ"),
    "doctorPathRoute": MessageLookupByLibrary.simpleMessage("DNS / маршрут"),
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("Путь подключения"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("Не проверено"),
    "doctorPortalDesc": MessageLookupByLibrary.simpleMessage(
      "Сеть не выпускает в интернет, пока вы не пройдёте авторизацию.",
    ),
    "doctorPortalTitle": MessageLookupByLibrary.simpleMessage(
      "Нужно войти в сеть Wi-Fi",
    ),
    "doctorProgress": m30,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("Защита"),
    "doctorRecentChecks": MessageLookupByLibrary.simpleMessage(
      "Недавние проверки",
    ),
    "doctorRefresh": MessageLookupByLibrary.simpleMessage("Обновить диагноз"),
    "doctorRemedyOpenDns": MessageLookupByLibrary.simpleMessage(
      "Настройки DNS",
    ),
    "doctorRemedyStartVpn": MessageLookupByLibrary.simpleMessage(
      "Запустить VPN",
    ),
    "doctorRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Текущий профиль не смог выбрать рабочий маршрут для этого соединения.",
    ),
    "doctorRouteTitle": MessageLookupByLibrary.simpleMessage(
      "Трафик направлен неправильно",
    ),
    "doctorScope": MessageLookupByLibrary.simpleMessage("Область данных"),
    "doctorScopeApp": MessageLookupByLibrary.simpleMessage("Это приложение"),
    "doctorScopeInbound": MessageLookupByLibrary.simpleMessage(
      "Локальный вход",
    ),
    "doctorSlowDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка не завершилась за отведённое время.",
    ),
    "doctorSlowTitle": MessageLookupByLibrary.simpleMessage(
      "Соединение слишком медленное",
    ),
    "doctorStale": MessageLookupByLibrary.simpleMessage("Устарело"),
    "doctorStaleHint": MessageLookupByLibrary.simpleMessage(
      "Среда могла измениться. Обновите диагноз или запустите новую проверку перед действием.",
    ),
    "doctorStaleTitle": MessageLookupByLibrary.simpleMessage(
      "Результат устарел",
    ),
    "doctorStandardExam": MessageLookupByLibrary.simpleMessage(
      "Запустить проверку",
    ),
    "doctorStepChangeDns": MessageLookupByLibrary.simpleMessage(
      "Попробуйте другой DNS-сервер в настройках профиля.",
    ),
    "doctorStepCheckRules": MessageLookupByLibrary.simpleMessage(
      "Проверьте правила профиля и режим маршрутизации.",
    ),
    "doctorStepCheckWifi": MessageLookupByLibrary.simpleMessage(
      "Подключитесь к Wi-Fi или мобильной сети, затем проверьте снова.",
    ),
    "doctorStepDeepCheck": MessageLookupByLibrary.simpleMessage(
      "Запустите глубокую проверку для сравнения путей DNS.",
    ),
    "doctorStepFlushDns": MessageLookupByLibrary.simpleMessage(
      "Очистите кэш DNS и проверьте снова.",
    ),
    "doctorStepPickNode": MessageLookupByLibrary.simpleMessage(
      "Выберите другой прокси-сервер.",
    ),
    "doctorStepRecheckLater": MessageLookupByLibrary.simpleMessage(
      "Проверьте позже или в другой сети.",
    ),
    "doctorStepRestartByeDpi": MessageLookupByLibrary.simpleMessage(
      "Перезапустите ByeDPI в расширенных настройках.",
    ),
    "doctorStepRestartTunnel": MessageLookupByLibrary.simpleMessage(
      "Перезапустите соединение и проверьте снова.",
    ),
    "doctorStepSignInPortal": MessageLookupByLibrary.simpleMessage(
      "Откройте страницу входа в сеть, затем проверьте снова.",
    ),
    "doctorStepStartVpn": MessageLookupByLibrary.simpleMessage(
      "Запустите VPN и проверьте снова.",
    ),
    "doctorStepSwitchNetwork": MessageLookupByLibrary.simpleMessage(
      "Переключитесь на другую сеть или восстановите доступ в интернет.",
    ),
    "doctorStepUpdateSubscription": MessageLookupByLibrary.simpleMessage(
      "Обновите подписку, если другие серверы тоже не работают.",
    ),
    "doctorStepUseAppThenRecheck": MessageLookupByLibrary.simpleMessage(
      "Откройте проблемное приложение, затем вернитесь и проверьте снова.",
    ),
    "doctorStormTitle": MessageLookupByLibrary.simpleMessage(
      "Все этапы соединения недоступны",
    ),
    "doctorStormVerdict": MessageLookupByLibrary.simpleMessage(
      "Проверка не нашла рабочего пути. Отказы следующих этапов могут быть следствием первого.",
    ),
    "doctorSupersededDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка остановлена из-за изменения сети или конфигурации.",
    ),
    "doctorSupersededTitle": MessageLookupByLibrary.simpleMessage(
      "Среда изменилась",
    ),
    "doctorTechnicalDetails": MessageLookupByLibrary.simpleMessage(
      "Технические данные",
    ),
    "doctorUnsupportedDesc": MessageLookupByLibrary.simpleMessage(
      "Эта версия Core не поддерживает диагностику соединения.",
    ),
    "doctorUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "Обновите Core, чтобы использовать диагностику соединения.",
    ),
    "doctorUnsupportedTitle": MessageLookupByLibrary.simpleMessage(
      "Диагностика недоступна",
    ),
    "doctorUnvalidatedDesc": MessageLookupByLibrary.simpleMessage(
      "Устройство подключено к сети, но Android не может выйти через неё в интернет.",
    ),
    "doctorUnvalidatedTitle": MessageLookupByLibrary.simpleMessage(
      "У сети нет доступа в интернет",
    ),
    "doctorVpnInactiveDesc": MessageLookupByLibrary.simpleMessage(
      "Ожидалась защита через VPN, но путь TUN не активен.",
    ),
    "doctorVpnInactiveTitle": MessageLookupByLibrary.simpleMessage(
      "VPN не активен",
    ),
    "doctorWhatToTry": MessageLookupByLibrary.simpleMessage("Что попробовать"),
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
    "emptyTip": m31,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Ввести вручную"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "entriesCount": m32,
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать приложение из недавних задач, когда оно в фоне",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Исключающий фильтр",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Исключаемые типы"),
    "existsTip": m33,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Выйти из полноэкранного режима",
    ),
    "expand": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Ожидаемый статус"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспортировано"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивная"),
    "externalActionConfirmMessage": m34,
    "externalActionConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Подтверждение внешнего действия",
    ),
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
    "filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Поиск процесса"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Может немного снизить производительность",
    ),
    "findingAuscultation": MessageLookupByLibrary.simpleMessage("Аускультация"),
    "findingCrown": MessageLookupByLibrary.simpleMessage("Венец"),
    "findingDiscoveredOn": m35,
    "findingFullLadder": MessageLookupByLibrary.simpleMessage(
      "Полная лестница",
    ),
    "findingMarks": MessageLookupByLibrary.simpleMessage("Марки"),
    "findingMarksDesc": MessageLookupByLibrary.simpleMessage(
      "Открылся лист марок ReClash.",
    ),
    "findingMeridian": MessageLookupByLibrary.simpleMessage("Пять меридианов"),
    "findingOdometer": MessageLookupByLibrary.simpleMessage("Одометр"),
    "findingOscilloscope": MessageLookupByLibrary.simpleMessage("Осциллограф"),
    "findingOscilloscopeDesc": MessageLookupByLibrary.simpleMessage(
      "Кольцо шесть секунд слушало живой трафик.",
    ),
    "findingPi": MessageLookupByLibrary.simpleMessage("Пи"),
    "findingPiDesc": MessageLookupByLibrary.simpleMessage(
      "Сессия прошла отметку 3:14:15 при открытом дашборде.",
    ),
    "findingPorcelain": MessageLookupByLibrary.simpleMessage("Фарфор"),
    "findingSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "Молчаливый автопилот",
    ),
    "findingSingularity": MessageLookupByLibrary.simpleMessage("Сингулярность"),
    "findingSingularityDesc": MessageLookupByLibrary.simpleMessage(
      "Орб держали, пока он не схлопнулся в точку и не вспыхнул заново.",
    ),
    "findingTurn": MessageLookupByLibrary.simpleMessage("Оборот"),
    "findingTurnDesc": MessageLookupByLibrary.simpleMessage(
      "Сессия пережила новогоднюю полночь.",
    ),
    "findingVigil": MessageLookupByLibrary.simpleMessage("Дозор"),
    "findings": MessageLookupByLibrary.simpleMessage("Находки"),
    "findingsCount": m36,
    "findingsDesc": MessageLookupByLibrary.simpleMessage(
      "Тихие детали, найденные во время использования ReClash",
    ),
    "findingsLocked": m37,
    "findingsMoments": MessageLookupByLibrary.simpleMessage("Моменты"),
    "findingsNextMilestone": m38,
    "findingsRelics": MessageLookupByLibrary.simpleMessage("Реликвии"),
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
    "geoSkipped": m39,
    "geoUpdated": m40,
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
    "goroutineInfo": MessageLookupByLibrary.simpleMessage("Горутины"),
    "gratitude": MessageLookupByLibrary.simpleMessage("Благодарности"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash существует благодаря их работе",
    ),
    "happImportAsClient": MessageLookupByLibrary.simpleMessage(
      "Обычный импорт",
    ),
    "happImportAsClientDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash запрашивает подписку от своего имени и определяет формат автоматически.",
    ),
    "happImportAsHapp": MessageLookupByLibrary.simpleMessage(
      "Режим совместимости с Happ",
    ),
    "happImportAsHappDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash представляется приложением Happ и читает его формат. Нужно, если провайдер отдаёт узлы под Happ.",
    ),
    "happImportChoiceTitle": MessageLookupByLibrary.simpleMessage(
      "Импорт подписки",
    ),
    "happImportPrompt": MessageLookupByLibrary.simpleMessage(
      "Ссылка открыта через Happ. Выберите, как запросить подписку.",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Кэшировать изменения?",
    ),
    "helperAgentUnavailable": MessageLookupByLibrary.simpleMessage(
      "Системный агент авторизации недоступен. Запустите агент аутентификации polkit в сеансе рабочего стола и повторите попытку.",
    ),
    "helperAuthorizationContinue": MessageLookupByLibrary.simpleMessage(
      "Продолжить",
    ),
    "helperAuthorizationLater": MessageLookupByLibrary.simpleMessage("Позже"),
    "helperAuthorizationMessage": MessageLookupByLibrary.simpleMessage(
      "Для TUN-режима нужно установить или обновить службу ReClash Helper. Нажмите «Продолжить», чтобы открыть системный запрос авторизации. Вводите пароль только в нём: ReClash не собирает пароли.",
    ),
    "helperAuthorizationTitle": MessageLookupByLibrary.simpleMessage(
      "Разрешить настройку Helper?",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите ReClash.",
    ),
    "helperInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось установить или обновить службу Helper. Проверьте журналы и повторите попытку.",
    ),
    "helperInstallNotReady": MessageLookupByLibrary.simpleMessage(
      "Настройка Helper завершена, но служба не готова к работе. Проверьте журналы и повторите попытку.",
    ),
    "helperPkexecUnavailable": MessageLookupByLibrary.simpleMessage(
      "pkexec недоступен. Установите пакет polkit для вашего дистрибутива и повторите попытку.",
    ),
    "helperSystemdUnavailable": MessageLookupByLibrary.simpleMessage(
      "Для TUN-режима нужен systemd, но в этой системе он недоступен.",
    ),
    "heroBlockedHint": MessageLookupByLibrary.simpleMessage(
      "Другой VPN перехватывает трафик — нажмите, чтобы повторить",
    ),
    "heroBlockedTitle": MessageLookupByLibrary.simpleMessage(
      "Туннель заблокирован",
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
    "heroRoutingAgo": m41,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация отключена",
    ),
    "heroStatusEasterEgg": MessageLookupByLibrary.simpleMessage(
      "Пакеты сегодня особенно послушные.",
    ),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы включить защиту",
    ),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы возобновить защиту",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Скрыть из списка"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Скрыть пароль"),
    "highPriorityAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Автозапуск с высоким приоритетом",
    ),
    "highPriorityAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать задачу планировщика Windows для более раннего запуска",
    ),
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
    "hoursAgo": m42,
    "hoursCount": m43,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("часа"),
    "icon": MessageLookupByLibrary.simpleMessage("Значок"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("История значков"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль значков"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL значка"),
    "identity": MessageLookupByLibrary.simpleMessage("Идентификация"),
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
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
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
    "invalidPolicy": m44,
    "invalidProxy": m45,
    "invalidProxyProvider": m46,
    "invalidSubRule": m47,
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
    "lanProfileImport": MessageLookupByLibrary.simpleMessage(
      "Получить с телефона",
    ),
    "lanProfileImportAddress": m48,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "Показать одноразовую страницу для передачи подписки с телефона по локальной сети",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось импортировать подписку",
    ),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage(
      "Подписка получена",
    ),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "Импорт подписки…",
    ),
    "lanProfileImportPhoneFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось импортировать подписку. Проверьте ссылку и повторите попытку.",
    ),
    "lanProfileImportPhoneHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте ссылку на подписку, чтобы импортировать её на телевизоре.",
    ),
    "lanProfileImportPhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Подписка импортирована. Можно вернуться к телевизору и закрыть эту страницу.",
    ),
    "lanProfileImportPhoneUnreachable": MessageLookupByLibrary.simpleMessage(
      "Нет связи с телевизором. Проверьте подключение и повторите запрос на этой странице, чтобы узнать результат.",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код телефоном в той же сети, затем вставьте URL подписки",
    ),
    "lanProfileImportSend": MessageLookupByLibrary.simpleMessage(
      "Импортировать на ТВ",
    ),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить передачу по локальной сети",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "Срок действия одноразовой ссылки истёк",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Получение подписки",
    ),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage(
      "Ожидание подписки…",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "lastUsed": MessageLookupByLibrary.simpleMessage("Последнее использование"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Запуск не завершён",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена — при необходимости запустите её вручную.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "level": MessageLookupByLibrary.simpleMessage("Уровень"),
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
    "locationPermissionGuide": m49,
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
    "maxLengthTip": m50,
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "memory": MessageLookupByLibrary.simpleMessage("Память"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "metaInfo": MessageLookupByLibrary.simpleMessage("Подписка"),
    "milestoneDecorations": MessageLookupByLibrary.simpleMessage(
      "Скрытые находки",
    ),
    "milestoneDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать находки, заслуженные при использовании ReClash",
    ),
    "milestoneRevealAuscultation": MessageLookupByLibrary.simpleMessage(
      "Сто проверок. У сети есть пульс.",
    ),
    "milestoneRevealCrown": MessageLookupByLibrary.simpleMessage(
      "Год покрытого времени.",
    ),
    "milestoneRevealFullLadder": MessageLookupByLibrary.simpleMessage(
      "Все ступени — и обратно на первую.",
    ),
    "milestoneRevealMeridian": MessageLookupByLibrary.simpleMessage(
      "Пересечены пять меридианов.",
    ),
    "milestoneRevealOdometer": MessageLookupByLibrary.simpleMessage(
      "Через приложение прошёл один терабайт.",
    ),
    "milestoneRevealPorcelain": MessageLookupByLibrary.simpleMessage(
      "Семь спокойных суток.",
    ),
    "milestoneRevealSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "Тысяча решений без вмешательства.",
    ),
    "milestoneRevealVigil": MessageLookupByLibrary.simpleMessage(
      "Девяносто суток без разрыва.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Минимальный"),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменяет стандартное поведение при выходе",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("минута"),
    "minutesAgo": m51,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("минуты"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m52,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "moveDown": MessageLookupByLibrary.simpleMessage("Ниже"),
    "moveToBottom": MessageLookupByLibrary.simpleMessage("В конец"),
    "moveToTop": MessageLookupByLibrary.simpleMessage("В начало"),
    "moveUp": MessageLookupByLibrary.simpleMessage("Выше"),
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
    "networkDefaultLanBypass": MessageLookupByLibrary.simpleMessage(
      "Без собственных маршрутов локальная сеть обходит VPN. Для её захвата задайте маршруты явно.",
    ),
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
    "neverUsed": MessageLookupByLibrary.simpleMessage("Ещё не использовался"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("Обновлённый вид"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Кольцо подключения и трафик под ним",
    ),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("Новая"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Следующее совпадение"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("Нет анонсов"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noFilterCondition": MessageLookupByLibrary.simpleMessage(
      "Нет условий фильтра",
    ),
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
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Ничего не найдено",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущую группу прокси нельзя выбрать",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Текущая сеть не из доверенных",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Уведомление"),
    "notificationActionButtons": MessageLookupByLibrary.simpleMessage(
      "Кнопки действий",
    ),
    "notificationActionButtonsDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать кнопки паузы и остановки в уведомлении",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Добавить компонент",
    ),
    "notificationAndroidOnly": MessageLookupByLibrary.simpleMessage(
      "Доступно на Android",
    ),
    "notificationAndroidOnlyDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки постоянного уведомления применяются только к VPN-сервису Android.",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Автоматическая группа",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Группа серверов не определена, строка не показывается",
    ),
    "notificationBlockedSmartRoutingOff": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация выключена, строка не показывается",
    ),
    "notificationComponentBehaviour": MessageLookupByLibrary.simpleMessage(
      "Поведение",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Компоненты уведомления",
    ),
    "notificationComponentsActive": MessageLookupByLibrary.simpleMessage(
      "В уведомлении",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Соберите уведомление из компонентов с актуальными данными.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "Компоненты не добавлены",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Без компонентов уведомление показывает только статус защиты.",
    ),
    "notificationComponentsOrderHint": MessageLookupByLibrary.simpleMessage(
      "Строки идут в этом порядке. Первая строка с данными видна в свёрнутом уведомлении.",
    ),
    "notificationConnectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Доктор соединения",
    ),
    "notificationConnectionDoctorDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать вердикт диагностики соединения",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Текущий сервер",
    ),
    "notificationCurrentServerDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать узел, выбранный в группе",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Доставка Android-уведомлений",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Проверяем доступ Android к уведомлениям",
    ),
    "notificationDeliveryFix": MessageLookupByLibrary.simpleMessage(
      "Исправить",
    ),
    "notificationDeliveryOff": MessageLookupByLibrary.simpleMessage(
      "Уведомление отключено в настройках системы",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Уведомления ReClash заблокированы",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Уведомления могут доставляться",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "Канал сервиса ReClash отключён",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Канал напоминаний о подписке отключён",
        ),
    "notificationDetailedDesc": MessageLookupByLibrary.simpleMessage(
      "Живые строки статуса, быстрые действия и значок в статус-баре",
    ),
    "notificationDoctorPriority": MessageLookupByLibrary.simpleMessage(
      "Приоритет Доктора соединения",
    ),
    "notificationDoctorPriorityAlways": MessageLookupByLibrary.simpleMessage(
      "Всегда",
    ),
    "notificationDoctorPriorityProblems": MessageLookupByLibrary.simpleMessage(
      "Только проблемы",
    ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Скрывать скорость при простое",
    ),
    "notificationHideIdleSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать значения скорости при отсутствии трафика",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Скрывать личные данные на экране блокировки",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать профиль, маршрутизацию и диагностику, пока устройство заблокировано",
    ),
    "notificationMinimalDesc": MessageLookupByLibrary.simpleMessage(
      "Только статус защиты, без живых деталей и быстрых действий",
    ),
    "notificationMoveDown": MessageLookupByLibrary.simpleMessage("Ниже"),
    "notificationMoveUp": MessageLookupByLibrary.simpleMessage("Выше"),
    "notificationNetworkNormal": MessageLookupByLibrary.simpleMessage("Норма"),
    "notificationNetworkOffline": MessageLookupByLibrary.simpleMessage(
      "Нет сети",
    ),
    "notificationNetworkPortal": MessageLookupByLibrary.simpleMessage(
      "Портал авторизации",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Скорость сети",
    ),
    "notificationNetworkSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать текущую скорость загрузки и отдачи",
    ),
    "notificationNetworkState": MessageLookupByLibrary.simpleMessage(
      "Состояние сети",
    ),
    "notificationNetworkStateDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать текущий сетевой ландшафт RCX",
    ),
    "notificationNetworkUnknown": MessageLookupByLibrary.simpleMessage(
      "Неизвестно",
    ),
    "notificationNetworkWhitelist": MessageLookupByLibrary.simpleMessage(
      "Белый список",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage(
      "Конфиденциальность",
    ),
    "notificationProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "Постоянное уведомление показывает, активна ли защита.",
    ),
    "notificationProtectionTitle": MessageLookupByLibrary.simpleMessage(
      "Статус защиты",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Напоминания",
    ),
    "notificationRemindersDesc": MessageLookupByLibrary.simpleMessage(
      "Напоминания идут по своему каналу и приходят при любом уровне уведомления.",
    ),
    "notificationRemoveComponent": MessageLookupByLibrary.simpleMessage(
      "Убрать из уведомления",
    ),
    "notificationReorder": MessageLookupByLibrary.simpleMessage(
      "Изменить порядок",
    ),
    "notificationSelectServerGroup": MessageLookupByLibrary.simpleMessage(
      "Выбрать группу серверов",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "Выбранной группы нет в профиле",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Канал сервиса",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Трафик сеанса",
    ),
    "notificationSessionTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать объём загрузки и отдачи за текущий сеанс",
    ),
    "notificationSmartRouting": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация",
    ),
    "notificationSmartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать активное решение Умной маршрутизации",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Канал напоминаний о подписке",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Напоминания о подписке",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Уведомлять, когда подписке требуется внимание",
        ),
    "notificationTurnOff": MessageLookupByLibrary.simpleMessage(
      "Отключить уведомление",
    ),
    "notificationTurnOffDesc": MessageLookupByLibrary.simpleMessage(
      "Android требует уведомление, пока работает защита. Открой настройки системы, чтобы отключить этот канал.",
    ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Уровень уведомления",
    ),
    "notificationVisibilityAlways": MessageLookupByLibrary.simpleMessage(
      "Показывается всегда",
    ),
    "notificationVisibilityCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Показывается, когда группа серверов определена",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Подробно",
    ),
    "notificationVisibilityDoctorProblems":
        MessageLookupByLibrary.simpleMessage(
          "Показывается при обнаружении проблемы",
        ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Минимум",
    ),
    "notificationVisibilitySessionTraffic":
        MessageLookupByLibrary.simpleMessage(
          "Показывается, когда в сессии есть трафик",
        ),
    "notificationVisibilitySmartRoutingOn":
        MessageLookupByLibrary.simpleMessage(
          "Показывается при включённой умной маршрутизации",
        ),
    "notificationVisibilitySpeedIdle": MessageLookupByLibrary.simpleMessage(
      "Скрывается, когда трафика нет",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Профилей пока нет. Сначала добавьте профиль.",
    ),
    "nullTip": m53,
    "numberTip": m54,
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
    "panelHwidIdentityDisabled": MessageLookupByLibrary.simpleMessage(
      "Передача HWID выключена. Включайте её только если доверяете панели.",
    ),
    "panelHwidNotSupported": MessageLookupByLibrary.simpleMessage(
      "Панель сообщила об ограничении HWID",
    ),
    "panelHwidNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "Панель вернула x-hwid-not-supported. Это не доказывает несовместимость клиента. Проверьте настройки HWID и условия подписки.",
    ),
    "panelSettingsConfirmMessage": m55,
    "panelSettingsConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Применить настройки провайдера",
    ),
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
    "porcelainThemeDesc": MessageLookupByLibrary.simpleMessage(
      "Применить холодную почти монохромную палитру",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portTip": m56,
    "predictiveBack": MessageLookupByLibrary.simpleMessage(
      "Предиктивный жест «Назад»",
    ),
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
    "profileImportEmptyResponse": MessageLookupByLibrary.simpleMessage(
      "Сервер вернул пустой профиль",
    ),
    "profileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось импортировать профиль",
    ),
    "profileImportFileReadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать выбранный файл",
    ),
    "profileImportFormatClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "profileImportFormatLinks": MessageLookupByLibrary.simpleMessage(
      "Ссылки узлов",
    ),
    "profileImportFormatSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box",
    ),
    "profileImportFormatWireguard": MessageLookupByLibrary.simpleMessage(
      "WireGuard",
    ),
    "profileImportFormatXray": MessageLookupByLibrary.simpleMessage("Xray"),
    "profileImportInvalidConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурация профиля некорректна",
    ),
    "profileImportSkippedNodes": m57,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль импортирован",
    ),
    "profileImportSuccessSummary": m58,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "Ссылка импорта повреждена или не поддерживается",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите название профиля",
    ),
    "profileUnusedForDays": m59,
    "profileUnusedForMonths": m60,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providerEffects": MessageLookupByLibrary.simpleMessage(
      "Эффекты провайдера",
    ),
    "providerEffectsDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить подписке добавлять декоративный эффект на главный экран",
    ),
    "providerView": MessageLookupByLibrary.simpleMessage(
      "Оформление от провайдера",
    ),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "Провайдер подписки может оформить страницу прокси по-своему. Ваши изменения сохраняются.",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m61,
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
    "qrScanUnsupported": MessageLookupByLibrary.simpleMessage(
      "Сканирование QR-кодов не поддерживается на этом устройстве.",
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
    "regexSearch": MessageLookupByLibrary.simpleMessage(
      "Поиск по регулярному выражению",
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
    "resetFindings": MessageLookupByLibrary.simpleMessage("Сбросить находки"),
    "resetFindingsConfirm": MessageLookupByLibrary.simpleMessage(
      "Открытые записи скроются и смогут появиться снова. История использования не изменится.",
    ),
    "resetFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "Повторить моменты раскрытия, не сбрасывая историю использования",
    ),
    "resetFindingsTitle": MessageLookupByLibrary.simpleMessage(
      "Сбросить находки?",
    ),
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
    "restorePreviewDescription": MessageLookupByLibrary.simpleMessage(
      "До подтверждения ничего не изменится.",
    ),
    "restorePreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка восстановления",
    ),
    "restoreProfilesCount": m62,
    "restoreProxyGroupsCount": m63,
    "restoreRulesCount": m64,
    "restoreScriptsCount": m65,
    "restoreSettingsIncluded": MessageLookupByLibrary.simpleMessage(
      "Настройки включены",
    ),
    "restoreSettingsNotIncluded": MessageLookupByLibrary.simpleMessage(
      "Эта резервная копия не содержит настроек",
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
    "roleAuthor": MessageLookupByLibrary.simpleMessage("Автор и мейнтейнер"),
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
      "Сопоставить по регулярному выражению домена",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить суффикс домена",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставление по маске; поддерживаются только * и ?",
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
    "rulesCount": m66,
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "schedule": MessageLookupByLibrary.simpleMessage("По расписанию"),
    "scheduleDesc": m67,
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Режим скрипта: переопределяет конфигурацию внешними скриптами-расширениями",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Прокрутить к выбранному",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "searchApps": MessageLookupByLibrary.simpleMessage("Поиск приложений"),
    "seasonBirthdayNote": MessageLookupByLibrary.simpleMessage(
      "Сегодня день рождения ReClash.",
    ),
    "seasonFirstRunNote": MessageLookupByLibrary.simpleMessage(
      "Сегодня годовщина вашего первого запуска.",
    ),
    "seasonalDecorations": MessageLookupByLibrary.simpleMessage(
      "Сезонное оформление",
    ),
    "seasonalDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать ненавязчивые сезонные детали на главном экране",
    ),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m68,
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
    "selectedCountTitle": m69,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage(
      "Отправлять HWID",
    ),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Отправлять идентификатор и название устройства, а также версию приложения на сервер провайдера",
    ),
    "sendDeviceIdentityDisableWarning": MessageLookupByLibrary.simpleMessage(
      "При отключении HWID большинство подписок перестанет работать. Продолжить?",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Сервис"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage(
      "Добавить ещё",
    ),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage(
      "Подключаться при открытии ReClash",
    ),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически запускает VPN после загрузки исправного профиля",
    ),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль, чтобы включить автоподключение",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("Назад"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "Продолжить без профиля",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN останется выключен. Профиль можно добавить позже или использовать режим «Только ByeDPI» без VPN-провайдера.",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "Отправлять необязательные отчёты о сбоях",
    ),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "Помогает находить причины сбоев. Без вашего согласия отчёты не отправляются.",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage("Не принимаю и выйти"),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("Удалить"),
    "setupDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage(
      "Готово и подключиться",
    ),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage(
      "Проверьте настройки",
    ),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "Позже его можно сменить в настройках",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage(
      "Прочитать полный отказ от ответственности",
    ),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage(
      "Лицензии открытого ПО",
    ),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash создаёт локальное VPN-подключение для маршрутизации трафика. Вы сами выбираете конфигурацию или провайдера и отвечаете за их использование.",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage(
      "Прежде чем продолжить",
    ),
    "setupNext": MessageLookupByLibrary.simpleMessage("Далее"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage(
      "Оптимизация батареи",
    ),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешите ReClash поддерживать VPN в фоновом режиме",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage(
      "Проверяем…",
    ),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage(
      "Будет запрошено при подключении",
    ),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Не разрешено",
    ),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить",
    ),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage(
      "Уведомления",
    ),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "Показывают состояние подключения во время работы ReClash",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
      "Открыть настройки",
    ),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Недоступно",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage(
      "Разрешение на VPN",
    ),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "Система запросит его при первом подключении",
    ),
    "setupPermissionsTitle": MessageLookupByLibrary.simpleMessage("Разрешения"),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash не продаёт доступ к VPN. Используйте ссылку, QR-код или файл конфигурации от провайдера, которому доверяете. Перед сохранением профиль будет проверен.",
    ),
    "setupProfilesReady": m70,
    "setupRawConfig": MessageLookupByLibrary.simpleMessage(
      "Текст конфигурации",
    ),
    "setupRawConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Вставить конфигурацию YAML, совместимую с Clash",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Выберите регион сети. При выборе России включается HWID — его можно выключить ниже. Умная маршрутизация включается отдельно.",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("Другое"),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется для вашего языка",
    ),
    "setupRegionSettings": MessageLookupByLibrary.simpleMessage(
      "Быстрые настройки региона",
    ),
    "setupRegionSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Проверьте георесурсы, пресеты маршрутизации и доступ приложений. Ничего не добавляется автоматически.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Где находится текущая сеть?",
    ),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("Заменить"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "Текущий профиль будет удалён только после успешного импорта и проверки нового.",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage(
      "Повторить первоначальную настройку",
    ),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "Проверить язык, профиль, маршрутизацию и разрешения без удаления данных",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage(
      "Восстановить из копии",
    ),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить настройки и профили из копии ReClash, FlClashX или FlClash",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("Продолжить без профиля"),
    "setupStepProgress": m71,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "В профиле хранятся серверы и правила, необходимые ReClash для подключения. Импортируйте его у своего провайдера или из резервной копии.",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "Профиль готов",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль подключения",
    ),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage(
      "Автоподключение: выключено",
    ),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage(
      "Автоподключение: включено",
    ),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "Профиля VPN нет — VPN останется выключен; доступен режим «Только ByeDPI»",
    ),
    "setupSummaryProfile": m72,
    "setupSummaryRouting": m73,
    "setupSummarySystemProxyOff": MessageLookupByLibrary.simpleMessage(
      "Системный прокси: выключен",
    ),
    "setupSummarySystemProxyOn": MessageLookupByLibrary.simpleMessage(
      "Системный прокси: включён",
    ),
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage("Итог настройки"),
    "setupSummaryTunOff": MessageLookupByLibrary.simpleMessage("TUN: выключен"),
    "setupSummaryTunOn": MessageLookupByLibrary.simpleMessage("TUN: включён"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage("Язык системы"),
    "setupSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Направляет поддерживаемые приложения через ReClash без прав администратора",
    ),
    "setupTunDesc": MessageLookupByLibrary.simpleMessage(
      "Направляет весь трафик устройства; при подключении система может запросить права администратора",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "Несколько понятных шагов — и всё готово",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLabels": MessageLookupByLibrary.simpleMessage(
      "Подписи в боковой панели",
    ),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
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
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "Временно отложенные провайдеры",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "Временно отложенные проверки",
    ),
    "smartRoutingAdmittedYes": MessageLookupByLibrary.simpleMessage("Допущен"),
    "smartRoutingAliveCount": m74,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "Все серверы",
    ),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage(
      "Доступность",
    ),
    "smartRoutingAvailabilityValue": m75,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "Среднее переключение",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "Среднее восстановление",
    ),
    "smartRoutingAvoidCountries": MessageLookupByLibrary.simpleMessage(
      "Избегать стран выхода",
    ),
    "smartRoutingAvoidCountriesDesc": MessageLookupByLibrary.simpleMessage(
      "Никогда не выпускать трафик через сервер, чей выход измерен в этих странах — даже в крайнем случае",
    ),
    "smartRoutingAxisData": MessageLookupByLibrary.simpleMessage(
      "Экономия трафика",
    ),
    "smartRoutingAxisSpeed": MessageLookupByLibrary.simpleMessage("Скорость"),
    "smartRoutingAxisStability": MessageLookupByLibrary.simpleMessage(
      "Стабильность",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Вернуть автовыбор",
    ),
    "smartRoutingBackup": MessageLookupByLibrary.simpleMessage(
      "Резервная копия",
    ),
    "smartRoutingBandInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите положительное число миллисекунд",
    ),
    "smartRoutingBandLabel": m76,
    "smartRoutingBands": m77,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Поведение"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Нет в текущем списке серверов",
    ),
    "smartRoutingBlockAvoidExit": MessageLookupByLibrary.simpleMessage(
      "Выходит через избегаемую страну",
    ),
    "smartRoutingBlockCooling": m78,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Не прошёл проверки в этой сети",
    ),
    "smartRoutingBlockIgnored": MessageLookupByLibrary.simpleMessage(
      "Игнорируется правилом",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "Местный сервер, в этой сети под запретом",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage(
      "Без поддержки UDP",
    ),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "Провайдер временно отложен после независимых отказов",
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
    "smartRoutingCanariesAnswered": m79,
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
    "smartRoutingCeiling": MessageLookupByLibrary.simpleMessage(
      "Потолок задержки",
    ),
    "smartRoutingCeilingDesc": MessageLookupByLibrary.simpleMessage(
      "Покинуть рабочий сервер, когда его задержка превышает этот предел",
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
    "smartRoutingCoolFor": m80,
    "smartRoutingCountryEchoes": MessageLookupByLibrary.simpleMessage(
      "Сервисы определения страны",
    ),
    "smartRoutingCountryEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "Эндпоинты, сообщающие реальную страну выхода сервера при проверке подозрительного узла",
    ),
    "smartRoutingCountryNoMatch": MessageLookupByLibrary.simpleMessage(
      "Нет подходящего кода страны",
    ),
    "smartRoutingCountryPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика по странам",
    ),
    "smartRoutingCountryPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Какие страны считать цензурирующими и каких избегать на выходе",
    ),
    "smartRoutingCountrySearch": MessageLookupByLibrary.simpleMessage(
      "Поиск по коду страны",
    ),
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage(
      "Проверить все серверы",
    ),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "Не считается с лимитом проб, поэтому трафика уходит больше",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "Проверяем все серверы…",
    ),
    "smartRoutingDegradeConfirm": MessageLookupByLibrary.simpleMessage(
      "Время подтверждения деградации",
    ),
    "smartRoutingDegradeConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "Сколько сервер должен ронять трафик, прежде чем его сменят",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("Тормозит"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически подбирает рабочий сервер для каждой сети — приложение можно не открывать",
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
    "smartRoutingEgress": MessageLookupByLibrary.simpleMessage(
      "Проверка точки выхода",
    ),
    "smartRoutingEgressDesc": MessageLookupByLibrary.simpleMessage(
      "Сервисы, которые показывают, где на самом деле выходит подменённый сервер",
    ),
    "smartRoutingEgressEchoes": MessageLookupByLibrary.simpleMessage(
      "Сервисы эхо-адреса",
    ),
    "smartRoutingEgressEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "Сервисы, отвечающие адресом вызывающего, чтобы вскрыть реальный выход прикрытого сервера",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока ничего не измерено",
    ),
    "smartRoutingEngineAvailable": MessageLookupByLibrary.simpleMessage(
      "Время с рабочим маршрутом",
    ),
    "smartRoutingEngineDeepScan": MessageLookupByLibrary.simpleMessage(
      "Полная проверка",
    ),
    "smartRoutingEngineLanes": MessageLookupByLibrary.simpleMessage(
      "Полосы сервисов",
    ),
    "smartRoutingEngineLinkAge": MessageLookupByLibrary.simpleMessage(
      "Возраст подключения",
    ),
    "smartRoutingEngineMode": MessageLookupByLibrary.simpleMessage(
      "Режим ядра",
    ),
    "smartRoutingEnginePin": MessageLookupByLibrary.simpleMessage(
      "Закреплённый сервер",
    ),
    "smartRoutingEnginePreset": MessageLookupByLibrary.simpleMessage(
      "Региональный пресет",
    ),
    "smartRoutingEngineReportAge": MessageLookupByLibrary.simpleMessage(
      "Возраст отчёта",
    ),
    "smartRoutingEngineTerrain": MessageLookupByLibrary.simpleMessage(
      "Код сети",
    ),
    "smartRoutingEngineTransport": MessageLookupByLibrary.simpleMessage(
      "Тип подключения",
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
    "smartRoutingExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт настроек",
    ),
    "smartRoutingExportDesc": MessageLookupByLibrary.simpleMessage(
      "Сохранить все настройки умной маршрутизации в файл",
    ),
    "smartRoutingExported": MessageLookupByLibrary.simpleMessage(
      "Настройки умной маршрутизации экспортированы",
    ),
    "smartRoutingFails": m81,
    "smartRoutingFieldReset": MessageLookupByLibrary.simpleMessage(
      "Сбросить к значению стратегии",
    ),
    "smartRoutingFitNo": MessageLookupByLibrary.simpleMessage("Не подходит"),
    "smartRoutingFitYes": MessageLookupByLibrary.simpleMessage("Подходит"),
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
    "smartRoutingHeuristics": MessageLookupByLibrary.simpleMessage(
      "Эвристики узлов",
    ),
    "smartRoutingHeuristicsDesc": MessageLookupByLibrary.simpleMessage(
      "Подсказки по именам и правила, влияющие на выбор серверов",
    ),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage(
      "Последние переключения",
    ),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Переключений ещё не было",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage(
      "из проверки задержки",
    ),
    "smartRoutingImport": MessageLookupByLibrary.simpleMessage(
      "Импорт настроек",
    ),
    "smartRoutingImportDesc": MessageLookupByLibrary.simpleMessage(
      "Заменить настройки умной маршрутизации из файла",
    ),
    "smartRoutingImportFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать этот файл настроек",
    ),
    "smartRoutingImported": MessageLookupByLibrary.simpleMessage(
      "Настройки умной маршрутизации импортированы",
    ),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage(
      "Обнаружено сбоев",
    ),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage(
      "Претендент",
    ),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage(
      "В работе",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("оставлен"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage(
      "Допущен к сравнению",
    ),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage(
      "Полоса задержки",
    ),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage(
      "Доказательства",
    ),
    "smartRoutingKeyHomeRisk": MessageLookupByLibrary.simpleMessage(
      "Выходит за рубеж",
    ),
    "smartRoutingKeyIncumbent": MessageLookupByLibrary.simpleMessage(
      "Уже используется",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "Пригодность для сети",
    ),
    "smartRoutingKeyTiebreak": MessageLookupByLibrary.simpleMessage(
      "Устойчивый разрыв ничьей",
    ),
    "smartRoutingKeyUnproven": MessageLookupByLibrary.simpleMessage(
      "Пропускал трафик",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("Вердикт"),
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "Два сервера читаются строка за строкой. Решает первая строка, где они разошлись, и всё, что ниже неё, не читается вовсе.",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage(
      "Последнее переключение",
    ),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage(
      "Последнее восстановление",
    ),
    "smartRoutingLatencyBands": MessageLookupByLibrary.simpleMessage(
      "Лестница задержек",
    ),
    "smartRoutingLatencyBandsDesc": MessageLookupByLibrary.simpleMessage(
      "Границы в миллисекундах, делящие серверы на тиры скорости; пусто — значение стратегии",
    ),
    "smartRoutingLostAt": m82,
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "Учитывать ручной выбор",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "Держать выбранный вами сервер, пока он работает",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "Держится, пока работает",
    ),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "Изолировано проверок сервисов",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "Допустимые статусы",
    ),
    "smartRoutingMarkerStatusesDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP-коды, которые считаются успешным прохождением проверки",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "Через запятую, например 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "Укажите коды HTTP через запятую",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkerUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Полный URL, который запрашивает проверка, чтобы подтвердить доступность",
    ),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage(
      "Проверки сервисов",
    ),
    "smartRoutingMarkersDesc": MessageLookupByLibrary.simpleMessage(
      "URL-адреса, подтверждающие доступ сервера к открытому интернету или домашним сервисам",
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
    "smartRoutingMarkersLocal": MessageLookupByLibrary.simpleMessage(
      "Проверки только для домашних",
    ),
    "smartRoutingMarkersLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Подтверждают, что сервер отвечает только из домашней страны, прежде чем клеймить его",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "Проверки открытого интернета",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер считается проверенным, только если вернул один из этих статусов",
    ),
    "smartRoutingMeasuredOver": m83,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage(
      "Лимитная сеть",
    ),
    "smartRoutingMillis": m84,
    "smartRoutingMinutes": m85,
    "smartRoutingNameHints": MessageLookupByLibrary.simpleMessage(
      "Подсказки по имени домашнего узла",
    ),
    "smartRoutingNameHintsDesc": MessageLookupByLibrary.simpleMessage(
      "Части имени, намекающие, что сервер стоит в домашней стране",
    ),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("Сеть"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "В этой сети сервер ещё не менялся",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("нет ответа"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage(
      "Восстановленных сбоев ещё не было",
    ),
    "smartRoutingNoRivals": MessageLookupByLibrary.simpleMessage(
      "Больше не с чем сравнивать",
    ),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "Нет доступных серверов",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage(
      "Проверка серверов",
    ),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("Без UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m86,
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
    "smartRoutingPacing": MessageLookupByLibrary.simpleMessage("Темп"),
    "smartRoutingPacingDesc": MessageLookupByLibrary.simpleMessage(
      "Как быстро движок реагирует и как долго доверяет проверкам",
    ),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Требуется вход в Wi-Fi",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("Пресет"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("Китай"),
    "smartRoutingPresetEdited": m87,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Другое"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Россия"),
    "smartRoutingProbeBudget": m88,
    "smartRoutingProbes": MessageLookupByLibrary.simpleMessage(
      "Проверки доступности",
    ),
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Пробы"),
    "smartRoutingProofTtl": MessageLookupByLibrary.simpleMessage(
      "Срок годности проверок",
    ),
    "smartRoutingProofTtlDesc": MessageLookupByLibrary.simpleMessage(
      "Как долго пройденная проверка держит сервер подтверждённым до перепроверки",
    ),
    "smartRoutingProvenNo": MessageLookupByLibrary.simpleMessage("Пока нет"),
    "smartRoutingProvenYes": MessageLookupByLibrary.simpleMessage("Да"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "Открыто блокировок провайдеров",
    ),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage(
      "Порядок сравнения",
    ),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage(
      "Порядок выбора",
    ),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "Лестница задержек делит серверы на тиры скорости; измеренный сервер всегда выше неизмеренного",
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
    "smartRoutingReasonHandoffRecovery": MessageLookupByLibrary.simpleMessage(
      "Связь восстановлена после смены сети",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "Работает, ничего лучше не нашлось",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "Прежний сервер перестал отвечать",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "Повторные проверки подтвердили меньшую задержку",
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
    "smartRoutingReasonQualityConfirming": MessageLookupByLibrary.simpleMessage(
      "Подтверждаем улучшение повторными сравнениями",
    ),
    "smartRoutingReasonReliabilityGain": MessageLookupByLibrary.simpleMessage(
      "Повторные проверки подтвердили более стабильную альтернативу",
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
    "smartRoutingRegionCard": MessageLookupByLibrary.simpleMessage(
      "Как работает этот регион",
    ),
    "smartRoutingRegionCardDesc": MessageLookupByLibrary.simpleMessage(
      "Что настраивает регион и как он выбирает серверы",
    ),
    "smartRoutingRegionEditNote": MessageLookupByLibrary.simpleMessage(
      "Всё это можно изменить в расширенной настройке",
    ),
    "smartRoutingRegionHow": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация удерживает рабочий сервер и проверяет остальные в фоне, предпочитая быстрые с доступом к открытому интернету. Регион ниже задаёт эти проверки; меняйте их, только если ваша сеть отличается.",
    ),
    "smartRoutingRegionNote": MessageLookupByLibrary.simpleMessage(
      "Заданы регионом, выбранным в приложении; меняйте только если этого требует ваша сеть",
    ),
    "smartRoutingRegionSeeds": MessageLookupByLibrary.simpleMessage(
      "Что настраивает этот регион",
    ),
    "smartRoutingRegionUnused": MessageLookupByLibrary.simpleMessage(
      "Не используется в этом регионе",
    ),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "Требовать поддержку UDP",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Отсеивать серверы, через которые не пойдут звонки и игры",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "Ограниченная сеть · домашние сервисы напрямую",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "Сервер не отвечает, ищем замену",
    ),
    "smartRoutingRuleAction": MessageLookupByLibrary.simpleMessage("Действие"),
    "smartRoutingRuleAdd": MessageLookupByLibrary.simpleMessage(
      "Добавить правило",
    ),
    "smartRoutingRuleCountry": MessageLookupByLibrary.simpleMessage(
      "Страна выхода",
    ),
    "smartRoutingRuleCountryDesc": MessageLookupByLibrary.simpleMessage(
      "Измеренная страна выхода, двухбуквенный код",
    ),
    "smartRoutingRuleGroup": MessageLookupByLibrary.simpleMessage("Группа"),
    "smartRoutingRuleGroupDesc": MessageLookupByLibrary.simpleMessage(
      "Группа прокси, к которой относится сервер",
    ),
    "smartRoutingRuleIgnore": MessageLookupByLibrary.simpleMessage(
      "Игнорировать",
    ),
    "smartRoutingRuleIgnoreDesc": MessageLookupByLibrary.simpleMessage(
      "Никогда не использовать подходящие серверы",
    ),
    "smartRoutingRuleLastResort": MessageLookupByLibrary.simpleMessage(
      "Крайний случай",
    ),
    "smartRoutingRuleLastResortDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать подходящие серверы, только когда не работает ничего другого",
    ),
    "smartRoutingRuleMatchAny": MessageLookupByLibrary.simpleMessage(
      "Совпадает с любым сервером",
    ),
    "smartRoutingRuleMatchHint": MessageLookupByLibrary.simpleMessage(
      "Оставьте поле пустым, чтобы не учитывать его; правило срабатывает, только когда совпадают все заполненные поля",
    ),
    "smartRoutingRuleName": MessageLookupByLibrary.simpleMessage(
      "Имя содержит",
    ),
    "smartRoutingRuleNameDesc": MessageLookupByLibrary.simpleMessage(
      "Совпадение по фрагменту имени сервера",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "Доступна только в режиме «Правила»",
    ),
    "smartRoutingRulePrefer": MessageLookupByLibrary.simpleMessage(
      "Предпочитать",
    ),
    "smartRoutingRulePreferDesc": MessageLookupByLibrary.simpleMessage(
      "Предпочитать подходящие серверы, пока они исправны",
    ),
    "smartRoutingRuleProvider": MessageLookupByLibrary.simpleMessage(
      "Провайдер",
    ),
    "smartRoutingRuleProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Подписка, из которой пришёл сервер",
    ),
    "smartRoutingRules": MessageLookupByLibrary.simpleMessage(
      "Правила серверов",
    ),
    "smartRoutingRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Игнорировать, придерживать или предпочитать серверы по имени, провайдеру или измеренной стране",
    ),
    "smartRoutingRungVersus": m89,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Подбор сервера…",
    ),
    "smartRoutingSeconds": m90,
    "smartRoutingSectionEngine": MessageLookupByLibrary.simpleMessage("Движок"),
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage(
      "Серверы",
    ),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "Предыдущие переключения",
    ),
    "smartRoutingSectionLadder": MessageLookupByLibrary.simpleMessage(
      "Как сравниваются серверы",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "Надёжность",
    ),
    "smartRoutingSectionRivals": MessageLookupByLibrary.simpleMessage(
      "Против выбранного сервера",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("Решение"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("Серверы"),
    "smartRoutingServersCount": m91,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "Любой провайдер",
    ),
    "smartRoutingServiceCandidates": m92,
    "smartRoutingServiceEnabled": MessageLookupByLibrary.simpleMessage(
      "Использовать маршрут сервиса",
    ),
    "smartRoutingServiceEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "Направлять сервис через подходящий специальный сервер",
    ),
    "smartRoutingServiceFallback": MessageLookupByLibrary.simpleMessage(
      "Если специальный сервер недоступен",
    ),
    "smartRoutingServiceFallbackActiveMain":
        MessageLookupByLibrary.simpleMessage(
          "Специальный сервер недоступен · основной маршрут",
        ),
    "smartRoutingServiceFallbackActiveReject":
        MessageLookupByLibrary.simpleMessage(
          "Специальный сервер недоступен · сервис заблокирован",
        ),
    "smartRoutingServiceFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Что выберет скрытая группа сервиса, пока подходящих серверов нет",
    ),
    "smartRoutingServiceFallbackMain": MessageLookupByLibrary.simpleMessage(
      "Использовать основной сервер Smart Routing",
    ),
    "smartRoutingServiceFallbackReject": MessageLookupByLibrary.simpleMessage(
      "Блокировать сервис",
    ),
    "smartRoutingServiceGemini": MessageLookupByLibrary.simpleMessage(
      "Доступ к Gemini",
    ),
    "smartRoutingServiceManual": MessageLookupByLibrary.simpleMessage(
      "Ручные признаки",
    ),
    "smartRoutingServiceManualEmpty": MessageLookupByLibrary.simpleMessage(
      "Ручных признаков нет",
    ),
    "smartRoutingServiceManualEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Добавьте фрагмент имени и, при необходимости, провайдера",
    ),
    "smartRoutingServiceManualSelector": MessageLookupByLibrary.simpleMessage(
      "Ручной признак сервера",
    ),
    "smartRoutingServiceMatchedNone": MessageLookupByLibrary.simpleMessage(
      "Пока нет подходящих серверов",
    ),
    "smartRoutingServiceNameContains": MessageLookupByLibrary.simpleMessage(
      "Имя содержит",
    ),
    "smartRoutingServiceNameContainsDesc": MessageLookupByLibrary.simpleMessage(
      "Фрагмент имени сервера с учётом регистра",
    ),
    "smartRoutingServiceNoCandidates": MessageLookupByLibrary.simpleMessage(
      "Нет признаков специальных серверов",
    ),
    "smartRoutingServicePending": MessageLookupByLibrary.simpleMessage(
      "Ожидание движка",
    ),
    "smartRoutingServiceProvider": m93,
    "smartRoutingServiceProviderCandidates": m94,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Точное имя провайдера; оставьте пустым для любого",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "Провайдер (необязательно)",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "Манифест подписки",
    ),
    "smartRoutingServiceReady": m95,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("Маршрут"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage(
      "Маршруты сервисов",
    ),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "Маршруты сервисов не настроены",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage(
      "Источники признаков",
    ),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage(
      "Состояние",
    ),
    "smartRoutingServiceTokenTooLong": m96,
    "smartRoutingServiceVia": m97,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "YouTube без рекламы",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "Восстановлено через тёплый резерв",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Решил, кого пропускать",
    ),
    "smartRoutingStepAdmitBody": m98,
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
      "Решает первая строка, на которой два сервера разошлись",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage(
      "Обычная",
    ),
    "smartRoutingStrategyBalancedDesc": MessageLookupByLibrary.simpleMessage(
      "Подходит для всего — оставьте, если не уверены",
    ),
    "smartRoutingStrategyEdited": m99,
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "Скорость",
    ),
    "smartRoutingStrategyLowestLatencyDesc":
        MessageLookupByLibrary.simpleMessage(
          "Берёт самый быстрый из работающих серверов",
        ),
    "smartRoutingStrategyPace": MessageLookupByLibrary.simpleMessage(
      "Задаёт темп",
    ),
    "smartRoutingStrategySaver": MessageLookupByLibrary.simpleMessage(
      "Экономия",
    ),
    "smartRoutingStrategySaverDesc": MessageLookupByLibrary.simpleMessage(
      "Реже проверяет серверы, экономит трафик и батарею",
    ),
    "smartRoutingStrategyStable": MessageLookupByLibrary.simpleMessage(
      "Надёжность",
    ),
    "smartRoutingStrategyStableDesc": MessageLookupByLibrary.simpleMessage(
      "Держится за работающий сервер и реже его меняет",
    ),
    "smartRoutingSwitchLine": m100,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("сменён"),
    "smartRoutingSwitchedAgo": m101,
    "smartRoutingTabDetails": MessageLookupByLibrary.simpleMessage(
      "Подробности",
    ),
    "smartRoutingTabOverview": MessageLookupByLibrary.simpleMessage("Обзор"),
    "smartRoutingTabRanking": MessageLookupByLibrary.simpleMessage("Подбор"),
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage(
      "Технические подробности",
    ),
    "smartRoutingTiedAll": MessageLookupByLibrary.simpleMessage(
      "Совпадает по всем строкам",
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
    "smartRoutingWaitingNetwork": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация ждёт сеть",
    ),
    "smartRoutingWaitingTunnel": MessageLookupByLibrary.simpleMessage(
      "Умная маршрутизация включена · ждёт туннель",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage(
      "Серверов за проверку",
    ),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "Сколько серверов измеряет одна фоновая проверка",
    ),
    "smartRoutingWaveNodes": m102,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Проверка связи",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Почему"),
    "smartRoutingWinsAt": m103,
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
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("Свой"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "Приложение запросит подписку в формате этого клиента",
    ),
    "subscriptionClientExperimentalLabel": MessageLookupByLibrary.simpleMessage(
      "Экспериментально",
    ),
    "subscriptionClientExperimentalTip": MessageLookupByLibrary.simpleMessage(
      "Совместимость с другими клиентами экспериментальна: провайдер отдаёт формат выбранного клиента, и ReClash его преобразует.",
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
    "subscriptionConfigurationSource": MessageLookupByLibrary.simpleMessage(
      "переданной конфигурации",
    ),
    "subscriptionDirectRetryConfirm": MessageLookupByLibrary.simpleMessage(
      "Повторить напрямую",
    ),
    "subscriptionDirectRetryMessage": MessageLookupByLibrary.simpleMessage(
      "Не удалось связаться с подпиской через текущее подключение. Повторить эту загрузку напрямую, не выключая VPN? Панель увидит IP-адрес вашей сети. Маршрут остального трафика не изменится.",
    ),
    "subscriptionDirectRetryTitle": MessageLookupByLibrary.simpleMessage(
      "Повторить вне VPN?",
    ),
    "subscriptionDomainMoved": m104,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Подписка истекла",
    ),
    "subscriptionExpiresInDays": m105,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Подписка истекает сегодня",
    ),
    "subscriptionFaultClient": MessageLookupByLibrary.simpleMessage(
      "Проблема на этом устройстве",
    ),
    "subscriptionFaultClientDesc": MessageLookupByLibrary.simpleMessage(
      "VPN или туннель не полностью активен. Переподключитесь и сформируйте отчёт заново.",
    ),
    "subscriptionFaultInconclusive": MessageLookupByLibrary.simpleMessage(
      "Однозначной причины нет",
    ),
    "subscriptionFaultInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "Данные не указывают явно на одну сторону. Всё равно сохраните отчёт — агрегаты помогут провайдеру.",
    ),
    "subscriptionFaultServer": MessageLookupByLibrary.simpleMessage(
      "Похоже, проблема у провайдера",
    ),
    "subscriptionFaultServerDesc": MessageLookupByLibrary.simpleMessage(
      "Ноды массово падают на отдельных выходах, а ваша сеть в порядке. Отправьте отчёт провайдеру.",
    ),
    "subscriptionFaultSubscription": MessageLookupByLibrary.simpleMessage(
      "Подписка не обновляется",
    ),
    "subscriptionFaultSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить или разобрать конфиг. Отправьте отчёт провайдеру — он указывает на загрузку или панель.",
    ),
    "subscriptionFaultUnknown": MessageLookupByLibrary.simpleMessage(
      "Пока недостаточно данных",
    ),
    "subscriptionFaultUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "Попользуйтесь соединением, затем сформируйте отчёт заново для более чёткого вывода.",
    ),
    "subscriptionFaultYourNetwork": MessageLookupByLibrary.simpleMessage(
      "Проблема в вашей сети",
    ),
    "subscriptionFaultYourNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Трафик блокируется или сеть недоступна ещё до провайдера. Проверьте Wi-Fi, мобильный интернет или captive-портал.",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("О подписке"),
    "subscriptionLoopbackWarning": MessageLookupByLibrary.simpleMessage(
      "Адрес профиля указывает на прокси-порт самого ReClash. Проверьте ссылку подписки.",
    ),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "Подписка не сообщает ни лимит трафика, ни срок действия",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Напоминания о подписке",
    ),
    "subscriptionProviderInterval": m106,
    "subscriptionReport": MessageLookupByLibrary.simpleMessage(
      "Отчёт по подписке",
    ),
    "subscriptionReportConfirm": MessageLookupByLibrary.simpleMessage(
      "Отчёт содержит только обезличенную диагностику: псевдонимы нод с метками протокола, транспорта и страны выхода, классы ошибок, интервалы задержек и ваши пресеты маршрутизации и desync. В него никогда не попадают URL подписки, реальные имена нод, хосты, адреса и порты. Сохранить как JSON, чтобы отправить провайдеру?",
    ),
    "subscriptionReportFlaggedNodes": MessageLookupByLibrary.simpleMessage(
      "Проблемные ноды",
    ),
    "subscriptionReportGenerating": MessageLookupByLibrary.simpleMessage(
      "Формируем отчёт…",
    ),
    "subscriptionReportRuntimeDials": MessageLookupByLibrary.simpleMessage(
      "Соединения",
    ),
    "subscriptionReportSave": MessageLookupByLibrary.simpleMessage(
      "Сохранить JSON",
    ),
    "subscriptionReportUpdateFailures": MessageLookupByLibrary.simpleMessage(
      "Сбои обновления",
    ),
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "В подписке не найдено обычных адресов узлов. Возможно, панель вернула заглушку. Подключение к серверам не проверялось.",
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
    "toolsSelectPanePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Выберите настройку, чтобы посмотреть её здесь.",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Докупить трафик"),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Всего"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт TProxy"),
    "trafficFreeOfTotal": m107,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash говорит на вашем языке, чтобы им могли пользоваться люди из разных стран. Если какая-то формулировка режет глаз — напишите, поправим.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Предложить правку перевода",
    ),
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
    "urlTip": m108,
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
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Размытие"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Непрозрачность карточек",
    ),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage(
      "Выбрать изображение",
    ),
    "wallpaperDescription": MessageLookupByLibrary.simpleMessage(
      "Ваше изображение заменяет фон подписки. Отключите его, чтобы вернуть прежнее оформление.",
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
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрирование"),
    "wallpaperLibraryFull": m109,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage(
      "Непрозрачность изображения",
    ),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("Читаемость"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage(
      "Удалить изображение",
    ),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage(
      "Сбросить параметры",
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
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Положение по вертикали",
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
    "yearsAgo": m110,
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
  };
}
