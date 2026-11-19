#!/bin/bash
set -euo pipefail
[[ -x $HOME/.vite-plus/bin/vp ]] && exit 0
curl -fsSL https://vite.plus | VP_NODE_MANAGER=yes bash
