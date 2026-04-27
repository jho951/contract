# ADR-0001: Service Contract 레포를 Cross-Service 기준점으로 둔다

- Status: Accepted
- Date: 2026-04-27

## 배경

서비스가 여러 GitHub 레포로 분리되어 있고, 각 레포가 독립적으로 진화하면 인터페이스 해석과 운영 기준이 쉽게 드리프트 난다. 구현 레포만으로는 공통 규칙, 서비스 간 책임 경계, 계약 채택 상태를 한 곳에서 확인하기 어렵다.

## 결정

- 이 레포를 cross-service contract와 공통 운영 규칙의 기준점으로 둔다.
- 코드와 서비스 내부 구현 세부는 각 구현 레포가 소유한다.
- 공통 규칙은 `shared`에 둔다.
- 서비스별 계약 인덱스는 `services`에 둔다.
- 도메인, platform, 운영 현황 요약은 `infra`에 둔다.
- 기술적 아키텍처 결정은 `adr`에 둔다.

## 결과

- 구현 변경 전에 contract 문서를 먼저 정리하는 순서를 강제할 수 있다.
- 서비스별 local 관례가 공통 계약과 충돌할 때 우선 조정할 기준이 생긴다.
- 서비스 구현 레포와 contract 레포의 책임이 분리된다.
- 상세 API 원문은 이 ADR이 아니라 `services/artifacts/openapi`와 서비스 문서에서 계속 관리한다.

## 연관 문서

- [../README.md](../README.md)
- [../conventions/shared/README.md](../conventions/shared/README.md)
- [../services/README.md](../services/README.md)
- [README.md](README.md)
