# 문제 해결

이 contract 레포에서 `auth-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.

## `db/schema.sql` 기준

이유:

- `auth-service`가 `auth_accounts`, `auth_login_attempts`, `mfa_factors`를 직접 소유합니다.
- `prod` profile은 `spring.jpa.hibernate.ddl-auto: none`입니다.
- 운영 DB schema는 애플리케이션 시작으로 자동 변경되지 않습니다.
- 따라서 신규 운영 DB를 처음 만들 baseline schema가 필요합니다.

현재 역할 분리는 아래와 같습니다.

```text
app/src/main/java/.../entity
  현재 애플리케이션의 DB 모델

app/src/main/resources/*_db.yml
  dev/prod DB 연결과 Hibernate DDL 정책

db/schema.sql
  신규 운영 DB baseline schema

scripts/db
  운영 SQL 실행 wrapper가 필요할 때 추가

docker/{dev,prod}/services/mysql/init.sql
  MySQL 컨테이너 최초 DB/user/권한 bootstrap
```

`db/schema.sql`은 테이블 DDL의 단일 source입니다. Docker `init.sql`은 DB/user/권한을 만든 뒤 `SOURCE /schema/auth-schema.sql;`로 `db/schema.sql`을 실행합니다. 현재 migration 파일은 두지 않습니다.

## MSA에서 DB schema 위치

MSA에서는 보통 서비스가 자기 데이터베이스 schema를 소유합니다.
따라서 `auth-service`가 소유하는 테이블의 baseline schema는 `auth-service` repo 안에 두는 것이 실무적으로 안전합니다.

좋은 PR 단위:

```text
entity 변경
repository/service 변경
db/schema.sql 변경
docs/database.md 변경
OpenAPI 변경이 있으면 docs/openapi 변경
```

피해야 할 방식:

```text
entity만 변경하고 db/schema.sql 미반영
운영 SQL을 개인 문서나 별도 위치에만 보관
Docker init.sql에 테이블 DDL 섞기
다른 서비스가 auth DB schema를 직접 변경
```

## Migration 미사용 기준

현재 baseline schema를 직접 관리하는 파일:

```text
db/schema.sql
docs/database.md
```

장점:

- 단순합니다.
- 현재 repo 구조와 잘 맞습니다.
- 신규 DB가 어떤 schema로 시작하는지 파일로 바로 확인할 수 있습니다.

한계:

- DB 내부에 schema 적용 이력이 자동으로 남지 않습니다.
- CI/CD 자동화 수준이 낮습니다.

현재 기준:

```text
지금은 db/schema.sql baseline 유지
현재 migration은 두지 않음
```

## UUID schema 기준

신규 DB는 처음부터 canonical UUID `CHAR(36)` 기준으로 생성합니다.

```sql
id CHAR(36) NOT NULL
```

따라서 `BINARY(16)`에서 `CHAR(36)`으로 바꾸려 했던 이유는 성능 최적화보다 운영 가독성, 디버깅 편의성, 서비스 간 UUID 표현의 일관성을 우선했기 때문입니다.

## EC2 Compose와 ECS/Fargate 중 무엇을 쓸지

이 서비스는 두 방식을 모두 검토했습니다. 구현 이력과 대표 코드 조각은 service-contract의 `conventions/shared/deployment-topologies.md`에 남깁니다.

`EC2 + Docker Compose`가 맞는 경우:

- 한 대 또는 소수의 host에 직접 exporter, sidecar, daemon 성격 구성을 붙여야 합니다.
- 무중단보다 단순 bootstrap과 수동 운영이 우선입니다.
- Redis, monitoring처럼 host 단위 운영이 더 자연스러운 서비스입니다.

`ECS/Fargate + CodeDeploy`가 맞는 경우:

- 새 배포본을 health check로 검증한 뒤 트래픽을 옮겨야 합니다.
- 단일 EC2 컨테이너 교체가 아니라 task set 수준의 blue/green이 필요합니다.
- auth-service처럼 gateway 뒤의 핵심 인증 서비스를 무중단으로 교체해야 합니다.

현재 운영 기본값:

```text
현재 단일 EC2 `m7i-flex.large`
  -> 단일 EC2 + docker compose 통합 배포
  -> auth-service는 gateway 뒤 same-host compose network로 연결

장기 권장
  -> gateway는 ECS/Fargate + public ALB

auth-service
  -> ECS/Fargate + CodeDeploy blue/green

auth DB
  -> RDS MySQL 또는 별도 private DB endpoint

redis-service / monitoring-service
  -> EC2 유지
```

핵심 판단:

- 현재는 `m7i-flex.large` 단일 EC2 통합 배포를 먼저 사용합니다.
- `auth-service`는 장기적으로 무중단 배포가 필요하므로 ECS/Fargate 승격 대상입니다.
- DB는 여전히 애플리케이션 runtime과 분리합니다.
- Docker Compose의 MySQL 컨테이너 구성은 로컬, 개발, 임시 검증 용도로만 취급합니다.

## 브랜치 분리 대신 환경 분리를 택한 이유

한때 아래 구조도 고민했습니다.

```text
dev 브랜치
  개발용 Docker Compose, 개발용 인프라 정의

main 브랜치
  운영용 Docker Compose, 운영용 인프라 정의
```

겉으로는 단순해 보이지만, 이 서비스에는 장기적으로 불리하다고 판단했습니다.

문제점:

- 같은 서비스의 배포 정의가 브랜치마다 갈라져 drift가 쉽게 생깁니다.
- `main`에서 운영 hotfix를 한 뒤 `dev` 쪽 인프라 정의와 다시 맞추는 비용이 커집니다.
- 어느 커밋이 실제로 dev/prod 모두에 배포 가능한 상태인지 추적하기 어려워집니다.
- rollback, cherry-pick, release tag 판단이 코드와 설정 양쪽에서 복잡해집니다.
- CI/CD가 한 브랜치의 설정만 검증하면 다른 브랜치의 배포 정의는 쉽게 깨집니다.

이 repo는 처음부터 "같은 코드 + 환경 선택" 구조에 더 가깝습니다.

현재 근거:

- `app/src/main/resources/application.yml`은 `spring.profiles.active` 기준으로 `dev`/`prod` 설정을 import합니다.
- Docker는 `docker/compose.yml` 공통 정의 위에 `docker/dev/compose.yml`, `docker/prod/compose.yml` override를 얹습니다.
- CD는 `.github/workflows/cd.yml`에서 브랜치와 tag 기준으로 target environment를 결정합니다.
- dev/prod 런타임 값은 `.env.dev`, `.env.prod`, GitHub Environment, AWS secret/variable로 분리할 수 있습니다.

그래서 이 서비스는 브랜치 분리보다 환경 분리를 선택합니다.

선택 이유:

- 애플리케이션 코드와 배포 정의를 한 commit 단위로 함께 검증할 수 있습니다.
- `main`에서 dev/prod 배포 정의를 동시에 검증해 환경 drift를 줄일 수 있습니다.
- 운영 hotfix가 들어와도 배포 구조가 두 브랜치로 찢어지지 않습니다.
- release, rollback, tag 기준을 코드와 동일한 revision으로 맞출 수 있습니다.
- 차이는 브랜치가 아니라 profile, env file, secret, deploy target에서 관리하는 편이 운영상 더 명확합니다.

현재 운영 원칙:

```text
main
  코드와 배포 정의의 기준 브랜치
  dev/prod 관련 설정 파일을 함께 유지

dev 브랜치
  필요하면 통합/검증 브랜치로 사용
  dev 자동 배포 트리거로 사용할 수 있음
  개발 인프라 정의의 유일한 source로 두지 않음

환경 차이
  application-{env}.yml
  docker/{env}/compose.yml
  .env.{env}
  GitHub Environment
  AWS secret / variable / deploy target
```

빠른 판단:

```text
dev 설정을 main에서 지우고 싶다
  -> branch 분리보다 env file 또는 profile 분리가 맞는지 먼저 본다

운영 비밀값을 코드에서 숨기고 싶다
  -> branch 분리가 아니라 secret store와 environment protection으로 푼다

dev와 prod의 compose 차이가 커진다
  -> 공통 compose + override 구조를 유지하되 차이를 명시적으로 문서화한다

main은 운영만, dev는 개발만 담고 싶다
  -> 단기적으로는 편해 보여도 drift와 rollback 비용이 더 커질 가능성이 높다
```

## 빠른 판단 기준

```text
서비스가 테이블을 소유한다
  -> baseline schema는 서비스 repo에 둔다

prod ddl-auto가 none이다
  -> 신규 DB는 db/schema.sql로 만든다

Docker init.sql을 수정하려 한다
  -> DB/user bootstrap인지 먼저 확인하고, 테이블 DDL은 db/schema.sql에 둔다

DB 변경과 코드 변경이 다른 PR로 갈라진다
  -> 배포 순서와 rollback 위험을 다시 검토한다

AWS 운영 배포에서 MySQL 위치를 정한다
  -> 기본은 RDS 분리, MySQL 컨테이너는 개발/임시 환경으로 제한한다
```

# 문제 해결

## `db/schema.sql` 기준

이유:

- `auth-service`가 `auth_accounts`, `auth_login_attempts`, `mfa_factors`를 직접 소유합니다.
- `prod` profile은 `spring.jpa.hibernate.ddl-auto: none`입니다.
- 운영 DB schema는 애플리케이션 시작으로 자동 변경되지 않습니다.
- 따라서 신규 운영 DB를 처음 만들 baseline schema가 필요합니다.

현재 역할 분리는 아래와 같습니다.

```text
app/src/main/java/.../entity
  현재 애플리케이션의 DB 모델

app/src/main/resources/*_db.yml
  dev/prod DB 연결과 Hibernate DDL 정책

db/schema.sql
  신규 운영 DB baseline schema

scripts/db
  운영 SQL 실행 wrapper가 필요할 때 추가

docker/{dev,prod}/services/mysql/init.sql
  MySQL 컨테이너 최초 DB/user/권한 bootstrap
```

`db/schema.sql`은 테이블 DDL의 단일 source입니다. Docker `init.sql`은 DB/user/권한을 만든 뒤 `SOURCE /schema/auth-schema.sql;`로 `db/schema.sql`을 실행합니다. 현재 migration 파일은 두지 않습니다.

## MSA에서 DB schema 위치

MSA에서는 보통 서비스가 자기 데이터베이스 schema를 소유합니다.
따라서 `auth-service`가 소유하는 테이블의 baseline schema는 `auth-service` repo 안에 두는 것이 실무적으로 안전합니다.

좋은 PR 단위:

```text
entity 변경
repository/service 변경
db/schema.sql 변경
docs/database.md 변경
OpenAPI 변경이 있으면 docs/openapi 변경
```

피해야 할 방식:

```text
entity만 변경하고 db/schema.sql 미반영
운영 SQL을 개인 문서나 별도 위치에만 보관
Docker init.sql에 테이블 DDL 섞기
다른 서비스가 auth DB schema를 직접 변경
```

## Migration 미사용 기준

현재 baseline schema를 직접 관리하는 파일:

```text
db/schema.sql
docs/database.md
```

장점:

- 단순합니다.
- 현재 repo 구조와 잘 맞습니다.
- 신규 DB가 어떤 schema로 시작하는지 파일로 바로 확인할 수 있습니다.

한계:

- DB 내부에 schema 적용 이력이 자동으로 남지 않습니다.
- CI/CD 자동화 수준이 낮습니다.

현재 기준:

```text
지금은 db/schema.sql baseline 유지
현재 migration은 두지 않음
```

## UUID schema 기준

신규 DB는 처음부터 canonical UUID `CHAR(36)` 기준으로 생성합니다.

```sql
id CHAR(36) NOT NULL
```

따라서 `BINARY(16)`에서 `CHAR(36)`으로 바꾸려 했던 이유는 성능 최적화보다 운영 가독성, 디버깅 편의성, 서비스 간 UUID 표현의 일관성을 우선했기 때문입니다.

## EC2 Compose와 ECS/Fargate 중 무엇을 쓸지

이 서비스는 두 방식을 모두 검토했습니다. 구현 이력과 대표 코드 조각은 service-contract의 `conventions/shared/deployment-topologies.md`에 남깁니다.

`EC2 + Docker Compose`가 맞는 경우:

- 한 대 또는 소수의 host에 직접 exporter, sidecar, daemon 성격 구성을 붙여야 합니다.
- 무중단보다 단순 bootstrap과 수동 운영이 우선입니다.
- Redis, monitoring처럼 host 단위 운영이 더 자연스러운 서비스입니다.

`ECS/Fargate + CodeDeploy`가 맞는 경우:

- 새 배포본을 health check로 검증한 뒤 트래픽을 옮겨야 합니다.
- 단일 EC2 컨테이너 교체가 아니라 task set 수준의 blue/green이 필요합니다.
- auth-service처럼 gateway 뒤의 핵심 인증 서비스를 무중단으로 교체해야 합니다.

현재 운영 기본값:

```text
현재 단일 EC2 `m7i-flex.large`
  -> 단일 EC2 + docker compose 통합 배포
  -> auth-service는 gateway 뒤 same-host compose network로 연결

장기 권장
  -> gateway는 ECS/Fargate + public ALB

auth-service
  -> ECS/Fargate + CodeDeploy blue/green

auth DB
  -> RDS MySQL 또는 별도 private DB endpoint

redis-service / monitoring-service
  -> EC2 유지
```

핵심 판단:

- 현재는 `m7i-flex.large` 단일 EC2 통합 배포를 먼저 사용합니다.
- `auth-service`는 장기적으로 무중단 배포가 필요하므로 ECS/Fargate 승격 대상입니다.
- DB는 여전히 애플리케이션 runtime과 분리합니다.
- Docker Compose의 MySQL 컨테이너 구성은 로컬, 개발, 임시 검증 용도로만 취급합니다.

## 브랜치 분리 대신 환경 분리를 택한 이유

한때 아래 구조도 고민했습니다.

```text
dev 브랜치
  개발용 Docker Compose, 개발용 인프라 정의

main 브랜치
  운영용 Docker Compose, 운영용 인프라 정의
```

겉으로는 단순해 보이지만, 이 서비스에는 장기적으로 불리하다고 판단했습니다.

문제점:

- 같은 서비스의 배포 정의가 브랜치마다 갈라져 drift가 쉽게 생깁니다.
- `main`에서 운영 hotfix를 한 뒤 `dev` 쪽 인프라 정의와 다시 맞추는 비용이 커집니다.
- 어느 커밋이 실제로 dev/prod 모두에 배포 가능한 상태인지 추적하기 어려워집니다.
- rollback, cherry-pick, release tag 판단이 코드와 설정 양쪽에서 복잡해집니다.
- CI/CD가 한 브랜치의 설정만 검증하면 다른 브랜치의 배포 정의는 쉽게 깨집니다.

이 repo는 처음부터 "같은 코드 + 환경 선택" 구조에 더 가깝습니다.

현재 근거:

- `app/src/main/resources/application.yml`은 `spring.profiles.active` 기준으로 `dev`/`prod` 설정을 import합니다.
- Docker는 `docker/compose.yml` 공통 정의 위에 `docker/dev/compose.yml`, `docker/prod/compose.yml` override를 얹습니다.
- CD는 `.github/workflows/cd.yml`에서 브랜치와 tag 기준으로 target environment를 결정합니다.
- dev/prod 런타임 값은 `.env.dev`, `.env.prod`, GitHub Environment, AWS secret/variable로 분리할 수 있습니다.

그래서 이 서비스는 브랜치 분리보다 환경 분리를 선택합니다.

선택 이유:

- 애플리케이션 코드와 배포 정의를 한 commit 단위로 함께 검증할 수 있습니다.
- `main`에서 dev/prod 배포 정의를 동시에 검증해 환경 drift를 줄일 수 있습니다.
- 운영 hotfix가 들어와도 배포 구조가 두 브랜치로 찢어지지 않습니다.
- release, rollback, tag 기준을 코드와 동일한 revision으로 맞출 수 있습니다.
- 차이는 브랜치가 아니라 profile, env file, secret, deploy target에서 관리하는 편이 운영상 더 명확합니다.

현재 운영 원칙:

```text
main
  코드와 배포 정의의 기준 브랜치
  dev/prod 관련 설정 파일을 함께 유지

dev 브랜치
  필요하면 통합/검증 브랜치로 사용
  dev 자동 배포 트리거로 사용할 수 있음
  개발 인프라 정의의 유일한 source로 두지 않음

환경 차이
  application-{env}.yml
  docker/{env}/compose.yml
  .env.{env}
  GitHub Environment
  AWS secret / variable / deploy target
```

빠른 판단:

```text
dev 설정을 main에서 지우고 싶다
  -> branch 분리보다 env file 또는 profile 분리가 맞는지 먼저 본다

운영 비밀값을 코드에서 숨기고 싶다
  -> branch 분리가 아니라 secret store와 environment protection으로 푼다

dev와 prod의 compose 차이가 커진다
  -> 공통 compose + override 구조를 유지하되 차이를 명시적으로 문서화한다

main은 운영만, dev는 개발만 담고 싶다
  -> 단기적으로는 편해 보여도 drift와 rollback 비용이 더 커질 가능성이 높다
```

## 빠른 판단 기준

```text
서비스가 테이블을 소유한다
  -> baseline schema는 서비스 repo에 둔다

prod ddl-auto가 none이다
  -> 신규 DB는 db/schema.sql로 만든다

Docker init.sql을 수정하려 한다
  -> DB/user bootstrap인지 먼저 확인하고, 테이블 DDL은 db/schema.sql에 둔다

DB 변경과 코드 변경이 다른 PR로 갈라진다
  -> 배포 순서와 rollback 위험을 다시 검토한다

AWS 운영 배포에서 MySQL 위치를 정한다
  -> 기본은 RDS 분리, MySQL 컨테이너는 개발/임시 환경으로 제한한다
```
