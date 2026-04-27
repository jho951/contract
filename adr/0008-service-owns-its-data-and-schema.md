# ADR-0008: 각 서비스는 자기 데이터와 스키마를 소유한다

- Status: Accepted
- Date: 2026-04-27

## 배경

MSA 구조에서 여러 서비스가 같은 데이터 저장소를 암묵적으로 공유하거나, 다른 서비스의 schema를 직접 변경하면 책임 경계가 흐려지고 배포 순서와 장애 영향 범위가 커진다. 특히 운영 DB baseline과 schema 기준이 서비스 바깥에 흩어지면 어떤 저장 구조가 진실인지 판단하기 어려워진다.

## 결정

- 각 deployable service는 자기 업무 데이터와 schema의 source of truth를 직접 소유한다.
- 다른 서비스가 소유한 DB schema를 직접 변경하는 방식은 기본선으로 허용하지 않는다.
- 운영 DB baseline schema와 관련 문서는 해당 서비스 구현 레포 안에서 관리한다.
- contract 레포는 schema 원문보다 ownership boundary와 cross-service 영향만 기록한다.

## 결과

- 데이터 모델 변경의 책임과 리뷰 범위가 명확해진다.
- 서비스별 배포와 롤백 판단이 단순해진다.
- schema 변경이 cross-service coupling으로 번지는 것을 줄일 수 있다.
- 서비스 간 데이터 연동은 DB 공유 대신 API, 이벤트, cache, 파생 저장소 같은 명시적 경계로 다뤄야 한다.

## 연관 문서

- [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
- [../services/server/auth/troubleshooting.md](../services/server/auth/troubleshooting.md)
- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
