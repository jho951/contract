# Authz Troubleshooting

이 contract 레포에서 `authz-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
RBAC, policy, cache, ops, error 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../shared/security.md](../../../conventions/shared/security.md)
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../artifacts/openapi/v1/authz-service.yaml](../../artifacts/openapi/v1/authz-service.yaml)
- [v2.md](v2.md)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- `POST /permissions/internal/admin/verify` 입력 헤더와 Gateway 위임 경로가 current contract와 맞는지 확인한다.
- `AUTHZ_SPRING_DATASOURCE_*`와 legacy `PERMISSION_*` prefix가 환경별로 섞여 있지 않은지 확인한다.
- 권한 판정 실패는 role 데이터보다 internal auth 문맥, trace header, cache invalidation 순서를 먼저 본다.
- Redis/DB 연결은 readiness 이전에 실패하기 쉬우므로 compose alias와 datasource interpolation을 먼저 점검한다.
- platform security/governance env preset이 editor나 다른 서비스 값으로 새지 않았는지 확인한다.
