> dotfiles

1. githubにsshの公開鍵を登録する

2. 以下を実行

```console
zsh =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/install.zsh)
```

## CentOSのメモ

最低以下のインストールはソースからやる必要あり(yumのでは古かったりしてうまくいかない)

zsh, curl, git, vim+lua

## Ubuntuのメモ

デフォルトのawkがnawkなのでzplugの要求条件を満たさない。gawkをインストールする

vimはluaサポートが合った方がいいのでvim-gnomeあたりをインストールする
