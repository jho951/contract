# REST API Design

이 문서는 여러 서비스가 공통으로 따라야 하는 REST API 설계 기준을 정의한다.
서비스별 세부 API shape는 구현 레포의 API 문서와 `services/artifacts/openapi/v1/*.yaml`이 소유하고, 이 문서는 경로/메서드/응답/쿼리/동시성 같은 공통 설계 원칙을 고정한다.

## 범위
- 외부 client가 Gateway를 통해 호출하는 public REST API
- Gateway가 backend service로 전달하는 upstream API
- backend service 간 internal HTTP API

아래 원칙은 HTTP JSON API 기본선이다. 파일 업로드, webhook, SSE, callback, actuator 같은 예외 surface는 서비스 문서에 별도 명시한다.

## 기본 원칙
- public route versioning은 Gateway가 소유하고, backend service는 upstream/internal path를 소유한다.
- 경로는 resource 중심으로 설계하고, 동작은 HTTP method로 표현한다.
- 경로 segment는 소문자 kebab-case를 사용한다.
- collection은 복수형 noun을 사용한다.
- 공통 에러 응답은 [../api-standard.md](../api-standard.md)를 따른다.
- OpenAPI와 사람이 읽는 API 문서는 함께 갱신한다.

## Route Ownership
| Layer | Owner | 예시 | 비고 |
| --- | --- | --- | --- |
| public route | Gateway | `/v1/auth/login`, `/v1/users/me` | browser/mobile/client가 직접 호출 |
| upstream route | backend service | `/auth/login`, `/users/me` | Gateway가 service로 전달 |
| internal route | backend service | `/internal/users`, `/permissions/internal/admin/verify` | service-to-service 또는 operator 전용 |
| runtime route | 각 서비스 | `/`, `/health`, `/ready`, `/.well-known/*` | 상태, discovery, actuator |

- backend service는 public `/v1/**` prefix를 직접 소유하지 않는다.
- Gateway가 public request/response를 upstream 계약에 맞게 rewrite 또는 passthrough 할 수 있다.
- public route와 upstream route는 같은 의미라도 경로를 분리해서 문서화한다.

## Resource Naming
### 권장
- collection: `/users`, `/documents`, `/sessions`
- single resource: `/users/{userId}`, `/documents/{documentId}`
- sub-resource: `/documents/{documentId}/blocks`, `/users/{userId}/social-links`
- singleton or caller-scoped resource: `/users/me`, `/auth/me`

### 금지
- camelCase path: `/findOrCreateSocial`
- 구현 클래스명 노출: `/userController`
- public route에서 service 이름 중복: `/v1/user-service/users`

## HTTP Method Rules
| Method | 의미 | 예시 |
| --- | --- | --- |
| `GET` | 조회 | `GET /users/me` |
| `POST` | 생성 또는 non-idempotent command | `POST /users/signup`, `POST /auth/login` |
| `PUT` | 전체 교체 또는 명시적 상태 설정 | `PUT /internal/users/{userId}/status` |
| `PATCH` | 부분 수정 | `PATCH /documents/{documentId}` |
| `DELETE` | 삭제 | `DELETE /documents/{documentId}` |

- `GET`은 body를 요구하지 않는다.
- `POST`는 생성과 command 모두 가능하지만, command 의미가 강하면 문서에 이유를 남긴다.
- `PATCH`는 partial update 용도로만 사용한다.
- `DELETE`는 기본적으로 삭제 의미로만 사용하고, 복구는 별도 action endpoint로 둔다.

## Action Endpoint Rules
기본은 resource noun 중심이지만, 아래 경우는 action endpoint를 허용한다.

- 인증/세션 command: `/auth/login`, `/auth/refresh`, `/auth/logout`
- 복구/이동/검증처럼 resource CRUD만으로 의미를 표현하기 어려운 경우
- batch/transaction/command semantic이 명확한 경우

### 허용 예시
- `POST /documents/{documentId}/restore`
- `POST /documents/{documentId}/move`
- `POST /permissions/internal/admin/verify`
- `POST /documents/{documentId}/transactions`

### 규칙
- action 이름은 소문자 kebab-case를 사용한다.
- action endpoint는 method만 봐도 멱등성/부작용을 이해할 수 있게 문서화한다.
- 같은 동작을 resource model로 자연스럽게 표현할 수 있으면 action endpoint를 만들지 않는다.

## Status Code Rules
| Status | 사용 기준 |
| --- | --- |
| `200 OK` | 일반 조회/수정/command 성공 |
| `201 Created` | 새 resource 생성 성공 |
| `202 Accepted` | 비동기 처리 접수 |
| `204 No Content` | body 없는 성공 응답 |
| `400 Bad Request` | 입력 형식/파라미터/validation 오류 |
| `401 Unauthorized` | 인증 필요 또는 인증 실패 |
| `403 Forbidden` | 인증은 됐지만 권한 없음 |
| `404 Not Found` | 대상 resource 없음 |
| `405 Method Not Allowed` | 허용되지 않은 HTTP method |
| `409 Conflict` | 버전 충돌, 정렬 충돌, 상태 충돌 |
| `429 Too Many Requests` | rate limit 초과 |
| `500` / `502` / `504` | 서버 내부 오류, upstream 실패, timeout |

- validation 오류는 기본적으로 `400`을 사용한다.
- optimistic locking, duplicate mutation, sortKey/version 충돌은 `409`를 우선 사용한다.
- `404`는 resource 부재일 때만 사용하고, 권한 은닉을 위한 의도적 `404`는 서비스 문서에 명시한다.

