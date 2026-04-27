# Versioning Conventions

이 디렉토리는 API 경로 버전과 contract release 버전을 분리해서 정리한다.
public route, upstream route, release tag, deprecation 상태를 함께 볼 때 사용한다.
기존 `shared/versioning.md`의 본문은 여기로 재구성했고, `shared` 쪽에는 이동 안내만 남긴다.

## 문서
| 문서 | 역할 |
| --- | --- |
| [api-versioning.md](api-versioning.md) | Gateway public route와 backend upstream version 규칙 |
| [contract-versioning.md](contract-versioning.md) | contract release 버전, tag, lock 갱신 기준 |

## 함께 볼 문서
- [../shared/routing.md](../shared/routing.md)
- [../coding/rest-api-design.md](../coding/rest-api-design.md)
- [../api-standard.md](../api-standard.md)
- [../../services/registry/lifecycle.md](../../services/registry/lifecycle.md)
