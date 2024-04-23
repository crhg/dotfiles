> dotfiles

1. (optional)githubにsshの公開鍵を登録する

2. 以下を実行

```console
zsh =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/install.zsh)
```

3. お好みで以下を設定

3.1 .dotfiles/conf-availableの中で使いたい物に.dotfiles/conf-enabledからリンクを作成

3.2 .loginからzshを起動する機能を使いたければ ~/.i_want_to_use_zsh を作成する

## CentOSのメモ

最低以下のインストールはソースからやる必要あり(yumのでは古かったりしてうまくいかない)

zsh, curl, git, vim+lua

## Ubuntuのメモ

デフォルトのawkがnawkなのでzplugの要求条件を満たさない。gawkをインストールする

vimはluaサポートがあった方がいいのでvim-gnomeあたりをインストールする

日本語localeが入っていないことがあるのでlocale -aでチェックし、なければlanguage-pack-jaをインストールする(ないとvimが文字化けする)

fzfを入れる

python-is-python3を入れる

## deopleteのメモ

deopleteはpython環境をちゃんと用意する必要がある。

https://github.com/zchee/deoplete-jedi/wiki/Setting-up-Python-for-Neovim

の記述に従って準備すればよいが結構面倒くさい。

