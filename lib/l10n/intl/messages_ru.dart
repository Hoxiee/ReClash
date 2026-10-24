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

  static String m0(count) => "Выбрано: ${count}";

  static String m1(count) =>
      "Приложений, которые провайдер пускает мимо VPN: ${count}. Включите контроль доступа, чтобы изменить список.";

  static String m2(name) => "«${name}» добавлен в локальные прокси";

  static String m3(name) => "«${name}» уже есть в локальных прокси";

  static String m4(count, skipped) =>
      "Будет добавлено: ${count}, пропущено (уже есть): ${skipped}";

  static String m5(detail) => "Не удалось очистить данные: ${detail}";

  static String m6(code) =>
      "Windows отказалась запускать ReClashCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите ReClash в этой политике или отключите её и повторите попытку.";

  static String m7(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, профиль ${name} снят с выбора, а автоматическая настройка пропущена. Вы можете выбрать его снова в любой момент.";

  static String m8(url) => "Создать профиль по ссылке ${url}?";

  static String m9(groups) =>
      "У групп прокси ${groups} отброшен include-all; добавьте прокси или провайдеры прокси, которые они используют";

  static String m10(count, label) =>
      "${Intl.plural(count, one: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правило SUB-RULE', few: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правила SUB-RULE', many: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правил SUB-RULE', other: 'Пользовательские профили не поддерживают подправила, поэтому отброшено ${label} правила SUB-RULE')}";

  static String m11(message) =>
      "Ядро не может разобрать этот прокси: ${message}";

  static String m12(proxy, target) =>
      "${proxy} подключается через ${target}, а ${target} снова ведёт к ${proxy}, поэтому подключение зацикливается";

  static String m13(name) =>
      "Имя ${name} уже занято другим прокси или группой прокси";

  static String m14(path) =>
      "Группы прокси ссылаются друг на друга по кругу: ${path}";

  static String m15(name) =>
      "Резервом для пустой группы может быть только прокси, а ${name} не существует или является группой прокси";

  static String m16(name, message) =>
      "${name}: недопустимое регулярное выражение: ${message}";

  static String m17(name) => "Прокси для подключения ${name} не существует";

  static String m18(names) => "Эти провайдеры прокси не существуют: ${names}";

  static String m19(names) => "Эти прокси или политики не существуют: ${names}";

  static String m20(name) =>
      "${name} — встроенное имя политики, его нельзя использовать";

  static String m21(count) =>
      "Проблем: ${count}, применение профиля может завершиться ошибкой";

  static String m22(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m23(count) => "${count} дн. назад";

  static String m24(label) =>
      "Вы уверены, что хотите удалить выбранные элементы (${label})?";

  static String m25(label) => "Вы уверены, что хотите удалить «${label}»?";

  static String m26(label) => "Сведения: ${label}";

  static String m27(name) =>
      "Подключение через ${name} ведёт обратно к прокси, который его использует, поэтому соединение остановлено";

  static String m28(label) => "Поле «${label}» не может быть пустым";

  static String m29(label) => "«${label}» уже существует";

  static String m30(count) => "Ошибок: ${count}";

  static String m31(label, message) => "${label}: ${message}";

  static String m32(name) => "${name}: уже последняя версия";

  static String m33(name) => "${name}: обновлено";

  static String m34(count) => "Групп: ${count}";

  static String m35(count) => "Тайм-аут: ${count}";

  static String m36(action) =>
      "Уже используется для «${action}». При сохранении будет перенесено сюда.";

  static String m37(actions) => "Не экспортировано: ${actions}";

  static String m38(modifiers) =>
      "Добавьте хотя бы одну из клавиш: ${modifiers}";

  static String m39(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m40(count) => "${count} ч назад";

  static String m41(target) => "${target} — недопустимая политика";

  static String m42(proxyName) => "${proxyName} — недопустимый прокси";

  static String m43(providerName) =>
      "${providerName} — недопустимый провайдер прокси";

  static String m44(ruleSet) => "${ruleSet} — недопустимый набор правил";

  static String m45(subRule) => "${subRule} — недопустимый SUB_RULE";

  static String m46(count) =>
      "${Intl.plural(count, one: '${count} элемент', few: '${count} элемента', many: '${count} элементов', other: '${count} элемента')}";

  static String m47(line, message) => "Строка ${line}: ${message}";

  static String m48(appName) =>
      "1. Откройте Системные настройки > Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nПосле настройки вернитесь в приложение и продолжайте работу. Спасибо за сотрудничество.";

  static String m49(label, max) => "«${label}» — не более ${max} символов";

  static String m50(size) => "Освобождено ${size}";

  static String m51(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m52(count) => "${count} мин назад";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m54(count) => "${count} мес. назад";

  static String m55(code) =>
      "Сервер запретил доступ (HTTP ${code}). Возможно, ссылка устарела или учётные данные неверны";

  static String m56(code) => "Сервер отклонил запрос (HTTP ${code})";

  static String m57(code) =>
      "По этому адресу ничего не найдено (HTTP ${code}). Проверьте правильность URL";

  static String m58(detail) => "Сетевой запрос не выполнен: ${detail}";

  static String m59(code) =>
      "На сервере произошла ошибка (HTTP ${code}). Повторите попытку позже";

  static String m60(label) => "Пока нет: ${label}";

  static String m61(label, min, max) =>
      "Значение «${label}» должно быть от ${min} до ${max}";

  static String m62(label) => "Значение «${label}» должно быть числом";

  static String m63(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m64(port) => "Порт ${port}";

  static String m65(added, skipped, failed) =>
      "Добавлено: ${added}; пропущено: ${skipped}; ошибок: ${failed}.";

  static String m66(days) => "Осталось дней: ${days}";

  static String m67(date, days) => "Истекает ${date}, осталось дней: ${days}";

  static String m68(name) => "Уже добавлена как «${name}»";

  static String m69(client) => "Как её получает приложение ${client}";

  static String m70(count) =>
      "${Intl.plural(count, one: '${count} сервер', few: '${count} сервера', many: '${count} серверов', other: '${count} сервера')}";

  static String m71(time) => "Обновлено ${time}";

  static String m72(label, profiles) =>
      "«${label}» всё ещё используется профилями: ${profiles}. После удаления они будут работать неправильно. Вы уверены, что хотите удалить его?";

  static String m73(count, label) =>
      "${Intl.plural(count, other: '${label} прокси')}";

  static String m74(name, count) => "${name} и другие (${count} прокси)";

  static String m75(removed) =>
      "Будут удалены прокси: ${removed}. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?";

  static String m76(removed, added) =>
      "Будут удалены прокси: ${removed}. Будут добавлены: ${added}. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?";

  static String m77(label) =>
      "На «${label}» всё ещё ссылаются правила, группы прокси, прокси для подключения, DNS или NTP этого профиля, и после удаления эти ссылки перестанут работать. Вы уверены, что хотите удалить её?";

  static String m78(count, label) =>
      "${Intl.plural(count, one: '${label} группа прокси', few: '${label} группы прокси', many: '${label} групп прокси', other: '${label} группы прокси')}";

  static String m79(pick, now) => "Выберет ${pick} вместо ${now}";

  static String m80(group) => "Проверка для ${group}";

  static String m81(pick) => "Оставит ${pick}";

  static String m82(number) => "Условие ${number}";

  static String m83(profile) => "«${profile}» хочет проверить эти сайты";

  static String m84(profile) => "Удалить «${profile}»?";

  static String m85(requests, used, cap) =>
      "Проверок сегодня: ${requests} · ${used} из ${cap}";

  static String m86(condition) => "кроме ${condition}";

  static String m87(country) => "выход ${country}";

  static String m88(member) => "Через ${member}";

  static String m89(profile) => "Добавлен «${profile}»";

  static String m90(node) => "${node} перестал работать";

  static String m91(from, to) => "Режим ${from} → ${to}";

  static String m92(line, text) => "Строка ${line}: ${text}";

  static String m93(check) =>
      "Проверка ${check} нигде не используется, поэтому не выполняется";

  static String m94(hosts) => "Обращается к сторонним сайтам: ${hosts}";

  static String m95(group) => "В этом конфиге нет группы ${group}";

  static String m96(group) =>
      "Ни один сервер группы ${group} не проходит фильтр";

  static String m97(tag) => "Тег ${tag} нигде не используется";

  static String m98(tier, group) =>
      "Сейчас ни один сервер группы ${group} не входит в «${tier}»";

  static String m99(tier, after) =>
      "«${tier}» повторяет условие «${after}», поэтому в него ничего не попадает";

  static String m100(keys) =>
      "Перенесено; вы тоже меняли это, поэтому сохранены ваши значения: ${keys}";

  static String m101(mode) => "Режим: ${mode}";

  static String m102(kind) => "Сеть: ${kind}";

  static String m103(tier) => "может попасть в «${tier}» после проверки";

  static String m104(node) => "Закреплён: ${node}";

  static String m105(error) => "Ошибка профиля: ${error}";

  static String m106(profile) =>
      "Профиль ${profile} не найден; используется стандартный";

  static String m107(error) =>
      "Не удалось сохранить состояние маршрутизации: ${error}";

  static String m108(tier) => "Переключено на сервер из «${tier}»";

  static String m109(from) => "Сервер сменён; ${from} пропускается 15 минут";

  static String m110(from) =>
      "${from} перестал работать; переключено на лучший запасной";

  static String m111(from, gain) => "Ушёл с ${from}: быстрее на ${gain} мс";

  static String m112(node) => "Сценарий держит ${node}";

  static String m113(node) => "${node} нет в этой группе";

  static String m114(limit) => "Достигнут лимит переключений (${limit} в час)";

  static String m115(mode) => "Не используется: режим ${mode}";

  static String m116(from) => "${from} больше не входит в список";

  static String m117(kind) =>
      "Пауза, пока сеть — «${kind}»: ничего не проверяется и не переключается";

  static String m118(node) => "Сценарий переключает на ${node}";

  static String m119(node) => "Переключено на закреплённый ${node}";

  static String m120(node) =>
      "Нет рабочих серверов; запасной вариант — ${node}";

  static String m121(scenario) =>
      "Сейчас этой группой управляет сценарий «${scenario}».";

  static String m122(count, total) => "Подходят ${count} из ${total}";

  static String m123(node) =>
      "Перейдёт на ${node}, как только проверка это подтвердит";

  static String m124(node, gain) =>
      "Перейдёт на ${node}, если он останется быстрее на ${gain} мс";

  static String m125(node, minutes) =>
      "Может перейти на ${node} через ${minutes} мин";

  static String m126(name) => "проверка ${name}";

  static String m127(name) => "диагностика сети ${name}";

  static String m128(region, bypassed, proxied) =>
      "${region}: в список обхода VPN попадут ${bypassed} приложений, в список VPN — ${proxied}. Оба списка будут заменены; режим и остальные параметры не изменятся. Совпадения пакетов и SDK — лишь подсказки: проверьте результат после применения.";

  static String m129(seconds) => "Подтверждение через ${seconds} с";

  static String m130(count, label) =>
      "${Intl.plural(count, one: '${label} правило', few: '${label} правила', many: '${label} правил', other: '${label} правила')}";

  static String m131(appName) => "${appName} (Безопасный режим)";

  static String m132(count) =>
      "${Intl.plural(count, one: '${count} секунда', few: '${count} секунды', many: '${count} секунд', other: '${count} секунды')}";

  static String m133(count) => "Действуют: ${count}";

  static String m134(count) => "Проблем: ${count}";

  static String m135(count) =>
      "${Intl.plural(count, one: '${count} настройка', few: '${count} настройки', many: '${count} настроек', other: '${count} настройки')}";

  static String m136(count) => "Приложений в обход VPN: ${count}";

  static String m137(count) => "Доступно профилей: ${count}";

  static String m138(step, total) => "${step} из ${total}";

  static String m139(server) => "Попробовать ${server}";

  static String m140(link) => "Не удалось прочитать прокси из ${link}";

  static String m141(label) => "«${label}» — только одно значение";

  static String m142(client, format, count) =>
      "Получено как ${client}: ${format}, узлов: ${count}.";

  static String m143(count) =>
      "${Intl.plural(count, one: 'Подписка истекает через ${count} день', few: 'Подписка истекает через ${count} дня', many: 'Подписка истекает через ${count} дней', other: 'Подписка истекает через ${count} дней')}";

  static String m144(count) =>
      "${Intl.plural(count, one: 'Добавить ${count} сервер', few: 'Добавить ${count} сервера', many: 'Добавить ${count} серверов', other: 'Добавить ${count} сервера')}";

  static String m145(count) =>
      "${Intl.plural(count, one: 'Сервер будет добавлен', other: 'Все серверы будут добавлены: ${count}')}";

  static String m146(count, total) =>
      "Будет добавлено ${count} из ${Intl.plural(total, one: '${total} сервера', other: '${total} серверов')}";

  static String m147(count) => "Показать все (${count})";

  static String m148(format) => "Формат: ${format}";

  static String m149(percent) => "Израсходовано ${percent}% трафика";

  static String m150(count) => "Результатов: ${count}";

  static String m151(value) => "Пик ${value}";

  static String m152(value) => "Всего ${value}";

  static String m153(transport) => "Заголовки ${transport}";

  static String m154(version) => "Установлена версия ${version}";

  static String m155(count) => "${count} мин";

  static String m156(time) => "Осталось ${time}";

  static String m157(count) => "${count} с";

  static String m158(speed) => "${speed}/с";

  static String m159(nodes, groups, providers) =>
      "Прокси: ${nodes}, группы: ${groups}, удалённые провайдеры: ${providers}";

  static String m160(action) =>
      "Ссылка запрашивает действие «${action}». Разрешить ReClash выполнить его?";

  static String m161(name, source) =>
      "Импортировать «${name}» из ${source}? После согласия выполнятся проверка профиля и рассмотрение преобразований.";

  static String m162(label) => "Значение «${label}» должно быть URL";

  static String m163(index) => "Фон ${index}";

  static String m164(count) =>
      "Можно хранить до ${count} фонов. Удалите один, чтобы добавить новый.";

  static String m165(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  static String m166(count) =>
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
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки контроля доступа",
    ),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Вернуть приложения провайдеру",
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
    "addNetwork": MessageLookupByLibrary.simpleMessage("Добавить сеть"),
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
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Добавить в локальные прокси",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Добавленные правила"),
    "addedToLocalProxies": m2,
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
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("Ответы"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("Иконка приложения"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("Установить иконку"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Чертёж"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "Новая иконка может появиться на рабочем столе через несколько секунд. Некоторые лаунчеры убирают ярлык — добавьте его снова из списка приложений.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Схема"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Дизайн значка приложения",
    ),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Эхо"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Чернила"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Осколки"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Солнце"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Искра"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Стандартная"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Пласты"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Рельеф"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("След"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Бархат"),
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
    "applied": MessageLookupByLibrary.simpleMessage("Применено"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Применить сейчас"),
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
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("Размытие фона"),
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
    "batchPreviewTip": m4,
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
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("Очистить кэш DNS"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось очистить кэш DNS",
    ),
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
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Разрывать все открытые соединения, когда VPN на паузе",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Контрастность"),
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
    "contrastHigh": MessageLookupByLibrary.simpleMessage("Высокая"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Средняя"),
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
    "coreBlockedByPolicyTip": m6,
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
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfileFromUrlTip": m8,
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
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "Имя не задано",
    ),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Не выбраны ни прокси, ни провайдеры прокси, поэтому ядро отклонит эту группу",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Ресурсы пользовательских профилей",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Ресурсы пользовательских профилей — это прокси, провайдеры правил, фильтры и наборы значков, которые вы сами добавляете для пользовательских профилей.",
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
    "daysAgo": m22,
    "daysAgoShort": m23,
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
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут теста задержки",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
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
    "details": m26,
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
    "dialerProxyLoopStopped": m27,
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
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("Кэш DNS очищен"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Без этого параметра TUN перехватывает все DNS-запросы на порт 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Добавленные здесь параметры заменяют DNS всех профилей из URL и файлов; остальные остаются такими, как в профиле. DNS пользовательского профиля задаётся в его содержимом.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS-запросы"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Все переопределения DNS будут удалены, а DNS-серверы выбранного региона — установлены заново.",
    ),
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
    "editNetwork": MessageLookupByLibrary.simpleMessage("Изменить сеть"),
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
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enabled": MessageLookupByLibrary.simpleMessage("Включено"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Ввести вручную"),
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
    "existsTip": m29,
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
    "extra": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Очень крупный"),
    "fade": MessageLookupByLibrary.simpleMessage("Растворение"),
    "failedCount": m30,
    "failedItem": m31,
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
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Добавленные здесь параметры заменяют соответствующие настройки всех профилей; остальные остаются такими, как в профиле, а если профиль их не задаёт, действуют значения ядра по умолчанию.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
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
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("групп"),
    "groupTimeoutCount": m35,
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
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Глобальные горячие клавиши работают, даже когда окно скрыто. Нажмите на действие, чтобы записать сочетание клавиш.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Хоткеи рабочего стола",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Назначьте команду на сочетание клавиш в настройках рабочего стола. ReClash должен быть запущен, но окно может оставаться скрытым. Эти глобальные привязки настраиваются средствами рабочего стола.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Файлы конфигурации композитора недоступны. Можно использовать команды рабочего стола выше.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Эти сочетания работают, когда окно приложения в фокусе. Для глобальных сочетаний подключите команды рабочего стола ниже.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "hotkeyNeedsModifier": m38,
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
    "hoursAgo": m39,
    "hoursAgoShort": m40,
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
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Введите порт или диапазон, например 443 или 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Этот QR-код не содержит ссылку на профиль",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Введите числа или диапазоны, например 80 или 8000-9000, через /",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID не может превышать 32 байта UTF-8",
    ),
    "invalidSubRule": m45,
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
    "itemsCount": m46,
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
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Перенос строк"),
    "link": MessageLookupByLibrary.simpleMessage("Ссылка"),
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
    "locationPermissionGuide": m48,
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
    "maxLengthTip": m49,
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
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage(
      "Монохромный значок",
    ),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Нижняя панель"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("Подписи вкладок"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Всегда"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Никогда"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage(
      "Активная",
    ),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Навигация"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage(
      "Панель вкладок",
    ),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage(
      "Боковая панель",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Запрос отменён",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться к серверу. Проверьте подключение к сети или настройки прокси",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Home Wi-Fi) или подсеть (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить адрес сервера. Проверьте правильность URL и работу DNS",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Имя сети"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Слишком много запросов (HTTP 429). Подождите немного и повторите попытку",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Список обхода и MTU для TUN вернутся к значениям выбранного региона.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Секрет сети"),
    "networkServerError": m59,
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
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Текущая сеть не из доверенных",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Уведомление"),
    "notificationActive": MessageLookupByLibrary.simpleMessage(
      "Защита активна",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Добавить компонент",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Автоматическая группа",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "Группа серверов не определена, строка не показывается",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Компоненты уведомления",
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
    "notificationContent": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Текущий сервер",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Доставка Android-уведомлений",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Проверяем доступ Android к уведомлениям",
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
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Скрывать скорость при простое",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Скрывать личные данные на экране блокировки",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Для уведомления сервиса и напоминаний. Скрытие зависит от настроек экрана блокировки Android; после разблокировки детали видны.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Подробный режим показывает текущие данные и кнопку остановки. Минимальный — только состояние защиты.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Скорость сети",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage(
      "Конфиденциальность",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage(
      "Напоминания",
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
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Уровень уведомления",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Подробно",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Минимум",
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
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("Обфускация"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Хост обфускации"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Режим обфускации"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Параметр обфускации"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Пароль обфускации"),
    "onDemand": MessageLookupByLibrary.simpleMessage("По условию"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "Эта подсеть охватывает широкий диапазон сетей",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Закрывать соединения",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "«По условию» приостанавливает прокси в исключённых сетях Wi-Fi.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage(
      "Полная остановка",
    ),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "На паузе снимать TUN и закрывать локальные прокси-порты. Наблюдение за сетью продолжится для автоматического возобновления.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Приостановить"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Возобновить"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить сети Wi-Fi. Повторите поиск или добавьте сеть вручную.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "Требовать SSID и подсеть вместе",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "Если заданы оба вида правил — пауза только при совпадении SSID и подсети",
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
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешите доступ к геолокации, чтобы увидеть ближайшие сети Wi-Fi, или добавьте сеть вручную.",
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
    "plugin": MessageLookupByLibrary.simpleMessage("Плагин"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("Шифр плагина"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Хост плагина"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Режим плагина"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("Пароль плагина"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Путь плагина"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя плагина",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Перескок портов"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("Порты"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Общий ключ"),
    "preferred": MessageLookupByLibrary.simpleMessage("Предпочтительный"),
    "prerequisites": MessageLookupByLibrary.simpleMessage(
      "Предварительные условия",
    ),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Нажмите ещё раз, чтобы выйти",
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
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль изменён. Отключить автообновление?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Загрузка страницы подписки…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "Загружаем подписку…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "Профиль с этим URL подписки уже добавлен",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "Подписка зашифрована — ключ спросим при добавлении.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("Истекла"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Формат подписки",
    ),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "Лучший формат для ReClash, подбирается автоматически",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "От провайдера",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Часть настроек не поддерживается — покажем их перед добавлением.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить страницу подписки. Вы всё равно можете её добавить.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Серверы"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Один сервер",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Новая подписка",
    ),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "Ничего не добавлено. Можно выбрать другой формат и попробовать снова.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Безлимит"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Действует до",
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
    "profileUpdatedAt": m71,
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
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("Объявление"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Подробнее",
    ),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("Читать"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Уведомление"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "От провайдера",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Вернуть провайдеру",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Вернуть настройки провайдеру",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Изменённые вами настройки снова будут следовать подписке",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Поддерживаются только удалённые ресурсы",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Группа прокси пуста",
    ),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Группы появятся здесь после запуска ядра",
    ),
    "proxyGroupsCount": m78,
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
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Ссылка слишком длинная для QR-кода. Используйте «Копировать ссылку».",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Быстрые действия"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Быстрое редактирование"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Добавить группу"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("Добавить тип сети"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Добавить шаблон"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Добавить тег"),
    "rcxAddTier": MessageLookupByLibrary.simpleMessage("Добавить предпочтение"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "Эти части правятся в YAML.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Все группы"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Любой"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("Автоуправление"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "Сценарий управляет всем подключением: режимом в каждом типе сети и тем, что делает каждая группа. Группы, которых он не касается, работают по своему профилю.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("Вернуть авто"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Сбалансированно"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Основан на"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Поведение"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Перенести изменения",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Ваши правки останутся как есть",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("Сменить сервер"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Сменить на"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Проверка"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("На группе"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("Не найдёт сервер"),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage(
      "открывает заблокированное",
    ),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Проверки"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Проверки доступности",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Добавить условие"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("Все условия"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Всегда"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Любое условие"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("Любой сервер"),
    "rcxCondClause": m82,
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Поле"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage(
      "Без учёта регистра",
    ),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Совпадение"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("Не заданы"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("не"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Оператор"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Шаблон"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("Как текст"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "Условие содержит вложенные группы, поэтому правится как текст.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Значение"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Значения через запятую",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Пока вы не разрешите, группа работает по профилю «Простой». Сайты открываются только через ваши серверы или для проверки сети.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("Нужно разрешение"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage(
      "Сайты, к которым обращается",
    ),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Сторонние сайты не принадлежат ни вашему провайдеру, ни встроенным профилям.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Управление"),
    "rcxDeleteProfile": m84,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage("Диагностика сети"),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Прямые сайты через эту группу",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage(
      "Включено сейчас",
    ),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "Если сайты, которые правила отправляют напрямую, перестанут открываться, они пойдут через эту группу. Локальные адреса всегда остаются прямыми.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "Ждёт: прямые сайты пока открываются",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage(
      "Дублировать и изменить",
    ),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Экономно"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Точно"),
    "rcxEnergyToday": m85,
    "rcxExcept": m86,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Исключён профилем",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "Пропущен после «Сменить сервер»",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage(
      "Не входит в список",
    ),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Не подходит ни под одно предпочтение",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Ещё не проверен",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage("Не сервер"),
    "rcxExit": m87,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage(
      "Проверка страны выхода",
    ),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Экспорт"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Редко"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Часто"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Работает"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("Используется"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Не работает"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Диагностика сети"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Страна входа"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Страна выхода"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage(
      "Не проходит проверку",
    ),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Задержка, мс"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Измерено"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("Лимитная сеть"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Имя"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("Проходит проверку"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Страница входа"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Провайдер"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("Адрес сервера"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Тег"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage(
      "Тип подключения",
    ),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Протокол"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("Поддерживает UDP"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "Вся группа идёт через этот элемент без перебора серверов; выберите балансировщик или вложенную группу, чтобы отдать им весь трафик.",
    ),
    "rcxFixedOn": m88,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("Общие"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage("Профили групп"),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "Как смарт-группа выбирает сервер. Нажмите на свой, чтобы изменить его, на любой другой — чтобы изменить копию.",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Работает"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Не работает"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("Работал раньше"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Не проверялся"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("История"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Прежние версии",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage(
      "Добавить в мои профили",
    ),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Запустите ядро приложения, чтобы проверить этот профиль.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Импорт профиля маршрутизации",
    ),
    "rcxImported": m89,
    "rcxJournalFailure": m90,
    "rcxJournalMode": m91,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("проверяется"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "В этой сети они заменяют одноимённые группы сценария; остальные работают как во всех сетях.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Название"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Строчные латинские буквы, цифры и дефисы, до 24 символов",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("открытый интернет"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("страница входа"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Распознаётся, когда"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Типы проверяются сверху вниз; сеть получает первый подходящий.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage(
      "только белые списки",
    ),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Запасной вариант"),
    "rcxLastResortHint": MessageLookupByLibrary.simpleMessage(
      "Запасное предпочтение используется, только если в лучших предпочтениях нет серверов.",
    ),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Уровень"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Продвинутый"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Простой"),
    "rcxLine": m92,
    "rcxLintCheckUnused": m93,
    "rcxLintConsent": m94,
    "rcxLintGroupMissing": m95,
    "rcxLintPoolEmpty": m96,
    "rcxLintTagUnused": m97,
    "rcxLintTierEmpty": m98,
    "rcxLintTierUnreachable": m99,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Основная группа"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Сделать группу умной",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash держит в группе рабочий сервер и переключается, когда он перестаёт работать. Проверки идут только пока вы пользуетесь сетью.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Профили и сценарии создаются и редактируются в разделе «Расширенная конфигурация» → «Авто-маршрут».",
    ),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось перенести изменения",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Изменения перенесены"),
    "rcxMergedConflicts": m100,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Авто"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Выбирает и переключает серверы по профилю",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Вернуть режим сценарию",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "Режим в этой сети задаёт сценарий",
    ),
    "rcxModeIs": m101,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("Не менять"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Вручную"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "Выбираете вы; авто-маршрут ничего не переключает",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "Режим выбран вручную; сценарий ждёт, пока вы не выберете «Авто»",
    ),
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "В этой сети режим ваш",
    ),
    "rcxMoveDown": MessageLookupByLibrary.simpleMessage("Вниз"),
    "rcxMoveUp": MessageLookupByLibrary.simpleMessage("Вверх"),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Нужно ваше разрешение",
    ),
    "rcxNetwork": m102,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Типы сетей"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("Новый профиль"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("Новый сценарий"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("В этой сети"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("не проходит"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("одно из"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("равно"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("не равно"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("соответствует"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("проходит"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage("Изменения по сетям"),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage(
      "Свой профиль группы",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "Шаблон — неверное регулярное выражение",
    ),
    "rcxPendingTier": m103,
    "rcxPinned": m104,
    "rcxPinnedHint": MessageLookupByLibrary.simpleMessage(
      "Уходит с него только при сбое и возвращается, когда он оживёт",
    ),
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Закреплён"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Исключить"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Использовать"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "В группе нет серверов",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "В текущей конфигурации эта группа не селектор",
    ),
    "rcxProblemProfileInvalid": m105,
    "rcxProblemProfileMissing": m106,
    "rcxProblemStoreFailed": m107,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Название"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "Группа выбирает сервер по этому профилю среди серверов, которые оставляет пул.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Действие"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Отдать одному элементу",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Элемент"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Выбирать сервер"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage("Это лучший сервер"),
    "rcxReasonBetterTier": m108,
    "rcxReasonChangeServer": m109,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Проверяет лучшего кандидата",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "Более быстрому серверу нужен ещё один замер",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Недавно переключался; выжидает перед следующим",
    ),
    "rcxReasonFailover": m110,
    "rcxReasonFaster": m111,
    "rcxReasonFixed": m112,
    "rcxReasonFixedMissing": m113,
    "rcxReasonFlapLimit": m114,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Держит закреплённый сервер",
    ),
    "rcxReasonIdle": m115,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Выбран лучший доступный сервер",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage(
      "Управление вручную",
    ),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Сеть сменилась",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "Похоже, пропала сеть; серверы не виноваты",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "Нет другого рабочего сервера",
    ),
    "rcxReasonOutOfPool": m116,
    "rcxReasonPaused": m117,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось выбрать сервер",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Прямые сайты снова идут напрямую",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Прямые сайты теперь идут через эту группу",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Нет рабочих серверов; держит текущий",
    ),
    "rcxReasonSwitchFixed": m118,
    "rcxReasonSwitchPinned": m119,
    "rcxReasonSwitchStranded": m120,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Работает; держится до сбоя",
    ),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Сценарий"),
    "rcxScenarioDrives": m121,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Группы"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Основная группа — та, куда ведёт последнее правило; «Все группы» — остальные группы-селекторы, не названные здесь.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Распознавайте сети по прямой диагностике и меняйте режим и группы в каждой.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage(
      "Режим подключения",
    ),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Выключено"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Сценарии"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "Сценарий управляет всем подключением. Нажмите на свой, чтобы изменить его, на любой другой — чтобы изменить копию.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Серверы"),
    "rcxServersMatch": m122,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("Шаблон имени"),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("Смарт-группы"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Встроенный"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "Исходный профиль изменился",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("Что изменилось"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("От провайдера"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Мои"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage(
      "Если сервер не подходит",
    ),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("Идти напрямую"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Оставить текущий сервер",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Переключения"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Имя тега"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Только латинские буквы, цифры, - и _, до 24 символов",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Теги"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "Тег один раз называет набор серверов, чтобы использовать его в предпочтениях как tag(name).",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("сторонний"),
    "rcxTier": MessageLookupByLibrary.simpleMessage("Предпочтение"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Метка"),
    "rcxTierWhen": MessageLookupByLibrary.simpleMessage(
      "Серверы в этом предпочтении",
    ),
    "rcxTiers": MessageLookupByLibrary.simpleMessage("Порядок предпочтений"),
    "rcxTiersHint": MessageLookupByLibrary.simpleMessage(
      "Сервер попадает в первое подходящее предпочтение; побеждает лучшее предпочтение, где есть серверы. Для смены порядка зажмите и перетащите.",
    ),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Авто-маршрут"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Переводы"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage(
      "Выключить авто-маршрут",
    ),
    "rcxUntilCheck": m123,
    "rcxUntilConfirm": m124,
    "rcxUntilDwell": m125,
    "rcxUseCheck": m126,
    "rcxUseDiagnostic": m127,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage(
      "проверка страны выхода",
    ),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Предупреждения"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Почему этот сервер"),
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
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
    "regionAppsPreview": m128,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр подбора",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS-серверы"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("MTU для TUN"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Проверки сервисов",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("Что изменится"),
    "regionChina": MessageLookupByLibrary.simpleMessage("Китай"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Значения, которые вы меняли сами, останутся как есть.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Египет"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Подбирает DNS-серверы, MTU для TUN, список обхода и проверки сервисов под вашу страну. Язык интерфейса не меняется.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Иран"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Настройки не изменятся.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Проверки сервисов отключены",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Не выбран"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Другая страна"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется для этого устройства",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Россия"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Подбор приложений по региону",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Сначала выберите поддерживаемый регион, чтобы использовать региональный подбор приложений.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Региональный профиль"),
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
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Продлить подписку",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Заменить"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Заменить все"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("Заголовки запроса"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Запросы и обновления",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Обязательно"),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetAllData": MessageLookupByLibrary.simpleMessage("Сбросить все данные"),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage("Удалить всё"),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "Все профили, настройки, скрипты, обои и кэш будут безвозвратно удалены. Архивы резервных копий сохранятся. После сброса приложение закроется. Это действие нельзя отменить.",
    ),
    "resetAllDataWait": m129,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На этой странице есть изменения. Вы уверены, что хотите выполнить сброс?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выполнить сброс?",
    ),
    "resettingAllData": MessageLookupByLibrary.simpleMessage(
      "Удаление данных…",
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
    "restoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Восстановить по умолчанию",
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
    "rulesCount": m130,
    "runTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "running": MessageLookupByLibrary.simpleMessage("Работает"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Конфигурация выполнения",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Безопасный режим"),
    "safeModeAppTitle": m131,
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
    "secondsCount": m132,
    "secretKey": MessageLookupByLibrary.simpleMessage("Ключ"),
    "sectionsInEffect": m133,
    "select": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Выберите набор правил",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Выберите стратегию распределения",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "send": MessageLookupByLibrary.simpleMessage("Отправить"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Отправить с телефона",
    ),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Импортировать ссылку с телефона?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Это устройство не подключено к локальной сети",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Ссылка на подписку или ссылка на прокси",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Отправлено. Подтвердите импорт на другом устройстве.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "Отправить ссылку в ReClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Чтобы получить ссылку с телефона, ReClash нужно разрешение «Устройства поблизости» для доступа к локальной сети. Включите его в настройках приложения.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте код камерой телефона и вставьте ссылку на открывшейся странице. Оба устройства должны быть в одной сети.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serviceAbnormalCount": m134,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("Все доступны"),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "Автоматически проверять активные",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage(
      "Проверять все",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Доступен"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Заблокировано"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Проверить все"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "Проверять только при подключении",
    ),
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
    "settingsCount": m135,
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
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Изменить настройки",
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
    "setupDirectApps": m136,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "Местные приложения не найдены. Сайты всё равно пойдут напрямую.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "Они будут работать без VPN. Список можно изменить позже в управлении доступом.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Ищем местные приложения…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Сервисы вашей страны откроются без сервера: быстрее, и банки или госсервисы не будут вас блокировать. В общие правила добавится:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Местные сайты и приложения — напрямую",
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
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash закроется. Выбор сохранится, и настройка продолжится при следующем запуске.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage(
      "Выйти из настройки?",
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
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Добавьте или выберите профиль, чтобы продолжить.",
    ),
    "setupProfileCount": m137,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash не предоставляет серверы. Добавьте подписку или конфигурацию вашего провайдера.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Импортировать профиль",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Добавить другой профиль",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте ссылку из письма, бота или личного кабинета провайдера либо выберите файл или QR-код.",
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
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Регион"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Рекомендуется"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Оставить настройки профиля",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Региональные настройки не меняются.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash подстроит DNS, MTU и прямые маршруты под сети вашей страны. Язык интерфейса не изменится.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Откуда вы подключаетесь?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "Если ничего не выбрать, текущие региональные настройки останутся прежними.",
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
    "setupStepStatus": m138,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Ваш выбор сохранён. Прежнее подключение не остановлено.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка остановлена",
    ),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Выберите другой охват: некоторые сети блокируют VPN.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что интернет работает без ReClash.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Обновите профиль или выберите другой сервер после настройки.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage(
      "Что можно попробовать",
    ),
    "setupTitle": MessageLookupByLibrary.simpleMessage("Первое подключение"),
    "setupTryServer": m139,
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
    "shareLinkUnreadable": m140,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать прокси из ссылок",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте в ReClash на другом устройстве, чтобы импортировать этот профиль.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Кнопка остановки в уведомлении",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Показать пароль"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Боковая панель"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Размытие боковой панели",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Размытие фона показывает рабочий стол за окном сквозь боковую панель.",
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
    "singleValueTip": m141,
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
      "Строгая маршрутизация не даёт трафику вроде DNS обходить TUN, а при выключенном IPv6 блокирует IPv6-соединения этого устройства.",
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
    "subscriptionCompatibilityPrepared": m142,
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
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Подписка истекла",
    ),
    "subscriptionExpiresInDays": m143,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Подписка истекает сегодня",
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
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "Многие подписки перестанут работать, если отключить отправку HWID.",
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
    "subscriptionImportAdd": m144,
    "subscriptionImportAllAdded": m145,
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
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "Разделы конфигурации",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "Вместо этих частей источника ReClash применит собственные настройки.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "Не переносится",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "Ни один сервер не поддерживается",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "Часть параметров серверов не поддерживается и будет опущена",
    ),
    "subscriptionImportPartial": m146,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "Не указаны скорости загрузки и отдачи",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "Протокол не поддерживается",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "Транспорт не поддерживается",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Больше не спрашивать для этой подписки",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Если перестанет переноситься что-то ещё, мы спросим снова.",
        ),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Перенесётся не всё",
    ),
    "subscriptionImportShowAll": m147,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "Не будут добавлены",
    ),
    "subscriptionImportSourceFormat": m148,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Информация о подписке",
    ),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("Разработка"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("Промо"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("Тестовая"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Напоминания о подписке",
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
    "subscriptionTrafficLow": m149,
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
    "toolsResults": m150,
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
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Докупить трафик"),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "total": MessageLookupByLibrary.simpleMessage("Всего"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Загружено"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Отдано"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficPeak": m151,
    "trafficTotal": m152,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Предложить правку перевода",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "transportHeaders": m153,
    "trayIcon": MessageLookupByLibrary.simpleMessage("Иконка в трее"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Цветная"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Чёрная"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("Белая"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Доверенные сети"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "В этих сетях VPN ставится на паузу",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Текущая сеть доверенная",
    ),
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
    "tunSetupApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "Разрешите помощник TUN",
    ),
    "tunSetupConfirm": MessageLookupByLibrary.simpleMessage("Настроить"),
    "tunSetupDone": MessageLookupByLibrary.simpleMessage("TUN включён"),
    "tunSetupInstallTitle": MessageLookupByLibrary.simpleMessage(
      "Настроить TUN",
    ),
    "tunSetupInstantStart": MessageLookupByLibrary.simpleMessage(
      "Дальше TUN включается сразу, в том числе при автозапуске",
    ),
    "tunSetupLater": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "tunSetupLinuxInstall": MessageLookupByLibrary.simpleMessage(
      "Чтобы TUN направлял через ReClash весь трафик системы, нужен системный помощник — служба systemd, которая запускает ядро только с сетевыми правами.",
    ),
    "tunSetupLinuxScope": MessageLookupByLibrary.simpleMessage(
      "Помощник запускает только проверенное ядро ReClash и даёт ему лишь сетевые права",
    ),
    "tunSetupLinuxUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash обновился, и помощнику TUN нужно обновиться вместе с ним, чтобы продолжить работу.",
    ),
    "tunSetupMacosInstall": MessageLookupByLibrary.simpleMessage(
      "Для TUN нужен помощник ReClash. macOS один раз попросит его разрешить.",
    ),
    "tunSetupOnceConfirm": MessageLookupByLibrary.simpleMessage(
      "Windows попросит подтверждение один раз для этой версии",
    ),
    "tunSetupOncePassword": MessageLookupByLibrary.simpleMessage(
      "Пароль администратора понадобится один раз для этой версии",
    ),
    "tunSetupPasswordPrivacy": MessageLookupByLibrary.simpleMessage(
      "Вводите пароль только в системном окне: ReClash его не видит.",
    ),
    "tunSetupUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "TUN недоступен",
    ),
    "tunSetupUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Обновить помощник TUN",
    ),
    "tunSetupWaiting": MessageLookupByLibrary.simpleMessage(
      "Ждём подтверждения в системном окне…",
    ),
    "tunSetupWindowsInstall": MessageLookupByLibrary.simpleMessage(
      "Чтобы TUN направлял через ReClash весь трафик системы, нужна служба ReClash Service — она запускает ядро с правами, которых требует сетевой адаптер.",
    ),
    "tunSetupWindowsScope": MessageLookupByLibrary.simpleMessage(
      "Служба запускает только проверенное ядро ReClash и принимает запросы только от вашей учётной записи",
    ),
    "tunSetupWindowsUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash обновился, и службе ReClash Service нужно обновиться вместе с ним, чтобы TUN продолжил работать.",
    ),
    "tunSetupWithoutTun": MessageLookupByLibrary.simpleMessage("Без TUN"),
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
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash сможет устанавливать проверенные стабильные обновления без нового запроса каждый раз. Ваш VPN не будет отключён. Android всё ещё может попросить подтвердить установку.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Разрешить автоматическую установку?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Устанавливать автоматически",
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
      "Не удалось проверить обновления",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Проверьте соединение и попробуйте ещё раз.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Проверка обновлений…",
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
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить обновление",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Загруженная часть сохранена. Проверьте соединение и продолжите загрузку.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Понятно"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить установщик пакетов",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android не завершил установку. Попробуйте ещё раз, когда будет удобно.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage(
      "Установить сейчас",
    ),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Обновление установлено",
    ),
    "updateInstalledVersion": m154,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android завершает установку. На этом этапе ReClash может закрыться.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Устанавливаем обновление",
    ),
    "updateMinutes": m155,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Описание изменений не опубликовано.",
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
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Пауза"),
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
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Настройки не сохранены. Попробуйте ещё раз; автоустановка не включена.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Настройки обновлений",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage("Загружать по Wi-Fi"),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Готово к установке",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Подробности релиза",
    ),
    "updateRemainingTime": m156,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Продолжить загрузку",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage(
      "Проверить ещё раз",
    ),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Повторить установку",
    ),
    "updateSeconds": m157,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Все примечания к релизу",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Показать все изменения",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Обновления"),
    "updateTransferSpeed": m158,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить целостность загруженного обновления.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Файл, версия или подпись не прошли проверку. Загрузите новую копию и попробуйте ещё раз.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Этот пакет нельзя установить",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Проверяем обновление",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Для установки ReClash ненадолго закроется. Отключайте VPN, только если готовы прервать соединение.",
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
      "Добавить URL подписки. Имя необязательно.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось подтвердить подлинность зашифрованной ссылки. Она может быть повреждена или использовать другой ключ.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Создать ссылку"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage(
      "Закрыть приложение",
    ),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Закрыть приложение согласно настройке закрытия.",
    ),
    "urlSchemeConfigCounts": m159,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте конфигурацию YAML или JSON",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Состав конфигурации",
    ),
    "urlSchemeConfirmMessage": m160,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Внешняя команда приложения",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "Команды подключения и закрытия из внешних ссылок требуют подтверждения.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Подключить"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Подключиться с выбранным профилем.",
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
      "Остановить подключение, не меняя профиль.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Встроенная конфигурация",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Пример профиля",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Форматы"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Форматы ссылок. Подставьте свой URL или данные.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Импортировать конфигурацию",
    ),
    "urlSchemeImportConfirm": m161,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Встроить конфигурацию YAML или JSON в ссылку.",
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
      "Создать ссылку подписки в формате клиентов Clash.",
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
      "Показать окно ReClash.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Параметры"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать буфер обмена. Вставьте ссылку вручную.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Ссылка"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Введите URL или конфигурацию, чтобы создать ссылку.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Ссылка может содержать токены или пароли. Делитесь осторожно.",
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
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Переключить подключение",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Подключиться, если выключено; отключиться, если работает.",
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
    "urlTip": m162,
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
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Положение по горизонтали",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Выберите корректное изображение PNG, JPEG или WebP.",
    ),
    "wallpaperImageLabel": m163,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Кадрирование"),
    "wallpaperLibraryFull": m164,
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
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Доступ"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Доступ к панели завершён",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "В приложении",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "В браузере",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("Выключен"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Доступ локальный и защищён секретом. Открытие панели не меняет сохранённые настройки внешнего контроллера.",
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
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Панель"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Установить панель",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "Выбранная панель загрузится при первом открытии. Используется закреплённый релиз с проверкой SHA-256.",
    ),
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
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "Доступ к панели отключён вашим провайдером.",
    ),
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
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Версия"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Записывать в систему",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "«Записывать в систему» также устанавливает системные часы; Android это игнорирует.",
    ),
    "yearsAgo": m165,
    "yearsAgoShort": m166,
    "yes": MessageLookupByLibrary.simpleMessage("Да"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
  };
}
