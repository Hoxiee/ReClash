# Манифест снимков экрана

Изображения для документации редактора находятся в этой папке под именами `images/<id>.png`. В тексте страницы каждый маркер содержит `Screenshot <id>`; таблица ниже задаёт, каким должен быть снимок.

## Демонстрационная настройка

Используйте одну и ту же настройку для всех снимков.

- Подписка «Demo» с серверами: 🇳🇴 Oslo 1, 🇳🇴 Oslo 2, 🇳🇴 Oslo 3, 🇸🇪 Stockholm 1, 🇸🇪 Stockholm 2, 🇷🇺 Moscow ⚡ 1, 🇷🇺 Moscow ⚡ 2, *Premium NL, 🇩🇪 Frankfurt.
- Пользовательский сценарий «My split» запущен, маршруты:
  - основной трафик (весь остальной): страна Norway;
  - ▶️ YouTube: шаги «⚡ RU», затем любой работающий сервер;
  - 🤖 Claude: страна Sweden;
  - ✨ Gemini: шаг «Имя содержит `*`»;
  - 🏠 Local: Direct, категория сайта `category-ru` и домен с поддоменами `yandex.ru`.
- Подключение в режиме rule, светлая тема, разрешение 412×915, если для строки не указано иное.
- В библиотеке профилей групп находятся встроенные профили и один пользовательский.

## Снимки экрана

