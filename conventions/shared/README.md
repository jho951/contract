# Shared Contract

`conventions/shared`는 모든 서비스가 공유하는 규칙을 담는다. 특정 서비스의 세부 API가 아니라, 서비스 간 계약을 해석하는 기준이다.

## 무엇을 여기에 두나
| 문서                                               | 역할                                            |
|--------------------------------------------------|-----------------------------------------------|
| [common-guidelines.md](common-guidelines.md)     | 코딩 컨벤션, 보안, 인프라, 변경 절차의 중앙 진입점        |
| [../coding/rest-api-design.md](../coding/rest-api-design.md) | 공통 REST resource/method/status/query 설계 기준 |
| [routing.md](routing.md)                         | public route와 upstream route의 책임 분리           |
| [headers.md](headers.md)                         | trace header, trusted header, internal secret |
| [security.md](security.md)                       | 공통 보안 원칙과 trust boundary                      |
| [auth-channel-policy.md](auth-channel-policy.md) | web/native/cli/api 인증 채널 판정                   |
| [errors.md](errors.md)                           | 공통 에러 envelope와 code 관리 원칙                    |
| [audit.md](audit.md)                             | 공통 감사 이벤트 원칙                                  |
| [monitoring.md](monitoring.md)                   | 공통 health/readiness/metrics 관측 기준                |
| [deployment-topologies.md](deployment-topologies.md) | 배포 방식 이력, EC2 bootstrap 구현 기록, ECS 전환 기준 |
| [v2-ecs-terraform-deployment.md](v2-ecs-terraform-deployment.md) | 현재 EC2 image 배포에서 v2 ECS + Terraform로 전환할 때의 목표 구조와 마이그레이션 기준 |
| [developer-portal-v2.md](developer-portal-v2.md) | 각 repo 문서를 중앙 포털로 수집하는 Backstage + OpenAPI/Swagger v2 구조 |
| [single-ec2-deployment.md](single-ec2-deployment.md) | `m7i-flex.large` 기준 단일 EC2 배포 체크리스트, env, 포트 정책 |
| [single-ec2-edge-routing.md](single-ec2-edge-routing.md) | 단일 EC2에서 backend 7개와 frontend 2개를 함께 노출하는 도메인, 포트, Nginx reverse proxy 기준 |
| [implementation-rollup-2026-04-24.md](implementation-rollup-2026-04-24.md) | 구현 레포 반영 사항, ECR 정책, build/run 분리 요약 |
| [terraform/shared-platform-network/README.md](terraform/shared-platform-network/README.md) | shared VPC, subnet, private hosted zone 공통 Terraform |
| [env.md](env.md)                                 | 공통 환경변수 작성 원칙                                 |
| [terraform.md](terraform.md)                     | MSA 공통 Terraform 구조와 모듈 분리 기준                  |
| [decision-criteria.md](decision-criteria.md)     | 설계 판단 기준                                      |

## moved to conventions
| 문서 | 현재 위치 |
| --- | --- |
| 코딩 컨벤션 | [../coding/coding-conventions.md](../coding/coding-conventions.md) |
| CI/CD 절차 | [../pipeline/ci-cd-procedure.md](../pipeline/ci-cd-procedure.md) |
| 테스트 통과 기준 | [../pipeline/test-pass-criteria.md](../pipeline/test-pass-criteria.md) |
| CI env 규칙 | [../pipeline/env/README.md](../pipeline/env/README.md) |
| 버전 정책 | [../versioning/README.md](../versioning/README.md) |

## 공통 원칙
- 공통 가이드라인의 첫 진입점은 [common-guidelines.md](common-guidelines.md)다.
- coding, pipeline, versioning 운영 규칙은 [../conventions](../README.md)에 둔다.
- Gateway는 public route versioning을 소유한다.
- Backend service는 자기 upstream/internal route를 소유한다.
- Downstream 서비스는 Gateway가 재주입한 trusted header만 신뢰한다.
- 공통 에러 응답은 [../api-standard.md](../api-standard.md)와 [error-envelope.schema.json](../../services/artifacts/schemas/error-envelope.schema.json)을 따른다.
- 공통 감사 이벤트 원칙은 [audit.md](audit.md)를 따른다.
- 공통 관측 기준은 [monitoring.md](monitoring.md)를 따른다.
- OpenAPI 파일은 `services/artifacts/openapi`에 둔다.
- 공통 Terraform 구조는 [terraform.md](terraform.md)를 따른다.

## 서비스별 로컬 메모
| 서비스 | Contract Repo에 남기는 문서 |
| --- | --- |
| Gateway | [troubleshooting.md](../../services/server/gateway/troubleshooting.md), [v2.md](../../services/server/gateway/v2.md) |
| Auth | [troubleshooting.md](../../services/server/auth/troubleshooting.md), [v2.md](../../services/server/auth/v2.md) |
| Authz | [troubleshooting.md](../../services/server/authz/troubleshooting.md), [v2.md](../../services/server/authz/v2.md) |
| User | [troubleshooting.md](../../services/server/user/troubleshooting.md), [v2.md](../../services/server/user/v2.md) |
| Block | [troubleshooting.md](../../services/server/editor/troubleshooting.md), [v2.md](../../services/server/editor/v2.md) |
| Redis | [troubleshooting.md](../../services/server/redis/troubleshooting.md), [v2.md](../../services/server/redis/v2.md) |
| Monitoring | [troubleshooting.md](../../services/server/monitoring/troubleshooting.md), [v2.md](../../services/server/monitoring/v2.md) |

## 사용 방법
1. 먼저 [common-guidelines.md](common-guidelines.md)에서 공통 가이드 맵과 우선순위를 확인한다.
2. coding, pipeline, versioning 이슈면 먼저 [../README.md](../README.md)로 이동한다.
3. 서비스별 로컬 troubleshooting/v2 문서를 보고, API/security/ops/error 상세는 구현 레포 문서를 확인한다.
4. request/response 세부 shape은 `services/artifacts/openapi`의 YAML을 확인한다.
5. 공통 규칙과 서비스 문서가 충돌하면 common 문서를 먼저 정리한 뒤 서비스 문서를 맞춘다.
