# ADR-0002: Gateway가 Public Edge와 외부 Backend 진입점을 소유한다

- Status: Accepted
- Date: 2026-03-25

## 배경

브라우저, 외부 클라이언트, 내부 서비스가 각 backend를 직접 호출하면 인증 방식, 버전 해석, route ownership이 분산된다. 서비스마다 public surface를 따로 노출하면 보안 경계와 운영 규칙을 일관되게 유지하기 어렵다.

## 결정

- 외부 backend 진입점은 `gateway-service` 하나로 둔다.
- public API versioning은 Gateway가 소유한다.
- backend 서비스는 upstream/internal 계약만 소유한다.
- frontend 소비자는 backend 개별 서비스가 아니라 Gateway만 직접 호출한다.
- route rewrite, passthrough, public-to-upstream 매핑 책임은 Gateway 축에서 관리한다.

## 결과

- public API 변화는 Gateway 검토를 반드시 거치게 된다.
- backend 서비스는 외부 공개 surface보다 도메인 로직과 upstream 계약에 집중할 수 있다.
- 브라우저 인증, CORS, public entry 정책을 Gateway 한 곳에서 통제할 수 있다.
- 서비스별 상세 API shape는 이 ADR이 아니라 각 서비스 문서와 OpenAPI artifact가 소유한다.

## 연관 문서

- [../conventions/shared/routing.md](../conventions/shared/routing.md)
- [../conventions/coding/rest-api-design.md](../conventions/coding/rest-api-design.md)
- [../services/server/gateway/readme.md](../services/server/gateway/readme.md)
