# 初回のインストールスクリプト
function setup_homebrew() {
    if ((! ${+commands[brew]})); then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
        ;;
esac

source =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/.zshrc)
dot_main clone && dot_main set -v
