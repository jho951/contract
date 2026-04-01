# Service Audit Events

이 문서는 각 서비스가 `audit-log`로 발행해야 하는 대표 이벤트 범위를 정의한다.

## Auth-server
| 이벤트 | 설명 |
| --- | --- |
| `auth.login.success` | 로그인 성공 |
| `auth.login.failure` | 로그인 실패 |
| `auth.logout` | 로그아웃 |
| `auth.refresh.success` | refresh 성공 |
| `auth.refresh.failure` | refresh 실패 |
| `auth.mfa.challenge` | MFA 챌린지 생성 |
| `auth.mfa.verify.success` | MFA 검증 성공 |
| `auth.mfa.verify.failure` | MFA 검증 실패 |
| `auth.session.revoke` | 세션 무효화 |
| `auth.sso.start` | SSO 시작 |
| `auth.sso.callback.success` | SSO 콜백 성공 |
| `auth.sso.callback.failure` | SSO 콜백 실패 |

## Authz-server
| 이벤트 | 설명 |
| --- | --- |
| `authz.decision.allow` | 권한 허용 |
| `authz.decision.deny` | 권한 거부 |
| `authz.policy.create` | 정책 생성 |
| `authz.policy.update` | 정책 수정 |
| `authz.policy.delete` | 정책 삭제 |
| `authz.role.grant` | 역할 부여 |
| `authz.role.revoke` | 역할 회수 |
| `authz.delegation.grant` | 권한 위임 |
| `authz.delegation.revoke` | 권한 위임 회수 |
| `authz.introspection.success` | 현재 권한 상태 조회 성공 |
| `authz.introspection.failure` | 현재 권한 상태 조회 실패 |

## User-server
| 이벤트 | 설명 |
| --- | --- |
| `user.profile.create` | 프로필 생성 |
| `user.profile.update` | 프로필 수정 |
| `user.visibility.update` | 공개 범위 변경 |
| `user.privacy.update` | 개인정보 공개 정책 변경 |
| `user.social.link` | 소셜 연동 추가 |
| `user.social.unlink` | 소셜 연동 해제 |
| `user.status.lock` | 계정 잠금 |
| `user.status.unlock` | 계정 잠금 해제 |
| `user.internal.create` | 내부 사용자 생성 |

## Gateway
| 이벤트 | 설명 |
| --- | --- |
| `gateway.auth.allow` | 인증 프록시 허용 |
| `gateway.auth.deny` | 인증 프록시 거부 |
| `gateway.admin.block` | 관리자 IP guard 차단 |
| `gateway.internal.secret.reject` | 내부 secret 불일치 |
| `gateway.header.normalize` | trusted header 정규화 |
| `gateway.route.block` | 라우트 레벨 차단 |

## Editor / Block-server
| 이벤트 | 설명 |
| --- | --- |
| `editor.document.create` | 문서 생성 |
| `editor.document.update` | 문서 수정 |
| `editor.document.delete` | 문서 삭제 |
| `editor.document.restore` | 문서 복구 |
| `editor.document.share` | 문서 공유 |
| `editor.document.publish` | 문서 게시 |
| `editor.block.create` | 블록 생성 |
| `editor.block.update` | 블록 수정 |
| `editor.block.move` | 블록 이동 |
| `editor.block.delete` | 블록 삭제 |
| `editor.comment.create` | 댓글 작성 |
| `editor.comment.moderate` | 댓글 관리 |

## Redis-server
| 이벤트 | 설명 |
| --- | --- |
| `cache.invalidate` | 캐시 무효화 |
| `cache.key.delete` | 특정 키 삭제 |
| `cache.namespace.flush` | 네임스페이스 플러시 |
| `cache.operation.reject` | 금지된 운영 명령 거부 |

## 원칙
- 서비스는 고위험 이벤트만 우선 발행해도 된다.
- 모든 debug log를 감사 이벤트로 보내지 않는다.
- 각 서비스는 `audit-log`가 요구하는 공통 필드를 빠뜨리지 않아야 한다.
