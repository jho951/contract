# Environment Contract

## 운영 원칙
- 아래 `필수(Required)` 값은 정상 기능(인증/연동) 기준이며, 누락 시 부분 동작/오류가 발생할 수 있습니다.
- 로컬 개발에서는 일부 값이 fallback 기본값으로 대체될 수 있습니다.

## 네트워크
- `SHARED_SERVICE_NETWORK=service-backbone-shared`
- Gateway 전용 환경변수는 [repositories/gateway-service/env.md](../repositories/gateway-service/env.md)에서 관리한다.

## Docker / MSA Compose 규칙
- 현재 구현은 repo 이름과 runtime service name이 완전히 같지 않다.
- 현재 canonical compose service key는 Gateway `gateway-service`, Auth `auth-service`, User `user-service`, Authz `authz-service`, Editor `editor-service`, Redis `redis-server`다.
- 서비스 전용 DB host는 Auth `auth-mysql`, User `user-mysql`, Authz `authz-mysql`, Editor `editor-mysql`처럼 앞에 서비스 이름을 붙여 고정한다.
- shared-network 호출 이름은 Editor `editor-service`, Redis `redis`를 기준으로 맞춘다.
- Gateway만 public ingress 역할을 가지며, backend service는 private network에서만 통신한다.
- backend service는 host port publish가 필요할 때만 `<SERVICE>_HOST_BIND`, `<SERVICE>_HOST_PORT` 규칙으로 외부 bind를 연다.
- 공통 Docker network는 `service-backbone-shared`를 기준으로 맞춘다.
- Redis host 기본값은 운영 예시 기준 `redis`이고, Redis compose service key는 `redis-server`다. code fallback은 `127.0.0.1` 또는 env override를 사용한다.

## User Service
### 필수(Required)
- `USER_SERVICE_INTERNAL_JWT_ISSUER=auth-service`
- `USER_SERVICE_INTERNAL_JWT_AUDIENCE=user-service`
- `USER_SERVICE_INTERNAL_JWT_SECRET=<shared-secret>`
- `USER_SERVICE_INTERNAL_JWT_SCOPE=internal`

## Auth Service
### 필수(Required) - User 연동/내부 JWT
- `USER_SERVICE_BASE_URL=http://user-service:8082`
- `USER_SERVICE_JWT_ISSUER=auth-service`
- `USER_SERVICE_JWT_AUDIENCE=user-service`
- `USER_SERVICE_JWT_SUBJECT=auth-service`
- `USER_SERVICE_JWT_SCOPE=internal`
- `USER_SERVICE_JWT_SECRET=<shared-secret>`

### 필수(Required) - DB/Redis 기동
- `MYSQL_DB`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_URL`
- `REDIS_HOST`
- `REDIS_PORT`

### 선택(Optional) - SSO 사용 시 필수
- `SSO_GITHUB_CLIENT_ID`
- `SSO_GITHUB_CLIENT_SECRET`
- `SSO_GITHUB_CALLBACK_URI`

## Gateway Service
### 필수(Required) - Upstream URL
- `AUTH_SERVICE_URL=http://auth-service:8081`
- `USER_SERVICE_URL=http://user-service:8082`
- `EDITOR_SERVICE_URL=http://editor-service:8083`
- `AUTHZ_ADMIN_VERIFY_URL=http://authz-service:8084/permissions/internal/admin/verify`
- `REDIS_HOST=redis`

### 비고
- current gateway runtime은 `EDITOR_SERVICE_URL`을 editor upstream 설정으로 읽는다.
- current gateway dev compose 기본값은 `http://editor-service:8083`이다.
- current gateway runtime은 `AUTHZ_SERVICE_URL`을 직접 읽지 않고, 관리자 인가 위임 대상은 `AUTHZ_ADMIN_VERIFY_URL`로만 설정한다.

## Authz Service
### 필수(Required) - DB/Redis 기동
- `AUTHZ_MYSQL_DATABASE`
- `AUTHZ_MYSQL_USER`
- `AUTHZ_MYSQL_PASSWORD`
- `AUTHZ_MYSQL_ROOT_PASSWORD`
- `AUTHZ_SPRING_DATASOURCE_URL`
- `AUTHZ_SPRING_DATASOURCE_USERNAME`
- `AUTHZ_SPRING_DATASOURCE_PASSWORD`
- `AUTHZ_SPRING_DATASOURCE_DRIVER_CLASS_NAME`
- `REDIS_HOST`
- `REDIS_PORT`

### 비고
- 운영 single-EC2 bundle 기준 Authz 전용 DB host는 `authz-mysql`이다.
- `service-authz`는 `prod`에서도 datasource env를 필수로 읽고, schema는 JPA `ddl-auto: update`로 생성한다.
- `PLATFORM_SECURITY_SERVICE_ROLE_PRESET`, `PLATFORM_GOVERNANCE_AUDIT_SERVICE_NAME` 같은 platform env는 공용 `.env.backend`에만 두지 말고 compose에서 Authz 전용 값으로 다시 고정한다.
- 현재 `service-authz` prod 이미지는 rate-limit port 구현이 없어 `AUTHZ_PLATFORM_SECURITY_RATE_LIMIT_ENABLED=false`로 두어야 정상 기동한다.
