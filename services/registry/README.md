# Registry

`services/registry`는 이 contract repo가 관리하는 repository 목록, adoption 상태, 운영 절차, 배포 토폴로지를 담는다.
개별 서비스 계약 메모는 `services/server/*`, `services/client/*`에 두고, registry는 전체 지도를 관리한다.

공통 가이드라인의 중앙 진입점은 [../../conventions/shared/common-guidelines.md](../../conventions/shared/common-guidelines.md)이고, `services/registry`는 그중 rollout/ownership/topology 절차를 담당한다.

## 구조
| 문서 | 역할 |
| --- | --- |
| [repositories.yml](../repositories.yml) | machine-readable repository registry |
| [adoption-matrix.md](adoption-matrix.md) | repository별 계약 반영 상태 |
| [service-ownership.md](service-ownership.md) | repo 계층 분류와 소유권 |
| [contract-oss.md](contract-oss.md) | 1/2/3계층 OSS/platform 사용 계약과 breaking change |
| [deployment-topology.md](deployment-topology.md) | EC2 기준 배포, network, security group, 운영 체크리스트 |
| [module-ecosystem.md](module-ecosystem.md) | 공통 모듈과 외부 모듈 책임 |
| [adoption-playbook.md](adoption-playbook.md) | 서비스 레포에 contract 기준을 도입하는 절차 |
| [lifecycle.md](lifecycle.md) | 계약 변경 생명주기 |
| [../../infra/templates/agent-task-template.md](../../infra/templates/agent-task-template.md) | AI agent 작업 지시 템플릿 |
| [automation.md](automation.md) | contract lock 검증과 자동화 방향 |
| [troubleshooting.md](troubleshooting.md) | 장애 분류와 복구 가이드 |

## 원칙
- repository별 계약 메모는 `services/server/*`, `services/client/*`에 둔다.
- 공통 규칙은 `conventions/shared`에 둔다.
- OpenAPI와 JSON Schema는 `services/artifacts`에 둔다.
- 서비스별 현재 platform 사용 방식은 각 구현 레포의 `docs/platform.md`가 소유한다.
- 서비스 레포에 복사할 문서는 `infra/templates`에 둔다.
