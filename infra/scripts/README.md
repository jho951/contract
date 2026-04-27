# Scripts

이 디렉터리는 이 contract repo가 소유하는 실행 스크립트의 canonical source를 둔다.

## 구조

- `validate-compose-required-env.sh`
- `validate-compose-with-contract-env.sh`
- `validate-service-compose.sh`
- `deploy-service-via-bundle.sh`

위 4개는 contract 기준 검증과 원격 deploy wrapper입니다.

- `service-repo/`

서비스 구현 레포의 `scripts/`로 복사해 쓰는 얇은 wrapper입니다.

- `single-ec2/`

단일 EC2 수동/자동 배포 helper입니다.

- `deploy-bundle/`

`/opt/deploy/scripts`로 들어가는 runtime script의 source입니다. 실제 bundle asset은 `templates/single-ec2/deploy-bundle/`와 함께 패키징됩니다.
