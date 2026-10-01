import 'package:material_ui/material_ui.dart';

/// Localized copy for [InitErrorScreen]. Kept self-contained instead of going
/// through [AppLocalizations], because the init failure that shows the screen
/// may be the localization load itself. [of] resolves by language code only
/// and falls back to English for locales without a translation here.
class InitErrorStrings {
  const InitErrorStrings({
    required this.cantStart,
    required this.intro,
    required this.recoverySteps,
    required this.suggested,
    required this.technicalDetails,
    required this.copy,
    required this.copied,
    required this.cancel,
    required this.continueLabel,
    required this.resetAction,
    required this.doneTitle,
    required this.restartDesktopTitle,
    required this.restartDesktopSubtitle,
    required this.restartMobileTitle,
    required this.restartMobileSubtitle,
    required this.resetPrefsTitle,
    required this.resetPrefsSubtitle,
    required this.resetConfigTitle,
    required this.resetConfigSubtitle,
    required this.openFolderTitle,
    required this.openFolderSubtitle,
    required this.factoryResetTitle,
    required this.factoryResetSubtitle,
    required this.confirmResetPrefsTitle,
    required this.confirmResetPrefsMessage,
    required this.confirmResetConfigTitle,
    required this.confirmResetConfigMessage,
    required this.confirmFactoryTitle,
    required this.confirmFactoryMessage,
    required this.doneRestartDesktop,
    required this.doneRestartMobile,
    required this.diagPrefsTitle,
    required this.diagPrefsDetail,
    required this.diagDbTitle,
    required this.diagDbDetail,
    required this.diagConfigTitle,
    required this.diagConfigDetail,
    required this.diagCoreTitle,
    required this.diagCoreDetail,
    required this.diagUnknownTitle,
    required this.diagUnknownDetail,
    required this.couldNotCompletePrefix,
    required this.couldNotOpenFolderPrefix,
  });

  final String cantStart;
  final String intro;
  final String recoverySteps;
  final String suggested;
  final String technicalDetails;
  final String copy;
  final String copied;
  final String cancel;
  final String continueLabel;
  final String resetAction;
  final String doneTitle;
  final String restartDesktopTitle;
  final String restartDesktopSubtitle;
  final String restartMobileTitle;
  final String restartMobileSubtitle;
  final String resetPrefsTitle;
  final String resetPrefsSubtitle;
  final String resetConfigTitle;
  final String resetConfigSubtitle;
  final String openFolderTitle;
  final String openFolderSubtitle;
  final String factoryResetTitle;
  final String factoryResetSubtitle;
  final String confirmResetPrefsTitle;
  final String confirmResetPrefsMessage;
  final String confirmResetConfigTitle;
  final String confirmResetConfigMessage;
  final String confirmFactoryTitle;
  final String confirmFactoryMessage;
  final String doneRestartDesktop;
  final String doneRestartMobile;
  final String diagPrefsTitle;
  final String diagPrefsDetail;
  final String diagDbTitle;
  final String diagDbDetail;
  final String diagConfigTitle;
  final String diagConfigDetail;
  final String diagCoreTitle;
  final String diagCoreDetail;
  final String diagUnknownTitle;
  final String diagUnknownDetail;
  final String couldNotCompletePrefix;
  final String couldNotOpenFolderPrefix;

  static InitErrorStrings of(Locale? locale) {
    switch (locale?.languageCode) {
      case 'ru':
        return ru;
      case 'zh':
        return zh;
      case 'ja':
        return ja;
      case 'ko':
        return ko;
      default:
        return en;
    }
  }

  /// Languages the screen can switch to on demand, each with its own autonym.
  /// Only locales with a real translation here are listed; everything else
  /// resolves to English through [of] and would be a no-op choice.
  static const List<(Locale, String)> languages = [
    (Locale('en'), 'English'),
    (Locale('ru'), 'Русский'),
    (Locale('zh', 'CN'), '中文'),
    (Locale('ja'), '日本語'),
    (Locale('ko'), '한국어'),
  ];

