# ADR-0014: 감사는 선택 기능이 아니라 Cross-Service 계약으로 다룬다

- Status: Accepted
- Date: 2026-04-27

## 배경

감사 이벤트는 인증, 인가, 개인정보, 문서 변경, 운영 조작처럼 여러 서비스에서 발생한다. 서비스별로 다른 기준을 쓰면 사건 해석, 증적 보존, 상관관계 추적이 어려워진다.

## 결정

- 감사는 개별 서비스의 부가 기능이 아니라 cross-service 계약으로 다룬다.
- 어떤 이벤트를 감사 대상으로 삼는지와 최소 필드 기준은 공통 문서에서 정의한다.
- 서비스별 상세 이벤트 목록은 구현 레포가 소유하되, 공통 해석 기준은 공유한다.
- token, password, secret, raw credential 같은 민감값은 감사 이벤트에 남기지 않는다.
- 공통 감사 모듈과 platform seam은 별도 ecosystem 문서 기준을 따른다.

## 결과

- 인증, 권한, 편집, 운영 이벤트를 같은 기준으로 해석할 수 있다.
- incident analysis와 compliance 성격의 추적성이 좋아진다.
- 서비스가 달라도 request/correlation 축으로 이벤트를 연결하기 쉬워진다.
- 감사 필드나 의미 변경은 단일 서비스 변경이 아니라 공통 계약 변경으로 다뤄야 한다.

## 연관 문서

- [../conventions/shared/audit.md](../conventions/shared/audit.md)
- [../services/registry/module-ecosystem.md](../services/registry/module-ecosystem.md)
- [../services/registry/adoption-matrix.md](../services/registry/adoption-matrix.md)
