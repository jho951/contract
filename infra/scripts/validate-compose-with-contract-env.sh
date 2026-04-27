#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  validate-compose-with-contract-env.sh \
    --service <service-name> \
    --environment <dev|prod> \
    [--repo-root <repo-root>] \
    [--required-from <compose-file>] \
    --compose-file <compose-file> [--compose-file <compose-file> ...]
EOF
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_ROOT="${ENV_ROOT:-$CONTRACT_ROOT/ci/env}"

SERVICE_NAME=""
TARGET_ENV=""
REPO_ROOT="$(pwd)"
REQUIRED_FROM=""
COMPOSE_FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)
      SERVICE_NAME="${2:-}"
      shift 2
      ;;
    --environment)
      TARGET_ENV="${2:-}"
      shift 2
      ;;
    --repo-root)
      REPO_ROOT="${2:-}"
      shift 2
      ;;
    --required-from)
      REQUIRED_FROM="${2:-}"
      shift 2
      ;;
    --compose-file)
      COMPOSE_FILES+=("${2:-}")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

[[ -n "$SERVICE_NAME" && -n "$TARGET_ENV" && ${#COMPOSE_FILES[@]} -gt 0 ]] || usage
[[ "$TARGET_ENV" == "dev" || "$TARGET_ENV" == "prod" ]] || {
  echo "Unsupported environment: $TARGET_ENV" >&2
  exit 1
}
[[ -d "$REPO_ROOT" ]] || { echo "Repo root not found: $REPO_ROOT" >&2; exit 1; }

ENV_FILE="$ENV_ROOT/$SERVICE_NAME/.env.ci.$TARGET_ENV"
[[ -f "$ENV_FILE" ]] || { echo "Contract env file not found: $ENV_FILE" >&2; exit 1; }

if [[ -z "$REQUIRED_FROM" ]]; then
  last_index=$((${#COMPOSE_FILES[@]} - 1))
  REQUIRED_FROM="${COMPOSE_FILES[$last_index]}"
fi

for compose_file in "${COMPOSE_FILES[@]}"; do
  if [[ ! -f "$compose_file" ]]; then
    echo "Compose file not found: $compose_file" >&2
    exit 1
  fi
done

"$SCRIPT_DIR/validate-compose-required-env.sh" "$REQUIRED_FROM" "$ENV_FILE"

compose_cmd=(docker compose --env-file "$ENV_FILE")
for compose_file in "${COMPOSE_FILES[@]}"; do
  compose_cmd+=(-f "$compose_file")
done
compose_cmd+=(config)

(
  cd "$REPO_ROOT"
  "${compose_cmd[@]}" >/dev/null
)

echo "Compose validation passed for $SERVICE_NAME ($TARGET_ENV)"