| id | Файл | Страница | Что должно быть показано | Как открыть |
| --- | --- | --- | --- | --- |
| editor-map | images/editor-map.png | editor/README.md | Три точки входа рядом: центр (вкладка Overview), лист группы из Proxies и редактор маршрута; стрелки показывают переходы; светлая тема, 412×915. | Композиция из трёх экранов: hub-overview, group-sheet-auto, route-editor. |
| group-sheet-auto | images/group-sheet-auto.png | editor/groups.md | Лист основной группы в режиме Auto: карточка состояния, Control, чипы Change to, Behaviour; светлая тема, 412×915. | Proxies → основная группа → лист авто-маршрутизации. |
| group-intro | images/group-intro.png | editor/groups.md | Лист группы без авто-маршрутизации с кнопкой Turn on auto routing; светлая тема, 412×915. | Лист обычной группы, ещё не ставшей умной. |
| group-sheet-pinned | images/group-sheet-pinned.png | editor/groups.md | Control в режиме Pinned и текст «Holding the pinned server» на карточке состояния; светлая тема, 412×915. | Лист группы → Control → Pinned. |
| group-change-to | images/group-change-to.png | editor/groups.md | Change to с чипами Any, 🇳🇴, 🇸🇪, 🇷🇺 и одним пользовательским шаблоном; светлая тема, 412×915. | Лист группы → Change to. |
| group-behaviour | images/group-behaviour.png | editor/groups.md | Раздел Behaviour с профилем Fastest, сводкой Server order и строкой настроек; светлая тема, 412×915. | Лист группы → Behaviour. |
| group-settings | images/group-settings.png | editor/groups.md | Страница настроек: Name pattern «4 of 5 match», Switching Balanced, Checks Economical и переключатель прямых сайтов; светлая тема, 412×915. | Лист группы → строка настроек. |
| group-why | images/group-why.png | editor/groups.md | Развёрнутый раздел Why this server с пятью строками, включая «Skipped after Change server»; светлая тема, 412×915. | Лист группы → Why this server. |
| group-history | images/group-history.png | editor/groups.md | Развёрнутая History с аварийным переключением и закреплением; светлая тема, 412×915. | Лист группы → History. |
| group-consent | images/group-consent.png | editor/groups.md | Раздел Permission needed со списком узлов и строкой Allow; светлая тема, 412×915. | Лист группы с профилем, требующим согласия. |
| group-route | images/group-route.png | editor/groups.md | Лист группы «▶️ YouTube» с разделом Made by a route; светлая тема, 412×915. | Proxies → группа маршрута YouTube → лист авто-маршрутизации. |
| hub-menu | images/hub-menu.png | editor/hub.md | Верхняя панель центра с открытым меню New scenario, New profile и Import; светлая тема, 412×915. | Advanced configuration → Auto routing → меню с тремя точками. |
| hub-overview | images/hub-overview.png | editor/hub.md | Overview с включённой авто-маршрутизацией и сценарием My split, строкой состояния, Routes, Smart groups и итогом энергопотребления; светлая тема, 412×915. | Auto routing → Overview, активен My split. |
| hub-no-subscription | images/hub-no-subscription.png | editor/hub.md | Вкладка Overview в состоянии No subscription; светлая тема, 412×915. | Удалить выбранный профиль и открыть Auto routing. |
| hub-overview-off | images/hub-overview-off.png | editor/hub.md | Overview с выключенным общим переключателем и подсказкой; светлая тема, 412×915. | Auto routing → Overview с выключенным переключателем. |
| scenario-chooser | images/scenario-chooser.png | editor/hub.md | Лист сценариев с разделами Mine, From provider и Built-in, заголовками и описаниями; выбран My split; светлая тема, 412×915. | Overview → Change. |
| hub-groups-energy | images/hub-groups-energy.png | editor/hub.md | Несколько строк Smart groups и итог «Checks today»; светлая тема, 412×915. | Overview → прокрутить до Smart groups после проверок. |
| hub-routes | images/hub-routes.png | editor/hub.md | Вкладка Routes сценария My split: четыре маршрута, Add route, Everything else, Other groups, Networks; светлая тема, 412×915. | Auto routing → Routes. |
| hub-routes-off | images/hub-routes-off.png | editor/hub.md | Routes с сообщением No scenario is running и кнопкой Start a scenario; светлая тема, 412×915. | Выключить авто-маршрутизацию и открыть Routes. |
| hub-routes-rule-only | images/hub-routes-rule-only.png | editor/hub.md | Внизу Routes показано предупреждение о rule mode при подключении в global; светлая тема, 412×915. | Переключить подключение в global и открыть Routes. |
| hub-routes-reorder | images/hub-routes-reorder.png | editor/hub.md | Список Routes в режиме сортировки с ручками перетаскивания; светлая тема, 412×915. | Routes → кнопка сортировки в заголовке. |
| hub-everything-else | images/hub-everything-else.png | editor/hub.md | Строка Everything else и редактор с шагом «Country Norway»; светлая тема, 412×915. | Routes → Everything else. |
| hub-other-groups | images/hub-other-groups.png | editor/hub.md | Другие группы: одна строка Every group и меню Add group; светлая тема, 412×915. | Routes → Other groups → Add group. |
| hub-networks | images/hub-networks.png | editor/hub.md | Развёрнутый раздел Networks с Connection mode, типом сети, Tags и Advanced; светлая тема, 412×915. | Routes → развернуть Mode and networks. |
| copy-dialog | images/copy-dialog.png | editor/hub.md | Диалог Make your own copy? с кнопкой Make a copy; светлая тема, 412×915. | Запустить встроенный сценарий и добавить маршрут. |
| hub-library | images/hub-library.png | editor/hub.md | Вкладка Library, фильтр Scenarios, карточки с метками Built-in, From provider, Mine; выбран My split; светлая тема, 412×915. | Auto routing → Library. |
| library-menu | images/library-menu.png | editor/hub.md | Карточка Mine с открытым меню Edit, Duplicate and edit, Export, Delete; светлая тема, 412×915. | Library → долго нажать Mine-карточку. |
| scenario-editor | images/scenario-editor.png | editor/hub.md | Редактор My split с заголовком, описанием, маршрутами и меню YAML; светлая тема, 412×915. | Library → My split. |
| route-delete-menu | images/route-delete-menu.png | editor/hub.md | Контекстное меню маршрута с Edit и Delete; светлая тема, 412×915. | Routes → долго нажать маршрут. |
| walk-1-empty | images/walk-1-empty.png | editor/hub.md | Вкладка Routes с сообщением No scenario is running; светлая тема, 412×915. | Открыть Routes без активного сценария. |
| walk-2-youtube-step | images/walk-2-youtube-step.png | editor/hub.md | Редактор шага с Name contains «⚡ RU» и строкой «N servers fit now»; светлая тема, 412×915. | Routes → Add route → YouTube → Next → Add a step. |
| walk-3-done | images/walk-3-done.png | editor/hub.md | Routes с четырьмя маршрутами и Everything else через Norway; светлая тема, 412×915. | Вкладка Routes после пошаговой настройки из hub.md. |
| route-traffic-picker | images/route-traffic-picker.png | editor/routes.md | Страница New route с выбранными YouTube и Gemini и разделом Custom; светлая тема, 412×915. | Routes → Add route. |
| route-entry-form | images/route-entry-form.png | editor/routes.md | Форма записи, тип Site category, некорректное значение и сообщение Invalid value; светлая тема, 412×915. | Add route → Add entry. |
| route-editor | images/route-editor.png | editor/routes.md | Редактор ▶️ YouTube: имя, «YouTube · 2 more», Send through = Auto, порядок серверов, поведение; светлая тема, 412×915. | Routes → нажать YouTube. |
| route-editor-fixed | images/route-editor-fixed.png | editor/routes.md | Маршрут One server и строка Server с выбором 🇳🇴 Oslo 1; светлая тема, 412×915. | Route editor → Send through → One server. |
| route-behaviour | images/route-behaviour.png | editor/routes.md | Страница Behaviour с Built-in, From provider, User и описанием внизу; светлая тема, 412×915. | Route editor → Behaviour. |
| route-pool | images/route-pool.png | editor/routes.md | Для группового правила строка Leave out содержит «name contains …», ниже строка Use; светлая тема, 412×915. | Route editor → Leave out. |
| route-editor-ladder | images/route-editor-ladder.png | editor/routes.md | Server order с шагами «⚡ RU» и «Any working server», связью, подписью «if none of them works» и кнопкой Add a step; светлая тема, 412×915. | Прокрутить Route editor до Server order. |
| ladder-step-editor | images/ladder-step-editor.png | editor/routes.md | Редактор шага: Name contains «⚡ RU», Country, Add condition и «2 servers fit now»; светлая тема, 412×915. | Server order → открыть или добавить шаг. |
| country-picker | images/country-picker.png | editor/routes.md | Choose countries: On your servers (Norway 3 servers verified, Sweden 2, Russia 2) и All countries; светлая тема, 412×915. | Step editor → Country. |
| condition-builder | images/condition-builder.png | editor/routes.md | Конструктор Match = All conditions с условиями «Country is one of Norway, Sweden» и «Latency is under 300»; светлая тема, 412×915. | Route editor → Leave out или step editor → Advanced condition. |
| condition-text | images/condition-text.png | editor/routes.md | Раздел As text с баннером ошибки разбора; светлая тема, 412×915. | Condition builder → As text и намеренная синтаксическая ошибка. |
| export-sheet | images/export-sheet.png | editor/sharing.md | Лист экспорта с тремя действиями; светлая тема, 412×915. | Library → долго нажать карточку → Export. |
| import-page | images/import-page.png | editor/sharing.md | Страница Import routing profile для одного сценария с заголовком, источником и описанием; светлая тема, 412×915. | Меню центра → Import → вставить ссылку сценария. |
| import-bundle | images/import-bundle.png | editor/sharing.md | Страница импорта пакета с одним сценарием и двумя профилями; светлая тема, 412×915. | Импортировать ссылку на пакет. |
| import-problems | images/import-problems.png | editor/sharing.md | Страница импорта с баннером ошибки и неактивным сохранением; светлая тема, 412×915. | Импортировать повреждённый файл. |
| studio-form | images/studio-form.png | editor/studio.md | Студия в режиме формы: General, Servers, Server order, Tags, Behaviour; светлая тема, 412×915. | Library → Group profiles → пользовательский профиль. |
| studio-yaml | images/studio-yaml.png | editor/studio.md | YAML-редактор текста профиля; светлая тема, 412×915. | Studio → меню → YAML. |
| studio-warnings | images/studio-warnings.png | editor/studio.md | Предупреждения: шаг повторяет раннее условие, метка не используется; светлая тема, 412×915. | Студия с перекрытым шагом и неиспользуемой меткой. |
| studio-check | images/studio-check.png | editor/studio.md | Проверка для Proxy: «Would pick 🇳🇴 Oslo 1 instead of 🇸🇪 Stockholm 1»; светлая тема, 412×915. | Studio → Check → Against group. |
| studio-merge | images/studio-merge.png | editor/studio.md | Раздел The original profile changed с двумя строками; светлая тема, 412×915. | Студия копии, оригинал которой изменился. |
| studio-restore | images/studio-restore.png | editor/studio.md | Лист Earlier versions с отметками времени; светлая тема, 412×915. | Studio → меню → Earlier versions. |
| cookbook-routes-hub | images/cookbook-routes-hub.png | cookbook.md | Routes с YouTube, Claude, Gemini, Local; у каждого текущий сервер и шаг; светлая тема, 412×915. | Advanced configuration → Auto routing → Routes, активен сценарий разделения. |
| cookbook-ladder-ranking | images/cookbook-ladder-ranking.png | cookbook.md | Объяснение группы с рейтингом по Starred, Finland, Anything; текущий сервер отмечен; светлая тема, 412×915. | Proxies → группа → авто-маршрутизация → Why this server. |
| cookbook-pin-control | images/cookbook-pin-control.png | cookbook.md | Лист группы с Auto, Pinned, Manual; Pinned выбран, сервер выделен; светлая тема, 412×915. | Proxies → группа → авто-маршрутизация после ручного выбора сервера. |
| cookbook-bundle-import | images/cookbook-bundle-import.png | cookbook.md | Проверка импорта: один сценарий, один профиль и их итоговые имена; светлая тема, 412×915. | Меню центра → Import → пакет Streaming. |
