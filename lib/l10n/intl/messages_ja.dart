// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(value) => "Off (suggested ${value})";

  static String m1(time) => "DPI バイパス中 ${time}";

  static String m2(time) => "接続時間 ${time}";

  static String m3(code) =>
      "Windows が ReClashCore.exe の実行を拒否しました（エラー ${code}）。スマート アプリ コントロールや AppLocker などのアプリ制御ポリシーは未署名のプログラムをブロックします。ポリシーで ReClash を許可するか、ポリシーを無効にしてから再試行してください。";

  static String m4(name) =>
      "アプリの起動が2回連続で完了しませんでした。クラッシュループを断ち切るため、プロファイル ${name} の選択を解除し、今回の自動セットアップをスキップしました。いつでも選択し直せます。";

  static String m5(url) => "${url} からプロファイルを作成しますか？";

  static String m6(date, days) => "${date} から · 稼働 ${days} 日";

  static String m7(count) => "${count} 日前";

  static String m8(count) => "${count} 日";

  static String m9(label) => "選択した${label}を削除してもよろしいですか？";

  static String m10(label) => "この${label}を削除してもよろしいですか？";

  static String m11(token) => "${token} はアプリが設定するため除外されます";

  static String m12(count) => "${Intl.plural(count, other: '${count} 個の引数')}";

  static String m13(token) => "${token} には値が必要です";

  static String m14(token) => "${token} はオプションではありません";

  static String m15(token) => "不明なオプション ${token}";

  static String m16(count) => "${count} 個のルーティングカテゴリが ByeDPI エンジンを使用";

  static String m17(passed, total) => "ラダー結果: ${passed}/${total}";

  static String m18(presets, groups, domains) =>
      "${presets} プリセット · ${groups} グループ · ${domains} ホスト";

  static String m19(count) => "${Intl.plural(count, other: '${count} 個のドメイン')}";

  static String m20(count) => "完了: ${count} 個のストラテジーをテストしました";

  static String m21(count) =>
      "エンジンを通して ${count} 個のホストへ全ストラテジーを試します。終了後に現在のストラテジーへ戻します";

  static String m22(index, total) => "テスト中 ${index} / ${total}";

  static String m23(passed, total) => "${total} ホスト中 ${passed} が応答";

  static String m24(label) => "${label}の詳細";

  static String m25(days) => "${days} 日";

  static String m26(name) => "${name} をインストールしました";

  static String m27(count) => "高負荷により ${count} 件の証拠を破棄しました。確度は上げていません。";

  static String m28(completed, total) => "接続を確認中：${completed}/${total}";

  static String m29(layer) => "接続の問題：${layer}";

  static String m30(completed, total) => "${total} ステップ中 ${completed}";

  static String m31(label) => "${label}は空にできません";

  static String m32(count) => "${count} 件";

  static String m33(label) => "${label}はすでに存在します";

  static String m34(action) => "外部リンクによる「${action}」の実行を許可しますか？";

  static String m35(date) => "${date} に発見";

  static String m36(found, total) => "${total} 件中 ${found} 件を発見";

  static String m37(count) => "未発見が ${count} 件";

  static String m38(days) => "次の刻みまであと ${days} 日";

  static String m39(name) => "${name} はすでに最新です";

  static String m40(name) => "${name} を更新しました";

  static String m41(time) => "${time}前";

  static String m42(action) => "すでに「${action}」で使用されています。保存するとこちらに移動します。";

  static String m43(modifiers) => "${modifiers} のいずれかを含めてください";

  static String m44(count) => "${count} 時間前";

  static String m45(count) => "${count} 時間";

  static String m46(target) => "${target} は無効なポリシーです";

  static String m47(proxyName) => "${proxyName} は無効なプロキシです";

  static String m48(providerName) => "${providerName} は無効なプロキシプロバイダーです";

  static String m49(subRule) => "${subRule} は無効な SUB_RULE です";

  static String m50(address) => "またはスマートフォンのブラウザで ${address} を開いてください";

  static String m51(appName) =>
      "1. システム設定 > プライバシーとセキュリティ を開く\n2. 位置情報サービス を選択\n3. リストで ${appName} を見つけてチェックを入れる\n\n設定が完了したらアプリに戻ると、通常どおり使用できます。ご協力ありがとうございます。";

  static String m52(label, max) => "${label}は最大${max}文字です";

  static String m54(count) => "${count} 分前";

  static String m55(count) => "${count} か月前";

  static String m56(label) => "${label}はまだありません";

  static String m57(label) => "${label}は数値である必要があります";

  static String m58(settings) => "このサブスクリプションは次のアプリ全体の設定を要求しています：\n${settings}";

  static String m59(label) => "${label} は 1024〜49151 の範囲で指定してください";

  static String m60(count) => "プロファイルをインポートし、未対応のノード ${count} 件をスキップしました";

  static String m61(format, client, nodes, groups) =>
      "インポート完了：${format} · ${client} · ノード ${nodes} 件 · グループ ${groups} 件";

  static String m62(days) => "${days} 日間使用されていません";

  static String m63(months) => "${months} か月使用されていません";

  static String m64(count) => "プロキシ ${count} 件";

  static String m65(count) => "プロファイル：${count}";

  static String m66(count) => "プロキシグループ：${count}";

  static String m67(count) => "ルール：${count}";

  static String m68(count) => "スクリプト：${count}";

  static String m69(count) => "ルール ${count} 件";

  static String m70(darkAt, lightAt) => "${darkAt} から ${lightAt} までダーク";

  static String m71(count) => "${count} 秒";

  static String m72(count) => "${count} 件選択中";

  static String m73(count) => "${count} 件のプロファイルを準備しました";

  static String m74(step, count) => "${count} ステップ中 ${step}";

  static String m75(name) => "プロファイル：${name}";

  static String m76(value) => "スマートルーティング：${value}";

  static String m77(alive, total) => "現在 ${total} 台のうち ${alive} 台が使用可能";

  static String m78(percent, duration) => "${duration} の稼働率 ${percent}%";

  static String m79(band) => "${band} 段";

  static String m80(bands) => "遅延帯: ${bands}";

  static String m81(count) => "${count} 回の失敗後のクールダウン中";

  static String m82(answered, total) => "${total} 件中 ${answered} 件が応答";

  static String m83(seconds) => "残り ${seconds} 秒";

  static String m84(count) => "${count} 回連続で失敗";

  static String m85(step) => "敗れた行: ${step}";

  static String m86(duration) => "計測期間 ${duration}";

  static String m87(ms) => "${ms} ミリ秒";

  static String m88(minutes) => "${minutes} 分";

  static String m89(measured, total) => "${total} 台のうち ${measured} 台を測定";

  static String m90(preset) => "${preset} · 調整済み";

  static String m91(left, cap) => "この 1 時間の検査は残り ${left}/${cap} 回";

  static String m92(value, against) => "${value} 対 ${against}";

  static String m93(seconds) => "${seconds} 秒";

  static String m94(eligible, total) => "${total} 台のうち ${eligible} 台が使用可能";

  static String m95(count) => "専用ノードのセレクター：${count} 件";

  static String m96(provider) => "プロバイダー：${provider}";

  static String m97(count) => "プロバイダー提供のセレクター：${count} 件";

  static String m98(eligible, total) => "${total} 台中 ${eligible} 台が利用可能";

  static String m99(label) => "${label} は UTF-8 で 64 バイト以内にしてください";

  static String m100(node) => "${node} 経由";

  static String m101(eligible, total, blocked) =>
      "${total} 台のうち ${eligible} 台が通過、${blocked} 台を除外";

  static String m102(strategy) => "${strategy}・変更済み";

  static String m103(from, to) => "${from} → ${to}";

  static String m104(time) => "${time}前に切り替え";

  static String m105(count) => "${count} 台";

  static String m106(step) => "上位の行: ${step}";

  static String m107(host) => "プロバイダーは ${host} に移転しました";

  static String m108(count) => "サブスクリプションは ${count} 日後に期限切れになります";

  static String m109(value) => "プロバイダーの推奨は ${value} です";

  static String m110(total) => "残り（${total} 中）";

  static String m111(label) => "${label}はURLである必要があります";

  static String m112(count) => "背景は最大 ${count} 件まで保存できます。追加するには 1 件削除してください。";

  static String m113(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "accessControl": MessageLookupByLibrary.simpleMessage("アクセス制御"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリのみVPNを経由します",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシを利用するアプリを設定します",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "アプリアクセス制御は無効です",
    ),
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "VPNから除外",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "VPNに含める",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリはVPNから除外されます",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("アクセス制御の設定"),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "action": MessageLookupByLibrary.simpleMessage("アクション"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("すべての遅延をテスト"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("ダイレクトモード"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("グローバルモード"),
    "actionMode": MessageLookupByLibrary.simpleMessage("モード切替"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("ルールモード"),
    "actionStart": MessageLookupByLibrary.simpleMessage("開始/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("プロファイルを更新"),
    "actionView": MessageLookupByLibrary.simpleMessage("表示/非表示"),
    "add": MessageLookupByLibrary.simpleMessage("追加"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("ネットワークを追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイルを追加"),
    "addProxies": MessageLookupByLibrary.simpleMessage("プロキシを追加"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを追加"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダーを追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "addWidget": MessageLookupByLibrary.simpleMessage("ウィジェットを追加"),
    "addedRules": MessageLookupByLibrary.simpleMessage("追加ルール"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage("追加パラメータ"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーのアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "有効なWebDAVアドレスを入力してください",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage("多彩な設定項目を提供します"),
    "agree": MessageLookupByLibrary.simpleMessage("同意する"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("アプリによるVPNバイパスを許可"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、一部のアプリがVPNをバイパスできます",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LANプロキシ"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN経由でのプロキシ利用を許可します"),
    "animations": MessageLookupByLibrary.simpleMessage("アニメーション"),
    "announce": MessageLookupByLibrary.simpleMessage("お知らせ"),
    "app": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("アプリアクセス制御"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("ブループリント"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "ランチャーは数秒後にアイコンを再描画します。一部のランチャーではピン留めショートカットが消えることがあります。",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("サーキット"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("エコー"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("インク"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("設定"),
    "appIconPreview": MessageLookupByLibrary.simpleMessage("アイコンのプレビュー"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("シャッター"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("ソーラー"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("スパーク"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("ストラータ"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("地形"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("トレース"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("ベルベット"),
    "appRegion": MessageLookupByLibrary.simpleMessage("アプリの地域"),
    "appRegionDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークの地域を選択してください。ロシアを選ぶと HWID が有効になりますが、下で無効にできます。スマートルーティングは別に設定します。",
    ),
    "appRegionOther": MessageLookupByLibrary.simpleMessage("その他"),
    "appearance": MessageLookupByLibrary.simpleMessage("外観"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("背景"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "テーマ・色・アイコンとダッシュボードの見た目",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("アイコン"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを追加"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "設定にシステムDNSを強制的に追加します",
    ),
    "application": MessageLookupByLibrary.simpleMessage("アプリケーション"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "アプリケーション関連の設定を変更します",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("認証"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルプロキシポートに認証を要求し、他のアプリによる無断利用を防ぎます",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "認証が有効な間は適用されません",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("許可"),
    "authorized": MessageLookupByLibrary.simpleMessage("許可済み"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("更新の自動チェック"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "アプリ起動時に更新を自動的にチェックします",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("接続を自動的に閉じる"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "ノードの切り替え後、接続を自動的に閉じます",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自動起動"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage("システム起動時に自動的に起動します"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動実行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("アプリを開いたときに自動的に実行します"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを自動設定"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔（分）"),
    "autoUpdateOffSuggested": m0,
    "back": MessageLookupByLibrary.simpleMessage("戻る"),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVまたはファイルでデータを同期します",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップが完了しました"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("基本設定"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage("基本設定をグローバルに変更します"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基本情報"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基本ポリシー"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンドでの動作を維持するため、このアプリの電池の最適化を無効にしてください。タップすると設定を開きます。",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "システムの制限により、実行中は電池の最適化の状態を正しく取得できません",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("連携"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("ブラックリストモード"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("接続をブロック"),
    "byedpiActive": MessageLookupByLibrary.simpleMessage("DPI バイパスが有効です"),
    "byedpiActiveFor": m1,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage("DPI エンジンを確認中"),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage(
      "DPI エンジンを確認してください",
    ),
    "byedpiOff": MessageLookupByLibrary.simpleMessage("DPI バイパスはオフです"),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage("DPI バイパスは一時停止中です"),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage("DPI エンジンを再起動中"),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage("DPI バイパスを開始中"),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage(
      "タップして DPI バイパスを再開",
    ),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage(
      "タップしてローカルバイパスエンジンを開始",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("除外ドメイン"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "システムプロキシが有効な場合のみ適用されます",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "カメラへのアクセスがオフです。QRコードをスキャンするには設定でオンにしてください。",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("すべて選択解除"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "プロキシの切り替えに失敗したため、前回の選択に戻しました",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("サーバーを変更"),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("破壊的変更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新機能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("不具合修正"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("パフォーマンス"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("取り消し"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS証明書を検証"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "信頼できない証明書を拒否します。無効にすると、サブスクリプションやバックアップが中間者攻撃にさらされます",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("更新を確認"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("すでに最新バージョンです"),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("クラシック"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage("タイル配置と開始ボタン"),
    "clearData": MessageLookupByLibrary.simpleMessage("データを消去"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("検索をクリア"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage("クライアント未対応"),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "プロバイダーはこのクライアントに対応していません。",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("クリップボードへエクスポート"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("クリップボードからインポート"),
    "close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("接続を閉じる"),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPNの一時停止時に開いている接続をすべて切断します",
    ),
    "color": MessageLookupByLibrary.simpleMessage("カラー"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("カラースキーム"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compatible": MessageLookupByLibrary.simpleMessage("互換モード"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "設定内にデータが見つかりました",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("OK"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "すべてのデータを消去してもよろしいですか？",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "このプロキシグループを削除してもよろしいですか？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "現在のウィンドウを閉じてもよろしいですか？",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "コアを強制クラッシュさせてもよろしいですか？",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "確定すると既存のデータを上書きします",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "connectedFor": m2,
    "connecting": MessageLookupByLibrary.simpleMessage("接続中..."),
    "connection": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionDoctor": MessageLookupByLibrary.simpleMessage("接続ドクター"),
    "connectionProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "connectionType": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("現在の接続データを表示します"),
    "connectivity": MessageLookupByLibrary.simpleMessage("接続状態："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容は空にできません"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("コンテンツ"),
    "contrast": MessageLookupByLibrary.simpleMessage("コントラスト"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "ピュアブラックでは +0.3 のコントラストが読みやすいことが多い",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "グローバル追加ルールを管理",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage("バージョン情報をコピー"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("環境変数をコピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "core": MessageLookupByLibrary.simpleMessage("コア"),
    "coreBlockedByPolicyTip": m3,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows のスマート アプリ コントロールが、署名されていない ReClashCore.exe をブロックしました。Windows セキュリティ → アプリとブラウザーの制御 → スマート アプリ コントロールの設定で「オフ」を選び、ReClash を再起動してください。一度オフにすると、Windows を再インストールしない限り再度オンにはできません。",
    ),
    "coreRunning": MessageLookupByLibrary.simpleMessage("稼働中"),
    "coreStarting": MessageLookupByLibrary.simpleMessage("起動中…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コアの状態"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("停止中"),
    "country": MessageLookupByLibrary.simpleMessage("地域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("クラッシュを検出しました"),
    "crashDetectedTip": m4,
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("クラッシュ分析"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "有効にすると、アプリのクラッシュ時に機密情報を含まないクラッシュログを自動的にアップロードします",
    ),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "createProfile": MessageLookupByLibrary.simpleMessage("プロファイルを作成"),
    "createProfileFromUrlTip": m5,
    "creationTime": MessageLookupByLibrary.simpleMessage("作成日時"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — 本アプリの基盤クライアント",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — プロバイダ機能とアイデア",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("mihomo — プロキシコア"),
    "crownHistory": m6,
    "custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "darkAt": MessageLookupByLibrary.simpleMessage("ダーク切替"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ダッシュボード"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "VPN プロファイルなしで DPI を回避するには、ByeDPI 専用モードを使います。",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage(
      "VPN プロバイダーがありませんか？",
    ),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルは保存されていますが、選択されていません。VPN を操作するにはプロファイルを選んでください。",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "VPN プロファイルを選択",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "信頼できるプロバイダーの VPN プロファイルを追加してください。それまでは VPN はオフのままです。",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage("接続を設定"),
    "dashboardProviderDetails": MessageLookupByLibrary.simpleMessage("詳細を見る"),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage("プロファイルを選択"),
    "dashboardShowConnection": MessageLookupByLibrary.simpleMessage("接続画面に戻る"),
    "dashboardShowProvider": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの詳細を表示",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("ダッシュボードのスタイル"),
    "dashboardSubscriptionAttention": MessageLookupByLibrary.simpleMessage(
      "確認が必要です",
    ),
    "dashboardSubscriptionCurrent": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションは有効です",
    ),
    "dashboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの期限切れ",
    ),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI を使う"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "データの変更を検出しました。保存しますか？",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "本アプリは、安定性向上のために Firebase Crashlytics を使用してクラッシュ情報を収集します。\n収集されるデータにはデバイス情報とクラッシュの詳細が含まれますが、個人の機密データは含まれません。\nこの機能は設定で無効にできます。",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage("データ収集について"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "変更の保存に失敗したため、元に戻しました",
    ),
    "day": MessageLookupByLibrary.simpleMessage("日"),
    "days": MessageLookupByLibrary.simpleMessage("日"),
    "daysAgo": m7,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("日"),
    "daysLeft": m8,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("デフォルトネームサーバー"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNSサーバーの名前解決に使用します",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "delay": MessageLookupByLibrary.simpleMessage("遅延"),
    "delayTest": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteMultipTip": m9,
    "deleteTip": m10,
    "desc": MessageLookupByLibrary.simpleMessage(
      "マルチプラットフォーム mihomo クライアント。作り直したダッシュボード、賢いルーティング、充実したサブスクリプション対応。オープンソースで広告もテレメトリもありません。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPIバイパス"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage("有効なストラテジー"),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("エンジン引数"),
    "desyncArgsAppOwnedFlag": m11,
    "desyncArgsCount": m12,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m13,
    "desyncArgsPositional": m14,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "引用符が閉じられていません",
    ),
    "desyncArgsUnknownFlag": m15,
    "desyncCache": MessageLookupByLibrary.simpleMessage("戦略キャッシュ"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "選ばれた戦略はネットワークごとに保持されます",
    ),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage(
      "ストラテジーキャッシュは無効です",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("キャッシュ保持期間"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("デフォルトのラダー"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage("ByeDPI デシンク戦略"),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("エンジン"),
    "desyncEngineSummary": m16,
    "desyncFeatureEnable": MessageLookupByLibrary.simpleMessage("ByeDPI を有効化"),
    "desyncFeatureEnableDesc": MessageLookupByLibrary.simpleMessage(
      "DPI 回避エンジンとダッシュボードのモードを有効にします。オフの間、ByeDPI はどこにも表示されません。",
    ),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("TCPへ強制"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "上記カテゴリのQUICをブロックします。デシンクはUDPに効きません",
    ),
    "desyncLadderResult": m17,
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("接続モード"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("ルーティング"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "選択した GEOSITE カテゴリ以外の通信はすべて直接接続します",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "カテゴリの内容は内蔵 GEOSITE データベースから取得され、テストドメイン一覧とは別です",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "バイパスカテゴリが選択されていません",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "現在 ByeDPI を通るサービスはありません",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage("有効なルール"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("現在のものを保存"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage("戦略名"),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("戦略"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "中断しました: ストラテジーがエンジンへ届きません",
    ),
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("テストバッテリー"),
    "desyncTestBatterySummary": m18,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("テストドメイン"),
    "desyncTestDomainsCount": m19,
    "desyncTestDone": m20,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "このストラテジーでエンジンが停止しました",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "エンジンが動作していません — DPI バイパスを有効にして接続してください",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "このストラテジーが失敗したホスト",
    ),
    "desyncTestHint": m21,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "下からドメインリストを1つ以上選んでください",
    ),
    "desyncTestProgress": m22,
    "desyncTestScore": m23,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("ストラテジーテスト"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("開始"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage("全プリセットを実行"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12時間"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28時間"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1時間"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7日"),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "サードパーティAPIに依存しているため、参考値です",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("IPを確認中..."),
    "developerAllRewards": MessageLookupByLibrary.simpleMessage("すべての報酬をプレビュー"),
    "developerFindingEvents": MessageLookupByLibrary.simpleMessage("発見を再生"),
    "developerFindingQueued": MessageLookupByLibrary.simpleMessage(
      "正常な接続のダッシュボード表示を待っています。何度でも再生できます。",
    ),
    "developerFindings": MessageLookupByLibrary.simpleMessage("発見のプレビュー"),
    "developerFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "一時的なプレビューです。カウンター、獲得済みの発見、ネットワーク設定は変更しません。リセットまたは開発者モードの無効化で終了します。効果は正常な接続のダッシュボード表示を待ち、外観設定に従います。外観で選択したアイコンやテーマは保存されます。",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("開発者モード"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "開発者モードが有効になりました。",
    ),
    "developerPatina": MessageLookupByLibrary.simpleMessage("プロファイルのほこり"),
    "developerPatinaApply": MessageLookupByLibrary.simpleMessage("プロファイル一覧に適用"),
    "developerPatinaApplyDesc": MessageLookupByLibrary.simpleMessage(
      "すべてのプロファイルをこの経過日数に固定します。オフの場合は各プロファイルの実際の最終使用日を使います。",
    ),
    "developerPatinaDays": m25,
    "developerPatinaLab": MessageLookupByLibrary.simpleMessage("ほこりラボ"),
    "developerPatinaSample": MessageLookupByLibrary.simpleMessage(
      "放置されたサブスクリプション",
    ),
    "developerPreviewAutomatic": MessageLookupByLibrary.simpleMessage("自動"),
    "developerPreviewReset": MessageLookupByLibrary.simpleMessage("プレビューを解除"),
    "developerSeasonAnniversary": MessageLookupByLibrary.simpleMessage(
      "初回起動の記念日",
    ),
    "developerSeasonBirthday": MessageLookupByLibrary.simpleMessage(
      "ReClash の誕生日",
    ),
    "developerSeasonDrift": MessageLookupByLibrary.simpleMessage("季節の色合い"),
    "developerSeasonNewYear": MessageLookupByLibrary.simpleMessage("新年"),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "プロバイダーウィジェット、サーバー切替、プロキシ表示",
    ),
    "developerSubscriptionEmberDesc": MessageLookupByLibrary.simpleMessage(
      "パネル全体を一括確認：通信量、ウィジェット、テーマ、ローカル背景",
    ),
    "developerSubscriptionInstalled": m26,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "通信量、有効期限、お知らせ、ドメイン移行、オファー",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "ブランドカラー、カスタム Hero Ring、ローカルロゴ",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage(
      "テスト用サブスクリプション",
    ),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage(
      "デバイス数の上限に達しました",
    ),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "プロバイダーによると、このサブスクリプションのデバイス数が上限に達しています。サブスクリプションは更新されました。",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDPを無効化"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責事項"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは、学習・交流や研究などの非商用目的でのみ使用できます。商用目的での使用は固く禁じられています。いかなる商業行為も本ソフトウェアとは一切関係ありません。",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("切断済み"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンが見つかりました",
    ),
    "discoveredFindings": MessageLookupByLibrary.simpleMessage("発見済み"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS関連の設定を更新します"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNSハイジャック"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNSモード"),
    "doctorBrokenDesc": MessageLookupByLibrary.simpleMessage(
      "最初に失敗したレイヤーを確認しました。",
    ),
    "doctorBrokenTitle": MessageLookupByLibrary.simpleMessage("接続の問題を検出しました"),
    "doctorByeDpiFailedDesc": MessageLookupByLibrary.simpleMessage(
      "ローカル ByeDPI プロキシが利用できないため、通信を通せません。",
    ),
    "doctorByeDpiFailedTitle": MessageLookupByLibrary.simpleMessage(
      "ByeDPI を起動できませんでした",
    ),
    "doctorCancelExam": MessageLookupByLibrary.simpleMessage("確認をキャンセル"),
    "doctorCancelledDesc": MessageLookupByLibrary.simpleMessage(
      "診断は変更されていません。再度確認できます。",
    ),
    "doctorCancelledTitle": MessageLookupByLibrary.simpleMessage(
      "確認をキャンセルしました",
    ),
    "doctorCaptureActive": MessageLookupByLibrary.simpleMessage("有効"),
    "doctorCaptureInactive": MessageLookupByLibrary.simpleMessage("無効"),
    "doctorCaptureNotApplicable": MessageLookupByLibrary.simpleMessage("対象外"),
    "doctorConfidence": MessageLookupByLibrary.simpleMessage("確度"),
    "doctorConfidenceConfirmed": MessageLookupByLibrary.simpleMessage("確認済み"),
    "doctorConfidenceInsufficient": MessageLookupByLibrary.simpleMessage("不十分"),
    "doctorConfidenceProbable": MessageLookupByLibrary.simpleMessage("可能性あり"),
    "doctorDeepExam": MessageLookupByLibrary.simpleMessage("詳細確認"),
    "doctorDegradedDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワーク経路に問題の可能性があります。",
    ),
    "doctorDegradedTitle": MessageLookupByLibrary.simpleMessage("接続が不安定です"),
    "doctorDetails": MessageLookupByLibrary.simpleMessage("診断"),
    "doctorDnsFailedDesc": MessageLookupByLibrary.simpleMessage(
      "テスト先のアドレスを解決できませんでした。",
    ),
    "doctorDnsFailedTitle": MessageLookupByLibrary.simpleMessage(
      "DNS が機能していません",
    ),
    "doctorDnsStaleDesc": MessageLookupByLibrary.simpleMessage(
      "キャッシュされたアドレスが現在のネットワークと一致しません。",
    ),
    "doctorDnsStaleTitle": MessageLookupByLibrary.simpleMessage(
      "DNS 情報が古くなっています",
    ),
    "doctorEndpointReachableDesc": MessageLookupByLibrary.simpleMessage(
      "Core はテスト先に到達しましたが、保護された経路全体は確認されていません。",
    ),
    "doctorEndpointReachableTitle": MessageLookupByLibrary.simpleMessage(
      "テスト先に到達できます",
    ),
    "doctorEvidence": MessageLookupByLibrary.simpleMessage("証拠"),
    "doctorEvidenceConsequence": MessageLookupByLibrary.simpleMessage(
      "先行する障害の結果",
    ),
    "doctorEvidenceDropped": m27,
    "doctorExaminingDesc": MessageLookupByLibrary.simpleMessage(
      "制限されたプローブでネットワーク経路を確認しています。",
    ),
    "doctorExaminingTitle": MessageLookupByLibrary.simpleMessage("接続を確認中"),
    "doctorExportConfirm": MessageLookupByLibrary.simpleMessage(
      "レポートには診断コード、時間区分、プラットフォーム情報、匿名化された証拠が含まれます。アドレス、ホスト名、プロファイル、ノード、アプリ名は含まれません。JSON で保存しますか？",
    ),
    "doctorExportReport": MessageLookupByLibrary.simpleMessage("レポートをエクスポート"),
    "doctorFlushDns": MessageLookupByLibrary.simpleMessage("DNS キャッシュを消去"),
    "doctorFresh": MessageLookupByLibrary.simpleMessage("最新"),
    "doctorGenericDesc": MessageLookupByLibrary.simpleMessage(
      "接続の問題を検出しましたが、詳しい原因を特定できませんでした。",
    ),
    "doctorHealthyDesc": MessageLookupByLibrary.simpleMessage(
      "観測した経路は正常に完了しました。",
    ),
    "doctorHealthyEasterEgg": MessageLookupByLibrary.simpleMessage(
      "患者は疑わしいほど健康です。",
    ),
    "doctorHealthyTitle": MessageLookupByLibrary.simpleMessage("接続は正常です"),
    "doctorHeroExamining": m28,
    "doctorHeroIssue": m29,
    "doctorInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "推測せずに障害を確認できませんでした。",
    ),
    "doctorInconclusiveTitle": MessageLookupByLibrary.simpleMessage(
      "証拠が不足しています",
    ),
    "doctorIngressDesc": MessageLookupByLibrary.simpleMessage(
      "アプリは通信を送信しましたが、想定した VPN またはローカルプロキシの入口に届きませんでした。",
    ),
    "doctorIngressTitle": MessageLookupByLibrary.simpleMessage(
      "通信がトンネルに入りませんでした",
    ),
    "doctorIpUnavailable": MessageLookupByLibrary.simpleMessage("公開 IP は未測定"),
    "doctorLayer": MessageLookupByLibrary.simpleMessage("原因レイヤー"),
    "doctorLayerCapture": MessageLookupByLibrary.simpleMessage("キャプチャ"),
    "doctorLayerDial": MessageLookupByLibrary.simpleMessage("接続確立"),
    "doctorLayerDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "doctorLayerIngress": MessageLookupByLibrary.simpleMessage("VPN 入口"),
    "doctorLayerMarker": MessageLookupByLibrary.simpleMessage("アプリ応答"),
    "doctorLayerRoute": MessageLookupByLibrary.simpleMessage("ルーティング"),
    "doctorLayerTransport": MessageLookupByLibrary.simpleMessage("トランスポート"),
    "doctorLimitations": MessageLookupByLibrary.simpleMessage("この結果について"),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("詳細"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("標準"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage("利用できる証拠はまだありません"),
    "doctorNoIncidents": MessageLookupByLibrary.simpleMessage("完了した確認はありません"),
    "doctorNoNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "デバイスが Wi-Fi またはモバイルデータに接続されていません。",
    ),
    "doctorNoNetworkTitle": MessageLookupByLibrary.simpleMessage(
      "インターネット接続がありません",
    ),
    "doctorNoNodeDesc": MessageLookupByLibrary.simpleMessage(
      "この接続を中継する有効なプロキシサーバーがありません。",
    ),
    "doctorNoNodeTitle": MessageLookupByLibrary.simpleMessage(
      "プロキシサーバーが選択されていません",
    ),
    "doctorNodeDownDesc": MessageLookupByLibrary.simpleMessage(
      "選択したプロキシサーバーが接続を受け付けないか、応答しませんでした。",
    ),
    "doctorNodeDownTitle": MessageLookupByLibrary.simpleMessage(
      "プロキシサーバーを利用できません",
    ),
    "doctorNodeRefusedDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシには接続できましたが、テスト先から期待した応答がありませんでした。",
    ),
    "doctorNodeRefusedTitle": MessageLookupByLibrary.simpleMessage(
      "テスト先に拒否されました",
    ),
    "doctorObservingDesc": MessageLookupByLibrary.simpleMessage(
      "アクティブなプローブはありません。アプリ使用中に証拠を収集します。",
    ),
    "doctorObservingTitle": MessageLookupByLibrary.simpleMessage("実際の通信を監視中"),
    "doctorOutcomeDropped": MessageLookupByLibrary.simpleMessage("破棄"),
    "doctorOutcomeFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "doctorOutcomeNotApplicable": MessageLookupByLibrary.simpleMessage("対象外"),
    "doctorOutcomeSeen": MessageLookupByLibrary.simpleMessage("観測"),
    "doctorOutcomeSucceeded": MessageLookupByLibrary.simpleMessage("成功"),
    "doctorPassiveHint": MessageLookupByLibrary.simpleMessage(
      "この画面を開くと確認が 1 回実行されます。それ以外のときは実際の通信を観察するだけで、追加の通信は発生しません。",
    ),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("アプリ"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("確認中"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage("前の問題により未確認"),
    "doctorPathFailed": MessageLookupByLibrary.simpleMessage("ここに問題があります"),
    "doctorPathIngress": MessageLookupByLibrary.simpleMessage("VPN / ローカル入口"),
    "doctorPathIngressByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "doctorPathIngressDirect": MessageLookupByLibrary.simpleMessage("直接接続"),
    "doctorPathIngressLocalProxy": MessageLookupByLibrary.simpleMessage(
      "ローカルプロキシ",
    ),
    "doctorPathIngressTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "doctorPathIngressVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "doctorPathInternet": MessageLookupByLibrary.simpleMessage(
      "プロキシ / インターネット",
    ),
    "doctorPathNotApplicable": MessageLookupByLibrary.simpleMessage("不要"),
    "doctorPathPassed": MessageLookupByLibrary.simpleMessage("正常"),
    "doctorPathResponse": MessageLookupByLibrary.simpleMessage("応答"),
    "doctorPathRoute": MessageLookupByLibrary.simpleMessage("DNS / ルート"),
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("接続経路"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("未確認"),
    "doctorPortalDesc": MessageLookupByLibrary.simpleMessage(
      "ログインするまで、このネットワークからインターネットに接続できません。",
    ),
    "doctorPortalTitle": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi へのログインが必要です",
    ),
    "doctorProgress": m30,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("保護"),
    "doctorRecentChecks": MessageLookupByLibrary.simpleMessage("最近の確認"),
    "doctorRefresh": MessageLookupByLibrary.simpleMessage("診断を更新"),
    "doctorRemedyOpenDns": MessageLookupByLibrary.simpleMessage("DNS 設定"),
    "doctorRemedyStartVpn": MessageLookupByLibrary.simpleMessage("VPN を起動"),
    "doctorRouteDesc": MessageLookupByLibrary.simpleMessage(
      "現在のプロファイルでは、この接続に使える経路を選択できませんでした。",
    ),
    "doctorRouteTitle": MessageLookupByLibrary.simpleMessage("通信の経路が正しくありません"),
    "doctorScope": MessageLookupByLibrary.simpleMessage("証拠の範囲"),
    "doctorScopeApp": MessageLookupByLibrary.simpleMessage("このアプリ"),
    "doctorScopeInbound": MessageLookupByLibrary.simpleMessage("ローカル入口"),
    "doctorSlowDesc": MessageLookupByLibrary.simpleMessage(
      "制限時間内にテストが完了しませんでした。",
    ),
    "doctorSlowTitle": MessageLookupByLibrary.simpleMessage("接続が遅すぎます"),
    "doctorStale": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "doctorStaleHint": MessageLookupByLibrary.simpleMessage(
      "環境が変わった可能性があります。操作前に更新または再確認してください。",
    ),
    "doctorStaleTitle": MessageLookupByLibrary.simpleMessage("結果が古くなっています"),
    "doctorStandardExam": MessageLookupByLibrary.simpleMessage("確認を実行"),
    "doctorStepChangeDns": MessageLookupByLibrary.simpleMessage(
      "プロファイル設定で別の DNS サーバーを試してください。",
    ),
    "doctorStepCheckRules": MessageLookupByLibrary.simpleMessage(
      "プロファイルのルールとルーティングモードを確認してください。",
    ),
    "doctorStepCheckWifi": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi またはモバイルデータに接続して、もう一度確認してください。",
    ),
    "doctorStepDeepCheck": MessageLookupByLibrary.simpleMessage(
      "詳細確認を実行して DNS 経路を比較してください。",
    ),
    "doctorStepFlushDns": MessageLookupByLibrary.simpleMessage(
      "DNS キャッシュを消去して、もう一度確認してください。",
    ),
    "doctorStepPickNode": MessageLookupByLibrary.simpleMessage(
      "別のプロキシサーバーを選択してください。",
    ),
    "doctorStepRecheckLater": MessageLookupByLibrary.simpleMessage(
      "時間をおくか、別のネットワークで再確認してください。",
    ),
    "doctorStepRestartByeDpi": MessageLookupByLibrary.simpleMessage(
      "詳細設定で ByeDPI を再起動してください。",
    ),
    "doctorStepRestartTunnel": MessageLookupByLibrary.simpleMessage(
      "接続を再起動して、もう一度確認してください。",
    ),
    "doctorStepSignInPortal": MessageLookupByLibrary.simpleMessage(
      "ネットワークのログインページを開いてから、もう一度確認してください。",
    ),
    "doctorStepStartVpn": MessageLookupByLibrary.simpleMessage(
      "VPN を起動して、もう一度確認してください。",
    ),
    "doctorStepSwitchNetwork": MessageLookupByLibrary.simpleMessage(
      "別のネットワークに切り替えるか、インターネット接続を復旧してください。",
    ),
    "doctorStepUpdateSubscription": MessageLookupByLibrary.simpleMessage(
      "他のサーバーも失敗する場合は、サブスクリプションを更新してください。",
    ),
    "doctorStepUseAppThenRecheck": MessageLookupByLibrary.simpleMessage(
      "問題のあるアプリを使用してから戻り、もう一度確認してください。",
    ),
    "doctorStormTitle": MessageLookupByLibrary.simpleMessage(
      "接続のすべての段階が利用できません",
    ),
    "doctorStormVerdict": MessageLookupByLibrary.simpleMessage(
      "利用可能な経路が見つかりませんでした。後続の失敗は最初の障害に起因している可能性があります。",
    ),
    "doctorSupersededDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークまたは設定の変更により確認を停止しました。",
    ),
    "doctorSupersededTitle": MessageLookupByLibrary.simpleMessage("環境が変わりました"),
    "doctorTechnicalDetails": MessageLookupByLibrary.simpleMessage("技術的な詳細"),
    "doctorUnsupportedDesc": MessageLookupByLibrary.simpleMessage(
      "この Core は接続診断に対応していません。",
    ),
    "doctorUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "接続診断を使用するには Core を更新してください。",
    ),
    "doctorUnsupportedTitle": MessageLookupByLibrary.simpleMessage(
      "診断を利用できません",
    ),
    "doctorUnvalidatedDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークには接続されていますが、Android はそこからインターネットに到達できません。",
    ),
    "doctorUnvalidatedTitle": MessageLookupByLibrary.simpleMessage(
      "ネットワークからインターネットに接続できません",
    ),
    "doctorVpnInactiveDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 保護が必要ですが、TUN 経路が有効ではありません。",
    ),
    "doctorVpnInactiveTitle": MessageLookupByLibrary.simpleMessage(
      "VPN が有効ではありません",
    ),
    "doctorWhatToTry": MessageLookupByLibrary.simpleMessage("試すこと"),
    "domain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("更新をダウンロード中"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルールを編集"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("ネットワークを編集"),
    "editProxy": MessageLookupByLibrary.simpleMessage("プロキシを編集"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを編集"),
    "editRule": MessageLookupByLibrary.simpleMessage("ルールを編集"),
    "emptyTip": m31,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "enterManually": MessageLookupByLibrary.simpleMessage("手動で入力"),
    "entries": MessageLookupByLibrary.simpleMessage(" 件"),
    "entriesCount": m32,
    "exclude": MessageLookupByLibrary.simpleMessage("最近のタスクから隠す"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンド時に、最近のタスクからアプリを隠します",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage("除外ノードフィルター"),
    "excludeType": MessageLookupByLibrary.simpleMessage("除外タイプ"),
    "existsTip": m33,
    "exit": MessageLookupByLibrary.simpleMessage("終了"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("全画面表示を終了"),
    "expand": MessageLookupByLibrary.simpleMessage("標準"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("期待するステータス"),
    "expireTime": MessageLookupByLibrary.simpleMessage("有効期限"),
    "exportFile": MessageLookupByLibrary.simpleMessage("ファイルをエクスポート"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("ログをエクスポート"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポートが完了しました"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("エクスプレッシブ"),
    "externalActionConfirmMessage": m34,
    "externalActionConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "外部操作の確認",
    ),
    "externalController": MessageLookupByLibrary.simpleMessage("外部コントローラー"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、ポート9090でClashコアを制御できます",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部取得"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部リンク"),
    "extra": MessageLookupByLibrary.simpleMessage("追加"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IPフィルター"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP範囲"),
    "fallback": MessageLookupByLibrary.simpleMessage("フォールバック"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("通常は国外のDNSを使用します"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("フォールバックフィルター"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("フィデリティ"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("プロファイルファイルを直接アップロードします"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "ファイルが変更されています。変更を保存しますか？",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("フィルター"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("プロセス検出"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、パフォーマンスが多少低下します",
    ),
    "findingAuscultation": MessageLookupByLibrary.simpleMessage("聴診"),
    "findingCrown": MessageLookupByLibrary.simpleMessage("冠"),
    "findingDiscoveredOn": m35,
    "findingFullLadder": MessageLookupByLibrary.simpleMessage("完全な梯子"),
    "findingMarks": MessageLookupByLibrary.simpleMessage("マーク"),
    "findingMarksDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash のマークシートが見つかりました。",
    ),
    "findingMeridian": MessageLookupByLibrary.simpleMessage("五つの子午線"),
    "findingOdometer": MessageLookupByLibrary.simpleMessage("走行計"),
    "findingOscilloscope": MessageLookupByLibrary.simpleMessage("オシロスコープ"),
    "findingOscilloscopeDesc": MessageLookupByLibrary.simpleMessage(
      "リングが六秒間、実際の通信を聴きました。",
    ),
    "findingPi": MessageLookupByLibrary.simpleMessage("円周率"),
    "findingPiDesc": MessageLookupByLibrary.simpleMessage(
      "ダッシュボードを開いたまま、セッションが 3:14:15 を越えました。",
    ),
    "findingPorcelain": MessageLookupByLibrary.simpleMessage("磁器"),
    "findingSilentAutopilot": MessageLookupByLibrary.simpleMessage("静かな自動操縦"),
    "findingSingularity": MessageLookupByLibrary.simpleMessage("特異点"),
    "findingSingularityDesc": MessageLookupByLibrary.simpleMessage(
      "リングは一点に崩壊するまで握られ、再び弾けました。",
    ),
    "findingTurn": MessageLookupByLibrary.simpleMessage("年越し"),
    "findingTurnDesc": MessageLookupByLibrary.simpleMessage(
      "セッションが新年の午前零時を越えました。",
    ),
    "findingVigil": MessageLookupByLibrary.simpleMessage("見張り"),
    "findings": MessageLookupByLibrary.simpleMessage("発見"),
    "findingsCount": m36,
    "findingsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash の使用中に静かに見つかった細部",
    ),
    "findingsLocked": m37,
    "findingsMoments": MessageLookupByLibrary.simpleMessage("瞬間"),
    "findingsNextMilestone": m38,
    "findingsRelics": MessageLookupByLibrary.simpleMessage("遺物"),
    "followProfile": MessageLookupByLibrary.simpleMessage("プロファイルに従う"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("フォント"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "コアを強制再起動してもよろしいですか？",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("フルーツサラダ"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自動更新間隔は0より大きくしてください",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geoオプション"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geoリソース"),
    "geoSkipped": m39,
    "geoUpdated": m40,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低メモリモード"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、低メモリのGeoローダーを使用します",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIPコード"),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "go": MessageLookupByLibrary.simpleMessage("開く"),
    "goDownload": MessageLookupByLibrary.simpleMessage("ダウンロードへ"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("スクリプト設定へ移動"),
    "goroutineInfo": MessageLookupByLibrary.simpleMessage("ゴルーチン"),
    "gratitude": MessageLookupByLibrary.simpleMessage("感謝"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "彼らの成果の上に ReClash があります",
    ),
    "happImportAsClient": MessageLookupByLibrary.simpleMessage("通常のインポート"),
    "happImportAsClientDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash 自身として購読を要求し、形式を自動的に判別します。",
    ),
    "happImportAsHapp": MessageLookupByLibrary.simpleMessage("Happ 互換モード"),
    "happImportAsHappDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash を Happ アプリとして識別させ、その形式を読み込みます。プロバイダーが Happ 向けにノードを提供する場合に必要です。",
    ),
    "happImportChoiceTitle": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポート",
    ),
    "happImportPrompt": MessageLookupByLibrary.simpleMessage(
      "このリンクは Happ 経由で開かれました。Happ 互換モードで購読を取得しますか、それとも ReClash の通常の方法にしますか？",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "helperAgentUnavailable": MessageLookupByLibrary.simpleMessage(
      "システムの認証エージェントが利用できません。デスクトップセッションで polkit 認証エージェントを起動してから、再試行してください。",
    ),
    "helperAuthorizationContinue": MessageLookupByLibrary.simpleMessage("続行"),
    "helperAuthorizationLater": MessageLookupByLibrary.simpleMessage("後で"),
    "helperAuthorizationMessage": MessageLookupByLibrary.simpleMessage(
      "TUN モードには ReClash Helper サービスのインストールまたは更新が必要です。「続行」を押すと、システムの認証ダイアログが開きます。パスワードはそのダイアログにのみ入力してください。ReClash がパスワードを収集することはありません。",
    ),
    "helperAuthorizationTitle": MessageLookupByLibrary.simpleMessage(
      "Helper の設定を許可しますか？",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper サービスが利用できないため、TUN モードを有効にできません。ReClash を再インストールしてください。",
    ),
    "helperInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Helper サービスをインストールまたは更新できませんでした。ログを確認して再試行してください。",
    ),
    "helperInstallNotReady": MessageLookupByLibrary.simpleMessage(
      "Helper の設定は完了しましたが、サービスが準備できていません。ログを確認して再試行してください。",
    ),
    "helperPkexecUnavailable": MessageLookupByLibrary.simpleMessage(
      "pkexec が利用できません。お使いのディストリビューションの polkit パッケージをインストールしてから、再試行してください。",
    ),
    "helperSystemdUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN モードには systemd が必要ですが、このシステムでは利用できません。",
    ),
    "heroBlockedHint": MessageLookupByLibrary.simpleMessage(
      "別の VPN がトラフィックを捕捉しています — タップで再試行",
    ),
    "heroBlockedTitle": MessageLookupByLibrary.simpleMessage("トンネルがブロックされています"),
    "heroChecking": MessageLookupByLibrary.simpleMessage("ネットワークを確認中…"),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage("選択したノードを計測中"),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("接続中…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage("接続が機能していません"),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage("ノードが応答しません"),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage(
      "通信は一時停止中、保護は待機しています",
    ),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage("ノードの応答が遅いです"),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続を待っています",
    ),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("保護されていません"),
    "heroPaused": MessageLookupByLibrary.simpleMessage("一時停止 — 信頼済みネットワーク"),
    "heroProtected": MessageLookupByLibrary.simpleMessage("保護されています"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage("再接続中…"),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage("トンネルを復元中"),
    "heroRoutingAgo": m41,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage("スマートルーティングは無効です"),
    "heroStatusEasterEgg": MessageLookupByLibrary.simpleMessage(
      "今日のパケットは妙にお行儀がいいです。",
    ),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage("タップして保護を有効にする"),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage("タップして保護を再開"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("リストから隠す"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("パスワードを隠す"),
    "highPriorityAutoLaunch": MessageLookupByLibrary.simpleMessage("高優先度の自動起動"),
    "highPriorityAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Windows のタスク スケジューラを使って早く起動します",
    ),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Hostsを追加します"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("ホットキーが競合しています"),
    "hotkeyConflictWith": m42,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "グローバルホットキーはウィンドウが隠れていても動作します。操作をタップしてキーの組み合わせを記録します。",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("ホットキー管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "キーボードでアプリを操作します",
    ),
    "hotkeyNeedsModifier": m43,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("未設定"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "登録されていません。他のアプリが使用中の可能性があります",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("時間"),
    "hours": MessageLookupByLibrary.simpleMessage("時間"),
    "hoursAgo": m44,
    "hoursCount": m45,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("時間"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("時間"),
    "icon": MessageLookupByLibrary.simpleMessage("アイコン"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("アイコン履歴"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("アイコンスタイル"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("アイコンURL"),
    "identity": MessageLookupByLibrary.simpleMessage("識別情報"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "電池の最適化を無視",
    ),
    "import": MessageLookupByLibrary.simpleMessage("インポート"),
    "importFile": MessageLookupByLibrary.simpleMessage("ファイルからインポート"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "inbound": MessageLookupByLibrary.simpleMessage("インバウンド"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage("すべてのプロキシを含める"),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "プロキシグループに属さないすべてのプロキシを取り込みます。下でプロキシグループを追加できます",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "すべてのプロキシプロバイダーを含める",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "有効にすると、取り込んだプロキシプロバイダーを上書きします",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("無期限"),
    "init": MessageLookupByLibrary.simpleMessage("初期化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "正しいホットキーを入力してください",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名を入力してください",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("ルールの内容を入力してください"),
    "installUpdate": MessageLookupByLibrary.simpleMessage("更新をインストール"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "アプリ一覧の権限が拒否されたため、インストール済みアプリを取得できません。システム設定から手動で許可してください。",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "このシステムでは、許可するまでインストール済みアプリの一覧が提供されません。許可すると、アプリごとのプロキシを設定できます。",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "アプリ一覧の権限が必要です",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("スマート選択"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("インターフェース名"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "アウトバウンド接続に使用するネットワークインターフェース名",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "アウトバウンドインターフェース",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("クリア"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("設定に従う"),
    "internet": MessageLookupByLibrary.simpleMessage("インターネット"),
    "interval": MessageLookupByLibrary.simpleMessage("間隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("イントラネットIP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("無効なバックアップファイル"),
    "invalidPolicy": m46,
    "invalidProxy": m47,
    "invalidProxyProvider": m48,
    "invalidSubRule": m49,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、IPv6トラフィックを受信できます",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("IPv6インバウンドを許可します"),
    "ja": MessageLookupByLibrary.simpleMessage("日本語"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCPキープアライブ間隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "kk": MessageLookupByLibrary.simpleMessage("カザフ語"),
    "ko": MessageLookupByLibrary.simpleMessage("韓国語"),
    "lanProfileImport": MessageLookupByLibrary.simpleMessage("スマートフォンから受信"),
    "lanProfileImportAddress": m50,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルネットワーク経由でスマートフォンからサブスクリプションを送信する一回限りのページを表示します",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポートできませんでした",
    ),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションを受信しました",
    ),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポート中…",
    ),
    "lanProfileImportPhoneFailed": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポートできませんでした。URL を確認して再試行してください。",
    ),
    "lanProfileImportPhoneHint": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション URL を貼り付けて、テレビにインポートします。",
    ),
    "lanProfileImportPhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポートしました。テレビに戻り、このページを閉じてください。",
    ),
    "lanProfileImportPhoneUnreachable": MessageLookupByLibrary.simpleMessage(
      "テレビに接続できませんでした。接続を確認し、このページで再試行して結果を確認してください。",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "同じネットワーク上のスマートフォンでこの QR コードをスキャンし、サブスクリプション URL を貼り付けてください",
    ),
    "lanProfileImportSend": MessageLookupByLibrary.simpleMessage("テレビにインポート"),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "ローカル共有を開始できませんでした",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "一回限りのリンクの有効期限が切れました",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションを受信",
    ),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションを待機中…",
    ),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "lastUsed": MessageLookupByLibrary.simpleMessage("最終使用"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("起動が完了しませんでした"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "前回、アプリは起動中に予期せず終了しました。今回の自動セットアップはスキップしました。手動で起動して再試行できます。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "level": MessageLookupByLibrary.simpleMessage("レベル"),
    "license": MessageLookupByLibrary.simpleMessage("ライセンス"),
    "licenses": MessageLookupByLibrary.simpleMessage("ライセンス一覧"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("アプリに同梱されているパッケージ"),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "lightAt": MessageLookupByLibrary.simpleMessage("ライト切替"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リッスン"),
    "loading": MessageLookupByLibrary.simpleMessage("読み込み中..."),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルにデータをバックアップします",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置情報の権限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が拒否されたため、現在の Wi-Fi 名を取得できません。システム設定で位置情報の権限を手動で有効にしてください。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "システムの要件により、Wi-Fi 名の取得には位置情報の権限が必要です。Android では「常に許可」を選択してください。そうしないと、アプリがバックグラウンドにあるときに Wi-Fi 名を取得できません。",
    ),
    "locationPermissionGuide": m51,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が必要です",
    ),
    "log": MessageLookupByLibrary.simpleMessage("ログ"),
    "logLevel": MessageLookupByLibrary.simpleMessage("ログレベル"),
    "logcat": MessageLookupByLibrary.simpleMessage("ログキャプチャ"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("無効にするとログの入り口が非表示になります"),
    "logs": MessageLookupByLibrary.simpleMessage("ログ"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("キャプチャしたログの記録"),
    "logsTest": MessageLookupByLibrary.simpleMessage("ログテスト"),
    "loopback": MessageLookupByLibrary.simpleMessage("ループバック解除ツール"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("UWPのループバック解除に使用します"),
    "loose": MessageLookupByLibrary.simpleMessage("ゆったり"),
    "madeBy": MessageLookupByLibrary.simpleMessage("制作"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("送信元IPにマッチ"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET を対象にしたルールの行き先。既定ではこのプロファイル末尾の MATCH ルールのターゲットを使います。",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("マッチ先"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失敗回数"),
    "maxLengthTip": m52,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memory": MessageLookupByLibrary.simpleMessage("Memory"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("これはメッセージです。"),
    "metaInfo": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "milestoneDecorations": MessageLookupByLibrary.simpleMessage("隠された発見"),
    "milestoneDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash の使用中に獲得した発見を表示します",
    ),
    "milestoneRevealAuscultation": MessageLookupByLibrary.simpleMessage(
      "百回の検査。ネットワークには脈がある。",
    ),
    "milestoneRevealCrown": MessageLookupByLibrary.simpleMessage(
      "保護された時間、一年分。",
    ),
    "milestoneRevealFullLadder": MessageLookupByLibrary.simpleMessage(
      "すべての段を上り、最初の段へ。",
    ),
    "milestoneRevealMeridian": MessageLookupByLibrary.simpleMessage(
      "五つの子午線を越えた。",
    ),
    "milestoneRevealOdometer": MessageLookupByLibrary.simpleMessage(
      "一テラバイトが通過した。",
    ),
    "milestoneRevealPorcelain": MessageLookupByLibrary.simpleMessage("静かな七日間。"),
    "milestoneRevealSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "千回の判断、介入なし。",
    ),
    "milestoneRevealVigil": MessageLookupByLibrary.simpleMessage("途切れずに九十日。"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("終了時に最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "システム標準の終了動作を変更します",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("分"),
    "minutesAgo": m54,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("分"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("分"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixedポート"),
    "mode": MessageLookupByLibrary.simpleMessage("モード"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "monthsAgo": m55,
    "more": MessageLookupByLibrary.simpleMessage("その他"),
    "moveDown": MessageLookupByLibrary.simpleMessage("下へ移動"),
    "moveToBottom": MessageLookupByLibrary.simpleMessage("末尾へ移動"),
    "moveToTop": MessageLookupByLibrary.simpleMessage("先頭へ移動"),
    "moveUp": MessageLookupByLibrary.simpleMessage("上へ移動"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "複数の値はカンマで区切ってください",
    ),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameserver": MessageLookupByLibrary.simpleMessage("ネームサーバー"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("ドメインの名前解決に使用します"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("ネームサーバーポリシー"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインごとのネームサーバーポリシーを指定します",
    ),
    "network": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "networkDefaultLanBypass": MessageLookupByLibrary.simpleMessage(
      "カスタムルートがない場合、ローカルネットワークは VPN を経由しません。VPN を経由させるにはルートを明示的に設定してください。",
    ),
    "networkDesc": MessageLookupByLibrary.simpleMessage("ネットワーク関連の設定を変更します"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("ネットワーク検出"),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID（自宅Wi-Fi）またはサブネット（192.168.1.0/24）",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "ネットワークエラーです。接続を確認してから再試行してください",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("ネットワーク速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワーク種別"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage("信頼できるネットワークがありません"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("ニュートラル"),
    "neverUsed": MessageLookupByLibrary.simpleMessage("まだ使用されていません"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("新しいデザイン"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage("接続リングと下部のトラフィック"),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("新しい"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("次の一致"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("お知らせはありません"),
    "noData": MessageLookupByLibrary.simpleMessage("データがありません"),
    "noFilterCondition": MessageLookupByLibrary.simpleMessage("フィルター条件なし"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("ホットキーはまだありません"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報がありません"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("今後表示しない"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークがありません"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("ネットワーク不使用アプリ"),
    "noRecords": MessageLookupByLibrary.simpleMessage("記録がありません"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IPを解決しない"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("ホスト名を解決しない"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("一致する結果はありません"),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループは選択できません",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "現在のネットワークは信頼されていません",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("通知"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "コンポーネントを追加",
    ),
    "notificationAndroidOnly": MessageLookupByLibrary.simpleMessage(
      "Android で利用できます",
    ),
    "notificationAndroidOnlyDesc": MessageLookupByLibrary.simpleMessage(
      "フォアグラウンド通知の設定は Android VPN サービスにのみ適用されます。",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "自動グループ",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "サーバーグループが確定していないため、この行は表示されません",
    ),
    "notificationBlockedSmartRoutingOff": MessageLookupByLibrary.simpleMessage(
      "スマートルーティングが無効のため、この行は表示されません",
    ),
    "notificationComponentBehaviour": MessageLookupByLibrary.simpleMessage(
      "動作",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage("通知コンポーネント"),
    "notificationComponentsActive": MessageLookupByLibrary.simpleMessage(
      "通知に表示",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "リアルタイムのステータス部品で通知を構成します。",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "コンポーネントはありません",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "コンポーネントがない場合、通知は保護状態のみを表示します。",
    ),
    "notificationComponentsOrderHint": MessageLookupByLibrary.simpleMessage(
      "行はこの順序で並びます。折りたたみ時は最初のデータ行が表示されます。",
    ),
    "notificationConnectionDoctor": MessageLookupByLibrary.simpleMessage(
      "接続ドクター",
    ),
    "notificationConnectionDoctorDesc": MessageLookupByLibrary.simpleMessage(
      "接続診断の判定を表示します",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("内容"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "現在のサーバー",
    ),
    "notificationCurrentServerDesc": MessageLookupByLibrary.simpleMessage(
      "グループで選択中のノードを表示します",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android 通知の配信",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android の通知アクセスを確認しています",
    ),
    "notificationDeliveryFix": MessageLookupByLibrary.simpleMessage("修正"),
    "notificationDeliveryOff": MessageLookupByLibrary.simpleMessage(
      "システム設定で通知がオフになっています",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage("ReClash の通知はブロックされています"),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "通知を配信できます",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash サービスチャンネルは無効です",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage("サブスクリプション通知チャンネルは無効です"),
    "notificationDetailedDesc": MessageLookupByLibrary.simpleMessage(
      "ライブのステータス行、クイック操作、ステータスバーのアイコンを表示します",
    ),
    "notificationDoctorPriority": MessageLookupByLibrary.simpleMessage(
      "接続ドクターの優先度",
    ),
    "notificationDoctorPriorityAlways": MessageLookupByLibrary.simpleMessage(
      "常に",
    ),
    "notificationDoctorPriorityProblems": MessageLookupByLibrary.simpleMessage(
      "問題がある場合のみ",
    ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "アイドル時の速度を隠す",
    ),
    "notificationHideIdleSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "通信がない間は速度を表示しません",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "ロック画面で機密情報を隠す",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "端末のロック中はプロファイル、ルーティング、診断の詳細を隠します",
    ),
    "notificationMinimalDesc": MessageLookupByLibrary.simpleMessage(
      "保護状態のみを表示し、詳細情報やクイック操作は表示しません",
    ),
    "notificationMoveDown": MessageLookupByLibrary.simpleMessage("下へ移動"),
    "notificationMoveUp": MessageLookupByLibrary.simpleMessage("上へ移動"),
    "notificationNetworkNormal": MessageLookupByLibrary.simpleMessage("正常"),
    "notificationNetworkOffline": MessageLookupByLibrary.simpleMessage("オフライン"),
    "notificationNetworkPortal": MessageLookupByLibrary.simpleMessage(
      "キャプティブポータル",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "ネットワーク速度",
    ),
    "notificationNetworkSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "現在のアップロードとダウンロード速度を表示します",
    ),
    "notificationNetworkState": MessageLookupByLibrary.simpleMessage(
      "ネットワーク状態",
    ),
    "notificationNetworkStateDesc": MessageLookupByLibrary.simpleMessage(
      "現在の RCX ネットワーク状況を表示します",
    ),
    "notificationNetworkUnknown": MessageLookupByLibrary.simpleMessage("不明"),
    "notificationNetworkWhitelist": MessageLookupByLibrary.simpleMessage(
      "許可リスト",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("プライバシー"),
    "notificationProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "常駐通知で保護が有効かどうかを確認できます。",
    ),
    "notificationProtectionTitle": MessageLookupByLibrary.simpleMessage(
      "保護の状態",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("リマインダー"),
    "notificationRemindersDesc": MessageLookupByLibrary.simpleMessage(
      "リマインダーは専用チャンネルを使い、どの通知レベルでも届きます。",
    ),
    "notificationRemoveComponent": MessageLookupByLibrary.simpleMessage(
      "通知から削除",
    ),
    "notificationReorder": MessageLookupByLibrary.simpleMessage("並べ替え"),
    "notificationSelectServerGroup": MessageLookupByLibrary.simpleMessage(
      "サーバーグループを選択",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "選択したグループがプロファイルにありません",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "サービスチャンネル",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "セッショントラフィック",
    ),
    "notificationSessionTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "このセッションのアップロード量とダウンロード量を表示します",
    ),
    "notificationSmartRouting": MessageLookupByLibrary.simpleMessage(
      "スマートルーティング",
    ),
    "notificationSmartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "現在のスマートルーティングの判断を表示します",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション通知チャンネル",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション通知",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage("サブスクリプションへの対応が必要なときに通知します"),
    "notificationTurnOff": MessageLookupByLibrary.simpleMessage("通知をオフにする"),
    "notificationTurnOffDesc": MessageLookupByLibrary.simpleMessage(
      "保護の実行中、Android は通知を必要とします。システム設定を開いてこのチャンネルを無効にできます。",
    ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage("通知レベル"),
    "notificationVisibilityAlways": MessageLookupByLibrary.simpleMessage(
      "常に表示",
    ),
    "notificationVisibilityCurrentServer": MessageLookupByLibrary.simpleMessage(
      "サーバーグループが確定しているときに表示",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "詳細",
    ),
    "notificationVisibilityDoctorProblems":
        MessageLookupByLibrary.simpleMessage("問題が検出されたときに表示"),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage("最小"),
    "notificationVisibilitySessionTraffic":
        MessageLookupByLibrary.simpleMessage("セッションに通信があるときに表示"),
    "notificationVisibilitySmartRoutingOn":
        MessageLookupByLibrary.simpleMessage("スマートルーティングが有効なときに表示"),
    "notificationVisibilitySpeedIdle": MessageLookupByLibrary.simpleMessage(
      "通信がないときは非表示",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルがありません。先にプロファイルを追加してください",
    ),
    "nullTip": m56,
    "numberTip": m57,
    "off": MessageLookupByLibrary.simpleMessage("オフ"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("アイコンのみ"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("プロキシのみ集計"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロキシのトラフィックのみを集計します",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("ブラウザーで開く"),
    "optional": MessageLookupByLibrary.simpleMessage("任意"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("その他の貢献者"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "override": MessageLookupByLibrary.simpleMessage("上書き"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNSを上書き"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロファイル内のDNS設定を上書きします",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("上書きモード"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "ネットワーク設定を上書き",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの値ではなく、アプリのポート、IPv6、allow-lan、find-process-mode、TUN スタックを適用する",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage("上書きスクリプト"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "カスタムモード：プロキシグループとルールを完全にカスタマイズできます",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("ページアニメーション"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage("ページ切替をアニメーション化"),
    "palette": MessageLookupByLibrary.simpleMessage("パレット"),
    "panelHwidIdentityDisabled": MessageLookupByLibrary.simpleMessage(
      "HWID の送信は無効です。パネルを信頼できる場合にのみ有効にしてください。",
    ),
    "panelHwidNotSupported": MessageLookupByLibrary.simpleMessage(
      "パネルが HWID の制限を報告しました",
    ),
    "panelHwidNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "パネルが x-hwid-not-supported を返しました。これだけではクライアントの非互換性は判断できません。HWID の設定とサブスクリプションの条件を確認してください。",
    ),
    "panelSettingsConfirmMessage": m58,
    "panelSettingsConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "プロバイダー設定を適用",
    ),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "paste": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "pause": MessageLookupByLibrary.simpleMessage("一時停止"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("VPNを一時停止しています..."),
    "paused": MessageLookupByLibrary.simpleMessage("一時停止中"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage(
      "無期限サブスクリプション",
    ),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("アルバムから選択"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("ネットワークを選択"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage("周囲の Wi-Fi ネットワーク"),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi ネットワークが見つかりません",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "近くの Wi-Fi ネットワークを一覧表示するには位置情報の権限が必要です",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("更新"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "近くの Wi-Fi ネットワークを検索中…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("最前面に固定"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAVを連携してください"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "スクリプト名を入力してください",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "有効なQRコードをアップロードしてください",
    ),
    "porcelainThemeDesc": MessageLookupByLibrary.simpleMessage(
      "冷たく、ほぼモノクロの配色を適用",
    ),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("別のポートを入力してください"),
    "portTip": m59,
    "predictiveBack": MessageLookupByLibrary.simpleMessage("予測型戻る"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("DoHでHTTP/3を優先します"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前提条件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("キーを押してください"),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("前の一致"),
    "process": MessageLookupByLibrary.simpleMessage("プロセス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な間隔を入力してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("自動更新間隔を入力してください"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されています。自動更新を無効にしますか？",
    ),
    "profileImportEmptyResponse": MessageLookupByLibrary.simpleMessage(
      "サーバーから空のプロファイルが返されました",
    ),
    "profileImportFailed": MessageLookupByLibrary.simpleMessage(
      "プロファイルをインポートできませんでした",
    ),
    "profileImportFileReadFailed": MessageLookupByLibrary.simpleMessage(
      "選択したファイルを読み込めませんでした",
    ),
    "profileImportFormatClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "profileImportFormatLinks": MessageLookupByLibrary.simpleMessage("共有リンク"),
    "profileImportFormatSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box",
    ),
    "profileImportFormatWireguard": MessageLookupByLibrary.simpleMessage(
      "WireGuard",
    ),
    "profileImportFormatXray": MessageLookupByLibrary.simpleMessage("Xray"),
    "profileImportInvalidConfig": MessageLookupByLibrary.simpleMessage(
      "プロファイル設定が正しくありません",
    ),
    "profileImportSkippedNodes": m60,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage(
      "プロファイルをインポートしました",
    ),
    "profileImportSuccessSummary": m61,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "インポートリンクが破損しているか、サポートされていません",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル名を入力してください",
    ),
    "profileUnusedForDays": m62,
    "profileUnusedForMonths": m63,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルのURLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイルの並べ替え"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "providerEffects": MessageLookupByLibrary.simpleMessage("プロバイダー効果"),
    "providerEffectsDesc": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションがホーム画面に装飾効果を追加できるようにします",
    ),
    "providerView": MessageLookupByLibrary.simpleMessage("プロバイダーのビュー"),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションにプロキシ画面の外観を任せます。自分で変更した項目は保持されます。",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("外部リソース"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxiesCount": m64,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("プロキシが空です"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "選択したプロキシに異常が見つかりました",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("ノードフィルター"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループに異常が見つかりました",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("プロキシグループが空です"),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名が重複しています",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名は空にできません",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("プロキシネームサーバー"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシノードのドメイン解決に使用します",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "選択したプロキシプロバイダーに異常が見つかりました",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーが空です",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーは空にできません",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("プロキシタイプ"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("キャッシュを整理"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("ピュアブラックモード"),
    "qrScanUnsupported": MessageLookupByLibrary.simpleMessage(
      "このデバイスではQRコードのスキャンに対応していません。",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QRコードをスキャンしてプロファイルを取得します",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("クイック入力"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("レインボー"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直す"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("モーションを減らす"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage("装飾アニメーションを無効化"),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage(
      "システム設定で既に有効です",
    ),
    "regexSearch": MessageLookupByLibrary.simpleMessage("正規表現検索"),
    "reload": MessageLookupByLibrary.simpleMessage("再読み込み"),
    "remaining": MessageLookupByLibrary.simpleMessage("残り"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("残り"),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVにデータをバックアップします",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "remove": MessageLookupByLibrary.simpleMessage("削除"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("サブスクリプションを更新"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("最近のリクエスト記録を表示します"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetFindings": MessageLookupByLibrary.simpleMessage("発見をリセット"),
    "resetFindingsConfirm": MessageLookupByLibrary.simpleMessage(
      "発見済みの項目は非表示になり、再び現れるようになります。使用履歴は変わりません。",
    ),
    "resetFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "使用履歴を消さず、発見の瞬間をもう一度表示します",
    ),
    "resetFindingsTitle": MessageLookupByLibrary.simpleMessage("発見をリセットしますか？"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "このページには変更があります。リセットしてもよろしいですか？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("リセットしてもよろしいですか？"),
    "resources": MessageLookupByLibrary.simpleMessage("リソース"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部リソースの関連情報"),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルールに従う"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS接続がルールに従います。proxy-server-nameserverの設定が必要です",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("再起動"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("コアを再起動してもよろしいですか？"),
    "restore": MessageLookupByLibrary.simpleMessage("復元"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("すべてのデータを復元"),
    "restoreException": MessageLookupByLibrary.simpleMessage("復元エラー"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "ファイルからデータを復元します",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVからデータを復元します",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("プロファイルのみ復元"),
    "restorePreviewDescription": MessageLookupByLibrary.simpleMessage(
      "確認するまで変更は行われません。",
    ),
    "restorePreviewTitle": MessageLookupByLibrary.simpleMessage("復元内容の確認"),
    "restoreProfilesCount": m65,
    "restoreProxyGroupsCount": m66,
    "restoreRulesCount": m67,
    "restoreScriptsCount": m68,
    "restoreSettingsIncluded": MessageLookupByLibrary.simpleMessage("設定を含む"),
    "restoreSettingsNotIncluded": MessageLookupByLibrary.simpleMessage(
      "このバックアップには設定がありません",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("復元方式"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("互換"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("上書き"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("復元が完了しました"),
    "resume": MessageLookupByLibrary.simpleMessage("再開"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("作者・メンテナー"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("ルートアドレス"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "リッスンするルートアドレスを設定します",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("ルートモード"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "プライベートアドレスをバイパス",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("設定を使用"),
    "ru": MessageLookupByLibrary.simpleMessage("ロシア語"),
    "rule": MessageLookupByLibrary.simpleMessage("ルール"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("論理ルール AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("完全なドメインにマッチ"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインキーワードにマッチ",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインの正規表現でマッチ",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインサフィックスにマッチ",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "ワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCPマークにマッチ（tproxy udpインバウンドのみ）",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "宛先ポート範囲にマッチ",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("IPの国コードにマッチ"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite 内のドメインにマッチ",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("インバウンド名にマッチ"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドポートにマッチ",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドタイプにマッチ",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドユーザー名にマッチ（/ で複数指定可）",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IPが属するASNにマッチ",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IPアドレス範囲にマッチ（IP-CIDR6 は別名です）",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IPアドレス範囲にマッチ",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IPサフィックス範囲にマッチ",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "すべてのリクエストにマッチ（条件不要）",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCPまたはUDPにマッチ",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("論理ルール NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("論理ルール OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名でマッチ（Androidではパッケージ名にマッチ）",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名の正規表現でマッチ（Androidではパッケージ名にマッチ）",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名のワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスのフルパスでマッチ",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスパスの正規表現でマッチ",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスパスのワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "再マッチ名にマッチ（複数は / で区切る）",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "ルールセットを参照します。rule-providersの設定が必要です",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPの国コードにマッチ",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPが属するASNにマッチ",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPアドレス範囲にマッチ",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPサフィックス範囲にマッチ",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "送信元ポート範囲にマッチ",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "サブルールへマッチします。括弧の使い方に注意してください",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "LinuxのユーザーIDにマッチ",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("ルールが空です"),
    "ruleName": MessageLookupByLibrary.simpleMessage("ルール名"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("ルールセット"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルールターゲット"),
    "rules": MessageLookupByLibrary.simpleMessage("ルール"),
    "rulesCount": m69,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "schedule": MessageLookupByLibrary.simpleMessage("スケジュール"),
    "scheduleDesc": m70,
    "script": MessageLookupByLibrary.simpleMessage("スクリプト"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "スクリプトモード：外部の拡張スクリプトを使用し、ワンクリックで設定を上書きします",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("選択項目へスクロール"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "searchApps": MessageLookupByLibrary.simpleMessage("アプリを検索"),
    "seasonBirthdayNote": MessageLookupByLibrary.simpleMessage(
      "今日は ReClash の誕生日です。",
    ),
    "seasonFirstRunNote": MessageLookupByLibrary.simpleMessage(
      "今日は初回起動の周年記念日です。",
    ),
    "seasonalDecorations": MessageLookupByLibrary.simpleMessage("季節の外観"),
    "seasonalDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "ホーム画面にさりげない季節の装飾を表示します",
    ),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m71,
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET を選択",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage("プロキシを選択"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーを選択",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("ルールセットを選択してください"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略を選択してください",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage("サブルールを選択してください"),
    "selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "selectedCountTitle": m72,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("HWID を送信"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "デバイス識別子・アプリのバージョン・端末名をプロバイダーのサーバーに送信します",
    ),
    "sendDeviceIdentityDisableWarning": MessageLookupByLibrary.simpleMessage(
      "HWID の送信をオフにすると、ほとんどのサブスクリプションが使えなくなります。続行しますか？",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("サービス"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage("さらに追加"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage("ReClash 起動時に接続"),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルの読み込み後、VPN を自動的に開始します",
    ),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "自動接続を有効にするにはプロファイルを追加してください",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("戻る"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "プロファイルなしで続行",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN はオフのままです。後から追加するか、VPN プロバイダー不要の ByeDPI 専用モードを利用できます。",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "任意のクラッシュレポートを送信",
    ),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "アプリの不具合調査に役立ちます。有効にしない限り送信されません。",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage("同意せず終了"),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("削除"),
    "setupDone": MessageLookupByLibrary.simpleMessage("完了"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage("完了して接続"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("設定内容を確認"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage("後から設定で変更できます"),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("言語を選択"),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage("免責事項をすべて読む"),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage("オープンソースライセンス"),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash は通信を経路制御するため、端末内に VPN 接続を作成します。設定やプロバイダーはご自身で選び、その利用にはご自身が責任を負います。",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage("続行する前に"),
    "setupNext": MessageLookupByLibrary.simpleMessage("次へ"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage("バッテリー最適化"),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンドでも VPN を維持できるようにします",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage("確認中…"),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage("初回接続時に確認"),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage("未許可"),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage("確認できませんでした"),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage("許可済み"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage("通知"),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash の動作中に接続状態を表示します",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
      "設定を開く",
    ),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage("許可する"),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage("利用不可"),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage("VPN の許可"),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "初回接続時にシステムが確認します",
    ),
    "setupPermissionsTitle": MessageLookupByLibrary.simpleMessage("権限"),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash は VPN サービスを販売していません。信頼できるプロバイダーのリンク、QR コード、設定ファイルを使ってください。保存前に内容を検証します。",
    ),
    "setupProfilesReady": m73,
    "setupRawConfig": MessageLookupByLibrary.simpleMessage("設定テキスト"),
    "setupRawConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash 互換の YAML 設定を貼り付けます",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークの地域を選択してください。ロシアを選ぶと HWID が有効になりますが、下で無効にできます。スマートルーティングは別に設定します。",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("その他"),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage("言語からのおすすめ"),
    "setupRegionSettings": MessageLookupByLibrary.simpleMessage("地域のクイック設定"),
    "setupRegionSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "地域データ、ルーティングプリセット、アプリのアクセスを確認します。自動では追加されません。",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "現在のネットワークはどの地域ですか？",
    ),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("置き換え"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "新しいプロファイルの読み込みと検証が成功してから現在のものを削除します。",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage("初期設定をもう一度実行"),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "データを削除せず、言語、プロファイル、経路、権限を見直します",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage("バックアップから復元"),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash、FlClashX、FlClash のバックアップから設定とプロファイルを復元",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("プロファイルなしで続行"),
    "setupStepProgress": m74,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルには接続に必要なサーバーとルールが含まれます。プロバイダーまたはバックアップから読み込んでください。",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "プロファイルの準備完了",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "接続プロファイルを追加",
    ),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage("自動接続：オフ"),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage("自動接続：オン"),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "VPN プロファイルなし — VPN はオフ。ByeDPI 専用モードは利用できます",
    ),
    "setupSummaryProfile": m75,
    "setupSummaryRouting": m76,
    "setupSummarySystemProxyOff": MessageLookupByLibrary.simpleMessage(
      "システムプロキシ：オフ",
    ),
    "setupSummarySystemProxyOn": MessageLookupByLibrary.simpleMessage(
      "システムプロキシ：オン",
    ),
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage("設定の概要"),
    "setupSummaryTunOff": MessageLookupByLibrary.simpleMessage("TUN：オフ"),
    "setupSummaryTunOn": MessageLookupByLibrary.simpleMessage("TUN：オン"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage("システムの言語"),
    "setupSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "管理者権限なしで対応アプリの通信を ReClash 経由にします",
    ),
    "setupTunDesc": MessageLookupByLibrary.simpleMessage(
      "デバイス全体の通信を転送します。接続時に管理者権限を求められる場合があります",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage("わかりやすい手順ですぐに準備できます"),
    "show": MessageLookupByLibrary.simpleMessage("表示"),
    "showLabels": MessageLookupByLibrary.simpleMessage("サイドバーのラベル"),
    "showLess": MessageLookupByLibrary.simpleMessage("折りたたむ"),
    "showMore": MessageLookupByLibrary.simpleMessage("展開"),
    "showPassword": MessageLookupByLibrary.simpleMessage("パスワードを表示"),
    "shrink": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("サイレント起動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("バックグラウンドで起動します"),
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "smartPause": MessageLookupByLibrary.simpleMessage("スマート一時停止"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage(
      "接続を切断する",
    ),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "信頼できるネットワークで自動的にVPNを一時停止します",
    ),
    "smartRouting": MessageLookupByLibrary.simpleMessage("スマートルーティング"),
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "一時保留中のプロバイダー",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "一時保留中のチェック",
    ),
    "smartRoutingAdmittedYes": MessageLookupByLibrary.simpleMessage("対象"),
    "smartRoutingAliveCount": m77,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage("すべてのサーバー"),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage("可用性"),
    "smartRoutingAvailabilityValue": m78,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "平均の切り替え",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "平均復旧時間",
    ),
    "smartRoutingAvoidCountries": MessageLookupByLibrary.simpleMessage(
      "出口国を回避",
    ),
    "smartRoutingAvoidCountriesDesc": MessageLookupByLibrary.simpleMessage(
      "実測した出口がこれらの国のサーバーは、最終手段でも決して経由しません",
    ),
    "smartRoutingAxisData": MessageLookupByLibrary.simpleMessage("通信量の節約"),
    "smartRoutingAxisSpeed": MessageLookupByLibrary.simpleMessage("速度"),
    "smartRoutingAxisStability": MessageLookupByLibrary.simpleMessage("安定性"),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage("自動選択に戻す"),
    "smartRoutingBackup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "smartRoutingBandInvalid": MessageLookupByLibrary.simpleMessage(
      "正のミリ秒数を入力してください",
    ),
    "smartRoutingBandLabel": m79,
    "smartRoutingBands": m80,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("動作"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "現在のサーバー一覧にありません",
    ),
    "smartRoutingBlockAvoidExit": MessageLookupByLibrary.simpleMessage(
      "回避対象の国から出ています",
    ),
    "smartRoutingBlockCooling": m81,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "ここでは検査に通りませんでした",
    ),
    "smartRoutingBlockIgnored": MessageLookupByLibrary.simpleMessage(
      "ルールにより無視",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "国内サーバー。このネットワークでは使いません",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage("UDP 非対応"),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "独立した複数の障害によりプロバイダーを一時保留中",
    ),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "このネットワークではまだ経路がありません",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage("ホワイトリスト用"),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "制限されたネットワーク用に確保し、開放網では使いません",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "ホワイトリスト専用サーバー名",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "制限された網向けに用意されたサーバーを示す名前の断片",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage("カナリアアドレス"),
    "smartRoutingCanariesAnswered": m82,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "国内カナリア",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "直接接続して、ホワイトリスト網と完全な不通を見分けます",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "海外カナリア",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "IP:ポートへ直接接続し、開放されたネットワークと遮断を見分けます",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage("国内"),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage("海外"),
    "smartRoutingCeiling": MessageLookupByLibrary.simpleMessage("遅延の上限"),
    "smartRoutingCeilingDesc": MessageLookupByLibrary.simpleMessage(
      "動作中のサーバーでも遅延がこの上限を超えたら切り替える",
    ),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage("検閲のある国"),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "その地域のサーバーは国内扱いになり、遮断時まで使われません",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage("選択中のサーバー"),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "まだサーバーが選ばれていません",
    ),
    "smartRoutingCoolFor": m83,
    "smartRoutingCountryEchoes": MessageLookupByLibrary.simpleMessage(
      "国判定サービス",
    ),
    "smartRoutingCountryEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "疑わしいノードの検証時にサーバーの実際の出口国を報告するエンドポイント",
    ),
    "smartRoutingCountryNoMatch": MessageLookupByLibrary.simpleMessage(
      "一致する国コードがありません",
    ),
    "smartRoutingCountryPolicy": MessageLookupByLibrary.simpleMessage("国別ポリシー"),
    "smartRoutingCountryPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "どの国を検閲国とみなし、どの国を出口として避けるか",
    ),
    "smartRoutingCountrySearch": MessageLookupByLibrary.simpleMessage(
      "国コードで検索",
    ),
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage("すべてのサーバーを検査"),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "検査の上限を無視するため通信量がかかります",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "すべてのサーバーを検査中…",
    ),
    "smartRoutingDegradeConfirm": MessageLookupByLibrary.simpleMessage(
      "スロットル確認時間",
    ),
    "smartRoutingDegradeConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーを切り替える前に通信の劣化が続く時間",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("帯域制限中"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "アプリを開かなくても、ネットワークごとに使えるサーバーを選び続けます",
    ),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage(
      "遮断中は国内サーバーを使う",
    ),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "ホワイトリスト網での最後の手段。国内サービスだけは使えます",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "国内サービスは直接接続",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "国内サービスは選択したサーバー経由",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage("維持時間"),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "より速いサーバーに切り替わるまで、使えるサーバーを保つ時間",
    ),
    "smartRoutingEgress": MessageLookupByLibrary.simpleMessage("出口の検証"),
    "smartRoutingEgressDesc": MessageLookupByLibrary.simpleMessage(
      "偽装サーバーが実際にどこで出口となるかを明らかにするサービス",
    ),
    "smartRoutingEgressEchoes": MessageLookupByLibrary.simpleMessage(
      "出口エコーサービス",
    ),
    "smartRoutingEgressEchoesDesc": MessageLookupByLibrary.simpleMessage(
      "呼び出し元のアドレスを返し、偽装サーバーの実際の出口を明らかにするエンドポイント",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage("まだ測定結果がありません"),
    "smartRoutingEngineAvailable": MessageLookupByLibrary.simpleMessage(
      "経路が使えた時間",
    ),
    "smartRoutingEngineDeepScan": MessageLookupByLibrary.simpleMessage("全件検査"),
    "smartRoutingEngineLanes": MessageLookupByLibrary.simpleMessage("サービスレーン"),
    "smartRoutingEngineLinkAge": MessageLookupByLibrary.simpleMessage(
      "回線の経過時間",
    ),
    "smartRoutingEngineMode": MessageLookupByLibrary.simpleMessage("コアのモード"),
    "smartRoutingEnginePin": MessageLookupByLibrary.simpleMessage("固定したサーバー"),
    "smartRoutingEnginePreset": MessageLookupByLibrary.simpleMessage("地域プリセット"),
    "smartRoutingEngineReportAge": MessageLookupByLibrary.simpleMessage(
      "レポートの経過時間",
    ),
    "smartRoutingEngineTerrain": MessageLookupByLibrary.simpleMessage(
      "ネットワーク種別コード",
    ),
    "smartRoutingEngineTransport": MessageLookupByLibrary.simpleMessage(
      "回線の種類",
    ),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage("ネットワーク記憶キー"),
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "国内のアドレスは応答しませんでした",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "国内のアドレスが応答しました",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "海外のアドレスは応答しませんでした",
    ),
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "ゲートが偽造証明書で応答しました",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "海外のアドレスが証明書検証を通過しました",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "最近の検査で確認済み",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "自分の通信で確認済み",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage("未確認"),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "システムがサインインページを検出しました",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "確認したのは少し前です",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "システムはインターネットなしと報告しています",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "システムがインターネット接続を確認しました",
    ),
    "smartRoutingExport": MessageLookupByLibrary.simpleMessage("設定をエクスポート"),
    "smartRoutingExportDesc": MessageLookupByLibrary.simpleMessage(
      "スマートルーティング設定全体をファイルに保存",
    ),
    "smartRoutingExported": MessageLookupByLibrary.simpleMessage(
      "スマートルーティング設定をエクスポートしました",
    ),
    "smartRoutingFails": m84,
    "smartRoutingFieldReset": MessageLookupByLibrary.simpleMessage(
      "戦略の既定値にリセット",
    ),
    "smartRoutingFitNo": MessageLookupByLibrary.simpleMessage("不適合"),
    "smartRoutingFitYes": MessageLookupByLibrary.simpleMessage("適合"),
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage("接続なし"),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "国内も海外も応答しません",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage("完全に開放"),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "あなたと開かれたインターネットの間に遮断はありません",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage(
      "サインインが必要",
    ),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "通信を通す前にログインを求めるネットワークです",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage(
      "制限あり",
    ),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "国内サービスだけが応答し、海外は応答しません",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage("計測中"),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "判断するには応答がまだ足りません",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage("除外"),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage("未確認"),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("使用可"),
    "smartRoutingHeuristics": MessageLookupByLibrary.simpleMessage("ノードの推定ルール"),
    "smartRoutingHeuristicsDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーの選び方を左右する名前のヒントとルール",
    ),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage("最近の切り替え"),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "まだ切り替えはありません",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage("遅延テストの値"),
    "smartRoutingImport": MessageLookupByLibrary.simpleMessage("設定をインポート"),
    "smartRoutingImportDesc": MessageLookupByLibrary.simpleMessage(
      "スマートルーティング設定をファイルから置き換え",
    ),
    "smartRoutingImportFailed": MessageLookupByLibrary.simpleMessage(
      "その設定ファイルを読み取れませんでした",
    ),
    "smartRoutingImported": MessageLookupByLibrary.simpleMessage(
      "スマートルーティング設定をインポートしました",
    ),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage("検出された障害"),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage("挑戦側"),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage("使用中"),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("維持"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage("比較の対象"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("遅延帯"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("証拠"),
    "smartRoutingKeyHomeRisk": MessageLookupByLibrary.simpleMessage("国外に出る"),
    "smartRoutingKeyIncumbent": MessageLookupByLibrary.simpleMessage("使用中"),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage("ネットワーク適合"),
    "smartRoutingKeyTiebreak": MessageLookupByLibrary.simpleMessage("安定した同点処理"),
    "smartRoutingKeyUnproven": MessageLookupByLibrary.simpleMessage("通信の実績"),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("判定"),
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "2 つのサーバーを 1 行ずつ読み比べます。最初に違いが出た行で決まり、それより下の行は一切読みません。",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage("直近の切り替え"),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage("直近の復旧時間"),
    "smartRoutingLatencyBands": MessageLookupByLibrary.simpleMessage(
      "レイテンシの階層",
    ),
    "smartRoutingLatencyBandsDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーを速度ティアに分けるミリ秒の境界。空欄の場合は戦略の既定値を使用します",
    ),
    "smartRoutingLostAt": m85,
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "手動の選択を尊重する",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "選んだサーバーが機能しなくなるまで維持する",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "機能しなくなるまで維持",
    ),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "隔離されたサービスチェック",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "許容ステータス",
    ),
    "smartRoutingMarkerStatusesDesc": MessageLookupByLibrary.simpleMessage(
      "このチェックの成功と見なす HTTP ステータスコード",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "カンマ区切り、例: 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "HTTP ステータスコードをカンマ区切りで入力してください",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkerUrlDesc": MessageLookupByLibrary.simpleMessage(
      "このチェックを確認するためにプローブが要求する完全な URL",
    ),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage("サービス検査"),
    "smartRoutingMarkersDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーがオープンインターネットや国内サービスに到達できることを証明する URL",
    ),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage(
      "国内向け検査",
    ),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "遮断中に国内サーバーへ使用します",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage(
      "検査が設定されていません",
    ),
    "smartRoutingMarkersLocal": MessageLookupByLibrary.simpleMessage(
      "国内限定チェック",
    ),
    "smartRoutingMarkersLocalDesc": MessageLookupByLibrary.simpleMessage(
      "国内サーバーと判定する前に、国内からのみ応答することを確認",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "オープンインターネット検査",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "これらのステータスのいずれかを返した場合のみ確認済みとみなします",
    ),
    "smartRoutingMeasuredOver": m86,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("従量制の回線"),
    "smartRoutingMillis": m87,
    "smartRoutingMinutes": m88,
    "smartRoutingNameHints": MessageLookupByLibrary.simpleMessage(
      "国内サーバー名のヒント",
    ),
    "smartRoutingNameHintsDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーが国内にあることを示す名前の断片",
    ),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "このネットワークでの切り替えはまだありません",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("応答なし"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage(
      "復旧済みの障害はまだありません",
    ),
    "smartRoutingNoRivals": MessageLookupByLibrary.simpleMessage(
      "比較できる他のサーバーがありません",
    ),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "利用できるサーバーがありません",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage("サーバーチェック"),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("UDP なし"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m89,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage("汎用"),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "スマートルーティングを有効にすると、サーバーを自動で選びます",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage("スマートルーティングは有効です"),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage("ルーティングの概要"),
    "smartRoutingPacing": MessageLookupByLibrary.simpleMessage("ペース"),
    "smartRoutingPacingDesc": MessageLookupByLibrary.simpleMessage(
      "エンジンの反応速度と検査が信頼される期間",
    ),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi へのサインインが必要です",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("プリセット"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("中国"),
    "smartRoutingPresetEdited": m90,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("イラン"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("その他"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("ロシア"),
    "smartRoutingProbeBudget": m91,
    "smartRoutingProbes": MessageLookupByLibrary.simpleMessage("到達性チェック"),
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("検査"),
    "smartRoutingProofTtl": MessageLookupByLibrary.simpleMessage("確認の有効期間"),
    "smartRoutingProofTtlDesc": MessageLookupByLibrary.simpleMessage(
      "再検査までに合格した検査がサーバーを有効に保つ期間",
    ),
    "smartRoutingProvenNo": MessageLookupByLibrary.simpleMessage("まだなし"),
    "smartRoutingProvenYes": MessageLookupByLibrary.simpleMessage("あり"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "プロバイダー保護の作動回数",
    ),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage("比較の順序"),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage("並び順"),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "遅延帯は固定です。ここに調整を置くとミリ秒が可用性を上回ってしまいます",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "このネットワークでの最初の選択",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "前のサーバーが通信を通さなくなりました",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "切り替える前に維持時間を待っています",
    ),
    "smartRoutingReasonHandoffRecovery": MessageLookupByLibrary.simpleMessage(
      "ネットワーク変更後に接続が復旧しました",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "問題なく動作中で、これより良い候補はありません",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "前のサーバーが応答しなくなりました",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "繰り返しの検査で遅延の改善を確認しました",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "あなたが選んだサーバーを尊重しています",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "切り替える前に候補を確認しています",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "検査を通過したサーバーがありません",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "あなたが選んだサーバーが再び使えます",
    ),
    "smartRoutingReasonQualityConfirming": MessageLookupByLibrary.simpleMessage(
      "比較を繰り返して改善を確認しています",
    ),
    "smartRoutingReasonReliabilityGain": MessageLookupByLibrary.simpleMessage(
      "繰り返しの検査でより安定した候補を確認しました",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "到達先がないため現在のサーバーを維持します",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "ネットワークが変わりました",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "こちらは開かれたインターネットへの到達が確認済みです",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage("今すぐ確認"),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("地域"),
    "smartRoutingRegionCard": MessageLookupByLibrary.simpleMessage("この地域の仕組み"),
    "smartRoutingRegionCardDesc": MessageLookupByLibrary.simpleMessage(
      "この地域が設定する内容とサーバーの選び方",
    ),
    "smartRoutingRegionEditNote": MessageLookupByLibrary.simpleMessage(
      "これらはすべて詳細設定で編集できます",
    ),
    "smartRoutingRegionHow": MessageLookupByLibrary.simpleMessage(
      "スマートルーティングは動作中のサーバーを維持し、他のサーバーをバックグラウンドで確認して、オープンなインターネットに到達できる高速なものを優先します。下の地域がこれらのチェックを設定します。ネットワークが異なる場合を除き、変更は不要です。",
    ),
    "smartRoutingRegionNote": MessageLookupByLibrary.simpleMessage(
      "アプリで選んだ地域から設定されています。ネットワークに必要な場合のみ変更してください",
    ),
    "smartRoutingRegionSeeds": MessageLookupByLibrary.simpleMessage(
      "この地域が設定する内容",
    ),
    "smartRoutingRegionUnused": MessageLookupByLibrary.simpleMessage(
      "この地域では使用しません",
    ),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "UDP 対応を必須にする",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "通話やゲームを通せないサーバーを除外します",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "制限されたネットワーク · 国内サービスは直接接続",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "サーバーが応答しません。別のサーバーを探しています",
    ),
    "smartRoutingRuleAction": MessageLookupByLibrary.simpleMessage("アクション"),
    "smartRoutingRuleAdd": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "smartRoutingRuleCountry": MessageLookupByLibrary.simpleMessage("出口国"),
    "smartRoutingRuleCountryDesc": MessageLookupByLibrary.simpleMessage(
      "実測の出口国、2 文字のコード",
    ),
    "smartRoutingRuleGroup": MessageLookupByLibrary.simpleMessage("グループ"),
    "smartRoutingRuleGroupDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーが属するプロキシグループ",
    ),
    "smartRoutingRuleIgnore": MessageLookupByLibrary.simpleMessage("無視"),
    "smartRoutingRuleIgnoreDesc": MessageLookupByLibrary.simpleMessage(
      "一致するサーバーを使用しない",
    ),
    "smartRoutingRuleLastResort": MessageLookupByLibrary.simpleMessage("最終手段"),
    "smartRoutingRuleLastResortDesc": MessageLookupByLibrary.simpleMessage(
      "他に使えるものがない場合のみ一致するサーバーを使用する",
    ),
    "smartRoutingRuleMatchAny": MessageLookupByLibrary.simpleMessage(
      "任意のサーバーに一致",
    ),
    "smartRoutingRuleMatchHint": MessageLookupByLibrary.simpleMessage(
      "空欄の項目は無視されます。入力したすべての項目が一致した場合のみルールが適用されます",
    ),
    "smartRoutingRuleName": MessageLookupByLibrary.simpleMessage("名前に含む"),
    "smartRoutingRuleNameDesc": MessageLookupByLibrary.simpleMessage(
      "名前にこのテキストを含むサーバーに一致",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "ルールモードでのみ利用できます",
    ),
    "smartRoutingRulePrefer": MessageLookupByLibrary.simpleMessage("優先"),
    "smartRoutingRulePreferDesc": MessageLookupByLibrary.simpleMessage(
      "一致するサーバーが正常なときは優先する",
    ),
    "smartRoutingRuleProvider": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "smartRoutingRuleProviderDesc": MessageLookupByLibrary.simpleMessage(
      "サーバーの取得元サブスクリプション",
    ),
    "smartRoutingRules": MessageLookupByLibrary.simpleMessage("サーバールール"),
    "smartRoutingRulesDesc": MessageLookupByLibrary.simpleMessage(
      "名前・プロバイダー・実測した国でサーバーを無視、抑制、または優先します",
    ),
    "smartRoutingRungVersus": m92,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "サーバーを選んでいます…",
    ),
    "smartRoutingSeconds": m93,
    "smartRoutingSectionEngine": MessageLookupByLibrary.simpleMessage("エンジン"),
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage("サーバー"),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "以前の切り替え",
    ),
    "smartRoutingSectionLadder": MessageLookupByLibrary.simpleMessage(
      "サーバーの比べ方",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "ネットワーク",
    ),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "信頼性",
    ),
    "smartRoutingSectionRivals": MessageLookupByLibrary.simpleMessage(
      "選ばれたサーバーとの比較",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("判断"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("サーバー"),
    "smartRoutingServersCount": m94,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "すべてのプロバイダー",
    ),
    "smartRoutingServiceCandidates": m95,
    "smartRoutingServiceEnabled": MessageLookupByLibrary.simpleMessage(
      "サービスルートを使用",
    ),
    "smartRoutingServiceEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "一致する専用ノード経由でこのサービスを送信します",
    ),
    "smartRoutingServiceFallback": MessageLookupByLibrary.simpleMessage(
      "専用ノードが使えない場合",
    ),
    "smartRoutingServiceFallbackActiveMain":
        MessageLookupByLibrary.simpleMessage("利用可能な専用ノードなし · メインノードを使用"),
    "smartRoutingServiceFallbackActiveReject":
        MessageLookupByLibrary.simpleMessage("利用可能な専用ノードなし · サービスをブロック"),
    "smartRoutingServiceFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "専用ノードがない間に非表示のサービスグループが使う経路です",
    ),
    "smartRoutingServiceFallbackMain": MessageLookupByLibrary.simpleMessage(
      "Smart Routing のメインノードを使用",
    ),
    "smartRoutingServiceFallbackReject": MessageLookupByLibrary.simpleMessage(
      "サービスをブロック",
    ),
    "smartRoutingServiceGemini": MessageLookupByLibrary.simpleMessage(
      "Gemini アクセス",
    ),
    "smartRoutingServiceManual": MessageLookupByLibrary.simpleMessage(
      "手動セレクター",
    ),
    "smartRoutingServiceManualEmpty": MessageLookupByLibrary.simpleMessage(
      "手動セレクターはありません",
    ),
    "smartRoutingServiceManualEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "名前の一部と、必要に応じてプロバイダーを追加します",
    ),
    "smartRoutingServiceManualSelector": MessageLookupByLibrary.simpleMessage(
      "手動専用ノードセレクター",
    ),
    "smartRoutingServiceMatchedNone": MessageLookupByLibrary.simpleMessage(
      "一致するサーバーはまだありません",
    ),
    "smartRoutingServiceNameContains": MessageLookupByLibrary.simpleMessage(
      "名前に含む文字列",
    ),
    "smartRoutingServiceNameContainsDesc": MessageLookupByLibrary.simpleMessage(
      "大文字と小文字を区別するノード名の一部",
    ),
    "smartRoutingServiceNoCandidates": MessageLookupByLibrary.simpleMessage(
      "専用ノードのセレクターがありません",
    ),
    "smartRoutingServicePending": MessageLookupByLibrary.simpleMessage(
      "エンジンを待っています",
    ),
    "smartRoutingServiceProvider": m96,
    "smartRoutingServiceProviderCandidates": m97,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "プロバイダーの完全一致名。空欄ならすべて対象です",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "プロバイダー（任意）",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "購読マニフェスト",
    ),
    "smartRoutingServiceReady": m98,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("ルート"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage(
      "サービスルート",
    ),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "サービスルートは設定されていません",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage(
      "セレクターの取得元",
    ),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage("状態"),
    "smartRoutingServiceTokenTooLong": m99,
    "smartRoutingServiceVia": m100,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "広告なし YouTube",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "ウォームスタンバイで復旧",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage("対象を絞り込み"),
    "smartRoutingStepAdmitBody": m101,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage("これに決定"),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage(
      "ネットワークを判定",
    ),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage("残りを並べ替え"),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "2 つのサーバーが最初に違った行が結果を決めます",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("ストラテジー"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage("標準"),
    "smartRoutingStrategyBalancedDesc": MessageLookupByLibrary.simpleMessage(
      "どんな用途にも合います。迷ったらこれを選んでください",
    ),
    "smartRoutingStrategyEdited": m102,
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "速度重視",
    ),
    "smartRoutingStrategyLowestLatencyDesc":
        MessageLookupByLibrary.simpleMessage("つながるサーバーの中から最も速いものを選びます"),
    "smartRoutingStrategyPace": MessageLookupByLibrary.simpleMessage("ペースを設定"),
    "smartRoutingStrategySaver": MessageLookupByLibrary.simpleMessage("節約"),
    "smartRoutingStrategySaverDesc": MessageLookupByLibrary.simpleMessage(
      "確認の回数を減らし、通信量とバッテリーを節約します",
    ),
    "smartRoutingStrategyStable": MessageLookupByLibrary.simpleMessage("安定重視"),
    "smartRoutingStrategyStableDesc": MessageLookupByLibrary.simpleMessage(
      "つながっているサーバーを保ち、切り替えを減らします",
    ),
    "smartRoutingSwitchLine": m103,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("切り替え"),
    "smartRoutingSwitchedAgo": m104,
    "smartRoutingTabDetails": MessageLookupByLibrary.simpleMessage("詳細"),
    "smartRoutingTabOverview": MessageLookupByLibrary.simpleMessage("概要"),
    "smartRoutingTabRanking": MessageLookupByLibrary.simpleMessage("選定"),
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage("技術的な詳細"),
    "smartRoutingTiedAll": MessageLookupByLibrary.simpleMessage("すべての行で同一"),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage("未検査"),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "最後の手段",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "開かれたインターネットに到達",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage("使用不可"),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage("使用可能"),
    "smartRoutingWaitingNetwork": MessageLookupByLibrary.simpleMessage(
      "スマートルーティングはネットワークを待っています",
    ),
    "smartRoutingWaitingTunnel": MessageLookupByLibrary.simpleMessage(
      "スマートルーティングは有効 · トンネル待ちです",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage("1 回の検査台数"),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "1 回のバックグラウンド検査で測るサーバーの数",
    ),
    "smartRoutingWaveNodes": m105,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage("回線チェック"),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("理由"),
    "smartRoutingWinsAt": m106,
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKSポート"),
    "sort": MessageLookupByLibrary.simpleMessage("並べ替え"),
    "source": MessageLookupByLibrary.simpleMessage("ソース"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("ソースコード"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("速度統計"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("振り分け戦略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略は空にできません",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準モード：基本設定を上書きし、シンプルなルール追加機能を提供します",
    ),
    "start": MessageLookupByLibrary.simpleMessage("開始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPNを起動しています..."),
    "status": MessageLookupByLibrary.simpleMessage("状態"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("無効にすると、システムDNSを使用します"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPNを停止しています..."),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "subRule": MessageLookupByLibrary.simpleMessage("サブルール"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("サブルールが空です"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage("サブルールは空にできません"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("自動"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "このクライアントの形式で購読を取得します",
    ),
    "subscriptionClientExperimentalLabel": MessageLookupByLibrary.simpleMessage(
      "実験的",
    ),
    "subscriptionClientExperimentalTip": MessageLookupByLibrary.simpleMessage(
      "他のクライアントとの互換性は実験的です。プロバイダーが選択したクライアントの形式を返し、ReClash が変換します。",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage("クライアント形式"),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionConfigurationSource": MessageLookupByLibrary.simpleMessage(
      "指定された設定",
    ),
    "subscriptionDirectRetryConfirm": MessageLookupByLibrary.simpleMessage(
      "直接再試行",
    ),
    "subscriptionDirectRetryMessage": MessageLookupByLibrary.simpleMessage(
      "現在の接続ではサブスクリプションにアクセスできませんでした。VPN を無効にせず、このダウンロードだけを直接再試行しますか？パネルにはご利用のネットワークの IP アドレスが伝わります。他の通信経路は変わりません。",
    ),
    "subscriptionDirectRetryTitle": MessageLookupByLibrary.simpleMessage(
      "VPN を経由せずに再試行しますか？",
    ),
    "subscriptionDomainMoved": m107,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの有効期限が切れました",
    ),
    "subscriptionExpiresInDays": m108,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションは本日期限切れになります",
    ),
    "subscriptionFaultClient": MessageLookupByLibrary.simpleMessage(
      "問題はこの端末にあります",
    ),
    "subscriptionFaultClientDesc": MessageLookupByLibrary.simpleMessage(
      "VPN またはトンネルが完全に有効になっていません。再接続してからレポートを作り直してください。",
    ),
    "subscriptionFaultInconclusive": MessageLookupByLibrary.simpleMessage(
      "単一の原因は特定できません",
    ),
    "subscriptionFaultInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "証拠はどちらか一方を明確に示していません。それでもレポートを保存してください。集計はプロバイダーの役に立ちます。",
    ),
    "subscriptionFaultServer": MessageLookupByLibrary.simpleMessage(
      "問題はプロバイダー側のようです",
    ),
    "subscriptionFaultServerDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークは正常なのに、特定の出口でノードが大量に失敗しています。このレポートをプロバイダーに送ってください。",
    ),
    "subscriptionFaultSubscription": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションを更新できませんでした",
    ),
    "subscriptionFaultSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "設定を取得または解析できませんでした。このレポートをプロバイダーに送ってください。取得側またはパネル側を示しています。",
    ),
    "subscriptionFaultUnknown": MessageLookupByLibrary.simpleMessage(
      "データがまだ足りません",
    ),
    "subscriptionFaultUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "しばらく接続を使ってから、より明確な判定のためにレポートを作り直してください。",
    ),
    "subscriptionFaultYourNetwork": MessageLookupByLibrary.simpleMessage(
      "問題はあなたのネットワークです",
    ),
    "subscriptionFaultYourNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "プロバイダーに届く前に通信が遮断されているか、ネットワークがオフラインです。Wi-Fi、モバイル通信、キャプティブポータルを確認してください。",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("サブスクリプション情報"),
    "subscriptionLoopbackWarning": MessageLookupByLibrary.simpleMessage(
      "このプロファイルの URL は ReClash 自身のプロキシポートを指しています。サブスクリプションの URL を確認してください。",
    ),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションはトラフィック上限も有効期限も返しません",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションのリマインダー",
    ),
    "subscriptionProviderInterval": m109,
    "subscriptionReport": MessageLookupByLibrary.simpleMessage("サブスクリプションレポート"),
    "subscriptionReportConfirm": MessageLookupByLibrary.simpleMessage(
      "レポートには匿名化された診断情報のみが含まれます。プロトコル・トランスポート・出口国のラベル付きノード仮名、エラークラス、遅延の区分、ルートと desync のプリセットです。サブスクリプションの URL、実際のノード名、ホスト名、アドレス、ポートは一切含まれません。プロバイダーに送るために JSON として保存しますか?",
    ),
    "subscriptionReportFlaggedNodes": MessageLookupByLibrary.simpleMessage(
      "該当ノード",
    ),
    "subscriptionReportGenerating": MessageLookupByLibrary.simpleMessage(
      "レポートを作成中…",
    ),
    "subscriptionReportRuntimeDials": MessageLookupByLibrary.simpleMessage(
      "ランタイム接続",
    ),
    "subscriptionReportSave": MessageLookupByLibrary.simpleMessage("JSON を保存"),
    "subscriptionReportUpdateFailures": MessageLookupByLibrary.simpleMessage(
      "更新の失敗",
    ),
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションに通常のノードアドレスが見つかりません。パネルが仮の設定を返した可能性があります。サーバーへの接続はテストしていません。",
    ),
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("更新日時"),
    "support": MessageLookupByLibrary.simpleMessage("サポート"),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "system": MessageLookupByLibrary.simpleMessage("システム"),
    "systemApp": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "systemColor": MessageLookupByLibrary.simpleMessage("システムの色"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "OS のアクセント色を使用 (Material You)",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("システムプロキシを設定します"),
    "systemSeed": MessageLookupByLibrary.simpleMessage("OS の色"),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("タブアニメーション"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage("モバイル表示でのみ有効です"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("タップして許可"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP同時接続"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、TCPの同時接続を許可します",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("テスト間隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("テストURL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用時にテスト"),
    "textScale": MessageLookupByLibrary.simpleMessage("テキストの拡大縮小"),
    "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "themeColor": MessageLookupByLibrary.simpleMessage("テーマカラー"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("ダークモードの設定と色の調整"),
    "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "tight": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "time": MessageLookupByLibrary.simpleMessage("時刻"),
    "timeout": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "tk": MessageLookupByLibrary.simpleMessage("トルクメン語"),
    "toggle": MessageLookupByLibrary.simpleMessage("切り替え"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("ラベルを切り替え"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("トーナルスポット"),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "toolsSelectPanePlaceholder": MessageLookupByLibrary.simpleMessage(
      "設定を選択すると、ここに表示されます。",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("データ量を追加"),
    "torch": MessageLookupByLibrary.simpleMessage("ライト"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("合計トラフィック"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxyポート"),
    "trafficFreeOfTotal": m110,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("トラフィック統計"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClashはさまざまな国の人に使ってもらえるよう、あなたの言語に対応しています。不自然な表現があれば教えてください。修正します。",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage("翻訳の修正を提案する"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("信頼できるネットワーク"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "これらのネットワークに接続中はVPNを一時停止します",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "現在のネットワークは信頼済み — ここではVPNを一時停止します",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("管理者モードでのみ有効"),
    "turnOff": MessageLookupByLibrary.simpleMessage("オフにする"),
    "turnOn": MessageLookupByLibrary.simpleMessage("オンにする"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("統一遅延"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "ハンドシェイクなどの余分な遅延を除きます",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("不明"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("不明なネットワークエラー"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unnamed": MessageLookupByLibrary.simpleMessage("名称未設定"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("固定を解除"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "更新をダウンロードできませんでした",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "ダウンロードしたファイルが破損しています",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URLからプロファイルを取得します"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URLスキーム"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("サブスクリプションを追加"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "確認後にサブスクリプション URL を追加します",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("閉じる"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "トレイに隠す、設定によっては終了します",
    ),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage("自動化コマンド"),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "タスクやスクリプト、ショートカットの自動化用",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("接続"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "トンネルを開始して接続します",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("切断"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "トンネルを停止します",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("設定をインポート"),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "base64 の設定ファイルをプロファイルとして取り込みます",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "インポートのペイロードが正しい base64 ではありません",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage("プロファイルの追加"),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash・FlClash のボタンが既に使っている互換リンク",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("開く"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage("ウィンドウを前面に表示します"),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("切り替え"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "停止中なら接続、実行中なら切断します",
    ),
    "urlTip": m111,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostsを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムのHostsを使用"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("使用済みトラフィック"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "uz": MessageLookupByLibrary.simpleMessage("ウズベク語"),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("ビブラント"),
    "view": MessageLookupByLibrary.simpleMessage("表示"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN関連の設定変更を検出しました",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VpnServiceでシステムの全トラフィックを自動的にルーティングします",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("変更はVPNの再起動後に有効になります"),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("ぼかし"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage("カードの不透明度"),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("画像を選択"),
    "wallpaperDescription": MessageLookupByLibrary.simpleMessage(
      "選択した画像はサブスクリプションの背景より優先されます。カスタム背景をオフにすると元の背景に戻ります。",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("暗さ"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("画像の調整"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage("カスタム背景を使用"),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("画像の配置"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("全体を表示"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("画面いっぱいに表示"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("引き伸ばし"),
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "保存済みの背景をタップして適用するか、新しい背景を追加します。",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "水平方向の位置",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "有効な PNG、JPEG、WebP 形式の画像を選択してください。",
    ),
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("構図"),
    "wallpaperLibraryFull": m112,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("画像の不透明度"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("読みやすさ"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("画像を削除"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("調整をリセット"),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "背景を保存できませんでした。元の背景はそのままです。",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("拡大率"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG、JPEG、WebP · 20 MB 以下",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("カスタム背景"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "20 MB 以下、5,000 万画素以下の画像を選択してください。",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "垂直方向の位置",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Web ダッシュボード"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "コア自身が配信する zashboard",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "初回起動時に zashboard をダウンロードします",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("ダッシュボードを開く"),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "ダッシュボードを開いている間は外部コントローラーが有効です",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "コアがまだダッシュボードを配信していません",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("ホワイトリストモード"),
    "yearsAgo": m113,
    "zhCN": MessageLookupByLibrary.simpleMessage("簡体字中国語"),
  };
}
