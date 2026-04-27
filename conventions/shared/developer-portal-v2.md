# Developer Portal v2

Developer Portal v2는 각 서비스 repo가 문서와 API 명세의 원본을 소유하고, 중앙 포털이 이를 수집해서 보여주는 구조를 목표로 한다.

## 목표
- 기술 문서와 API 명세의 authoring source는 각 서비스 repo에 둔다.
- 중앙 문서 포털은 원본 저장소가 아니라 read-only aggregation surface로 둔다.
- 서비스 런타임이 아니라 CI/CD가 문서와 명세를 검증하고 publish한다.
- 중앙 포털은 `Backstage + OpenAPI/Swagger` 조합을 기본 후보로 둔다.

## 핵심 원칙
- `docs/`, `openapi.yaml`, `catalog-info.yaml` 같은 원본은 각 repo에 둔다.
- 공통 규칙, ownership, cross-service boundary는 `service-contract`가 계속 소유한다.
- 중앙 포털은 구현 repo를 대체하지 않는다. 검색, 탐색, 카탈로그, rendered docs를 제공한다.
- 서비스 배포와 문서 포털 배포를 강결합하지 않는다.

## 권장 구조

```txt
Each Service Repo
  -> docs source
  -> OpenAPI source
  -> catalog metadata
  -> CI validate
  -> CI publish artifact

Central Storage
  -> generated TechDocs site
  -> published OpenAPI artifact
  -> versioned metadata

Developer Portal
  -> Backstage catalog
  -> TechDocs reader
  -> API docs viewer
```

## Source of Truth

각 서비스는 최소한 아래 자산의 원본을 자기 repo에 둔다.

- 사람용 기술 문서
- 기계 판독 가능한 OpenAPI 또는 동등한 API spec
- owner, system, lifecycle, dependency metadata

Expected examples:
- `docs/`
- `openapi/openapi.yaml` 또는 repo root의 `openapi.yaml`
- `catalog-info.yaml`

## 중앙 포털 역할

Backstage는 아래 역할을 수행한다.

- 서비스 카탈로그
- owner/system/lifecycle 탐색
- TechDocs rendered view
- OpenAPI rendered view
- 제공 API / 소비 API 관계 시각화

Swagger 또는 OpenAPI tooling은 아래 역할을 수행한다.

- API definition 포맷의 표준화
- OpenAPI lint / validation
- interactive API documentation rendering
- 필요 시 API governance rule 적용

즉 v2 기준 중앙 포털은 `Backstage가 상위 집계 UI`, `OpenAPI/Swagger가 API 표현 포맷과 viewer/tooling` 역할을 맡는다.

## 배포 기준

Backstage는 정적 파일 묶음이 아니라 서버 배포형 애플리케이션으로 본다.

Required runtime components:
- Backstage application server
- catalog/metadata 저장용 database
- generated docs/spec artifact를 읽을 storage

Minimum production-minded baseline:
- Backstage app 1개
- Postgres 1개
- object storage 1개

Allowed PoC baseline:
- 단일 VM 또는 EC2 + Docker Compose
- local DB 또는 small managed Postgres
- local filesystem 또는 low-cost object storage

## Publish 방식

문서와 API 명세는 서비스 런타임이 중앙 서버에 직접 push하지 않는다.

Preferred flow:
1. 개발자가 각 repo에서 문서와 OpenAPI를 수정한다.
2. CI가 lint, schema, link, build 검증을 수행한다.
3. CI가 generated docs와 OpenAPI artifact를 중앙 storage 또는 registry에 publish한다.
4. Backstage는 published artifact를 읽어 렌더링한다.

Notes:
- deploy 성공 여부를 문서 포털의 일시 장애와 강결합하지 않는다.
- 문서 publish는 build/release pipeline의 일부로 본다.
- artifact는 `service + version/tag + git sha` 기준으로 추적 가능해야 한다.

## 보안 기준

- internal API spec는 public 문서처럼 취급하지 않는다.
- 중앙 포털은 사내망 또는 SSO 뒤에 둔다.
- portal에서 보는 OpenAPI `servers` 정보는 환경별로 관리하거나 sanitize할 수 있어야 한다.
- private spec artifact storage 접근 권한은 CI publisher와 portal reader로 분리한다.

## service-contract 역할

v2에서도 `service-contract`는 아래를 소유한다.

- 공통 규칙
- ownership 경계
- public route / upstream route 기준
- 문서/명세 publish 계약
- portal adoption 기준

반대로 `service-contract`가 각 서비스 문서의 영구 원본 저장소가 되지는 않는다.

## 단계별 도입 기준

### Phase 1
- `gateway-service`, `auth-service`, `user-service`만 catalog 등록
- 각 repo의 OpenAPI와 docs를 노출
- 중앙 포털 최소 배포

### Phase 2
- 나머지 서비스 등록
- ownership / system taxonomy 정리
- CI publish 표준화

### Phase 3
- API governance
- docs quality gate
- cross-service dependency graph 강화

## Contract Notes
- 이 문서는 v2 목표 구조다. 현재 구현이 아직 Backstage 또는 central portal을 사용하지 않아도 된다.
- v2 전환 시 각 repo의 문서 위치, OpenAPI 위치, CI publish 단계, access control을 함께 정렬한다.
