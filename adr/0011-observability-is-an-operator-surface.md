# ADR-0011: 관측 시스템은 Public Product Surface가 아니라 Operator Surface로 다룬다

- Status: Accepted
- Date: 2026-04-27

## 배경

Grafana, Prometheus, Loki 같은 관측 시스템은 사용자 기능을 제공하는 product surface와 목적이 다르다. 이를 일반 public 서비스처럼 노출하면 보안 경계가 흐려지고 운영 시스템이 불필요하게 외부 공격면이 된다.

## 결정

- 관측 시스템은 operator surface로 분류한다.
- `monitoring-service`는 서비스 runtime의 진실을 직접 소유하지 않고, metric/log/dashboard/alert 운영 기준을 소유한다.
- Grafana 등 운영 UI는 기본적으로 운영자 제한 공개 또는 private 접근을 전제로 둔다.
- product public domain과 observability domain은 분리해서 관리한다.

## 결과

- 운영 시스템 공개 범위를 더 엄격하게 통제할 수 있다.
- product traffic 경계와 operator traffic 경계가 섞이지 않는다.
- monitoring stack의 배포, 접근 정책, alert 기준을 사용자 기능과 분리해 다룰 수 있다.
- public exposure가 필요하더라도 예외로 보고 IP 제한, VPN, 별도 접근 정책을 함께 검토해야 한다.

## 연관 문서

- [../conventions/shared/monitoring.md](../conventions/shared/monitoring.md)
- [../infra/domain-management.md](../infra/domain-management.md)
- [../services/server/monitoring/readme.md](../services/server/monitoring/readme.md)
