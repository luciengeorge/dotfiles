#!/bin/bash
# New Mac, one command: see README (mirrored to a gist)
set -euo pipefail

xcode-select -p >/dev/null 2>&1 || { xcode-select --install; read -rp "Press enter once Command Line Tools are installed" </dev/tty; }

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install gh chezmoi
brew install --cask 1password 1password-cli

gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web </dev/tty
gh auth setup-git

until op vault list >/dev/null 2>&1; do
  read -rp "Open 1Password, sign in, enable Settings > Developer > Integrate with 1Password CLI, then press enter" </dev/tty
done

chezmoi init --apply luciengeorge </dev/tty
