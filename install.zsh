# 初回のインストールスクリプト
function setup_homebrew() {
    if ((! ${+commands[brew]})); then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

source =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/.zshrc)
dot_main clone && dot_main set -v

case $OSTYPE in
    darwin*)
        setup_homebrew
        brew bundle --global
        ;;
esac
