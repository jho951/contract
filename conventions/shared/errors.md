# Common Error Contract

이 문서는 compatibility 경로다.
공통 에러 응답 envelope의 canonical 문서는 [../api-standard.md](../api-standard.md)다.

## Canonical Source

- 공통 에러 응답 포맷: [../api-standard.md](../api-standard.md)
- 기계 검증용 schema: [../../services/artifacts/schemas/error-envelope.schema.json](../../services/artifacts/schemas/error-envelope.schema.json)

## Ownership

- 공통 envelope shape와 금지 규칙은 `api-standard.md`가 소유한다.
- 서비스별 error code 체계와 상세 분류는 각 구현 레포가 소유한다.

## Notes

- Gateway public 에러와 backend upstream 에러는 같은 envelope shape를 사용한다.
- 운영 로그와 troubleshooting에서는 upstream 원형 `code`를 추적 가능하게 유지한다.
