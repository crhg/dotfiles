# .zshrcのprofilerなど
if [ "$ZSHRC_PROFILE" != "" ]; then
    zmodload zsh/zprof && zprof > /dev/null
fi
alias profile_zshrc='ZSHRC_PROFILE=1 zsh -i -c zprof'
alias time_zshrc='time zsh -i -c exit'


__zshrc::get_time() {
    print -P %D{%s.%10.}
}

typeset -E 20 _zshrc_debug_last_time=$(__zshrc::get_time)
typeset -E 20 _zshrc_debug_base_time=$_zshrc_debug_last_time

__zshrc::debug_print() {
    if [ $# != 0 ]; then
        local -E 20 now=$(__zshrc::get_time)
        local -E 20 dt0=$(( ($now - $_zshrc_debug_base_time) * 1000))
        local -E 20 dt=$(( ($now - $_zshrc_debug_last_time) * 1000))
        print -P %D{%H:%M:%S.%.} $(printf "%.2f" $dt0) $(printf "%.2f" $dt) "$@"
    fi
    _zshrc_debug_last_time=$(__zshrc::get_time)
}

bindkey -e

setopt extended_glob
setopt auto_pushd
setopt pushd_ignore_dups
setopt equals
setopt magic_equal_subst
setopt print_eight_bit
setopt print_exit_value

alias ls='ls -Fh --color=always --width=$COLUMNS'
export LESS=-R
# alias crontab='crontab -i'

setopt prompt_subst
PROMPT=$'%{\e[$[32+$RANDOM % 5]m%}%U%B$HOST{%n}%b%%%{\e[m%}%u '
RPROMPT=$'%{\e[33m%}[%~]%{\e[m%}'


export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_ignore_all_dups
setopt hist_ignore_space
# setopt hist_verify
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt share_history
setopt extended_history
setopt append_history # historyファイルを上書きせず追加

# macならkeychainからssh-addする
case $OSTYPE in
    darwin*)
        ssh-add -K 2>/dev/null >/dev/null
        ;;
esac

# zplug
export ZPLUG_PACKAGE=crhg/zplug
export ZPLUG_PACKAGE_AT=master
if [ ! -d ~/.zplug ]; then
    printf "Install zplug? [y/N]: "
    if read -q; then
        echo;
        # curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
        curl -sL --proto-redir -all,https https://raw.githubusercontent.com/crhg/zplug_installer/master/installer.zsh| zsh
    fi
fi

export ZPLUG_LOADFILE=~/.zplug_packages.zsh
[ -f $ZPLUG_LOADFILE ] || touch $ZPLUG_LOADFILE # ファイルがないとログが出てうるさいので作る

source ~/.zplug/init.zsh

zplug "plugins/laravel5", from:oh-my-zsh, defer:2
zplug "plugins/composer", from:oh-my-zsh, defer:2
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "$ZPLUG_PACKAGE", at:"${ZPLUG_PACKAGE_AT:-"master"}", hook-build:'zplug --self-manage'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux, defer:2
# zplug "b4b4r07/enhancd", use:init.sh
zplug "crhg/enhancd", use:init.sh
zplug "rupa/z", use:"*.sh", defer:2
zplug "ssh0/dot", use:"*.sh", defer:2

# check コマンドで未インストール項目があるかどうか verbose にチェックし
# false のとき（つまり未インストール項目がある）y/N プロンプトで
# インストールする
# ただしcheckはそこそこ重いので最後のチェック以後に.zshrcが更新されているときのみにする
if [ ! ~/.zplug/last_zshrc_check_time -nt ~/.zshrc ]; then
    touch ~/.zplug/last_zshrc_check_time
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install

            # XXX: zplug以下の*.zshは全部zcompileしてみる
            for i in ~/.zplug/**/*.{sh,zsh}; do
                zcompile $i
            done
        fi
    fi
fi

# プラグインを読み込み、コマンドにパスを通す
zplug load # --verbose

# zcompdumpを必要に応じてzcompileする
__zshrc::zcompile_update() {
    if [ -f $1 -a \! \( -f $1.zwc -a $1.zwc -nt $1 \) ]; then
        zcompile $1
    fi
}
__zshrc::zcompile_update ~/.zplug/zcompdump
__zshrc::zcompile_update ~/.zcompdump
unfunction __zshrc::zcompile_update

# zsh-history-substring-searchのキーバインド
if whence history-substring-search-up > /dev/null; then
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
fi

# enhancd
export ENHANCD_HOME_ARG=// # cdは元の動作にして替わりにcd //でヒストリ全部からの選択

# highlighter
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# dot
export DOT_REPO='https://github.com/crhg/dotfiles.git'
export DOT_DIR=~/.dotfiles

# brew file wrapper
case $OSTYPE in
    darwin*)
        __zshrc::brew_file_wrapper_init() {
            export HOMEBREW_BREWFILE_APPSTORE=0 # AppStoreのアプリは含めない
            # brew_prefix=$(brew --prefix)
            # brew --prefixは意外に時間かかるのであまり変わらないだろうから決め打ちに変更
            brew_prefix=/usr/local
            if [ -f $brew_prefix/etc/brew-wrap ];then
                source $brew_prefix/etc/brew-wrap
            fi
        }
        __zshrc::brew_file_wrapper_init
        unfunction __zshrc::brew_file_wrapper_init
        ;;
esac

# google cloud sdk
__zshrc::gcloud_sdk_init() {
    # The next line updates PATH for the Google Cloud SDK.
    if [ -f /Users/matsui/google-cloud-sdk/path.zsh.inc ]; then
        source '/Users/matsui/google-cloud-sdk/path.zsh.inc'
    fi

    # The next line enables shell command completion for gcloud.
    if [ -f /Users/matsui/google-cloud-sdk/completion.zsh.inc ]; then
        source '/Users/matsui/google-cloud-sdk/completion.zsh.inc'
    fi
}
__zshrc::gcloud_sdk_init
unfunction __zshrc::gcloud_sdk_init

fpath=(~/myfuncs $fpath)

# End of lines added by compinstall
