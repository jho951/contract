# Service Repo Wrapper Templates

이 디렉터리는 각 서비스 repo가 그대로 복사해 쓸 얇은 wrapper 스크립트 템플릿을 둔다.

목적:

- workflow에서 compose validation용 inline env를 제거한다.
- workflow는 repo 안의 wrapper만 호출하고, 실제 env 선택과 required-key 검증은 fetch한 contract repo 스크립트가 담당한다.
- EC2 CD는 `/opt/deploy`의 deploy bundle만 호출하도록 고정한다.

기본 파일:

- `scripts/fetch-contract.sh`: `contract.lock.yml`의 `repo/ref/commit`을 읽어 `.contract`를 lock 기준 commit으로 fetch한다.
- `scripts/validate-compose.sh`: `dev|prod`를 받아 `.contract/scripts/validate-service-compose.sh`를 호출한다.
- `scripts/deploy-stack-service.sh`: `.contract/scripts/deploy-service-via-bundle.sh`를 호출해 lock으로 가져온 deploy bundle을 원격 `/opt/deploy`에 동기화하고, env 갱신 후 `./scripts/deploy-stack.sh up <service>`를 실행한다.

service repo 적용 예:

```bash
mkdir -p scripts
cp templates/service-repo/scripts/fetch-contract.sh <service-repo>/scripts/fetch-contract.sh
cp templates/service-repo/scripts/validate-compose.sh <service-repo>/scripts/validate-compose.sh
cp templates/service-repo/scripts/deploy-stack-service.sh <service-repo>/scripts/deploy-stack-service.sh
chmod +x <service-repo>/scripts/fetch-contract.sh <service-repo>/scripts/validate-compose.sh <service-repo>/scripts/deploy-stack-service.sh
```
