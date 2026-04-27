# Gateway Troubleshooting

이 contract 레포에서 `gateway-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
API, security, env, response, execution 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../shared/routing.md](../../../conventions/shared/routing.md)
- [../../shared/headers.md](../../../conventions/shared/headers.md)
- [../../shared/security.md](../../../conventions/shared/security.md)
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../artifacts/openapi/v1/public.yaml](../../artifacts/openapi/v1/public.yaml)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- public `/v1/**` 경로와 backend upstream 경로 ownership이 섞이지 않았는지 확인한다.
- exact path route 등록 구조면 새 하위 경로 추가 시 route entry 누락을 먼저 의심한다.
- `AUTH_SERVICE_URL`, `USER_SERVICE_URL`, `EDITOR_SERVICE_URL`, `AUTHZ_ADMIN_VERIFY_URL`가 현재 topology와 일치하는지 확인한다.
- `PLATFORM_SECURITY_AUTH_JWT_SECRET`, `AUTH_JWT_SHARED_SECRET`, IP guard 설정이 환경별로 일치하는지 확인한다.
- browser 인증이 흔들리면 cookie/session 경로, CORS preflight, `OPTIONS` 허용, trusted header 재주입 순서를 같이 본다.
- 관리자 경로 장애는 Gateway route보다 `POST /permissions/internal/admin/verify` 위임 입력과 timeout을 먼저 본다.
