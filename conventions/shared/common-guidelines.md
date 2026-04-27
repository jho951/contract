# Common Guidelines

이 문서는 `service-contract` 레포에서 관리하는 공통 가이드라인의 중앙 진입점이다.
코딩 컨벤션, 보안 정책, 인프라 구조, 계약 변경 절차를 한곳에서 찾을 수 있게 하고, 상세 규칙은 주제별 문서로 연결한다.

## 적용 범위
- 모든 backend/frontend/infra repository는 이 문서를 공통 시작점으로 본다.
- 서비스별 세부 API/security/ops/errors 문서는 구현 레포가 소유한다.
- 이 contract 레포의 `services/server/*`, `services/client/*`는 troubleshooting과 v2 확장 메모만 유지한다.
- machine-readable 계약은 `services/artifacts/openapi`, `services/artifacts/schemas`가 소유한다.
- 운영 절차, adoption, topology rollout은 `services/registry` 문서가 소유한다.

## 우선순위
1. 공통 판단 기준과 진입점은 이 문서를 따른다.
2. coding, pipeline, versioning 규칙은 `conventions/*.md`를 따른다.
3. 나머지 공통 기술 규칙은 `conventions/shared/*.md`를 따른다.
4. 서비스별 세부 구현 사항은 구현 레포 문서를 따른다.
5. API/schema shape는 `services/artifacts/openapi/v1/*`, `services/artifacts/schemas/*`를 따른다.
6. 배포 rollout, adoption, ownership는 `services/registry/*.md`를 따른다.

공통 문서와 서비스 문서가 충돌하면 먼저 `conventions`와 `conventions/shared` 기준을 정리한 뒤 서비스 문서를 맞춘다.

## 공통 가이드 맵
| 영역 | 기본 문서 | 함께 봐야 하는 문서 | 사용 시점 |
| --- | --- | --- | --- |
| 코딩 컨벤션 | [../coding/coding-conventions.md](../coding/coding-conventions.md) | [../versioning/api-versioning.md](../versioning/api-versioning.md), [../api-standard.md](../api-standard.md) | 구현 규칙, 네이밍, 품질 게이트를 정할 때 |
| REST API 설계 | [../coding/rest-api-design.md](../coding/rest-api-design.md) | [routing.md](routing.md), [../versioning/api-versioning.md](../versioning/api-versioning.md), [../api-standard.md](../api-standard.md), `services/artifacts/openapi/v1/*`, 구현 레포 API 문서 | resource 경로, method, status code, pagination 기준을 정할 때 |
| 라우팅/API 경계 | [routing.md](routing.md) | [../versioning/api-versioning.md](../versioning/api-versioning.md), `services/artifacts/openapi/v1/*`, 구현 레포 API 문서 | 새 endpoint, route rewrite, public API 변경 시 |
| 보안 정책 | [security.md](security.md) | [auth-channel-policy.md](auth-channel-policy.md), [headers.md](headers.md), 구현 레포 security 문서 | 인증/인가, trusted header, internal JWT 변경 시 |
| 에러/감사/관측 | [../api-standard.md](../api-standard.md) | [audit.md](audit.md), [monitoring.md](monitoring.md), [errors.md](errors.md) | 에러 envelope, audit event, health/metrics 기준 변경 시 |
| 환경 변수/Compose | [env.md](env.md) | [../pipeline/ci-cd-procedure.md](../pipeline/ci-cd-procedure.md), [single-ec2-deployment.md](single-ec2-deployment.md), [single-ec2-edge-routing.md](single-ec2-edge-routing.md) | runtime env, compose, 단일 EC2 배포 기준 확인 시 |
| 인프라 구조 | [terraform.md](terraform.md) | [v2-ecs-terraform-deployment.md](v2-ecs-terraform-deployment.md), [terraform/shared-platform-network/README.md](terraform/shared-platform-network/README.md), [../../services/registry/deployment-topology.md](../../services/registry/deployment-topology.md) | Terraform 구조, 네트워크, ECS/EC2 배치 변경 시 |
| 설계 판단 | [decision-criteria.md](decision-criteria.md) | `services/server/authz/v2.md`, `services/server/editor/v2.md`, 구현 레포 설계 문서 | 권한, 조건, 캐시 무효화, 책임 경계를 정할 때 |
| 변경 절차/자동화 | [../../services/registry/lifecycle.md](../../services/registry/lifecycle.md) | [../../services/registry/adoption-playbook.md](../../services/registry/adoption-playbook.md), [../../services/registry/automation.md](../../services/registry/automation.md), [../pipeline/ci-cd-procedure.md](../pipeline/ci-cd-procedure.md) | contract 변경부터 서비스 반영, lock/CI 절차를 따를 때 |

