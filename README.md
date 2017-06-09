> dotfiles

1. githubにsshの公開鍵を登録する

2. 以下を実行

```console
zsh =(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/dotfiles/master/install.zsh)
```

## CentOSのメモ

最低以下のインストールはソースからやる必要あり(yumのでは古かったりしてうまくいかない)

curl, git, vim+lua
