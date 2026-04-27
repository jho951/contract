# ADR-0009: 브라우저 클라이언트는 Backend 개별 서비스가 아니라 Gateway만 직접 호출한다

- Status: Accepted
- Date: 2026-04-27

## 배경

브라우저가 `auth-service`, `user-service`, `editor-service` 같은 backend 개별 서비스와 직접 통신하면 인증 transport, CORS, cookie 처리, public URL 관리가 분산된다. 프론트별로 호출 규칙이 갈라지면 public contract도 레포마다 다른 방식으로 해석될 수 있다.

## 결정

- 브라우저 클라이언트의 직접 backend 진입점은 `gateway-service` 하나로 고정한다.
- frontend는 backend 개별 서비스의 private/upstream 주소를 직접 사용하지 않는다.
- 브라우저 인증 transport는 Gateway 경유 cookie/session 흐름을 기준으로 둔다.
- frontend 레포의 API base URL 정책은 Gateway public origin 기준으로만 해석한다.

## 결과

- frontend와 backend 사이의 public surface가 Gateway 한 곳으로 수렴한다.
- backend 개별 서비스 주소, private DNS, runtime topology 변경이 브라우저에 직접 새지 않는다.
- 인증과 public route 규칙의 drift를 줄일 수 있다.
- frontend contract 변경은 Gateway 소비 계약과 함께 검토해야 한다.

## 연관 문서

- [../services/client/editor/README.md](../services/client/editor/README.md)
- [../services/client/explain/README.md](../services/client/explain/README.md)
- [0002-gateway-owns-public-edge.md](0002-gateway-owns-public-edge.md)
- [0003-gateway-is-the-trust-boundary.md](0003-gateway-is-the-trust-boundary.md)
