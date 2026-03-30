# Stack Orchestration

`contract` 레포에서 전체 MSA를 한 번에 기동/종료하는 스크립트입니다.

## Script
- `scripts/msa-stack.sh`

## Commands
```bash
# 레포 동기화 + shared network 준비
./scripts/msa-stack.sh init

# 전체 서비스 up
./scripts/msa-stack.sh up

# 상태 확인
./scripts/msa-stack.sh ps

# 전체 서비스 down
./scripts/msa-stack.sh down
```

## Defaults
- `MSA_HOME=$HOME/msa`
- `SHARED_SERVICE_NETWORK=service-backbone-shared`
- SoT branches:
  - gateway/auth/user/redis: `main`
  - block: `dev`

## Notes
- `Auth-server`는 `.env.dev`가 필요합니다.
- 일부 서비스가 shared network에 기본 미조인인 경우, 스크립트가 `docker network connect --alias`로 보정합니다.
