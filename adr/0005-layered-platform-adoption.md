# ADR-0005: 3계층 서비스는 2계층 Platform을 통해 1계층 Primitive를 사용한다

- Status: Accepted
- Date: 2026-04-27

## 배경

공통 인증, 감사, resource lifecycle, 정책 평가를 각 서비스가 raw library 수준에서 직접 조립하면 중복과 drift가 늘어난다. 반대로 platform 내부 구현까지 서비스가 직접 의존하면 업그레이드와 책임 분리가 깨진다.

## 결정

- 계층 분류는 `1계층 primitive`, `2계층 platform`, `3계층 deployable service`로 고정한다.
- 3계층 서비스는 2계층 platform의 BOM, starter, sanctioned add-on, public SPI만 사용한다.
- 3계층 서비스가 1계층 primitive를 raw compile dependency로 직접 조립하는 패턴은 기본선에서 피한다.
- 서비스별 차이는 platform 내부 구현 수정이 아니라 preset과 service-owned collaborator seam으로 표현한다.
- 현재 공통 baseline은 `platform 4.0.0`으로 맞춘다.

## 결과

- 공통 보안/감사/runtime 정책을 여러 서비스에 반복 구현하지 않아도 된다.
- platform 업그레이드와 서비스 도메인 구현의 경계가 명확해진다.
- `redis-service`, `monitoring-service`처럼 infra repo 성격의 런타임은 같은 규칙의 직접 적용 대상이 아니다.
- platform 내부 구현 class를 서비스가 직접 가져다 쓰는 경우는 예외로 간주하고 별도 검토가 필요하다.

## 연관 문서

- [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
- [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
- [../infra/platform-usage.md](../infra/platform-usage.md)
