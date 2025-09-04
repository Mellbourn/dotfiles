#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only"; exit 1; }
[[ $EUID -eq 0 ]] || { echo "Run with: sudo $0"; exit 1; }

TEMPLATE=/etc/pam.d/sudo_local.template
TARGET=/etc/pam.d/sudo_local
REQ='auth       sufficient     pam_tid.so'

# Ensure sudo_local exists (prefer Apple template)
[[ -f "$TARGET" ]] || { [[ -f "$TEMPLATE" ]] && cp -p "$TEMPLATE" "$TARGET" || printf '# sudo_local\n' >"$TARGET"; }

tmp="$(mktemp)"
# Remove any existing (commented or not) pam_tid.so lines, then prepend the required one
awk '!/^[[:space:]]*#?[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so[[:space:]]*$/' "$TARGET" \
  | { printf '%s\n' "$REQ"; cat; } >"$tmp"

# Replace only if changed
cmp -s "$tmp" "$TARGET" || mv "$tmp" "$TARGET"
rm -f "$tmp"

# Heads-up if sudo doesn't include sudo_local
grep -Eq '(^|[[:space:]])(include|@include)[[:space:]]+sudo_local' /etc/pam.d/sudo || \
  echo "Note: /etc/pam.d/sudo may not include sudo_local."

echo "Touch ID for sudo is enabled."
