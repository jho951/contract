# Coding Conventions

기존 `shared/coding-conventions.md` 본문을 여기로 옮기고, 현재 구조 기준으로 읽기 순서를 다시 정리했다.

## 네이밍 기준
- repository 이름, `services/repositories.yml`의 canonical service name, runtime/service 식별자는 가능한 한 같은 축으로 맞춘다.
- contract 디렉토리 구조는 `services/server/<domain>`, `services/client/<app>` 기준으로 정리한다.
- canonical service key는 `gateway-service`, `auth-service`, `user-service`, `authz-service`, `editor-service`, `redis-server`, `monitoring-service`를 우선 사용한다.
- canonical DB host는 `auth-mysql`, `user-mysql`, `authz-mysql`, `editor-mysql`를 기준으로 맞춘다.
- env var는 대문자 snake case를 사용하고, 서비스 prefix를 명확히 둔다.
- legacy alias를 남길 때는 호환 목적을 문서에 적고, 새 코드에서는 canonical 이름을 우선한다.

## 구현 기준
- 브라우저 진입점은 backend 개별 서비스가 아니라 Gateway public route를 기본선으로 둔다.
- public API version prefix는 Gateway가 소유하고, backend service는 upstream/internal path만 소유한다.
- host, port, secret, token, callback URL은 코드에 하드코딩하지 않고 env, secret manager, profile 설정으로 주입한다.
- request/response shape가 바뀌면 구현 코드만 바꾸지 말고 관련 문서와 `services/artifacts/openapi` 또는 `services/artifacts/schemas`를 함께 갱신한다.
- 보안 경계, trusted header, internal JWT 규칙은 코드에 암묵적으로 숨기지 않고 공통 문서와 맞춘다.
- optimistic locking이나 상태 충돌을 쓰는 API는 `version` 필드와 `409 Conflict` 규칙을 함께 문서화한다.

## 문서 반영 기준
- coding, pipeline, versioning 운영 규칙은 `conventions`에 둔다.
- REST API, routing, security, env, terraform 같은 공통 기술 규칙은 `conventions/shared`에 둔다.
- repo별 계약 메모는 `services/server/*`, `services/client/*`에 둔다.
- machine-readable 계약은 `services/artifacts/openapi`, `services/artifacts/schemas`에 둔다.
- 운영 topology, lifecycle, automation은 `services/registry`에 둔다.
- 서비스 레포 복사용 템플릿과 wrapper는 `infra/templates`, `infra/scripts`에 둔다.

## 품질 기준
- 구현 변경 시 관련 contract 문서, OpenAPI/schema, `contract.lock.yml`을 함께 갱신한다.
- 테스트, 스모크, 검증 명령과 결과를 PR 또는 CI 기록에 남긴다.
- secret, password, token 원문을 repository에 commit하지 않는다.
- 각 서비스 레포는 최소 `lint`, `typecheck` 또는 동등한 정적 검증 명령을 제공한다.
- formatter, pre-commit, staged lint 같은 로컬 보조 게이트를 추가하더라도 공통 계약보다 약해지면 안 된다.

## 변경 체크리스트
1. 이 변경이 공통 규칙인지 서비스 전용 규칙인지 먼저 구분한다.
2. 공통 규칙이면 `conventions` 또는 `conventions/shared` 중 canonical 위치부터 수정한다.
3. API 또는 응답이 바뀌면 서비스 문서와 `services/artifacts/openapi`를 함께 수정한다.
4. env, compose, 인프라가 바뀌면 `conventions/shared/env.md`, `conventions/pipeline/ci-cd-procedure.md`, `conventions/shared/terraform.md` 반영 여부를 같이 확인한다.
5. 서비스 레포 반영 후 `contract.lock.yml`과 CI 계약 검증을 맞춘다.
