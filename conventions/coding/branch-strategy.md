# Branch Strategy

## 기준

- "환경 분리"로 dev/prod를 서로 다른 source-of-truth 브랜치로 갈라놓지 않습니다.
- 같은 기준 브랜치에서 profile, env, secret, deploy target으로 환경 차이를 관리한다.

## 기준 브랜치
| Repo                 | 기준 브랜치   |
|----------------------|----------|
| `gateway-service`    | `main`   |
| `auth-service`       | `main`   |
| `authz-service`      | `main`   |
| `user-service`       | `main`   |
| `editor-service`     | `main`   |
| `redis-service`      | `main`   |
| `monitoring-service` | `main`   |
| `Explain-page`       | `main`   |
| `Editor-page`        | `main`   |


## 운영 원칙
- 코드와 배포 정의는 같은 기준 브랜치에서 함께 유지한다.
- dev/prod 차이는 `application-{env}.yml`, `docker/{env}/compose.yml`, `.env.{env}`, GitHub Environment, secret store로 푼다.
- production deploy는 protected branch 또는 tag에서만 수행한다.
- release 판단 기준은 브랜치보다 immutable commit SHA와 tag를 우선한다.

## 브랜치 종류
| 종류      | 용도               | 비고                               |
|---------|------------------|----------------------------------|
| 기준 브랜치  | 운영 가능한 최신 기준     | `main`                           |
| 작업 브랜치  | 기능, 버그 수정, 문서 작업 | 기준 브랜치에서 분기                      |
| bug 브랜치 | 운영 이슈 긴급 수정      | 기준 브랜치에서 분기 후 빠르게 merge          |
| 통합 브랜치  | 선택적 사전 검증        | `dev`를 둘 수 있지만 유일한 source로 쓰지 않음 |

## 권장 흐름
1. 기준 브랜치에서 작업 브랜치를 만든다.
2. contract 영향이 있으면 contract 문서를 먼저 수정한다.
3. 서비스 구현과 `contract.lock.yml`을 맞춘다.
4. CI 계약 검증, 테스트, build를 통과시킨다.
5. contract PR을 먼저, 서비스 PR을 다음 순서로 merge한다.
6. production 배포는 protected branch 또는 release tag 기준으로 실행한다.

## 하지 말아야 할 것
- dev/prod 배포 정의를 서로 다른 장기 브랜치에서 따로 관리하는 것
- `main`과 `dev`에서 서로 다른 compose 구조를 장기 유지하는 것
- release, rollback, bug 기준을 브랜치 이름만으로 판단하는 것
- 환경 비밀값 문제를 브랜치 분리로 해결하려는 것

## 권장 이름 예시
- `feature/<topic>`
- `fix/<topic>`
- `bug/<topic>`
- `docs/<topic>`
- `refector/<topic>`
- `chore/<topic>`
