export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(gitfast git last-working-dir common-aliases sublime zsh-syntax-highlighting history-substring-search)
source $ZSH/oh-my-zsh.sh

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# User configuration
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


if [[ `system_profiler SPHardwareDataType | grep Serial` =~ "XFN4C7FHLX"  ]]; then
  [[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
  [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
fi

export EDITOR="vim"