  static const InitErrorStrings en = InitErrorStrings(
    cantStart: "ReClash couldn't start",
    intro:
        'Something went wrong while loading. You can usually fix it right here, without reinstalling the app.',
    recoverySteps: 'Recovery steps',
    suggested: 'Suggested',
    technicalDetails: 'Technical details',
    copy: 'Copy',
    copied: 'Error details copied to clipboard',
    cancel: 'Cancel',
    continueLabel: 'Continue',
    resetAction: 'Reset',
    doneTitle: 'Done',
    restartDesktopTitle: 'Restart ReClash',
    restartDesktopSubtitle: 'Relaunch the app and try a clean start.',
    restartMobileTitle: 'Close ReClash',
    restartMobileSubtitle:
        'Close the app, then open it again to retry a clean start.',
    resetPrefsTitle: 'Reset app settings',
    resetPrefsSubtitle:
        'Clears the settings and cache file. Profiles and subscriptions are kept.',
    resetConfigTitle: 'Reset network config',
    resetConfigSubtitle:
        'Removes the generated config. It is rebuilt on the next launch.',
    openFolderTitle: 'Open data folder',
    openFolderSubtitle: 'Inspect or back up your files before a reset.',
    factoryResetTitle: 'Factory reset',
    factoryResetSubtitle:
        'Removes all profiles and settings but keeps ReClash installed. Last resort.',
    confirmResetPrefsTitle: 'Reset app settings?',
    confirmResetPrefsMessage:
        'This deletes the settings and cache file. Your profiles and subscriptions are not affected.',
    confirmResetConfigTitle: 'Reset network config?',
    confirmResetConfigMessage:
        'This deletes the generated network configuration. ReClash rebuilds it on the next launch.',
    confirmFactoryTitle: 'Factory reset?',
    confirmFactoryMessage:
        'This permanently removes ALL profiles, subscriptions and settings. ReClash stays installed. This cannot be undone.',
    doneRestartDesktop: 'The fix was applied. Restart ReClash to try again.',
    doneRestartMobile:
        'The fix was applied. Close ReClash now, then open it again.',
    diagPrefsTitle: 'Settings file looks corrupted',
    diagPrefsDetail:
        'A broken settings or cache file is the usual cause. Resetting app settings clears it and keeps your profiles and subscriptions.',
    diagDbTitle: 'Profile storage failed to open',
    diagDbDetail:
        'The profile database could not be opened or migrated. A factory reset rebuilds it, but your profiles are removed in the process.',
    diagConfigTitle: 'Network config failed to load',
    diagConfigDetail:
        'The generated network configuration could not be read. Rebuilding it on the next launch usually fixes this.',
    diagCoreTitle: 'The core engine could not start',
    diagCoreDetail:
        'The bundled core failed to prepare its working copy. Restarting ReClash lets it extract a fresh one.',
    diagUnknownTitle: 'ReClash stopped during startup',
    diagUnknownDetail:
        'It hit an error before finishing load. The steps below go from safest to last resort, so start at the top.',
    couldNotCompletePrefix: 'Could not complete: ',
    couldNotOpenFolderPrefix: 'Could not open folder: ',
  );

