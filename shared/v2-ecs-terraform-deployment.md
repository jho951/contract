# V2 ECS + Terraform Deployment Contract

이 문서는 현재의 EC2 + Docker image 배포를 v2에서 AWS ECS + Terraform 중심 배포로 전환할 때의 공통 기준을 정의한다.

핵심 선언:

```text
v2에서는 애플리케이션 배포 단위를 EC2 host에서 ECS service로 올리고,
network, security boundary, service runtime은 Terraform으로 관리한다.
```

관련 문서:

- 현재 운영 기준: [single-ec2-deployment.md](single-ec2-deployment.md)
- 배포 방식 이력: [deployment-topologies.md](deployment-topologies.md)
- Terraform 구조 기준: [terraform.md](terraform.md)
- shared network 기준: [terraform/shared-platform-network/README.md](terraform/shared-platform-network/README.md)
- 공통 CI/CD 기준: [ci-cd.md](ci-cd.md)

## 1. 목적

- 현재의 image-only EC2 배포를 service 단위 managed runtime으로 승격한다.
- public / private ingress 경계를 명확히 고정한다.
- 서비스별 Terraform 코드 복제를 막고 공통 모듈 기준으로 정리한다.
- 배포 방식 변경이 API 계약 변경으로 번지지 않게 분리한다.

## 2. 적용 범위

v2 필수 전환 범위:

- `gateway-service`
- `auth-service`
- `user-service`
- `authz-service`
- `editor-service`

v2 후속 전환 또는 별도 트랙:

- `redis-service`
- `monitoring-service`
- `editor-page`
- `explain-page`

기본 원칙:

- backend app service 5개를 우선 ECS로 전환한다.
- stateful 또는 operator 성격이 강한 서비스는 같은 시점에 무리해서 합치지 않는다.
- frontend는 backend ECS 전환의 blocker로 두지 않는다.

## 3. 현재와 v2 비교

| 항목 | 현재 | v2 목표 |
| --- | --- | --- |
| runtime 단위 | 단일 EC2 host + `docker compose` | service별 ECS task / ECS service |
| infra provisioning | EC2, SG, bootstrap, bundle 중심 | VPC, subnet, SG, ALB, ECS, DNS를 Terraform으로 관리 |
| 배포 방식 | EC2에서 image pull 후 container 교체 | ECR image 기반 task definition revision 배포 |
| 서비스 탐색 | compose alias (`auth-service:8081`) | private DNS + internal ALB |
| 외부 진입점 | EC2 public IP 또는 host reverse proxy | public ALB + Route53 public record |
| 내부 경계 | 같은 host network 의존 | private subnet + SG + internal endpoint |
| 확장 단위 | host 단위 | service 단위 desired count / autoscaling |
| 롤백 방식 | 이전 image 재배포 | 이전 task definition 또는 deployment rollback |

## 4. v2 목표 토폴로지

```text
Internet / Client
  -> Route53 public record
  -> public ALB
  -> gateway-service ECS service
  -> auth.internal.platform.local
  -> user.internal.platform.local
  -> authz.internal.platform.local
  -> editor.internal.platform.local

redis-service
  -> private endpoint only

monitoring-service
  -> operator/private access only
```

세부 원칙:

1. public ALB만 internet-facing이다.
2. `gateway-service` task는 private subnet에서 실행하고, ALB만 public subnet에 둔다.
3. `auth-service`, `user-service`, `authz-service`, `editor-service`는 private subnet에만 둔다.
4. 내부 앱 서비스는 public listener를 만들지 않는다.
5. Redis는 public ALB나 public IP를 사용하지 않는다.
6. Monitoring은 operator/private network에서만 접근한다.

## 5. 서비스별 배치 기준

| 서비스 | v2 runtime | ingress | discovery | 메모 |
| --- | --- | --- | --- | --- |
| `gateway-service` | ECS service | public ALB | public DNS | public `/v1/**`, `/v2/**` 소유 |
| `auth-service` | ECS service | internal ALB | `auth.internal.platform.local` | Gateway 또는 내부 caller만 접근 |
| `user-service` | ECS service | internal ALB | `user.internal.platform.local` | public direct exposure 금지 |
| `authz-service` | ECS service | internal ALB | `authz.internal.platform.local` | 관리자 verify / 내부 introspection |
| `editor-service` | ECS service | internal ALB | `editor.internal.platform.local` | editor upstream 전용 |
| `redis-service` | 별도 상태관리 계층 | 없음 | private endpoint | v2 필수 ECS 전환 범위는 아님 |
| `monitoring-service` | 별도 운영 계층 | operator only | private endpoint | v2 필수 ECS 전환 범위는 아님 |
| `editor-page` | 별도 public web delivery | public | site domain | backend cutover blocker로 두지 않음 |
| `explain-page` | 별도 public web delivery | public | site domain | backend cutover blocker로 두지 않음 |

## 6. Terraform 소유 범위

