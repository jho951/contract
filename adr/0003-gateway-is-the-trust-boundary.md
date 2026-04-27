# ADR-0003: Gateway를 인증/신뢰 경계로 둔다

- Status: Accepted
- Date: 2026-04-27

## 배경

외부 요청의 Bearer token, cookie, custom header를 downstream 서비스가 직접 해석하면 각 서비스가 서로 다른 인증 기준을 갖게 된다. 그러면 trust boundary가 분산되고, 내부 서비스가 어떤 입력을 신뢰해야 하는지도 흔들린다.

## 결정

- Gateway를 외부 요청과 내부 서비스 사이의 인증/신뢰 경계로 둔다.
- Gateway가 먼저 요청 채널과 인증 수단을 판정한다.
- Gateway는 외부에서 들어온 민감 인증 헤더를 정리한 뒤, 검증 성공 시 내부에서 신뢰할 값만 재주입한다.
- downstream 서비스는 Gateway가 재주입한 내부 JWT와 trusted header만 신뢰한다.
- downstream 서비스는 외부 cookie나 외부 Bearer token을 직접 신뢰하지 않는다.

## 결과

- 인증 규칙과 trusted header 규칙이 서비스별로 흩어지지 않는다.
- auth/authz/user/editor 같은 downstream 서비스의 보안 모델이 단순해진다.
- 외부 입력 정규화, 내부 사용자 문맥 전달, 관리자 경로 보호를 Gateway 한 곳에서 일관되게 다룰 수 있다.
- Gateway 장애나 설정 오류의 영향 범위가 크므로 관련 변경은 공통 계약 문서를 함께 갱신해야 한다.

## 연관 문서

- [../conventions/shared/security.md](../conventions/shared/security.md)
- [../conventions/shared/auth-channel-policy.md](../conventions/shared/auth-channel-policy.md)
- [../conventions/shared/headers.md](../conventions/shared/headers.md)