  static const InitErrorStrings ru = InitErrorStrings(
    cantStart: 'Не удалось запустить ReClash',
    intro:
        'При загрузке возникла ошибка. Обычно её можно исправить прямо здесь, без переустановки приложения.',
    recoverySteps: 'Шаги восстановления',
    suggested: 'Рекомендуется',
    technicalDetails: 'Технические подробности',
    copy: 'Копировать',
    copied: 'Сведения об ошибке скопированы в буфер обмена',
    cancel: 'Отмена',
    continueLabel: 'Продолжить',
    resetAction: 'Сбросить',
    doneTitle: 'Готово',
    restartDesktopTitle: 'Перезапустить ReClash',
    restartDesktopSubtitle:
        'Перезапустить приложение и попробовать чистый старт.',
    restartMobileTitle: 'Закрыть ReClash',
    restartMobileSubtitle:
        'Закройте приложение и откройте снова для чистого запуска.',
    resetPrefsTitle: 'Сбросить настройки приложения',
    resetPrefsSubtitle:
        'Удаляет файл настроек и кэша. Профили и подписки сохранятся.',
    resetConfigTitle: 'Сбросить сетевой конфиг',
    resetConfigSubtitle:
        'Удаляет сгенерированный конфиг. Он пересоздастся при следующем запуске.',
    openFolderTitle: 'Открыть папку данных',
    openFolderSubtitle:
        'Просмотрите или сделайте резервную копию файлов перед сбросом.',
    factoryResetTitle: 'Сброс к заводским',
    factoryResetSubtitle:
        'Удаляет все профили и настройки, но приложение остаётся установленным. Крайняя мера.',
    confirmResetPrefsTitle: 'Сбросить настройки приложения?',
    confirmResetPrefsMessage:
        'Будет удалён файл настроек и кэша. Профили и подписки не затрагиваются.',
    confirmResetConfigTitle: 'Сбросить сетевой конфиг?',
    confirmResetConfigMessage:
        'Будет удалён сгенерированный сетевой конфиг. ReClash пересоздаст его при следующем запуске.',
    confirmFactoryTitle: 'Сброс к заводским настройкам?',
    confirmFactoryMessage:
        'Будут безвозвратно удалены ВСЕ профили, подписки и настройки. ReClash останется установленным. Это действие необратимо.',
    doneRestartDesktop:
        'Исправление применено. Перезапустите ReClash, чтобы попробовать снова.',
    doneRestartMobile:
        'Исправление применено. Закройте ReClash и откройте снова.',
    diagPrefsTitle: 'Файл настроек повреждён',
    diagPrefsDetail:
        'Чаще всего причина — повреждённый файл настроек или кэша. Сброс настроек приложения очистит его, сохранив профили и подписки.',
    diagDbTitle: 'Не удалось открыть хранилище профилей',
    diagDbDetail:
        'База данных профилей не открылась или не прошла миграцию. Сброс к заводским пересоздаст её, но профили будут удалены.',
    diagConfigTitle: 'Не удалось загрузить сетевой конфиг',
    diagConfigDetail:
        'Не удалось прочитать сгенерированный сетевой конфиг. Обычно помогает его пересоздание при следующем запуске.',
    diagCoreTitle: 'Не удалось запустить ядро',
    diagCoreDetail:
        'Встроенному ядру не удалось подготовить рабочую копию. Перезапуск ReClash позволит извлечь новую.',
    diagUnknownTitle: 'ReClash остановился при запуске',
    diagUnknownDetail:
        'Ошибка возникла до завершения загрузки. Шаги ниже идут от самого безопасного к крайнему — начните сверху.',
    couldNotCompletePrefix: 'Не удалось выполнить: ',
    couldNotOpenFolderPrefix: 'Не удалось открыть папку: ',
  );

  static const InitErrorStrings zh = InitErrorStrings(
    cantStart: 'ReClash 无法启动',
    intro: '加载时出现问题。通常无需重新安装，即可在此修复。',
    recoverySteps: '恢复步骤',
    suggested: '建议',
    technicalDetails: '技术详情',
    copy: '复制',
    copied: '错误详情已复制到剪贴板',
    cancel: '取消',
    continueLabel: '继续',
    resetAction: '重置',
    doneTitle: '完成',
    restartDesktopTitle: '重启 ReClash',
    restartDesktopSubtitle: '重新启动应用并尝试全新启动。',
    restartMobileTitle: '关闭 ReClash',
    restartMobileSubtitle: '关闭应用后再次打开，重试全新启动。',
    resetPrefsTitle: '重置应用设置',
    resetPrefsSubtitle: '清除设置和缓存文件。配置文件和订阅将保留。',
    resetConfigTitle: '重置网络配置',
    resetConfigSubtitle: '删除生成的配置，下次启动时会重建。',
    openFolderTitle: '打开数据文件夹',
    openFolderSubtitle: '在重置前查看或备份文件。',
    factoryResetTitle: '恢复出厂设置',
    factoryResetSubtitle: '删除所有配置文件和设置，但保留 ReClash 的安装。最后手段。',
    confirmResetPrefsTitle: '重置应用设置？',
    confirmResetPrefsMessage: '这将删除设置和缓存文件。不会影响你的配置文件和订阅。',
    confirmResetConfigTitle: '重置网络配置？',
    confirmResetConfigMessage: '这将删除生成的网络配置。ReClash 会在下次启动时重建。',
    confirmFactoryTitle: '恢复出厂设置？',
    confirmFactoryMessage: '这将永久删除所有配置文件、订阅和设置。ReClash 仍保持安装。此操作无法撤消。',
    doneRestartDesktop: '修复已应用。请重启 ReClash 再试。',
    doneRestartMobile: '修复已应用。请关闭 ReClash 后再次打开。',
    diagPrefsTitle: '设置文件似乎已损坏',
    diagPrefsDetail: '最常见的原因是设置或缓存文件损坏。重置应用设置可清除它，并保留你的配置文件和订阅。',
    diagDbTitle: '无法打开配置文件存储',
    diagDbDetail: '配置文件数据库无法打开或迁移。恢复出厂设置会重建它，但你的配置文件将被删除。',
    diagConfigTitle: '无法加载网络配置',
    diagConfigDetail: '无法读取生成的网络配置。通常在下次启动时重建即可修复。',
    diagCoreTitle: '核心引擎无法启动',
    diagCoreDetail: '内置核心无法准备其工作副本。重启 ReClash 可让其重新提取。',
    diagUnknownTitle: 'ReClash 在启动时停止',
    diagUnknownDetail: '它在完成加载前遇到错误。以下步骤从最安全到最后手段，请从顶部开始。',
    couldNotCompletePrefix: '无法完成：',
    couldNotOpenFolderPrefix: '无法打开文件夹：',
  );

