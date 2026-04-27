# ADR-0010: 공통 에러 Envelope를 전 서비스 기준으로 채택한다

- Status: Accepted
- Date: 2026-04-27

## 배경

서비스마다 실패 응답의 필드 이름, 구조, 해석 기준이 다르면 frontend, Gateway, 운영 도구가 에러를 일관되게 처리하기 어렵다. 공통 오류 구조가 없으면 public edge와 downstream 간의 실패 전파도 불안정해진다.

## 결정

- 모든 서비스의 실패 응답은 공통 에러 envelope 기본선을 따른다.
- 서비스별 세부 error code와 도메인 의미는 달라도, client와 Gateway가 읽는 핵심 필드는 같은 축으로 유지한다.
- 공통 에러 구조의 기준은 shared contract 문서가 소유하고, 서비스 문서는 code range와 도메인 의미를 확장한다.
- detailed API payload 예시는 ADR이 아니라 공통 문서와 OpenAPI artifact가 소유한다.

## 결과

- frontend와 Gateway가 실패 응답을 예측 가능한 방식으로 처리할 수 있다.
- 서비스 간 에러 처리 전략을 공통화하기 쉬워진다.
- 세부 error taxonomy는 서비스별로 유지하면서도 공통 클라이언트 동작을 보장할 수 있다.
- error envelope 변경은 사실상 cross-service breaking surface로 다뤄야 한다.

## 연관 문서

- [../conventions/shared/errors.md](../conventions/shared/errors.md)
- [../conventions/coding/rest-api-design.md](../conventions/coding/rest-api-design.md)
- [../services/artifacts/schemas/error-envelope.schema.json](../services/artifacts/schemas/error-envelope.schema.json)
