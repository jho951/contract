# Redis Troubleshooting

이 contract 레포에서 `redis-service`에 남기는 로컬 문서는 `readme.md`, troubleshooting, v2 확장 메모다.
key namespace, security, ops 상세는 구현 레포 문서가 소유한다.

## 먼저 볼 것
- [../../shared/env.md](../../../conventions/shared/env.md)
- [../../shared/monitoring.md](../../../conventions/shared/monitoring.md)
- [../../registry/troubleshooting.md](../../registry/troubleshooting.md)

## 자주 확인하는 드리프트
- compose service key `redis-server`와 shared alias `redis`를 혼동하지 않았는지 확인한다.
- password 정책이 비어 있으면 compose interpolation 단계에서 먼저 실패하는지 확인한다.
- Gateway/Auth/Authz가 같은 Redis host/port와 TTL 정책을 보는지 확인한다.
- exporter metric과 실제 application dependency metric을 함께 봐야 한다.
- 운영자 수준 key 조작은 감사 대상이므로 ad-hoc 수동 삭제를 남용하지 않는다.