## 필수 기준
- 인터페이스 Source of Truth는 이 contract 레포다.
- 구현 변경이 필요하면 `contract 변경 -> 구현 변경` 순서를 지킨다.
- public route versioning은 Gateway가 소유하고, backend는 upstream/internal route를 소유한다.
- 새 구현은 canonical service name, DB host, env naming을 [env.md](env.md) 기준으로 맞춘다.
- 에러 응답은 [../api-standard.md](../api-standard.md)와 `services/artifacts/schemas/error-envelope.schema.json` 기준을 따른다.
- 외부 입력 header, token, cookie 신뢰 경계는 [security.md](security.md)와 [headers.md](headers.md)를 따른다.
- 인프라 구조 변경은 topology, env, Terraform, CI/CD 문서를 같이 갱신한다.
- 서비스 레포는 구현 반영 후 `contract.lock.yml`에 참조 ref/SHA와 소비 문서를 고정한다.

## 영역별 시작점
| 작업 유형 | 먼저 볼 문서 | 다음 문서 |
| --- | --- | --- |
| 공통 REST API 설계 | [../coding/rest-api-design.md](../coding/rest-api-design.md) | [routing.md](routing.md), [../api-standard.md](../api-standard.md), `services/artifacts/openapi/v1/*`, 구현 레포 API 문서 |
| 새 public API 추가 | [routing.md](routing.md) | [../versioning/api-versioning.md](../versioning/api-versioning.md), `services/artifacts/openapi/v1/*`, 구현 레포 API 문서 |
| 인증/인가 정책 수정 | [security.md](security.md) | [auth-channel-policy.md](auth-channel-policy.md), [headers.md](headers.md), 구현 레포 security 문서 |
| 공통 에러/응답 수정 | [../api-standard.md](../api-standard.md) | [errors.md](errors.md), 구현 레포 error 문서, `services/artifacts/schemas/error-envelope.schema.json` |
| Redis/캐시/세션 정책 수정 | [decision-criteria.md](decision-criteria.md) | `services/server/redis/troubleshooting.md`, `services/server/authz/v2.md`, 구현 레포 운영 문서 |
| 배포 구조/네트워크 수정 | [../../services/registry/deployment-topology.md](../../services/registry/deployment-topology.md) | [env.md](env.md), [terraform.md](terraform.md), [../pipeline/ci-cd-procedure.md](../pipeline/ci-cd-procedure.md) |
| 새 서비스 레포 contract 도입 | [../../services/registry/adoption-playbook.md](../../services/registry/adoption-playbook.md) | [../coding/coding-conventions.md](../coding/coding-conventions.md), `infra/templates/*` |
| AI agent 작업 지시 | [../../infra/templates/agent-task-template.md](../../infra/templates/agent-task-template.md) | [../coding/coding-conventions.md](../coding/coding-conventions.md), [../pipeline/test-pass-criteria.md](../pipeline/test-pass-criteria.md) |

## 중앙화 원칙
- 상세 문서를 무리하게 합치지 않고, 중앙 허브에서 링크와 우선순위를 관리한다.
- 새 공통 규칙이 생기면 먼저 이 문서에 entry를 추가하고, 그 다음 상세 문서를 만든다.
- 서비스 전용 구현 규칙은 구현 레포에 두고, 이 contract 레포에는 `services/server/*`, `services/client/*` 아래 troubleshooting과 v2 메모만 남긴다.
