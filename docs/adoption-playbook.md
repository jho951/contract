# Adoption Playbook

## 1) 서비스 레포에 Contract Link 추가
- README 상단에 Contract Source 섹션 추가
- `https://github.com/jho951/contract` 링크 명시

## 2) CONTRACT_SYNC.md 배치
- 서비스별 SoT 브랜치 명시
- 필수 계약 문서 링크(routing/headers/security/env/openapi)
- 운영 체크리스트 유지

## 3) 계약 변경 절차 강제
- 구현 PR 전에 contract PR 선반영
- breaking change는 버전 증가 + migration 문서 필수

## 4) 정기 점검
- 분기별로 adoption-matrix 상태 갱신
- gateway와 각 서비스의 route/header/security drift 확인
