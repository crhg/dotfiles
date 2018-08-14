# .zshrcのprofilerなど
if [ "$ZSHRC_PROFILE" != "" ]; then
    zmodload zsh/zprof && zprof > /dev/null
fi
alias profile_zshrc='ZSHRC_PROFILE=1 zsh -i -c zprof'
alias time_zshrc='time ZSHRC_TIME=1 zsh -i -c exit'
alias trace_zshrc='PS4="+%D{%H:%M:%S.%.} %N %i > " zsh -x -i -c exit'

# ZSHRC_TIME=1
if [ "$ZSHRC_TIME" != "" ]; then
    __zshrc::get_time() {
        print -P %D{%s.%10.}
    }

    typeset -E 20 _zshrc_debug_last_time=$(__zshrc::get_time)
    typeset -E 20 _zshrc_debug_base_time=$_zshrc_debug_last_time

    __zshrc::debug_print() {
        local -E 20 now=$(__zshrc::get_time)

        if [ $# != 0 ]; then
            local -E 20 dt0=$(( ($now - $_zshrc_debug_base_time) * 1000))
            local -E 20 dt=$(( ($now - $_zshrc_debug_last_time) * 1000))
            print -P %D{%H:%M:%S.%.} $(printf "%.2f" $dt0) $(printf "%.2f" $dt) "$@"
        fi

        # 出力に時間がかかるのでその分補正する
        local -E 20 now2=$(__zshrc::get_time)
        _zshrc_debug_base_time=$(( $_zshrc_debug_base_time + ($now2 - $now) ))

        _zshrc_debug_last_time=$now2
    }
else
    __zshrc::debug_print() {}
fi

# zshrc用のキャッシュディレクトリ
__zshrc_cache_dir=~/.cache/zshrc
if [ \! -d $__zshrc_cache_dir ]; then
    mkdir -p $__zshrc_cache_dir
fi

bindkey -e

setopt extended_glob
setopt auto_pushd
setopt pushd_ignore_dups
setopt equals
setopt magic_equal_subst
setopt print_eight_bit
setopt print_exit_value

if (( $+commands[gls] )); then
    alias ls='gls -Fh --color=always --width=$COLUMNS'
else
    alias ls='ls -Fh --color=always --width=$COLUMNS'
fi
export CLICOLOR=1
export LESS=-R
# alias crontab='crontab -i'

if (( $+commands[nvim] )); then
    alias vi=nvim
else
    alias vi=vim
fi

setopt prompt_subst
PROMPT=$'%{\e[$[32+$RANDOM % 5]m%}%U%B%m{%n}%(2L.($SHLVL).)%b%#%{\e[m%}%u '
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
# case $OSTYPE in
#     darwin*)
#         ssh-add -K 2>/dev/null >/dev/null
#         ;;
# esac

__zshrc::debug_print before dot
# dot
export DOT_REPO='https://github.com/crhg/dotfiles.git'
export DOT_DIR=~/.dotfiles

# gitのバージョン1系はdotがサポートしていないので代替関数
function dot-pull() {
    echo "$(tput bold)$(tput setaf 4)Update dotfiles$(tput sgr0) dot cd && git pull"
    dot_main cd && git pull
}
function dot-update() {
    dot-pull
    dot_main set
}
__zshrc::debug_print dot

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
__zshrc::debug_print brew

fpath=(~/myfuncs $fpath)

typeset -U manpath MANPATH
manpath=(
    /opt/local/share/man
    /usr/local/share/man
    /usr/share/man
    $manpath
)
manpath=(
        # allow directories only (-/)
        # reject world-writable directories (^W)
    ${^manpath}(N-/^W)
)

__zshrc::debug_print manpath
# zplug

# https://github.com/zplug/zplug/issues/468 の問題を回避するためZPLUG_HOMEを設定する
export ZPLUG_HOME=~/.zplug

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
__zshrc::debug_print zplug/init.zsh

zplug "plugins/laravel5", from:oh-my-zsh, defer:2
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/composer", from:oh-my-zsh, defer:2, if:'(( $+commands[composer] ))'
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "${ZPLUG_PACKAGE:-"zplug/zplug"}", at:"${ZPLUG_PACKAGE_AT:-"master"}", hook-build:'zplug --self-manage'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux, defer:2
# zplug "b4b4r07/enhancd", use:init.sh
zplug "crhg/enhancd", use:init.sh
zplug "rupa/z", use:"*.sh", defer:2
zplug "ssh0/dot", use:"*.sh"
zplug "zsh-users/zsh-autosuggestions", defer:2

__zshrc::debug_print zplug setting

# zplug以下の*.zsh, *.sh, を全部zcompileする
function zplug_compile() {
    for i in ~/.zplug/**/*.{sh,zsh} ~/.zplug/**/_*~*.zwc; do
        case $i in
        */test-data/*)
            ;;
        *)
            zcompile $i
            ;;
        esac
    done
}

# ただしcheckはそこそこ重いので最後のチェック以後に.zshrcが更新されているときのみにする
if [ ~/.zplug/last_zshrc_check_time -nt ~/.zshrc ]; then
    # .zshrcが更新されていないとき
    # いきなり__zplug::core::load::from_cacheを呼ぶだけでいいはず(たぶん)
    #     なぜなら更新がないなら更新側で実行されるzplug loadで書かれたcacheは有効な筈である
    # compinitに対する注意は下記とと同じ

    # XXX: oh-my-zshの中でcomposer global config bin-dirコマンドを実行してpathを設定しているが
    #      とてつもなく遅い(約300ms)のでload中はaliasで置き換える
    alias composer="echo $HOME/.composer/vendor/bin"
    __zplug::core::load::from_cache

    # composerのaliasを元に戻す
    unalias composer
else
    # .zshrcが最終チェック以降に更新されてたらこっちのルート(遅い)
    touch ~/.zplug/last_zshrc_check_time

    # check コマンドで未インストール項目があるかどうか verbose にチェックし
    # false のとき（つまり未インストール項目がある）y/N プロンプトで
    # インストールする
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install

            zplug_compile
        fi
    fi

    # プラグインを読み込み、コマンドにパスを通す
    # XXX: compinitはzplug loadの中で行われる
    #      (zplugで読まれるプラグイン以外による)fpathの設定はここまでに行うこと
    #      (zplugで読まれるプラグイン以外で)compinitで用意される関数を必要とするものこの後に記述すること
    zplug load # --verbose
fi
__zshrc::debug_print zplug load

# zcompdumpを必要に応じてzcompileする
__zshrc::zcompile_update() {
    if [ -f $1 -a \! \( -f $1.zwc -a $1.zwc -nt $1 \) ]; then
        zcompile $1
    fi
}
__zshrc::zcompile_update ~/.zplug/zcompdump
__zshrc::zcompile_update ~/.zcompdump
unfunction __zshrc::zcompile_update
__zshrc::debug_print zcompile_update

# zsh-history-substring-searchのキーバインド
if whence history-substring-search-up > /dev/null; then
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
fi

# select-history
# from https://blog.sgr-ksmt.org/2016/12/10/smart_fzf_history/
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

# zsh-autosuggestionsの設定
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# enhancd
export ENHANCD_HOME_ARG=// # cdは元の動作にして替わりにcd //でヒストリ全部からの選択
export ENHANCD_DOT_ARG=.   # cd ..は元の動作にして替わりにcd .で上位ディレクトリのリストから選択

__enhancd::filter::fuzzy() # redefine 
{
    if [[ -z $1 ]]; then
        cat <&0
    else
        if [[ $ENHANCD_USE_FUZZY_MATCH == 1 ]]; then
            if (( ${+commands[fuzzydirfilter]} )); then
                fuzzydirfilter "$1"
            else
                awk \
                    -f "$ENHANCD_ROOT/src/share/fuzzy.awk" \
                    -v search_string="$1"
            fi
        else
            # Case-insensitive (don't use fuzzy searhing)
            awk '$0 ~ /\/.?'"$1"'[^\/]*$/{print $0}' 2>/dev/null
        fi
    fi
}

## cdの補完に一般ファイル含まれないようにする
compdef __enhancd::cd=cd


__zshrc::debug_print enhancd

# highlighter
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# google cloud sdk
__zshrc::gcloud_sdk_init() {
    # The next line updates PATH for the Google Cloud SDK.
    if [ -f ~/google-cloud-sdk/path.zsh.inc ]; then
        source ~/google-cloud-sdk/path.zsh.inc
    fi

    # The next line enables shell command completion for gcloud.
    if [ -f ~/google-cloud-sdk/completion.zsh.inc ]; then
        source ~/google-cloud-sdk/completion.zsh.inc
    fi
}
__zshrc::gcloud_sdk_init
unfunction __zshrc::gcloud_sdk_init
__zshrc::debug_print gcloud_sdk_init

# pyenv
if (( $+commands[pyenv] )); then
    if [ ! -f $__zshrc_cache_dir/pyenv-init ]; then
	pyenv init - > $__zshrc_cache_dir/pyenv-init
    fi
    source $__zshrc_cache_dir/pyenv-init
    if [ ! -f $__zshrc_cache_dir/pyenv-virtialenv-init ]; then
	pyenv virtualenv-init - > $__zshrc_cache_dir/pyenv-virtualenv-init
    fi
    source $__zshrc_cache_dir/pyenv-virtualenv-init
    __zshrc::debug_print pyenv
fi

# gitの便利alias
alias git-log-graph='git log --graph --decorate --oneline'

# phpbrew
if [ -f ~/.phpbrew/bashrc ]; then
    source ~/.phpbrew/bashrc
fi

#amesh
alias amesh='docker run -e TERM_PROGRAM --rm otiai10/amesh'

__zshrc::debug_print zshrc end
