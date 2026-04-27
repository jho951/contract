# ADR-0012: 배포는 Image-Only 산출물과 Repo-Owned Deploy Bundle 기준으로 운영한다

- Status: Accepted
- Date: 2026-04-27

## 배경

배포 시점에 소스 트리를 서버에서 재조립하거나, 운영 환경이 임의 스크립트에 의존하면 재현성과 추적 가능성이 떨어진다. 반대로 서비스 구현 레포가 자기 배포 산출물 구조를 소유하지 않으면 contract와 runtime 사이의 책임 경계가 애매해진다.

## 결정

- 운영 배포 기본선은 image-only 산출물을 사용한다.
- 배포에 필요한 compose, env example, README, Nginx example 같은 bundle은 각 구현 레포가 직접 소유한다.
- contract 레포는 배포 bundle의 구조 기준과 공통 규칙만 기록한다.
- 단일 EC2든 이후 다른 topology든, 배포 산출물은 repo-owned deploy bundle을 기준으로 검증한다.

## 결과

- 빌드 결과물과 운영 실행 구성이 더 재현 가능해진다.
- 서비스별 배포 정의와 구현 책임이 같은 레포에 모인다.
- contract 레포는 실행 파일 저장소가 아니라 검증 기준과 운영 규칙 저장소 역할에 집중할 수 있다.
- deploy bundle 구조 변경은 서비스 레포와 공통 배포 문서를 함께 갱신해야 한다.

## 연관 문서

- [../conventions/shared/single-ec2-deployment.md](../conventions/shared/single-ec2-deployment.md)
- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
- [../services/client/editor/README.md](../services/client/editor/README.md)
- [../services/client/explain/README.md](../services/client/explain/README.md)
