#!/bin/sh

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then # link doesn't exist
    echo "-----> Symlinking your new $link"
    ln -fs "$file" "$link"
  fi
}

backup() {
  target=$1
  if [ -e "$target" ]; then # file exists
    if [ ! -L "$target" ]; then # file is not a symbolic link
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

if (! command -v nvm &> /dev/null; ); then
  echo "-----> Installing nvm"
  rm -rf "$HOME/.nvm"
  mkdir -p "$HOME/.nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi

# if test "$(uname)" = "Darwin" && ! command -v brew &> /dev/null; then
#   echo "-----> Installing Homebrew"
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#   eval "$(/opt/homebrew/bin/brew shellenv)"

#   if [ -f "$PWD/Brewfile" ]; then
#     echo "-----> Running brew bundle"
#     brew bundle
#   fi

#   gh auth login -s 'user:email' -w
# fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "-----> Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  echo '-----> Installing powerlevel10k theme'
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

CURRENT_DIR="$(pwd)"
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR" || exit

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "-----> Installing zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  echo "-----> Installing zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

cd "$CURRENT_DIR" || exit

for name in aliases p10k.zsh zshrc irbrc pryrc rspec hushlogin; do
  echo "-----> Symlinking $name"
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup "$target"
    if [ "$SPIN" ]; then
      symlink "$HOME/dotfiles/$name" "$target"
    else
      symlink "$PWD/$name" "$target"
    fi
  fi
done

CODE_PATH=~/Library/Application\ Support/Code/User

echo "-----> Importing VSCode keybindings"
name="keybindings.json"
target="$CODE_PATH/$name"
backup "$target"
symlink "$PWD/$name" "$target"

if test "$(uname)" = "Darwin"; then
  SUBL_PATH=~/Library/Application\ Support/Sublime\ Text
  if [ -d "$SUBL_PATH" ]; then
    echo "-----> Importing Sublime Text settings"
    mkdir -p "$SUBL_PATH/Packages/User $SUBL_PATH/Installed Packages"
    backup "$SUBL_PATH/Packages/User/Preferences.sublime-settings"
    curl https://sublime.wbond.net/Package%20Control.sublime-package > "$SUBL_PATH/Installed Packages/Package Control.sublime-package"
    ln -s "$PWD/Preferences.sublime-settings" "$SUBL_PATH/Packages/User/Preferences.sublime-settings"
    ln -s "$PWD/Package Control.sublime-settings" "$SUBL_PATH/Packages/User/Package Control.sublime-settings"
  fi
fi

echo "-----> Generating gitconfig"
target="$HOME/.gitconfig"
backup "$target"
symlink "$PWD/gitconfig $target"

echo "-----> Setting ssh configs"
target=~/.ssh/config
backup $target
symlink "$PWD/config" "$target"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

echo "-----> Installing fzf"
target="$HOME/.fzf.zsh"
backup "$target"
symlink "$PWD/fzf.zsh" "$target"

exec zsh

echo "-----> install.sh done ✅"
