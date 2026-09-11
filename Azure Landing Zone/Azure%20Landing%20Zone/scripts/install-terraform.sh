#!/usr/bin/env bash
set -euo pipefail

VERSION="${TERRAFORM_VERSION:-1.15.8}"
INSTALL_DIR="${TERRAFORM_INSTALL_DIR:-$HOME/bin}"
mkdir -p "$INSTALL_DIR"

if command -v terraform >/dev/null 2>&1 && terraform version | head -1 | grep -q "v${VERSION}"; then
  exit 0
fi

ZIP="terraform_${VERSION}_linux_amd64.zip"
BASE_URL="https://releases.hashicorp.com/terraform/${VERSION}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl --fail --silent --show-error --location "$BASE_URL/$ZIP" --output "$TMP/$ZIP"
curl --fail --silent --show-error --location "$BASE_URL/terraform_${VERSION}_SHA256SUMS" --output "$TMP/SHA256SUMS"
(
  cd "$TMP"
  grep " ${ZIP}$" SHA256SUMS | sha256sum -c -
  unzip -q "$ZIP"
)
install -m 0755 "$TMP/terraform" "$INSTALL_DIR/terraform"

echo "##vso[task.prependpath]$INSTALL_DIR" 2>/dev/null || true
export PATH="$INSTALL_DIR:$PATH"
terraform version
