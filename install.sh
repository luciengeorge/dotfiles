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
  echo "-----> Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
  echo '-----> Installing powerlevel10k theme'
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "-----> Installing zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  echo "-----> Installing zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

cd "$CURRENT_DIR"

for name in aliases gitconfig zshrc p10k.zsh irbrc pryrc rspec; do
  echo "-----> Symlinking $name"
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup $target
    if [ "$SPIN" ]; then
      symlink $HOME/dotfiles/$name $target
    else
      symlink $PWD/$name $target
    fi
  fi
done

if [ "$SPIN" ]; then
  CODE_PATH=~/.vscode-server/data/Machine
else
  CODE_PATH=~/Library/Application\ Support/Code/User
fi

echo "-----> Importing VSCode settings and keybindings"
for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup $target
  if [ "$SPIN" ]; then
    symlink $HOME/dotfiles/$name $target
  else
    symlink $PWD/$name $target
  fi
done

if [[ `uname` =~ "darwin" ]]; then
  SUBL_PATH=~/Library/Application\ Support/Sublime\ Text
  if [ -d "$SUBL_PATH" ]; then
    mkdir -p $SUBL_PATH/Packages/User $SUBL_PATH/Installed\ Packages
    backup "$SUBL_PATH/Packages/User/Preferences.sublime-settings"
    curl https://sublime.wbond.net/Package%20Control.sublime-package > $SUBL_PATH/Installed\ Packages/Package\ Control.sublime-package
    ln -s $PWD/Preferences.sublime-settings $SUBL_PATH/Packages/User/Preferences.sublime-settings
    ln -s $PWD/Package\ Control.sublime-settings $SUBL_PATH/Packages/User/Package\ Control.sublime-settings
  fi
fi

if [[ `uname` =~ "Darwin" ]]; then
  if [[ ! `system_profiler SPHardwareDataType | grep Serial` =~ "XFN4C7FHLX" ]]; then
    echo "-----> Setting ssh configs"
    target=~/.ssh/config
    backup $target
    symlink $PWD/config $target
    ssh-add -K ~/.ssh/id_ed25519
  fi
fi

exec zsh
