# Services

`services`는 실제 GitHub repository별 계약 메모와 service inventory를 담는다.
backend 서비스 디렉터리에는 이 contract 레포 기준으로 `readme.md`, `troubleshooting.md`, `v2.md`만 유지합니다.
API/security/ops/errors 같은 상세 문서는 구현 레포가 소유합니다.

## Canonical Docs

- 운영 중인 서비스 목록, 상태, runtime baseline, OpenAPI/Swagger 링크: [inventory.md](inventory.md)
- machine-readable 서비스 메타데이터: [repositories.yml](repositories.yml)

## Service Notes

- backend 서비스 로컬 메모: `server/<service>/readme.md`, `troubleshooting.md`, `v2.md`
- frontend 소비자 메모: `client/editor/README.md`, `client/explain/README.md`
- 구현 레포 기준으로 repo 이름과 runtime host는 항상 같지 않을 수 있으므로, runtime baseline은 `inventory.md`와 `repositories.yml`을 먼저 본다.

## Rules
- 공통 규칙은 여기로 복제하지 않고 [conventions/shared](../conventions/shared/README.md)를 링크한다.
- backend 서비스 디렉터리에서는 `readme.md`, `troubleshooting.md`, `v2.md`만 유지한다.
- API/security/ops/errors 같은 구현 상세 문서는 각 구현 레포가 소유한다.
- OpenAPI와 JSON Schema는 [artifacts](artifacts/README.md)에 둔다.
- frontend repo는 OpenAPI를 직접 소유하지 않고, Gateway public route 계약을 소비한다.