  static const InitErrorStrings ja = InitErrorStrings(
    cantStart: 'ReClash を起動できませんでした',
    intro: '読み込み中に問題が発生しました。多くの場合、再インストールせずにここで修復できます。',
    recoverySteps: '復旧の手順',
    suggested: '推奨',
    technicalDetails: '技術的な詳細',
    copy: 'コピー',
    copied: 'エラーの詳細をクリップボードにコピーしました',
    cancel: 'キャンセル',
    continueLabel: '続行',
    resetAction: 'リセット',
    doneTitle: '完了',
    restartDesktopTitle: 'ReClash を再起動',
    restartDesktopSubtitle: 'アプリを再起動してクリーンな状態で試します。',
    restartMobileTitle: 'ReClash を閉じる',
    restartMobileSubtitle: 'アプリを閉じてから再度開き、クリーンな起動を試します。',
    resetPrefsTitle: 'アプリ設定をリセット',
    resetPrefsSubtitle: '設定とキャッシュファイルを削除します。プロファイルとサブスクリプションは保持されます。',
    resetConfigTitle: 'ネットワーク設定をリセット',
    resetConfigSubtitle: '生成された設定を削除します。次回起動時に再構築されます。',
    openFolderTitle: 'データフォルダーを開く',
    openFolderSubtitle: 'リセット前にファイルを確認またはバックアップします。',
    factoryResetTitle: '初期化',
    factoryResetSubtitle: 'すべてのプロファイルと設定を削除しますが、ReClash はインストールされたままです。最終手段です。',
    confirmResetPrefsTitle: 'アプリ設定をリセットしますか？',
    confirmResetPrefsMessage: '設定とキャッシュファイルを削除します。プロファイルとサブスクリプションには影響しません。',
    confirmResetConfigTitle: 'ネットワーク設定をリセットしますか？',
    confirmResetConfigMessage: '生成されたネットワーク設定を削除します。ReClash は次回起動時に再構築します。',
    confirmFactoryTitle: '初期化しますか？',
    confirmFactoryMessage:
        'すべてのプロファイル、サブスクリプション、設定が完全に削除されます。ReClash はインストールされたままです。この操作は取り消せません。',
    doneRestartDesktop: '修復を適用しました。ReClash を再起動して再試行してください。',
    doneRestartMobile: '修復を適用しました。ReClash を閉じてから再度開いてください。',
    diagPrefsTitle: '設定ファイルが破損している可能性があります',
    diagPrefsDetail:
        '設定またはキャッシュファイルの破損が主な原因です。アプリ設定をリセットすると解消され、プロファイルとサブスクリプションは保持されます。',
    diagDbTitle: 'プロファイルの保存領域を開けませんでした',
    diagDbDetail: 'プロファイルのデータベースを開けないか、移行できませんでした。初期化で再構築されますが、プロファイルは削除されます。',
    diagConfigTitle: 'ネットワーク設定を読み込めませんでした',
    diagConfigDetail: '生成されたネットワーク設定を読み取れませんでした。通常は次回起動時の再構築で解決します。',
    diagCoreTitle: 'コアエンジンを起動できませんでした',
    diagCoreDetail: '内蔵コアが作業用コピーを準備できませんでした。ReClash を再起動すると新しく展開されます。',
    diagUnknownTitle: 'ReClash が起動中に停止しました',
    diagUnknownDetail: '読み込みの完了前にエラーが発生しました。以下の手順は安全なものから最終手段の順です。上から始めてください。',
    couldNotCompletePrefix: '完了できませんでした: ',
    couldNotOpenFolderPrefix: 'フォルダーを開けませんでした: ',
  );

