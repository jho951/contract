# Shared Libraries

이 문서는 여러 서비스가 공통으로 사용하거나 표준으로 삼는 라이브러리와 모듈을 정리한다.

## 프론트엔드 공통 모듈

| Library | Repo | Purpose | 주요 소비자 |
| --- | --- | --- | --- |
| `Ui-components-module` | `https://github.com/jho951/Ui-components-module` | 공통 UI 컴포넌트와 토큰 제공 | `Editor-page`, `Explain-page` |

## 백엔드 공통 primitive 라이브러리

| Library | 위치 | 역할 | 현재 사용 방식 |
| --- | --- | --- | --- |
| `auth` | `/module/auth` | 인증, JWT, session primitive | 주로 `platform-security`를 통해 흡수 |
| `audit-log` | `/module/audit-log` | 감사 이벤트 기록 primitive | `platform-governance` 및 감사 흐름의 기반 |
| `file-storage` | `/module/file-storage` | 파일 저장 primitive | `platform-resource`가 조립 |
| `ip-guard` | `/module/ip-guard` | IP/CIDR 평가 primitive | `platform-security`가 조립 |
| `notification` | `/module/notification` | 알림 발송 primitive | `platform-resource` 확장 축 |
| `plugin-policy-engine` | `/module/plugin-policy-engine` | 정책 평가 engine | `authz-service` 인가 런타임의 evaluator |
| `policy-config` | `/module/policy-config` | 정책 정의/설정 primitive | `platform-governance`와 authz 정책 축의 기반 |
| `rate-limiter` | `/module/rate-limiter` | 요청 제한 primitive | `platform-security` 및 서비스별 rate limit port 기반 |

## 현재 사용 원칙
- 3계층 서비스는 raw primitive를 직접 조립하기보다 2계층 platform starter/BOM/public SPI를 통해 사용한다.
- `gateway-service`, `auth-service`, `authz-service`, `user-service`, `editor-service`의 mainline compile surface에는 `2026-04-25` 기준 raw 1계층 직접 의존을 남기지 않는 것을 기본선으로 둔다.
- `redis-service`, `monitoring-service`는 deployable infra repo이므로 위 platform 소비 대상이 아니다.

## 연관 문서
- [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
- [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
