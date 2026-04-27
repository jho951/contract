# Monitoring Troubleshooting

이 contract 레포에서 `monitoring-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
target, security, ops 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../shared/monitoring.md](../../../conventions/shared/monitoring.md)
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../artifacts/openapi/v1/monitoring-service.yaml](../../artifacts/openapi/v1/monitoring-service.yaml)
- [v2.md](v2.md)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- dev/prod target file이 같은 container path로 overlay되는지 먼저 확인한다.
- Grafana host port `3005 -> 3000`, Prometheus readiness, Loki bind 주소가 bundle과 같은지 확인한다.
- datasource provisioning이 Auth/User/Editor/Authz current runtime 이름과 일치하는지 확인한다.
- Grafana/Loki/Prometheus는 public traffic이 아니라 operator/private access를 전제로 둔다.
- DNS, TLS, reverse proxy가 없는 상태에서 grafana public domain만 먼저 열지 않는다.
