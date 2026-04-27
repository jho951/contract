# Infra

`infra`는 서비스별 구현 계약이 아니라 도메인, 공통 라이브러리, 플랫폼 사용 방식, 현재 운영 상태를 인프라 관점에서 빠르게 찾기 위한 문서 묶음이다.

## 문서 목록
| 파일 | 역할 |
| --- | --- |
| [domain-management.md](domain-management.md) | 서비스별 공개 도메인, 내부 주소, 장기 private DNS 기준 |
| [shared-libraries.md](shared-libraries.md) | 공통으로 사용하는 라이브러리와 모듈 카탈로그 |
| [platform-usage.md](platform-usage.md) | 2계층 platform 사용 원칙과 서비스별 적용 매트릭스 |
| [current-status.md](current-status.md) | 현재 운영 모드, rollout 상태, 채택 공백 요약 |
| [deployment-flow.md](deployment-flow.md) | 코드 push부터 ECR, remote deploy, health check까지의 현재 배포 흐름 |

## Source of Truth
- 도메인/엣지 라우팅 기준: [../conventions/shared/single-ec2-edge-routing.md](../conventions/shared/single-ec2-edge-routing.md)
- 현재/장기 배포 토폴로지: [../conventions/shared/deployment-topologies.md](../conventions/shared/deployment-topologies.md)
- 공통 모듈과 platform baseline: [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
- 계층/책임 분리 기준: [../services/registry/service-ownership.md](../services/registry/service-ownership.md)
- 계약 채택 상태: [../services/registry/adoption-matrix.md](../services/registry/adoption-matrix.md)
