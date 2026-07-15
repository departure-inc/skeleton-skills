#!/bin/sh
# Resolve COMPANY_KNOWLEDGE_ROOT for agents (Cursor / Claude / etc.)
set -e

print_if_dir() {
  if [ -n "$1" ] && [ -d "$1" ]; then
    printf '%s\n' "$1"
    return 0
  fi
  return 1
}

if print_if_dir "${COMPANY_KNOWLEDGE_ROOT:-}"; then
  exit 0
fi

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
config_file="${config_home}/company/knowledge-root"
if [ -f "$config_file" ]; then
  root=$(head -n 1 "$config_file" | tr -d '\r\n')
  if print_if_dir "$root"; then
    exit 0
  fi
fi

if print_if_dir "$HOME/.config/company/skeleton"; then
  exit 0
fi

echo "company-knowledge: root not found." >&2
echo "Set COMPANY_KNOWLEDGE_ROOT, or write an absolute path to ${config_file}," >&2
echo "or clone the company knowledge repo to \$HOME/.config/company/skeleton." >&2
exit 1
