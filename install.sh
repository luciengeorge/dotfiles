sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# Install zsh-syntax-highlighting plugin
CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

# if ! command -v bat &> /dev/null; then
#   sudo apt-get install -y bat
# fi

cd "$CURRENT_DIR"

cp ~/dotfiles/.zshrc ~/.zshrc
cp ~/dotfiles/p10k.zsh ~/.p10k.zsh
cp ~/dotfiles/.aliases ~/.aliases
cp ~/dotfiles/.gitconfig ~/.gitconfig
