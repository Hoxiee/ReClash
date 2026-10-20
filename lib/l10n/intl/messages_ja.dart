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

  static String m0(count, skipped) => "${count}件を追加、${skipped}件は既存のためスキップ";

  static String m1(detail) => "データを消去できませんでした：${detail}";

  static String m2(code) =>
      "Windows が ReClashCore.exe の実行を拒否しました（エラー ${code}）。スマート アプリ コントロールや AppLocker などのアプリ制御ポリシーは未署名のプログラムをブロックします。ポリシーで ReClash を許可するか、ポリシーを無効にしてから再試行してください。";

  static String m3(name) =>
      "アプリの起動が2回連続で完了しませんでした。クラッシュループを断ち切るため、プロファイル ${name} の選択を解除し、今回の自動セットアップをスキップしました。いつでも選択し直せます。";

  static String m4(url) => "${url} からプロファイルを作成しますか？";

  static String m5(groups) =>
      "プロキシグループ ${groups} の include-all を破棄しました。これらのグループで使うプロキシまたはプロキシプロバイダーを追加してください";

  static String m6(count, label) =>
      "${Intl.plural(count, other: 'カスタム設定はサブルールに対応していないため、SUB-RULE ルール ${label} 件を破棄しました')}";

  static String m7(message) => "コアがこのプロキシを解析できません：${message}";

  static String m8(proxy, target) =>
      "${proxy} は ${target} 経由で接続しますが、${target} から再び ${proxy} に戻るため、ループになります";

  static String m9(name) => "名前 ${name} は他のプロキシまたはプロキシグループで使用されています";

  static String m10(path) => "プロキシグループが循環参照しています：${path}";

  static String m11(name) =>
      "空グループのフォールバックはプロキシである必要がありますが、${name} は存在しないかプロキシグループです";

  static String m12(name, message) => "${name}は有効な正規表現ではありません：${message}";

  static String m13(name) => "ダイヤラープロキシ ${name} が存在しません";

  static String m14(names) => "次のプロキシプロバイダーは存在しません：${names}";

  static String m15(names) => "次のプロキシまたはポリシーは存在しません：${names}";

  static String m16(name) => "${name} は組み込みポリシー名のため使用できません";

  static String m17(count) => "${count} 件に問題があり、プロファイルの適用に失敗する可能性があります";

  static String m18(count) => "${count} 日前";

  static String m19(count) => "${count} 日前";

  static String m20(label) => "選択した${label}を削除してもよろしいですか？";

  static String m21(label) => "この${label}を削除してもよろしいですか？";

  static String m22(label) => "${label}の詳細";

  static String m23(name) => "${name} 経由の接続が使用元のプロキシに戻るため、接続を中止しました";

  static String m24(label) => "${label}は空にできません";

  static String m25(label) => "${label}はすでに存在します";

  static String m26(count) => "${count} 件が失敗しました";

  static String m27(label, message) => "${label}：${message}";

  static String m28(name) => "${name} はすでに最新です";

  static String m29(name) => "${name} を更新しました";

  static String m30(count) => "${count} 個";

  static String m31(count) => "${count} 件タイムアウト";

  static String m32(action) => "「${action}」で使用中です。保存するとこちらに移動します。";

  static String m33(actions) => "エクスポートされなかった操作: ${actions}";

  static String m34(modifiers) => "${modifiers} のいずれかを含めてください";

  static String m35(count) => "${count} 時間前";

  static String m36(count) => "${count} 時間前";

  static String m37(target) => "${target} は無効なポリシーです";

  static String m38(proxyName) => "${proxyName} は無効なプロキシです";

  static String m39(providerName) => "${providerName} は無効なプロキシプロバイダーです";

  static String m40(ruleSet) => "${ruleSet} は無効なルールセットです";

  static String m41(subRule) => "${subRule} は無効な SUB_RULE です";

  static String m42(count) => "${count} 件";

  static String m43(line, message) => "${line}行目：${message}";

  static String m44(appName) =>
      "1. システム設定 > プライバシーとセキュリティ を開く\n2. 位置情報サービス を選択\n3. リストで ${appName} を見つけてチェックを入れる\n\n設定が完了したらアプリに戻ると、通常どおり使用できます。ご協力ありがとうございます。";

  static String m45(label, max) => "${label}は最大${max}文字です";

  static String m46(size) => "${size} を解放しました";

  static String m47(count) => "${count} 分前";

  static String m48(count) => "${count} 分前";

  static String m49(count) => "${count} か月前";

  static String m50(count) => "${count} か月前";

  static String m51(code) =>
      "サーバーがアクセスを拒否しました（HTTP ${code}）。リンクの期限切れか、認証情報が誤っている可能性があります";

  static String m52(code) => "サーバーがリクエストを拒否しました（HTTP ${code}）";

  static String m53(code) =>
      "このアドレスには何も見つかりませんでした（HTTP ${code}）。URL が正しいか確認してください";

  static String m54(detail) => "ネットワークリクエストに失敗しました：${detail}";

  static String m55(code) => "サーバーで問題が発生しました（HTTP ${code}）。しばらくしてから再試行してください";

  static String m56(label) => "${label}はまだありません";

  static String m57(label, min, max) => "${label}は${min}から${max}の範囲で指定してください";

  static String m58(label) => "${label}は数値である必要があります";

  static String m59(label) => "${label} は 1024〜49151 の範囲で指定してください";

  static String m60(port) => "ポート ${port}";

  static String m61(added, skipped, failed) =>
      "追加: ${added}、スキップ: ${skipped}、失敗: ${failed}。";

  static String m62(days) => "残り ${days} 日";

  static String m63(date, days) => "${date} に期限切れ、残り ${days} 日";

  static String m64(time) => "${time}に更新";

  static String m65(label, profiles) =>
      "${label} は ${profiles} でまだ使用されており、削除するとそれらが正常に動作しなくなります。削除してもよろしいですか？";

  static String m66(count, label) =>
      "${Intl.plural(count, other: 'プロキシ ${label} 件')}";

  static String m67(name, count) => "${name} など${count}件のプロキシ";

  static String m68(removed) =>
      "次のプロキシが削除されます：${removed}。名前を変えた行は新しいプロキシとして扱われ、削除されたプロキシを参照するカスタムプロファイルでは見つからないと表示されます。適用しますか？";

  static String m69(removed, added) =>
      "次のプロキシが削除されます：${removed}。次のプロキシが追加されます：${added}。名前を変えた行は新しいプロキシとして扱われ、削除されたプロキシを参照するカスタムプロファイルでは見つからないと表示されます。適用しますか？";

  static String m70(label) =>
      "${label} はこのプロファイルのルール、プロキシグループ、ダイヤラープロキシ、DNS または NTP からまだ参照されており、削除するとそれらの参照は無効になります。削除してもよろしいですか？";

  static String m71(count, label) =>
      "${Intl.plural(count, other: 'プロキシグループ ${label} 件')}";

  static String m72(region, bypassed, proxied) =>
      "${region}: VPN バイパス一覧に ${bypassed} 個、VPN 一覧に ${proxied} 個のアプリを追加します。両方の一覧が置き換わり、モードや他の設定は変更されません。パッケージと SDK の一致は候補にすぎません。適用後に結果を確認してください。";

  static String m73(region, value) =>
      "地域 ${region} の一覧: ${value}。カスタム一覧は地域の既定値を置き換えます。";

  static String m74(region, source) => "候補: ${region} · ${source}";

  static String m75(region, value) =>
      "地域 ${region} の既定 DNS: ${value}。この画面の手動設定が優先されます。";

  static String m76(region) => "国のプロファイル: ${region}";

  static String m77(value) => "TUN MTU: ${value}";

  static String m78(value) => "既定のサービス確認: ${value}";

  static String m79(region, value) =>
      "地域 ${region} の MTU は ${value} です。独自の値を使うには MTU 設定を追加してください。";

  static String m80(count, label) =>
      "${Intl.plural(count, other: 'ルール ${label} 件')}";

  static String m81(appName) => "${appName}（セーフモード）";

  static String m82(count) => "${count} 秒";

  static String m83(count) => "${count} 件が有効";

  static String m84(count) => "${count} 件に問題";

  static String m85(time) => "${time} に検査";

  static String m86(count) => "設定 ${count} 件";

  static String m87(count) => "利用可能なプロファイル: ${count}";

  static String m88(step, total) => "${total} 件中 ${step} 件目";

  static String m89(server) => "${server} を試す";

  static String m90(link) => "${link} からプロキシを読み取れませんでした";

  static String m91(label) => "${label}は1項目のみ指定できます";

  static String m92(client, format, count) =>
      "${client} として取得：${format}、プロキシノード ${count} 件。";

  static String m93(sections) => "次の元設定セクションは引き継がれません: ${sections}。";

  static String m94(count, format) =>
      "${format} から ${count} 個のプロキシノードをインポートできます。";

  static String m95(count) => "変換できないノード: ${count} 個。";

  static String m96(count) => "${count} 件の結果";

  static String m97(value) => "ピーク ${value}";

  static String m98(value) => "累計 ${value}";

  static String m99(version) => "インストール済み: ${version}";

  static String m100(nodes, groups, providers) =>
      "プロキシ: ${nodes}、グループ: ${groups}、リモートプロバイダー: ${providers}";

  static String m101(action) => "このリンクは「${action}」を要求しています。ReClashで実行しますか？";

  static String m102(name, source) =>
      "${source}から「${name}」をインポートしますか？確認後にプロファイルの検証と変換内容の確認を行います。";

  static String m103(label) => "${label}はURLである必要があります";

  static String m104(index) => "背景 ${index}";

  static String m105(count) => "背景は最大 ${count} 件まで保存できます。追加するには 1 件削除してください。";

  static String m106(version) => "インストール済みバージョン: ${version}";

  static String m107(count) => "${count} 年前";

  static String m108(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "accessControl": MessageLookupByLibrary.simpleMessage("アクセス制御"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリのみVPNを経由します",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "アクセス制御では、プロキシを利用するアプリを選びます。",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "アプリアクセス制御は無効です",
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
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("プロキシを追加"),
    "addFilters": MessageLookupByLibrary.simpleMessage("フィルターを追加"),
    "addNodes": MessageLookupByLibrary.simpleMessage("ノードを追加"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("上書き項目を追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイルを追加"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("設定項目を追加"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSIDを追加"),
    "addedRules": MessageLookupByLibrary.simpleMessage("追加ルール"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage("追加パラメータ"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("名前のプレフィックス"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("名前のサフィックス"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーのアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "有効なWebDAVアドレスを入力してください",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "詳細設定には、ネットワーク、DNS、追加ルール、スクリプトがあります。",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("暗号化されたプロファイル"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 秘密鍵"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "このプロファイルは age で暗号化されており、復号には age 秘密鍵が必要です",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("同意する"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "参照されているすべてのプロキシ",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "参照されているすべてのプロキシプロバイダー",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage("アプリによるVPNバイパスを許可"),
    "allowLan": MessageLookupByLibrary.simpleMessage("LANプロキシ"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("許可する IP"),
    "answers": MessageLookupByLibrary.simpleMessage("応答"),
    "app": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("アプリアクセス制御"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("アプリアイコンのデザイン"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("ローカルプロキシがありません"),
    "appRegion": MessageLookupByLibrary.simpleMessage("アプリの地域"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("背景"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("インターフェース"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを追加"),
    "applicationSettings": MessageLookupByLibrary.simpleMessage("アプリの設定"),
    "authentication": MessageLookupByLibrary.simpleMessage("認証"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "認証を有効にすると、ローカルプロキシポートの利用にユーザー名とパスワードが必要になります。",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "認証が有効な間、システムプロキシは適用されません。",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("許可"),
    "authorized": MessageLookupByLibrary.simpleMessage("許可済み"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("更新の自動チェック"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("接続を自動的に閉じる"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシを切り替えると、既存の接続を自動的に閉じます。",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("自動で含める"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自動起動"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動実行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "自動実行はアプリを開いたときにプロキシを開始します。",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを自動設定"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "back": MessageLookupByLibrary.simpleMessage("戻る"),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "このバックアップは新しいバージョンのアプリで作成されています。アプリを更新してから復元してください",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップが完了しました"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基本情報"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基本ポリシー"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("一括追加"),
    "batchImport": MessageLookupByLibrary.simpleMessage("一括インポート"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "1行に1つのリンクを入力してください",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "1行に1項目、またはカンマ区切りで入力してください",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "1行に1件、キーと値はスペースで区切ってください",
    ),
    "batchPreviewTip": m0,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "1行に1つのURLを入力してください",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "電池の最適化を無視すると、アプリがバックグラウンドで動作し続けます。",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("連携"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("ブラックリストモード"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("接続をブロック"),
    "brightness": MessageLookupByLibrary.simpleMessage("明度"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("除外ドメイン"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "除外ドメインはシステムプロキシが有効な場合のみ適用されます。",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "プライベートアドレスをバイパス",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "プライベートアドレスをバイパスすると、LAN・ループバック・マルチキャストのアドレスは TUN を通りません。",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("キャッシュ"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("キャッシュアルゴリズム"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("キャッシュサイズ"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QRコードをスキャンするには、システム設定でカメラへのアクセスを許可するか、アルバムからQRコード画像を選択してください。",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "カメラの権限が必要です",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("カメラを使用できません"),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("すべて選択解除"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("保存できません"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "プロキシの切り替えに失敗したため、前回の選択に戻しました",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("破壊的変更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新機能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("不具合修正"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("パフォーマンス"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("取り消し"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS証明書を検証"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS 証明書の検証を無効にすると、サブスクリプションとバックアップが中間者攻撃にさらされます。",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("更新を確認"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("すでに最新バージョンです"),
    "cipher": MessageLookupByLibrary.simpleMessage("暗号方式"),
    "clearData": MessageLookupByLibrary.simpleMessage("データを消去"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "すべてのプロファイル、設定、ローカルデータを削除してアプリを終了します。もう一度開くと最初から始められます。",
    ),
    "clearDataFailed": m1,
    "clearSearch": MessageLookupByLibrary.simpleMessage("検索をクリア"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "クライアントフィンガープリント",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("クリップボードへエクスポート"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("クリップボードからインポート"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "クリップボードにコピーできませんでした。選択範囲が大きすぎる可能性があります",
    ),
    "close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("接続を閉じる"),
    "color": MessageLookupByLibrary.simpleMessage("カラー"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("配色スタイル"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compact": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "compatible": MessageLookupByLibrary.simpleMessage("互換モード"),
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
    "congestionControl": MessageLookupByLibrary.simpleMessage("輻輳制御"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 輻輳制御"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 輻輳制御は mips スタックでのみ有効です。",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "connecting": MessageLookupByLibrary.simpleMessage("接続中…"),
    "connection": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("接続統計"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "ライブ接続、最近のリクエスト、DNS クエリ",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("接続"),
    "connectivity": MessageLookupByLibrary.simpleMessage("接続状態："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容は空にできません"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "グローバル追加ルールを管理",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("環境変数をコピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "core": MessageLookupByLibrary.simpleMessage("コア"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("アーキテクチャ"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows のスマート アプリ コントロールが、署名されていない ReClashCore.exe をブロックしました。Windows セキュリティ → アプリとブラウザーの制御 → スマート アプリ コントロールの設定で「オフ」を選び、ReClash を再起動してください。一度オフにすると、Windows を再インストールしない限り再度オンにはできません。",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("ビルドフラグ"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("ビルド日時"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("環境"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("コア実行ファイル"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "コア情報を取得できませんでした",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("実行方式"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("場所"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage("管理された権限昇格プロセス"),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage("Helper 経由のプロセス"),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage("プロセス内ライブラリ"),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "署名済みHelperによる管理プロセス",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("独立したプロセス"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage("実行時設定を開く"),
    "corePlatform": MessageLookupByLibrary.simpleMessage("プラットフォーム"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("稼働中"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage("実行時設定"),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "設定とスクリプトを適用して生成された設定です。読み取り専用。",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "実行時設定を読み込めませんでした",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("起動中…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コアの状態"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("停止中"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage("データフォルダー"),
    "country": MessageLookupByLibrary.simpleMessage("地域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("クラッシュを検出しました"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("作成日時"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI — DPI 回避ツール"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — 本アプリの基盤クライアント",
    ),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "FlClash-Patched — 追加機能",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — プロバイダ機能とアイデア",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("mihomo — プロキシコア"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "起動ボタンがあるため削除できません",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "customColor": MessageLookupByLibrary.simpleMessage("カスタムカラー"),
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("名前が空です"),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "プロキシもプロキシプロバイダーも選択されていないため、コアはこのグループを拒否します",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("カスタム"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "アプリのプロキシと他のプロファイルからプロキシグループとルールを組み立てます",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "カスタムプロファイルのリソース",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "カスタムプロファイルのリソースには、プロキシ、ルールプロバイダー、フィルター、アイコンセットがあります。",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ダッシュボード"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("追加できるカード"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "変更の保存に失敗したため、元に戻しました",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("デフォルトの選択"),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "設定は name と type を含む YAML マッピングである必要があります",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("遅延"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "delayTest": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMetaベースのマルチプラットフォーム対応プロキシクライアント。シンプルで使いやすく、オープンソースで広告もありません。",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "グラフィカル認証エージェントが利用できません。このデスクトップセッションで起動して再試行してください。",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "認証がキャンセルされました。TUNは起動していません。",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "認証が許可されませんでした。TUNは起動していません。",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUNには認証が必要です。接続を開始するかTUNを有効にして許可してください。",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "認証がタイムアウトしました。接続ボタンから再試行してください。",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "認証済みCoreが検証付き起動を完了できませんでした。パッケージとシステムログを確認してください。",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "CoreまたはHelperの整合性を確認できませんでした。完全なReClashパッケージを再インストールしてください。",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "システム設定 → 一般 → ログイン項目と機能拡張でReClash Helperを許可してから再試行してください。",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "インストール済みの Helper は異なるプロトコルを使用しています。別のインストールやサービスの上書き設定を確認し、完全なパッケージを再インストールしてください。",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "既存の Linux Helper の登録を安全に置き換えることができません。サービスの所有者と登録を確認してください。認証を繰り返しても競合は解消されません。",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd が TUN Helper を起動できませんでした。サービスのログを確認してください。インストーラーは以前のインストールの復元を試みました。",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN には systemd が管理する Linux セッションが必要です。このシステムではネットワーク Helper を実行できません。",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUNのHelperが利用できません。インストール済みパッケージとサービスを確認して再試行してください。",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "前の認証またはCoreの終了がまだ完了していません。完了後に再試行してください。",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUNには正しく署名されたReClashアプリとHelperが必要です。未署名またはad-hoc署名のビルドは認証できません。",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Coreは起動しましたがTUNアダプターの準備ができていません。TUNを使用する前にCoreログを確認してください。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "details": m22,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "サードパーティAPIに依存しているため、参考値です",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("開発者モード"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "開発者モードが有効になりました。",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("ダイヤラープロキシ"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "ダイヤラープロキシは NTP サーバーへの接続に使用するアウトバウンドです。",
    ),
    "dialerProxyLoopStopped": m23,
    "direct": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP 転送を無効化",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP 転送を無効にすると TUN が ping に直接応答するため、ping に実際の遅延が表示されなくなります。",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage("TCP キープアライブを無効化"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDPを無効化"),
    "disabled": MessageLookupByLibrary.simpleMessage("無効"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("変更を破棄しますか？"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責事項"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアをインストール、複製または使用した時点で、本声明のすべての内容を読み、同意したものとみなされます。いずれかの条項に同意いただけない場合は、直ちに使用を中止し、本ソフトウェアをアンインストールしてください。",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("声明への同意"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "この声明を読み、理解しました",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "内容を理解したことを確認するため、以下の声明を読み、下のチェックボックスをオンにしてください：",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("声明の確認"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "開発者はバージョンの更新に伴い本声明を変更することがあり、変更内容は新しいバージョンの公開とともに効力を生じます。更新後も本ソフトウェアを引き続き使用した場合、変更後の声明に同意したものとみなされます。",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("本声明の変更"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash（以下「本ソフトウェア」）をご利用になる前に、本声明の内容をよくお読みになり、十分にご理解ください。「同意する」をタップすると、以下のすべての条項を読み、理解し、承諾したものとみなされます。同意いただけない場合は「終了」をタップし、本ソフトウェアの使用を中止してください。",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "適用法で認められる最大限の範囲において、開発者およびすべての貢献者は、本ソフトウェアの使用または使用不能に起因する直接的、間接的、偶発的、特別、懲罰的または結果的な損害（データの消失、機器の損傷、ネットワーク障害、業務の中断、逸失利益、およびそれに起因する法的紛争を含むがこれらに限らない）について、その可能性を知らされていた場合であっても、一切責任を負いません。",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("責任の制限"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは GPL-3.0 ライセンスのもとでオープンソースとして公開されています。同ライセンスを遵守する限り、自由に使用、改変、再配布できますが、派生物も GPL-3.0 で公開し、原著作者の著作権表示を保持する必要があります。\n\n本ソフトウェアに含まれるサードパーティのコンポーネント（Clash.Meta コアを含む）は、それぞれのライセンスに従います。改変版や再配布版に起因する問題について、原著作者は責任を負いません。",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "オープンソースライセンス",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェア自体は、プロキシサーバー、ノード、サブスクリプション、ネットワーク接続サービスを一切提供しておらず、それらのサービス提供者と提携、代理、保証の関係はありません。",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは、サブスクリプション URL、ノード情報、設定内容、閲覧したウェブサイト、接続記録、通信内容、ログを収集またはアップロードしません。これらのデータは端末内にのみ保存され、開発者がアクセスすることはできません。\n\n本ソフトウェアが外部ネットワークにアクセスするのは、プロファイル更新時に指定されたサブスクリプション URL へアクセスする場合や、アップデート確認時に GitHub へアクセスする場合など、該当する機能を使用したときのみです。\n\n本ソフトウェアには、どのプラットフォームでも統計やクラッシュレポートのサービスは一切組み込まれていません。",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "データ収集とプライバシー",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage("最後までお読みください"),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "お住まいの国または地域で本ソフトウェアの使用が合法であることはご自身で確認する必要があり、本ソフトウェアを使用したすべての行為とその結果について、ご自身が単独で法的責任を負います。\n\nインポートするサブスクリプション、ノード、設定はご自身の判断で選択したものです。その出所の適法性、内容の安全性、サービスの安定性については、利用者と各提供者の間で解決してください。",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "利用者の責任",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage("上記の声明を入力"),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "声明の内容と一致しません",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "内容を理解したことを確認するため、以下の声明を下の入力欄に正確に入力してください：",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("声明の復唱"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは Clash.Meta（mihomo）コアをベースとしたオープンソースのネットワークプロキシクライアントであり、設定管理、ルールによる振り分け、トラフィック転送などのローカルツール機能のみを提供します。",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "ソフトウェアの性質",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションリンク、設定ファイル、ルールセット、スクリプト、外部リソース、外部リンクはすべて第三者が提供するものであり、開発者はその適法性、正確性、安全性、可用性を審査または保証することはできず、また行いません。\n\nサードパーティのコンテンツの使用に起因する情報漏えい、財産上の損失、アカウント停止その他の損失は、利用者と第三者の間で解決するものとし、開発者は一切責任を負いません。",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "サードパーティのコンテンツ",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは学習、交流、技術研究などの非商用目的でのみ使用できます。有償配布、抱き合わせ販売、商用サービスの一部としての利用、本ソフトウェアの名義での事業活動など、あらゆる商用目的での使用を固く禁じます。いかなる商業行為も本ソフトウェアおよび開発者とは一切関係ありません。\n\nお住まいの国または地域の法令に違反する目的での使用を固く禁じます。これには、法に基づくネットワークアクセス制限の回避、違法情報の拡散、サイバー攻撃、他者の権利の侵害などが含まれますが、これらに限りません。",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("使用の制限"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは「現状のまま」かつ「提供可能な範囲で」提供され、商品性、特定目的への適合性、非侵害、継続的な可用性、エラーやセキュリティ上の脆弱性がないことの保証を含め、明示または黙示を問わずいかなる保証も伴いません。\n\n開発者は、本ソフトウェアが利用者の要件を満たすこと、また中断やエラーなく動作することを保証しません。",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("無保証"),
    "disconnected": MessageLookupByLibrary.simpleMessage("切断済み"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンが見つかりました",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "追加しない場合、ポート 53 宛てのすべての DNS 問い合わせをハイジャックします（any:53）。",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNSハイジャック"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNSモード"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "ここで追加した項目は、すべての URL・ファイルプロファイルの DNS を上書きします。追加していない項目はプロファイル自身の設定のままです。カスタムプロファイルの DNS はその内容で設定します。",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNSクエリ"),
    "docked": MessageLookupByLibrary.simpleMessage("固定"),
    "domain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "done": MessageLookupByLibrary.simpleMessage("完了"),
    "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("ダウンロード帯域幅"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("更新をダウンロード中"),
    "duration": MessageLookupByLibrary.simpleMessage("経過時間"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("ダッシュボードを編集"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルールを編集"),
    "editProxy": MessageLookupByLibrary.simpleMessage("プロキシを編集"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを編集"),
    "editRule": MessageLookupByLibrary.simpleMessage("ルールを編集"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSIDを編集"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("エディターを利用できません"),
    "elapsed": MessageLookupByLibrary.simpleMessage("所要時間"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("空グループのフォールバック"),
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "enabled": MessageLookupByLibrary.simpleMessage("有効"),
    "entries": MessageLookupByLibrary.simpleMessage(" 件"),
    "error": MessageLookupByLibrary.simpleMessage("エラー"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("エラーの詳細"),
    "es": MessageLookupByLibrary.simpleMessage("スペイン語"),
    "exclude": MessageLookupByLibrary.simpleMessage("最近のタスクから隠す"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("除外宛先ポート"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "除外宛先ポートへの通信は TUN を通りません。",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("除外フィルター"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("除外インターフェース"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "docker0 などの除外インターフェースから入る通信は TUN を通りません。",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("除外送信元ポート"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "除外送信元ポートからの通信は TUN を通りません。",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("除外SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "除外した SSID の Wi-Fi に接続すると、アプリの実行状態が自動的に切り替わります。",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("除外ユーザー ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "除外ユーザー ID のプロセスの通信は TUN を通りません。",
    ),
    "existsTip": m25,
    "exit": MessageLookupByLibrary.simpleMessage("終了"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("全画面表示を終了"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("出口ノード"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("期待するステータス"),
    "expireTime": MessageLookupByLibrary.simpleMessage("有効期限"),
    "exportFile": MessageLookupByLibrary.simpleMessage("ファイルをエクスポート"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("ログをエクスポート"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポートが完了しました"),
    "extend": MessageLookupByLibrary.simpleMessage("拡張"),
    "extendMode": MessageLookupByLibrary.simpleMessage("拡張モード"),
    "extendScript": MessageLookupByLibrary.simpleMessage("拡張スクリプト"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部コントローラー"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "外部コントローラーを有効にすると、ポート 9090 でコアを制御できます。",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "外部コントローラーのシークレット",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部リンク"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("特大"),
    "fade": MessageLookupByLibrary.simpleMessage("フェード"),
    "failedCount": m26,
    "failedItem": m27,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IPフィルター"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IPフィルターモード"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP フィルターモードでは、blacklist は一致を除外、whitelist は一致のみ、rule はルールで判定します。",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP範囲"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP範囲（IPv6）"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("フォールバックフィルター"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("プロファイルファイルを直接アップロードします"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "ファイルが変更されています。変更を保存しますか？",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("フィルター"),
    "filters": MessageLookupByLibrary.simpleMessage("フィルター"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("プロセス検出"),
    "floating": MessageLookupByLibrary.simpleMessage("フローティング"),
    "followProfile": MessageLookupByLibrary.simpleMessage("プロファイルに従う"),
    "followSystem": MessageLookupByLibrary.simpleMessage("システムに従う"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("フォント"),
    "fontSize": MessageLookupByLibrary.simpleMessage("サイズ"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("DNSマッピングを強制"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNS マッピングを強制すると、DNS マッピングでドメインを得た接続もスニッフィングします。",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("強制するドメイン"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "強制するドメインもスニッフィングします。ドメインを持つその他の接続は対象外です。",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "コアを強制再起動してもよろしいですか？",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("フランス語"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低メモリモード"),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "go": MessageLookupByLibrary.simpleMessage("開く"),
    "goDownload": MessageLookupByLibrary.simpleMessage("ダウンロードへ"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "追加ルール設定へ移動",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("スクリプト設定へ移動"),
    "gratitude": MessageLookupByLibrary.simpleMessage("感謝"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "彼らの成果の上に ReClash があります",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("グリッド"),
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("個"),
    "groupTimeoutCount": m31,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("インバウンドユーザーでハッシュ"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("ヘルスチェック"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper サービスが利用できないため、TUN モードを有効にできません。ReClash を再インストールしてください。",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("16進数"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("リストから隠す"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP を隠す"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("パスワードを隠す"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "タイムアウトしたプロキシを隠す",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "前回の遅延テストがタイムアウトしたプロキシを表示しない",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("ホップ間隔"),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostname": MessageLookupByLibrary.simpleMessage("ホスト名"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("すべて消去"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "すべてのホットキーの組み合わせを削除しますか?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage("コンポジター設定"),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "コンポジターの設定に読み込み行を追加する方法もあります。これらのファイルは ReClash のキー設定に合わせて更新され、キー記録中は一時的に空になります。デスクトップ設定は自動変更されません。割り当ての競合はそちらで解消してください。",
    ),
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "グローバルホットキーはウィンドウが非表示でも有効です。アクションをタップしてキーの組み合わせを記録します。",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "デスクトップのショートカット",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "デスクトップ設定で、コマンドをカスタムショートカットに割り当ててください。ReClash が起動していれば、ウィンドウは非表示でも使用できます。これらのグローバル割り当てはデスクトップ設定で管理します。",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "コンポジター設定ファイルを利用できません。上記のデスクトップコマンドは使用できます。",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "これらのキー操作はアプリのウィンドウにフォーカスがある場合に動作します。グローバルショートカットは、以下の項目でデスクトップコマンドを設定してください。",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("ホットキー管理"),
    "hotkeyNeedsModifier": m34,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("未設定"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage("既定に戻す"),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "すべての組み合わせを既定に置き換えますか?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "セーフモードではショートカットの操作は無効ですが、割り当ては編集できます。",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "登録できませんでした。他のアプリが使用している可能性があります",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("時間"),
    "hoursAgo": m35,
    "hoursAgoShort": m36,
    "hue": MessageLookupByLibrary.simpleMessage("色相"),
    "icon": MessageLookupByLibrary.simpleMessage("アイコン"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("アイコン履歴"),
    "iconSets": MessageLookupByLibrary.simpleMessage("アイコンセット"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "アイコンセットはまだありません。「カスタムプロファイルのリソース → アイコンセット」で追加できます",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("アイコンスタイル"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("背景あり"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("非表示"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("背景なし"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("アイコンURL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "電池の最適化を無視",
    ),
    "import": MessageLookupByLibrary.simpleMessage("インポート"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "このファイルはインポートできる設定ではありません",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "インポートすると、このプロファイルの現在のプロキシグループ、ルール、設定が置き換えられます",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("ファイルからインポート"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("リンクからインポート"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "inbound": MessageLookupByLibrary.simpleMessage("インバウンド"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("対象インターフェース"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "対象インターフェースから入る通信だけが TUN を通り、除外インターフェースは無効になります。",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("対象ユーザー ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "対象ユーザー ID のプロセスの通信だけが TUN を通ります。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("無期限"),
    "init": MessageLookupByLibrary.simpleMessage("初期化"),
    "initFailed": MessageLookupByLibrary.simpleMessage("起動に失敗しました"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash の起動中にエラーが発生したため、続行できません。詳細をコピーして問題を報告できます。繰り返し発生する場合は、データを消去すると起動できるようになることがあります。",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("発信元"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("発信元"),
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
    "installedFonts": MessageLookupByLibrary.simpleMessage("インストール済みのフォント"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("スマート選択"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("インターフェース名"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "インターフェース名は、アウトバウンド接続に使用するネットワークインターフェースです。",
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
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "192.168.0.0/16 のような CIDR 形式の IP 範囲を入力してください",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP マークは 63 を超えられません",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "ドメインまたは IP アドレスを入力してください",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("有効なアイコンセットではありません"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションリンクまたはプロキシの共有リンクではありません",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053 のようなアドレスとポートを入力してください",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "tcp または udp のみ対応しています",
    ),
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 や 8000-9000 のようなポートまたは範囲を入力してください",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "このQRコードにはプロファイルのリンクが含まれていません",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 や 8000-9000 のような数値または範囲を / 区切りで入力してください",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP アドレス"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("不正利用の履歴"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("検出"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("組織"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP タイプを判定できませんでした",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("良好"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("レベル"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("普通"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("再確認"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("リスクあり"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("品質"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("採用したソース"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("各ソース"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "アウトバウンド IP が不一致",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("判定不可"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("レート制限"),
    "ipType": MessageLookupByLibrary.simpleMessage("タイプ"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("ビジネス"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("データセンター"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("モバイル回線"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("住宅"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("タイプ不明"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP バージョン"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 トラフィックは IPv6 が有効なときだけ受信します。",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6 を有効にすると、VPN で IPv6 インバウンドを許可します。",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6タイムアウト（ms）"),
    "itemsCount": m42,
    "ja": MessageLookupByLibrary.simpleMessage("日本語"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP キープアライブ待機時間"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCPキープアライブ間隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "kk": MessageLookupByLibrary.simpleMessage("カザフ語"),
    "ko": MessageLookupByLibrary.simpleMessage("韓国語"),
    "label": MessageLookupByLibrary.simpleMessage("ラベル"),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "large": MessageLookupByLibrary.simpleMessage("大"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("最終更新"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("起動が完了しませんでした"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "前回、アプリは起動中に予期せず終了しました。今回の自動セットアップはスキップしました。手動で起動して再試行できます。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "license": MessageLookupByLibrary.simpleMessage("ライセンス"),
    "licenses": MessageLookupByLibrary.simpleMessage("ライセンス一覧"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("アプリに同棑されているパッケージ"),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("折り返し"),
    "link": MessageLookupByLibrary.simpleMessage("リンク"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションリンクまたはプロキシの共有リンクからプロファイルを取得します",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("リキッドグラス"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リッスン"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("リッスンのルーティングマーク"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "リッスンのルーティングマークは Linux でのみ有効です。",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("リアルタイム接続"),
    "loading": MessageLookupByLibrary.simpleMessage("読み込み中…"),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localImage": MessageLookupByLibrary.simpleMessage("ローカル画像"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "ローカルネットワークの権限が拒否されたため gvisor スタックを使用します。LAN にはアクセスできません。",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("ローカルプロキシ"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置情報の権限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が拒否されたため、現在の Wi-Fi 名を取得できません。システム設定で位置情報の権限を手動で有効にしてください。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "システムの要件により、Wi-Fi 名の取得には位置情報の権限が必要です。Android では「常に許可」を選択してください。そうしないと、アプリがバックグラウンドにあるときに Wi-Fi 名を取得できません。",
    ),
    "locationPermissionGuide": m44,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が必要です",
    ),
    "log": MessageLookupByLibrary.simpleMessage("ログ"),
    "logLevel": MessageLookupByLibrary.simpleMessage("ログレベル"),
    "logcat": MessageLookupByLibrary.simpleMessage("ログキャプチャ"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "ログキャプチャを無効にすると、ログの入り口が非表示になります。",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("ログ"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("ログと診断"),
    "logsTest": MessageLookupByLibrary.simpleMessage("ログテスト"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP ループバック解除"),
    "loose": MessageLookupByLibrary.simpleMessage("ゆったり"),
    "madeBy": MessageLookupByLibrary.simpleMessage("制作"),
    "matchCase": MessageLookupByLibrary.simpleMessage("大文字と小文字を区別"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("送信元IPにマッチ"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失敗回数"),
    "maxLengthTip": m45,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("常駐メモリ"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("アプリと共有"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("未使用のヒープ"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("使用中のヒープ"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "コアは実行されていません",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("ランタイムのオーバーヘッド"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("ゴルーチンスタック"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスの常駐メモリからの推定値で、システムの表示とは異なる場合があります。",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "コアはアプリと同じプロセスで動作します。コア分はランタイム統計から推定し、残りはアプリと共有メモリとして計上します。",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("アプリとコアが使用するメモリ"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("メモリを解放しました"),
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("これはメッセージです。"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("終了時に最小化"),
    "minutes": MessageLookupByLibrary.simpleMessage("分"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixedポート"),
    "mode": MessageLookupByLibrary.simpleMessage("モード"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("その他"),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("ボトムバー"),
    "network": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "リクエストはキャンセルされました",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "サーバーに接続できませんでした。ネットワーク接続またはプロキシ設定を確認してください",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "サーバーのアドレスを解決できませんでした。URL が正しいこと、DNS が使えることを確認してください",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("ネットワーク名"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "リクエストが多すぎます（HTTP 429）。しばらく待ってから再試行してください",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage("ネットワークシークレット"),
    "networkServerError": m55,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("ネットワーク速度"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("トラフィックの引き継ぎ"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "リクエストがタイムアウトしました。ネットワークまたはプロキシを確認してから再試行してください",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "安全な接続に失敗しました。サーバー証明書が無効か、接続が傍受されている可能性があります",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワーク種別"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("次の一致"),
    "no": MessageLookupByLibrary.simpleMessage("いいえ"),
    "noData": MessageLookupByLibrary.simpleMessage("データがありません"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報がありません"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("今後表示しない"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークがありません"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("ネットワーク不使用アプリ"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IPを解決しない"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("ホスト名を解決しない"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("一致する結果はありません"),
    "nodes": MessageLookupByLibrary.simpleMessage("ノード"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "この外部リソースはテキストファイルではありません",
    ),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notRunning": MessageLookupByLibrary.simpleMessage("停止中"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループは選択できません",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("同期間隔（分）"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP を有効にすると、システムクロックではなく NTP サーバーから時刻を取得します。",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルを追加して始めましょう",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
    "obfs": MessageLookupByLibrary.simpleMessage("難読化"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("難読化ホスト"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("難読化モード"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("難読化パラメータ"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("難読化パスワード"),
    "onDemand": MessageLookupByLibrary.simpleMessage("オンデマンド"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "オンデマンドは、除外した Wi-Fi に接続している間プロキシを一時停止します。",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "プロキシトラフィックのみ集計",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("任意"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("その他の貢献者"),
    "outbound": MessageLookupByLibrary.simpleMessage("アウトバウンド"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("出口"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("アウトバウンド IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("宛先を上書き"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "宛先を上書きすると、元のアドレスではなく検出したドメインに接続します。",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("上書き項目"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("純粋なIPを解析"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "純粋な IP を解析すると、IP アドレスしかない接続をスニッフィングします。",
    ),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "paste": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "peers": MessageLookupByLibrary.simpleMessage("ピア"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("アルバムから選択"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("最前面に固定"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAVを連携してください"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "スクリプト名を入力してください",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "有効なQRコードをアップロードしてください",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("プラグイン"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("プラグインホスト"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("プラグインモード"),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("別のポートを入力してください"),
    "portHopping": MessageLookupByLibrary.simpleMessage("ポートホッピング"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("ポート"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("事前共有鍵"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前提条件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("キーの組み合わせを押してください"),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの重複を防ぐ",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "既存のプロファイルが使用している購読リンクを拒否します",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("前の一致"),
    "privateKey": MessageLookupByLibrary.simpleMessage("秘密鍵"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("秘密鍵のパスフレーズ"),
    "process": MessageLookupByLibrary.simpleMessage("プロセス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な間隔を入力してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("自動更新間隔を入力してください"),
    "profileBatchResult": m61,
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されています。自動更新を無効にしますか？",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションURLのプロファイルは既に存在します",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル名を入力してください",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "このプロファイルにのみ適用されます。追加していない項目はデフォルト値を使用します。",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "このプロファイルにのみ適用され、ネットワーク設定の TUN 上書き項目より優先されます。",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルのURLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイルの並べ替え"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "protocol": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("プロトコルパラメータ"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("プロトコルバージョン"),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("リモートリソースのみ対応しています"),
    "providers": MessageLookupByLibrary.simpleMessage("外部リソース"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("プロキシグループが空です"),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "起動するとここにグループが表示されます",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "proxyType": MessageLookupByLibrary.simpleMessage("プロキシタイプ"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("キャッシュを整理"),
    "publicKey": MessageLookupByLibrary.simpleMessage("公開鍵"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("ピュアブラック"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("ピュアブラックモード"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QRコードをスキャンしてプロファイルを取得します",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("クイック操作"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("クイック編集"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("最近のリクエスト"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("おすすめ"),
    "recordType": MessageLookupByLibrary.simpleMessage("レコードタイプ"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直す"),
    "regex": MessageLookupByLibrary.simpleMessage("正規表現"),
    "regionApply": MessageLookupByLibrary.simpleMessage("地域を適用"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "地域またはアプリ一覧が変更されました。現在の設定で選択をやり直してください。",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "この地域に一致するアプリはありません。一覧は変更されません。",
    ),
    "regionAppsPreview": m72,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "アプリ選択のプレビュー",
    ),
    "regionBypassSettings": m73,
    "regionChina": MessageLookupByLibrary.simpleMessage("中国"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("国を選択"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("現在の地域"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "手動の DNS・MTU 設定、バイパス一覧、ルーティングルール、サービスの選択は保持されます。",
    ),
    "regionDetected": m74,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage("デバイスからの候補"),
    "regionDnsSettings": m75,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("エジプト"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "表示言語とは別に、地域のネットワーク既定値とサービス確認を設定します。",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("イラン"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "ネットワーク既定値とサービス確認は変更されません。",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "一致する候補がありません。タイムゾーンとシステムロケールのみを使用します。",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage("サービス確認はオフです"),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("オフ"),
    "regionOther": MessageLookupByLibrary.simpleMessage("その他 / 共通"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "Android では MTU やバイパスの変更に VPN の再起動確認が必要な場合があります。アプリの選択は別途実行します。",
    ),
    "regionPreviewBase": m76,
    "regionPreviewMtu": m77,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "プロキシの選択とルーティングルールは変更されません。",
    ),
    "regionPreviewServices": m78,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage("プロファイルの既定値"),
    "regionRussia": MessageLookupByLibrary.simpleMessage("ロシア"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage("地域別にアプリを選択"),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "地域別アプリ候補を使うには、対応する地域を選択してください。",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "システムロケールの国",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "システム言語",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage("タイムゾーン"),
    "regionTitle": MessageLookupByLibrary.simpleMessage("地域プロファイル"),
    "regionTunSettings": m79,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage("検出した地域を選択"),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "国の選択はプレビューだけを更新します。地域の既定値は適用後に変更されます。",
    ),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage("地域設定"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("メモリを解放"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "メモリの解放に失敗しました",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("リモート DNS 解決"),
    "remove": MessageLookupByLibrary.simpleMessage("削除"),
    "rename": MessageLookupByLibrary.simpleMessage("名前を変更"),
    "replace": MessageLookupByLibrary.simpleMessage("置換"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("すべて置換"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("リクエストと更新"),
    "required": MessageLookupByLibrary.simpleMessage("必須"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "このページには変更があります。リセットしてもよろしいですか？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("リセットしてもよろしいですか？"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自動更新間隔は0より大きくしてください",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("リソース"),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルールに従う"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "ルールに従うを有効にすると DNS 接続がルールに従います。Proxy Server Nameserver の設定が必要です。",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("応答コード"),
    "restart": MessageLookupByLibrary.simpleMessage("再起動"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("コアを再起動してもよろしいですか？"),
    "restore": MessageLookupByLibrary.simpleMessage("復元"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("すべてのデータを復元"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("プロファイルのみ復元"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("復元方式"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("互換"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("上書き"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("復元が完了しました"),
    "result": MessageLookupByLibrary.simpleMessage("結果"),
    "retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("作者・メンテナー"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("ルートアドレス"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("ルート除外アドレス"),
    "routingMark": MessageLookupByLibrary.simpleMessage("ルーティングマーク"),
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
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "ルールは 1 項目に 1 つのルールを書いた YAML リストにしてください。例：- DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent を直接接続",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS をブロック",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "プロキシのループバックを防止",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("QUIC をブロック"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("STUN をブロック"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN 直接接続"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple と Microsoft に直接接続",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("ルールプロバイダー"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("ルールセット"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "ルールセットに使用できるエントリがありません",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "この mrs ファイルを読み込めません",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "ルールセットにドメインと IP 範囲が混在しているため、種類を判別できません",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルールターゲット"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "ルールは対応する種類で始めてください。例：DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("ルール"),
    "rulesCount": m80,
    "runTime": MessageLookupByLibrary.simpleMessage("稼働時間"),
    "running": MessageLookupByLibrary.simpleMessage("実行中"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("ランタイム設定"),
    "safeMode": MessageLookupByLibrary.simpleMessage("セーフモード"),
    "safeModeAppTitle": m81,
    "saturation": MessageLookupByLibrary.simpleMessage("彩度"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "script": MessageLookupByLibrary.simpleMessage("スクリプト"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "スクリプトモード：拡張スクリプトでプロファイル全体を書き換えます",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("選択項目へスクロール"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m82,
    "secretKey": MessageLookupByLibrary.simpleMessage("キー"),
    "sectionsInEffect": m83,
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("ルールセットを選択してください"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略を選択してください",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "server": MessageLookupByLibrary.simpleMessage("サーバー"),
    "serviceAbnormalCount": m84,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("すべて利用可能"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("利用可能"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("ブロック済み"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("検査"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("すべて検査"),
    "serviceCheckedAt": m85,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("近日提供予定"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "許可されていない ISP",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("検出に失敗しました"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("サービスを管理"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("オリジナル作品のみ"),
    "servicePending": MessageLookupByLibrary.simpleMessage("未検査"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("アクセス制限"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "ダッシュボードに表示",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("サービスの状態"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("利用不可"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage("対象外の地域"),
    "settingEntries": MessageLookupByLibrary.simpleMessage("設定項目"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "settingsCount": m86,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "このプロファイルは暗号化されています。続行するには age キーを入力してください。",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "このサーバーは個別の確認に応答しました。切り替えてルート全体を再確認してください。",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage("ReClash の起動時に接続"),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "アプリと一緒にこの接続を開始します。",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage("接続を確認"),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "結果はこのルートに対するもので、すべてのアプリやサイトを対象としません。",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "選択したルートを1つ確認します。システムの許可要求は別に表示されます。",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage("接続と確認中"),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("確認済み"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "選択したルートから応答がありました。通信はプロファイルのルールに従います。",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage("接続できました"),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage("プロキシアドレスをコピー"),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("すべてのアプリ"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN は端末の通信を取得します。システムから許可を求められる場合があります。",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android は VPN 接続の作成許可を求めます。アプリの選択はアクセス設定で行います。",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash を使うアプリを選択します。サーバーを使う接続はプロファイルのルールで決まります。",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage("アプリを手動で設定する"),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "接続したい各アプリにローカルプロキシのアドレスを設定します。",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "すべての通信を取得しても、すべてをサーバー経由で送るわけではありません。直接ルートは維持されます。",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "システムプロキシに対応していないアプリは直接接続します。",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage("どのアプリを接続しますか？"),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("詳細"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage("接続に問題があります"),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "設定は後から変更できます。",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("続行"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "利用条件を読む前に言語を選択してください。後から変更できます。",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("言語を選択"),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "設定は未完了です。接続は確認されていません。",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "接続したいアプリにこのアドレスを設定してください。この確認ではアプリの設定状況は確認できません。",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage("ローカルプロキシの準備完了"),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("未確認"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "ルートから応答がありましたが、一部の確認ができませんでした。",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage("接続済み（一部制限あり）"),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "システムの確認画面で接続を許可して再試行するか、対象範囲を変更してください。",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage("権限が必要です"),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "別のサーバーを検索中",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage("接続を開始中"),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("コアを起動中"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage("出口を確認中"),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage("プロファイルを適用中"),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage("ルートを確認中"),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage("サービスを確認中"),
    "setupProfileCount": m87,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash はサーバーを提供していません。プロバイダーのサブスクリプションまたは設定を読み込んでください。",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage("プロファイルを読み込む"),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションまたは共有リンク",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("プロファイルの準備完了"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("後で設定"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage("接続プロファイルを追加"),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("接続設定"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("確認結果"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("対象範囲"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage("この地域設定を使う"),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "地域の候補は表示言語ではなく端末情報に基づきます。ネットワークに合う場合のみ適用してください。",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage("プロファイルの既定値を維持"),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("もう一度確認"),
    "setupReport": MessageLookupByLibrary.simpleMessage("確認レポート"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage("接続を許可"),
    "setupRestart": MessageLookupByLibrary.simpleMessage("接続を設定"),
    "setupResume": MessageLookupByLibrary.simpleMessage("設定を続ける"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "確認中にルートが変更されました。現在の接続をもう一度確認してください。",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "セーフモードでは実際の接続を開始しません。設定を保存するか通常ビルドでお試しください。",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "設定を保存できませんでした。もう一度お試しください。",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "接続せずに保存",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "設定を保存しました。準備ができたらダッシュボードから接続できます。",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("後で接続"),
    "setupStepStatus": m88,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "設定を保存しました。以前の接続は停止していません。",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage("確認を停止しました"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("初回接続"),
    "setupTryServer": m89,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("応答なし"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "接続は開始しましたが、選択したルートから十分な結果を得られませんでした。",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage("接続を確認できません"),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "処理が完了しませんでした。再試行するか詳細を開いてください。",
    ),
    "shareLinkUnreadable": m90,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "リンクからプロキシを読み取れませんでした",
    ),
    "show": MessageLookupByLibrary.simpleMessage("表示"),
    "showLess": MessageLookupByLibrary.simpleMessage("折りたたむ"),
    "showMore": MessageLookupByLibrary.simpleMessage("展開"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知に停止ボタンを表示",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("パスワードを表示"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage("サイドバーのぼかし"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "ウィンドウ背後のデスクトップをぼかしてサイドバーに透過します",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("サイレント起動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "サイレント起動ではウィンドウを表示しません。",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("個別追加"),
    "singleImport": MessageLookupByLibrary.simpleMessage("個別インポート"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "ここにはリンクを 1 つだけ入力してください。複数の場合は一覧のクイック編集を使ってください",
    ),
    "singleValueTip": m91,
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("証明書の検証をスキップ"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("スキップするドメイン"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "スキップするドメインにあるドメインを検出しても使用しません。",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("スキップする宛先アドレス"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("スキップする送信元アドレス"),
    "slide": MessageLookupByLibrary.simpleMessage("スライド"),
    "sliders": MessageLookupByLibrary.simpleMessage("スライダ"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "sniffer": MessageLookupByLibrary.simpleMessage("スニッファー"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "スニッファーは TLS・HTTP・QUIC の通信からドメインを読み取り、ルールで照合できるようにします。",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKSポート"),
    "softStyle": MessageLookupByLibrary.simpleMessage("ソフト"),
    "sort": MessageLookupByLibrary.simpleMessage("並べ替え"),
    "source": MessageLookupByLibrary.simpleMessage("ソース"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "spectrum": MessageLookupByLibrary.simpleMessage("スペクトル"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("速度統計"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("振り分け戦略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略は空にできません",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDが空です"),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("スタックトレース"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準モード：プロファイルにルールを追加します",
    ),
    "start": MessageLookupByLibrary.simpleMessage("開始"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("最初から作成"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPNを起動しています…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("起動とバックグラウンド"),
    "status": MessageLookupByLibrary.simpleMessage("状態"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS を無効にすると、システム DNS を使用します。",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPNを停止しています…"),
    "strategy": MessageLookupByLibrary.simpleMessage("戦略"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("厳格なルーティング"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "厳格なルーティングは DNS などの通信が TUN を迂回するのを防ぎます。有効にすると他のデバイスからこの端末にアクセスできなくなります。",
    ),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("自動"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "カスタム User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "制御文字を含まない有効な User-Agent を入力してください。",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "クライアントの選択で端末識別情報は送信されません。",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "クライアントとして要求",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "この設定はサブスクリプション URL に適用されます。プロキシリンクはローカルでインポートされます。",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションの確認には AGE キーを入力してください。",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("確認済みの結果を適用"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "サーバーが認証を拒否したため、クライアントの選択を停止しました。",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "確認",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "互換性のあるサブスクリプションを取得できませんでした。以前の設定は変更されていません。",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "現在の入力を保存や VPN の再起動なしで確認します。ノードの接続可否ではなく、設定の解析を確認します。",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage("インポート時の省略を再確認する"),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションURLを非表示",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("前回成功したクライアント"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "インポートでは元のデータの一部が省略されます。適用前に省略内容を確認してください。",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("このクライアントを使用"),
    "subscriptionCompatibilityPrepared": m92,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core がこの結果を解析しました。まだ保存も適用もされていません。",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage("サーバーがリクエストを制限しました。後で再試行してください。"),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションURLを表示",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "入力またはプロファイルが変更されました。もう一度確認してください。",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの確認がタイムアウトしました。",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "互換性",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "接続に失敗したため、クライアントの選択を停止しました。",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションで使用できる端末枠がありません。プロバイダーのアカウントから端末を削除して、もう一度お試しください。",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションでは端末の登録が必要です。プロバイダーの案内に従ってください。",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "OSと端末モデルも送信",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage("識別子とともにOSバージョンと端末モデルを送信します。"),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションのオリジンに、安定した仮名化端末IDを送信します。ハードウェア認証ではなく、同意はこの端末内だけに保存されます。",
    ),
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロファイルで上書きされない限り、すべてのURLサブスクリプションのリクエストで端末識別子を送信します。OSと端末情報はサブスクリプションごとに個別に許可します。",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションの識別情報",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "HWIDを送信",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "全体設定を使用",
    ),
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "承認してインポート",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "一部の元データが保持されないことを理解しました。",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "対応ノードのみをインポートする。",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "元クライアントの設定が省略されることを理解しました。",
    ),
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash 設定",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "暗号化されたサブスクリプション",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "プロキシリンク",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "不明な形式",
    ),
    "subscriptionImportIgnoredSections": m93,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "インポートできる対応プロキシノードがありません。",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "このサブスクリプションの同意を記憶",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "この取得元、形式、同意した省略内容にのみ適用されます。新たな省略には再度の同意が必要です。",
        ),
    "subscriptionImportReviewSummary": m94,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションのインポートを確認",
    ),
    "subscriptionImportSkippedNodes": m95,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("サブスクリプション情報"),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "アカウント",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "プランを購入",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "通信量を購入",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage("ロゴのURL"),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage("サポート"),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "ウェブサイト",
    ),
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "プロバイダーの更新間隔を使う",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage("sudo のパスワードを入力"),
    "suspended": MessageLookupByLibrary.simpleMessage("一時停止中…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("プロファイルを切り替え"),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "system": MessageLookupByLibrary.simpleMessage("システム"),
    "systemApp": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("タブアニメーション"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("アイコンをタップして再試行"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("タップして許可"),
    "target": MessageLookupByLibrary.simpleMessage("宛先"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP同時接続"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "この端末でTelegramを開けませんでした。",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Telegramを開く"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage("ブラウザーで開く"),
    "testInterval": MessageLookupByLibrary.simpleMessage("テスト間隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("テストURL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用時にテスト"),
    "textScale": MessageLookupByLibrary.simpleMessage("テキストの拡大縮小"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "アプリ内の文字はこの大きさで表示されます",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "themeColor": MessageLookupByLibrary.simpleMessage("テーマカラー"),
    "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "tight": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "time": MessageLookupByLibrary.simpleMessage("時刻"),
    "timeout": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("ティント"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "tk": MessageLookupByLibrary.simpleMessage("トルクメン語"),
    "toggle": MessageLookupByLibrary.simpleMessage("切り替え"),
    "tolerance": MessageLookupByLibrary.simpleMessage("許容値"),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("操作"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage("セクションを選ぶか設定を検索してください"),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "すべての接続が切断されます。続行しますか？",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("操作が完了しました"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("設定"),
    "toolsData": MessageLookupByLibrary.simpleMessage("リソースとデータ"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage("一致する設定や操作はありません"),
    "toolsInformation": MessageLookupByLibrary.simpleMessage("情報とデバッグ"),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("最近使った項目"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "先に認証を有効にしてください",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "先に外部コントローラーを有効にしてください",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage("この操作にはコアの起動が必要です"),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "先にカスタムネットワークインターフェースを選択してください",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "先に MIPS ネットワークスタックを選択してください",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "先に DNS ページでこの上書きを追加してください",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "先に WebDAV を設定してください",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("診断"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("ピン留めする"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("ピン留め"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage("コアを再起動"),
    "toolsResults": m96,
    "toolsRun": MessageLookupByLibrary.simpleMessage("実行"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("セクション"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("設定"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("ピン留めを解除"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage("リソースを更新"),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "ルールやスクリプトの更新により設定が再適用され、接続に影響する場合があります。続行しますか？",
    ),
    "torch": MessageLookupByLibrary.simpleMessage("ライト"),
    "total": MessageLookupByLibrary.simpleMessage("合計"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("ダウンロード量"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("合計トラフィック"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("アップロード量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxyポート"),
    "traffic": MessageLookupByLibrary.simpleMessage("通信量"),
    "trafficPeak": m97,
    "trafficTotal": m98,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("トラフィック統計"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClashはさまざまな国の人に使ってもらえるよう、あなたの言語に対応しています。不自然な表現があれば教えてください。修正します。",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage("翻訳の修正を提案する"),
    "transport": MessageLookupByLibrary.simpleMessage("トランスポート"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN の権限を取得できなかったため、オフにしました。",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("TUN は管理者モードでのみ有効です。"),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "ここで追加した項目は、すべてのプロファイルの TUN 設定を上書きします。追加していない項目はプロファイル自身の設定のままです。カスタムプロファイル自身が追加した項目が優先されます。",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("オフにする"),
    "turnOn": MessageLookupByLibrary.simpleMessage("オンにする"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP リレーモード"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP タイムアウト"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP タイムアウトは秒単位で、gvisor・system・mixed スタックでのみ有効です。",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("最高"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("統一遅延"),
    "unknown": MessageLookupByLibrary.simpleMessage("不明"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("不明なネットワークエラー"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unnamed": MessageLookupByLibrary.simpleMessage("名称未設定"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("固定を解除"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateChannel": MessageLookupByLibrary.simpleMessage("更新チャンネル"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("プレリリース"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage("リリース"),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage("更新を確認できませんでした。"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "更新をダウンロードできませんでした。",
    ),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "パッケージインストーラーを起動できませんでした。",
    ),
    "updateInstalledVersion": m99,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage("すでに最新バージョンです。"),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage("主な変更点"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "リリースノートはありません。",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash にこの提供元からのアプリのインストールを許可してから、戻って続行してください。",
    ),
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "リリースノート全文を見る",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage("すべての変更を表示"),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "ダウンロードした更新の整合性を確認できませんでした。",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("アップロード帯域幅"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URLスキーム"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("操作"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("サブスクリプションを追加する"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "HTTPまたはHTTPSのサブスクリプションURLからプロファイルを作成します。名前は省略できます。",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "暗号化リンクを認証できませんでした。破損しているか、異なる鍵を使っている可能性があります。",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("リンクを作成"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "選択した操作に必要な項目だけが含まれます。設定リンクは内容全体を含み、確認を省略することはできません。",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("アプリを閉じる"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "終了設定に従ってウィンドウを隠すかReClashを終了します。Androidでは通常のアプリ終了動作に従います。",
    ),
    "urlSchemeConfigCounts": m100,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAMLまたはJSONの設定を貼り付けてください",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage("設定の内容"),
    "urlSchemeConfirmMessage": m101,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "外部からのアプリコマンド",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "外部からの接続・終了コマンドは確認が必要です。接続コマンドを使う前に初期設定を完了してください。",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("接続する"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "選択中のプロファイルと現在の適用範囲設定で接続を開始します。",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("接続"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage("内容の形式"),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "変換では一部の内容が省略されます。インポート時に変更を確認して承認してください。",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "リンクをコピーできませんでした。再試行してください。",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "リンクを受け取れなかったか、待機キューがいっぱいです。現在の操作が終わってから再試行してください。",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("切断する"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "選択中のプロファイルを変更せずに接続を停止します。",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage("埋め込み設定"),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "サンプルプロファイル",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("設定をインポートする"),
    "urlSchemeImportConfirm": m102,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "リンクにBase64で埋め込まれたUTF-8設定をインポートします。名前は省略できます。",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage("リンクを確認"),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "アプリまたはプロファイルのリンクを貼り付けてください",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "確認はこの端末内で行います。リンクを開いたり、サブスクリプションをダウンロードしたり、プロファイルをインポートしたりしません。",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "リンクの構造は有効です。サブスクリプションの取得とコアによる検証はインポート時に行います。",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage("確認結果"),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "設定をインストールする",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clashクライアント対応のinstall-config形式でサブスクリプションをインポートします。",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "ReClashをショートカット、ウェブサイト、ほかのアプリと連携させます。すぐ使えるリンクを作成したり、開く前に内容を確認したりできます。",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "埋め込み設定が有効なUTF-8 Base64データではありません。",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "リンクの形式が正しくありません。構造とパーセントエンコーディングを確認してください。",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "プロファイル名は64文字以内にし、制御文字を含めないでください。",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "有効なHTTPまたはHTTPSのサブスクリプションURLを入力してください。",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "リンクにサブスクリプションURLまたは設定がありません。",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "操作は実行されていません。",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("アプリを表示する"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "接続状態を変えずにReClashを前面に表示します。",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("パラメーター"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "クリップボードを読み取れませんでした。リンクを手動で貼り付けてください。",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("リンクのプレビュー"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "必須項目を入力するとリンクが表示されます。",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "リンクにはアクセストークンやプロキシ認証情報が含まれる場合があります。信頼できる相手にだけ共有してください。ReClashはリンクの履歴を保存しません。",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "プロファイルコマンドはリンク作成画面を開きます。外部リンクのインポートには確認が必要で、通常の検証と変換チェックも行われます。",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage("プロキシ共有リンク"),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage("リンクを認識しました"),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "外部接続コマンドを使う前に接続の初期設定を完了してください。",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "対応するインポートリンク",
    ),
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Clashリンク、INCY・Happのラップされたリンク、プロキシ共有リンクは手動インポートやQRスキャンでも使えます。未知の暗号化バージョンは拒否されます。",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("接続を切り替える"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "停止中なら接続し、接続中なら切断します。確認画面には実際の操作が表示されます。",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "リンクのラップが多重に入れ子になりすぎています。",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "リンクが4 MB、または埋め込み設定が2 MBを超えています。",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "このリンクコマンドには対応していません。",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "この暗号化バージョンには対応していません。通常のサブスクリプションリンクを依頼してください。",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("例を使う"),
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション、埋め込み設定、INCY crypt1",
    ),
    "urlTip": m103,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostsを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムのHostsを使用"),
    "usedShort": MessageLookupByLibrary.simpleMessage("使用済み"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("使用済みトラフィック"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("ユーザー名"),
    "uz": MessageLookupByLibrary.simpleMessage("ウズベク語"),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "view": MessageLookupByLibrary.simpleMessage("表示"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("仮想 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("ビビッド"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN関連の設定変更を検出しました",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN は VpnService でシステムの全トラフィックを自動的にルーティングします。",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("ぼかし"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage("カードの不透明度"),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("画像を選択"),
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
    "wallpaperImageLabel": m104,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("構図"),
    "wallpaperLibraryFull": m105,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("画像の不透明度"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("読みやすさ"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("画像を削除"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("効果をリセット"),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage("構図をリセット"),
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
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage("画像を利用できません"),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "垂直方向の位置",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("ウェブパネル"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "パネルへのアクセスが終了しました",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "アクセスはローカルで認証されます。保存された外部コントローラー設定は変更されません。ブラウザーの使用後はここでアクセスを終了してください。",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "パネルの設定を適用できませんでした。",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "有効なパネルのアーカイブではありません。",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "コアが認証情報を拒否しました。パネルを開き直してください。",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "ブラウザーのアクセスは終了操作またはReClashの終了まで続きます",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage("別のパネル操作が進行中です。"),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "パネルの操作をキャンセルしました。",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "チェックサムが固定されたリリースと一致しません。",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "コアの準備ができていません。",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "コアを管理するローカルウェブパネル",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "パネルをダウンロードできませんでした。再試行してください。",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "パネルをダウンロード中",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "パネルを閉じるとアクセスが終了します",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "パネルへのアクセスを終了",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage("パネルを展開中"),
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage("パネルのファイル"),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("パネル"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage("パネルをインストール"),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "選択したパネルは初回起動時にダウンロードされます。固定されたリリースをSHA-256で検証します。",
    ),
    "webDashboardInstalledVersion": m106,
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "ブラウザーを開けませんでした。",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage("パネルのセッションなし"),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "パネルを開く前にプロファイルを選択してください。",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage("未インストール"),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("パネルを開く"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "ブラウザーで開く",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("再読み込み"),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "セーフモードではパネルへのアクセスは無効です。",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "パネルのファイルを安全に読み取りまたは置換できませんでした。",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "パネルのアーカイブが許容サイズを超えています。",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "コアはこのパネルを提供していません。",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage("ダウンロードを検証中"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("ホワイトリストモード"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("システムに書き込む"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "システムに書き込むを有効にするとシステムクロックも設定します。Android では無視されます。",
    ),
    "yearsAgo": m107,
    "yearsAgoShort": m108,
    "yes": MessageLookupByLibrary.simpleMessage("はい"),
    "zhCN": MessageLookupByLibrary.simpleMessage("簡体字中国語"),
  };
}
