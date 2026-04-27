#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  validate-service-compose.sh \
    --service <service-name> \
    --environment <dev|prod> \
    [--repo-root <repo-root>]
EOF
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_ROOT="${ENV_ROOT:-$CONTRACT_ROOT/ci/env}"

SERVICE_NAME=""
TARGET_ENV=""
REPO_ROOT="$(pwd)"

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
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

[[ -n "$SERVICE_NAME" && -n "$TARGET_ENV" ]] || usage
[[ "$TARGET_ENV" == "dev" || "$TARGET_ENV" == "prod" ]] || {
  echo "Unsupported environment: $TARGET_ENV" >&2
  exit 1
}
[[ -d "$REPO_ROOT" ]] || { echo "Repo root not found: $REPO_ROOT" >&2; exit 1; }

ENV_FILE="$ENV_ROOT/$SERVICE_NAME/.env.ci.$TARGET_ENV"
[[ -f "$ENV_FILE" ]] || { echo "Contract env file not found: $ENV_FILE" >&2; exit 1; }

compose_files=()
required_from=""
compose_env_exports=()
repo_env_copy=""
repo_env_backup=""
repo_env_existed="false"

restore_repo_env() {
  if [[ -z "$repo_env_copy" ]]; then
    return 0
  fi

  if [[ "$repo_env_existed" == "true" ]]; then
    cp "$repo_env_backup" "$repo_env_copy"
  else
    rm -f "$repo_env_copy"
  fi

  if [[ -n "$repo_env_backup" ]]; then
    rm -f "$repo_env_backup"
  fi
}

trap restore_repo_env EXIT

prepare_repo_env_copy() {
  repo_env_copy="$1"
  if [[ -f "$repo_env_copy" ]]; then
    repo_env_existed="true"
    repo_env_backup="$(mktemp)"
    cp "$repo_env_copy" "$repo_env_backup"
  fi
  cp "$ENV_FILE" "$repo_env_copy"
}

case "$SERVICE_NAME" in
  auth-service)
    compose_files=(
      "$REPO_ROOT/docker/compose.yml"
      "$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    )
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    compose_env_exports=("AUTH_ENV_FILE=$ENV_FILE")
    ;;
  authz-service)
    compose_files=(
      "$REPO_ROOT/docker/compose.yml"
      "$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    )
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    prepare_repo_env_copy "$REPO_ROOT/.env.$TARGET_ENV"
    ;;
  editor-service)
    compose_files=("$REPO_ROOT/docker/$TARGET_ENV/compose.yml")
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    if [[ "$TARGET_ENV" == "dev" ]]; then
      prepare_repo_env_copy "$REPO_ROOT/.env.dev"
    else
      compose_env_exports=("EDITOR_ENV_FILE=$ENV_FILE")
    fi
    ;;
  gateway-service)
    compose_files=(
      "$REPO_ROOT/docker/compose.yml"
      "$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    )
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    compose_env_exports=("GATEWAY_ENV_FILE=$ENV_FILE")
    ;;
  monitoring-service)
    compose_files=("$REPO_ROOT/docker/$TARGET_ENV/compose.yml")
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    ;;
  redis-service)
    compose_files=("$REPO_ROOT/docker/$TARGET_ENV/compose.yml")
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    ;;
  user-service)
    compose_files=(
      "$REPO_ROOT/docker/compose.yml"
      "$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    )
    required_from="$REPO_ROOT/docker/$TARGET_ENV/compose.yml"
    ;;
  *)
    echo "Unsupported service: $SERVICE_NAME" >&2
    exit 1
    ;;
esac

for compose_file in "${compose_files[@]}"; do
  [[ -f "$compose_file" ]] || { echo "Compose file not found: $compose_file" >&2; exit 1; }
done

"$SCRIPT_DIR/validate-compose-required-env.sh" "$required_from" "$ENV_FILE"

compose_cmd=(docker compose --env-file "$ENV_FILE")
for compose_file in "${compose_files[@]}"; do
  compose_cmd+=(-f "$compose_file")
done
compose_cmd+=(config)

(
  cd "$REPO_ROOT"
  if [[ ${#compose_env_exports[@]} -gt 0 ]]; then
    env "${compose_env_exports[@]}" "${compose_cmd[@]}" >/dev/null
  else
    "${compose_cmd[@]}" >/dev/null
  fi
)

echo "Service compose validation passed for $SERVICE_NAME ($TARGET_ENV)"
