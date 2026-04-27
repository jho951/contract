# Deployment Flow

이 문서는 현재 canonical `ec2-compose` 배포 경로에서, 코드 push 이후 실제 배포까지 어떤 단계로 흐르는지 요약한다.

대상:

- `gateway-service`
- `auth-service`
- `authz-service`
- `user-service`
- `editor-service`
- `redis-service`
- `monitoring-service`

## 요약 그림

```mermaid
flowchart TD
  A[Developer push / PR / manual dispatch] --> B[Service repo GitHub Actions workflow]
  B --> C[contract-lock<br/>contract.lock.yml 검증]
  C --> D[fetch-contract.sh<br/>locked contract commit fetch]
  D --> E[compose validation<br/>.contract/scripts/validate-service-compose.sh]
  E --> F[test and build]
  F -->|push main/dev or tag| G[Docker image build]
  G --> H[Amazon ECR push<br/>immutable tag = GITHUB_SHA]
  H -->|workflow_dispatch<br/>deploy_environment=dev/prod| I[deploy gate]
  I --> J[fetch locked contract again]
  J --> K[deploy-stack-service.sh]
  K --> L[.contract/scripts/deploy-service-via-bundle.sh]
  L --> M[Sync deploy bundle assets + scripts<br/>to remote /opt/deploy]
  M --> N[Update /opt/deploy env with new image URI]
  N --> O[/opt/deploy/scripts/deploy-stack.sh up service]
  O --> P[docker compose pull + up -d]
  P --> Q[health check + smoke check]
```

## 핵심 요약

- PR 단계는 `contract-lock`, compose validation, test/build까지만 진행하고 배포는 열지 않는다.
- deployable 서비스는 `main`/`dev` push 또는 tag 기준으로 image를 빌드해 Amazon ECR에 `${GITHUB_SHA}` immutable tag로 push한다.
- 실제 배포는 `workflow_dispatch`와 `deploy_environment=dev|prod` 선택 이후에만 진행한다.
- 원격 EC2는 source build를 하지 않고 `/opt/deploy/scripts/deploy-stack.sh up <service>`로 대상 서비스만 pull/up 한다.
- 배포 helper는 lock된 contract commit을 다시 fetch하므로 CI와 remote deploy 기준이 drift 나지 않는다.

## Source of Truth

- 상세 절차와 품질 게이트: [../conventions/pipeline/ci-cd-procedure.md](../conventions/pipeline/ci-cd-procedure.md)
- workflow 템플릿: [github/workflow-templates/contract-check.yml](github/workflow-templates/contract-check.yml)
- deploy wrapper: [scripts/deploy-service-via-bundle.sh](scripts/deploy-service-via-bundle.sh)
- remote runtime script: [scripts/deploy-bundle/deploy-stack.sh](scripts/deploy-bundle/deploy-stack.sh)
- single EC2 bundle: [templates/single-ec2/deploy-bundle/README.md](templates/single-ec2/deploy-bundle/README.md)
