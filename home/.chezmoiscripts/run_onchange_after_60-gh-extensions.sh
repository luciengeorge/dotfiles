#!/bin/bash
set -uo pipefail
export PATH=/opt/homebrew/bin:$PATH
gh auth status >/dev/null 2>&1 || { echo "gh not logged in, skipping extensions" >&2; exit 0; }
for ext in github/gh-copilot github/gh-stack; do
  gh extension list | grep -q "${ext#*/}" || gh extension install "$ext"
done