  static const InitErrorStrings ko = InitErrorStrings(
    cantStart: 'ReClash를 시작할 수 없습니다',
    intro: '로드 중 문제가 발생했습니다. 대부분 재설치 없이 여기에서 바로 복구할 수 있습니다.',
    recoverySteps: '복구 단계',
    suggested: '권장',
    technicalDetails: '기술 세부정보',
    copy: '복사',
    copied: '오류 세부정보를 클립보드에 복사했습니다',
    cancel: '취소',
    continueLabel: '계속',
    resetAction: '초기화',
    doneTitle: '완료',
    restartDesktopTitle: 'ReClash 다시 시작',
    restartDesktopSubtitle: '앱을 다시 실행하여 깨끗한 상태로 시작합니다.',
    restartMobileTitle: 'ReClash 닫기',
    restartMobileSubtitle: '앱을 닫은 뒤 다시 열어 깨끗한 시작을 시도합니다.',
    resetPrefsTitle: '앱 설정 초기화',
    resetPrefsSubtitle: '설정 및 캐시 파일을 지웁니다. 프로필과 구독은 유지됩니다.',
    resetConfigTitle: '네트워크 구성 초기화',
    resetConfigSubtitle: '생성된 구성을 삭제합니다. 다음 실행 시 다시 만들어집니다.',
    openFolderTitle: '데이터 폴더 열기',
    openFolderSubtitle: '초기화 전에 파일을 확인하거나 백업하세요.',
    factoryResetTitle: '공장 초기화',
    factoryResetSubtitle: '모든 프로필과 설정을 삭제하지만 ReClash 설치는 유지됩니다. 최후의 수단입니다.',
    confirmResetPrefsTitle: '앱 설정을 초기화할까요?',
    confirmResetPrefsMessage: '설정 및 캐시 파일을 삭제합니다. 프로필과 구독에는 영향을 주지 않습니다.',
    confirmResetConfigTitle: '네트워크 구성을 초기화할까요?',
    confirmResetConfigMessage: '생성된 네트워크 구성을 삭제합니다. ReClash가 다음 실행 시 다시 만듭니다.',
    confirmFactoryTitle: '공장 초기화할까요?',
    confirmFactoryMessage:
        '모든 프로필, 구독, 설정이 영구적으로 삭제됩니다. ReClash 설치는 유지됩니다. 이 작업은 되돌릴 수 없습니다.',
    doneRestartDesktop: '수정이 적용되었습니다. ReClash를 다시 시작하여 재시도하세요.',
    doneRestartMobile: '수정이 적용되었습니다. ReClash를 닫은 뒤 다시 여세요.',
    diagPrefsTitle: '설정 파일이 손상된 것 같습니다',
    diagPrefsDetail:
        '설정 또는 캐시 파일 손상이 일반적인 원인입니다. 앱 설정을 초기화하면 해결되며 프로필과 구독은 유지됩니다.',
    diagDbTitle: '프로필 저장소를 열지 못했습니다',
    diagDbDetail:
        '프로필 데이터베이스를 열거나 마이그레이션하지 못했습니다. 공장 초기화로 다시 만들어지지만 프로필은 삭제됩니다.',
    diagConfigTitle: '네트워크 구성을 불러오지 못했습니다',
    diagConfigDetail: '생성된 네트워크 구성을 읽지 못했습니다. 보통 다음 실행 시 다시 만들면 해결됩니다.',
    diagCoreTitle: '코어 엔진을 시작하지 못했습니다',
    diagCoreDetail: '내장 코어가 작업 복사본을 준비하지 못했습니다. ReClash를 다시 시작하면 새로 추출됩니다.',
    diagUnknownTitle: 'ReClash가 시작 중 중단되었습니다',
    diagUnknownDetail:
        '로드를 마치기 전에 오류가 발생했습니다. 아래 단계는 가장 안전한 것부터 최후의 수단 순입니다. 맨 위부터 시작하세요.',
    couldNotCompletePrefix: '완료하지 못했습니다: ',
    couldNotOpenFolderPrefix: '폴더를 열지 못했습니다: ',
  );
}
