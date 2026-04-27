# Service Contract

## 원칙
- 공통 계약과 충돌하는 로컬 관례는 허용하지 않는다.
- 새 규칙을 추가할 때는 서비스 구현보다 먼저 contract 문서를 갱신한다.

## 의의

```txt
Frontend -> Gateway -> Auth / Authz / User / Editor / Redis / Monitoring
```

서비스가 여러 레포로 나뉘면 각 팀/서비스가 서로 다른 이해관계가 생깁니다.

이 레포는 위 서비스들이 같은 기준을 보도록 만드는 단일 기준점이다.

## 핵심 원칙
- Public API versioning(예: `v1`)은 Gateway가 소유합니다.
- service는 자기 upstream/internal API만 소유합니다.
- coding, pipeline, versioning 운영 규칙은 `conventions`에 둔다.
- REST API, routing, security, env, terraform 공통 기술 규칙은 `conventions/shared`에 둔다.
- 기술적 아키텍처 결정은 `adr`에 둔다.
- 도메인, 공통 라이브러리, platform 사용 현황, 현재 운영 상태 요약은 `infra`에 둔다.
- 기계가 검증할 schema는 `services/artifacts/schemas`에 둔다.
- 서비스별 계약 메모는 `services/server/*`, `services/client/*`에 둔다.
- OpenAPI 파일은 `services/artifacts/openapi`에 둔다.
- Terraform 공통 구조는 `conventions/shared/terraform.md`에 둔다.
- 미래 기능은 현재 계약처럼 쓰지 않고 draft/planned로 표시한다.

## 디렉토리 지도
| 위치                                                                           | 역할                                                             |
|------------------------------------------------------------------------------|----------------------------------------------------------------|
| [services](services/README.md) | 서비스별 계약 메모, client/server 분류, artifact 허브 |
| [services/registry](services/registry/README.md) | repository 목록, adoption 상태, 운영 절차 |
| [conventions](conventions/README.md) | coding, pipeline, versioning 축 운영 규칙 허브 |
| [conventions/shared](conventions/shared/README.md) | 모든 서비스가 따르는 공통 기술 규칙 |
| [adr](adr/README.md) | 기술적 아키텍처 결정 기록 |
| [infra](infra/README.md) | 도메인, 공통 라이브러리, platform 사용, 현재 운영 상태 요약 |
| [conventions/pipeline/env](conventions/pipeline/env/README.md) | 서비스 repo compose validation용 공통 `.env.ci.dev` / `.env.ci.prod` |
| [services/server/gateway](services/server/gateway/troubleshooting.md) | public route, 인증 프록시, header 재주입 |
| [services/server/auth](services/server/auth/troubleshooting.md) | 로그인, refresh, SSO, session, JWT/JWKS |
| [services/server/authz](services/server/authz/troubleshooting.md) | 권한 판단, RBAC, policy, introspection |
| [services/server/user](services/server/user/troubleshooting.md) | 사용자 프로필, 상태, visibility |
| [services/server/editor](services/server/editor/troubleshooting.md) | 문서/블록 편집 도메인 계약 |
| [services/client/editor](services/client/editor/README.md) | editor UI의 Gateway 소비 계약 |
| [services/client/explain](services/client/explain/README.md) | explain UI의 Gateway/SSO 소비 계약 |
| [services/server/redis](services/server/redis/troubleshooting.md) | Redis key, cache, ops 계약 |
| [services/server/monitoring](services/server/monitoring/troubleshooting.md) | metrics, logs, dashboard, alert 운영 계약 |
| [services/artifacts/schemas](services/artifacts/schemas) | 공통 JSON Schema |
| [services/artifacts/openapi](services/artifacts/openapi) | OpenAPI 계약 |
| [infra/github](infra/github) | 서비스 레포에 복사할 GitHub Actions workflow 템플릿 |
| [infra/templates](infra/templates/README.md) | 서비스별 `contract.lock.yml`, 문서, compose/env 템플릿 |
| [infra/scripts](infra/scripts/README.md) | contract 검증, deploy wrapper, service repo/single-EC2 helper 스크립트 |

## 읽는 순서
1. [services/registry/adoption-matrix.md](services/registry/adoption-matrix.md)에서 대상 repo와 branch를 확인한다.
2. 빠른 분류가 필요하면 [conventions/README.md](conventions/README.md)에서 coding, pipeline, versioning 중 어디를 봐야 할지 먼저 고른다.
3. [conventions/shared/common-guidelines.md](conventions/shared/common-guidelines.md)에서 공통 가이드라인의 중앙 진입점을 확인한다.
4. REST API를 건드리면 [conventions/coding/rest-api-design.md](conventions/coding/rest-api-design.md)에서 resource, method, status, query 기준을 먼저 확인한다.
5. [conventions/shared/README.md](conventions/shared/README.md)에서 공통 문서 지도를 확인한다.
6. Gateway가 관련되면 [services/server/gateway/troubleshooting.md](services/server/gateway/troubleshooting.md)를 먼저 본다.
7. 변경하려는 서비스의 local `troubleshooting.md`, `v2.md`와 구현 레포 문서를 함께 본다.
8. API shape은 [services/artifacts/openapi](services/artifacts/openapi)의 해당 YAML로 확인한다.
9. 실제 서비스 레포 작업 후 해당 레포의 `contract.lock.yml`을 contract tag/commit에 맞추고 CI 계약 검증 결과를 확인한다.

