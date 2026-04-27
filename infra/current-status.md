# Current Status

## 운영 모드
- 현재 운영 기본선은 "논리적 MSA, 물리적 단일 EC2 통합"이다.
- 앱 서비스는 `gateway-service`, `auth-service`, `user-service`, `authz-service`, `editor-service` 5개다.
- 인프라 서비스는 `redis-service`, `monitoring-service` 2개다.
- 외부 공개 backend 진입점은 `gateway-service` 하나이며, 브라우저는 `https://api.myeditor.n-e.kr`만 직접 호출한다.
- 프론트 공개 주소 기본선은 `https://myeditor.n-e.kr`, `https://editor.myeditor.n-e.kr`이다.

## 배포/도메인 현재값
- 현재 단일 EC2 모드에서는 Nginx가 `127.0.0.1:8080`의 `gateway-service`, `127.0.0.1:8081`의 `editor-page`, `127.0.0.1:3000`의 `explain-page`를 reverse proxy한다.
- `auth-service`, `user-service`, `authz-service`, `editor-service`, `redis-service`는 개별 public 도메인 없이 내부 주소로만 운영한다.
- Grafana는 `https://grafana.myeditor.n-e.kr` 후보를 두되 운영자 제한 공개를 권장한다.

## Platform Rollout 상태
- `gateway-service`, `auth-service`, `authz-service`, `user-service`, `editor-service`는 published `platform 4.0.0`을 소비하는 main 브랜치 상태로 정리됐다.
- 같은 날짜 기준 서비스 CD는 5개 모두 성공했다.
- `authz-service`는 stale container 제거 guard를 추가해 single-EC2 배포 안정화를 보강했다.
- 기준 위 5개 서비스의 mainline compile surface에는 raw 1계층 직접 의존을 남기지 않는 상태를 목표선으로 맞췄다.

## Contract Adoption 상태

| Repo | 상태 | 메모 |
| --- | --- | --- |
| `gateway-service` | `adopted` | `contract.lock.yml` 사용 |
| `auth-service` | `adopted` | `contract.lock.yml` 사용 |
| `authz-service` | `adopted` | `contract.lock.yml` 사용 |
| `user-service` | `adopted` | `contract.lock.yml` 사용 |
| `editor-service` | `adopted` | `contract.lock.yml` 사용 |
| `redis-service` | `adopted` | `contract.lock.yml` 사용 |
| `monitoring-service` | `adopted` | `contract.lock.yml` 사용 |
| `Editor-page` | `partial` | `contract.lock.yml` 없음 |
| `Explain-page` | `partial` | `contract.lock.yml` 없음 |

## 현재 공백
- 프론트 2개 레포는 아직 `contract.lock.yml`과 정식 contract-check workflow가 없다.
- 현재 운영 기본선은 단일 EC2 통합이므로 고가용성/무중단 기본값은 아니다.
- 장기 목표는 `gateway-service`만 public ALB를 두고, `auth-service`, `user-service`, `authz-service`, `editor-service`는 private DNS 뒤로 이동하는 구조다.
- `redis-service`, `monitoring-service`는 장기적으로도 EC2/self-managed 축을 유지하는 방향이 기본선이다.

## 연관 문서
- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
- [../conventions/shared/single-ec2-edge-routing.md](../conventions/shared/single-ec2-edge-routing.md)
- [../services/registry/adoption-matrix.md](../services/registry/adoption-matrix.md)
- [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
