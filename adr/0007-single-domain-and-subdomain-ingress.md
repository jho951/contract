# ADR-0007: 단일 등록 도메인과 서브도메인 Ingress 전략을 채택한다

- Status: Accepted
- Date: 2026-03-31

## 배경

frontend, gateway, 운영 UI를 각각 별도 등록 도메인으로 운영하면 DNS, TLS, redirect, 브라우저 인증 설정이 불필요하게 복잡해진다. 반대로 한 host에 path 기반으로 모든 앱을 우겨 넣으면 프론트 build/base URL 규칙이 복잡해질 수 있다.

## 결정

- 등록 도메인은 하나를 기준으로 둔다.
- 공개 엔드포인트는 같은 등록 도메인 아래 서브도메인으로 분리한다.
- backend public entry는 API 서브도메인을 통해 Gateway로만 연결한다.
- frontend는 각자 전용 서브도메인을 사용한다.
- 운영용 Grafana는 별도 서브도메인을 둘 수 있지만 기본은 운영자 제한 공개로 둔다.

## 결과

- DNS와 인증서 관리 축이 단순해진다.
- 브라우저에서 사용하는 public origin이 명확해진다.
- backend 개별 서비스에 public 도메인을 부여하지 않는 원칙을 유지할 수 있다.
- 장기적으로 public ALB와 private DNS 구조로 전환하더라도 외부 공개 주소 체계는 유지하기 쉽다.

## 연관 문서

- [../infra/domain-management.md](../infra/domain-management.md)
- [../conventions/shared/single-ec2-edge-routing.md](../conventions/shared/single-ec2-edge-routing.md)
- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
