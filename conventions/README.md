# Conventions

`conventions`는 이 레포의 운영 규칙을 실제 사용 축 기준으로 재배치한 canonical 디렉토리다.
코딩, 파이프라인, 버전 정책은 여기 문서를 먼저 보고, `shared`와 `registry`는 기술 배경과 인접 규칙을 보강하는 용도로 사용한다.

## 구성
| 경로 | 역할 | 현재 범위 |
| --- | --- | --- |
| [coding](coding/README.md) | cross-repo 코딩 규칙, 언어별 스타일 가이드, 브랜치 전략 | 기존 `shared/coding-conventions.md`와 브랜치 운영 메모 통합 |
| [pipeline](pipeline/README.md) | CI/CD 절차, CI env, 테스트 통과 기준 | 기존 `shared/ci-cd.md`, `ci/README.md`, `ci/env/*` 통합 |
| [versioning](versioning/README.md) | API/public route 버전 규칙, contract release 버전 정책 | 기존 `shared/versioning.md` 재구성 |

## 사용 원칙
- coding, pipeline, versioning 범주의 실질적 기준 문서는 여기 둔다.
- `shared`에는 REST API, routing, security, env, terraform 같은 공통 기술 규칙을 둔다.
- `registry`에는 lifecycle, automation, topology, ownership 같은 운영 절차와 현황을 둔다.
- 새 규칙이 충돌하면 `conventions`, `shared`, `registry`를 같은 턴에 함께 정리한다.

## 이동된 문서
- 기존 `shared/coding-conventions.md` 내용은 [coding/coding-conventions.md](coding/coding-conventions.md)로 이관했다.
- 기존 `shared/ci-cd.md` 내용은 [pipeline/ci-cd-procedure.md](pipeline/ci-cd-procedure.md)로 이관했다.
- 기존 `shared/versioning.md` 내용은 [versioning/api-versioning.md](versioning/api-versioning.md), [versioning/contract-versioning.md](versioning/contract-versioning.md)로 분리했다.
- 기존 `ci/README.md`와 `ci/env/*`는 [pipeline/env/README.md](pipeline/env/README.md)와 `pipeline/env/*`로 옮겼다.

## 함께 볼 문서
- [shared/common-guidelines.md](shared/common-guidelines.md)
- [coding/rest-api-design.md](coding/rest-api-design.md)
- [shared/routing.md](shared/routing.md)
- [shared/env.md](shared/env.md)
- [../services/registry/automation.md](../services/registry/automation.md)
- [../services/registry/lifecycle.md](../services/registry/lifecycle.md)
