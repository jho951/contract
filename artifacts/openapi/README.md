# OpenAPI Artifacts

`artifacts/openapi`는 현재 서비스 계약 중 기계 판독 가능한 HTTP API 문서를 둔다.

## 현재 파일
- `gateway-service.public.v1.yaml`: Gateway가 외부에 소유하는 public `/v1/**` edge 계약
- `auth-service.upstream.v1.yaml`: Auth-service upstream `/auth/**`, internal account, session 검증 계약
- `authz-service.upstream.v1.yaml`: Authz-service upstream `/permissions/internal/admin/verify`와 운영 endpoint 계약
- `user-service.v1.yaml`: User-service public/internal 사용자 계약
- `editor-service.v1.yaml`: Editor-service upstream `/documents/**`, `/admin/**`, actuator 계약
- `monitoring-service.ops.v1.yaml`: Monitoring stack의 operator-facing health/readiness endpoint 계약

## 비고
- `redis-service`는 HTTP API를 노출하지 않으므로 OpenAPI artifact를 만들지 않는다.
- Frontend repo인 `editor-page`, `explain-page`는 API 소비자이며 API provider가 아니므로 이 디렉터리에 OpenAPI를 두지 않는다.
- Gateway public route와 backend upstream route는 분리해서 관리한다. Gateway가 `/v1/**`를 소유하고, backend는 upstream path를 소유한다.
