# ADR

`adr`는 이 레포에서 반복적으로 참조되는 기술적 결정을 Architecture Decision Record 형식으로 고정하는 디렉토리다.

## 범위
- cross-service 아키텍처 원칙
- 배포/운영 topology 기준
- platform/library 채택 기준
- contract governance 기준
- 도메인/ingress 같은 운영 경계 결정

## 비범위
- 상세 API path, request/response shape
- 서비스별 구현 코드 설명
- 장애 대응 runbook
- OpenAPI/JSON Schema 원문

상세 API 명세는 `services/artifacts/openapi`, 서비스별 계약 문서, `conventions/coding/rest-api-design.md`가 소유한다.

## ADR 목록
| ID | 제목 | 상태 |
| --- | --- | --- |
| [0001](0001-service-contract-as-cross-service-source-of-truth.md) | Service Contract 레포를 cross-service 기준점으로 둔다 | Accepted |
| [0002](0002-gateway-owns-public-edge.md) | Gateway가 public edge와 외부 backend 진입점을 소유한다 | Accepted |
| [0003](0003-gateway-is-the-trust-boundary.md) | Gateway를 인증/신뢰 경계로 둔다 | Accepted |
| [0004](0004-logical-msa-with-single-ec2-baseline.md) | 논리적 MSA와 물리적 단일 EC2 운영 기준을 채택한다 | Accepted |
| [0005](0005-layered-platform-adoption.md) | 3계층 서비스는 2계층 platform을 통해 1계층 primitive를 사용한다 | Accepted |
| [0006](0006-contract-lock-and-ci-governance.md) | `contract.lock.yml`과 CI로 계약 소비를 고정한다 | Accepted |
| [0007](0007-single-domain-and-subdomain-ingress.md) | 단일 등록 도메인과 서브도메인 ingress 전략을 채택한다 | Accepted |
| [0008](0008-service-owns-its-data-and-schema.md) | 각 서비스는 자기 데이터와 스키마를 소유한다 | Accepted |
| [0009](0009-browser-clients-call-gateway-only.md) | 브라우저 클라이언트는 backend 개별 서비스가 아니라 Gateway만 직접 호출한다 | Accepted |
| [0010](0010-common-error-envelope-across-services.md) | 공통 에러 envelope를 전 서비스 기준으로 채택한다 | Accepted |
| [0011](0011-observability-is-an-operator-surface.md) | 관측 시스템은 public product surface가 아니라 operator surface로 다룬다 | Accepted |
| [0012](0012-image-only-and-repo-owned-deploy-bundles.md) | 배포는 image-only 산출물과 repo-owned deploy bundle 기준으로 운영한다 | Accepted |
| [0013](0013-authz-is-the-final-authorization-authority.md) | 최종 권한 판단과 capability truth는 authz-service가 소유한다 | Accepted |
| [0014](0014-audit-is-a-cross-service-contract.md) | 감사는 선택 기능이 아니라 cross-service 계약으로 다룬다 | Accepted |
| [0015](0015-health-and-readiness-are-distinct-contracts.md) | health와 readiness는 서로 다른 계약으로 분리한다 | Accepted |
| [0016](0016-canonical-service-keys-and-internal-addressing.md) | canonical service key와 내부 주소 규칙을 고정한다 | Accepted |
| [0017](0017-terraform-shared-state-and-role-based-modules.md) | Terraform은 shared state 분리와 역할별 모듈 구조를 따른다 | Accepted |

## 작성 규칙
- ADR은 `배경`, `결정`, `결과`를 중심으로 쓴다.
- 구현 세부나 예시 payload는 넣지 않는다.
- 기존 ADR을 뒤집는 경우 새 ADR을 추가하고 이전 ADR 상태를 `Superseded`로 바꾼다.
- 세부 운영 체크리스트는 `conventions/shared`, `infra`, `services/registry` 문서로 연결한다.
