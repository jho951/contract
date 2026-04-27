# ADR-0017: Terraform은 Shared State 분리와 역할별 모듈 구조를 따른다

- Status: Accepted
- Date: 2026-04-27

## 배경

모든 인프라를 하나의 Terraform state나 단일 모듈에 몰아넣으면 변경 범위가 커지고, 공통 네트워크와 개별 서비스 배포를 독립적으로 다루기 어렵다. 서비스별로 복사된 Terraform 코드를 늘리는 것도 drift를 만든다.

## 결정

- shared infrastructure와 service infrastructure는 state를 분리한다.
- 모듈은 역할별로 나누고, 서비스 차이는 코드 복사보다 변수로 표현한다.
- 공통 네트워크, 공통 observability, app service, gateway, redis, monitoring은 별도 모듈 축으로 관리한다.
- 환경별 live configuration은 `dev`, `prod` 같은 단위로 분리한다.
- 서비스 계약 변경으로 port, health path, dependency가 바뀌면 Terraform 선언도 함께 갱신한다.

## 결과

- 공통 네트워크와 개별 서비스 배포를 독립적으로 변경하기 쉬워진다.
- Terraform 구조가 서비스 수 증가에 더 안정적으로 대응한다.
- 인프라 코드 복제 대신 공통 모듈 재사용을 기본선으로 둘 수 있다.
- 네트워크와 서비스 state를 분리했기 때문에 변경 계획과 장애 영향 범위를 더 잘 통제할 수 있다.

## 연관 문서

- [../conventions/shared/terraform.md](../conventions/shared/terraform.md)
- [../conventions/shared/terraform/shared-platform-network/README.md](../conventions/shared/terraform/shared-platform-network/README.md)
- [../conventions/shared/v2-ecs-terraform-deployment.md](../conventions/shared/v2-ecs-terraform-deployment.md)
