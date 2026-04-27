# Pipeline Conventions

이 디렉토리는 현재 레포가 정의한 CI/CD 공통 절차와 품질 게이트를 모은다.
실행 순서, profile별 차이, 테스트 통과 기준을 빠르게 확인할 때 사용한다.
기존 `shared/ci-cd.md`, `ci/README.md`, `ci/env/*` 내용은 여기로 옮겨 정리한다.

## 문서
| 문서 | 역할 |
| --- | --- |
| [ci-cd-procedure.md](ci-cd-procedure.md) | 현재 canonical CI/CD 단계와 배포 절차 |
| [env/README.md](env/README.md) | compose validation용 CI env 파일 규칙 |
| [test-pass-criteria.md](test-pass-criteria.md) | profile별 테스트, compose, smoke 통과 기준 |

## 함께 볼 문서
- [../../services/registry/automation.md](../../services/registry/automation.md)
- [../../services/registry/lifecycle.md](../../services/registry/lifecycle.md)
- [../../infra/templates/service-repo/README.md](../../infra/templates/service-repo/README.md)
- [../../infra/github/workflow-templates/contract-check.yml](../../infra/github/workflow-templates/contract-check.yml)
