# Test Pass Criteria

테스트 통과 기준은 "코드가 실행된다" 수준이 아니라 contract, build, runtime, smoke까지 포함한다.
아래 항목 중 필수 게이트 하나라도 실패하면 해당 pipeline은 실패로 본다.

## 공통 필수 기준
| 항목 | 통과 조건 |
| --- | --- |
| Contract lock | `contract.lock.yml`이 존재하고 `repo/ref/commit/consumes` 검증을 통과한다. |
| Consumed paths | `consumes`에 적힌 문서와 artifact가 lock 기준 contract commit에 실제 존재한다. |
| Runtime validation | 해당 profile이 요구하는 Java, Node, compose 준비가 정상 완료된다. |
| Test | repo 표준 테스트 명령이 0 exit code로 끝난다. |
| Build | 배포 또는 배포 직전 산출물 생성이 성공한다. |
| Evidence | 실행한 테스트/스모크/검증 명령과 결과를 PR 또는 CI 로그에 남긴다. |

## profile별 기준
### Spring Boot 서비스
- `./gradlew clean test` 또는 동등한 test command가 통과해야 한다.
- `bootJar` 또는 동등한 build command가 통과해야 한다.
- `ec2-compose` 배포면 `dev`, `prod` compose validation이 모두 통과해야 한다.
- 운영 배포가 있는 repo는 Docker image build/push가 성공해야 한다.

### Frontend
- `npm ci`가 재현 가능하게 끝나야 한다.
- 최소 `lint`, `typecheck`, `build`가 통과해야 한다.
- Gateway public route 조립 규칙이 깨지지 않아야 한다.
- cookie/session 기반 호출이면 `withCredentials` 또는 `credentials: "include"` 계약을 유지해야 한다.

### Infra / Compose 중심 repo
- `docker compose config` 또는 동등 검증이 dev/prod 모두 통과해야 한다.
- required env key 누락이 없어야 한다.
- 운영 compose는 image-only 실행 기준을 충족해야 한다.

### Module / Library
- test와 build가 모두 통과해야 한다.
- publish-on-tag 구조면 tag 기준 release job이 재현 가능해야 한다.

## 배포 전 추가 기준
- production deploy는 protected branch, tag, 또는 수동 승인 환경 조건을 만족해야 한다.
- 이미지 태그는 `${GITHUB_SHA}`를 기본 immutable tag로 사용해야 한다.
- compose 배포는 실제 운영 실행 파일 기준 validation을 우선한다.

## 배포 후 통과 기준
- health endpoint가 성공해야 한다.
- readiness endpoint가 성공해야 한다.
- 대표 smoke 시나리오가 통과해야 한다.
- 실패 시 rollback 또는 재배포 판단에 필요한 로그와 실행 명령이 남아 있어야 한다.

## v2 또는 강화 게이트
- `gateway-service`가 v2 기준으로 전환되면 JaCoCo coverage verification이 필수다.
- v2 Gateway는 line coverage뿐 아니라 branch coverage gate도 포함한다.
- edge 회귀를 보기 위한 k6 smoke/load 시나리오는 release gate 또는 사전 검증 단계에 연결한다.

## 실패로 간주하는 예
- contract 문서는 바뀌었는데 `contract.lock.yml` ref/commit 갱신이 없다.
- 테스트는 통과했지만 compose required env가 깨져 prod validation이 실패한다.
- 이미지는 발행됐지만 health/ready 또는 smoke check가 실패한다.
- PR에는 결과가 없고 CI 로그에도 어떤 검증을 했는지 남지 않는다.
