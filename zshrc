export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"


plugins=(gitfast git last-working-dir common-aliases sublime zsh-syntax-highlighting zsh-autosuggestions history-substring-search)
source $ZSH/oh-my-zsh.sh

# Store your own aliases in the ~/.aliases file and load it
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

if [ "$SPIN" ] || command -v spin &> /dev/null; then
  [[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
  [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

  if [ ! "$SPIN" ]; then
    export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
    chruby ruby-3.0.3
  fi
else
  export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
  type -a rbenv > /dev/null && eval "$(rbenv init -)"
fi

if [ ! "$SPIN" ]; then
  unalias rm # No interactive rm by default (brought by plugins/common-aliases)
  export HOMEBREW_NO_ANALYTICS=1
  [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
  type -a thefuck > /dev/null && eval $(thefuck --alias)

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

export BUNDLER_EDITOR=code
export EDITOR="vim"

if ( command -v op &> /dev/null; ); then
  eval "$(op completion zsh)"; compdef _op op
fi

if ( command -v github-copilot-cli &> /dev/null; ); then
  eval "$(github-copilot-cli alias -- "$0")"
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
