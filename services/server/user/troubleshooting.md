# User Troubleshooting

이 contract 레포에서 `user-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
API, security, ops, error, visibility 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../shared/security.md](../../../conventions/shared/security.md)
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../artifacts/openapi/v1/user-service.yaml](../../artifacts/openapi/v1/user-service.yaml)
- [v2.md](v2.md)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- public `/users/**`와 internal `/internal/users/**` 책임이 섞이지 않았는지 확인한다.
- `USER_SERVICE_INTERNAL_JWT_*`와 Gateway/Auth internal caller 설정이 같은 값을 보는지 확인한다.
- social link/ensure/find-or-create 흐름은 provider key shape와 unique constraint를 함께 본다.
- capability truth는 authz-service, 공개 여부는 user-service라는 경계가 응답 모델에서 섞이지 않았는지 확인한다.
- `/users/me`와 internal lookup의 envelope 또는 status code가 OpenAPI와 drift 나지 않았는지 확인한다.
