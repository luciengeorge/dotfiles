#!/bin/bash
set -uo pipefail
[[ -n ${CI:-} ]] && exit 0

printf '\n\033[1;34m==> %s\033[0m\n' "Extra macOS apps (GotEmail, Wonder, Sublime Package Control)"
eval "$(/opt/homebrew/bin/brew shellenv)"

install_gotemail() {
  [[ -d /Applications/GotEmail.app ]] && return 0
  local tmp mnt url dmg
  url=$(curl -fsSL "https://gotemail.net/appcast.xml" | sed -n 's/.*url="\([^"]*\.dmg\)".*/\1/p' | head -n 1)
  [[ -n $url ]] || { echo "warning: could not resolve GotEmail download URL" >&2; return 1; }
  tmp=$(mktemp -d)
  mnt="$tmp/mnt"
  dmg="$tmp/GotEmail.dmg"
  mkdir -p "$mnt"
  if curl -fsSL "$url" -o "$dmg" && hdiutil attach -nobrowse -quiet -mountpoint "$mnt" "$dmg"; then
    cp -R "$mnt/GotEmail.app" /Applications/
    hdiutil detach -quiet "$mnt" || true
  else
    echo "warning: GotEmail install failed" >&2
    rm -rf "$tmp"
    return 1
  fi
  rm -rf "$tmp"
}

install_wonder() {
  [[ -d /Applications/Wonder.app ]] && return 0
  local tmp file url zip
  file=$(curl -fsSL "https://download.todesktop.com/260604iu721fo/latest-mac.yml" | sed -n 's/^[[:space:]]*- url:[[:space:]]*\(.*arm64-mac\.zip\)$/\1/p' | head -n 1)
  [[ -n $file ]] || { echo "warning: could not resolve Wonder download URL" >&2; return 1; }
  url="https://download.todesktop.com/260604iu721fo/$(printf '%s' "$file" | jq -sRr @uri)"
  tmp=$(mktemp -d)
  zip="$tmp/Wonder.zip"
  if curl -fsSL "$url" -o "$zip" && ditto -x -k "$zip" "$tmp/out"; then
    cp -R "$tmp/out/Wonder.app" /Applications/
  else
    echo "warning: Wonder install failed" >&2
    rm -rf "$tmp"
    return 1
  fi
  rm -rf "$tmp"
}

install_sublime_package_control() {
  local dir="$HOME/Library/Application Support/Sublime Text/Installed Packages"
  local pkg="$dir/Package Control.sublime-package"
  [[ -f $pkg ]] && return 0
  mkdir -p "$dir"
  curl -fsSL "https://github.com/sublimehq/package_control/releases/latest/download/Package.Control.sublime-package" -o "$pkg" \
    || echo "warning: Sublime Package Control install failed" >&2
}

install_gotemail || true
install_wonder || true
install_sublime_package_control || true
