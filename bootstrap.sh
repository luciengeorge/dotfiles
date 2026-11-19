#!/bin/bash
# New Mac, one command: see README
set -euo pipefail
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

step "Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || { xcode-select --install; read -rp "Press enter once Command Line Tools are installed" </dev/tty; }

step "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "gh, chezmoi, 1Password"
brew install gh chezmoi
brew install --cask 1password 1password-cli

step "GitHub login"
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web </dev/tty
gh auth setup-git

step "1Password CLI"
until op vault list >/dev/null 2>&1; do
  read -rp "Open 1Password, sign in, enable Settings > Developer > Integrate with 1Password CLI, then press enter" </dev/tty
done

step "dotfiles -> ~/src/luciengeorge/dotfiles (then installs everything, takes a while)"
chezmoi init --apply --source "$HOME/src/luciengeorge/dotfiles" luciengeorge </dev/tty
step "Done. Open a new terminal."
