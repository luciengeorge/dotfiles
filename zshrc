export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

export HOMEBREW_NO_ANALYTICS=1

plugins=(gitfast git last-working-dir common-aliases sublime zsh-syntax-highlighting history-substring-search)
source $ZSH/oh-my-zsh.sh
unalias rm # No interactive rm by default (brought by plugins/common-aliases)

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

if [[ `system_profiler SPHardwareDataType | grep Serial` =~ "XFN4C7FHLX"  ]]; then
  [[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
  [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

  if [ ! "$SPIN" ]; then
    export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
    chruby ruby-3.0.3
  fi
else
  export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
  type -a rbenv > /dev/null && eval "$(rbenv init -)"

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"
fi

if [ ! "$SPIN" ]; then
  [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
fi

export BUNDLER_EDITOR=code
export EDITOR="vim"

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
