symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "-----> Symlinking your new $link"
    ln -fs $file $link
  fi
}

backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

cd "$CURRENT_DIR"

for name in aliases gitconfig zshrc; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup $target
    if [ "$SPIN" ] then;
      file=~/dotfiles/$1
      symlink $HOME/dotfiles/$name $target
    else
      symlink $PWD/$name $target
    fi
  fi
done

if [ "$SPIN" ] then;
  CODE_PATH=~/.vscode-server/data/Machine
else
  CODE_PATH=~/Library/Application\ Support/Code/User
fi

for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup $target
  if [ "$SPIN" ] then;
    file=~/dotfiles/$1
    symlink $HOME/dotfiles/$name $target
  else
    symlink $PWD/$name $target
  fi
done

if [[ `uname` =~ "Darwin" ]]; then
  target=~/.ssh/config
  backup $target
  symlink $PWD/config $target
  ssh-add -K ~/.ssh/id_ed25519
fi

exec zsh

# symlink zshrc ~/.zshrc
# symlink p10k.zsh ~/.p10k.zsh
# symlink aliases ~/.aliases
# symlink gitconfig ~/.gitconfig

# if ! command -v bat &> /dev/null; then
#   sudo apt-get install -y bat
# fi