## Request Design
### Path Parameter
- resource identity는 path parameter로 표현한다.
- path parameter 이름은 `{userId}`, `{documentId}`처럼 resource 의미를 포함한다.
- ID 타입은 UUID 문자열을 기본선으로 한다.

### Query Parameter
- filtering, search, sort, pagination은 query parameter로 표현한다.
- path에는 filter 조건을 넣지 않는다.
- boolean은 `true|false` 문자열을 사용한다.
- multi-value filter는 repeated query parameter를 우선한다.

예:
```text
GET /documents?status=ACTIVE&status=TRASHED&ownerId=123
GET /users?page=0&size=20&sort=createdAt&direction=desc
GET /documents?q=notion
```

### Body
- 생성/수정/command 입력은 JSON body로 보낸다.
- request body field는 camelCase를 사용한다.
- null 허용 여부, 기본값, enum 의미는 OpenAPI에 명시한다.

## Response Design
### 성공 응답
- 성공 응답 body shape는 서비스가 소유한다.
- Gateway public 성공 응답은 기본적으로 upstream body를 passthrough 할 수 있다.
- 같은 서비스 안에서는 성공 response shape를 일관되게 유지한다.
- list 응답은 item 배열과 pagination metadata 위치를 일관되게 유지한다.

### 실패 응답
- 실패 응답은 [../api-standard.md](../api-standard.md)의 공통 envelope를 따른다.
- `httpStatus`, `success=false`, `code`, `message`는 필수다.
- 민감 정보, token, password, internal secret은 error body에 넣지 않는다.

## Pagination / Filter / Sort
### Offset 기반 기본선
- `page`: 0-based page number
- `size`: page size
- `sort`: field name
- `direction`: `asc|desc`

### Cursor 기반 예외
- 대용량 목록이나 안정적 이어받기가 필요하면 `cursor`, `limit`을 사용할 수 있다.
- cursor 방식은 같은 endpoint에서 offset 방식과 섞지 않는다.

### 공통 규칙
- default sort가 있으면 문서에 명시한다.
- 정렬 가능 field와 filter 가능 field를 OpenAPI와 API 문서에 명시한다.
- domain preference API와 조회 query sort는 구분한다.

## Idempotency / Concurrency
- `GET`, `PUT`, `DELETE`는 기본적으로 idempotent 해야 한다.
- `POST`는 기본적으로 non-idempotent로 본다.
- `ensure-*`, `find-or-create-*` 같은 endpoint는 문서에 idempotent semantics를 명시한다.
- 재시도 가능성이 높은 external create/command는 필요 시 `Idempotency-Key` 같은 별도 정책을 서비스 문서에 둔다.
- version 기반 optimistic locking을 쓰면 request/response에 `version` field를 명시하고 충돌 시 `409`를 반환한다.

## Field Naming
- JSON field는 camelCase를 사용한다.
- 시간 필드는 `createdAt`, `updatedAt`, `deletedAt`, `modifiedAt`처럼 `At` suffix를 사용한다.
- 식별자 필드는 `id`, `userId`, `documentId`, `parentId`처럼 대상 의미를 포함한다.
- 상태/역할/타입 field는 enum string을 기본선으로 한다.

## Time / Format
- timestamp는 ISO-8601 문자열을 사용한다.
- timezone offset 또는 UTC 기준을 서비스 문서에 명시한다.
- money, percentage, opaque token 같은 값은 문자열/정수 중 하나를 명시적으로 고정하고 혼용하지 않는다.

## Header Rules
- 공통 trace header는 `X-Request-Id`, `X-Correlation-Id`를 사용한다.
- client가 보낸 trusted header는 service가 직접 신뢰하지 않는다.
- 인증/인가용 trusted header와 internal JWT 규칙은 [headers.md](../shared/headers.md), [security.md](../shared/security.md)를 따른다.

## OpenAPI / Documentation Rules
- API를 추가/변경하면 구현 레포 API 문서와 `services/artifacts/openapi/v<major>/*.yaml`를 함께 수정한다.
- request/response example을 최소 1개 이상 둔다.
- error response, security scheme, path parameter, enum 의미를 문서에 포함한다.
- public route와 upstream route가 다르면 두 경로를 혼동하지 않게 각각 적는다.

## Compatibility Rules
- breaking change는 Gateway public route version에서 해결하는 것을 우선한다.
- backend upstream route는 가능하면 안정적으로 유지한다.
- 미래 기능은 `draft` 또는 `planned`로 표시하고 현재 구현처럼 문서화하지 않는다.

## Anti-Patterns
- public API를 backend service가 직접 `/v1/**`로 구현하는 것
- 같은 의미의 resource를 endpoint마다 singular/plural로 섞는 것
- path에 동사와 transport detail을 과도하게 넣는 것
- validation 오류와 version 충돌을 둘 다 `500`으로 뭉개는 것
- query parameter로 mutation을 수행하는 것
- service가 외부에서 들어온 trusted header를 직접 신뢰하는 것

## Common Examples
### 좋은 예
```text
POST /v1/auth/login
GET /v1/users/me
POST /internal/users/find-or-create-and-link-social
PATCH /documents/{documentId}
POST /documents/{documentId}/restore
```

### 피해야 하는 예
```text
GET /v1/createUser
POST /v1/users/getMe
PATCH /v1/auth/login
GET /documents/delete?id=123
POST /user-service/users
```
