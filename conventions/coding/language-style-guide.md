# Language Style Guide

이 문서는 현재 레포가 다루는 구현 유형을 기준으로 언어별 기본 스타일을 정리한다.
형식 도구는 각 구현 레포의 formatter/linter를 우선 사용하되, 아래 규칙보다 느슨하면 안 된다.

## 공통 원칙
- 새 코드는 현재 repo의 naming axis와 runtime 구조를 존중한다.
- public API 변경은 코드 변경과 문서 변경을 분리하지 않는다.
- secret, host, port, callback URL, image URI는 코드 상수보다 env 또는 설정 파일에 둔다.
- 브라우저 클라이언트는 Gateway를 단일 API 진입점으로 사용한다.

## Java / Spring Boot
- package는 소문자, type은 PascalCase, method/field는 camelCase, 상수는 `UPPER_SNAKE_CASE`를 사용한다.
- controller는 public `/v1/**`를 직접 소유하지 않고 upstream/internal route만 노출한다.
- 설정은 `application-{env}.yml`, env var, secret 주입으로 관리하고 하드코딩을 피한다.
- DTO와 응답 모델은 OpenAPI 및 실제 JSON field와 같은 이름 축을 유지한다.
- version 기반 충돌 제어를 쓰면 request/response에 `version`을 명시하고 충돌 시 `409`를 반환한다.
- 테스트는 최소 `./gradlew clean test`로 재현 가능해야 한다.

## TypeScript / React / Next.js / Vite
- component, page, type, interface는 PascalCase를 사용한다.
- hook은 `use*`, 일반 함수와 변수는 camelCase를 사용한다.
- 브라우저 앱은 backend 개별 서비스 직접 호출 대신 Gateway public route를 사용한다.
- `Editor-page`는 base URL에 `/v1`를 넣지 않고 endpoint 상수에 `/v1`를 둔다.
- `Explain-page`는 base URL을 `/v1` 축으로 정규화하고 path 상수에는 `/v1`를 중복하지 않는다.
- cookie/session 기반 인증을 쓰는 요청은 `withCredentials=true` 또는 `credentials: "include"`를 유지한다.
- 품질 게이트 기본선은 `npm run lint`, `npm run typecheck`, `npm run build`다.

## YAML / Docker Compose / OpenAPI
- compose service key, network alias, env key는 canonical service naming을 따른다.
- prod compose는 `build:`보다 `image:`를 기본으로 사용하고, build secret은 CI 또는 build 전용 compose에만 둔다.
- required env key는 명시적으로 선언하고 `conventions/pipeline/env/<service>`와 contract 검증 스크립트로 맞춘다.
- base compose와 env override는 같은 service key를 유지해 override가 신규 서비스 추가로 바뀌지 않게 한다.
- OpenAPI는 path, parameter, example, error response, security scheme까지 코드와 같이 갱신한다.

## Shell / Bash
- workflow wrapper와 운영 스크립트는 bash 기준으로 작성하고 `set -euo pipefail`을 기본으로 둔다.
- 스크립트는 얇게 유지하고, 환경별 분기나 검증 로직은 공통 contract script로 위임한다.
- workflow 안에 대형 inline shell과 inline env 매트릭스를 늘리지 말고 repo 내부 wrapper를 호출한다.
- secret, token, 개인 계정 값은 스크립트에 직접 쓰지 않는다.

## Terraform
- 환경별 값은 `terraform.tfvars`, variable, remote state 입력으로 분리하고 코드에 고정하지 않는다.
- 네이밍, tag, subnet, private hosted zone, shared network 구조는 공통 Terraform 문서와 같은 축을 유지한다.
- shared 인프라와 서비스별 인프라의 책임을 섞지 않는다.

## Markdown / Contract Docs
- 현재 구현은 `current`, 미래 설계는 `draft` 또는 `planned`로 구분한다.
- breaking change는 migration, rollout, versioning 영향을 같이 적는다.
- 구현 메모는 서비스별 문서에 두고, 공통 규칙은 `shared`와 `conventions`에 둔다.
- 사람이 읽는 문서와 machine-readable artifact가 서로 다른 내용을 말하지 않게 유지한다.
