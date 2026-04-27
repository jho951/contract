# Templates

이 디렉토리는 서비스 레포에 복사하거나 PR 본문에 붙일 수 있는 템플릿과 예시 문서를 담는다.

## Templates
| File | Purpose |
| --- | --- |
| [contract-lock-template.yml](contract-lock-template.yml) | 모든 서비스/프론트 레포용 `contract.lock.yml` 기본 템플릿 |
| [agent-task-template.md](agent-task-template.md) | AI agent 작업 지시 템플릿 |
| [readme-contract-source-monitoring.md](readme-contract-source-monitoring.md) | monitoring-service README에 넣을 contract source 섹션 |
| [readme-contract-source-frontend.md](readme-contract-source-frontend.md) | 프론트엔드 README에 넣을 contract source 섹션 |
| [service-repo/README.md](service-repo/README.md) | 서비스 repo용 compose validation / deploy wrapper 스크립트 템플릿 |
| [single-ec2/README.md](single-ec2/README.md) | 단일 EC2 `m7i-flex.large` bootstrap, compose override, `.env.prod` 템플릿 |
| [single-ec2/deploy-bundle/README.md](single-ec2/deploy-bundle/README.md) | 앱 레포 clone 없이 ECR image만으로 단일 EC2를 올리는 deploy bundle |
| [single-ec2/nginx.single-ec2.conf.example](single-ec2/nginx.single-ec2.conf.example) | 단일 EC2에서 `api`, `editor`, `explain`, `grafana`를 도메인별로 프록시하는 Nginx 예시 |

## Notes
- 새 서비스 레포에는 `contract.lock.yml`을 우선 배치한다.
- GitHub Actions workflow 템플릿은 [../github/workflow-templates/contract-check.yml](../github/workflow-templates/contract-check.yml)을 기준으로 복사한다.
- compose validation이 필요한 서비스 레포는 [../scripts/service-repo/](../scripts/service-repo/)의 wrapper를 그대로 복사하는 쪽을 기본으로 본다.
- `consumes`에는 해당 서비스가 직접 참조하는 문서와 OpenAPI만 남긴다.
