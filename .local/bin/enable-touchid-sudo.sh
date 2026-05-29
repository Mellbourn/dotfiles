#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only"; exit 1; }
[[ $EUID -eq 0 ]] || { echo "Run with: sudo $0"; exit 1; }

TEMPLATE=/etc/pam.d/sudo_local.template
TARGET=/etc/pam.d/sudo_local
TID_LINE='auth       sufficient     pam_tid.so'

reattach_module=""
reattach_candidates=(
  /opt/homebrew/lib/pam/pam_reattach.so
  /usr/local/lib/pam/pam_reattach.so
)
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  reattach_candidates=("${HOMEBREW_PREFIX}/lib/pam/pam_reattach.so" "${reattach_candidates[@]}")
fi

for candidate in "${reattach_candidates[@]}"; do
  if [[ -n "$candidate" && -f "$candidate" ]]; then
    reattach_module="$candidate"
    break
  fi
done

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if [[ -f "$TARGET" ]]; then
  source_file="$TARGET"
elif [[ -f "$TEMPLATE" ]]; then
  source_file="$TEMPLATE"
else
  source_file=""
fi

if [[ -n "$source_file" ]]; then
  unexpected_auth_lines=$(awk '
    /^[[:space:]]*auth[[:space:]]+/ && $0 !~ /pam_reattach\.so/ && $0 !~ /pam_tid\.so/ { print }
  ' "$source_file")
  if [[ -n "$unexpected_auth_lines" ]]; then
    echo "Refusing to update $TARGET: found unexpected active auth lines in $source_file:" >&2
    printf '%s\n' "$unexpected_auth_lines" >&2
    exit 1
  fi
fi

{
  if [[ -n "$reattach_module" ]]; then
    printf 'auth       optional       %s\n' "$reattach_module"
  fi
  printf '%s\n' "$TID_LINE"

  if [[ -n "$source_file" ]]; then
    awk '
      /^[[:space:]]*#?[[:space:]]*auth[[:space:]]+[^[:space:]]+[[:space:]]+.*pam_reattach\.so([[:space:]].*)?$/ { next }
      /^[[:space:]]*#?[[:space:]]*auth[[:space:]]+[^[:space:]]+[[:space:]]+pam_tid\.so([[:space:]].*)?$/ { next }
      { print }
    ' "$source_file"
  else
    printf '# sudo_local\n'
  fi
} >"$tmp"

if ! grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]*)?$' "$tmp"; then
  echo "Refusing to update $TARGET: generated file does not enable pam_tid.so" >&2
  exit 1
fi

if [[ -n "$reattach_module" ]]; then
  reattach_line=$(awk '/^[[:space:]]*auth[[:space:]]+[^[:space:]]+[[:space:]]+.*pam_reattach\.so([[:space:]].*)?$/ { print NR; exit }' "$tmp")
  tid_line=$(awk '/^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]*)?$/ { print NR; exit }' "$tmp")
  if [[ -z "$reattach_line" || -z "$tid_line" || "$reattach_line" -ge "$tid_line" ]]; then
    echo "Refusing to update $TARGET: pam_reattach.so must be before pam_tid.so" >&2
    exit 1
  fi
else
  echo "Warning: pam_reattach.so not found; Touch ID may not work inside tmux." >&2
fi

if [[ -f "$TARGET" ]] && cmp -s "$tmp" "$TARGET"; then
  echo "Touch ID for sudo is already configured."
else
  if [[ -f "$TARGET" ]]; then
    backup="${TARGET}.backup.$(date +%Y%m%d-%H%M%S).$$"
    cp -p "$TARGET" "$backup"
    echo "Backed up $TARGET to $backup"
  fi
  install -o root -g wheel -m 600 "$tmp" "$TARGET"
  echo "Touch ID for sudo has been configured."
fi

# Heads-up if sudo doesn't include sudo_local
grep -Eq '(^|[[:space:]])(include|@include)[[:space:]]+sudo_local' /etc/pam.d/sudo || \
  echo "Note: /etc/pam.d/sudo may not include sudo_local."
