# ADR-0013: 최종 권한 판단과 Capability Truth는 `authz-service`가 소유한다

- Status: Accepted
- Date: 2026-04-27

## 배경

인증, 프로필, 편집 같은 여러 서비스가 권한 관련 정보를 다루더라도, 최종 allow/deny 판단의 진실이 여러 곳에 흩어지면 권한 drift가 생긴다. 특히 역할 보유 사실, 공개 여부, 실제 기능 집행을 같은 책임으로 섞으면 경계가 흐려진다.

## 결정

- 최종 권한 판단의 기준 서비스는 `authz-service`로 둔다.
- capability truth는 `authz-service`가 소유한다.
- 공개 여부나 프로필 표현은 `user-service`가 소유한다.
- 실제 저장, 수정, 삭제 같은 기능 집행은 소비자 도메인 서비스가 최종 책임을 진다.
- Gateway는 외부 요청을 정규화하고, 필요 시 `authz-service` 판단을 우선 적용한다.

## 결과

- 권한의 진실, 공개 범위, 기능 집행 책임을 분리할 수 있다.
- 서비스별 권한 해석이 서로 엇갈리는 문제를 줄일 수 있다.
- `auth-service`는 인증과 세션, `authz-service`는 권한 상태와 정책 판단이라는 역할이 더 명확해진다.
- 권한 모델 변경은 `authz-service` 문서와 Gateway 연계 문서를 함께 검토해야 한다.

## 연관 문서

- [../services/server/authz/v2.md](../services/server/authz/v2.md)
- [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
- [../conventions/shared/headers.md](../conventions/shared/headers.md)
