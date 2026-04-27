# CI Environment

이 디렉토리는 compose validation에 사용하는 공통 CI env placeholder를 보관한다.
기존 `ci/env/*`를 여기로 옮겼다.

## 규칙

- 경로는 `conventions/pipeline/env/<service>/.env.ci.dev`, `conventions/pipeline/env/<service>/.env.ci.prod`로 고정한다.
- 값은 runtime secret이 아니라 compose interpolation과 `:?required` 검증을 통과시키기 위한 non-secret placeholder다.
- 서비스 repo workflow는 contract repo를 fetch한 뒤 이 파일을 직접 읽지 않고, 얇은 wrapper 스크립트를 통해 contract repo의 검증 스크립트를 호출한다.
- 실제 service-aware compose 선택과 env file 주입 편차는 `scripts/validate-service-compose.sh`가 담당한다.
- `docker/prod/compose.yml`의 required key가 바뀌면 해당 서비스의 `.env.ci.prod`를 같이 갱신한다.
- dev compose가 별도 required key를 가지면 `.env.ci.dev`에도 같은 기준으로 반영한다.

## 사용법

```bash
./scripts/validate-compose.sh dev
./scripts/validate-compose.sh prod
```
