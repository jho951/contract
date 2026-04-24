#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: validate-compose-required-env.sh <compose-file> <env-file>" >&2
  exit 1
}

trim_leading() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  printf '%s\n' "$value"
}

COMPOSE_FILE="${1:-}"
ENV_FILE="${2:-}"

[[ -n "$COMPOSE_FILE" && -n "$ENV_FILE" ]] || usage
[[ -f "$COMPOSE_FILE" ]] || { echo "Compose file not found: $COMPOSE_FILE" >&2; exit 1; }
[[ -f "$ENV_FILE" ]] || { echo "Env file not found: $ENV_FILE" >&2; exit 1; }

REQUIRED_KEYS_FILE="$(mktemp)"
ENV_KEYS_FILE="$(mktemp)"
EMPTY_KEYS_FILE="$(mktemp)"

cleanup() {
  rm -f "$REQUIRED_KEYS_FILE" "$ENV_KEYS_FILE" "$EMPTY_KEYS_FILE"
}
trap cleanup EXIT

grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*(:\?|\?)[^}]*required[^}]*\}' "$COMPOSE_FILE" \
  | sed -E 's/^\$\{([A-Za-z_][A-Za-z0-9_]*).*/\1/' \
  | sort -u > "$REQUIRED_KEYS_FILE" || true

while IFS= read -r raw_line; do
  line="$(trim_leading "$raw_line")"
  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue
  if [[ "$line" == export\ * ]]; then
    line="${line#export }"
  fi
  [[ "$line" == *=* ]] || continue

  key="${line%%=*}"
  value="${line#*=}"

  key="${key%"${key##*[![:space:]]}"}"
  value="${value#"${value%%[![:space:]]*}"}"

  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue

  printf '%s\n' "$key" >> "$ENV_KEYS_FILE"
  if [[ -z "$value" ]]; then
    printf '%s\n' "$key" >> "$EMPTY_KEYS_FILE"
  fi
done < "$ENV_FILE"

sort -u -o "$ENV_KEYS_FILE" "$ENV_KEYS_FILE"
sort -u -o "$EMPTY_KEYS_FILE" "$EMPTY_KEYS_FILE"

if [[ ! -s "$REQUIRED_KEYS_FILE" ]]; then
  echo "No required env keys found in $COMPOSE_FILE"
  exit 0
fi

missing_count=0
empty_count=0

while IFS= read -r key; do
  [[ -n "$key" ]] || continue
  if ! grep -Fxq "$key" "$ENV_KEYS_FILE"; then
    echo "Missing required key in $ENV_FILE: $key" >&2
    missing_count=$((missing_count + 1))
    continue
  fi
  if grep -Fxq "$key" "$EMPTY_KEYS_FILE"; then
    echo "Required key is empty in $ENV_FILE: $key" >&2
    empty_count=$((empty_count + 1))
  fi
done < "$REQUIRED_KEYS_FILE"

if [[ $missing_count -gt 0 || $empty_count -gt 0 ]]; then
  echo "Required env validation failed for $COMPOSE_FILE" >&2
  exit 1
fi

echo "Required env validation passed for $COMPOSE_FILE using $ENV_FILE"
