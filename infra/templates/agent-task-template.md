# Agent Task Template


## Contract Source
- Repo: `https://github.com/jho951/service-contract`
- Commit SHA: `<contract-sha>`
- Referenced Docs:
  - `conventions/coding/rest-api-design.md`
  - `conventions/shared/routing.md`
  - `conventions/shared/headers.md`
  - `conventions/shared/common-guidelines.md`
  - `conventions/coding/coding-conventions.md`
  - `conventions/shared/security.md`
  - `services/server/auth/v2.md`
  - `services/server/auth/troubleshooting.md`
  - `services/artifacts/openapi/v1/auth-service.yaml`
  - `services/server/authz/v2.md`
  - `services/server/authz/troubleshooting.md`
  - `services/artifacts/openapi/v1/authz-service.yaml`
  - `services/server/redis/troubleshooting.md`
  - `services/server/redis/v2.md`
  - `services/server/monitoring/troubleshooting.md`
  - `services/server/monitoring/v2.md`
  - `conventions/shared/audit.md`
  - `services/registry/service-ownership.md`
  - `services/registry/adoption-matrix.md`
  - `services/server/user/troubleshooting.md`
  - `services/server/user/v2.md`
  - `services/server/gateway/troubleshooting.md`
  - `services/server/gateway/v2.md`
  - `services/server/editor/troubleshooting.md`
  - `services/server/editor/v2.md`
  - `conventions/shared/env.md`
  - `services/artifacts/openapi/v1/<service>.yaml`

## Impacted Services
- `gateway-service (main)`:
- `auth-service (main)`:
- `authz-service (main)`:
- `user-service (main)`:
- `redis-service (main)`:
- `editor-service (main)`:
- `monitoring-service (main)`:
- `Editor-page (master)`:
- `Explain-page (main)`:

## Change Plan
1. contract 문서/OpenAPI 갱신
2. 서비스 구현 반영
3. `contract.lock.yml` 업데이트
4. CI 계약 검증/스모크 확인

## Validation
- 실행 명령:
  - `<test-or-smoke-command-1>`
  - `<test-or-smoke-command-2>`
- 결과 요약:
  - `<pass/fail + 핵심 로그>`

## PR Body Snippet
```md
Contract SHA: <contract-sha>
Contract Lock: contract.lock.yml
Contract Areas: routing, headers, security, auth, auth-v2, authz, authz-v2, authz-rbac, authz-audit, authz-policy, authz-policy-engine, authz-delegation, authz-versioning, authz-introspection, authz-cache, authz-boundaries, user, user-visibility, redis, redis-keys, redis-security, redis-ops, monitoring, monitoring-targets, monitoring-security, monitoring-ops, audit, auth-ops, auth-errors, authz-ops, authz-errors, user-ops, user-errors, env, openapi
Validation: <commands/results>
```
