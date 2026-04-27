# ADR-0006: `contract.lock.yml`과 CI로 계약 소비를 고정한다

- Status: Accepted
- Date: 2026-04-15

## 배경

서비스 레포가 어떤 contract 버전을 기준으로 구현되었는지 명시하지 않으면, 문서 변경과 구현 변경의 순서가 어긋나고 CI가 무엇을 검증해야 하는지도 불명확해진다.

## 결정

- contract를 채택한 서비스 레포는 `contract.lock.yml`로 소비 기준을 고정한다.
- lock 파일에는 contract repo, ref, commit, consumes 정보가 들어가야 한다.
- CI의 첫 번째 검증 단계는 `contract-lock`으로 둔다.
- CI는 lock 기준 contract를 fetch해서 구현과 계약의 정합성을 검사한다.
- contract 영향이 있는 변경은 관련 서비스 레포의 lock 갱신을 동반해야 한다.

## 결과

- 서비스 레포가 어떤 contract snapshot을 기준으로 구현되었는지 추적 가능해진다.
- contract 드리프트가 CI 단계에서 더 빨리 드러난다.
- adopted repo와 partial repo를 운영적으로 구분할 수 있다.
- 현재 frontend 소비자 레포는 아직 partial 상태이므로 같은 거버넌스를 완전히 적용하지 못하고 있다.

## 연관 문서

- [../conventions/shared/ci-cd.md](../conventions/shared/ci-cd.md)
- [../conventions/versioning/contract-versioning.md](../conventions/versioning/contract-versioning.md)
- [../services/registry/adoption-matrix.md](../services/registry/adoption-matrix.md)
