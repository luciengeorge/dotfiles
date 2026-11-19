#!/bin/bash
set -euo pipefail
printf '\n\033[1;34m==> %s\033[0m\n' "Vite+ (node, npm, pnpm)"
[[ -x $HOME/.vite-plus/bin/vp ]] && exit 0
curl -fsSL https://vite.plus | VP_NODE_MANAGER=yes bash
