# API Standard

이 문서는 모든 서비스가 공통으로 따라야 하는 에러 응답 포맷을 정의한다.
서비스별 error code 체계와 세부 분류는 각 구현 레포가 소유하지만, envelope shape은 공통으로 유지한다.

## 공통 에러 응답

```json
{
  "httpStatus": 401,
  "success": false,
  "code": 9101,
  "message": "인증이 필요합니다.",
  "data": null
}
```

## 필드 규칙

| Field | Required | Type | Rule |
| --- | --- | --- | --- |
| `httpStatus` | yes | integer | 실제 HTTP status와 가능하면 동일해야 한다 |
| `success` | yes | boolean | 실패 응답에서는 항상 `false`여야 한다 |
| `code` | yes | string or integer | 서비스/도메인별 에러 코드를 담는다 |
| `message` | yes | string | 사용자 또는 운영자가 이해할 수 있는 문장이어야 한다 |
| `data` | no | any JSON value | validation detail, field error, debug-safe context만 담는다 |

## 예시

### 인증 실패

```json
{
  "httpStatus": 401,
  "success": false,
  "code": "AUTH_REQUIRED",
  "message": "로그인이 필요합니다.",
  "data": null
}
```

### 검증 실패

```json
{
  "httpStatus": 400,
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "요청 값이 올바르지 않습니다.",
  "data": {
    "fieldErrors": [
      {
        "field": "email",
        "reason": "must be a well-formed email address"
      }
    ]
  }
}
```

## 금지 사항

- `success: true`와 함께 에러를 반환하지 않는다.
- token, password, secret, internal stack trace 같은 민감 정보를 `message`나 `data`에 넣지 않는다.
- 서비스별 raw exception class 이름을 public contract처럼 노출하지 않는다.
- Gateway public 응답과 upstream 내부 응답에서 envelope shape를 다르게 만들지 않는다.

## Gateway 처리 원칙

- Gateway는 upstream 에러를 public API 응답으로 정규화할 수 있다.
- 다만 원형 `code`는 운영 로그와 troubleshooting에서 추적 가능해야 한다.
- Gateway 자체 에러도 같은 envelope shape를 사용한다.

## Machine-readable Schema

- canonical schema: [../services/artifacts/schemas/error-envelope.schema.json](../services/artifacts/schemas/error-envelope.schema.json)
- compatibility 문서: [shared/errors.md](shared/errors.md)

## Ownership

- 공통 envelope shape: contract repo
- 서비스별 error code, 상세 분류, local message policy: 각 구현 레포
