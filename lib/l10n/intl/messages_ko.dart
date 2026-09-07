// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(time) => "DPI 우회 중 ${time}";

  static String m1(time) => "${time}째 연결 중";

  static String m2(code) =>
      "Windows가 ReClashCore.exe 실행을 거부했습니다(오류 ${code}). 스마트 앱 제어나 AppLocker 같은 앱 제어 정책이 서명되지 않은 프로그램을 차단합니다. 해당 정책에서 ReClash를 허용하거나 정책을 끈 후 다시 시도하세요.";

  static String m3(name) =>
      "앱이 연속 두 번 시작하지 못했습니다. 같은 문제가 반복되지 않도록 ${name} 프로필 선택을 해제하고 자동 설정을 건너뛰었습니다. 언제든 다시 선택할 수 있습니다.";

  static String m4(url) => "${url}에서 프로필을 추가하시겠습니까?";

  static String m5(count) =>
      "${Intl.plural(count, one: '1일 전', other: '${count}일 전')}";

  static String m6(count) =>
      "${Intl.plural(count, one: '1일 남음', other: '${count}일 남음')}";

  static String m7(label) => "선택한 ${label}을(를) 삭제하시겠습니까?";

  static String m8(label) => "이 ${label}을(를) 삭제하시겠습니까?";

  static String m9(token) => "${token}은(는) 앱이 설정하므로 제외됩니다";

  static String m10(count) => "${Intl.plural(count, other: '인수 ${count}개')}";

  static String m11(token) => "${token}에 값이 필요합니다";

  static String m12(token) => "${token}은(는) 옵션이 아닙니다";

  static String m13(token) => "알 수 없는 옵션 ${token}";

  static String m14(count) => "${count}개 라우팅 카테고리가 ByeDPI 엔진 사용";

  static String m15(presets, groups, domains) =>
      "프리셋 ${presets}개 · 그룹 ${groups}개 · 호스트 ${domains}개";

  static String m16(count) => "${Intl.plural(count, other: '도메인 ${count}개')}";

  static String m17(count) => "완료: ${count}개 전략을 테스트했습니다";

  static String m18(count) =>
      "엔진을 통해 ${count}개 호스트에 모든 알려진 전략을 시도합니다; 종료 후 현재 전략으로 되돌립니다";

  static String m19(index, total) => "테스트 중 ${index} / ${total}";

  static String m20(passed, total) => "${total}개 중 ${passed}개 호스트 응답";

  static String m21(label) => "${label} 세부 정보";

  static String m22(name) => "${name} 설치 완료";

  static String m23(label) => "${label}은(는) 비워 둘 수 없습니다";

  static String m24(count) =>
      "${Intl.plural(count, one: '항목 1개', other: '항목 ${count}개')}";

  static String m25(label) => "이미 ${label}이(가) 있습니다";

  static String m26(name) => "${name}은(는) 이미 최신 버전입니다";

  static String m27(name) => "${name}이(가) 업데이트됐습니다";

  static String m28(time) => "${time} 전";

  static String m29(count) =>
      "${Intl.plural(count, one: '1시간 전', other: '${count}시간 전')}";

  static String m30(count) =>
      "${Intl.plural(count, one: '1시간', other: '${count}시간')}";

  static String m31(target) => "${target}은(는) 잘못된 정책입니다";

  static String m32(proxyName) => "${proxyName}은(는) 잘못된 프록시입니다";

  static String m33(providerName) => "${providerName}은(는) 잘못된 프록시 공급자입니다";

  static String m34(subRule) => "${subRule}은(는) 잘못된 SUB_RULE입니다";

  static String m35(address) => "또는 ${address}(으)로 JSON을 보내세요";

  static String m36(appName) =>
      "1. 시스템 설정 > 개인 정보 보호 및 보안을 엽니다\n2. 위치 서비스를 선택합니다\n3. 목록에서 ${appName}을(를) 찾아 켭니다\n\n설정을 마친 후 앱으로 돌아와 계속 진행하세요. 협조해 주셔서 감사합니다.";

  static String m37(label, max) => "${label}은(는) 최대 ${max}자여야 합니다";

  static String m38(count) =>
      "${Intl.plural(count, one: '1분 전', other: '${count}분 전')}";

  static String m39(count) =>
      "${Intl.plural(count, one: '1개월 전', other: '${count}개월 전')}";

  static String m40(label) => "아직 ${label}이(가) 없습니다";

  static String m41(label) => "${label}은(는) 숫자여야 합니다";

  static String m42(label) => "${label}은(는) 1024~49151 사이의 값이어야 합니다";

  static String m43(count) =>
      "${Intl.plural(count, one: '프록시 1개', other: '프록시 ${count}개')}";

  static String m44(count) =>
      "${Intl.plural(count, one: '규칙 1개', other: '규칙 ${count}개')}";

  static String m45(darkAt, lightAt) => "${darkAt}부터 ${lightAt}까지 다크 모드를 사용합니다";

  static String m46(count) =>
      "${Intl.plural(count, one: '1초', other: '${count}초')}";

  static String m47(count) => "${count}개 선택됨";

  static String m48(count) => "프로필 ${count}개 준비 완료";

  static String m49(step, count) => "${count}단계 중 ${step}단계";

  static String m50(name) => "프로필: ${name}";

  static String m51(value) => "스마트 라우팅: ${value}";

  static String m52(alive, total) => "지금 서버 ${total}개 중 ${alive}개 사용 가능";

  static String m53(percent, duration) => "${duration} 동안 ${percent}%";

  static String m54(band) => "구간 ${band}";

  static String m55(bands) => "대역: ${bands}";

  static String m56(count) => "실패 ${count}회 후 대기 중";

  static String m57(answered, total) => "${total}개 중 ${answered}개 응답";

  static String m58(seconds) => "${seconds}초 남음";

  static String m59(count) => "연속 ${count}회 실패";

  static String m60(measured, total) => "${total}개 중 ${measured}개 측정";

  static String m61(preset) => "${preset} · 조정됨";

  static String m62(left, cap) => "최근 1시간 동안 탐색 ${cap}회 중 ${left}회 남음";

  static String m63(seconds) => "${seconds}초";

  static String m64(eligible, total) => "${total}개 중 ${eligible}개 사용 가능";

  static String m65(eligible, total, blocked) =>
      "서버 ${total}개 중 ${eligible}개가 통과했고 ${blocked}개는 보류됐습니다";

  static String m66(from, to) => "${from} → ${to}";

  static String m67(time) => "${time} 전에 전환됨";

  static String m68(count) => "서버 ${count}개";

  static String m69(host) => "제공자가 ${host}(으)로 이동했습니다";

  static String m70(count) =>
      "${Intl.plural(count, one: '구독이 내일 만료됩니다', other: '구독이 ${count}일 후에 만료됩니다')}";

  static String m71(value) => "제공자 권장값: ${value}";

  static String m72(total) => "전체 ${total} 중 사용 가능";

  static String m73(label) => "${label}은(는) URL이어야 합니다";

  static String m74(count) =>
      "${Intl.plural(count, one: '1년 전', other: '${count}년 전')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("정보"),
    "accessControl": MessageLookupByLibrary.simpleMessage("액세스 제어"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱만 VPN을 통과합니다",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "어떤 앱이 프록시를 사용할지 제어합니다",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "앱 액세스 제어가 꺼져 있습니다",
    ),
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "VPN에서 제외",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "VPN에 포함",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱은 VPN을 통과하지 않습니다",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("액세스 제어 설정"),
    "account": MessageLookupByLibrary.simpleMessage("계정"),
    "action": MessageLookupByLibrary.simpleMessage("동작"),
    "actionMode": MessageLookupByLibrary.simpleMessage("모드 전환"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "actionStart": MessageLookupByLibrary.simpleMessage("시작/중지"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("표시/숨기기"),
    "add": MessageLookupByLibrary.simpleMessage("추가"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("네트워크 추가"),
    "addProfile": MessageLookupByLibrary.simpleMessage("프로필 추가"),
    "addProxies": MessageLookupByLibrary.simpleMessage("프록시 추가"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 추가"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage("프록시 공급자 추가"),
    "addRule": MessageLookupByLibrary.simpleMessage("규칙 추가"),
    "addWidget": MessageLookupByLibrary.simpleMessage("위젯 추가"),
    "addedRules": MessageLookupByLibrary.simpleMessage("추가된 규칙"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage("추가 매개변수"),
    "address": MessageLookupByLibrary.simpleMessage("주소"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV 서버 주소"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "올바른 WebDAV 주소를 입력해 주세요.",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("고급 설정"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "다양한 설정 옵션을 제공합니다",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("동의"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("앱의 VPN 우회 허용"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "켜면 일부 앱이 VPN을 우회할 수 있습니다",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN 허용"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN에서 프록시 접근을 허용합니다"),
    "animations": MessageLookupByLibrary.simpleMessage("애니메이션"),
    "announce": MessageLookupByLibrary.simpleMessage("공지사항"),
    "app": MessageLookupByLibrary.simpleMessage("앱"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("앱 액세스 제어"),
    "appIcon": MessageLookupByLibrary.simpleMessage("앱 아이콘"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "런처는 몇 초 안에 아이콘을 다시 그립니다. 일부 런처에서는 고정된 바로가기가 사라질 수 있습니다.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("서킷"),
    "appIconGlacier": MessageLookupByLibrary.simpleMessage("글레이셔"),
    "appIconObsidian": MessageLookupByLibrary.simpleMessage("옵시디언"),
    "appIconPrism": MessageLookupByLibrary.simpleMessage("프리즘"),
    "appIconPulse": MessageLookupByLibrary.simpleMessage("펄스"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("솔라"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("벨벳"),
    "appearance": MessageLookupByLibrary.simpleMessage("외관"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "테마, 색상, 아이콘, 대시보드 모양",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("아이콘"),
    "appearanceLayout": MessageLookupByLibrary.simpleMessage("레이아웃"),
    "appearanceMotion": MessageLookupByLibrary.simpleMessage("모션"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("테마"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 추가"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "구성에 시스템 DNS를 강제로 추가합니다",
    ),
    "application": MessageLookupByLibrary.simpleMessage("애플리케이션"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("앱의 세부 설정을 변경합니다"),
    "authentication": MessageLookupByLibrary.simpleMessage("인증"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "로컬 프록시 포트에 인증을 요구해 다른 앱이 이 포트를 사용하지 못하도록 합니다",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "인증이 켜져 있으면 시스템 프록시에는 적용되지 않습니다",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("승인"),
    "authorized": MessageLookupByLibrary.simpleMessage("승인됨"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("업데이트 자동 확인"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "앱 시작 시 자동으로 업데이트를 확인합니다",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("연결 자동 종료"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "노드를 전환한 후 연결을 자동으로 종료합니다",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("자동 시작"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "시스템 시작 시 자동으로 실행됩니다",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("자동 실행"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("앱을 열면 자동으로 실행합니다"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 자동 설정"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("자동 업데이트 간격(분)"),
    "back": MessageLookupByLibrary.simpleMessage("뒤로"),
    "backup": MessageLookupByLibrary.simpleMessage("백업"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("백업 및 복원"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV 또는 파일로 데이터를 동기화합니다",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("백업이 완료됐습니다."),
    "basicConfig": MessageLookupByLibrary.simpleMessage("기본 설정"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "기본 설정을 전역으로 수정합니다",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("기본 정보"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("기본 전략"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "앱을 백그라운드에서 계속 실행하려면 배터리 최적화를 해제하세요. 탭하면 설정 화면이 열립니다.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "시스템 제한 때문에 실행 중에는 배터리 최적화 상태를 제대로 확인할 수 없습니다",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("연결"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("블랙리스트 모드"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("연결 차단"),
    "byedpiActive": MessageLookupByLibrary.simpleMessage("DPI 우회 활성"),
    "byedpiActiveFor": m0,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage("DPI 엔진 확인 중"),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage("DPI 엔진 확인 필요"),
    "byedpiOff": MessageLookupByLibrary.simpleMessage("DPI 우회 꺼짐"),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage("DPI 우회 일시 중지"),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage(
      "DPI 엔진 다시 시작 중",
    ),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage("DPI 우회 시작 중"),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage("탭하여 DPI 우회 재개"),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage("탭하여 로컬 우회 엔진 시작"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("우회 도메인"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "시스템 프록시가 켜져 있을 때만 적용됩니다",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "캐시가 손상됐습니다. 지우시겠습니까?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("선택 해제"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "프록시 전환에 실패해 이전 선택으로 되돌렸습니다.",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("서버 변경"),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("호환성 깨짐"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("새로운 기능"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("버그 수정"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("성능"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("되돌림"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS 인증서 확인"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "신뢰할 수 없는 인증서를 거부합니다. 끄면 구독과 백업이 중간자 공격에 노출됩니다.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("이미 최신 버전입니다."),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("클래식"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "시작 버튼이 있는 타일 그리드",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("데이터 지우기"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("검색어 지우기"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage("지원되지 않는 클라이언트"),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "제공자가 이 클라이언트를 지원하지 않습니다.",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("클립보드로 내보내기"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("클립보드에서 가져오기"),
    "close": MessageLookupByLibrary.simpleMessage("닫기"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("연결 끊기"),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN이 일시 중지되면 열려 있는 모든 연결을 끊습니다",
    ),
    "color": MessageLookupByLibrary.simpleMessage("색상"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("색 구성표"),
    "columns": MessageLookupByLibrary.simpleMessage("열"),
    "compatible": MessageLookupByLibrary.simpleMessage("호환 모드"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "구성에서 기존 데이터를 감지했습니다",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "모든 데이터를 지우시겠습니까?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "이 프록시 그룹을 삭제하시겠습니까?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("현재 창을 닫으시겠습니까?"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 크래시하시겠습니까?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "확인하면 기존 데이터를 덮어씁니다",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("연결됨"),
    "connectedFor": m1,
    "connecting": MessageLookupByLibrary.simpleMessage("연결 중…"),
    "connection": MessageLookupByLibrary.simpleMessage("연결"),
    "connections": MessageLookupByLibrary.simpleMessage("연결"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("현재 연결 데이터를 확인합니다"),
    "connectivity": MessageLookupByLibrary.simpleMessage("연결 상태: "),
    "content": MessageLookupByLibrary.simpleMessage("내용"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("내용은 비워 둘 수 없습니다"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("콘텐츠"),
    "contrast": MessageLookupByLibrary.simpleMessage("대비"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "순수 검정 배경에서는 대비 +0.3이 대체로 더 읽기 편합니다",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "전역 추가 규칙 관리",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("복사"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage("버전 정보 복사"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("환경 변수 복사"),
    "copyLink": MessageLookupByLibrary.simpleMessage("링크 복사"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("복사됐습니다"),
    "core": MessageLookupByLibrary.simpleMessage("코어"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 스마트 앱 제어가 서명되지 않은 ReClashCore.exe를 차단했습니다. Windows 보안 → 앱 및 브라우저 제어 → 스마트 앱 제어 설정을 열고 \'끄기\'를 선택한 다음 ReClash를 다시 시작하세요. 스마트 앱 제어는 Windows를 다시 설치하지 않으면 다시 켤 수 없습니다.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("코어 상태"),
    "country": MessageLookupByLibrary.simpleMessage("지역"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("크래시 감지됨"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("크래시 테스트"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("크래시 분석"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "사용하면 앱이 크래시될 때 민감 정보를 제외한 크래시 로그가 자동으로 업로드됩니다",
    ),
    "create": MessageLookupByLibrary.simpleMessage("만들기"),
    "createProfile": MessageLookupByLibrary.simpleMessage("프로필 만들기"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("생성 시간"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — 이 앱의 기반이 된 클라이언트",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — 프로바이더 기능과 아이디어",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("mihomo — 프록시 코어"),
    "custom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("잘라내기"),
    "dark": MessageLookupByLibrary.simpleMessage("어둡게"),
    "darkAt": MessageLookupByLibrary.simpleMessage("다크 모드 시작"),
    "dashboard": MessageLookupByLibrary.simpleMessage("대시보드"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 프로필 없이 DPI를 우회하려면 ByeDPI 전용 모드를 사용하세요.",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage(
      "VPN 제공업체가 없나요?",
    ),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "프로필이 저장되어 있지만 활성 프로필이 없습니다. VPN 제어를 사용하려면 하나를 선택하세요.",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "VPN 프로필 선택",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "신뢰하는 제공업체의 VPN 프로필을 추가하세요. 추가하기 전까지 VPN은 꺼진 상태로 유지됩니다.",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage("연결 설정"),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage("프로필 선택"),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("대시보드 스타일"),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI 사용"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "변경 사항이 있습니다. 저장하시겠습니까?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "이 앱은 안정성 개선을 위해 Firebase Crashlytics로 크래시 정보를 수집합니다.\n수집 항목은 기기 정보와 크래시 세부 정보이며, 민감한 개인 정보는 포함되지 않습니다.\n설정에서 언제든 끌 수 있습니다.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage("데이터 수집 안내"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "변경 사항 저장에 실패해 되돌렸습니다.",
    ),
    "day": MessageLookupByLibrary.simpleMessage("일"),
    "days": MessageLookupByLibrary.simpleMessage("일"),
    "daysAgo": m5,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("일"),
    "daysLeft": m6,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("기본 네임서버"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 서버를 확인하는 데 사용됩니다",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("기본"),
    "delay": MessageLookupByLibrary.simpleMessage("지연"),
    "delayTest": MessageLookupByLibrary.simpleMessage("지연 시간 테스트"),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteMultipTip": m7,
    "deleteTip": m8,
    "desc": MessageLookupByLibrary.simpleMessage(
      "멀티플랫폼 mihomo 클라이언트: 새로 구성한 대시보드, 더 스마트한 라우팅, 강력한 구독 지원. 오픈소스이며 광고와 텔레메트리가 없습니다.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("대상"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("대상 GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("대상 IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPI 우회"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage("활성 전략"),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("엔진 인수"),
    "desyncArgsAppOwnedFlag": m9,
    "desyncArgsCount": m10,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m11,
    "desyncArgsPositional": m12,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage("닫히지 않은 따옴표"),
    "desyncArgsUnknownFlag": m13,
    "desyncCache": MessageLookupByLibrary.simpleMessage("전략 캐시"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "선택된 전략은 네트워크별로 보관됩니다",
    ),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage("전략 캐시 꺼짐"),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("보관 기간"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("기본 사다리"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage("ByeDPI 디싱크 전략"),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("엔진"),
    "desyncEngineSummary": m14,
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("TCP 강제"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "위 카테고리의 QUIC를 차단합니다; 디싱크는 UDP에 닿지 못합니다",
    ),
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("연결 모드"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("라우팅"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 GEOSITE 카테고리 밖의 모든 트래픽은 직접 연결됩니다",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "카테고리 구성은 내장 GEOSITE 데이터베이스에서 가져오며 테스트 도메인 목록과 별개입니다",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "우회 카테고리 미선택",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "현재 ByeDPI를 통하는 서비스가 없습니다",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage("적용 규칙"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("현재 것 저장"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage("전략 이름"),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("전략"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "중단됨: 전략이 엔진에 닿지 않습니다",
    ),
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("테스트 배터리"),
    "desyncTestBatterySummary": m15,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("테스트 도메인"),
    "desyncTestDomainsCount": m16,
    "desyncTestDone": m17,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "이 전략에서 엔진이 중단되었습니다",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "엔진이 실행 중이 아닙니다 — DPI 우회를 켜고 먼저 연결하세요",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "이 전략이 실패한 호스트",
    ),
    "desyncTestHint": m18,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "아래에서 도메인 목록을 하나 이상 선택하세요",
    ),
    "desyncTestProgress": m19,
    "desyncTestScore": m20,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("전략 테스트"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("시작"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage("모든 프리셋 실행"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12시간"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28시간"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1시간"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7일"),
    "details": m21,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "외부 API를 사용하므로 참고용입니다",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("IP 확인 중…"),
    "developerMode": MessageLookupByLibrary.simpleMessage("개발자 모드"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "개발자 모드가 켜져 있습니다",
    ),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "공급자 위젯, 서버 전환 및 프록시 레이아웃",
    ),
    "developerSubscriptionInstalled": m22,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "할당량, 만료, 공지, 도메인 이전 및 상품",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "브랜드 색상, 사용자 지정 Hero Ring 및 로컬 로고",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage("테스트 구독"),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage("기기 제한 초과"),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "이 구독의 기기 연결 한도에 도달했다고 제공자가 알려왔습니다. 그래도 구독은 업데이트됐습니다.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("직접"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP 사용 안 함"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("면책 조항"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "이 소프트웨어는 학습, 연구 등 비상업적 용도로만 사용할 수 있습니다. 상업적 목적으로 사용하는 것은 엄격히 금지되며, 모든 상업적 활동은 이 소프트웨어와 무관합니다.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("연결 해제됨"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("새 버전이 있습니다"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS 관련 설정을 변경합니다"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS 하이재킹"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 모드"),
    "domain": MessageLookupByLibrary.simpleMessage("도메인"),
    "download": MessageLookupByLibrary.simpleMessage("다운로드"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("업데이트 다운로드 중"),
    "edit": MessageLookupByLibrary.simpleMessage("편집"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("전역 규칙 편집"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("네트워크 편집"),
    "editProxy": MessageLookupByLibrary.simpleMessage("프록시 편집"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 편집"),
    "editRule": MessageLookupByLibrary.simpleMessage("규칙 편집"),
    "emptyTip": m23,
    "en": MessageLookupByLibrary.simpleMessage("영어"),
    "enterManually": MessageLookupByLibrary.simpleMessage("직접 입력"),
    "entries": MessageLookupByLibrary.simpleMessage(" 항목"),
    "entriesCount": m24,
    "exclude": MessageLookupByLibrary.simpleMessage("최근 앱 목록에서 숨기기"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드에 있을 때 앱을 최근 앱 목록에서 숨깁니다",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage("제외 프록시 필터"),
    "excludeType": MessageLookupByLibrary.simpleMessage("제외 유형"),
    "existsTip": m25,
    "exit": MessageLookupByLibrary.simpleMessage("종료"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("전체 화면 종료"),
    "expand": MessageLookupByLibrary.simpleMessage("표준"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("예상 상태"),
    "expireTime": MessageLookupByLibrary.simpleMessage("만료 시간"),
    "exportFile": MessageLookupByLibrary.simpleMessage("파일 내보내기"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("로그 내보내기"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("내보내기가 완료됐습니다"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("표현력"),
    "externalController": MessageLookupByLibrary.simpleMessage("외부 컨트롤러"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "켜면 9090 포트를 통해 Clash 코어를 제어할 수 있습니다",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("외부에서 가져오기"),
    "externalLink": MessageLookupByLibrary.simpleMessage("외부 링크"),
    "extra": MessageLookupByLibrary.simpleMessage("기타"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP 필터"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP 범위"),
    "fallback": MessageLookupByLibrary.simpleMessage("폴백"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("일반적으로 해외 DNS입니다"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("폴백 필터"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("충실도"),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("파일에서 직접 프로필을 추가합니다"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "파일이 수정됐습니다. 변경 사항을 저장하시겠습니까?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("프로세스 찾기"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "사용하면 성능이 다소 저하됩니다",
    ),
    "followProfile": MessageLookupByLibrary.simpleMessage("프로필 따르기"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("글꼴"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 다시 시작하시겠습니까?",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("과일 샐러드"),
    "general": MessageLookupByLibrary.simpleMessage("일반"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage("자동 업데이트 간격"),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격은 0보다 커야 합니다",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("GeoIP 옵션"),
    "geoResources": MessageLookupByLibrary.simpleMessage("GeoIP 리소스"),
    "geoSkipped": m26,
    "geoUpdated": m27,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo 메모리 절약 모드"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "메모리를 적게 쓰는 Geo 로더를 사용합니다",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP 코드"),
    "global": MessageLookupByLibrary.simpleMessage("전역"),
    "go": MessageLookupByLibrary.simpleMessage("이동"),
    "goDownload": MessageLookupByLibrary.simpleMessage("다운로드"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("스크립트 구성으로 이동"),
    "gratitude": MessageLookupByLibrary.simpleMessage("감사한 분들"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash는 이 프로젝트 덕분에 존재합니다",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("변경 사항을 캐시하시겠습니까?"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "헬퍼 서비스를 사용할 수 없어 TUN 모드를 켤 수 없습니다. ReClash를 다시 설치하면 복구됩니다.",
    ),
    "heroChecking": MessageLookupByLibrary.simpleMessage("네트워크 확인 중…"),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage(
      "선택한 노드를 측정하고 있습니다",
    ),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("연결 중…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("방금 전"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage("연결에 문제가 있습니다"),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage("노드가 응답하지 않습니다"),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage(
      "트래픽이 일시 중지되어 보호도 대기 중입니다",
    ),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage("노드가 느리게 응답합니다"),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage("네트워크 연결 대기 중"),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("보호되지 않음"),
    "heroPaused": MessageLookupByLibrary.simpleMessage(
      "일시 중지됨 · 신뢰할 수 있는 네트워크",
    ),
    "heroProtected": MessageLookupByLibrary.simpleMessage("보호됨"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage("다시 연결하는 중…"),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage(
      "터널을 복원하고 있습니다",
    ),
    "heroRoutingAgo": m28,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage("스마트 라우팅이 꺼져 있습니다"),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage("탭해서 보호를 켜세요"),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage("탭해서 보호를 재개하세요"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("목록에서 숨기기"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("비밀번호 숨기기"),
    "host": MessageLookupByLibrary.simpleMessage("호스트"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("호스트 추가"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("단축키 충돌"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("단축키 관리"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "키보드로 앱을 제어합니다",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("시간"),
    "hours": MessageLookupByLibrary.simpleMessage("시간"),
    "hoursAgo": m29,
    "hoursCount": m30,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("시간"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("시간"),
    "icon": MessageLookupByLibrary.simpleMessage("아이콘"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("아이콘 기록"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("아이콘 스타일"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("아이콘 URL"),
    "identity": MessageLookupByLibrary.simpleMessage("식별 정보"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "배터리 최적화 무시",
    ),
    "import": MessageLookupByLibrary.simpleMessage("가져오기"),
    "importFile": MessageLookupByLibrary.simpleMessage("파일에서 가져오기"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URL에서 가져오기"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL에서 가져오기"),
    "inbound": MessageLookupByLibrary.simpleMessage("인바운드"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage("모든 프록시 포함"),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹에 속하지 않은 모든 프록시를 가져옵니다. 아래에서 프록시 그룹을 더 추가할 수 있습니다",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "모든 프록시 공급자 포함",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "켜면 가져온 프록시 공급자를 덮어씁니다",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("만료되지 않음"),
    "init": MessageLookupByLibrary.simpleMessage("초기화"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "올바른 단축키를 입력해 주세요",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹 이름을 입력하세요",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("규칙 내용을 입력하세요"),
    "installUpdate": MessageLookupByLibrary.simpleMessage("업데이트 설치"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "앱 목록 권한이 거부되어 설치된 앱을 표시할 수 없습니다. 시스템 설정에서 직접 권한을 허용해 주세요.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "이 시스템은 권한을 허용하기 전까지 설치된 앱 목록을 숨깁니다. 앱별 프록시를 설정하려면 이 권한을 허용해 주세요.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "앱 목록 권한 필요",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("스마트 선택"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("인터페이스 이름"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "아웃바운드 연결에 사용되는 네트워크 인터페이스입니다",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("아웃바운드 인터페이스"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("지우기"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("설정 따르기"),
    "internet": MessageLookupByLibrary.simpleMessage("인터넷"),
    "interval": MessageLookupByLibrary.simpleMessage("간격"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("사설 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("잘못된 백업 파일입니다."),
    "invalidPolicy": m31,
    "invalidProxy": m32,
    "invalidProxyProvider": m33,
    "invalidSubRule": m34,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("켜면 IPv6 트래픽을 수신할 수 있습니다"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("IPv6 인바운드 허용"),
    "ja": MessageLookupByLibrary.simpleMessage("일본어"),
    "justNow": MessageLookupByLibrary.simpleMessage("방금"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 연결 유지 간격",
    ),
    "key": MessageLookupByLibrary.simpleMessage("키"),
    "kk": MessageLookupByLibrary.simpleMessage("카자흐어"),
    "ko": MessageLookupByLibrary.simpleMessage("한국어"),
    "lanProfileImport": MessageLookupByLibrary.simpleMessage("휴대전화에서 받기"),
    "lanProfileImportAddress": m35,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "로컬 네트워크를 통해 구독 URL을 전송할 일회용 QR 코드를 표시합니다",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage(
      "구독을 가져올 수 없습니다",
    ),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage(
      "구독을 받았습니다",
    ),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "구독을 가져오는 중…",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "같은 네트워크의 휴대전화로 이 QR 코드를 스캔하세요",
    ),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "로컬 공유를 시작할 수 없습니다",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "일회용 링크가 만료되었습니다",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage("구독 받기"),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage(
      "구독을 기다리는 중…",
    ),
    "language": MessageLookupByLibrary.simpleMessage("언어"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("시작이 완료되지 않음"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "지난번에 앱이 시작 중에 예기치 않게 종료되었습니다. 이번에는 자동 설정을 건너뛰었으니 앱을 직접 시작해 다시 시도해 보세요.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("레이아웃"),
    "license": MessageLookupByLibrary.simpleMessage("라이선스"),
    "licenses": MessageLookupByLibrary.simpleMessage("라이선스"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("앱에 포함된 패키지"),
    "light": MessageLookupByLibrary.simpleMessage("밝게"),
    "lightAt": MessageLookupByLibrary.simpleMessage("라이트 모드 시작"),
    "list": MessageLookupByLibrary.simpleMessage("목록"),
    "listen": MessageLookupByLibrary.simpleMessage("수신 대기"),
    "loading": MessageLookupByLibrary.simpleMessage("불러오는 중…"),
    "local": MessageLookupByLibrary.simpleMessage("로컬"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("데이터를 로컬에 백업합니다"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("위치 권한"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "위치 권한이 거부되어 현재 와이파이 이름을 확인할 수 없습니다. 시스템 설정에서 위치 권한을 직접 허용해 주세요.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "와이파이 이름을 확인하려면 위치 권한이 필요합니다. Android에서는 \"항상 허용\"을 선택하세요. 그렇지 않으면 앱이 백그라운드에 있을 때 와이파이 이름을 확인할 수 없습니다.",
    ),
    "locationPermissionGuide": m36,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "위치 권한 필요",
    ),
    "log": MessageLookupByLibrary.simpleMessage("로그"),
    "logLevel": MessageLookupByLibrary.simpleMessage("로그 레벨"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("끄면 로그 메뉴가 표시되지 않습니다"),
    "logs": MessageLookupByLibrary.simpleMessage("로그"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("수집된 로그"),
    "logsTest": MessageLookupByLibrary.simpleMessage("로그 테스트"),
    "loopback": MessageLookupByLibrary.simpleMessage("루프백 잠금 해제 도구"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("UWP 루프백 예외에 사용됩니다"),
    "loose": MessageLookupByLibrary.simpleMessage("넓게"),
    "madeBy": MessageLookupByLibrary.simpleMessage("만든 이"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("소스 IP 일치"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET을 대상으로 하는 규칙이 이동하는 곳입니다. 기본값은 이 프로필의 마지막 MATCH 규칙 대상입니다.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("일치 대상"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("최대 실패 횟수"),
    "maxLengthTip": m37,
    "maximize": MessageLookupByLibrary.simpleMessage("최대화"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("메모리 정보"),
    "messageTest": MessageLookupByLibrary.simpleMessage("메시지 테스트"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("메시지입니다"),
    "metaInfo": MessageLookupByLibrary.simpleMessage("구독"),
    "min": MessageLookupByLibrary.simpleMessage("최소"),
    "minimize": MessageLookupByLibrary.simpleMessage("최소화"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("종료 시 최소화"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "종료 시 앱을 닫지 않고 최소화합니다",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("분"),
    "minutesAgo": m38,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("분"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("분"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("혼합 포트"),
    "mode": MessageLookupByLibrary.simpleMessage("모드"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("모노크롬"),
    "monthsAgo": m39,
    "more": MessageLookupByLibrary.simpleMessage("더 보기"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "여러 값을 쉼표로 구분하세요",
    ),
    "name": MessageLookupByLibrary.simpleMessage("이름"),
    "nameserver": MessageLookupByLibrary.simpleMessage("네임서버"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("도메인을 확인하는 데 사용됩니다"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("네임서버 정책"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "일치하는 도메인에 사용할 네임서버를 지정합니다",
    ),
    "network": MessageLookupByLibrary.simpleMessage("네트워크"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("네트워크 관련 설정을 조정합니다"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("네트워크 확인"),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID(집 와이파이) 또는 서브넷(192.168.1.0/24)",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "네트워크 오류입니다. 연결을 확인한 후 다시 시도하세요.",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("네트워크 속도"),
    "networkType": MessageLookupByLibrary.simpleMessage("네트워크 유형"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage("아직 신뢰하는 네트워크가 없습니다"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("뉴트럴"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("새로운 디자인"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "연결 링과 그 아래 트래픽 표시",
    ),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("새로운 스타일"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("다음 일치 항목"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("공지사항 없음"),
    "noData": MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("아직 단축키가 없습니다"),
    "noInfo": MessageLookupByLibrary.simpleMessage("정보 없음"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("다시 알리지 않기"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("네트워크 없음"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("네트워크 없는 앱"),
    "noRecords": MessageLookupByLibrary.simpleMessage("기록 없음"),
    "noResolve": MessageLookupByLibrary.simpleMessage("DNS 조회 안 함"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("호스트 이름 확인 안 함"),
    "none": MessageLookupByLibrary.simpleMessage("없음"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "이 프록시 그룹은 선택할 수 없습니다",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "현재 네트워크는 신뢰 목록에 없습니다",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "아직 프로필이 없습니다. 먼저 추가해 주세요.",
    ),
    "nullTip": m40,
    "numberTip": m41,
    "off": MessageLookupByLibrary.simpleMessage("꺼짐"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("아이콘만"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("프록시 트래픽만 집계"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "켜면 프록시 트래픽만 집계합니다",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("브라우저에서 열기"),
    "optional": MessageLookupByLibrary.simpleMessage("선택 사항"),
    "options": MessageLookupByLibrary.simpleMessage("옵션"),
    "other": MessageLookupByLibrary.simpleMessage("기타"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("기타 기여자"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("아웃바운드 모드"),
    "override": MessageLookupByLibrary.simpleMessage("재정의"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS 재정의"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "사용하면 프로필의 DNS 설정이 재정의됩니다",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("재정의 모드"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "네트워크 설정 재정의",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "구독 값 대신 앱의 포트, IPv6, allow-lan, find-process-mode 및 TUN 스택을 적용합니다",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage("재정의 스크립트"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 모드: 프록시 그룹과 규칙을 직접 구성합니다",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("페이지 애니메이션"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "페이지 전환에 애니메이션을 사용합니다",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("팔레트"),
    "password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "paste": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "pause": MessageLookupByLibrary.simpleMessage("일시정지"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("VPN 일시정지 중…"),
    "paused": MessageLookupByLibrary.simpleMessage("일시 중지됨"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage("무기한 구독"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("앨범에서 선택"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("네트워크 선택"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage("주변 와이파이 네트워크"),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage("주변에 와이파이가 없습니다"),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "주변 와이파이 네트워크를 표시하려면 위치 권한이 필요합니다",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("새로 고침"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "주변 와이파이를 찾는 중…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("창 고정"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAV를 연결해 주세요"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "스크립트 이름을 입력하세요",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "올바른 QR 코드를 업로드해 주세요",
    ),
    "port": MessageLookupByLibrary.simpleMessage("포트"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("다른 포트를 입력하세요"),
    "portTip": m42,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "DoH에 HTTP/3를 우선 사용합니다",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("필수 조건"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("키를 눌러 주세요"),
    "preview": MessageLookupByLibrary.simpleMessage("미리 보기"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("이전 일치 항목"),
    "process": MessageLookupByLibrary.simpleMessage("프로세스"),
    "profile": MessageLookupByLibrary.simpleMessage("프로필"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("올바른 간격을 입력하세요"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("자동 업데이트 간격을 입력하세요"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "프로필이 수정됐습니다. 자동 업데이트를 끄시겠습니까?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 이름을 입력하세요",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "올바른 프로필 URL을 입력하세요",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 URL을 입력하세요",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("프로필 정렬"),
    "project": MessageLookupByLibrary.simpleMessage("프로젝트"),
    "providerView": MessageLookupByLibrary.simpleMessage("제공자별 보기"),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "이 구독으로 프록시 페이지를 꾸밀 수 있습니다. 직접 바꾼 내용은 그대로 유지됩니다.",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("외부 리소스"),
    "proxies": MessageLookupByLibrary.simpleMessage("프록시"),
    "proxiesCount": m43,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("프록시가 비어 있습니다"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("프록시 체인"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "선택한 프록시가 올바르지 않습니다",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("프록시 필터"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "현재 프록시 그룹이 올바르지 않습니다",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("프록시 그룹이 비어 있습니다"),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹 이름이 중복됩니다",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹 이름은 비워 둘 수 없습니다",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("프록시 네임서버"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "프록시 노드 도메인을 확인하는 데 사용됩니다",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "선택한 프록시 공급자가 올바르지 않습니다",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("프록시 제공자"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "프록시 공급자가 비어 있습니다",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "프록시 공급자는 비워 둘 수 없습니다",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("프록시 유형"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("캐시 정리"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("퓨어 블랙 모드"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR 코드"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QR 코드를 스캔해 프로필을 추가합니다"),
    "quickFill": MessageLookupByLibrary.simpleMessage("빠른 입력"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("무지개"),
    "redirPort": MessageLookupByLibrary.simpleMessage("리다이렉트 포트"),
    "redo": MessageLookupByLibrary.simpleMessage("다시 실행"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("모션 줄이기"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage("장식용 애니메이션을 끕니다"),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage(
      "시스템 설정에서 이미 켜져 있습니다",
    ),
    "reload": MessageLookupByLibrary.simpleMessage("다시 불러오기"),
    "remaining": MessageLookupByLibrary.simpleMessage("남음"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("남은 트래픽"),
    "remote": MessageLookupByLibrary.simpleMessage("원격"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "데이터를 WebDAV에 백업합니다",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("원격 대상"),
    "remove": MessageLookupByLibrary.simpleMessage("삭제"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("구독 갱신"),
    "request": MessageLookupByLibrary.simpleMessage("요청"),
    "requests": MessageLookupByLibrary.simpleMessage("요청"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("최근 요청 기록을 확인합니다"),
    "reset": MessageLookupByLibrary.simpleMessage("재설정"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "이 페이지에 변경 사항이 있습니다. 되돌리시겠습니까?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("재설정하시겠습니까?"),
    "resources": MessageLookupByLibrary.simpleMessage("리소스"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("외부 리소스 정보"),
    "respectRules": MessageLookupByLibrary.simpleMessage("규칙 준수"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 요청이 규칙을 따르며, proxy-server-nameserver 설정이 필요합니다",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("다시 시작"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("코어를 다시 시작하시겠습니까?"),
    "restore": MessageLookupByLibrary.simpleMessage("복원"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("모든 데이터 복원"),
    "restoreException": MessageLookupByLibrary.simpleMessage("복원 오류"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "파일에서 데이터를 복원합니다",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV에서 데이터를 복원합니다",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("프로필만 복원"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("복원 전략"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("호환"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("재정의"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("복원이 완료됐습니다."),
    "resume": MessageLookupByLibrary.simpleMessage("재개"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("개발 및 관리"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("라우팅 주소"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "수신 대기할 라우팅 주소를 설정합니다",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("라우팅 모드"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage("사설 주소 우회"),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("설정 사용"),
    "ru": MessageLookupByLibrary.simpleMessage("러시아어"),
    "rule": MessageLookupByLibrary.simpleMessage("규칙"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "전체 도메인과 일치합니다",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 키워드와 일치합니다",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 정규식과 일치합니다",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 접미사와 일치합니다",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "와일드카드 일치이며 *와 ?만 지원합니다",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP 표시와 일치합니다(tproxy UDP 인바운드 전용)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "대상 포트 범위와 일치합니다",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "IP의 국가 코드와 일치합니다",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite에 포함된 도메인과 일치합니다",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 이름과 일치합니다",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 포트와 일치합니다",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 유형과 일치합니다",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 사용자 이름과 일치합니다. 사용자 이름이 여러 개인 경우 /로 구분하세요",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IP의 ASN과 일치합니다",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP 주소 범위와 일치합니다. IP-CIDR6은 별칭일 뿐입니다",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IP 주소 범위와 일치합니다",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IP 접미사 범위와 일치합니다",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "조건 없이 모든 요청과 일치합니다",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 또는 UDP와 일치합니다",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름으로 일치합니다. Android에서는 패키지 이름으로 일치합니다",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 정규식으로 일치합니다. Android에서는 패키지 이름으로 일치합니다",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 와일드카드로 일치합니다. *와 ?만 지원합니다",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 전체 경로로 일치합니다",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 정규식으로 일치합니다",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 와일드카드로 일치합니다. *와 ?만 지원합니다",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "재매치 이름과 일치합니다. 이름이 여러 개인 경우 /로 구분하세요",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "규칙 세트를 참조합니다. rule-providers가 필요합니다",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "소스 IP의 국가 코드와 일치합니다",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "소스 IP의 ASN과 일치합니다",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "소스 IP 주소 범위와 일치합니다",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "소스 IP 접미사 범위와 일치합니다",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "소스 포트 범위와 일치합니다",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "하위 규칙에서 일치합니다. 괄호 사용에 유의하세요",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux 사용자 ID로 일치합니다",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("규칙이 비어 있습니다"),
    "ruleName": MessageLookupByLibrary.simpleMessage("규칙 이름"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("규칙 세트"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("규칙 대상"),
    "rules": MessageLookupByLibrary.simpleMessage("규칙"),
    "rulesCount": m44,
    "save": MessageLookupByLibrary.simpleMessage("저장"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("변경 사항을 저장하시겠습니까?"),
    "schedule": MessageLookupByLibrary.simpleMessage("일정"),
    "scheduleDesc": m45,
    "script": MessageLookupByLibrary.simpleMessage("스크립트"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "스크립트 모드: 외부 확장 스크립트로 한 번에 구성을 재정의합니다",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("선택 항목으로 스크롤"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "searchApps": MessageLookupByLibrary.simpleMessage("앱 검색"),
    "seconds": MessageLookupByLibrary.simpleMessage("초"),
    "secondsCount": m46,
    "selectAll": MessageLookupByLibrary.simpleMessage("모두 선택"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET 선택",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage("프록시 선택"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage("프록시 공급자 선택"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("규칙 세트를 선택하세요"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략을 선택하세요"),
    "selectSubRule": MessageLookupByLibrary.simpleMessage("하위 규칙을 선택하세요"),
    "selected": MessageLookupByLibrary.simpleMessage("선택됨"),
    "selectedCountTitle": m47,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("HWID 전송"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "기기 식별자, 앱 버전, 기기 이름을 프로바이더 서버로 전송합니다",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("서비스"),
    "settings": MessageLookupByLibrary.simpleMessage("설정"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage("더 추가"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage("ReClash를 열 때 연결"),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "유효한 프로필을 불러온 뒤 VPN을 자동으로 시작합니다",
    ),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "자동 연결을 사용하려면 프로필을 추가하세요",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("뒤로"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "프로필 없이 계속",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN은 꺼진 상태로 유지됩니다. 나중에 프로필을 추가하거나 VPN 제공업체 없이 ByeDPI 전용 모드를 사용할 수 있습니다.",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "선택적 충돌 보고서 보내기",
    ),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "앱 충돌 원인을 찾는 데 도움이 됩니다. 직접 켜지 않으면 전송되지 않습니다.",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage("동의하지 않고 종료"),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("삭제"),
    "setupDone": MessageLookupByLibrary.simpleMessage("완료"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage("완료하고 연결"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("설정 검토"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "나중에 설정에서 변경할 수 있습니다",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("언어 선택"),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage("전체 면책 조항 읽기"),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage("오픈 소스 라이선스"),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash는 트래픽 경로를 지정하기 위해 기기에 로컬 VPN 연결을 만듭니다. 설정 또는 제공업체는 사용자가 직접 선택하며 사용에 대한 책임도 사용자에게 있습니다.",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage("계속하기 전에"),
    "setupNext": MessageLookupByLibrary.simpleMessage("다음"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage("배터리 최적화"),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드에서 VPN 연결을 유지하도록 허용합니다",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage("확인 중…"),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage(
      "처음 연결할 때 요청",
    ),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage("허용 안 됨"),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage("확인할 수 없음"),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage("허용됨"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage("알림"),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash 실행 중 연결 상태를 표시합니다",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
      "설정 열기",
    ),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage("허용"),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage(
      "사용할 수 없음",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage("VPN 권한"),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "처음 연결할 때 시스템이 요청합니다",
    ),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash는 VPN 서비스를 판매하지 않습니다. 신뢰하는 제공업체의 링크, QR 코드 또는 설정 파일을 사용하세요. 저장 전에 프로필을 검사합니다.",
    ),
    "setupProfilesReady": m48,
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "스마트 라우팅이 경로를 선택할 때 이 지역을 시작점으로 사용합니다. 언어는 추천에만 사용됩니다.",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage(
      "기타 지역 또는 스마트 라우팅 사용 안 함",
    ),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage("언어에 따른 추천"),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "현재 네트워크는 어느 지역에 있나요?",
    ),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("교체"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "새 프로필을 정상적으로 가져와 검사한 뒤 현재 프로필을 삭제합니다.",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage("초기 설정 다시 실행"),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "데이터를 지우지 않고 언어, 프로필, 라우팅, 권한을 검토합니다",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage("백업에서 복원"),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash, FlClashX 또는 FlClash 백업에서 설정과 프로필 복원",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("프로필 없이 계속"),
    "setupStepProgress": m49,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "프로필에는 연결에 필요한 서버와 규칙이 들어 있습니다. 제공업체나 백업에서 가져오세요.",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage("프로필 준비 완료"),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage("연결 프로필 추가"),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage("자동 연결: 꺼짐"),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage("자동 연결: 켜짐"),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "VPN 프로필 없음 — VPN은 꺼짐, ByeDPI 전용 모드는 사용 가능",
    ),
    "setupSummaryProfile": m50,
    "setupSummaryRouting": m51,
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage("설정 요약"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage("시스템 언어"),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "몇 가지 간단한 단계로 준비할 수 있습니다",
    ),
    "show": MessageLookupByLibrary.simpleMessage("표시"),
    "showLabels": MessageLookupByLibrary.simpleMessage("사이드바 레이블 표시"),
    "showLess": MessageLookupByLibrary.simpleMessage("접기"),
    "showMore": MessageLookupByLibrary.simpleMessage("펼치기"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "알림에 중지 버튼 표시",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "상시 알림에 중지 버튼을 표시합니다. 이 버튼 때문에 알림이 항상 펼쳐져 보인다면 끄세요.",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("비밀번호 표시"),
    "shrink": MessageLookupByLibrary.simpleMessage("컴팩트"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("백그라운드 시작"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("백그라운드에서 시작합니다"),
    "size": MessageLookupByLibrary.simpleMessage("크기"),
    "smartPause": MessageLookupByLibrary.simpleMessage("스마트 일시 중지"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage("연결 끊기"),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "신뢰할 수 있는 네트워크에 연결되면 VPN을 자동으로 일시 중지합니다",
    ),
    "smartRouting": MessageLookupByLibrary.simpleMessage("스마트 라우팅"),
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "일시 보류된 공급자",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "일시 보류된 확인",
    ),
    "smartRoutingAliveCount": m52,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage("모든 서버"),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage("가용성"),
    "smartRoutingAvailabilityValue": m53,
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "평균 복구 시간",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "자동 모드로 되돌리기",
    ),
    "smartRoutingBandLabel": m54,
    "smartRoutingBands": m55,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("동작"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "현재 서버 목록에 없음",
    ),
    "smartRoutingBlockCooling": m56,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서 점검에 실패함",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "로컬 서버라 이 네트워크에서는 제외됨",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage("UDP 미지원"),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "독립적인 장애가 여러 번 발생하여 공급자를 일시 보류함",
    ),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서는 아직 어떤 경로도 작동하지 않습니다",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage("화이트리스트 전용"),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "제한된 네트워크를 위해 남겨두므로 개방된 네트워크에서는 사용하지 않습니다",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "화이트리스트 전용 서버 이름",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "서버 이름에 포함되면 제한된 네트워크용 서버로 표시되는 단어입니다",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage("카나리아 주소"),
    "smartRoutingCanariesAnswered": m57,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "국내 카나리아",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "직접 연결해 화이트리스트 네트워크인지 아예 연결이 없는 상태인지 구분합니다",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "해외 카나리아",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "IP:포트로 직접 연결해 네트워크가 열려 있는지 차단 상태인지 구분합니다",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage("국내"),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage("해외"),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage("검열 국가"),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "이 국가의 서버는 국내로 간주되어 차단이 시작되기 전까지 보류됩니다",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage("선택된 서버"),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "아직 선택된 서버가 없습니다",
    ),
    "smartRoutingCoolFor": m58,
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage("모든 서버 점검"),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "탐색 횟수 제한을 무시하므로 트래픽이 더 들 수 있습니다",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "모든 서버를 점검하는 중…",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("속도 제한됨"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "앱을 열지 않고도 네트워크마다 작동하는 서버를 자동으로 골라 둡니다",
    ),
    "smartRoutingDetection": MessageLookupByLibrary.simpleMessage("탐지"),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage(
      "인터넷 차단 시 로컬 서버 사용",
    ),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "화이트리스트 네트워크에서는 최후 수단으로만 사용하며, 로컬 서비스를 계속 쓸 수 있게 합니다",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "로컬 서비스는 직접 연결됩니다",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "로컬 서비스는 선택된 서버를 거칩니다",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage("안정화 시간"),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "더 빠른 서버가 나타났을 때 작동 중인 서버를 얼마나 오래 유지할지 정합니다",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage("아직 측정 결과가 없습니다"),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage("네트워크별 기록 키"),
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "로컬 주소가 응답하지 않았습니다",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "로컬 주소가 응답했습니다",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "외부 주소가 응답하지 않았습니다",
    ),
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "게이트가 위조된 인증서로 응답했습니다",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "외부 주소가 인증서 검증을 통과했습니다",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "최근 점검으로 확인됨",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "실제 트래픽으로 확인됨",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage(
      "확인된 적 없음",
    ),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "시스템이 로그인 페이지를 감지했습니다",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "확인된 지 오래됨",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "시스템이 인터넷에 연결할 수 없다고 보고합니다",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "시스템이 인터넷 연결을 확인했습니다",
    ),
    "smartRoutingFails": m59,
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage("연결 없음"),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "로컬과 외부 모두 응답하지 않습니다",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage("완전 개방"),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "인터넷으로 가는 길이 막혀 있지 않습니다",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage("로그인 필요"),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "먼저 로그인해야 네트워크를 쓸 수 있습니다",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage("제한됨"),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "로컬 서비스만 응답하고 외부 서비스는 응답하지 않습니다",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage("측정 중"),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "아직 판단하기에 정보가 부족합니다",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage("차단됨"),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage("미확인"),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("사용 가능"),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage("최근 전환"),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "아직 전환이 없습니다",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage("지연 테스트 결과"),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage("감지된 장애"),
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "스마트 라우팅은 현재 네트워크에서 작동하는 서버를 골라 두고, 네트워크가 바뀌면 알아서 전환합니다. 지역 프리셋으로 시작한 다음 아래에서 전략, 검사, 마커를 세부 조정하세요.",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("유지됨"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("지연 시간 대역"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("증거"),
    "smartRoutingKeyHistory": MessageLookupByLibrary.simpleMessage(
      "현재 네트워크 기록",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "현재 네트워크 적합성",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("판정"),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage(
      "최근 복구 시간",
    ),
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage("수동 선택 우선"),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "직접 고른 서버는 연결이 끊길 때까지 그대로 둡니다",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "연결이 끊길 때까지 유지됨",
    ),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "격리된 서비스 확인",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "허용할 상태 코드",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "쉼표로 구분(예: 200, 204, 404)",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "HTTP 상태 코드를 쉼표로 구분하여 입력하세요",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage("서비스 확인"),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage(
      "국내 확인",
    ),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "차단 상태에서 국내 서버를 확인하는 데 사용합니다",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage(
      "아직 설정된 확인 항목이 없습니다",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "열린 인터넷 확인",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "서버가 이 상태 중 하나를 반환해야 검증된 서버로 간주됩니다",
    ),
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("종량제 네트워크"),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("네트워크"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서 아직 전환되지 않음",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("응답 없음"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage(
      "복구된 장애가 아직 없습니다",
    ),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "연결 가능한 서버 없음",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage("서버 점검"),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("UDP 없음"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m60,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage("범용"),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "스마트 라우팅을 켜면 서버를 알아서 선택합니다",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage("스마트 라우팅이 켜져 있습니다"),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage("라우팅 개요"),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage("와이파이 로그인 필요"),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("프리셋"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("중국"),
    "smartRoutingPresetEdited": m61,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("이란"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("꺼짐"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("러시아"),
    "smartRoutingProbeBudget": m62,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("탐색"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "공급자 보호 작동 횟수",
    ),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage("순위 기준"),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage("순위"),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "지연 시간 대역은 고정되어 있습니다. 조절 옵션을 두면 밀리초가 서버 작동 여부보다 우선순위가 됩니다",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서 처음 고른 서버입니다",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "이전 서버가 트래픽을 전달하지 못했습니다",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "전환 전 안정화 시간을 기다리는 중입니다",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "작동 중이며, 더 나은 서버를 찾지 못했습니다",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "이전 서버가 응답을 멈췄습니다",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "지연 시간이 한 단계 더 낮은 서버입니다",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "선택하신 서버를 그대로 유지하고 있습니다",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "전환 전에 후보 서버를 점검하는 중입니다",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "점검을 통과한 서버가 없습니다",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "선택하신 서버가 다시 정상 작동합니다",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "접근 가능한 서버가 없어 현재 서버를 유지합니다",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "네트워크가 바뀌었습니다",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "개방된 인터넷 연결이 확인된 서버입니다",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage("지금 점검"),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("지역"),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage("UDP 지원 필수"),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "통화와 게임 트래픽을 처리하지 못하는 서버는 건너뜁니다",
    ),
    "smartRoutingResetSection": MessageLookupByLibrary.simpleMessage(
      "프리셋으로 재설정",
    ),
    "smartRoutingResetSectionDesc": MessageLookupByLibrary.simpleMessage(
      "지역 기본값을 복원하고 스마트 라우팅은 켜 둡니다",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "제한된 네트워크 · 로컬 서비스는 직접 연결 유지",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "서버가 응답하지 않아 다른 서버를 찾고 있습니다",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "규칙 모드에서만 사용할 수 있습니다",
    ),
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage("서버를 찾는 중…"),
    "smartRoutingSeconds": m63,
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage("서버"),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage("전환 기록"),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("네트워크"),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "신뢰성",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("결정"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("서버"),
    "smartRoutingServersCount": m64,
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "웜 스탠바이로 복구",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage("허용 대상 결정"),
    "smartRoutingStepAdmitBody": m65,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage("최종 선택"),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage("네트워크 파악"),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage("남은 서버 순위 결정"),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "판정, 적합성, 증거, 지연 시간 대역, 기록 순으로 평가합니다",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("전략"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage("균형"),
    "smartRoutingStrategyDesc": MessageLookupByLibrary.simpleMessage(
      "엔진이 지연 시간과 안정성 중 무엇을 우선할지 정합니다",
    ),
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "최저 지연 시간",
    ),
    "smartRoutingSwitchLine": m66,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("전환됨"),
    "smartRoutingSwitchedAgo": m67,
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage("기술 세부 사항"),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage("미점검"),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "최후 수단",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "개방된 인터넷 접근 가능",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage("사용 불가"),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage("사용 가능"),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage("한 번에 점검할 서버 수"),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드 점검 한 번에 측정하는 서버 수입니다",
    ),
    "smartRoutingWaveNodes": m68,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage("링크 점검"),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("이유"),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS 포트"),
    "sort": MessageLookupByLibrary.simpleMessage("정렬"),
    "source": MessageLookupByLibrary.simpleMessage("소스"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("소스 코드"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("소스 IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("특수 프록시"),
    "specialRules": MessageLookupByLibrary.simpleMessage("특수 규칙"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("속도 통계"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "분할 전략은 비워 둘 수 없습니다",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("스택 모드"),
    "standard": MessageLookupByLibrary.simpleMessage("표준"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "표준 모드: 기본 구성을 재정의하고 간단한 규칙을 추가할 수 있습니다",
    ),
    "start": MessageLookupByLibrary.simpleMessage("시작"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN 시작 중…"),
    "status": MessageLookupByLibrary.simpleMessage("상태"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("끄면 시스템 DNS를 사용합니다"),
    "stop": MessageLookupByLibrary.simpleMessage("중지"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN 중지 중…"),
    "style": MessageLookupByLibrary.simpleMessage("스타일"),
    "subRule": MessageLookupByLibrary.simpleMessage("하위 규칙"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("하위 규칙이 비어 있습니다"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "하위 규칙은 비워 둘 수 없습니다",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("확인"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("구독"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("자동"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "구독을 요청할 때 이 클라이언트 형식을 사용합니다",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage("클라이언트 형식"),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionDomainMoved": m69,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("구독이 만료됐습니다"),
    "subscriptionExpiresInDays": m70,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "구독이 오늘 만료됩니다",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("구독 정보"),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "이 구독에는 트래픽 한도나 만료일 정보가 없습니다",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage("구독 알림"),
    "subscriptionProviderInterval": m71,
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "이 구독에는 연결할 수 있는 노드가 없습니다. 다른 클라이언트 형식을 시도해 보세요.",
    ),
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("업데이트됨"),
    "support": MessageLookupByLibrary.simpleMessage("지원"),
    "sync": MessageLookupByLibrary.simpleMessage("동기화"),
    "system": MessageLookupByLibrary.simpleMessage("시스템"),
    "systemApp": MessageLookupByLibrary.simpleMessage("시스템 앱"),
    "systemColor": MessageLookupByLibrary.simpleMessage("시스템 색상 사용"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "운영체제의 강조 색상을 가져옵니다(Material You)",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("시스템 프록시를 설정합니다"),
    "systemSeed": MessageLookupByLibrary.simpleMessage("시스템 시드"),
    "tab": MessageLookupByLibrary.simpleMessage("탭"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("탭 애니메이션"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage("모바일 화면에서만 적용됩니다"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("탭해서 승인"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 동시 연결"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "동시 TCP 연결을 허용합니다",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("테스트 간격"),
    "testUrl": MessageLookupByLibrary.simpleMessage("테스트 URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("사용 시 테스트"),
    "textScale": MessageLookupByLibrary.simpleMessage("텍스트 배율"),
    "theme": MessageLookupByLibrary.simpleMessage("테마"),
    "themeColor": MessageLookupByLibrary.simpleMessage("테마 색상"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("다크 모드와 색상을 설정합니다"),
    "themeMode": MessageLookupByLibrary.simpleMessage("테마 모드"),
    "tight": MessageLookupByLibrary.simpleMessage("좁게"),
    "time": MessageLookupByLibrary.simpleMessage("시간"),
    "timeout": MessageLookupByLibrary.simpleMessage("시간 제한"),
    "tip": MessageLookupByLibrary.simpleMessage("팁"),
    "tk": MessageLookupByLibrary.simpleMessage("튀르크멘어"),
    "toggle": MessageLookupByLibrary.simpleMessage("토글"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("레이블 전환"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("톤 스팟"),
    "tools": MessageLookupByLibrary.simpleMessage("도구"),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("트래픽 충전"),
    "torch": MessageLookupByLibrary.simpleMessage("손전등"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("전체 트래픽"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy 포트"),
    "trafficFreeOfTotal": m72,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("트래픽 사용량"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("신뢰할 수 있는 네트워크"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 등록한 네트워크에 연결되어 있으면 VPN이 일시 중지됩니다",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "신뢰하는 네트워크 · VPN 일시 중지됨",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("관리자 모드에서만 작동합니다"),
    "turnOff": MessageLookupByLibrary.simpleMessage("끄기"),
    "turnOn": MessageLookupByLibrary.simpleMessage("켜기"),
    "undo": MessageLookupByLibrary.simpleMessage("실행 취소"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("통합 지연"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "핸드셰이크 같은 추가 지연을 제거합니다",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "알 수 없는 네트워크 오류",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("이전 크기로 복원"),
    "unnamed": MessageLookupByLibrary.simpleMessage("이름 없음"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("창 고정 해제"),
    "update": MessageLookupByLibrary.simpleMessage("업데이트"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "업데이트를 다운로드할 수 없습니다.",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "다운로드한 파일이 손상됐습니다.",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("업로드"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URL로 프로필을 추가합니다"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL 스킴"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("구독 추가"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "구독 URL을 확인한 후 추가합니다",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("닫기"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "트레이로 숨기거나 설정에 따라 종료합니다",
    ),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage("자동화 명령"),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Tasker, 스크립트, 바로가기, 자동화에 사용합니다",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("연결"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "터널을 시작하고 연결합니다",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("연결 해제"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "터널을 중지합니다",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("설정 가져오기"),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "base64로 인코딩된 설정 파일을 프로필로 가져옵니다",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "가져온 데이터가 올바른 base64 형식이 아닙니다.",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage("프로필 설치"),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash와 FlClash 버튼이 이미 사용하는 호환 링크입니다",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("열기"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage("창을 맨 앞으로 가져옵니다"),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("전환"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "중지 상태면 연결하고, 실행 중이면 연결을 해제합니다",
    ),
    "urlTip": m73,
    "useHosts": MessageLookupByLibrary.simpleMessage("호스트 사용"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("시스템 호스트 사용"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("사용 트래픽"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "uz": MessageLookupByLibrary.simpleMessage("우즈베크어"),
    "value": MessageLookupByLibrary.simpleMessage("값"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("선명함"),
    "view": MessageLookupByLibrary.simpleMessage("보기"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN 관련 구성이 변경되었습니다",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "시스템의 모든 트래픽을 VpnService를 통해 자동으로 라우팅합니다",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("변경 사항은 VPN을 다시 시작해야 적용됩니다"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV 설정"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("웹 대시보드"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "코어에서 직접 제공하는 zashboard입니다",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "zashboard는 처음 열 때 다운로드됩니다",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("대시보드 열기"),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "대시보드가 열려 있는 동안 외부 컨트롤러가 켜져 있습니다",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "코어가 아직 대시보드를 제공하고 있지 않습니다",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("화이트리스트 모드"),
    "yearsAgo": m74,
    "zhCN": MessageLookupByLibrary.simpleMessage("중국어(간체)"),
  };
}
