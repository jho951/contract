# Domain Management

이 문서는 서비스별 도메인 주소와 현재 내부 호출 주소를 운영 관점에서 한 번에 보려는 목적의 요약이다.

## 현재 공개 도메인 기준

등록 도메인은 `myeditor.n-e.kr` 1개를 기준으로 두고, 공개 엔드포인트는 서브도메인으로 분리한다.

| Host | 연결 서비스 | 현재 upstream | 비고 |
| --- | --- | --- | --- |
| `https://myeditor.n-e.kr` | `explain-page` | Nginx -> `127.0.0.1:3000` | explain UI 기본 진입점 |
| `https://editor.myeditor.n-e.kr` | `editor-page` | Nginx -> `127.0.0.1:8081` | editor UI 진입점 |
| `https://api.myeditor.n-e.kr` | `gateway-service` | Nginx -> `127.0.0.1:8080` | 유일한 public backend 진입점 |
| `https://grafana.myeditor.n-e.kr` | `monitoring-service` Grafana | Nginx -> `127.0.0.1:3005` | 운영자 제한 공개 권장 |

## 서비스별 주소 기준

| Service | 현재 public domain | 현재 내부 주소 기준 | 장기 private DNS/endpoint 기준 | 비고 |
| --- | --- | --- | --- | --- |
| `gateway-service` | `https://api.myeditor.n-e.kr` | `http://127.0.0.1:8080` | public ALB behind `api.myeditor.n-e.kr` | 외부 공개 backend는 gateway만 담당 |
| `auth-service` | 없음 | `http://auth-service:8081` | `http://auth.internal.platform.local` | 개별 public 도메인 없음 |
| `user-service` | 없음 | `http://user-service:8082` | `http://user.internal.platform.local` | 개별 public 도메인 없음 |
| `authz-service` | 없음 | `http://authz-service:8084` | `http://authz.internal.platform.local` | admin verify/internal auth 용도 |
| `editor-service` | 없음 | `http://editor-service:8083` | `http://editor.internal.platform.local` | gateway upstream canonical target |
| `redis-service` | 없음 | `redis:6379` | private subnet address only | ALB/공개 도메인 미사용 |
| `monitoring-service` | `https://grafana.myeditor.n-e.kr` only | `http://127.0.0.1:3005` or internal compose targets | private target/file discovery 기준 | Prometheus/Loki는 public domain 미사용 |
| `editor-page` | `https://editor.myeditor.n-e.kr` | `http://127.0.0.1:8081` | 별도 internal DNS 필요 없음 | 브라우저는 `api.myeditor.n-e.kr` 호출 |
| `explain-page` | `https://myeditor.n-e.kr` | `http://127.0.0.1:3000` | 별도 internal DNS 필요 없음 | 브라우저는 `api.myeditor.n-e.kr` 호출 |

## 운영 규칙
- 현재 단일 EC2 모드에서는 `auth-service`, `user-service`, `authz-service`, `editor-service`, `redis-service`에 개별 public 도메인을 주지 않는다.
- 브라우저는 backend 개별 서비스가 아니라 `gateway-service` 도메인만 직접 호출한다.
- Grafana는 가능하면 public open 대신 운영자 IP 제한 또는 VPN 뒤에 둔다.
- 장기 목표는 `gateway-service`만 public ALB를 두고, 나머지 앱 서비스는 private hosted zone 이름으로 접근하는 구조다.

## 연관 문서
- [../conventions/shared/single-ec2-edge-routing.md](../conventions/shared/single-ec2-edge-routing.md)
- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
- [../services/registry/deployment-topology.md](../services/registry/deployment-topology.md)
