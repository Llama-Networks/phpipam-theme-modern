#!/bin/sh

set -eu

# Configuration is provided through the environment:
#   PHPIPAM_VERSION       Upstream version without a leading "v" (default: 1.8.3)
#   PHPIPAM_STOCK_SHA256  Required checksum for any non-default version
#   OUTPUT_FILE           Generated stylesheet path (default: dist/ in this repo)

repo_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
source_file="$repo_dir/phpipam-modern.css"
phpipam_version=${PHPIPAM_VERSION:-1.8.3}
output_file=${OUTPUT_FILE:-"$repo_dir/dist/bootstrap-custom-dark.css"}
default_version=1.8.3
default_stock_sha256=9b814bb93a6348264f03f8ad2ec2622f18539bf1b95ff2d0a8677bb44698e605

case "$phpipam_version" in
  ''|*[!A-Za-z0-9._-]*)
    printf 'error: invalid PHPIPAM_VERSION: %s\n' "$phpipam_version" >&2
    exit 1
    ;;
esac

if [ ! -f "$source_file" ]; then
  printf 'error: theme source not found: %s\n' "$source_file" >&2
  exit 1
fi

if [ -n "${PHPIPAM_STOCK_SHA256:-}" ]; then
  expected_stock_sha256=$PHPIPAM_STOCK_SHA256
elif [ "$phpipam_version" = "$default_version" ]; then
  expected_stock_sha256=$default_stock_sha256
else
  printf '%s\n' \
    'error: PHPIPAM_STOCK_SHA256 is required when building a non-default phpIPAM version' >&2
  exit 1
fi

expected_stock_sha256=$(printf '%s' "$expected_stock_sha256" | tr '[:upper:]' '[:lower:]')
case "$expected_stock_sha256" in
  *[!0-9a-f]*)
    printf 'error: PHPIPAM_STOCK_SHA256 must be a lowercase or uppercase SHA-256 digest\n' >&2
    exit 1
    ;;
esac
if [ "${#expected_stock_sha256}" -ne 64 ]; then
  printf 'error: PHPIPAM_STOCK_SHA256 must contain 64 hexadecimal characters\n' >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  printf 'error: curl is required to download the stock phpIPAM stylesheet\n' >&2
  exit 1
fi

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    printf 'error: sha256sum or shasum is required\n' >&2
    return 1
  fi
}

temp_root=${TMPDIR:-/tmp}
stock_file=$(mktemp "${temp_root%/}/phpipam-modern-stock.XXXXXX")
generated_file=$(mktemp "${temp_root%/}/phpipam-modern-build.XXXXXX")

cleanup() {
  rm -f -- "$stock_file" "$generated_file"
}
trap cleanup EXIT HUP INT TERM

stock_url="https://raw.githubusercontent.com/phpipam/phpipam/v${phpipam_version}/css/bootstrap/bootstrap-custom-dark.css"
printf 'Downloading phpIPAM %s stock dark theme...\n' "$phpipam_version"
curl --fail --location --silent --show-error --output "$stock_file" "$stock_url"

actual_stock_sha256=$(sha256_file "$stock_file")
if [ "$actual_stock_sha256" != "$expected_stock_sha256" ]; then
  printf 'error: stock stylesheet checksum mismatch\n' >&2
  printf '  expected: %s\n' "$expected_stock_sha256" >&2
  printf '  actual:   %s\n' "$actual_stock_sha256" >&2
  exit 1
fi

{
  cat <<EOF
/* bootstrap-custom-dark.css — phpIPAM ${phpipam_version} stock dark theme + "phpIPAM Modern" layer.
   Drop-in replacement for css/bootstrap/bootstrap-custom-dark.css. To roll back,
   remove this file override; the stock file is unchanged in the image/install.

   SPDX-License-Identifier: GPL-3.0-only
   Upstream: https://github.com/phpipam/phpipam/blob/v${phpipam_version}/css/bootstrap/bootstrap-custom-dark.css
   Modified by appending the phpIPAM Modern layer (2026). */

EOF

  if grep -q '^@import ' "$source_file"; then
    sed -n '/^@import /p' "$source_file"
    printf '\n'
  fi

  printf '%s\n\n' \
    "/* ===== stock phpIPAM v${phpipam_version} css/bootstrap/bootstrap-custom-dark.css (unmodified) ===== */"
  cat "$stock_file"
  printf '\n%s\n\n' '/* ===== phpIPAM Modern layer (source: phpipam-modern.css) ===== */'
  sed '/^@import /d' "$source_file"
} > "$generated_file"

mkdir -p "$(dirname -- "$output_file")"
chmod 0644 "$generated_file"
mv -f -- "$generated_file" "$output_file"

printf 'Built %s\n' "$output_file"
