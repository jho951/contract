# Environment Contract

## 운영 원칙
- 아래 `필수(Required)` 값은 정상 기능(인증/연동) 기준이며, 누락 시 부분 동작/오류가 발생할 수 있습니다.
- 로컬 개발에서는 일부 값이 fallback 기본값으로 대체될 수 있습니다.

## 네트워크
- `SHARED_SERVICE_NETWORK=service-backbone-shared`
- Gateway 전용 환경변수는 [repositories/gateway-service/env.md](../repositories/gateway-service/env.md)에서 관리한다.

## Docker / MSA Compose 규칙
- 현재 구현은 repo 이름과 runtime service name이 완전히 같지 않다.
- 대표적으로 Gateway는 service `gateway`, Editor는 `documents-service`, Authz prod는 `permission-service`, Redis는 `redis-server`와 alias `central-redis`, Monitoring은 compose project `monitoring-server`를 사용한다.
- Gateway만 public ingress 역할을 가지며, backend service는 private network에서만 통신한다.
- backend service는 host port publish가 필요할 때만 `<SERVICE>_HOST_BIND`, `<SERVICE>_HOST_PORT` 규칙으로 외부 bind를 연다.
- 공통 Docker network는 대부분 `service-backbone-shared`를 쓰지만, Redis 예제 env에는 `backend-shared`가 남아 있다.
- Redis host 기본값은 구현 레포별로 다르다. Gateway/Authz/terraform 예시는 `central-redis`, Redis service key는 `redis-server`, code fallback은 `127.0.0.1` 또는 env override를 사용한다.

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

### 비고
- current `auth-service/.env.example`에는 `USER_SERVICE_BASE_URL=http://user-service:8081`가 남아 있지만, user-service runtime 포트는 `8082`다.

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
- `BLOCK_SERVICE_URL=http://documents-service:8083`
- `AUTHZ_SERVICE_URL=http://authz-service:8084`
- `AUTHZ_ADMIN_VERIFY_URL=http://authz-service:8084/permissions/internal/admin/verify`
- `REDIS_HOST=central-redis`

### 비고
- `BLOCK_SERVICE_URL`이라는 변수명은 유지되고, current gateway dev compose의 host 기본값도 `documents-service`다.
- `AUTHZ_ADMIN_VERIFY_URL` 예시는 `authz-service`를 가리키지만, authz prod compose service key는 현재 `permission-service`다.
