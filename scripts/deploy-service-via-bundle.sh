#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_BUNDLE_ROOT="$CONTRACT_ROOT/templates/single-ec2/deploy-bundle"

usage() {
  cat >&2 <<'EOF'
Usage:
  deploy-service-via-bundle.sh \
    --service <service-name> \
    --environment <dev|prod>
EOF
  exit 1
}

SERVICE_NAME=""
TARGET_ENV=""

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
[[ -d "$DEPLOY_BUNDLE_ROOT" ]] || {
  echo "Deploy bundle not found: $DEPLOY_BUNDLE_ROOT" >&2
  exit 1
}

DEPLOY_HOST="${DEPLOY_HOST:?DEPLOY_HOST is required}"
DEPLOY_USER="${DEPLOY_USER:-ec2-user}"
SSH_PORT="${SSH_PORT:-${DEPLOY_PORT:-22}}"
DEPLOY_ROOT="${DEPLOY_ROOT:-${DEPLOY_BUNDLE_DIR:-/opt/deploy}}"
AWS_REGION="${AWS_REGION:?AWS_REGION is required}"

declare -a image_keys
env_file=".env.backend"
deploy_target="$SERVICE_NAME"

case "$SERVICE_NAME" in
  auth-service)
    image_keys=(AUTH_SERVICE_IMAGE)
    ;;
  authz-service)
    image_keys=(AUTHZ_SERVICE_IMAGE)
    ;;
  editor-service)
    image_keys=(EDITOR_SERVICE_IMAGE)
    ;;
  gateway-service)
    image_keys=(GATEWAY_IMAGE)
    ;;
  monitoring-service)
    image_keys=(PROMETHEUS_IMAGE GRAFANA_IMAGE LOKI_IMAGE PROMTAIL_IMAGE)
    ;;
  redis-service)
    image_keys=(REDIS_IMAGE)
    ;;
  user-service)
    image_keys=(USER_SERVICE_IMAGE)
    ;;
  *)
    echo "Unsupported service: $SERVICE_NAME" >&2
    exit 1
    ;;
esac

declare -a remote_assignments
remote_assignments=(
  "SERVICE_NAME=$(printf '%q' "$deploy_target")"
  "TARGET_ENV=$(printf '%q' "$TARGET_ENV")"
  "DEPLOY_ROOT=$(printf '%q' "$DEPLOY_ROOT")"
  "ENV_FILE_NAME=$(printf '%q' "$env_file")"
  "AWS_REGION=$(printf '%q' "$AWS_REGION")"
)

image_key_list=""
for key in "${image_keys[@]}"; do
  value="${!key:-}"
  if [[ -z "$value" ]]; then
    echo "Required image env is missing: $key" >&2
    exit 1
  fi
  remote_assignments+=("$key=$(printf '%q' "$value")")
  if [[ -n "$image_key_list" ]]; then
    image_key_list+=" "
  fi
  image_key_list+="$key"
done
remote_assignments+=("IMAGE_KEYS=$(printf '%q' "$image_key_list")")

REGISTRY="${REGISTRY:-}"
if [[ -z "$REGISTRY" ]]; then
  first_key="${image_keys[0]}"
  first_value="${!first_key}"
  REGISTRY="${first_value%%/*}"
fi
remote_assignments+=("REGISTRY=$(printf '%q' "$REGISTRY")")

ssh_args=(-p "$SSH_PORT" -o BatchMode=yes -o StrictHostKeyChecking=yes)
if [[ -n "${SSH_KEY_PATH:-}" ]]; then
  ssh_args+=(-i "$SSH_KEY_PATH")
fi

echo "Deploying $SERVICE_NAME ($TARGET_ENV) via $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_ROOT"

echo "Syncing locked deploy bundle to $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_ROOT"
tar -C "$DEPLOY_BUNDLE_ROOT" -cf - . | ssh "${ssh_args[@]}" "$DEPLOY_USER@$DEPLOY_HOST" \
  "mkdir -p \"$DEPLOY_ROOT\" && tar -xf - -C \"$DEPLOY_ROOT\" && chmod +x \"$DEPLOY_ROOT\"/scripts/*.sh"

ssh "${ssh_args[@]}" "$DEPLOY_USER@$DEPLOY_HOST" "bash -se" <<EOF
set -euo pipefail
$(printf '%s\n' "${remote_assignments[@]}")

update_env_key() {
  local file="\$1"
  local key="\$2"
  local value="\$3"
  local tmp

  tmp="\$(mktemp)"
  awk -v key="\$key" -v value="\$value" '
    BEGIN { updated = 0 }
    index(\$0, key "=") == 1 {
      print key "=" value
      updated = 1
      next
    }
    { print }
    END {
      if (!updated) {
        print key "=" value
      }
    }
  ' "\$file" > "\$tmp"
  mv "\$tmp" "\$file"
}

aws ecr get-login-password --region "\$AWS_REGION" | docker login --username AWS --password-stdin "\$REGISTRY"

cd "\$DEPLOY_ROOT"
test -f "\$ENV_FILE_NAME"

for key in \$IMAGE_KEYS; do
  update_env_key "\$ENV_FILE_NAME" "\$key" "\${!key}"
done

./scripts/deploy-stack.sh up "\$SERVICE_NAME"
EOF
