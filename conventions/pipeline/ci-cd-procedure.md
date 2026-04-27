# CI/CD Procedure

현재 canonical pipeline은 contract 검증을 첫 단계에 두고, 그 다음 테스트와 build, 마지막에 이미지와 배포를 수행한다.
repo별 차이는 `services/repositories.yml`의 `ci` / `cd` profile과 서비스별 wrapper script에서만 조정한다.
기존 `shared/ci-cd.md` 내용을 여기로 옮기고, 실제 job 흐름 순서에 맞춰 다시 정리했다.

## 기본 원칙
- `contract-lock`은 모든 repo에서 첫 번째 job이다.
- contract 검증이 실패하면 test, build, image, deploy는 진행하지 않는다.
- workflow는 큰 로직을 직접 품지 않고 repo 내부 wrapper script를 호출한다.
- production deploy는 protected branch 또는 tag, 또는 수동 승인 환경에서만 수행한다.

## 현재 canonical job 흐름
1. `contract-lock`
2. `test-build`
3. `docker-image`
4. `deploy`

현재 workflow template의 세부 흐름은 아래 순서를 따른다.

## CI 단계
| Stage | 필수 여부 | 목적 |
| --- | --- | --- |
| `contract-lock` | 필수 | `contract.lock.yml` 존재, contract repo/ref/commit/consumes 검증 |
| `fetch-contract` | profile 조건부 | lock 기준 contract를 `.contract`에 fetch |
| `validate-compose` | `ec2-compose`인 경우 필수 | `dev`, `prod` compose와 required env key 검증 |
| `setup-runtime` | 필수 | Java 또는 Node runtime 준비 |
| `test` | 필수 | unit/integration 또는 repo 표준 테스트 |
| `build` | 필수 | bootJar, frontend build, compose build 등 산출물 생성 |
| `image` | 배포형 repo 필수 | Docker image build/push 및 immutable tag 생성 |

## CD 단계
| Stage | 필수 여부 | 목적 |
| --- | --- | --- |
| `deploy-gate` | 필수 | 환경, protected branch, 수동 승인 확인 |
| `deploy` | deployable repo 필수 | wrapper script를 통한 배포 |
| `health-check` | 서비스형 repo 권장 | health/ready endpoint 확인 |
| `smoke-test` | 필수 | 배포 후 최소 기능 검증 |

## CI/CD profile
| Profile | 대상 | 기본 명령 축 |
| --- | --- | --- |
| `spring-boot` | gateway/auth/authz/user/editor | `./gradlew clean test`, `bootJar`, Docker image |
| `frontend` | Editor-page/Explain-page | `npm ci`, `npm test` 또는 동등 명령, `npm build` |
| `infra` | redis/monitoring runtime | compose validation, compose build, image |
| `module` | library/module | test/build, tag 기반 publish |

## 배포 절차
1. CI가 `${GITHUB_SHA}` 기준 immutable image tag를 만든다.
2. EC2 compose 계열 repo는 deploy 전에 lock 기준 contract를 다시 fetch한다.
3. repo wrapper는 `.contract/scripts/deploy-service-via-bundle.sh` 또는 동등한 공통 배포 스크립트를 호출한다.
4. 원격 호스트는 `docker compose pull` 후 `docker compose up -d` 또는 `/opt/deploy/scripts/deploy-stack.sh up <service>`로 반영한다.
5. 배포 후 `health`, `ready`, 대표 smoke route를 확인한다.

## 운영 규칙
- `latest`는 `main` 또는 `master`에서만 추가 발행하고 deploy 입력으로 직접 사용하지 않는다.
- 운영 compose는 `build:` 대신 `image:`를 사용한다.
- build secret과 private package 인증은 CI build 단계 또는 build 전용 compose에서만 사용한다.
- compose validation용 env 값은 `conventions/pipeline/env/<service>/.env.ci.dev`, `.env.ci.prod`에 둔다.
- workflow 안에 inline env를 복붙하지 않고 `scripts/validate-compose.sh` 같은 얇은 wrapper를 호출한다.
- `test`와 `build`는 contract 검증이 실패하면 실행하지 않는다.
- service-specific command는 workflow에 직접 흩뿌리지 않고 `contract.lock.yml`과 `services/repositories.yml`에 기록한다.
- 운영/실행용 Compose 파일은 image pull만 담당하고 build secret을 포함하지 않는다.
- 운영 이미지는 Amazon ECR repository를 기본으로 사용한다.
- 단일 이미지 서비스의 repository 이름은 `${deploy_environment}-${service_name}` 형식으로 통일한다.
- 다중 이미지 서비스는 `${deploy_environment}-${service_name}-<component>` suffix를 사용한다.
- 전체 스택 초기 기동이 아니라 서비스 단건 CD라면 대상 서비스만 지정해서 반영하는 것을 우선한다.
- private repository 접근 토큰과 key는 CI 서버 또는 로컬 build 환경에만 두고 production runtime에는 주입하지 않는다.
