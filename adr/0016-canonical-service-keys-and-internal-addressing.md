# ADR-0016: Canonical Service Key와 내부 주소 규칙을 고정한다

- Status: Accepted
- Date: 2026-04-27

## 배경

repo 이름, compose service key, runtime alias, env 변수 이름이 서로 다르면 운영 문서와 배포 설정이 쉽게 drift 난다. 내부 호출 주소가 환경마다 제각각이면 service discovery와 troubleshooting 비용도 커진다.

## 결정

- 서비스별 canonical service key를 계약 문서 기준으로 고정한다.
- 단일 EC2 baseline에서는 compose alias 기반 내부 주소를 canonical 값으로 본다.
- 장기 topology에서는 private DNS 또는 private endpoint를 canonical 값으로 승격한다.
- public URL, private DNS, compose alias의 역할을 혼동하지 않도록 문서에서 분리한다.
- legacy prefix나 과거 naming이 남아 있어도 canonical 이름 축을 우선 기준으로 삼는다.

## 결과

- env, compose, monitoring, deploy 문서 간 이름 drift를 줄일 수 있다.
- 단일 EC2에서 ECS/private DNS 구조로 전환할 때도 이름 체계를 유지하기 쉬워진다.
- 운영자와 개발자가 같은 주소 체계를 기준으로 대화할 수 있다.
- naming 변경은 단순 문구 수정이 아니라 cross-service 운영 변경으로 봐야 한다.

## 연관 문서

- [../conventions/shared/env.md](../conventions/shared/env.md)
- [../conventions/coding/coding-conventions.md](../conventions/coding/coding-conventions.md)
- [../services/registry/deployment-topology.md](../services/registry/deployment-topology.md)
