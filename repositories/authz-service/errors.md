# Authz Error Contract

## Error Code Range
- `400`과 일부 `403`은 공통 `GlobalResponse` envelope로 반환될 수 있다.
- 권한 거부 `403`은 응답 본문이 없을 수 있다.

## Main Errors
| HTTP Status | Code | Message | Meaning |
| :---: | :--- | :--- | :--- |
| 400 | - | X-User-Id 헤더가 필요합니다. | 요청 헤더 누락 |
| 400 | - | X-Original-Method 헤더가 필요합니다. | 요청 헤더 누락 |
| 400 | - | X-Original-Path 헤더가 필요합니다. | 요청 헤더 누락 |
| 400 | - | 허용하지 않는 HTTP Method입니다. | method invalid |
| 400 | - | X-Original-Path는 '/'로 시작해야 합니다. | path format error |
| 400 | - | X-Original-Path에 '..'를 포함할 수 없습니다. | path traversal guard |
| 400 | - | X-Original-Path 형식이 잘못되었습니다. | path format error |
| 403 | - | 응답 본문 없음 또는 `GlobalResponse` | internal caller proof 실패 또는 denied |

## Contract Notes
- OpenAPI의 `VoidGlobalResponse`는 `data: null`인 공통 envelope다.
- Gateway는 외부 실패를 표준화할 수 있으나, 내부 운영 문서에서는 Authz의 원문 메시지와 `code`를 기준으로 기록한다.
