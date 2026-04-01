# Audit Event Model

## 공통 필드
| 필드 | 설명 |
| --- | --- |
| `eventId` | 이벤트 고유 식별자 |
| `eventType` | 이벤트 유형 |
| `actorId` | 행위자 식별자 |
| `actorType` | `user`, `service`, `system` |
| `action` | 수행 행위 |
| `resourceType` | 대상 리소스 유형 |
| `resourceId` | 대상 리소스 식별자 |
| `result` | `ALLOW`, `DENY`, `SUCCESS`, `FAILURE`, `UPDATED` 등 |
| `traceId` | 분산 추적 식별자 |
| `correlationId` | 요청 상관관계 식별자 |
| `requestId` | 요청 식별자 |
| `ip` | 요청 IP |
| `userAgent` | 요청 UA |
| `metadata` | 서비스별 확장 필드 |

## eventType 규칙
| 분류 | 예시 |
| --- | --- |
| 인증 | `auth.login.success`, `auth.login.failure`, `auth.logout` |
| 인가 | `authz.decision.allow`, `authz.decision.deny`, `authz.policy.update` |
| 사용자 | `user.profile.update`, `user.visibility.update` |
| 관리자 | `gateway.admin.block`, `admin.permission.grant` |
| 편집 | `editor.block.update`, `editor.page.share`, `editor.document.publish` |
| 캐시/운영 | `cache.invalidate`, `cache.flush.rejected` |

## 저장 원칙
| 원칙 | 설명 |
| --- | --- |
| append-only | 이벤트는 새로 추가만 하고 기존 레코드는 덮어쓰지 않는다 |
| 정규화 | 서비스별 로그는 공통 필드로 변환 후 저장한다 |
| 비밀값 제외 | 토큰, 비밀번호, 원문 쿠키는 저장하지 않는다 |
| 선택적 보존 | 운영/보안 정책에 따라 retention 기간을 분리할 수 있다 |

## 조회 원칙
| 원칙 | 설명 |
| --- | --- |
| 내부 전용 | 감사 조회는 기본적으로 내부 관리자/보안 도구에 한정한다 |
| 조건 필터 | `actorId`, `resourceId`, `eventType`, `traceId` 기준 필터를 우선 제공한다 |
| 무결성 확인 | 이벤트 체인이 끊기지 않았는지 검증할 수 있어야 한다 |
