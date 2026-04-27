# ADR-0004: 논리적 MSA와 물리적 단일 EC2 운영 기준을 채택한다

- Status: Accepted
- Date: 2026-04-20

## 배경

서비스 경계는 분리되어 있지만, 현재 단계에서 항상 다중 인스턴스와 무중단 배포 구성을 유지하기에는 비용과 운영 복잡도가 크다. 반대로 모놀리식 배포로 되돌리면 서비스별 책임과 계약 구조를 잃는다.

## 결정

- 현재 운영 기본선은 논리적 MSA, 물리적 단일 EC2 통합으로 둔다.
- 앱 서비스는 독립 repo와 독립 contract를 유지한다.
- 실제 실행은 단일 EC2의 `docker compose` 기반 통합 운영을 기본선으로 둔다.
- 외부 공개 backend는 Gateway만 담당하고, 나머지 앱 서비스와 Redis는 내부 통신으로만 사용한다.
- 장기 목표는 앱 서비스를 public ALB/internal ALB/private DNS 구조로 분리하는 방향을 유지한다.

## 결과

- 현재 단계에서는 비용과 운영 단순성을 우선할 수 있다.
- 서비스 경계, 문서, env, monitoring 기준은 MSA 형태를 유지한다.
- 기본 운영 모드 자체는 고가용성/무중단을 보장하지 않는다.
- 이후 ECS/Fargate 또는 shared VPC 구조로 전환할 때도 contract와 서비스 책임 구조를 재사용할 수 있다.

## 연관 문서

- [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
- [../conventions/shared/single-ec2-deployment.md](../conventions/shared/single-ec2-deployment.md)
- [../infra/current-status.md](../infra/current-status.md)
