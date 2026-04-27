# API Versioning

API 버전 관리는 public route version과 backend upstream version을 분리해서 본다.
핵심 원칙은 Gateway가 public API 버전을 소유하고, backend service는 upstream/internal route를 소유한다는 점이다.
기존 `shared/versioning.md`의 public route 관련 본문을 여기로 분리해 가독성을 높였다.

## public route 규칙
| 항목                 | 규칙                      |
|--------------------|-------------------------|
| 소유자                | Gateway                 |
| 기본 안정 버전           | `/v1/**`                |
| breaking 또는 큰 확장   | `/v2/**`                |
| 브라우저/외부 client 진입점 | 항상 Gateway public route |

### 예시

```text
Client:  POST /v1/auth/login
Gateway: POST /auth/login -> auth-service
```

## public version을 올려야 하는 경우
- 기존 request/response shape를 호환 없이 바꿔야 할 때
- 인증/인가 semantics가 바뀌어 기존 client를 그대로 유지할 수 없을 때
- Gateway rewrite만으로 하위 호환을 유지하기 어려울 때
- 같은 route 이름에서 의미가 달라져 client 해석이 깨질 때

## backend upstream 규칙
- backend service는 기본적으로 public `/v1/**` prefix를 직접 구현하지 않는다.
- upstream route는 가능하면 안정적으로 유지한다.
- 같은 서비스가 동시에 두 개의 incompatible upstream contract를 제공해야 할 때만 upstream versioning을 도입한다.
- upstream versioning을 도입하면 구현 레포 문서, 서비스별 `v2.md`, `services/artifacts/openapi/v1/*.yaml` 또는 후속 version artifact를 함께 갱신한다.

## 호환성 우선순위
1. 먼저 Gateway public route에서 버전 분리로 해결할 수 있는지 본다.
2. Gateway rewrite로 해결 가능하면 backend upstream은 유지한다.
3. 그래도 안 되면 backend upstream versioning을 별도 문서로 도입한다.

## 상태 표기
| 상태 | 의미 |
| --- | --- |
| `current` | 현재 구현과 맞는 계약 |
| `draft` | 설계 중, 구현 보장 없음 |
| `planned` | 구현 예정이지만 아직 public contract 아님 |
| `deprecated` | 유지 중이나 제거 예정 |

## API 변경 체크리스트
1. public change인지 upstream/internal change인지 먼저 구분한다.
2. public change면 Gateway route와 client 영향부터 본다.
3. breaking change면 새 public version 또는 migration 전략을 정한다.
4. OpenAPI, 서비스 문서, 에러/보안/헤더 규칙을 함께 갱신한다.
5. 테스트와 smoke 결과를 PR과 CI 기록에 남긴다.
