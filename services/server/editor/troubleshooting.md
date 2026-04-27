# Editor Troubleshooting

이 contract 레포에서 `editor-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
API, schema, rule, cache, ops, error 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../conventions/coding/rest-api-design.md](../../../conventions/coding/rest-api-design.md)
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../artifacts/openapi/v1/editor-service.yaml](../../artifacts/openapi/v1/editor-service.yaml)
- [v2.md](v2.md)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- Gateway public `/v1/documents/**`, `/v1/editor-operations/**`, `/v1/admin/**`와 upstream `/documents/**`, `/admin/**`가 섞이지 않았는지 확인한다.
- `editor-service`와 `editor-mysql` alias, datasource env, GitHub Packages credential이 배포 bundle과 같은지 확인한다.
- save/move/restore 같은 editor interaction은 CRUD path가 아니라 operation semantic으로 이해해야 한다.
- document와 block의 ordering axis, version 충돌, transaction batch semantics가 FE 기대와 일치하는지 확인한다.
- 502가 Gateway에서 보이면 route보다 datasource, startup failure, filesystem backing부터 본다.
