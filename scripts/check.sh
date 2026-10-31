#!/bin/sh

set -eu

repo_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
expected_dist="$repo_dir/dist/bootstrap-custom-dark.css"
temp_root=${TMPDIR:-/tmp}
generated_dist=$(mktemp "${temp_root%/}/phpipam-modern-check.XXXXXX")

cleanup() {
  rm -f -- "$generated_dist"
}
trap cleanup EXIT HUP INT TERM

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$repo_dir"/scripts/*.sh
else
  printf 'warning: shellcheck not found; skipping shell lint\n' >&2
fi

OUTPUT_FILE=$generated_dist "$repo_dir/scripts/build.sh"

if ! cmp -s "$expected_dist" "$generated_dist"; then
  printf 'error: dist/bootstrap-custom-dark.css is out of date; run make build\n' >&2
  diff -u "$expected_dist" "$generated_dist" || true
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  matches=$(rg --line-number --hidden --glob '!.git/**' \
    '/(Users|home)/[^/[:space:]]+/' "$repo_dir" || true)
else
  matches=$(grep -RnE --exclude-dir=.git \
    '/(Users|home)/[^/[:space:]]+/' "$repo_dir" || true)
fi

if [ -n "$matches" ]; then
  printf 'error: local developer paths found:\n%s\n' "$matches" >&2
  exit 1
fi

printf 'All checks passed.\n'
