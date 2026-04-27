# gateway-service

## 레포 주소
- https://github.com/jho951/gateway-service

## 역할
- 외부 요청의 단일 진입점으로 public `/v1/**` route를 받아 backend upstream으로 라우팅하는 엣지 서비스입니다.
- 인증, CORS, 공통 헤더 전달, 관리자 권한 검증 같은 cross-cutting 동작을 함께 조정합니다.

## 참고 문서
- [troubleshooting.md](troubleshooting.md)
- [v2.md](v2.md)
