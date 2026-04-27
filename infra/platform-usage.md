# Platform Usage

이 문서는 공통 2계층 platform을 서비스들이 어떻게 사용해야 하는지에 대한 운영 기준이다.

## 핵심 규칙
- 의존 방향은 항상 `3계층 service -> 2계층 platform -> 1계층 primitive`를 따른다.
- 3계층 서비스는 `platform-*-starter`, release-train BOM, sanctioned add-on, public SPI만 compile surface로 사용한다.
- 2계층 platform의 internal 구현 class를 서비스가 직접 import하지 않는다.
- 서비스별 차이는 platform 내부 구현 변경이 아니라 preset과 service-owned collaborator bean으로 표현한다.

## 현재 공통 platform baseline

| Platform | Baseline | Purpose | 비고 |
| --- | --- | --- | --- |
| `platform-security` | `4.0.0` | 인증/인가 기본 조립, header, IP guard, rate limit | `auth`, `ip-guard`, `rate-limiter`를 흡수 |
| `platform-governance` | `4.0.0` | 감사, 운영 정책, policy config, governance decision chain | `audit-log`, `policy-config` 축과 연결 |
| `platform-resource` | `4.0.0` | resource lifecycle, metadata, storage orchestration | `file-storage`, `notification` 축을 조립 |
| `platform-integrations` | `4.0.0` | security/resource event와 governance audit bridge | 필요할 때만 optional bridge 사용 |

## 서비스별 현재 적용 매트릭스

| Service | 현재 사용 모듈 | 서비스가 직접 소유하는 대표 seam |
| --- | --- | --- |
| `gateway-service` | `platform-runtime-bom`, `platform-governance-starter`, `platform-security-starter`, `platform-security-hybrid-web-adapter`, `platform-security-governance-bridge` | `GatewayPlatformSecurityWebFilter`, `HybridSecurityRuntime`, `GovernanceAuditSink` |
| `auth-service` | `platform-runtime-bom`, `platform-governance-starter`, `platform-security-starter`, `platform-security-governance-bridge` | `PlatformTokenIssuerPort`, `PlatformSessionIssuerPort`, `PlatformSessionSupportFactory`, `PlatformRateLimitPort`, `GovernanceAuditSink` |
| `user-service` | `platform-runtime-bom`, `platform-governance-starter`, `platform-security-starter`, `platform-security-governance-bridge` | JWT decoder, `PlatformRateLimitPort`, `GovernanceAuditSink` |
| `authz-service` | `platform-runtime-bom`, `platform-governance-starter`, `platform-security-starter`, `platform-security-web-api`, `platform-security-governance-bridge` | internal auth flow, `PlatformRateLimitPort`, `GovernanceAuditSink` |
| `editor-service` | `platform-runtime-bom`, `platform-governance-starter`, `platform-security-starter`, `platform-security-web-api`, `platform-resource-starter`, `platform-resource-jdbc`, `platform-security-governance-bridge`, `platform-resource-governance-bridge`, runtime `platform-resource-support-local` | `ResourceContentStore`, `PlatformRateLimitPort`, `GovernanceAuditSink`, custom `SecurityFailureResponseWriter` |
| `monitoring-service` | 현재 비적용 | Prometheus/Grafana/Loki wrapper는 platform 소비 대상 아님 |
| `redis-service` | 현재 비적용 | real Redis infra는 platform 소비 대상 아님 |

## 운영 메모
- `platform-governance`의 공식 운영 sink SPI는 `GovernanceAuditSink`다.
- `GovernanceAuditRecorder`가 governance audit entry publish SPI다.
- `AuditLogRecorder`는 legacy seam으로 보고 새 mainline 가이드에는 싣지 않는다.
- `platform-security-auth-bridge-starter`, `platform-security-ratelimit-bridge-starter`는 optional migration path이며 현재 mainline 기본선에는 포함하지 않는다.

## 연관 문서
- [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
- [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
- [../services/registry/contract-oss.md](../services/registry/contract-oss.md)
