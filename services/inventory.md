# Service Inventory

현재 운영 범위에 들어가는 서비스와 각 서비스의 canonical OpenAPI/Swagger 링크를 정리한다.

이 문서의 링크는 contract repo 기준 OpenAPI artifact를 가리킨다.
runtime Swagger UI URL은 구현 레포가 별도로 소유하며, 이 contract repo에서는 고정 주소를 source of truth로 관리하지 않는다.

## API / Runtime Inventory

| Service | Type | Status | Runtime Baseline | Contract OpenAPI / Swagger |
| --- | --- | --- | --- | --- |
| `gateway-service` | gateway | adopted | public edge, `8080` | [artifacts/openapi/v1/public.yaml](artifacts/openapi/v1/public.yaml) |
| `auth-service` | backend API | adopted | auth/session/token, `8081` | [artifacts/openapi/v1/auth-service.yaml](artifacts/openapi/v1/auth-service.yaml) |
| `authz-service` | backend API | adopted | permission/admin verify, `8084` | [artifacts/openapi/v1/authz-service.yaml](artifacts/openapi/v1/authz-service.yaml) |
| `user-service` | backend API | adopted | user domain, `8082` | [artifacts/openapi/v1/user-service.yaml](artifacts/openapi/v1/user-service.yaml) |
| `editor-service` | backend API | adopted | document/block domain, `8083` | [artifacts/openapi/v1/editor-service.yaml](artifacts/openapi/v1/editor-service.yaml) |
| `monitoring-service` | operator API | adopted | Grafana/Prometheus/Loki stack, Grafana host default `3005` | [artifacts/openapi/v1/monitoring-service.yaml](artifacts/openapi/v1/monitoring-service.yaml) |
| `redis-service` | infra runtime | adopted | Redis runtime, `6379` | 없음 |
| `editor-page` | frontend consumer | partial | Vite/React UI, Gateway 소비자 | 없음 |
| `explain-page` | frontend consumer | partial | Next.js UI, Gateway 소비자 | 없음 |

## Notes

- `gateway-service`만 public `/v1/**` edge contract를 소유한다.
- backend 서비스 OpenAPI는 public route가 아니라 upstream/internal contract를 설명한다.
- `redis-service`는 HTTP API를 노출하지 않으므로 OpenAPI/Swagger artifact가 없다.
- frontend 레포는 API provider가 아니라 contract consumer이므로 Swagger를 소유하지 않는다.
- `audit-log`는 현재 runtime service inventory가 아니라 module/publish 대상이므로 이 표에서 제외한다.

## Source of Truth

- 서비스 목록과 상태: [repositories.yml](repositories.yml)
- 개별 서비스 메모: [README.md](README.md)
- OpenAPI artifact: [artifacts/openapi](artifacts/openapi)
