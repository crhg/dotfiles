# 初回のインストールスクリプト
function setup_homebrew() {
    if ((! ${+commands[brew]})); then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

function setup_homebrew_file() {
    brew install rcmdnk/file/brew-file
    source $(brew --prefix)/etc/brew-wrap
    brew set_repo --repo crhg/Brewfile
    brew file install
}

case $OSTYPE in
    darwin*)
        setup_homebrew
        setup_homebrew_file
        ;;
esac

source =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/.zshrc)
dot clone && dot set -v
