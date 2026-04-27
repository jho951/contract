# ADR-0015: Health와 Readiness는 서로 다른 계약으로 분리한다

- Status: Accepted
- Date: 2026-04-27

## 배경

서비스가 살아 있는지와 실제 요청을 처리할 준비가 되었는지는 같은 의미가 아니다. 이를 섞어 쓰면 배포 게이트, 장애 판정, 모니터링 알림이 불안정해진다.

## 결정

- liveness와 readiness를 서로 다른 운영 계약으로 분리한다.
- health는 프로세스와 애플리케이션 자체 생존 여부를 뜻한다.
- readiness는 DB, Redis, 필수 downstream 같은 critical dependency 준비 상태를 반영한다.
- adopted 서비스는 health, readiness, metrics 기준을 계약에 포함해야 한다.
- 배포 후 검증과 모니터링은 두 신호를 구분해서 사용한다.

## 결과

- 프로세스 생존과 실제 서비스 가능 상태를 구분해서 판단할 수 있다.
- 배포 후 health는 통과했지만 dependency 미준비인 상태를 더 정확히 다룰 수 있다.
- 모니터링과 alert 정책이 더 명확해진다.
- 서비스별 health/readiness path 변경은 monitoring, deploy, Terraform 기준과 함께 검토해야 한다.

## 연관 문서

- [../conventions/shared/monitoring.md](../conventions/shared/monitoring.md)
- [../conventions/pipeline/test-pass-criteria.md](../conventions/pipeline/test-pass-criteria.md)
- [../services/README.md](../services/README.md)