state는 최소 두 층으로 분리한다.

| State | 포함 리소스 |
| --- | --- |
| `env/shared` | VPC, public/private subnet, NAT, route table, public/private Route53 zone, 공통 네트워크 경계 |
| `env/services` | ECS cluster, task execution role, service SG, ALB/TG/listener, ECS service, log group, autoscaling, alarm |

모듈 기준은 [terraform.md](terraform.md)를 따른다.

| Module | 역할 |
| --- | --- |
| `shared-network` | 공통 VPC, subnet, private hosted zone |
| `gateway-service` | public entrypoint, listener, route, gateway runtime |
| `app-service` | `auth-service`, `user-service`, `authz-service`, `editor-service` 공통 배포 단위 |
| `redis` | Redis 상태 저장 계층 |
| `monitoring` | Prometheus/Grafana/Loki 또는 동등 observability 계층 |

금지 사항:

- 서비스별로 거의 같은 ECS/ALB/TG/TG listener 코드를 복사하지 않는다.
- Terraform 바깥에서 콘솔 수동 생성한 리소스를 기준 동작으로 삼지 않는다.
- internal 서비스에 public security group ingress를 열지 않는다.

## 7. Runtime / Config / Secret 기준

이미지 기준:

- registry는 Amazon ECR를 사용한다.
- deploy tag는 `${GITHUB_SHA}` immutable tag를 기본으로 둔다.
- `latest`는 참고용만 허용하고 deploy 입력으로 직접 사용하지 않는다.

설정 기준:

- non-secret 값은 task definition env 또는 Terraform variable로 관리한다.
- secret 값은 AWS Secrets Manager 또는 SSM Parameter Store reference로 주입한다.
- task definition에는 secret의 실제 평문을 commit하지 않는다.

health / metrics 기준:

- health, readiness, metrics path는 각 서비스의 운영 계약을 따른다.
- Terraform health check path는 서비스 repo 문서와 불일치하면 안 된다.
- 자세한 기준은 [monitoring.md](monitoring.md)와 각 서비스의 `ops.md`를 따른다.

Gateway upstream 예시:

```env
AUTH_SERVICE_URL=http://auth.internal.platform.local
USER_SERVICE_URL=http://user.internal.platform.local
EDITOR_SERVICE_URL=http://editor.internal.platform.local
AUTHZ_ADMIN_VERIFY_URL=http://authz.internal.platform.local/permissions/internal/admin/verify
REDIS_HOST=<private-redis-endpoint>
REDIS_PORT=6379
```

즉, v2에서는 compose alias 대신 private DNS 또는 private endpoint를 canonical 값으로 사용한다.

## 8. CI/CD 기준

CI/CD는 [ci-cd.md](ci-cd.md)를 따르되, v2 deploy 단계는 아래 기준으로 바꾼다.

1. Docker image build
2. Amazon ECR push
3. 현재 ECS service가 사용하는 task definition 기준값 조회
4. 새 image URI를 반영한 task definition revision 등록
5. ECS service deployment 실행
6. health / readiness / smoke test 확인

권장 원칙:

- 배포는 host SSH + `docker compose up`가 아니라 ECS deployment로 끝나야 한다.
- 외부 cutover 안정성이 중요한 서비스는 ECS rolling보다 CodeDeploy blue/green을 우선 검토한다.
- rollback은 이전 task definition revision 또는 deployment rollback으로 수행한다.
- public cutover 전후 smoke test는 Gateway public route 기준으로 검증한다.

## 9. 전환 순서

권장 순서:

1. 현재 EC2 기준 env, secret, ECR repository, health endpoint를 inventory로 고정한다.
2. shared network Terraform을 먼저 적용해 VPC, private subnet, hosted zone을 만든다.
3. secret을 EC2 `.env` 파일에서 Secrets Manager 또는 SSM reference 체계로 옮긴다.
4. `auth-service`, `user-service`, `authz-service`, `editor-service`를 private ECS service로 먼저 올린다.
5. 각 내부 서비스 private DNS와 health check가 정상인지 확인한다.
6. `gateway-service`를 ECS + public ALB로 전환하고 upstream 주소를 private DNS로 바꾼다.
7. public Route53 record를 새 ALB로 cutover하고 smoke test를 수행한다.
8. rollback 기준이 확인된 뒤 기존 EC2 compose 경로를 제거한다.

핵심 이유:

- 내부 서비스가 먼저 살아 있어야 gateway cutover가 단순해진다.
- gateway를 마지막에 바꾸면 외부 진입점 변경을 한 번으로 끝낼 수 있다.

## 10. 비목표

- v2 전환 때문에 public API path를 바꾸지 않는다.
- 배포 플랫폼 전환을 이유로 서비스 경계를 합치지 않는다.
- internal 서비스 포트를 internet에 직접 공개하지 않는다.
- Redis, monitoring, frontend를 backend ECS 전환과 강제로 같은 릴리스에 묶지 않는다.
