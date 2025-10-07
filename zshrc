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

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"

# pnpm
export PNPM_HOME="/Users/lucien/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/lucien/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/lucien/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/lucien/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/lucien/google-cloud-sdk/completion.zsh.inc'; fi

setup_web_app() {
    # Function to display help
    show_help() {
        echo "Usage: setup_web_app [SUBDIR] [OPTIONS]"
        echo
        echo "Watch and build fyxer web application components"
        echo
        echo "Subdirectory Selection (choose one):"
        echo "  1, functions     Watch and build the functions directory"
        echo "  2, app          Watch and build the app directory"
        echo "  3, dataScience  Watch and build the dataScience directory"
        echo
        echo "Options:"
        echo "  --subdir DIR     Explicitly specify the subdirectory"
        echo "  --watch          Watch the build command after building"
        echo "  -h, --help       Display this help message"
        echo "  --run            Run the build command for the app directory"
        echo "Legacy Format (maintained for backwards compatibility):"
        echo "  f, 0            Alternative for functions"
        echo "  a, 1            Alternative for app"
        echo "  d, 2            Alternative for dataScience"
        echo
        echo "Examples:"
        echo "  setup_web_app functions"
        echo "  setup_web_app 2 --watch"
        echo "  setup_web_app --subdir app --watch"
        echo "  setup_web_app --subdir app --run"
        return 0
    }

    # Default subdirectory
    local subdir=""
    local original_dir="$(pwd)"
    local no_watch=false
    local no_build=false

    # Show help if no arguments
    if [ $# -eq 0 ]; then
        show_help
        return 0
    fi

    # Function to handle cleanup on exit
    cleanup() {
        echo -e "\nCleaning up..."
        cd "$original_dir"
        # exit 0
    }

    # Set up trap for Ctrl+C
    trap cleanup SIGINT SIGTERM

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            --subdir)
                subdir="$2"
                shift 2
                ;;
            --watch)
                watch=true
                shift
                ;;
            --run)
                run=true
                shift
                ;;
            "1"|"functions")
                subdir="functions"
                shift
                ;;
            "2"|"app")
                subdir="app"
                shift
                ;;
            "3"|"dataScience")
                subdir="dataScience"
                shift
                ;;
            *)
                # Handle legacy format and direct argument without --subdir flag
                case "${1,,}" in  # Convert to lowercase for comparison
                    "d"|"datascience"|"2") subdir="dataScience" ;;
                    "f"|"functions"|"0") subdir="functions" ;;
                    "a"|"app"|"1") subdir="app" ;;
                    *)
                        subdir="$1"
                        ;;
                esac
                shift
                ;;
        esac
    done

    # If no subdir provided or if it's invalid, show interactive selection
    if [ -z "$subdir" ] || [[ ! "$subdir" =~ ^(functions|app|dataScience)$ ]]; then
        echo "Select a subdirectory to watch:"
        echo "1 or functions     -> functions"
        echo "2 or app          -> app"
        echo "3 or dataScience  -> dataScience"
        select subdir in "functions" "app" "dataScience"; do
            case $REPLY in
                1|2|3)
                    break
                    ;;
                *)
                    echo "Invalid selection. Please try again."
                    ;;
            esac
        done
    fi

    # Validate subdirectory
    if [[ ! "$subdir" =~ ^(functions|app|dataScience)$ ]]; then
        echo "Error: subdirectory must be one of: functions, app, dataScience"
        echo "You can use: numbers (1,2,3), letters (f,a,d), or full names"
        return 1
    fi

    # check if cwd directory is web-app
    if [ "$(basename "$(pwd)")" != "web-app" ]; then
        echo "Error: Current directory is not web-app"
        echo "Changing directory to web-app"
        cd ~/src/fyxerai/web-app
    fi

    # check if web-app is in the pwd path, if it is, cd .. back to the parent directory until it is web-app
    if [[ "$(basename "$(pwd)")" == *"web-app"* ]]; then
        while [[ "$(basename "$(pwd)")" != *"web-app"* ]]; do
            cd ..
        done
    fi

    # run the watch command
    cd ./shared && npm i && npm run distribute #&& cd ../functions && npm i && npm run build && npm run build:watch
    echo "Distributed the shared package"
    echo "cd into $subdir and build to reference the distributed shared package"

    if [ "$subdir" = "dataScience" ]; then
        cd "../$subdir" && npm i && npm run postinstall
    elif [ "$subdir" = "app" ]; then
        if [ "$run" = true ]; then
            cd "../$subdir" && npm i && npm run dev
        else
            cd "../$subdir" && npm i
        fi
    else
        cd "../$subdir" && npm i
        if [ "$watch" = true ]; then
            npm run build:watch
        else
            npm run build
        fi
    fi
}

setup_all() {
  CURRENT_DIR=$(pwd)
  setup_web_app --subdir functions
  setup_web_app --subdir app
  setup_web_app --subdir dataScience
  cd $CURRENT_DIR
}

# if current pwd is web-app, run setup_web_app
if [ "$(basename "$(pwd)")" = "web-app" ]; then
    echo "Run command: setup_web_app --subdir <functions|app|dataScience> to watch the web-app directory"
fi
export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/lucien/.lmstudio/bin"
# End of LM Studio CLI section
