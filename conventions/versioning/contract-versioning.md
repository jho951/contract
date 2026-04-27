# Contract Versioning

contract release 버전은 API route 버전과 별개로 관리한다.
이 레포의 release는 Semantic Versioning을 따르고, 서비스 레포는 `contract.lock.yml`로 소비 기준을 고정한다.
기존 `shared/versioning.md`의 contract release 본문을 여기로 분리했다.

## 버전 규칙
| 버전 파트 | 의미 |
| --- | --- |
| `MAJOR` | breaking contract change |
| `MINOR` | backward compatible extension |
| `PATCH` | 문서 보완, 오타 수정, 비기능 변경 |

## release tag 형식
```text
service-contract-v1.2.0
```

## release에 반드시 남길 것
- 변경 요약
- 영향 서비스
- migration 필요 여부
- 검증 결과

## 버전 올림 판단
### MAJOR
- 기존 public contract나 공통 규칙이 호환 없이 바뀐다.
- 서비스 구현이 새 버전 없이는 기존 client를 계속 지원할 수 없다.

### MINOR
- 기존 contract를 깨지 않는 새 endpoint, field, 옵션, 문서 영역이 추가된다.
- 기존 구현을 유지하면서 선택적으로 확장할 수 있다.

### PATCH
- 오타, 설명 보강, 링크 수정, 비기능 문서 개선이다.
- 구현이나 외부 계약 해석에 영향이 없다.

## lock 규칙
- 서비스 레포는 구현 완료 후 `contract.lock.yml`에 contract `ref`와 `commit`을 고정한다.
- `consumes`에는 실제로 의존하는 문서와 OpenAPI/schema 목록을 적는다.
- CI는 lock 기준 contract commit을 fetch해 서비스 구현과 계약을 대조한다.

## 반영 순서
1. contract 문서와 artifact를 먼저 갱신한다.
2. release tag 또는 참조 ref를 확정한다.
3. 서비스 레포 구현을 맞춘다.
4. 서비스 레포 `contract.lock.yml`의 `ref`, `commit`, `consumes`를 갱신한다.
5. CI 계약 검증, 테스트, smoke를 통과시킨다.

## 주의
- contract 버전이 올랐다고 public API route version을 반드시 올리는 것은 아니다.
- 반대로 public `/v2/**`를 도입하더라도 contract release는 MAJOR, MINOR, PATCH 판단을 별도로 한다.
- breaking change면 migration, rollout, deprecation 계획을 같이 남긴다.
