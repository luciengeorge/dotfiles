# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"


plugins=(gitfast git last-working-dir common-aliases sublime zsh-syntax-highlighting zsh-autosuggestions history-substring-search)
source $ZSH/oh-my-zsh.sh

# Store your own aliases in the ~/.aliases file and load it
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

unalias rm # No interactive rm by default (brought by plugins/common-aliases)
export HOMEBREW_NO_ANALYTICS=1
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
type -a thefuck > /dev/null && eval $(thefuck --alias)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"
if ( ! command -v spin &> /dev/null; ); then
  export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
  type -a rbenv > /dev/null && eval "$(rbenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

export BUNDLER_EDITOR=code
export EDITOR="vim"

if ( command -v op &> /dev/null; ); then
  eval "$(op completion zsh)"; compdef _op op
fi

if ( command -v gh &> /dev/null; ); then
  eval "$(gh copilot alias -- zsh)"
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

if [ ! "$SPIN" ]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export OPENAI_API_KEY="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"
export PATH="$HOME/.dotnet/tools:$PATH"

# pnpm
export PNPM_HOME="/Users/lucien/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
