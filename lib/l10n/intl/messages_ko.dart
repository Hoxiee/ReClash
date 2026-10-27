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

  static String m0(count) => "${count}개 선택됨";

  static String m1(count) =>
      "제공자가 VPN에서 제외한 앱: ${count}개. 목록을 바꾸려면 접근 제어를 켜세요.";

  static String m2(name) => "${name}을(를) 로컬 프록시에 추가했습니다";

  static String m3(name) => "${name}은(는) 이미 로컬 프록시에 있습니다";

  static String m4(count, skipped) => "추가 ${count}개, 이미 있어서 건너뜀 ${skipped}개";

  static String m5(detail) => "데이터를 지우지 못했습니다: ${detail}";

  static String m6(code) =>
      "Windows에서 ReClashCore.exe 실행을 거부했습니다(오류 ${code}). Smart App Control이나 AppLocker와 같은 앱 제어 정책이 서명되지 않은 프로그램을 차단합니다. 해당 정책에서 ReClash를 허용하거나 정책을 끈 후 다시 시도하세요.";

  static String m7(name) =>
      "앱이 두 번 연속 시작을 완료하지 못했습니다. 반복을 끊기 위해 프로필 ${name}의 선택을 해제하고 자동 설정을 건너뛰었습니다. 언제든지 다시 선택할 수 있습니다.";

  static String m8(url) => "${url}에서 프로필을 만드시겠습니까?";

  static String m9(groups) =>
      "프록시 그룹 ${groups}에서 include-all을 제거했습니다. 해당 그룹이 사용하는 프록시나 프록시 공급자를 추가하세요";

  static String m10(count, label) =>
      "${Intl.plural(count, other: '사용자 지정 프로필은 하위 규칙을 지원하지 않아 SUB-RULE 규칙 ${label}개를 제외했습니다')}";

  static String m11(message) => "코어가 이 프록시를 해석할 수 없습니다: ${message}";

  static String m12(proxy, target) =>
      "${proxy}이(가) ${target}을(를) 거쳐 다시 ${proxy}(으)로 돌아오므로 다이얼이 순환합니다";

  static String m13(name) => "다른 프록시 또는 프록시 그룹이 이미 사용 중인 이름입니다: ${name}";

  static String m14(path) => "프록시 그룹이 서로를 순환 참조합니다: ${path}";

  static String m15(name) => "빈 폴백은 프록시여야 하지만 존재하지 않거나 프록시 그룹입니다: ${name}";

  static String m16(name, message) => "올바른 정규식이 아닙니다(${name}): ${message}";

  static String m17(name) => "존재하지 않는 다이얼러 프록시: ${name}";

  static String m18(names) => "존재하지 않는 프록시 공급자: ${names}";

  static String m19(names) => "존재하지 않는 프록시 또는 정책: ${names}";

  static String m20(name) => "내장 정책 이름이라 여기에서 사용할 수 없습니다: ${name}";

  static String m21(count) => "문제가 있는 항목 ${count}개, 이 프로필을 적용하면 실패할 수 있습니다";

  static String m22(count) => "${Intl.plural(count, other: '${count}일 전')}";

  static String m23(count) => "${Intl.plural(count, other: '${count}일 전')}";

  static String m24(label) => "선택한 ${label}을(를) 삭제하시겠습니까?";

  static String m25(label) => "이 ${label}을(를) 삭제하시겠습니까?";

  static String m26(label) => "${label} 상세 정보";

  static String m27(name) =>
      "${name}을(를) 거치는 다이얼이 이를 사용하는 프록시로 되돌아와 연결을 중단했습니다";

  static String m28(label) => "${label}을(를) 입력하세요";

  static String m29(label) => "${label}이(가) 이미 있습니다";

  static String m30(count) => "${count}개 항목 실패";

  static String m31(label, message) => "${label}: ${message}";

  static String m32(name) => "${name}: 이미 최신 상태입니다";

  static String m33(name) => "${name}: 업데이트됨";

  static String m34(count) => "${Intl.plural(count, other: '그룹 ${count}개')}";

  static String m35(count) => "${count}개 시간 초과";

  static String m36(action) => "이미 “${action}”에서 사용 중입니다. 저장하면 이쪽으로 옮겨집니다.";

  static String m37(actions) => "내보내지 않은 동작: ${actions}";

  static String m38(modifiers) => "${modifiers} 중 하나 이상을 포함하세요";

  static String m39(count) => "${Intl.plural(count, other: '${count}시간 전')}";

  static String m40(count) => "${Intl.plural(count, other: '${count}시간 전')}";

  static String m41(target) => "올바르지 않은 정책: ${target}";

  static String m42(proxyName) => "올바르지 않은 프록시: ${proxyName}";

  static String m43(providerName) => "올바르지 않은 프록시 공급자: ${providerName}";

  static String m44(ruleSet) => "올바르지 않은 규칙 세트: ${ruleSet}";

  static String m45(subRule) => "올바르지 않은 SUB_RULE: ${subRule}";

  static String m46(count) => "${Intl.plural(count, other: '항목 ${count}개')}";

  static String m47(line, message) => "${line}행: ${message}";

  static String m48(appName) =>
      "1. 시스템 설정 > 개인정보 보호 및 보안을 엽니다\n2. 위치 서비스를 선택합니다\n3. 목록에서 ${appName}을(를) 찾아 체크합니다\n\n완료되면 앱으로 돌아와 계속하세요. 협조해 주셔서 감사합니다.";

  static String m49(label, max) => "${label}은(는) 최대 ${max}자까지 입력할 수 있습니다";

  static String m50(size) => "${size} 해제됨";

  static String m51(count) => "${Intl.plural(count, other: '${count}분 전')}";

  static String m52(count) => "${Intl.plural(count, other: '${count}분 전')}";

  static String m53(count) => "${Intl.plural(count, other: '${count}개월 전')}";

  static String m54(count) => "${Intl.plural(count, other: '${count}개월 전')}";

  static String m55(code) =>
      "서버가 접근을 거부했습니다(HTTP ${code}). 링크가 만료되었거나 자격 증명이 잘못되었을 수 있습니다";

  static String m56(code) => "서버가 요청을 거부했습니다(HTTP ${code})";

  static String m57(code) =>
      "이 주소에서 아무것도 찾지 못했습니다(HTTP ${code}). URL이 올바른지 확인하세요";

  static String m58(detail) => "네트워크 요청 실패: ${detail}";

  static String m59(code) => "서버에 문제가 발생했습니다(HTTP ${code}). 나중에 다시 시도하세요";

  static String m60(label) => "${label}이(가) 아직 없습니다";

  static String m61(label, min, max) => "${label}은(는) ${min}에서 ${max} 사이여야 합니다";

  static String m62(label) => "${label}은(는) 숫자여야 합니다";

  static String m63(label) => "${label}은(는) 1024에서 49151 사이여야 합니다";

  static String m64(port) => "포트 ${port}";

  static String m65(added, skipped, failed) =>
      "추가: ${added}, 건너뜀: ${skipped}, 실패: ${failed}.";

  static String m66(days) => "${Intl.plural(days, other: '${days}일 남음')}";

  static String m67(date, days) =>
      "${date} 만료, ${Intl.plural(days, other: '${days}일')} 남음";

  static String m68(name) => "이미 “${name}”(으)로 추가됨";

  static String m69(client) => "${client} 앱이 받는 형식 그대로";

  static String m70(count) => "${Intl.plural(count, other: '서버 ${count}개')}";

  static String m71(time) => "${time} 업데이트";

  static String m72(name) => "${name}: 구독이 활성화되었습니다";

  static String m73(count) => "${count}일 남음";

  static String m74(count) => "${count}시간 남음";

  static String m75(label, profiles) =>
      "${label}은(는) 아직 ${profiles}에서 사용 중이며, 삭제하면 해당 프로필이 제대로 작동하지 않습니다. 삭제하시겠습니까?";

  static String m76(count, label) =>
      "${Intl.plural(count, other: '프록시 ${label}개')}";

  static String m77(name, count) => "${name} 외 (프록시 ${count}개)";

  static String m78(removed) =>
      "다음 프록시가 삭제됩니다: ${removed}. 이름이 바뀐 줄은 새 프록시로 간주되며, 삭제된 프록시를 지정한 사용자 지정 프로필에는 누락으로 표시됩니다. 그래도 적용하시겠습니까?";

  static String m79(removed, added) =>
      "다음 프록시가 삭제됩니다: ${removed}. 다음 프록시가 추가됩니다: ${added}. 이름이 바뀐 줄은 새 프록시로 간주되며, 삭제된 프록시를 지정한 사용자 지정 프로필에는 누락으로 표시됩니다. 그래도 적용하시겠습니까?";

  static String m80(label) =>
      "${label}은(는) 이 프로필의 규칙, 프록시 그룹, 다이얼러 프록시, DNS 또는 NTP에서 아직 참조 중이며, 삭제하면 작동하지 않게 됩니다. 삭제하시겠습니까?";

  static String m81(count, label) =>
      "${Intl.plural(count, other: '프록시 그룹 ${label}개')}";

  static String m82(pick, now) => "${now} 대신 ${pick}을(를) 선택합니다";

  static String m83(group) => "${group} 확인";

  static String m84(pick) => "${pick}을(를) 유지합니다";

  static String m85(number) => "조건 ${number}";

  static String m86(profile) => "“${profile}”이(가) 이 사이트들을 확인하려 합니다";

  static String m87(count) => "${Intl.plural(count, other: '서버 ${count}개')}";

  static String m88(profile) => "“${profile}”을(를) 삭제할까요?";

  static String m89(requests, used, cap) =>
      "오늘 확인: ${requests} · ${cap} 중 ${used}";

  static String m90(condition) => "${condition} 제외";

  static String m91(country) => "출구 ${country}";

  static String m92(member) => "${member} 경유";

  static String m93(title) =>
      "“${title}”은(는) 변경할 수 없습니다. 수정 내용은 사본에 저장되고, 사본이 실행 중인 시나리오가 됩니다.";

  static String m94(mode) => "경로는 규칙 모드에서 적용됩니다. 현재 연결은 ${mode} 모드입니다.";

  static String m95(profile) => "“${profile}”을(를) 추가했습니다";

  static String m96(node) => "${node}이(가) 작동을 멈췄습니다";

  static String m97(from, to) => "모드 ${from} → ${to}";

  static String m98(count) =>
      "${Intl.plural(count, other: '현재 서버 ${count}개 해당')}";

  static String m99(ms) => "${ms}ms 미만";

  static String m100(text) => "이름에 ${text}";

  static String m101(what) => "${what} 제외";

  static String m102(provider) => "${provider} 제공";

  static String m103(number) => "${number}단계";

  static String m104(action) => "어느 단계에도 작동하는 서버가 없으면: ${action}";

  static String m105(tag) => "태그 ${tag}";

  static String m106(line, text) => "${line}행: ${text}";

  static String m107(check) => "확인 ${check}은(는) 사용되지 않아 실행되지 않습니다";

  static String m108(hosts) => "서드파티 사이트에 접속함: ${hosts}";

  static String m109(group) => "이 구성에는 ${group} 그룹이 없습니다";

  static String m110(group) => "${group}의 서버 중 필터를 통과하는 것이 없습니다";

  static String m111(tag) => "태그 ${tag}은(는) 사용되지 않습니다";

  static String m112(tier, group) =>
      "현재 ${group}의 서버 중 “${tier}”에 해당하는 것이 없습니다";

  static String m113(tier, after) =>
      "“${tier}”은(는) “${after}”와 조건이 같아 아무것도 들어가지 않습니다";

  static String m114(name, count) => "${name} 외 ${count}개";

  static String m115(keys) => "가져왔습니다. 다음 항목은 직접 수정했으므로 내 값을 유지했습니다: ${keys}";

  static String m116(mode) => "모드: ${mode}";

  static String m117(node) => "${node}에 머뭅니다. 장애가 날 때만 벗어나고 복구되면 돌아옵니다.";

  static String m118(kind) => "네트워크: ${kind}";

  static String m119(tier) => "확인 후 \'${tier}\'에 들 수 있음";

  static String m120(node) => "고정됨: ${node}";

  static String m121(error) => "프로필 오류: ${error}";

  static String m122(profile) => "${profile} 프로필을 찾을 수 없어 기본값을 사용합니다";

  static String m123(error) => "라우팅 상태를 저장할 수 없습니다: ${error}";

  static String m124(tier) => "“${tier}” 서버로 이동";

  static String m125(from) => "서버를 변경했습니다. ${from}은(는) 15분간 제외됩니다";

  static String m126(from) => "${from}이(가) 작동을 멈춰 최적의 예비 서버로 전환";

  static String m127(from, gain) => "${from}에서 전환: ${gain}ms 더 빠름";

  static String m128(node) => "시나리오가 ${node}을(를) 유지 중";

  static String m129(node) => "${node}이(가) 이 그룹에 없습니다";

  static String m130(limit) => "전환 한도 도달 (시간당 ${limit}회)";

  static String m131(mode) => "사용 안 함: ${mode} 모드";

  static String m132(from) => "${from}은(는) 더 이상 후보가 아닙니다";

  static String m133(kind) => "네트워크가 \'${kind}\'인 동안 일시 중지: 확인도 전환도 하지 않습니다";

  static String m134(route, error) =>
      "경로 \'${route}\'을(를) 적용하지 못했습니다: ${error}";

  static String m135(route) =>
      "경로 \'${route}\'을(를) 건너뛰었습니다. 같은 이름의 그룹이 이미 있습니다.";

  static String m136(route, to) =>
      "경로 \'${route}\'이(가) 트래픽을 보내는 \'${to}\'이(가) 프로필에 없습니다.";

  static String m137(node) => "시나리오가 ${node}(으)로 전환합니다";

  static String m138(node) => "고정된 서버 ${node}(으)로 전환";

  static String m139(node) => "작동하는 서버가 없어 ${node}(으)로 대체";

  static String m140(scenario) =>
      "시나리오 \'${scenario}\'의 경로가 이 그룹을 만들었습니다. 수정이나 삭제는 그곳에서 하세요.";

  static String m141(scenario) => "현재 이 그룹은 시나리오 \'${scenario}\'이(가) 제어합니다.";

  static String m142(count, total) => "${total}개 중 ${count}개 일치";

  static String m143(node) => "확인되면 ${node}(으)로 전환합니다";

  static String m144(node, gain) => "${gain}ms 더 빠른 상태가 유지되면 ${node}(으)로 전환합니다";

  static String m145(node, minutes) => "${minutes}분 후 ${node}(으)로 전환할 수 있습니다";

  static String m146(name) => "확인 ${name}";

  static String m147(name) => "네트워크 진단 ${name}";

  static String m148(count) =>
      "${Intl.plural(count, other: '서버 ${count}개 비교')}";

  static String m149(count) =>
      "${Intl.plural(count, other: '이 그룹의 서버 ${count}개 중에서 고릅니다.')}";

  static String m150(region, bypassed, proxied) =>
      "${region}의 현지 앱으로 인식된 앱은 VPN을 우회하고(${bypassed}개), 나머지 설치된 앱은 VPN을 사용합니다(${proxied}개).\n\n두 목록에서 직접 선택한 항목이 교체되며 모드는 바뀌지 않습니다. 저장하기 전에 결과를 확인하세요.";

  static String m151(seconds) => "${seconds}초 후 확인할 수 있습니다";

  static String m152(count, label) =>
      "${Intl.plural(count, other: '규칙 ${label}개')}";

  static String m153(appName) => "${appName} (안전 모드)";

  static String m154(count) => "${Intl.plural(count, other: '${count}초')}";

  static String m155(count) => "${count}개 적용 중";

  static String m156(count) => "${Intl.plural(count, other: '문제 ${count}건')}";

  static String m157(count) => "${Intl.plural(count, other: '설정 ${count}개')}";

  static String m158(count) => "VPN을 우회하는 앱: ${count}";

  static String m159(count) => "사용 가능한 프로필 ${count}개";

  static String m160(step, total) => "${total}개 중 ${step}단계";

  static String m161(server) => "${server} 사용해 보기";

  static String m162(link) => "읽을 수 있는 프록시가 없습니다: ${link}";

  static String m163(count) => "${Intl.plural(count, other: '${count}일')}";

  static String m164(delay) => "${delay} ms";

  static String m165(service) => "${service}은(는) 이 주소를 차단합니다";

  static String m166(service) => "${service}은(는) 아직 여기서 이용할 수 없습니다";

  static String m167(service) => "${service}은(는) 여기서 자체 작품만 보여 줍니다";

  static String m168(service) => "${service}은(는) 일부 제한이 있습니다";

  static String m169(service) => "${service}이(가) 열리지 않습니다";

  static String m170(service) => "${service}은(는) 이 나라에서 작동하지 않습니다";

  static String m171(size) => "탭할 때만 VPN 없이 약 ${size} 데이터를 내려받습니다.";

  static String m172(size) => "탭할 때만 VPN으로 약 ${size} 데이터를 내려받습니다.";

  static String m173(network) => "신뢰하는 네트워크 “${network}”";

  static String m174(total) => "${total} 중 남음";

  static String m175(date) => "${date}까지";

  static String m176(label) => "${label}은(는) 하나만 입력해야 합니다";

  static String m177(used, limit) => "${used} / ${limit}";

  static String m178(value) => "${value} ms";

  static String m179(size) =>
      "최대 ${size}의 테스트 데이터를 전송하며 인터넷 및 VPN 한도를 사용합니다. 네트워크 부가 데이터로 실제 사용량이 늘 수 있습니다.";

  static String m180(client, format, count) =>
      "${client}로 수신: ${format}, 프록시 노드 ${count}개.";

  static String m181(count) =>
      "${Intl.plural(count, one: '구독이 내일 만료됩니다', other: '구독이 ${count}일 후에 만료됩니다')}";

  static String m182(count) => "서버 ${count}개 추가";

  static String m183(count) => "서버 ${count}개가 모두 추가됩니다";

  static String m184(count, total) => "서버 ${total}개 중 ${count}개가 추가됩니다";

  static String m185(count) => "모두 보기 (${count})";

  static String m186(format) => "형식: ${format}";

  static String m187(percent) => "트래픽의 ${percent}%를 사용했습니다";

  static String m188(count) => "결과 ${count}개";

  static String m189(value) => "최고 ${value}";

  static String m190(value) => "합계 ${value}";

  static String m191(transport) => "${transport} 요청 헤더";

  static String m192(version) => "설치된 버전: ${version}";

  static String m193(count) => "${count}분";

  static String m194(time) => "${time} 남음";

  static String m195(count) => "${count}초";

  static String m196(speed) => "${speed}/초";

  static String m197(nodes, groups, providers) =>
      "프록시 ${nodes}개, 그룹 ${groups}개, 원격 공급자 ${providers}개";

  static String m198(action) =>
      "이 링크가 “${action}” 동작을 요청합니다. ReClash에서 실행하도록 허용할까요?";

  static String m199(name, source) =>
      "${source}에서 “${name}”을 가져올까요? 확인 후 프로필 검증과 변환 검토가 진행됩니다.";

  static String m200(label) => "${label}은(는) URL이어야 합니다";

  static String m201(index) => "배경 ${index}";

  static String m202(count) =>
      "배경은 최대 ${count}개까지 저장할 수 있습니다. 추가하려면 하나를 삭제하세요.";

  static String m203(count) => "${Intl.plural(count, other: '${count}년 전')}";

  static String m204(count) => "${Intl.plural(count, other: '${count}년 전')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("정보"),
    "accessControl": MessageLookupByLibrary.simpleMessage("접근 제어"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱만 VPN을 거칩니다",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "접근 제어는 프록시를 사용할 앱을 선택합니다.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "앱 접근 제어가 꺼져 있습니다",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱은 VPN에서 제외됩니다",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("접근 제어 설정"),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "앱을 제공자 설정으로 되돌리기",
    ),
    "account": MessageLookupByLibrary.simpleMessage("계정"),
    "action": MessageLookupByLibrary.simpleMessage("동작"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("모든 지연 테스트"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("직접 모드"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("전역 모드"),
    "actionMode": MessageLookupByLibrary.simpleMessage("모드 전환"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("규칙 모드"),
    "actionStart": MessageLookupByLibrary.simpleMessage("시작/중지"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("프로필 업데이트"),
    "actionView": MessageLookupByLibrary.simpleMessage("표시/숨기기"),
    "add": MessageLookupByLibrary.simpleMessage("추가"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("프록시 추가"),
    "addFilters": MessageLookupByLibrary.simpleMessage("필터 추가"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("네트워크 추가"),
    "addNodes": MessageLookupByLibrary.simpleMessage("노드 추가"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("덮어쓰기 항목 추가"),
    "addProfile": MessageLookupByLibrary.simpleMessage("프로필 추가"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 추가"),
    "addRule": MessageLookupByLibrary.simpleMessage("규칙 추가"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("설정 추가"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSID 추가"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage("로컬 프록시에 추가"),
    "addedRules": MessageLookupByLibrary.simpleMessage("추가한 규칙"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage("추가 매개변수"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("이름 접두사"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("이름 접미사"),
    "address": MessageLookupByLibrary.simpleMessage("주소"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV 서버 주소"),
    "addressTip": MessageLookupByLibrary.simpleMessage("올바른 WebDAV 주소를 입력하세요"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("고급 구성"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "고급 구성에는 네트워크, DNS, 추가한 규칙, 스크립트가 포함됩니다.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("암호화된 프로필"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 비밀 키"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "이 프로필은 age로 암호화되어 있어 복호화하려면 age 비밀 키가 필요합니다",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("동의"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage("참조된 모든 프록시"),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "참조된 모든 프록시 공급자",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage("앱의 VPN 우회 허용"),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN 허용"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("허용 IP"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("응답"),
    "app": MessageLookupByLibrary.simpleMessage("앱"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("앱 접근 제어"),
    "appIcon": MessageLookupByLibrary.simpleMessage("앱 아이콘"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("이 아이콘 사용"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("청사진"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "홈 화면에 새 아이콘이 나타나기까지 몇 초가 걸릴 수 있습니다. 일부 런처는 바로가기를 삭제하므로 앱 목록에서 다시 추가하세요.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("회로"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("앱 아이콘 디자인"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("에코"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("잉크"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("파편"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("태양"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("스파크"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("표준"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("지층"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("지형"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("흔적"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("벨벳"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("로컬 프록시 없음"),
    "appRegion": MessageLookupByLibrary.simpleMessage("앱 지역"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("배경"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("인터페이스"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("테마"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 추가"),
    "applicationSettings": MessageLookupByLibrary.simpleMessage("앱 설정"),
    "applied": MessageLookupByLibrary.simpleMessage("적용했습니다"),
    "applyNow": MessageLookupByLibrary.simpleMessage("지금 적용"),
    "authentication": MessageLookupByLibrary.simpleMessage("인증"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "인증을 켜면 로컬 프록시 포트에서 사용자 이름과 비밀번호를 요구합니다.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "인증이 켜져 있는 동안에는 시스템 프록시가 적용되지 않습니다.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("허용"),
    "authorized": MessageLookupByLibrary.simpleMessage("허용됨"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("업데이트 자동 확인"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("연결 자동 종료"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "연결 자동 종료는 프록시를 전환할 때 열려 있는 연결을 끊습니다.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("자동 포함"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("자동 실행"),
    "autoRun": MessageLookupByLibrary.simpleMessage("자동 시작"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "자동 시작은 앱을 열 때 프록시를 시작합니다.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 자동 설정"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("자동 업데이트 간격"),
    "back": MessageLookupByLibrary.simpleMessage("뒤로"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("배경 흐림"),
    "backup": MessageLookupByLibrary.simpleMessage("백업"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("백업 및 복원"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "이 백업은 더 최신 버전의 앱에서 만들어졌습니다. 복원하기 전에 앱을 업데이트하세요",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("백업 완료"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("기본 정보"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("기본 전략"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("일괄 추가"),
    "batchImport": MessageLookupByLibrary.simpleMessage("일괄 가져오기"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage("한 줄에 링크 하나씩"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나씩 또는 쉼표로 구분하여 입력하세요",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나씩, 키, 공백, 값 순서로 입력하세요",
    ),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage("한 줄에 URL 하나씩"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "배터리 최적화를 무시하면 앱이 백그라운드에서 계속 실행됩니다.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("연결"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("블랙리스트 모드"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("연결 차단"),
    "brightness": MessageLookupByLibrary.simpleMessage("밝기"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("우회 도메인"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "우회 도메인은 시스템 프록시가 켜져 있을 때만 적용됩니다.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage("사설 주소 우회"),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "사설 주소 우회를 켜면 LAN, 루프백, 멀티캐스트 주소는 TUN을 거치지 않습니다.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("캐시"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("캐시 알고리즘"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "캐시가 손상되었습니다. 지우시겠습니까?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("캐시 크기"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QR 코드를 스캔하려면 시스템 설정에서 카메라 접근을 허용하거나, 앨범에서 QR 코드 이미지를 선택하세요.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "카메라 권한 필요",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("카메라를 사용할 수 없음"),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("모두 선택 해제"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("저장할 수 없음"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "프록시를 전환하지 못해 이전 선택을 복원했습니다",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("호환성 변경"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("새로운 기능"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("버그 수정"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("성능"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("되돌림"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS 인증서 검증"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS 검증을 끄면 구독과 백업이 중간자 공격에 노출됩니다.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("이미 최신 버전입니다"),
    "cipher": MessageLookupByLibrary.simpleMessage("암호화 방식"),
    "clearData": MessageLookupByLibrary.simpleMessage("데이터 지우기"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "모든 프로필, 설정, 로컬 데이터를 삭제한 후 앱을 종료합니다. 앱을 다시 열면 처음부터 시작합니다.",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("DNS 캐시 지우기"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "DNS 캐시를 지우지 못했습니다",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("검색 지우기"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage("클라이언트 핑거프린트"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("클립보드로 내보내기"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("클립보드에서 가져오기"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "클립보드에 복사하지 못했습니다. 선택 영역이 너무 클 수 있습니다",
    ),
    "close": MessageLookupByLibrary.simpleMessage("닫기"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("연결 종료"),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "VPN이 일시 중지되면 열려 있는 모든 연결을 끊습니다",
    ),
    "color": MessageLookupByLibrary.simpleMessage("색상"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("대비"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("색상 스타일"),
    "columns": MessageLookupByLibrary.simpleMessage("열"),
    "compact": MessageLookupByLibrary.simpleMessage("간결하게"),
    "compatible": MessageLookupByLibrary.simpleMessage("호환 모드"),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "모든 데이터를 지우시겠습니까?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "이 프록시 그룹을 삭제하시겠습니까?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("현재 창을 닫으시겠습니까?"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 비정상 종료시키시겠습니까?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage("혼잡 제어"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 혼잡 제어"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 혼잡 제어는 mips 스택에서만 작동합니다.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("연결됨"),
    "connecting": MessageLookupByLibrary.simpleMessage("연결 중…"),
    "connection": MessageLookupByLibrary.simpleMessage("연결"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("연결 통계"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "실시간 연결, 최근 요청, DNS 쿼리",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("연결"),
    "connectivity": MessageLookupByLibrary.simpleMessage("연결 상태: "),
    "content": MessageLookupByLibrary.simpleMessage("내용"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("내용을 입력하세요"),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("높음"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("중간"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "전역 추가 규칙 관리",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("복사"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("환경 변수 복사"),
    "copyLink": MessageLookupByLibrary.simpleMessage("링크 복사"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("복사했습니다"),
    "core": MessageLookupByLibrary.simpleMessage("코어"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("아키텍처"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "서명되지 않아 Windows Smart App Control이 ReClashCore.exe를 차단했습니다. Windows 보안 → 앱 및 브라우저 컨트롤 → Smart App Control 설정에서 끔을 선택한 후 ReClash를 다시 시작하세요. Smart App Control은 Windows를 다시 설치하지 않으면 다시 켤 수 없습니다.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("빌드 플래그"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("빌드 시간"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("환경"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("코어 실행 파일"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "코어 정보를 읽을 수 없습니다",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("실행 방식"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("위치"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage("관리되는 권한 상승 프로세스"),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage("Helper를 통한 프로세스"),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage("프로세스 내 라이브러리"),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "서명된 Helper를 통한 관리 프로세스",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("별도 프로세스"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage("런타임 설정 열기"),
    "corePlatform": MessageLookupByLibrary.simpleMessage("플랫폼"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("실행 중"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage("런타임 설정"),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "설정과 스크립트를 적용한 최종 설정입니다. 읽기 전용입니다.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "런타임 설정을 읽을 수 없습니다",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("시작 중…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("코어 상태"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("중지됨"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage("데이터 폴더"),
    "country": MessageLookupByLibrary.simpleMessage("지역"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("비정상 종료 감지됨"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("비정상 종료 테스트"),
    "create": MessageLookupByLibrary.simpleMessage("만들기"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("생성 시간"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI 우회"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("앱의 기반"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage("추가 기능"),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage("프로바이더 기능과 아이디어"),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("프록시 코어"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "시작 버튼이 있어 제거할 수 없습니다",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "customColor": MessageLookupByLibrary.simpleMessage("사용자 지정 색상"),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("이름이 비어 있습니다"),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "선택한 프록시나 프록시 공급자가 없어 코어가 이 그룹을 거부합니다",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 프로필 리소스",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 프로필 리소스는 직접 추가해 사용자 지정 프로필에서 쓰는 프록시, 규칙 공급자, 필터, 아이콘 세트입니다.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("잘라내기"),
    "dark": MessageLookupByLibrary.simpleMessage("다크"),
    "dashboard": MessageLookupByLibrary.simpleMessage("대시보드"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("추가 가능"),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("대시보드"),
    "dashboardStyleDetailed": MessageLookupByLibrary.simpleMessage("상세"),
    "dashboardStyleSimple": MessageLookupByLibrary.simpleMessage("간단"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "변경 사항을 저장하지 못해 되돌렸습니다",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("기본 선택"),
    "defaultText": MessageLookupByLibrary.simpleMessage("기본값"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "구성은 이름과 유형이 있는 YAML 매핑이어야 합니다",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("지연"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "delayTest": MessageLookupByLibrary.simpleMessage("지연 테스트"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage("지연 테스트 시간 제한"),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta 기반의 멀티 플랫폼 프록시 클라이언트로, 간편하게 사용할 수 있으며 오픈 소스이고 광고가 없습니다.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "그래픽 인증 에이전트를 사용할 수 없습니다. 현재 데스크톱 세션에서 실행한 후 다시 시도하세요.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "인증이 취소되었습니다. TUN은 시작되지 않았습니다.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "인증이 승인되지 않았습니다. TUN은 시작되지 않았습니다.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN에는 인증이 필요합니다. 연결을 시작하거나 TUN을 켜서 승인하세요.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "인증 시간이 초과되었습니다. 연결 버튼으로 다시 시도하세요.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "인증된 Core가 검증된 시작을 완료하지 못했습니다. 패키지와 시스템 로그를 확인하세요.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core 또는 Helper의 무결성 검증에 실패했습니다. 전체 ReClash 패키지를 다시 설치하세요.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "시스템 설정 → 일반 → 로그인 항목 및 확장 프로그램에서 ReClash Helper를 허용한 후 다시 시도하세요.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "설치된 Helper가 다른 프로토콜을 사용합니다. 다른 설치 또는 서비스 재정의 설정을 확인한 다음 전체 패키지를 다시 설치하세요.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "기존 Linux Helper 등록을 안전하게 교체할 수 없습니다. 서비스 소유권과 등록을 확인하세요. 인증을 반복해도 충돌은 해결되지 않습니다.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd가 TUN Helper를 시작하지 못했습니다. 서비스 로그를 확인하세요. 설치 프로그램은 이전 설치 복원을 시도했습니다.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN에는 systemd가 관리하는 Linux 세션이 필요합니다. 이 시스템에서는 네트워크 Helper를 실행할 수 없습니다.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN Helper를 사용할 수 없습니다. 설치된 패키지와 서비스를 확인한 후 다시 시도하세요.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "이전 인증 또는 Core 종료가 아직 완료되지 않았습니다. 완료될 때까지 기다린 후 다시 시도하세요.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN에는 올바르게 서명된 ReClash 앱과 Helper가 필요합니다. 서명이 없거나 ad-hoc 서명된 빌드는 인증할 수 없습니다.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core는 시작되었지만 TUN 어댑터가 준비되지 않았습니다. TUN을 사용하기 전에 Core 로그를 확인하세요.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("목적지"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("목적지 GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("목적지 IP ASN"),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "서드파티 API에 의존하므로 참고용으로만 사용하세요",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("개발자 모드"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "개발자 모드가 켜졌습니다.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("다이얼러 프록시"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "다이얼러 프록시는 NTP 서버에 연결할 때 사용하는 아웃바운드입니다.",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("직접"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP 전달 사용 안 함",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP 전달을 끄면 TUN이 ping에 직접 응답하므로 ping에 실제 지연 시간이 표시되지 않습니다.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "TCP 킵얼라이브 사용 안 함",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP 사용 안 함"),
    "disabled": MessageLookupByLibrary.simpleMessage("사용 안 함"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("변경 사항을 취소하시겠습니까?"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("면책 조항"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어를 설치, 복사 또는 사용하면 이 문서 전체를 읽고 동의한 것으로 간주합니다. 어느 조항이라도 동의하지 않는 경우 즉시 본 소프트웨어의 사용을 중단하고 삭제하세요.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("동의"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "이 문구를 읽고 이해했습니다",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "내용을 이해했는지 확인하기 위해 다음 문구를 읽고 아래 항목에 체크하세요.",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("문구 확인"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "개발자는 릴리스와 함께 본 문서를 개정할 수 있으며, 개정 내용은 해당 릴리스가 공개되는 시점에 효력이 발생합니다. 업데이트 후에도 본 소프트웨어를 계속 사용하면 개정된 문서를 수락한 것으로 간주합니다.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("본 문서의 변경"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash(이하 “본 소프트웨어”)를 사용하기 전에 이 문서를 주의 깊게 읽고 모든 내용을 이해했는지 확인하세요. “동의”를 누르면 아래 모든 조항을 읽고 이해했으며 수락한 것으로 간주합니다. 동의하지 않으면 “종료”를 누르고 본 소프트웨어의 사용을 중단하세요.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "관련 법률이 허용하는 최대 범위에서, 개발자와 기여자는 본 소프트웨어의 사용 또는 사용 불능으로 발생하는 직접, 간접, 부수적, 특별, 징벌적 또는 결과적 손해에 대해 책임을 지지 않습니다. 여기에는 데이터 손실, 기기 손상, 네트워크 장애, 사업 중단, 이익 손실 및 그로 인한 법적 분쟁이 포함되며 이에 국한되지 않고, 그러한 손해의 가능성을 사전에 통지받은 경우에도 마찬가지입니다.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("책임의 제한"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 GPL-3.0 라이선스로 공개된 오픈 소스입니다. 파생 저작물도 GPL-3.0으로 배포하고 원저작권 고지를 유지해야 하는 라이선스 조건을 준수하는 한 자유롭게 사용, 수정, 배포할 수 있습니다.\n\nClash.Meta 코어를 포함한 본 소프트웨어의 제3자 구성 요소는 각자의 라이선스를 따릅니다. 원저작자는 수정 또는 재배포된 버전에서 발생하는 어떠한 문제에도 책임을 지지 않습니다.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "오픈 소스 라이선스",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어 자체는 프록시 서버, 노드, 구독, 네트워크 접속 서비스를 일절 제공하지 않으며, 이러한 서비스의 어떤 제공자와도 제휴, 대리 또는 보증 관계가 없습니다.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 구독 URL, 노드 정보, 구성 내용, 방문한 웹사이트, 연결 기록, 트래픽 내용, 로그를 수집하거나 업로드하지 않습니다. 이 데이터는 사용자의 기기에만 저장되며 개발자는 접근할 수 없습니다.\n\n본 소프트웨어는 프로필을 업데이트할 때 사용자가 입력한 구독 URL을 가져오거나 업데이트를 확인할 때 GitHub에 접속하는 등 기능이 필요할 때만 네트워크에 접속합니다.\n\n본 소프트웨어에는 어떤 플랫폼에서도 분석 또는 비정상 종료 보고 서비스가 포함되어 있지 않습니다.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "데이터 수집 및 개인정보 보호",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage("끝까지 읽기"),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어의 사용이 거주지에서 적법한지 확인할 책임은 사용자에게 있으며, 본 소프트웨어로 한 모든 행위와 그 결과에 대한 법적 책임은 사용자 본인이 부담합니다.\n\n가져오는 구독, 노드, 구성은 사용자 본인의 선택입니다. 출처의 적법성, 콘텐츠의 안전성, 서비스의 신뢰성은 사용자와 해당 제공자 사이의 문제입니다.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "사용자의 책임",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "위 문구를 입력하세요",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "문구와 일치하지 않습니다",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "내용을 이해했는지 확인하기 위해 아래 입력란에 다음 문구를 그대로 입력하세요.",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("문구 다시 입력"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 Clash.Meta(mihomo) 코어를 기반으로 한 오픈 소스 네트워크 프록시 클라이언트입니다. 구성 관리, 규칙 기반 라우팅, 트래픽 전달과 같은 로컬 도구만 제공합니다.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "소프트웨어의 성격",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "구독 링크, 구성 파일, 규칙 세트, 스크립트, 외부 리소스, 외부 링크는 모두 제3자가 제공합니다. 개발자는 이들의 적법성, 정확성, 안전성, 가용성을 심사하거나 보증할 수 없으며 보증하지 않습니다.\n\n제3자 콘텐츠로 인한 데이터 유출, 금전적 손실, 계정 정지 및 기타 손해는 사용자와 해당 제3자 사이에서 해결해야 하며, 개발자는 이에 대해 책임을 지지 않습니다.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "제3자 콘텐츠",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 학습, 교류, 기술 연구와 같은 비상업적 용도로만 제공됩니다. 유료 배포, 끼워 팔기, 상업 서비스의 일부로 사용, 본 소프트웨어의 이름을 내세운 영업 등 어떠한 상업적 목적의 사용도 엄격히 금지되며, 이에 국한되지 않습니다. 모든 상업 활동은 본 소프트웨어 및 개발자와 무관합니다.\n\n거주 국가 또는 지역의 법령을 위반하는 용도로 본 소프트웨어를 사용하는 것은 엄격히 금지됩니다. 여기에는 합법적으로 부과된 네트워크 접속 제한 우회, 불법 콘텐츠 유포, 네트워크 공격, 타인의 합법적 권리 침해가 포함되며 이에 국한되지 않습니다.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("사용 제한"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 “있는 그대로”, “이용 가능한 상태로” 제공되며, 상품성, 특정 목적에의 적합성, 비침해성, 중단 없는 이용 가능성, 오류 없음, 보안 취약점 없음에 대한 보증을 포함하되 이에 국한되지 않고 명시적이든 묵시적이든 어떠한 종류의 보증도 하지 않습니다.\n\n개발자는 본 소프트웨어가 사용자의 요구를 충족하거나 중단 및 오류 없이 실행될 것임을 보증하지 않습니다.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("보증 부인"),
    "disconnected": MessageLookupByLibrary.simpleMessage("연결 끊김"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("새 버전 발견"),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("DNS 캐시를 지웠습니다"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "추가하지 않으면 53번 포트로 가는 모든 DNS 쿼리를 하이재킹합니다(any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS 하이재킹"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 모드"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 추가한 항목은 모든 URL 및 파일 프로필의 DNS를 대체합니다. 추가하지 않은 항목은 프로필 자체 설정을 유지합니다. 사용자 지정 프로필은 내용에서 DNS를 설정합니다.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS 쿼리"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "모든 DNS 재정의가 삭제되고 선택한 지역의 DNS 서버가 다시 설정됩니다.",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("고정"),
    "domain": MessageLookupByLibrary.simpleMessage("도메인"),
    "done": MessageLookupByLibrary.simpleMessage("완료"),
    "download": MessageLookupByLibrary.simpleMessage("다운로드"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("다운로드 대역폭"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("업데이트 다운로드 중"),
    "duration": MessageLookupByLibrary.simpleMessage("소요 시간"),
    "edit": MessageLookupByLibrary.simpleMessage("편집"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("대시보드 편집"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("전역 규칙 편집"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("네트워크 편집"),
    "editProxy": MessageLookupByLibrary.simpleMessage("프록시 편집"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 편집"),
    "editRule": MessageLookupByLibrary.simpleMessage("규칙 편집"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSID 편집"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("편집기를 사용할 수 없음"),
    "elapsed": MessageLookupByLibrary.simpleMessage("소요"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("빈 폴백"),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("영어"),
    "enabled": MessageLookupByLibrary.simpleMessage("사용"),
    "enterManually": MessageLookupByLibrary.simpleMessage("직접 입력"),
    "entries": MessageLookupByLibrary.simpleMessage("개 항목"),
    "error": MessageLookupByLibrary.simpleMessage("오류"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("오류 세부 정보"),
    "es": MessageLookupByLibrary.simpleMessage("스페인어"),
    "exclude": MessageLookupByLibrary.simpleMessage("최근 작업에서 숨기기"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("제외할 대상 포트"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 대상 포트로 가는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("제외 필터"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("제외할 인터페이스"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "docker0와 같이 제외할 인터페이스로 들어오는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("제외할 소스 포트"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 소스 포트에서 나가는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("제외할 SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "제외 SSID의 Wi-Fi에 연결되면 앱의 실행 상태가 자동으로 전환됩니다.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("제외할 사용자 ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 사용자 ID의 프로세스 트래픽은 TUN을 거치지 않습니다.",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("종료"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("전체 화면 종료"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("출구 노드"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("예상 상태"),
    "expireTime": MessageLookupByLibrary.simpleMessage("만료 시간"),
    "exportFile": MessageLookupByLibrary.simpleMessage("파일 내보내기"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("로그 내보내기"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("내보내기 완료"),
    "extend": MessageLookupByLibrary.simpleMessage("확장"),
    "extendMode": MessageLookupByLibrary.simpleMessage("확장 모드"),
    "extendScript": MessageLookupByLibrary.simpleMessage("확장 스크립트"),
    "externalController": MessageLookupByLibrary.simpleMessage("외부 컨트롤러"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "외부 컨트롤러를 사용하면 9090 포트로 코어를 제어할 수 있습니다.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "외부 컨트롤러 시크릿",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("외부 링크"),
    "extra": MessageLookupByLibrary.simpleMessage("기타"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("매우 크게"),
    "fade": MessageLookupByLibrary.simpleMessage("페이드"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP 필터"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IP 필터 모드"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP 필터 모드에서 블랙리스트는 일치 항목을 제외하고, 화이트리스트는 일치 항목에만 가짜 IP를 사용하며, 규칙은 규칙에 따라 일치시킵니다.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP 범위"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP 범위(IPv6)"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("폴백 필터"),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "파일이 수정되었습니다. 변경 사항을 저장하시겠습니까?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("필터"),
    "filters": MessageLookupByLibrary.simpleMessage("필터"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("프로세스 찾기"),
    "floating": MessageLookupByLibrary.simpleMessage("플로팅"),
    "followProfile": MessageLookupByLibrary.simpleMessage("프로필 따르기"),
    "followSystem": MessageLookupByLibrary.simpleMessage("시스템 설정 따르기"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("글꼴"),
    "fontSize": MessageLookupByLibrary.simpleMessage("크기"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("DNS 매핑 강제"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 매핑 강제는 DNS 매핑에서 도메인을 얻은 연결도 스니핑합니다.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("강제 도메인"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "강제 도메인은 항상 스니핑합니다. 이미 도메인이 있는 다른 연결은 그대로 둡니다.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 다시 시작하시겠습니까?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("프랑스어"),
    "general": MessageLookupByLibrary.simpleMessage("일반"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 추가한 항목은 모든 프로필의 해당 설정을 대체합니다. 추가하지 않은 항목은 프로필 자체 설정을 유지하며, 프로필에 없으면 코어 기본값을 사용합니다.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo 저메모리 모드"),
    "global": MessageLookupByLibrary.simpleMessage("전역"),
    "go": MessageLookupByLibrary.simpleMessage("이동"),
    "goDownload": MessageLookupByLibrary.simpleMessage("다운로드"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "추가한 규칙 구성으로 이동",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("스크립트 구성으로 이동"),
    "gratitude": MessageLookupByLibrary.simpleMessage("감사의 말"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash는 그들의 작업 덕분에 존재합니다",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("격자"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("개"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("변경 사항을 캐시하시겠습니까?"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("인바운드 사용자별 해시"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("상태 확인"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "헬퍼 서비스를 사용할 수 없어 TUN 모드를 켤 수 없습니다. ReClash를 다시 설치하여 복구하세요.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("16진수"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("목록에서 숨기기"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP 숨기기"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("비밀번호 숨기기"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "시간 초과된 프록시 숨기기",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "마지막 지연 테스트에서 시간 초과된 프록시를 제외합니다",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("호핑 간격"),
    "host": MessageLookupByLibrary.simpleMessage("호스트"),
    "hostname": MessageLookupByLibrary.simpleMessage("호스트 이름"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("모두 지우기"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "모든 단축키 조합을 삭제할까요?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage("컴포지터 설정"),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "컴포지터 설정에 파일 포함 구문을 추가할 수도 있습니다. 이 파일은 ReClash의 키 조합 설정에 맞춰 갱신되며 키 기록 중에는 일시적으로 비워집니다. 데스크톱 설정은 자동으로 변경되지 않습니다. 충돌하는 키 바인딩은 해당 설정에서 해결하세요.",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "전역 단축키는 창이 숨겨져 있어도 작동합니다. 동작을 눌러 키 조합을 기록하세요.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage("데스크톱 단축키"),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "데스크톱 설정에서 명령을 사용자 지정 단축키에 할당하세요. ReClash가 실행 중이어야 하지만 창은 숨겨져 있어도 됩니다. 이 전역 키 바인딩은 데스크톱 설정에서 관리합니다.",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "컴포지터 설정 파일을 사용할 수 없습니다. 위의 데스크톱 명령은 계속 사용할 수 있습니다.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "이 조합은 앱 창이 포커스된 동안 작동합니다. 전역 단축키를 사용하려면 아래 데스크톱 명령을 연결하세요.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("단축키 관리"),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("설정 안 됨"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage("기본값 복원"),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "모든 조합을 기본값으로 바꿀까요?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "안전 모드에서는 단축키 동작이 비활성화되지만 키 조합은 편집할 수 있습니다.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "등록되지 않음: 다른 앱이 사용 중일 수 있습니다",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("시간"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("색조"),
    "icon": MessageLookupByLibrary.simpleMessage("아이콘"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("아이콘 기록"),
    "iconSets": MessageLookupByLibrary.simpleMessage("아이콘 세트"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "아이콘 세트가 아직 없습니다. 사용자 지정 프로필 리소스 → 아이콘 세트에서 추가하세요",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("아이콘 스타일"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("채움"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("숨김"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("기본"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("아이콘 URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "배터리 최적화 무시",
    ),
    "import": MessageLookupByLibrary.simpleMessage("가져오기"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "가져올 수 있는 구성 파일이 아닙니다",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "가져오면 이 프로필의 현재 프록시 그룹, 규칙, 설정이 대체됩니다",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("파일에서 가져오기"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("링크에서 가져오기"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL에서 가져오기"),
    "inbound": MessageLookupByLibrary.simpleMessage("인바운드"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("포함할 인터페이스"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "포함할 인터페이스로 들어오는 트래픽만 TUN을 거치며, 제외할 인터페이스는 더 이상 적용되지 않습니다.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("포함할 사용자 ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "포함할 사용자 ID의 프로세스 트래픽만 TUN을 거칩니다.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("만료되지 않음"),
    "init": MessageLookupByLibrary.simpleMessage("초기화"),
    "initFailed": MessageLookupByLibrary.simpleMessage("시작 실패"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash를 시작하는 중 오류가 발생하여 계속할 수 없습니다. 세부 정보를 복사하여 문제를 보고하세요. 문제가 계속되면 데이터를 지우면 대개 앱이 다시 시작됩니다.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("요청자"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("출처"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹 이름을 입력하세요",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("규칙 내용을 입력하세요"),
    "installUpdate": MessageLookupByLibrary.simpleMessage("업데이트 설치"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "앱 목록 권한이 거부되어 설치된 앱을 표시할 수 없습니다. 시스템 설정에서 직접 허용해 주세요.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "이 시스템은 권한을 허용하기 전까지 설치된 앱 목록을 숨깁니다. 앱별 프록시를 구성하려면 권한을 허용하세요.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "앱 목록 권한 필요",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("설치된 글꼴"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("스마트 선택"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("인터페이스 이름"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "인터페이스 이름은 아웃바운드 연결이 사용하는 네트워크 인터페이스입니다.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("아웃바운드 인터페이스"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("지정 안 함"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("구성 따르기"),
    "internet": MessageLookupByLibrary.simpleMessage("인터넷"),
    "interval": MessageLookupByLibrary.simpleMessage("간격"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("내부망 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("올바르지 않은 백업 파일"),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "192.168.0.0/16과 같은 CIDR 형식의 IP 범위를 입력하세요",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP 마크는 63을 넘을 수 없습니다",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "도메인 또는 IP 주소를 입력하세요",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("올바른 아이콘 세트가 아닙니다"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "구독 링크 또는 프록시 공유 링크가 아닙니다",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053과 같은 주소와 포트를 입력하세요",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "tcp 또는 udp만 지원합니다",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 또는 8000-9000과 같은 포트나 범위를 입력하세요",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "이 QR 코드에는 프로필 링크가 없습니다",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 또는 8000-9000과 같은 숫자나 범위를 /로 구분하여 입력하세요",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID는 UTF-8 기준 32바이트를 초과할 수 없습니다",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP 주소"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("악용 이력"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("프록시"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("플래그"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("조직"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP 유형을 확인할 수 없습니다",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("양호"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("등급"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("보통"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("다시 확인"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("위험"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("품질"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("응답 출처"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("출처"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("아웃바운드 IP가 다름"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("유형 없음"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("요청 제한됨"),
    "ipType": MessageLookupByLibrary.simpleMessage("유형"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("기업용"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("데이터 센터"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("모바일 네트워크"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("가정용"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("알 수 없는 유형"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP 버전"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 트래픽은 IPv6가 켜져 있을 때만 수신됩니다.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6를 켜면 VPN이 IPv6 인바운드를 허용합니다.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6 타임아웃(ms)"),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("일본어"),
    "justNow": MessageLookupByLibrary.simpleMessage("방금"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP 킵얼라이브 유휴 시간"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 킵얼라이브 간격",
    ),
    "key": MessageLookupByLibrary.simpleMessage("키"),
    "kk": MessageLookupByLibrary.simpleMessage("카자흐어"),
    "ko": MessageLookupByLibrary.simpleMessage("한국어"),
    "label": MessageLookupByLibrary.simpleMessage("레이블"),
    "language": MessageLookupByLibrary.simpleMessage("언어"),
    "large": MessageLookupByLibrary.simpleMessage("크게"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("마지막 업데이트"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("시작이 완료되지 않음"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "지난번 시작하는 중에 앱이 예기치 않게 종료되었습니다. 이번 실행에서는 자동 설정을 건너뛰었으니 직접 시작하여 다시 시도하세요.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("레이아웃"),
    "license": MessageLookupByLibrary.simpleMessage("라이선스"),
    "licenses": MessageLookupByLibrary.simpleMessage("라이선스"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("앱에 포함된 패키지"),
    "light": MessageLookupByLibrary.simpleMessage("라이트"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("자동 줄 바꿈"),
    "link": MessageLookupByLibrary.simpleMessage("링크"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("목록"),
    "listen": MessageLookupByLibrary.simpleMessage("수신"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("수신 라우팅 마크"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "수신 라우팅 마크는 Linux에서만 작동합니다.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("실시간 연결"),
    "loading": MessageLookupByLibrary.simpleMessage("로드 중…"),
    "local": MessageLookupByLibrary.simpleMessage("로컬"),
    "localImage": MessageLookupByLibrary.simpleMessage("로컬 이미지"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "로컬 네트워크 권한이 거부되었습니다. gvisor 스택을 사용하므로 LAN에 연결할 수 없습니다.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("로컬 프록시"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("위치 권한"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "위치 권한이 거부되어 현재 Wi-Fi 이름을 읽을 수 없습니다. 시스템 설정에서 위치 권한을 직접 켜 주세요.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "시스템에서 Wi-Fi 이름을 읽으려면 위치 권한이 필요합니다. Android에서는 “항상 허용”을 선택해야 하며, 그렇지 않으면 앱이 백그라운드에 있을 때 Wi-Fi 이름을 읽을 수 없습니다.",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "위치 권한 필요",
    ),
    "log": MessageLookupByLibrary.simpleMessage("로그"),
    "logLevel": MessageLookupByLibrary.simpleMessage("로그 수준"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Logcat을 끄면 로그 항목이 숨겨집니다.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("로그"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("로그 및 진단"),
    "logsTest": MessageLookupByLibrary.simpleMessage("로그 테스트"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP 루프백 예외"),
    "loose": MessageLookupByLibrary.simpleMessage("넓게"),
    "maintainer": MessageLookupByLibrary.simpleMessage("메인테이너"),
    "matchCase": MessageLookupByLibrary.simpleMessage("대/소문자 구분"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("출발지 IP 일치"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("최대 실패 횟수"),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("최대화"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("상주 메모리"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("앱 및 공유"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("유휴 힙"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("사용 중인 힙"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "코어가 실행 중이 아닙니다",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("런타임 오버헤드"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("고루틴 스택"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 상주 메모리로 추정한 값이며 시스템에 표시되는 값과 다를 수 있습니다.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "코어는 앱 프로세스 안에서 실행됩니다. 코어의 점유량은 런타임 통계로 추정하며, 나머지는 앱 및 공유 메모리로 집계합니다.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("메모리 정보"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("앱과 코어가 사용하는 메모리"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("메모리를 해제했습니다"),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("메시지 테스트"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("이것은 메시지입니다."),
    "minimize": MessageLookupByLibrary.simpleMessage("최소화"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("종료 시 최소화"),
    "minutes": MessageLookupByLibrary.simpleMessage("분"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("혼합 포트"),
    "mode": MessageLookupByLibrary.simpleMessage("모드"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("모노크롬 아이콘"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("모노크롬"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("더 보기"),
    "name": MessageLookupByLibrary.simpleMessage("이름"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("하단 바"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("탭 레이블"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("항상"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("안 함"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage("선택됨"),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("내비게이션"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage("탭 바"),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage("사이드바"),
    "network": MessageLookupByLibrary.simpleMessage("네트워크"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "요청이 취소되었습니다",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "서버에 연결할 수 없습니다. 네트워크 연결이나 프록시 설정을 확인하세요",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID(집 와이파이) 또는 서브넷(192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "서버 주소를 확인할 수 없습니다. URL이 올바른지, DNS가 정상인지 확인하세요",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("네트워크 이름"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "요청이 너무 많습니다(HTTP 429). 잠시 후 다시 시도하세요",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "우회 목록과 TUN MTU가 선택한 지역의 기본값으로 돌아갑니다.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("네트워크 시크릿"),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("네트워크 속도"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("트래픽 가로채기"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "요청 시간이 초과되었습니다. 네트워크나 프록시를 확인한 후 다시 시도하세요",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "보안 연결에 실패했습니다. 서버 인증서가 올바르지 않거나 연결이 가로채이고 있을 수 있습니다",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("네트워크 유형"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("다음 결과"),
    "no": MessageLookupByLibrary.simpleMessage("아니요"),
    "noData": MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "noInfo": MessageLookupByLibrary.simpleMessage("정보 없음"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("다시 알리지 않음"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("네트워크 없음"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("네트워크 미사용 앱"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP 확인 안 함"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("호스트 이름 확인 안 함"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("일치하는 결과 없음"),
    "nodes": MessageLookupByLibrary.simpleMessage("노드"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "이 외부 리소스는 텍스트 파일이 아닙니다",
    ),
    "none": MessageLookupByLibrary.simpleMessage("없음"),
    "notRunning": MessageLookupByLibrary.simpleMessage("실행 중 아님"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "현재 프록시 그룹은 선택할 수 없습니다",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "현재 네트워크는 신뢰 목록에 없습니다",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("알림"),
    "notificationActive": MessageLookupByLibrary.simpleMessage("보호 중"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "구성 요소 추가",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage("자동 그룹"),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "서버 그룹이 확인되지 않아 이 줄은 표시되지 않습니다",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage("알림 구성 요소"),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "실시간 상태 구성 요소로 알림을 구성하세요.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "추가된 구성 요소 없음",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "구성 요소가 없으면 알림에는 보호 상태만 표시됩니다.",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("내용"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage("현재 서버"),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android 알림 전달",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Android 알림 권한을 확인하는 중",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage("ReClash 알림이 차단되어 있습니다"),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "알림을 전달할 수 있습니다",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash 서비스 채널이 사용 중지되었습니다",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage("구독 알림 채널이 사용 중지되었습니다"),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "유휴 시 속도 숨기기",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "잠금 화면에서 민감한 정보 숨기기",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "서비스 알림과 리마인더는 Android 잠금 화면의 개인정보 설정을 따릅니다. 잠금을 해제하면 세부 정보가 표시됩니다.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "상세 모드는 실시간 정보와 중지 버튼을 표시합니다. 최소 모드는 보호 상태만 표시합니다.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage("네트워크 속도"),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("개인정보"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("리마인더"),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "선택한 그룹이 프로필에 없습니다",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "서비스 채널",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "세션 트래픽",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "구독 알림 채널",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "구독 알림",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage("구독에 확인이 필요할 때 알립니다"),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage("알림 수준"),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "상세",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage("최소"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("동기화 간격(분)"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP는 시스템 시계 대신 NTP 서버에서 시간을 가져옵니다.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("프로필을 추가하여 시작하세요"),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("난독화"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("난독화 호스트"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("난독화 모드"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("난독화 매개변수"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("난독화 비밀번호"),
    "onDemand": MessageLookupByLibrary.simpleMessage("필요 시 실행"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "이 서브넷은 광범위한 네트워크를 신뢰합니다",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage("연결 끊기"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "필요 시 실행은 제외된 Wi-Fi에서 프록시를 일시 중지합니다.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("완전 중지"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "일시 정지 중 TUN을 해제하고 로컬 프록시 포트를 닫습니다. 자동 재개를 위해 네트워크 감시는 계속됩니다.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("일시 정지"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("재개"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi 네트워크를 읽을 수 없습니다. 다시 시도하거나 수동으로 입력하세요.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "SSID와 서브넷 함께 일치 요구",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "두 종류의 규칙이 모두 있으면 SSID와 서브넷이 모두 일치할 때만 일시 중지",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("프록시 트래픽만 집계"),
    "optional": MessageLookupByLibrary.simpleMessage("선택 사항"),
    "options": MessageLookupByLibrary.simpleMessage("옵션"),
    "other": MessageLookupByLibrary.simpleMessage("기타"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("기타 기여자"),
    "outbound": MessageLookupByLibrary.simpleMessage("아웃바운드"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("출구"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("아웃바운드 IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("아웃바운드 모드"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("대상 덮어쓰기"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "대상 덮어쓰기는 원래 주소 대신 스니핑한 도메인으로 연결합니다.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("덮어쓰기 항목"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("순수 IP 분석"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "순수 IP 분석은 IP 주소만 있는 연결을 스니핑합니다.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "paste": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "peers": MessageLookupByLibrary.simpleMessage("피어"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("앨범에서 선택"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("네트워크 선택"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage("주변 와이파이 네트워크"),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage("주변에 와이파이가 없습니다"),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "주변 와이파이 네트워크를 표시하려면 위치 권한이 필요합니다",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "주변 Wi-Fi 네트워크를 보려면 위치 접근을 허용하거나 네트워크를 직접 입력하세요.",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("새로 고침"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "주변 와이파이를 찾는 중…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("창 고정"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAV를 연결하세요"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "스크립트 이름을 입력하세요",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "올바른 QR 코드를 업로드하세요",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("플러그인"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("플러그인 암호화 방식"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("플러그인 호스트"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("플러그인 모드"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("플러그인 비밀번호"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("플러그인 경로"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("플러그인 사용자 이름"),
    "port": MessageLookupByLibrary.simpleMessage("포트"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("다른 포트를 입력하세요"),
    "portHopping": MessageLookupByLibrary.simpleMessage("포트 호핑"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("포트"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("사전 공유 키"),
    "preferred": MessageLookupByLibrary.simpleMessage("우선"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("사전 요건"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "종료하려면 뒤로 버튼을 한 번 더 누르세요",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("키 조합을 누르세요"),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "구독 중복 방지",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "기존 프로필이 이미 사용하는 구독 링크를 거부합니다",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("미리보기"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("이전 결과"),
    "privateKey": MessageLookupByLibrary.simpleMessage("개인 키"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("개인 키 암호"),
    "process": MessageLookupByLibrary.simpleMessage("프로세스"),
    "profile": MessageLookupByLibrary.simpleMessage("프로필"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("올바른 간격을 입력하세요"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("자동 업데이트 간격을 입력하세요"),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "프로필이 수정되었습니다. 자동 업데이트를 끄시겠습니까?",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "구독 페이지 불러오는 중…",
    ),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage(
      "구독을 다운로드하는 중…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "이 구독 URL의 프로필이 이미 있습니다",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "구독이 암호화되어 있습니다. 추가할 때 키를 묻습니다.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("만료됨"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage("구독 형식"),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash에 가장 적합한 형식을 자동으로 선택",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "제공자 메시지",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "일부 항목은 지원되지 않습니다. 추가하기 전에 확인할 수 있습니다.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "구독 페이지를 불러오지 못했습니다. 그래도 추가할 수 있습니다.",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("서버"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage("단일 서버"),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage("새 구독"),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "추가된 항목이 없습니다. 다른 형식을 선택해 다시 시도할 수 있습니다.",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("무제한"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage("유효 기간"),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 이름을 입력하세요",
    ),
    "profilePasteFromClipboard": MessageLookupByLibrary.simpleMessage(
      "클립보드에서 붙여넣기",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "이 프로필에만 적용되며, 추가하지 않은 항목은 기본값을 사용합니다.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "이 프로필에만 적용되며 네트워크 설정의 TUN 덮어쓰기 항목보다 우선합니다.",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "올바른 프로필 URL을 입력하세요",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 URL을 입력하세요",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("프로필 정렬"),
    "project": MessageLookupByLibrary.simpleMessage("프로젝트"),
    "promoConverted": m72,
    "promoDaysLeft": m73,
    "promoEnded": MessageLookupByLibrary.simpleMessage("종료됨"),
    "promoHoursLeft": m74,
    "promoRenew": MessageLookupByLibrary.simpleMessage("연장"),
    "protocol": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("프로토콜 매개변수"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("프로토콜 버전"),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("공지"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage("자세히 보기"),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("읽기"),
    "providerInUse": m75,
    "providerNotice": MessageLookupByLibrary.simpleMessage("알림"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage("제공자 설정"),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "제공자 설정으로 되돌리기",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "설정을 제공자 설정으로 되돌리기",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "변경한 설정이 다시 구독을 따릅니다",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("원격 공급자만 지원합니다"),
    "providers": MessageLookupByLibrary.simpleMessage("외부 리소스"),
    "proxies": MessageLookupByLibrary.simpleMessage("프록시"),
    "proxiesCount": m76,
    "proxiesProfileLabel": m77,
    "proxiesRemovedTip": m78,
    "proxiesReplacedTip": m79,
    "proxyCardOneLine": MessageLookupByLibrary.simpleMessage("한 줄"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("프록시 체인"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("프록시 그룹이 비어 있습니다"),
    "proxyGroupInUse": m80,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "코어가 시작되면 그룹이 여기에 표시됩니다",
    ),
    "proxyGroupsCount": m81,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("프록시 공급자"),
    "proxyType": MessageLookupByLibrary.simpleMessage("프록시 유형"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("캐시 정리"),
    "publicKey": MessageLookupByLibrary.simpleMessage("공개 키"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("퓨어 블랙"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("퓨어 블랙 모드"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR 코드"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QR 코드를 스캔하여 프로필 가져오기"),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "이 링크는 너무 길어 QR 코드로 만들 수 없습니다. 링크 복사를 사용하세요.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("빠른 작업"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("빠른 편집"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("그룹 추가"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("네트워크 종류 추가"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("패턴 추가"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("태그 추가"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("고급"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "이 부분은 YAML로 편집합니다.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("모든 그룹"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("전체"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("자동 제어"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "시나리오는 연결 전체를 제어합니다. 네트워크 종류별 모드와 각 그룹의 동작을 정합니다. 지정하지 않은 그룹은 자체 프로필로 동작합니다.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("자동으로 돌아가기"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("균형"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("기반"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("동작"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage("변경 사항 가져오기"),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "내가 한 수정은 그대로 유지됩니다",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("서버 변경"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("전환 대상"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("확인"),
    "rcxCheckDifferent": m82,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("대상 그룹"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("서버를 찾지 못합니다"),
    "rcxCheckOn": m83,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("차단된 사이트 열림"),
    "rcxCheckSame": m84,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("확인"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage("사용 가능 여부 확인"),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("조건 추가"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("모든 조건"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("항상"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("조건 중 하나"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("모든 서버"),
    "rcxCondAtLeast": MessageLookupByLibrary.simpleMessage("이상"),
    "rcxCondAtMost": MessageLookupByLibrary.simpleMessage("이하"),
    "rcxCondClause": m85,
    "rcxCondCountry": MessageLookupByLibrary.simpleMessage("국가"),
    "rcxCondField": MessageLookupByLibrary.simpleMessage("항목"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage("대소문자 구분 안 함"),
    "rcxCondLess": MessageLookupByLibrary.simpleMessage("미만"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("일치 방식"),
    "rcxCondMore": MessageLookupByLibrary.simpleMessage("초과"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("선언된 항목 없음"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("아님"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("연산자"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("패턴"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("텍스트로"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "이 조건은 그룹이 중첩되어 있어 텍스트로 편집합니다.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("값"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage("값(쉼표로 구분)"),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("허용"),
    "rcxConsentAsk": m86,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "허용하기 전까지 그룹은 단순 프로필로 동작합니다. 사이트에는 내 서버를 통해서만, 또는 네트워크 테스트 시에만 접속합니다.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("권한 필요"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("접속하는 사이트"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "서드파티 사이트는 제공업체나 기본 제공 프로필에 속하지 않습니다.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("제어"),
    "rcxCountryAll": MessageLookupByLibrary.simpleMessage("모든 국가"),
    "rcxCountryOnServers": MessageLookupByLibrary.simpleMessage("내 서버의 국가"),
    "rcxCountryPickMany": MessageLookupByLibrary.simpleMessage("국가 선택"),
    "rcxCountryPickOne": MessageLookupByLibrary.simpleMessage("국가 하나 선택"),
    "rcxCountryServers": m87,
    "rcxCountryVerified": MessageLookupByLibrary.simpleMessage("확인됨"),
    "rcxDeleteProfile": m88,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage("네트워크 진단"),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage("직접 연결 사이트를 이 그룹으로"),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage("지금 켜짐"),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "규칙상 직접 연결하는 사이트가 열리지 않으면 이 그룹을 거치게 합니다. 로컬 주소는 항상 직접 연결됩니다.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "대기 중: 직접 연결 사이트가 아직 열림",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("복제 후 편집"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("절약"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("정밀"),
    "rcxEnergyToday": m89,
    "rcxExcept": m90,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage("프로필에서 제외됨"),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "“서버 변경” 후 제외됨",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage("후보 아님"),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "어떤 우선순위에도 해당하지 않음",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage("아직 확인 안 됨"),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage("서버가 아님"),
    "rcxExit": m91,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage("출구 국가 확인"),
    "rcxExport": MessageLookupByLibrary.simpleMessage("내보내기"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("드물게"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("자주"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("작동 중"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("사용 중"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("작동 안 함"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("네트워크 진단"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("입구 국가"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("출구 국가"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage("확인 실패"),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("네트워크 종류"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("지연 시간(ms)"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("측정됨"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("종량제 네트워크"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("이름"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("확인 통과"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("로그인 페이지"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("제공업체"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("서버 주소"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("태그"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage("연결 유형"),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("UDP 지원"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "그룹 전체가 서버 탐색 없이 이 항목을 거칩니다. 로드 밸런서나 중첩 그룹을 선택하면 모든 트래픽을 맡길 수 있습니다.",
    ),
    "rcxFixedOn": m92,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("일반"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage("그룹 프로필"),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "스마트 그룹이 서버를 고르는 방식입니다. 직접 만든 항목은 탭하여 편집하고, 그 외 항목은 복사본을 편집합니다.",
    ),
    "rcxGroupSettings": MessageLookupByLibrary.simpleMessage("그룹 설정"),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("작동 중"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("작동 안 함"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("이전에 작동"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("확인 안 됨"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("기록"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage("이전 버전"),
    "rcxHubAuto": MessageLookupByLibrary.simpleMessage("자동 라우팅"),
    "rcxHubBundle": MessageLookupByLibrary.simpleMessage("이 파일의 내용"),
    "rcxHubChange": MessageLookupByLibrary.simpleMessage("변경"),
    "rcxHubCopyConfirm": MessageLookupByLibrary.simpleMessage("사본 만들기"),
    "rcxHubCopyMessage": m93,
    "rcxHubCopyTitle": MessageLookupByLibrary.simpleMessage("내 사본을 만들까요?"),
    "rcxHubDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "이 시나리오가 하는 일",
    ),
    "rcxHubEverythingElse": MessageLookupByLibrary.simpleMessage("나머지 트래픽"),
    "rcxHubEverythingElseHint": MessageLookupByLibrary.simpleMessage(
      "어떤 경로에도 맞지 않는 트래픽은 구독의 기본 그룹을 거칩니다.",
    ),
    "rcxHubGroupsEmpty": MessageLookupByLibrary.simpleMessage(
      "아직 자동 라우팅이 관리하는 그룹이 없습니다.",
    ),
    "rcxHubLibrary": MessageLookupByLibrary.simpleMessage("라이브러리"),
    "rcxHubNeedsCore": MessageLookupByLibrary.simpleMessage(
      "자동 라우팅을 보려면 연결을 시작하세요",
    ),
    "rcxHubNetworks": MessageLookupByLibrary.simpleMessage("네트워크"),
    "rcxHubNetworksTitle": MessageLookupByLibrary.simpleMessage("모드 및 네트워크"),
    "rcxHubNoProfile": MessageLookupByLibrary.simpleMessage("구독 없음"),
    "rcxHubNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "먼저 구독을 추가하세요. 자동 라우팅은 그 그룹을 사용합니다.",
    ),
    "rcxHubOffHint": MessageLookupByLibrary.simpleMessage(
      "켜면 시나리오가 그룹과 경로의 서버를 고릅니다.",
    ),
    "rcxHubOtherGroups": MessageLookupByLibrary.simpleMessage("기타 그룹"),
    "rcxHubOtherGroupsHint": MessageLookupByLibrary.simpleMessage(
      "이 시나리오가 함께 관리하는 구독의 그룹입니다.",
    ),
    "rcxHubOverview": MessageLookupByLibrary.simpleMessage("개요"),
    "rcxHubRoutes": MessageLookupByLibrary.simpleMessage("경로"),
    "rcxHubRoutesHint": MessageLookupByLibrary.simpleMessage(
      "트래픽은 위에서부터 처음 일치하는 경로를 따릅니다.",
    ),
    "rcxHubRoutesOff": MessageLookupByLibrary.simpleMessage("실행 중인 시나리오가 없습니다"),
    "rcxHubRoutesOffHint": MessageLookupByLibrary.simpleMessage(
      "경로는 특정 서비스 같은 선택한 트래픽을 전용 서버로 보냅니다.",
    ),
    "rcxHubRoutesRuleOnly": m94,
    "rcxHubStartScenario": MessageLookupByLibrary.simpleMessage("시나리오 만들기"),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage("내 프로필에 추가"),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "이 프로필을 확인하려면 앱의 코어를 시작하세요.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage("라우팅 프로필 가져오기"),
    "rcxImported": m95,
    "rcxJournalFailure": m96,
    "rcxJournalMode": m97,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("확인 중"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서는 시나리오의 같은 이름 그룹을 대체하고, 나머지는 다른 모든 네트워크와 동일하게 동작합니다.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("이름"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "영문 소문자, 숫자, 하이픈, 최대 24자",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("제한 없는 인터넷"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("로그인 페이지"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("인식 조건"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "종류는 위에서 아래로 검사하며, 처음 일치하는 종류가 네트워크에 적용됩니다.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage("화이트리스트 전용"),
    "rcxLadderAdd": MessageLookupByLibrary.simpleMessage("단계 추가"),
    "rcxLadderAdvanced": MessageLookupByLibrary.simpleMessage("고급 조건…"),
    "rcxLadderAnyWorking": MessageLookupByLibrary.simpleMessage("작동하는 아무 서버"),
    "rcxLadderCountry": MessageLookupByLibrary.simpleMessage("국가"),
    "rcxLadderEmptyHint": MessageLookupByLibrary.simpleMessage(
      "단계를 추가하면 특정 서버를 우선할 수 있습니다",
    ),
    "rcxLadderExceptCountries": MessageLookupByLibrary.simpleMessage("이 국가 제외"),
    "rcxLadderFallThrough": MessageLookupByLibrary.simpleMessage("모두 작동하지 않으면"),
    "rcxLadderFits": m98,
    "rcxLadderGroupHint": MessageLookupByLibrary.simpleMessage(
      "이 순서는 이 그룹에만 적용됩니다. 비워 두면 프로필의 순서를 따릅니다.",
    ),
    "rcxLadderInherited": MessageLookupByLibrary.simpleMessage(
      "동작의 설정입니다. 단계를 편집하면 나만의 순서가 됩니다",
    ),
    "rcxLadderLastResortHint": MessageLookupByLibrary.simpleMessage(
      "최후의 수단 단계의 서버는 아래 단계를 포함해 다른 어느 단계에도 작동하는 서버가 없을 때만 사용됩니다.",
    ),
    "rcxLadderLatency": m99,
    "rcxLadderLatencyUnder": MessageLookupByLibrary.simpleMessage("지연 상한(ms)"),
    "rcxLadderNameContains": MessageLookupByLibrary.simpleMessage("이름에 포함"),
    "rcxLadderNameHas": m100,
    "rcxLadderNot": m101,
    "rcxLadderOther": MessageLookupByLibrary.simpleMessage("기타 조건"),
    "rcxLadderProvider": m102,
    "rcxLadderScenarioFirst": MessageLookupByLibrary.simpleMessage(
      "현재 시나리오가 이 그룹을 제어합니다. 시나리오가 지정한 서버 순서가 이 순서보다 우선합니다.",
    ),
    "rcxLadderServersIn": MessageLookupByLibrary.simpleMessage("이 단계의 서버"),
    "rcxLadderStep": m103,
    "rcxLadderStranded": m104,
    "rcxLadderTag": m105,
    "rcxLadderTitle": MessageLookupByLibrary.simpleMessage("서버 순서"),
    "rcxLadderUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("최후의 수단"),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("수준"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("고급"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("간단"),
    "rcxLine": m106,
    "rcxLintCheckUnused": m107,
    "rcxLintConsent": m108,
    "rcxLintGroupMissing": m109,
    "rcxLintPoolEmpty": m110,
    "rcxLintTagUnused": m111,
    "rcxLintTierEmpty": m112,
    "rcxLintTierUnreachable": m113,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("기본 그룹"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage("자동 라우팅 켜기"),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash가 이 그룹에서 작동하는 서버를 유지하고 장애 시 전환합니다. 확인은 네트워크를 사용하는 동안에만 실행됩니다.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "프로필과 시나리오는 고급 구성 → 자동 라우팅에서 만들고 편집합니다.",
    ),
    "rcxMatchAdd": MessageLookupByLibrary.simpleMessage("항목 추가"),
    "rcxMatchCidr": MessageLookupByLibrary.simpleMessage("IP 범위"),
    "rcxMatchCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "rcxMatchDomain": MessageLookupByLibrary.simpleMessage("도메인"),
    "rcxMatchGeoip": MessageLookupByLibrary.simpleMessage("IP 카테고리"),
    "rcxMatchGeosite": MessageLookupByLibrary.simpleMessage("사이트 카테고리"),
    "rcxMatchHint": MessageLookupByLibrary.simpleMessage(
      "이 경로가 추가로 처리할 도메인, IP 범위, 앱 또는 규칙 세트입니다.",
    ),
    "rcxMatchInvalid": MessageLookupByLibrary.simpleMessage("잘못된 값"),
    "rcxMatchKeyword": MessageLookupByLibrary.simpleMessage("도메인 키워드"),
    "rcxMatchMore": m114,
    "rcxMatchNext": MessageLookupByLibrary.simpleMessage("다음"),
    "rcxMatchNoResolve": MessageLookupByLibrary.simpleMessage("도메인 확인 안 함"),
    "rcxMatchNone": MessageLookupByLibrary.simpleMessage("선택한 트래픽 없음"),
    "rcxMatchPickHint": MessageLookupByLibrary.simpleMessage(
      "이 경로가 처리할 서비스를 고르세요. 직접 항목을 추가할 수도 있습니다.",
    ),
    "rcxMatchProcess": MessageLookupByLibrary.simpleMessage("앱"),
    "rcxMatchRuleSet": MessageLookupByLibrary.simpleMessage("규칙 세트"),
    "rcxMatchServices": MessageLookupByLibrary.simpleMessage("서비스"),
    "rcxMatchSuffix": MessageLookupByLibrary.simpleMessage("도메인 및 하위 도메인"),
    "rcxMatchType": MessageLookupByLibrary.simpleMessage("유형"),
    "rcxMatchTypeHint": MessageLookupByLibrary.simpleMessage(
      "도메인 접미사는 모든 하위 도메인도 포함합니다.",
    ),
    "rcxMatchValue": MessageLookupByLibrary.simpleMessage("값"),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage("변경 사항을 가져오지 못했습니다"),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("변경 사항을 가져왔습니다"),
    "rcxMergedConflicts": m115,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("자동"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "서버 순서에 따라 작동하는 가장 좋은 서버를 고르고, 장애가 나면 전환합니다.",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage("모드를 시나리오에 돌려주기"),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "이 네트워크의 모드는 시나리오가 정합니다",
    ),
    "rcxModeIs": m116,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("변경 안 함"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("수동"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "프록시 목록에서 직접 서버를 고릅니다. 자동 라우팅은 전환하지 않습니다.",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "모드를 직접 선택했습니다. 자동을(를) 선택할 때까지 시나리오는 대기합니다",
    ),
    "rcxModePinnedHint": m117,
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서는 모드를 직접 관리합니다",
    ),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage("허용이 필요합니다"),
    "rcxNetwork": m118,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("네트워크 종류"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("새 프로필"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("새 시나리오"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("이 네트워크에서"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("실패함"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("다음 중 하나"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("같음"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("같지 않음"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("일치함"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("성공함"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage("네트워크별 변경"),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage("그룹 자체 프로필"),
    "rcxOwnProfileHint": MessageLookupByLibrary.simpleMessage(
      "그룹은 자체 설정의 동작을 유지합니다.",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "패턴이 올바른 정규식이 아닙니다",
    ),
    "rcxPendingTier": m119,
    "rcxPinned": m120,
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("고정"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("제외"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("사용"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "그룹에 서버가 없습니다",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "현재 설정에서 이 그룹은 선택기 그룹이 아닙니다",
    ),
    "rcxProblemProfileInvalid": m121,
    "rcxProblemProfileMissing": m122,
    "rcxProblemStoreFailed": m123,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("프로필"),
    "rcxProfileDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "이 프로필이 하는 일",
    ),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("이름"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "그룹은 풀이 유지하는 서버 중에서 이 프로필로 서버를 고릅니다.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("동작"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage("한 항목에 맡기기"),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("항목"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("서버 선택"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage("최적의 서버입니다"),
    "rcxReasonBetterTier": m124,
    "rcxReasonChangeServer": m125,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage("더 나은 후보 확인 중"),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "더 빠른 서버의 추가 측정이 필요합니다",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "최근 전환하여 다음 변경 전 대기 중",
    ),
    "rcxReasonFailover": m126,
    "rcxReasonFaster": m127,
    "rcxReasonFixed": m128,
    "rcxReasonFixedMissing": m129,
    "rcxReasonFlapLimit": m130,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage("고정된 서버 유지"),
    "rcxReasonIdle": m131,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 최적의 서버 선택",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage("수동으로 제어 중"),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "네트워크가 변경됨",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "네트워크가 끊긴 것 같아 서버를 탓하지 않습니다",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "전환할 다른 작동 서버가 없습니다",
    ),
    "rcxReasonOutOfPool": m132,
    "rcxReasonPaused": m133,
    "rcxReasonRouteInvalid": m134,
    "rcxReasonRouteNameTaken": m135,
    "rcxReasonRouteToMissing": m136,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "서버를 선택할 수 없습니다",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "직접 연결 사이트가 다시 직접 연결됩니다",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "직접 연결 사이트가 이제 이 그룹을 거칩니다",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "작동하는 서버가 없어 현재 서버를 유지합니다",
    ),
    "rcxReasonSwitchFixed": m137,
    "rcxReasonSwitchPinned": m138,
    "rcxReasonSwitchStranded": m139,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "작동 중이며 장애 전까지 유지",
    ),
    "rcxRouteAdd": MessageLookupByLibrary.simpleMessage("경로 추가"),
    "rcxRouteChoose": MessageLookupByLibrary.simpleMessage("선택"),
    "rcxRouteEdit": MessageLookupByLibrary.simpleMessage("경로 수정"),
    "rcxRouteGroup": MessageLookupByLibrary.simpleMessage("경로로 생성됨"),
    "rcxRouteGroupHint": m140,
    "rcxRouteName": MessageLookupByLibrary.simpleMessage("이름"),
    "rcxRouteNameLong": MessageLookupByLibrary.simpleMessage("이름이 너무 깁니다"),
    "rcxRouteNameReserved": MessageLookupByLibrary.simpleMessage("예약된 이름입니다"),
    "rcxRouteNew": MessageLookupByLibrary.simpleMessage("새 경로"),
    "rcxRouteSend": MessageLookupByLibrary.simpleMessage("보낼 경로"),
    "rcxRouteSendAutoHint": MessageLookupByLibrary.simpleMessage(
      "경로 전용 그룹이 아래 순서대로 가장 좋은 서버를 고릅니다.",
    ),
    "rcxRouteSendDirectHint": MessageLookupByLibrary.simpleMessage(
      "이 트래픽은 프록시를 거치지 않습니다.",
    ),
    "rcxRouteSendFixed": MessageLookupByLibrary.simpleMessage("서버 하나"),
    "rcxRouteSendFixedHint": MessageLookupByLibrary.simpleMessage(
      "이 트래픽은 항상 선택한 서버나 그룹을 거칩니다.",
    ),
    "rcxRouteTarget": MessageLookupByLibrary.simpleMessage("서버"),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("시나리오"),
    "rcxScenarioDrives": m141,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("그룹"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "기본 그룹은 마지막 규칙이 트래픽을 보내는 그룹이고, \'모든 그룹\'은 여기에 지정하지 않은 선택 그룹을 모두 포함합니다.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "직접 진단으로 네트워크를 인식한 뒤 각 네트워크의 모드와 그룹을 변경하세요.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("연결 모드"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("꺼짐"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("시나리오"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "시나리오는 연결 전체를 제어합니다. 직접 만든 항목은 탭하여 편집하고, 그 외 항목은 복사본을 편집합니다.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("서버"),
    "rcxServersMatch": m142,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("이름 패턴"),
    "rcxSettingsLink": MessageLookupByLibrary.simpleMessage("자동 라우팅 설정"),
    "rcxSettingsLinkHint": MessageLookupByLibrary.simpleMessage(
      "프로필, 시나리오, 경로",
    ),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("스마트 그룹"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("기본 제공"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage("원본 프로필이 변경되었습니다"),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("변경된 내용"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("제공자 제공"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("내 프로필"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage("맞는 서버가 없을 때"),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("직접 연결"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage("현재 서버 유지"),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("전환"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("태그 이름"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "영문자, 숫자, -, _만 사용 가능, 최대 24자",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("태그"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "태그는 서버 묶음에 한 번 이름을 붙여 두고, 우선순위에서 tag(name)으로 사용합니다.",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("서드파티"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("레이블"),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("자동 라우팅"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("번역"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage("이 그룹의 자동 라우팅 끄기"),
    "rcxTurnOffHint": MessageLookupByLibrary.simpleMessage(
      "그룹은 현재 서버를 유지하고 더 이상 스스로 전환하지 않습니다.",
    ),
    "rcxUntilCheck": m143,
    "rcxUntilConfirm": m144,
    "rcxUntilDwell": m145,
    "rcxUseCheck": m146,
    "rcxUseDiagnostic": m147,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage("출구 국가 확인"),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("경고"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("이 서버를 선택한 이유"),
    "rcxWhyCount": m148,
    "rcxWouldDo": MessageLookupByLibrary.simpleMessage("자동 라우팅을 켜면"),
    "rcxWouldServers": m149,
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("최근 요청"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("추천"),
    "recordType": MessageLookupByLibrary.simpleMessage("레코드 유형"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir 포트"),
    "redo": MessageLookupByLibrary.simpleMessage("다시 실행"),
    "regex": MessageLookupByLibrary.simpleMessage("정규식"),
    "regionApply": MessageLookupByLibrary.simpleMessage("지역 적용"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "지역 또는 앱 목록이 바뀌었습니다. 현재 설정으로 다시 선택하세요.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "이 지역에 일치하는 앱이 없습니다. 목록은 변경되지 않습니다.",
    ),
    "regionAppsPreview": m150,
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS 서버"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage("서비스 확인"),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("변경 사항"),
    "regionChina": MessageLookupByLibrary.simpleMessage("중국"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "직접 변경한 값은 그대로 유지됩니다.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("이집트"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "국가에 맞게 DNS 서버, TUN MTU, 우회 목록, 서비스 확인을 설정합니다. 인터페이스 언어는 바뀌지 않습니다.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("이란"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage("설정이 변경되지 않습니다."),
    "regionNoServices": MessageLookupByLibrary.simpleMessage("서비스 확인이 꺼져 있습니다"),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("선택 안 됨"),
    "regionOther": MessageLookupByLibrary.simpleMessage("기타 국가"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage("이 기기에 권장"),
    "regionRussia": MessageLookupByLibrary.simpleMessage("러시아"),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "지역별 앱 추천을 사용하려면 지원되는 지역을 선택하세요.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("지역 프로필"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage("지역 맞춤 설정"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("메모리 해제"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "메모리를 해제하지 못했습니다",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("원격"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("원격 목적지"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("원격 DNS 확인"),
    "remove": MessageLookupByLibrary.simpleMessage("제거"),
    "rename": MessageLookupByLibrary.simpleMessage("이름 변경"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("구독 갱신"),
    "replace": MessageLookupByLibrary.simpleMessage("바꾸기"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("모두 바꾸기"),
    "request": MessageLookupByLibrary.simpleMessage("요청"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("요청 헤더"),
    "requests": MessageLookupByLibrary.simpleMessage("요청"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("요청 및 업데이트"),
    "required": MessageLookupByLibrary.simpleMessage("필수"),
    "reset": MessageLookupByLibrary.simpleMessage("초기화"),
    "resetAllData": MessageLookupByLibrary.simpleMessage("모든 데이터 초기화"),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage("모두 삭제"),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "모든 프로필, 설정, 스크립트, 배경화면 및 캐시 데이터가 영구적으로 삭제됩니다. 백업 파일은 유지됩니다. 이후 앱이 종료됩니다. 이 작업은 되돌릴 수 없습니다.",
    ),
    "resetAllDataWait": m151,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "이 페이지에 변경 사항이 있습니다. 초기화하시겠습니까?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("초기화하시겠습니까?"),
    "resettingAllData": MessageLookupByLibrary.simpleMessage("데이터 삭제 중…"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격은 0보다 커야 합니다",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("리소스"),
    "respectRules": MessageLookupByLibrary.simpleMessage("규칙 준수"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "규칙 준수는 DNS 연결을 규칙에 따라 라우팅하며 Proxy Server Nameserver가 필요합니다.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("응답 코드"),
    "restart": MessageLookupByLibrary.simpleMessage("다시 시작"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("코어를 다시 시작하시겠습니까?"),
    "restore": MessageLookupByLibrary.simpleMessage("복원"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("모든 데이터 복원"),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("기본값으로 복원"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("프로필만 복원"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("복원 방식"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("호환"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("덮어쓰기"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("복원 완료"),
    "result": MessageLookupByLibrary.simpleMessage("결과"),
    "retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("라우팅 주소"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("라우팅 제외 주소"),
    "routingMark": MessageLookupByLibrary.simpleMessage("라우팅 마크"),
    "ru": MessageLookupByLibrary.simpleMessage("러시아어"),
    "rule": MessageLookupByLibrary.simpleMessage("규칙"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("전체 도메인 일치"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 키워드 일치",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 정규식 일치",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 접미사 일치",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "와일드카드 일치, *와 ?만 지원",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP 마크 일치(tproxy UDP 인바운드 전용)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "목적지 포트 범위 일치",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("IP의 국가 코드 일치"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite의 도메인 일치",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("인바운드 이름 일치"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage("인바운드 포트 일치"),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage("인바운드 유형 일치"),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 사용자 이름 일치, 여러 사용자 이름은 /로 구분",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage("IP의 ASN 일치"),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP 주소 범위 일치, IP-CIDR6는 별칭일 뿐입니다",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage("IP 주소 범위 일치"),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IP 접미사 범위 일치",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "모든 요청과 일치, 조건 불필요",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 또는 UDP 일치",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름으로 일치, Android에서는 패키지 이름과 일치",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 정규식으로 일치, Android에서는 패키지 이름과 일치",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 와일드카드로 일치, *와 ?만 지원",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "전체 프로세스 경로로 일치",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 정규식으로 일치",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 와일드카드로 일치, *와 ?만 지원",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "리매치 이름 일치, 여러 이름은 /로 구분",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "규칙 세트 참조, rule-providers 필요",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP의 국가 코드 일치",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP의 ASN 일치",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP 주소 범위 일치",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP 접미사 범위 일치",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 포트 범위 일치",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "하위 규칙으로 일치, 괄호에 유의",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux 사용자 ID 일치",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("규칙이 비어 있습니다"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "규칙은 항목마다 규칙 하나인 YAML 목록이어야 합니다. 예: - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent 직접 연결",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS 차단",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "프록시 루프백 차단",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("QUIC 차단"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("STUN 차단"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN 직접 연결"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple 및 Microsoft 직접 연결",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("규칙 공급자"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("규칙 세트"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "규칙 세트에 사용할 수 있는 항목이 없습니다",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "이 mrs 파일을 읽을 수 없습니다",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "규칙 세트에 도메인과 IP 범위가 섞여 있어 유형을 판별할 수 없습니다",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("규칙 대상"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "규칙은 DOMAIN,example.com,DIRECT처럼 지원하는 유형으로 시작해야 합니다",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("규칙"),
    "rulesCount": m152,
    "runTime": MessageLookupByLibrary.simpleMessage("실행 시간"),
    "running": MessageLookupByLibrary.simpleMessage("실행 중"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("런타임 구성"),
    "safeMode": MessageLookupByLibrary.simpleMessage("안전 모드"),
    "safeModeAppTitle": m153,
    "saturation": MessageLookupByLibrary.simpleMessage("채도"),
    "save": MessageLookupByLibrary.simpleMessage("저장"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("변경 사항을 저장하시겠습니까?"),
    "script": MessageLookupByLibrary.simpleMessage("스크립트"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "스크립트 모드: 확장 스크립트로 프로필 전체를 다시 작성합니다",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("선택 항목으로 스크롤"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "seconds": MessageLookupByLibrary.simpleMessage("초"),
    "secondsCount": m154,
    "secretKey": MessageLookupByLibrary.simpleMessage("키"),
    "sectionsInEffect": m155,
    "select": MessageLookupByLibrary.simpleMessage("선택"),
    "selectAll": MessageLookupByLibrary.simpleMessage("모두 선택"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("규칙 세트를 선택하세요"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략을 선택하세요"),
    "selected": MessageLookupByLibrary.simpleMessage("선택됨"),
    "send": MessageLookupByLibrary.simpleMessage("보내기"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("휴대폰에서 보내기"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "휴대폰에서 받은 링크를 가져올까요?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "이 기기는 로컬 네트워크에 연결되어 있지 않습니다",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "구독 링크 또는 프록시 공유 링크",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "보냈습니다. 다른 기기에서 가져오기를 확인하세요.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "ReClash로 링크 보내기",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "휴대폰에서 링크를 받으려면 ReClash가 로컬 네트워크에 접근할 수 있도록 \'근처 기기\' 권한이 필요합니다. 앱 설정에서 켜 주세요.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "휴대폰 카메라로 코드를 스캔한 뒤 열린 페이지에 링크를 붙여 넣으세요. 두 기기가 같은 네트워크에 연결되어 있어야 합니다.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("서버"),
    "serviceAbnormalCount": m156,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("모두 사용 가능"),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "활성 서비스를 자동으로 확인",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage("모든 서비스 확인"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("사용 가능"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("차단됨"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("모두 확인"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "연결 시에만 확인",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("출시 예정"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage("허용되지 않는 ISP"),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("확인 실패"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("서비스 관리"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("오리지널 콘텐츠만"),
    "servicePending": MessageLookupByLibrary.simpleMessage("확인 전"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("접근 제한됨"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "대시보드에 표시됨",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("서비스 상태"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("사용 불가"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "지원하지 않는 지역",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("설정"),
    "settings": MessageLookupByLibrary.simpleMessage("설정"),
    "settingsCount": m157,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "이 프로필은 암호화되어 있습니다. 계속하려면 age 키를 입력하세요.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "이 서버는 별도 검사에 응답했습니다. 전환한 뒤 전체 경로를 다시 확인하세요.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage("ReClash 실행 시 연결"),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "앱과 함께 이 연결을 시작합니다.",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage("설정 변경"),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage("연결 확인"),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "결과는 모든 앱이나 웹사이트가 아니라 이 경로에만 해당합니다.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "선택한 경로 하나를 확인합니다. 시스템 권한 요청은 별도로 표시됩니다.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage("연결 및 확인 중"),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("확인됨"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "선택한 경로가 응답했습니다. 트래픽은 프로필 규칙을 따릅니다.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage("연결이 작동합니다"),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage("프록시 주소 복사"),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("모든 앱"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN이 기기 트래픽을 가로챕니다. 시스템에서 권한을 요청할 수 있습니다.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android에서 VPN 연결 생성 권한을 요청합니다. 앱 선택은 접근 설정에서 할 수 있습니다.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash를 사용할 앱을 선택하세요. 서버를 사용하는 연결은 프로필 규칙에 따라 결정됩니다.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage("앱을 직접 설정하겠습니다"),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "연결할 각 앱에 로컬 프록시 주소를 설정하세요.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "모든 트래픽을 가로채도 전부 서버로 전송되는 것은 아닙니다. 직접 경로는 유지됩니다.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "시스템 프록시를 지원하지 않는 앱은 직접 연결됩니다.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage("어떤 앱을 연결할까요?"),
    "setupDirectApps": m158,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "국내 앱을 찾지 못했습니다. 사이트는 계속 직접 연결됩니다.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "이 앱들은 VPN 없이 작동합니다. 목록은 나중에 접근 제어에서 바꿀 수 있습니다.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "국내 앱을 찾는 중…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "국내 서비스는 서버 없이 열립니다. 더 빠르고, 은행이나 공공 사이트에서 차단되지 않습니다. 다음 규칙이 전역 규칙에 추가됩니다:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "국내 사이트와 앱은 직접 연결",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("세부정보"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage("연결에 확인이 필요합니다"),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "설정에서 모든 선택을 변경할 수 있습니다.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("계속"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "약관을 읽기 전에 언어를 선택하세요. 나중에 변경할 수 있습니다.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("언어 선택"),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "설정이 완료되지 않았으며 연결도 확인되지 않았습니다.",
    ),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash가 종료됩니다. 선택한 내용은 저장되며 다음에 앱을 열면 설정이 이어집니다.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage("설정을 종료할까요?"),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "연결하려는 앱에 이 주소를 설정하세요. 이 확인은 앱 설정 여부를 보장하지 않습니다.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage("로컬 프록시 준비 완료"),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("확인 안 됨"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "경로가 응답했지만 일부 확인을 완료하지 못했습니다.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage("연결됨, 제한 있음"),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "시스템 메시지에서 연결을 허용하고 다시 시도하거나 다른 범위를 선택하세요.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage("권한이 필요합니다"),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "다른 서버 찾는 중",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage("연결 시작 중"),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("코어 시작 중"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage("출구 확인 중"),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage("프로필 적용 중"),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage("경로 확인 중"),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage("서비스 확인 중"),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "계속하려면 프로필을 추가하거나 선택하세요.",
    ),
    "setupProfileCount": m159,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash는 서버를 제공하지 않습니다. 제공업체의 구독 또는 구성을 가져오세요.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage("프로필 가져오기"),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "다른 프로필 추가",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "제공자의 이메일, 봇 또는 계정 페이지의 링크를 붙여 넣거나 파일 또는 QR 코드를 선택하세요.",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage("구독 또는 공유 링크"),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("프로필 준비 완료"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("나중에 설정"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage("연결 프로필 추가"),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("내 연결"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("확인"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("범위"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("프로필"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("지역"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("권장"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage("프로필 기본값 유지"),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "지역 설정을 바꾸지 않습니다.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash가 DNS, MTU, 직접 경로를 해당 국가의 네트워크에 맞춥니다. 인터페이스 언어는 바뀌지 않습니다.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage("어디에서 연결하나요?"),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "선택하지 않으면 현재 지역 설정이 그대로 유지됩니다.",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("다시 확인"),
    "setupReport": MessageLookupByLibrary.simpleMessage("확인 보고서"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage("연결 허용"),
    "setupRestart": MessageLookupByLibrary.simpleMessage("연결 설정"),
    "setupResume": MessageLookupByLibrary.simpleMessage("설정 계속하기"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "확인 중 경로가 변경되었습니다. 현재 연결을 다시 확인하세요.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "안전 모드에서는 실제 연결을 시작하지 않습니다. 설정을 저장하거나 일반 빌드에서 테스트하세요.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "선택 항목을 저장하지 못했습니다. 다시 시도하세요.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "연결하지 않고 저장",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "선택 항목이 저장되었습니다. 준비되면 대시보드에서 연결할 수 있습니다.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("나중에 연결"),
    "setupStepStatus": m160,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "선택 항목이 저장되었습니다. 이전 연결은 중지되지 않았습니다.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage("확인 중지됨"),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "다른 적용 범위를 선택하세요. 일부 네트워크는 VPN 연결을 차단합니다.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "ReClash 없이 인터넷이 되는지 확인하세요.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "프로필을 업데이트하거나 설정 후 다른 서버를 선택하세요.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage("시도해 볼 수 있는 방법"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("첫 연결"),
    "setupTryServer": m161,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("응답 없음"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "연결은 시작했지만 선택한 경로에서 충분한 결과를 얻지 못했습니다.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage("연결 확인 안 됨"),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "작업이 완료되지 않았습니다. 다시 시도하거나 세부정보를 여세요.",
    ),
    "shareLinkUnreadable": m162,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "링크에서 읽을 수 있는 프록시가 없습니다",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "다른 기기의 ReClash로 스캔하면 이 프로필을 가져올 수 있습니다.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("표시"),
    "showLess": MessageLookupByLibrary.simpleMessage("접기"),
    "showMore": MessageLookupByLibrary.simpleMessage("펼치기"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "알림에 중지 버튼 표시",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("비밀번호 표시"),
    "sidebar": MessageLookupByLibrary.simpleMessage("사이드바"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage("사이드바 블러"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "배경 흐림은 창 뒤의 바탕화면을 사이드바에 비쳐 보이게 합니다.",
    ),
    "sidebarWidth": MessageLookupByLibrary.simpleMessage("사이드바 너비"),
    "sidebarWidthNarrow": MessageLookupByLibrary.simpleMessage("좁게"),
    "sidebarWidthWide": MessageLookupByLibrary.simpleMessage("넓게"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("백그라운드 실행"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드 실행은 창을 표시하지 않고 시작합니다.",
    ),
    "simpleDashboardDetailed": MessageLookupByLibrary.simpleMessage("상세 대시보드"),
    "simpleDashboardEditWidgets": MessageLookupByLibrary.simpleMessage("위젯 편집"),
    "simpleDashboardEmpty": MessageLookupByLibrary.simpleMessage(
      "아직 위젯이 없어요. 편집 화면에서 추가하세요.",
    ),
    "simpleDashboardHome": MessageLookupByLibrary.simpleMessage("홈"),
    "simpleDashboardSimple": MessageLookupByLibrary.simpleMessage("간단한 대시보드"),
    "simpleDashboardWidgets": MessageLookupByLibrary.simpleMessage("위젯"),
    "simpleDaysCount": m163,
    "simpleIpBusiness": MessageLookupByLibrary.simpleMessage("기관 주소"),
    "simpleIpGoodDesc": MessageLookupByLibrary.simpleMessage(
      "CAPTCHA나 “VPN” 차단은 거의 없습니다.",
    ),
    "simpleIpHosting": MessageLookupByLibrary.simpleMessage("데이터 센터 주소"),
    "simpleIpLevelClean": MessageLookupByLibrary.simpleMessage("깨끗함"),
    "simpleIpLevelNormal": MessageLookupByLibrary.simpleMessage("보통"),
    "simpleIpLevelRisky": MessageLookupByLibrary.simpleMessage("위험"),
    "simpleIpMobile": MessageLookupByLibrary.simpleMessage("모바일 네트워크 주소"),
    "simpleIpNormalDesc": MessageLookupByLibrary.simpleMessage(
      "일부 사이트에서 CAPTCHA를 요구할 수 있습니다.",
    ),
    "simpleIpReal": MessageLookupByLibrary.simpleMessage("실제 주소"),
    "simpleIpRealDesc": MessageLookupByLibrary.simpleMessage(
      "인터넷 제공업체와 사이트는 사용자가 어디에 있고 무엇을 여는지 볼 수 있습니다.",
    ),
    "simpleIpResidential": MessageLookupByLibrary.simpleMessage("일반 가정용 주소"),
    "simpleIpRiskyDesc": MessageLookupByLibrary.simpleMessage(
      "사이트에서 더 자주 차단하거나 확인할 수 있습니다.",
    ),
    "simpleIpTitle": MessageLookupByLibrary.simpleMessage("사이트에서 보는 내 모습"),
    "simpleIpUnknown": MessageLookupByLibrary.simpleMessage("주소를 확인하지 못했습니다"),
    "simpleLatency": m164,
    "simpleLocationAll": MessageLookupByLibrary.simpleMessage("전체"),
    "simpleLocationAuto": MessageLookupByLibrary.simpleMessage("자동 선택"),
    "simpleLocationManual": MessageLookupByLibrary.simpleMessage("직접 선택"),
    "simpleLocationNone": MessageLookupByLibrary.simpleMessage("아직 서버가 없습니다"),
    "simpleLocationNoneHint": MessageLookupByLibrary.simpleMessage(
      "서버는 연결한 후에 표시됩니다",
    ),
    "simpleModeAuto": MessageLookupByLibrary.simpleMessage("자동"),
    "simpleModeAutoDesc": MessageLookupByLibrary.simpleMessage(
      "네트워크 시나리오가 모드를 정합니다",
    ),
    "simpleModeDirect": MessageLookupByLibrary.simpleMessage("직접 연결"),
    "simpleModeDirectDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 없이 트래픽이 흐릅니다",
    ),
    "simpleModeGlobal": MessageLookupByLibrary.simpleMessage("모두 VPN 경유"),
    "simpleModeGlobalDesc": MessageLookupByLibrary.simpleMessage(
      "모든 트래픽이 서버를 거칩니다",
    ),
    "simpleModeRule": MessageLookupByLibrary.simpleMessage("스마트"),
    "simpleModeRuleDesc": MessageLookupByLibrary.simpleMessage(
      "직접 열리지 않는 것만 VPN을 거칩니다",
    ),
    "simpleModeTitle": MessageLookupByLibrary.simpleMessage("모드"),
    "simpleNoExpiry": MessageLookupByLibrary.simpleMessage("종료일 없음"),
    "simpleProviderAnnouncement": MessageLookupByLibrary.simpleMessage(
      "제공자 공지",
    ),
    "simpleServiceBlocked": m165,
    "simpleServiceComingSoon": m166,
    "simpleServiceOriginalsOnly": m167,
    "simpleServiceRestricted": m168,
    "simpleServiceUnavailable": m169,
    "simpleServiceUnsupportedRegion": m170,
    "simpleServicesAfterConnect": MessageLookupByLibrary.simpleMessage(
      "연결 후 확인",
    ),
    "simpleServicesAllGood": MessageLookupByLibrary.simpleMessage("모두 정상"),
    "simpleServicesDirect": MessageLookupByLibrary.simpleMessage(
      "VPN 없을 때처럼 직접",
    ),
    "simpleServicesManual": MessageLookupByLibrary.simpleMessage("수동"),
    "simpleServicesTitle": MessageLookupByLibrary.simpleMessage("서비스"),
    "simpleServicesViaVpn": MessageLookupByLibrary.simpleMessage("VPN 경유"),
    "simpleSpeed4k": MessageLookupByLibrary.simpleMessage("4K 영상에 충분해요"),
    "simpleSpeedAgain": MessageLookupByLibrary.simpleMessage("다시"),
    "simpleSpeedAll": MessageLookupByLibrary.simpleMessage(
      "빠름: 모든 것을 동시에 써도 충분해요",
    ),
    "simpleSpeedChat": MessageLookupByLibrary.simpleMessage("메시지와 음악에 충분해요"),
    "simpleSpeedDirectIdleDesc": m171,
    "simpleSpeedDirectTag": MessageLookupByLibrary.simpleMessage("VPN 없이"),
    "simpleSpeedFailed": MessageLookupByLibrary.simpleMessage(
      "측정하지 못했습니다. 다시 시도해 주세요.",
    ),
    "simpleSpeedHd": MessageLookupByLibrary.simpleMessage("HD 영상에 충분해요"),
    "simpleSpeedIdleDesc": m172,
    "simpleSpeedLevel4k": MessageLookupByLibrary.simpleMessage("4K"),
    "simpleSpeedLevelAll": MessageLookupByLibrary.simpleMessage("모두 동시에"),
    "simpleSpeedLevelChat": MessageLookupByLibrary.simpleMessage("채팅"),
    "simpleSpeedLevelHd": MessageLookupByLibrary.simpleMessage("HD"),
    "simpleSpeedMeasure": MessageLookupByLibrary.simpleMessage("측정"),
    "simpleSpeedMeasuring": MessageLookupByLibrary.simpleMessage("측정 중…"),
    "simpleSpeedSlow": MessageLookupByLibrary.simpleMessage("느림: 페이지도 한참 걸려요"),
    "simpleSpeedTitle": MessageLookupByLibrary.simpleMessage("속도"),
    "simpleSpeedUnit": MessageLookupByLibrary.simpleMessage("Mbps"),
    "simpleStatusConnecting": MessageLookupByLibrary.simpleMessage("연결 중…"),
    "simpleStatusConnectingHint": MessageLookupByLibrary.simpleMessage(
      "가장 좋은 서버를 고르는 중",
    ),
    "simpleStatusNoProfile": MessageLookupByLibrary.simpleMessage("구독 없음"),
    "simpleStatusNoProfileHint": MessageLookupByLibrary.simpleMessage(
      "연결하려면 구독을 추가하세요",
    ),
    "simpleStatusOff": MessageLookupByLibrary.simpleMessage("보호되지 않음"),
    "simpleStatusOffHint": MessageLookupByLibrary.simpleMessage("탭하여 연결"),
    "simpleStatusOn": MessageLookupByLibrary.simpleMessage("보호됨"),
    "simpleStatusPaused": MessageLookupByLibrary.simpleMessage("일시 중지됨"),
    "simpleStatusPausedHint": MessageLookupByLibrary.simpleMessage("신뢰하는 네트워크"),
    "simpleStatusPausedOn": m173,
    "simpleTrafficLeft": m174,
    "simpleTrafficUnlimited": MessageLookupByLibrary.simpleMessage("무제한 트래픽"),
    "simpleTrustedDesc": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서는 VPN이 자동으로 일시 중지되고, 벗어나면 다시 켜집니다.",
    ),
    "simpleTrustedEmpty": MessageLookupByLibrary.simpleMessage("아직 네트워크가 없습니다"),
    "simpleTrustedThisNetwork": MessageLookupByLibrary.simpleMessage("이 네트워크"),
    "simpleTrustedTitle": MessageLookupByLibrary.simpleMessage(
      "내 네트워크에서 일시 중지",
    ),
    "simpleUntilDate": m175,
    "singleAdd": MessageLookupByLibrary.simpleMessage("개별 추가"),
    "singleImport": MessageLookupByLibrary.simpleMessage("개별 가져오기"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "여기에는 링크를 하나만 입력하세요. 여러 개는 목록의 빠른 편집에서 편집하세요",
    ),
    "singleValueTip": m176,
    "size": MessageLookupByLibrary.simpleMessage("크기"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("인증서 검증 건너뛰기"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("건너뛸 도메인"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "건너뛸 도메인 목록에 있는 스니핑된 도메인은 사용하지 않습니다.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("건너뛸 목적지 주소"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("건너뛸 출발지 주소"),
    "slide": MessageLookupByLibrary.simpleMessage("슬라이드"),
    "sliders": MessageLookupByLibrary.simpleMessage("슬라이더"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "sniffer": MessageLookupByLibrary.simpleMessage("스니퍼"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "스니퍼는 TLS, HTTP, QUIC 트래픽에서 도메인을 읽어 규칙이 일치할 수 있게 합니다.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS 포트"),
    "softStyle": MessageLookupByLibrary.simpleMessage("부드러움"),
    "sort": MessageLookupByLibrary.simpleMessage("정렬"),
    "source": MessageLookupByLibrary.simpleMessage("소스"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("출발지 IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("특수 프록시"),
    "specialRules": MessageLookupByLibrary.simpleMessage("특수 규칙"),
    "spectrum": MessageLookupByLibrary.simpleMessage("스펙트럼"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("속도 통계"),
    "speedTestAgain": MessageLookupByLibrary.simpleMessage("다시 테스트"),
    "speedTestAlwaysConfirm": MessageLookupByLibrary.simpleMessage(
      "모든 네트워크에서 확인",
    ),
    "speedTestBudget": MessageLookupByLibrary.simpleMessage("총 데이터 한도"),
    "speedTestBudgetHint": MessageLookupByLibrary.simpleMessage(
      "다운로드, 업로드, 준비 단계가 공유합니다. 네트워크 부가 데이터는 별도입니다.",
    ),
    "speedTestCancelled": MessageLookupByLibrary.simpleMessage("테스트 중지됨"),
    "speedTestComplete": MessageLookupByLibrary.simpleMessage("전체 테스트"),
    "speedTestConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "연결 테스트를 시작할까요?",
    ),
    "speedTestDataUsed": m177,
    "speedTestDone": MessageLookupByLibrary.simpleMessage("테스트 완료"),
    "speedTestDownload": MessageLookupByLibrary.simpleMessage("다운로드"),
    "speedTestIdleDesc": MessageLookupByLibrary.simpleMessage(
      "데이터 한도 내에서 다운로드, 업로드, 지연 시간, 지터를 측정합니다.",
    ),
    "speedTestJitter": MessageLookupByLibrary.simpleMessage("지터"),
    "speedTestLatency": MessageLookupByLibrary.simpleMessage("HTTP 지연 시간"),
    "speedTestLatencyOnly": MessageLookupByLibrary.simpleMessage("지연 시간과 지터만"),
    "speedTestLatencyWarning": MessageLookupByLibrary.simpleMessage(
      "작은 지연 시간 측정 요청만 전송합니다. 이 요청도 데이터를 사용하며 다운로드 및 업로드 속도는 측정하지 않습니다.",
    ),
    "speedTestLimited": MessageLookupByLibrary.simpleMessage(
      "속도가 안정되기 전에 데이터 한도에 도달했습니다. 추정 결과입니다.",
    ),
    "speedTestMeteredTitle": MessageLookupByLibrary.simpleMessage(
      "종량제 네트워크에서 데이터를 사용할까요?",
    ),
    "speedTestMode": MessageLookupByLibrary.simpleMessage("측정 항목"),
    "speedTestMs": m178,
    "speedTestMsUnit": MessageLookupByLibrary.simpleMessage("ms"),
    "speedTestNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "네트워크 또는 경로가 변경되었습니다. 테스트를 다시 시작하세요.",
    ),
    "speedTestOffline": MessageLookupByLibrary.simpleMessage("네트워크 연결 없음"),
    "speedTestOpen": MessageLookupByLibrary.simpleMessage("테스트 열기"),
    "speedTestPartial": MessageLookupByLibrary.simpleMessage(
      "일부 측정에 실패했습니다. 얻은 결과는 유지됩니다.",
    ),
    "speedTestPing": MessageLookupByLibrary.simpleMessage("지연 시간"),
    "speedTestPlatform": MessageLookupByLibrary.simpleMessage("테스트 플랫폼"),
    "speedTestPlatformHint": MessageLookupByLibrary.simpleMessage(
      "서비스 제공자가 가용성과 제한을 정합니다.",
    ),
    "speedTestPlatformUnavailable": MessageLookupByLibrary.simpleMessage(
      "이 플랫폼을 사용할 수 없습니다. 설정에서 다른 플랫폼을 선택하세요.",
    ),
    "speedTestPrivacy": MessageLookupByLibrary.simpleMessage(
      "플랫폼은 테스트 연결의 공인 IP를 볼 수 있습니다. 테스트 데이터는 기기에서 생성되며 개인 파일은 업로드하지 않습니다.",
    ),
    "speedTestReady": MessageLookupByLibrary.simpleMessage("측정 준비 완료"),
    "speedTestRouteCore": MessageLookupByLibrary.simpleMessage("Core 규칙 사용"),
    "speedTestRouteHint": MessageLookupByLibrary.simpleMessage(
      "선택한 VPN 노드가 아닌 플랫폼까지의 현재 경로를 측정할 수 있습니다. DIRECT로 자동 전환하지 않습니다.",
    ),
    "speedTestRouteSystem": MessageLookupByLibrary.simpleMessage("시스템 경로"),
    "speedTestSafetyHint": MessageLookupByLibrary.simpleMessage(
      "종량제이거나 한도를 알 수 없는 네트워크는 항상 확인합니다. Wi-Fi를 무제한으로 간주하지 않습니다.",
    ),
    "speedTestSettings": MessageLookupByLibrary.simpleMessage("테스트 설정"),
    "speedTestStart": MessageLookupByLibrary.simpleMessage("테스트 시작"),
    "speedTestStop": MessageLookupByLibrary.simpleMessage("테스트 중지"),
    "speedTestTitle": MessageLookupByLibrary.simpleMessage("연결 테스트"),
    "speedTestTrafficWarning": m179,
    "speedTestUnknownTitle": MessageLookupByLibrary.simpleMessage(
      "네트워크 데이터 한도를 알 수 없습니다",
    ),
    "speedTestUpload": MessageLookupByLibrary.simpleMessage("업로드"),
    "speedTestWarmup": MessageLookupByLibrary.simpleMessage("연결 준비 중"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "분할 전략을 입력하세요",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSID가 비어 있습니다"),
    "stackMode": MessageLookupByLibrary.simpleMessage("스택 모드"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("스택 트레이스"),
    "standard": MessageLookupByLibrary.simpleMessage("표준"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "표준 모드: 프로필 위에 규칙을 추가합니다",
    ),
    "start": MessageLookupByLibrary.simpleMessage("시작"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("처음부터 시작"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN 시작 중…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("시작 및 백그라운드"),
    "status": MessageLookupByLibrary.simpleMessage("상태"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS를 끄면 시스템 DNS를 사용합니다.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("중지"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN 중지 중…"),
    "strategy": MessageLookupByLibrary.simpleMessage("전략"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("엄격한 라우팅"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "엄격한 라우팅은 DNS 등의 트래픽이 TUN을 우회하지 못하게 하며, IPv6가 꺼져 있으면 이 기기의 IPv6 연결을 차단합니다.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("스타일"),
    "submit": MessageLookupByLibrary.simpleMessage("제출"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("자동"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "제어 문자가 없는 올바른 User-Agent를 입력하세요.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "클라이언트 선택은 기기 식별 정보를 보내지 않습니다.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "요청 클라이언트",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "이 설정은 구독 URL에 적용됩니다. 프록시 링크는 로컬에서 가져옵니다.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "이 구독을 확인하려면 AGE 키를 입력하세요.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("확인된 결과 적용"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage("서버가 인증을 거부하여 클라이언트 선택을 중단했습니다."),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "확인",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "호환되는 구독을 가져오지 못했습니다. 기존 설정은 변경되지 않았습니다.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "현재 입력값을 저장하거나 VPN을 재시작하지 않고 확인합니다. 노드의 연결 가능 여부가 아닌 설정 분석을 확인합니다.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage("가져오기 손실에 대해 다시 묻기"),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "구독 URL 숨기기",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("마지막으로 성공한 클라이언트"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "가져오기 과정에서 원본 데이터 일부가 생략됩니다. 적용 전에 손실 내용을 확인하세요.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("이 클라이언트 사용"),
    "subscriptionCompatibilityPrepared": m180,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core가 이 결과를 분석했습니다. 아직 저장하거나 적용하지 않았습니다.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage("서버가 요청을 제한했습니다. 나중에 다시 시도하세요."),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "구독 URL 표시",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "입력 또는 프로필이 변경되었습니다. 구독을 다시 확인하세요.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "구독 확인 시간이 초과되었습니다.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "호환성",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "연결에 실패하여 클라이언트 선택을 중단했습니다.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "이 구독에 사용할 수 있는 기기 슬롯이 없습니다. 제공업체 계정에서 기기를 삭제한 후 다시 시도하세요.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "이 구독은 기기 등록이 필요합니다. 제공업체의 안내를 따르세요.",
    ),
    "subscriptionDeviceStatus": MessageLookupByLibrary.simpleMessage("기기 상태"),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("구독이 만료됐습니다"),
    "subscriptionExpiresInDays": m181,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "구독이 오늘 만료됩니다",
    ),
    "subscriptionFields": MessageLookupByLibrary.simpleMessage("필드"),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "운영 체제와 기기 모델도 보내기",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage("식별자와 함께 운영 체제 버전과 기기 모델도 보냅니다."),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "이 구독 origin으로 안정적인 가명 기기 ID를 보냅니다. 하드웨어 증명이 아니며 동의는 이 기기에만 저장됩니다.",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "HWID 전송을 끄면 많은 구독이 작동하지 않게 됩니다.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "구독 식별 정보",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "HWID 보내기",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "전역 설정 사용",
    ),
    "subscriptionImportAdd": m182,
    "subscriptionImportAllAdded": m183,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash 구성",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "암호화된 구독",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "프록시 링크",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "알 수 없는 형식",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "구성 섹션",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "이 부분 대신 ReClash 자체 설정이 적용됩니다.",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "제외되는 항목",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "지원되는 서버가 없습니다",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "일부 서버 옵션은 지원되지 않아 제외됩니다",
    ),
    "subscriptionImportPartial": m184,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "업로드·다운로드 속도가 없습니다",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "지원되지 않는 프로토콜",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "지원되지 않는 전송 방식",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "이 구독에 대해 다시 묻지 않기",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage("다른 항목이 옮겨지지 않게 되면 다시 묻습니다."),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "일부는 옮겨지지 않습니다",
    ),
    "subscriptionImportShowAll": m185,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "추가되지 않음",
    ),
    "subscriptionImportSourceFormat": m186,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("구독 정보"),
    "subscriptionInspector": MessageLookupByLibrary.simpleMessage("구독 검사기"),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("개발"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("프로모"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("테스트"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage("구독 알림"),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("구독"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage("계정"),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "요금제 구매",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "트래픽 구매",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage("로고 URL"),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage("지원"),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage("웹사이트"),
    "subscriptionReceivedAt": MessageLookupByLibrary.simpleMessage("수신 시각"),
    "subscriptionTrafficLow": m187,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "제공자 업데이트 간격 사용",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "sudo 비밀번호를 입력하세요",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("일시 중지됨…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("프로필 전환"),
    "sync": MessageLookupByLibrary.simpleMessage("동기화"),
    "system": MessageLookupByLibrary.simpleMessage("시스템"),
    "systemApp": MessageLookupByLibrary.simpleMessage("시스템 앱"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "tab": MessageLookupByLibrary.simpleMessage("탭"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("탭 애니메이션"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("아이콘을 눌러 다시 시도"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("눌러서 허용"),
    "target": MessageLookupByLibrary.simpleMessage("대상"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 동시 연결"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "이 기기에서 Telegram을 열 수 없습니다.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Telegram 열기"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage("브라우저에서 열기"),
    "testInterval": MessageLookupByLibrary.simpleMessage("테스트 간격"),
    "testUrl": MessageLookupByLibrary.simpleMessage("테스트 URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("사용할 때 테스트"),
    "textScale": MessageLookupByLibrary.simpleMessage("글자 크기 조절"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "앱의 글자가 이렇게 표시됩니다",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("테마"),
    "themeColor": MessageLookupByLibrary.simpleMessage("테마 색상"),
    "themeMode": MessageLookupByLibrary.simpleMessage("테마 모드"),
    "tight": MessageLookupByLibrary.simpleMessage("좁게"),
    "time": MessageLookupByLibrary.simpleMessage("시간"),
    "timeout": MessageLookupByLibrary.simpleMessage("시간 초과"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("틴트"),
    "tip": MessageLookupByLibrary.simpleMessage("안내"),
    "tk": MessageLookupByLibrary.simpleMessage("투르크멘어"),
    "toggle": MessageLookupByLibrary.simpleMessage("전환"),
    "tolerance": MessageLookupByLibrary.simpleMessage("허용 오차"),
    "tools": MessageLookupByLibrary.simpleMessage("도구"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("작업"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage("섹션을 선택하거나 설정을 검색하세요"),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "모든 활성 연결이 종료됩니다. 계속할까요?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("작업 완료"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("구성"),
    "toolsData": MessageLookupByLibrary.simpleMessage("리소스 및 데이터"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage("일치하는 설정이나 작업이 없습니다"),
    "toolsInformation": MessageLookupByLibrary.simpleMessage("정보 및 디버깅"),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("최근 사용 항목"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "먼저 인증을 활성화하세요",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "먼저 외부 컨트롤러를 활성화하세요",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "이 작업을 사용하려면 코어를 시작하세요",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "먼저 사용자 지정 네트워크 인터페이스를 선택하세요",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "먼저 MIPS 네트워크 스택을 선택하세요",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "먼저 DNS 페이지에서 이 재정의 항목을 추가하세요",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "먼저 WebDAV를 설정하세요",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("진단"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("고정"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("고정됨"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage("코어 다시 시작"),
    "toolsResults": m188,
    "toolsRun": MessageLookupByLibrary.simpleMessage("실행"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("섹션"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("설정"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("고정 해제"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage("리소스 업데이트"),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "규칙과 스크립트를 업데이트하면 구성이 다시 적용되어 연결에 영향을 줄 수 있습니다. 계속할까요?",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("트래픽 충전"),
    "torch": MessageLookupByLibrary.simpleMessage("손전등"),
    "total": MessageLookupByLibrary.simpleMessage("합계"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("다운로드량"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("전체 트래픽"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("업로드량"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy 포트"),
    "traffic": MessageLookupByLibrary.simpleMessage("트래픽"),
    "trafficPeak": m189,
    "trafficTotal": m190,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("트래픽 사용량"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage("번역 수정 제안하기"),
    "transport": MessageLookupByLibrary.simpleMessage("전송"),
    "transportHeaders": m191,
    "trayIcon": MessageLookupByLibrary.simpleMessage("트레이 아이콘"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("컬러"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("검정"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("흰색"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("신뢰할 수 있는 네트워크"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 등록한 네트워크에 연결되어 있으면 VPN이 일시 중지됩니다",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "신뢰하는 네트워크 · VPN 일시 중지됨",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN 권한을 얻지 못해 끄기로 되돌렸습니다.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("TUN은 관리자 모드에서만 작동합니다."),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 추가한 항목은 모든 프로필의 TUN 설정을 대체합니다. 추가하지 않은 항목은 프로필 자체 설정을 유지합니다. 사용자 지정 프로필이 직접 추가한 항목이 우선합니다.",
    ),
    "tunSetupApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helper 허용",
    ),
    "tunSetupConfirm": MessageLookupByLibrary.simpleMessage("설정"),
    "tunSetupDone": MessageLookupByLibrary.simpleMessage("TUN이 켜졌습니다"),
    "tunSetupInstallTitle": MessageLookupByLibrary.simpleMessage("TUN 설정"),
    "tunSetupInstantStart": MessageLookupByLibrary.simpleMessage(
      "그 후에는 로그인할 때도 TUN이 바로 시작됩니다",
    ),
    "tunSetupLater": MessageLookupByLibrary.simpleMessage("나중에"),
    "tunSetupLinuxInstall": MessageLookupByLibrary.simpleMessage(
      "시스템의 모든 트래픽을 ReClash로 보내려면 TUN에 시스템 Helper가 필요합니다. 네트워크 권한만으로 Core를 시작하는 systemd 서비스입니다.",
    ),
    "tunSetupLinuxScope": MessageLookupByLibrary.simpleMessage(
      "Helper는 검증된 ReClash Core만 실행하며 네트워크 권한만 부여합니다",
    ),
    "tunSetupLinuxUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash가 업데이트되었습니다. 계속 작동하려면 TUN Helper도 함께 업데이트해야 합니다.",
    ),
    "tunSetupMacosInstall": MessageLookupByLibrary.simpleMessage(
      "TUN에는 ReClash Helper가 필요합니다. macOS에서 한 번만 허용하도록 요청합니다.",
    ),
    "tunSetupOnceConfirm": MessageLookupByLibrary.simpleMessage(
      "이 버전에서는 Windows 확인을 한 번 요청합니다",
    ),
    "tunSetupOncePassword": MessageLookupByLibrary.simpleMessage(
      "이 버전에서는 관리자 비밀번호가 한 번 필요합니다",
    ),
    "tunSetupPasswordPrivacy": MessageLookupByLibrary.simpleMessage(
      "비밀번호는 시스템 창에서만 입력하세요. ReClash는 비밀번호를 보지 않습니다.",
    ),
    "tunSetupUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "TUN을 사용할 수 없습니다",
    ),
    "tunSetupUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "TUN Helper 업데이트",
    ),
    "tunSetupWaiting": MessageLookupByLibrary.simpleMessage(
      "시스템 창에서 확인을 기다리는 중…",
    ),
    "tunSetupWindowsInstall": MessageLookupByLibrary.simpleMessage(
      "시스템의 모든 트래픽을 ReClash로 보내려면 TUN에 ReClash Service가 필요합니다. 네트워크 어댑터에 필요한 권한으로 Core를 실행하는 Windows 서비스입니다.",
    ),
    "tunSetupWindowsScope": MessageLookupByLibrary.simpleMessage(
      "서비스는 검증된 ReClash Core만 실행하며 사용자 계정의 요청만 받습니다",
    ),
    "tunSetupWindowsUpdate": MessageLookupByLibrary.simpleMessage(
      "ReClash가 업데이트되었습니다. TUN이 계속 작동하려면 ReClash Service도 함께 업데이트해야 합니다.",
    ),
    "tunSetupWithoutTun": MessageLookupByLibrary.simpleMessage("TUN 없이"),
    "turnOff": MessageLookupByLibrary.simpleMessage("끄기"),
    "turnOn": MessageLookupByLibrary.simpleMessage("켜기"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP 릴레이 모드"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP 시간 제한"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 시간 제한은 초 단위이며 gvisor, system, mixed 스택에서만 작동합니다.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("최고"),
    "undo": MessageLookupByLibrary.simpleMessage("실행 취소"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("통합 지연"),
    "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "알 수 없는 네트워크 오류",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("이전 크기로 복원"),
    "unnamed": MessageLookupByLibrary.simpleMessage("이름 없음"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("창 고정 해제"),
    "update": MessageLookupByLibrary.simpleMessage("업데이트"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage("자동 설치 허용"),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash가 검증되고 조건에 맞는 안정 버전을 매번 묻지 않고 설치할 수 있습니다. VPN을 끊지는 않습니다. Android에서 설치 확인을 요청할 수 있습니다.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "자동 설치를 허용할까요?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage("자동으로 설치"),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage("다운로드 취소"),
    "updateChannel": MessageLookupByLibrary.simpleMessage("업데이트 채널"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("사전 릴리스"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage("정식 릴리스"),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage("자동으로 확인"),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "업데이트를 확인할 수 없습니다",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "연결을 확인한 후 다시 시도하세요.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage("업데이트 확인 중…"),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("창 닫기"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android의 승인이 필요합니다. 계속하면 시스템 확인 화면이 열립니다.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Android에서 확인하세요",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "백그라운드에서 계속",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage("설치 계속"),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage("최신 버전입니다"),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "이 플랫폼에서는 ReClash가 릴리스 페이지를 엽니다. 업데이트를 직접 다운로드하고 설치하세요.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "이 기기용 검증 가능한 다운로드가 없습니다. 릴리스 페이지에서 패키지를 선택하세요.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage("연결 끊고 설치"),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage("수동 설치 유지"),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage("업데이트 다운로드"),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage("다시 다운로드"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "업데이트를 다운로드할 수 없습니다",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "다운로드한 부분은 저장되었습니다. 연결을 확인하고 재개하세요.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("확인"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "패키지 설치 프로그램을 시작할 수 없습니다",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android가 설치를 완료하지 못했습니다. 준비되면 다시 시도하세요.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("지금 설치"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage("업데이트 설치 완료"),
    "updateInstalledVersion": m192,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android가 설치를 마무리하고 있습니다. 이 과정에서 ReClash가 닫힐 수 있습니다.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage("업데이트 설치 중"),
    "updateMinutes": m193,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("나중에"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "릴리스 노트가 없습니다.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage("업데이트가 있습니다"),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Android 설정 열기",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage("기기용 빌드"),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("다운로드 크기"),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage("패키지 검증"),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "다운로드 후 설치 전에 검증합니다",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "무결성, 앱 식별 정보 및 서명 검증 완료",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("일시 중지"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage("다운로드 일시 중지됨"),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "ReClash가 이 출처의 앱을 설치하도록 허용한 다음 돌아와 계속하세요.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Android 권한이 필요합니다",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "확인, 다운로드, 설치를 각각 설정하세요.",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "설정을 저장하지 못했습니다. 다시 저장해 주세요. 자동 설치는 활성화되지 않았습니다.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage("업데이트 설정"),
    "updatePreload": MessageLookupByLibrary.simpleMessage("Wi-Fi로 미리 다운로드"),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage("설치 준비 완료"),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage("릴리스 상세 정보"),
    "updateRemainingTime": m194,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage("다운로드 재개"),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("재개"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("다시 확인"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage("설치 재시도"),
    "updateSeconds": m195,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "전체 릴리스 노트 보기",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage("모든 변경 사항 보기"),
    "updateTitle": MessageLookupByLibrary.simpleMessage("업데이트"),
    "updateTransferSpeed": m196,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "다운로드한 업데이트의 무결성을 확인할 수 없습니다.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "파일, 버전 또는 서명이 검증을 통과하지 못했습니다. 새로 다운로드하여 다시 시도하세요.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "이 패키지는 설치할 수 없습니다",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage("업데이트 검증 중"),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "설치 중 ReClash가 잠시 닫힙니다. 연결을 중단해도 될 때만 끊으세요.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage("VPN이 아직 켜져 있습니다"),
    "upload": MessageLookupByLibrary.simpleMessage("업로드"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("업로드 대역폭"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL 스킴"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("동작"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("구독 추가"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "구독 URL을 추가합니다. 이름은 선택 사항입니다.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "암호화 링크를 인증하지 못했습니다. 손상되었거나 다른 키를 사용할 수 있습니다.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("링크 만들기"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("앱 닫기"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "설정한 종료 동작을 사용합니다.",
    ),
    "urlSchemeConfigCounts": m197,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "YAML 또는 JSON 설정을 붙여넣으세요",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage("설정 내용"),
    "urlSchemeConfirmMessage": m198,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage("외부 앱 명령"),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "외부 연결 및 종료 명령은 확인을 요청합니다.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("연결"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 프로필로 연결합니다.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("연결"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage("내용 형식"),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "변환하면 일부 내용이 제외됩니다. 가져올 때 변경 사항을 검토하고 승인하세요.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "링크를 복사하지 못했습니다. 다시 시도하세요.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("링크 복사"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "링크를 전달하지 못했거나 대기열이 가득 찼습니다. 현재 동작이 끝난 뒤 다시 시도하세요.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("연결 해제"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "프로필을 유지하고 연결을 중지합니다.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage("내장 설정"),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage("예시 프로필"),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("형식"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "링크 형식입니다. 자리표시자를 URL이나 데이터로 바꾸세요.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("설정 가져오기"),
    "urlSchemeImportConfirm": m199,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "링크에 YAML 또는 JSON 설정을 포함합니다.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage("링크 확인"),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "앱 또는 프로필 링크를 붙여넣으세요",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "확인은 이 기기에서만 진행됩니다. 링크를 열거나 구독을 다운로드하거나 프로필을 가져오지 않습니다.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "링크 구조가 유효합니다. 구독 가용성과 코어 검증은 가져올 때 확인합니다.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage("확인 결과"),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage("설정 설치"),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash 클라이언트의 공통 구독 링크 형식을 사용합니다.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "내장 설정이 유효한 UTF-8 Base64 데이터가 아닙니다.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "링크 형식이 잘못되었습니다. 구조와 퍼센트 인코딩을 확인하세요.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "프로필 이름은 제어 문자 없이 64자 이내로 입력하세요.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "유효한 HTTP 또는 HTTPS 구독 URL을 입력하세요.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "링크에 구독 URL 또는 설정이 없습니다.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "아무 동작도 실행되지 않았습니다.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("앱 표시"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash를 전면에 표시합니다.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("매개변수"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "클립보드를 읽지 못했습니다. 링크를 직접 붙여넣으세요.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("링크"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "URL이나 설정을 입력하면 링크가 만들어집니다.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "링크에 토큰이나 인증 정보가 포함될 수 있습니다. 공유에 주의하세요.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage("프록시 공유 링크"),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage("링크가 인식되었습니다"),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "외부 연결 명령을 사용하기 전에 연결 설정을 완료하세요.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "지원하는 가져오기 링크",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("연결 전환"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "중지 상태면 연결하고 실행 중이면 해제합니다.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "링크에 중첩된 래퍼가 너무 많습니다.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "링크가 4 MB 또는 내장 설정이 2 MB를 초과합니다.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "이 링크 명령은 지원되지 않습니다.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "이 암호화 버전은 지원되지 않습니다. 일반 구독 링크를 요청하세요.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("예시 사용"),
    "urlTip": m200,
    "useHosts": MessageLookupByLibrary.simpleMessage("hosts 사용"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("시스템 hosts 사용"),
    "usedShort": MessageLookupByLibrary.simpleMessage("사용"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("사용한 트래픽"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("사용자 이름"),
    "uz": MessageLookupByLibrary.simpleMessage("우즈베크어"),
    "value": MessageLookupByLibrary.simpleMessage("값"),
    "view": MessageLookupByLibrary.simpleMessage("보기"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("가상 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("선명"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN 관련 구성 변경이 감지되었습니다",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN은 VpnService를 통해 모든 시스템 트래픽을 자동으로 라우팅합니다.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("흐림 효과"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage("카드 불투명도"),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("어둡게"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("이미지 조정"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage("사용자 지정 배경 사용"),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("이미지 맞춤"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("맞추기"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("채우기"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("늘이기"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "가로 위치",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "올바른 PNG, JPEG, WebP 또는 SVG 이미지를 선택하세요.",
    ),
    "wallpaperImageLabel": m201,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("구도"),
    "wallpaperLibraryFull": m202,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("이미지 불투명도"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("가독성"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("이미지 삭제"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("효과 초기화"),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage("구도 초기화"),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "배경을 저장하지 못했습니다. 이전 배경은 유지됩니다.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("배율"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG 또는 WebP · 최대 20 MB",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("사용자 지정 배경"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "20 MB 이하, 5,000만 화소 이하의 이미지를 선택하세요.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "이미지를 사용할 수 없음",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage("세로 위치"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV 구성"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("웹 패널"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("접근"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "패널 접근 종료됨",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage("앱 내"),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage("브라우저"),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("꺼짐"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "접근은 로컬에서만 가능하며 비밀 값으로 보호됩니다. 패널을 열어도 저장된 외부 컨트롤러 설정은 변경되지 않습니다.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "패널 설정을 적용하지 못했습니다.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "유효한 패널 압축 파일이 아닙니다.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "코어가 인증 정보를 거부했습니다. 패널을 다시 여세요.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "브라우저 접근은 종료하거나 ReClash를 종료할 때까지 유지됩니다",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "다른 패널 작업이 진행 중입니다.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "패널 작업이 취소되었습니다.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "체크섬이 고정된 릴리스와 일치하지 않습니다.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "코어가 준비되지 않았습니다.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "코어를 관리하는 로컬 웹 패널",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "패널을 다운로드하지 못했습니다. 다시 시도하세요.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "패널 다운로드 중",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "패널을 닫으면 접근이 종료됩니다",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage("패널 접근 종료"),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "패널 압축 해제 중",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("패널"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage("패널 설치"),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "선택한 패널은 처음 열 때 다운로드됩니다. 고정된 릴리스를 SHA-256으로 검증합니다.",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "브라우저를 열지 못했습니다.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage("활성 패널 세션 없음"),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "패널을 열기 전에 프로필을 선택하세요.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage("설치되지 않음"),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("패널 열기"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "브라우저에서 열기",
    ),
    "webDashboardReinstall": MessageLookupByLibrary.simpleMessage("대시보드 다시 설치"),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("새로고침"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "제공업체에서 대시보드 접근을 비활성화했습니다.",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "안전 모드에서는 패널 접근이 비활성화됩니다.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "패널 파일을 안전하게 읽거나 교체하지 못했습니다.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "패널 압축 파일이 허용 크기를 초과합니다.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "코어가 이 패널을 제공하지 않습니다.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage("다운로드 검증 중"),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("버전"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("화이트리스트 모드"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("시스템에 기록"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "시스템에 기록하면 시스템 시계도 설정합니다. Android에서는 무시됩니다.",
    ),
    "yearsAgo": m203,
    "yearsAgoShort": m204,
    "yes": MessageLookupByLibrary.simpleMessage("예"),
    "zhCN": MessageLookupByLibrary.simpleMessage("중국어 간체"),
  };
}
