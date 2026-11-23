#!/bin/bash
set -euo pipefail
[[ -n ${CI:-} ]] && exit 0

printf '\n\033[1;34m==> %s\033[0m\n' "Rectangle preferences"
defaults write com.knollsoft.Rectangle SUAutomaticallyUpdate -bool true
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool true
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle internalTilingNotified -bool true
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle moveCursorAcrossDisplays -int 1
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
defaults write com.knollsoft.Rectangle reflowTodo -dict keyCode -int 45 modifierFlags -int 786432
defaults write com.knollsoft.Rectangle toggleTodo -dict keyCode -int 11 modifierFlags -int 786432
