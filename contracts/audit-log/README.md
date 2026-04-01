# Audit Log Contract

`audit-log`는 모든 서비스가 공통으로 사용하는 감사 이벤트 모듈이다.  
서비스별 비즈니스 로직은 각 서비스가 책임지고, 감사 이벤트의 포맷/전달/보관 원칙은 이 허브에서 고정한다.

## 책임
| 책임 | 범위 |
| --- | --- |
| 공통 감사 포맷 | `actor`, `action`, `resource`, `result`, `traceId`, `correlationId`, `ip`, `userAgent` |
| 이벤트 수집 | 인증, 인가, 프로필, 관리자 작업, 편집, 캐시 변경 이벤트 수집 |
| 증적 보존 | 감사 이벤트는 append-only 성격으로 다루고, 변경/삭제는 제한한다 |
| 서비스 간 표준화 | 서비스별 이벤트를 동일한 계약 필드로 정규화한다 |

## 문서
- [Event Model](event-model.md)
- [Service Events](service-events.md)
- [Security Contract](security.md)
- [Operations Contract](ops.md)

## 계약 원칙
| 원칙 | 설명 |
| --- | --- |
| 공통 헤더 | `traceId`, `correlationId`, `requestId`, `actorId`는 공통 필수 식별자다 |
| 서비스 확장 필드 | 서비스별 고유 값은 `metadata`에 넣는다 |
| 최소 수집 | 비밀값, 원문 토큰, 전체 payload는 저장하지 않는다 |
| 변경 불가 | 감사 이벤트는 원칙적으로 수정하지 않는다 |
| 책임 분리 | 감사 이벤트를 남기는 주체는 각 서비스, 저장/조회 정책은 `audit-log`가 담당한다 |

## 연결 기준
- `Auth-server`는 로그인/세션/MFA/토큰 이벤트를 남긴다.
- `Authz-server`는 정책/역할/위임/인가 판단 이벤트를 남긴다.
- `User-server`는 프로필/가시성/개인정보 공개 정책 이벤트를 남긴다.
- `Gateway`는 관리자 접근 제한, 인증 실패, trusted header 정규화 실패를 남긴다.
- `Block-server`와 `Editor-page`는 문서/블록 편집, 공유, 삭제, 복구, 게시 이벤트를 남긴다.
- `Redis-server`는 캐시 무효화나 운영자 수준 변경만 감사 대상에 포함한다.