## 변경 흐름
### 기존 구현을 문서화할 때
```txt
서비스 구현 확인
-> service-contract 문서 정렬
-> OpenAPI/schema 정렬
-> contract.lock.yml 기준 검증
```

### 새 기능을 만들 때
```txt
service-contract 계약 변경
-> 영향 서비스 확인
-> 각 서비스 구현
-> 서비스별 contract.lock.yml 갱신
-> CI 계약 검증과 smoke/test 결과 확인
```

## 적용 대상
| 영역 | 레포 |
| --- | --- |
| Gateway | https://github.com/jho951/gateway-service |
| Auth | https://github.com/jho951/auth-service |
| Authz | https://github.com/jho951/authz-service |
| User | https://github.com/jho951/user-service |
| Redis | https://github.com/jho951/redis-service |
| Editor/Document | https://github.com/jho951/editor-service |
| Monitoring | https://github.com/jho951/monitoring-service |
| Frontend | https://github.com/jho951/Editor-page, https://github.com/jho951/Explain-page |

## Frontend Baseline
| Frontend | Current API Base Pattern | Auth Transport | Notes |
| --- | --- | --- | --- |
| `Editor-page` | base URL는 `http://localhost:8080`, endpoint 상수에 `/v1/**` 포함 | cookie, `withCredentials=true` | `/v1/auth/**`, `/v1/documents/**`, `/v1/editor-operations/**`를 Gateway로 호출한다. |
| `Explain-page` | base URL를 `http://localhost:8080/v1`로 정규화하고 path는 `/auth/**` 사용 | cookie, `credentials: "include"` | `/v1` 중복 없이 Gateway auth/session API를 조립한다. |

- 두 프론트 모두 현재 구현에는 `contract.lock.yml`이 없다.
- 두 프론트 모두 backend 개별 서비스가 아니라 Gateway를 단일 브라우저 진입점으로 사용한다.

## Current Implementation Baseline
| Service | Current compose/project shape | Port | Exposure | Notes |
| --- | --- | --- | --- | --- |
| Gateway | project `gateway-service`, service `gateway-service`, alias `gateway` | `8080` | public entry | 외부 ingress와 public `/v1/**` 소유. runtime status endpoint는 `/health`, `/ready`도 함께 노출한다. editor upstream은 current runtime에서 `EDITOR_SERVICE_URL`을 canonical로 읽고, Authz 위임은 `AUTHZ_ADMIN_VERIFY_URL`을 직접 사용한다. |
| Auth | project/service `auth-service` | `8081` container, local JVM `8081` | private | 인증 원천, JWT/JWKS, session |
| Authz | base/prod compose service `authz-service`, DB host `authz-mysql` | `8084` | private | 관리자 인가, RBAC/policy. single-EC2 bundle도 `authz-mysql`을 함께 띄우고 Redis는 외부 `redis`를 사용한다. env/terraform에는 `PERMISSION_*` 계열 legacy 이름이 남아 있을 수 있다. |
| User | service `user-service` | `8082` | private | 사용자 마스터/소셜/visibility |
| Editor | service `editor-service`, DB host `editor-mysql` | `8083` | private | repo 이름과 app identity를 모두 `editor-service`로 맞춘다. editor 전용 DB host와 runtime 이름도 같은 축으로 정렬한다. |
| Redis | project `redis-server-*`, service `redis-server`, shared alias `redis` | `6379` | private | 캐시/세션 저장 계층. exporter container 기본 이름은 `redis-exporter`다. |
| Monitoring | project `monitoring-server` | Prometheus `9090`, Grafana host default `3005`, Loki `3100` | operator/private | Grafana container는 `3000`을 쓰지만 compose host 기본값은 `3005`다. dev Grafana는 각 서비스 private network에 붙고 Auth/User/Editor/Authz MySQL datasource를 기본 provisioning한다. |

- contract의 서비스 문서는 `services/server/<domain>`과 `services/client/<app>` 구조를 따른다.
- repository 이름과 contract 디렉토리 이름이 다를 수 있으므로 canonical 식별자는 `services/repositories.yml`의 `name`을 기준으로 본다.
- canonical 내부 이름은 `auth-mysql`, `user-mysql`, `authz-mysql`, `editor-mysql`, `editor-service`, `redis`, `redis-server`를 기준으로 맞춘다.
