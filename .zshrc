#zmodload zsh/zprof

# 標準入力がpipeだとzplugの警告が誤爆するのでスキップする
# 通常pipeになることはないが、WebStormからvitestを起動するときに警告が出てうるさかった
if [[ -p /dev/stdin ]]; then
    return
fi
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
    alias ls='ls -Fh --color=always'
fi
export CLICOLOR=1
export LESS=-FRX
# alias crontab='crontab -i'

if (( $+commands[nvim] )); then
    alias vi=nvim
else
    alias vi=vim
fi

if (( $+commands[starship] )); then
    eval "$(starship init zsh)" 

    function set_win_title() {
        local repo=$(git rev-parse --show-toplevel 2>/dev/null)

        if [[ -n $repo ]]; then
            local root=${repo:t}
            local rel=${PWD#$repo}
            rel=${rel#/}
            print -Pn "\e]0;${root}/${rel}\a"
        else
            print -Pn "\e]0;%~\a"
        fi
    }
    precmd_functions+=(set_win_title)
else
    setopt prompt_subst
    PROMPT=$'%{\e]0;%n@%m: %2~\a\e[$[32+$RANDOM % 5]m%}%U%B%n@%m%(2L.($SHLVL).)%b%#%{\e[m%}%u '
    RPROMPT=$'%{\e[33m%}[%~]%{\e[m%}'
fi


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
export DOT_COMMAND=DOOOOOOOOOOOOT

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
# antidote
# プラグイン一覧は dotfiles と一緒に管理し、生成済みの静的ロードファイルだけをキャッシュする。
# そのため通常の起動では antidote 本体も Git も実行しない。
typeset -g _zshrc_dir=${${(%):-%N}:A:h}
typeset -g ANTIDOTE_HOME=${ZDOTDIR:-$HOME}/.antidote
typeset -g _zsh_plugins_file=$_zshrc_dir/.zsh_plugins.txt
typeset -g _zsh_plugins_cache=$__zshrc_cache_dir/antidote-plugins.zsh

if [[ ! -r $ANTIDOTE_HOME/antidote.zsh ]]; then
    printf 'Install antidote? [y/N]: '
    if read -q; then
        echo
        git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
    fi
fi

if [[ -r $ANTIDOTE_HOME/antidote.zsh ]]; then
    # 一覧または antidote 本体が更新されたときだけ、プラグインを取得して静的ファイルを再生成する。
    if [[ ! $_zsh_plugins_cache -nt $_zsh_plugins_file || ! $_zsh_plugins_cache -nt $ANTIDOTE_HOME/antidote.zsh ]]; then
        source "$ANTIDOTE_HOME/antidote.zsh"
        typeset _zsh_plugins_cache_tmp=$_zsh_plugins_cache.$$
        if antidote bundle < "$_zsh_plugins_file" > "$_zsh_plugins_cache_tmp"; then
            mv "$_zsh_plugins_cache_tmp" "$_zsh_plugins_cache"
        else
            rm -f "$_zsh_plugins_cache_tmp"
            print -u2 'antidote: plugin cache could not be generated'
        fi
    fi

    if [[ -r $_zsh_plugins_cache ]]; then
        source "$_zsh_plugins_cache"
        # zplug は load 時に compinit を呼んでいた。antidote では明示する。
        autoload -Uz compinit
        compinit -C -d "$__zshrc_cache_dir/zcompdump"
    fi
else
    print -u2 'antidote is not installed; skipping zsh plugins'
fi

unset _zsh_plugins_cache_tmp
unset _zshrc_dir _zsh_plugins_file _zsh_plugins_cache
__zshrc::debug_print antidote

# zsh-history-substring-searchのキーバインド
if whence history-substring-search-up > /dev/null; then
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
fi

# atuin
# Ctrl-R と ↑ で履歴を検索する。通常の zsh 履歴も残すため、Atuin 未導入時も従来どおり動作する。
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh)"
fi

# zsh-autosuggestionsの設定
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# enhancd
export ENHANCD_HOME_ARG=// # cdは元の動作にして替わりにcd //でヒストリ全部からの選択
export ENHANCD_DOT_ARG=.   # cd ..は元の動作にして替わりにcd .で上位ディレクトリのリストから選択
export ENHANCD_USE_FUZZY_MATCH=1

__enhancd::filter::fuzzy() # redefine 
{
    if [[ -z $1 ]]; then
        cat <&0
    else
        if [[ $ENHANCD_USE_FUZZY_MATCH == 1 ]]; then
            if (( ${+commands[fuzzydirfilter]} )); then
                fuzzydirfilter -s "$1"
            else
                awk \
                    -f "$ENHANCD_ROOT/src/share/fuzzy.awk" \
                    -v search_string="$1"
            fi
        else
            # Case-insensitive (don't use fuzzy searching)
            awk '$0 ~ /\/.?'"$1"'[^\/]*$/{print $0}' 2>/dev/null
        fi
    fi
}

__enhancd::filter::exists() # redefine
{
    local line

    while read line
    do
        if [[ $line == /Volumes/* || -d $line ]]; then
            echo "$line"
        fi
    done
    # perl -ne 'chomp; (m:^/Volumes/: || -d $_) and print $_, "\n"'
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

# gitの便利alias
alias git-log-graph='git log --graph --decorate --oneline'

# phpbrew
if [ -f ~/.phpbrew/bashrc ]; then
    source ~/.phpbrew/bashrc
fi
phpbrew-install() {
    # いくつかの必要なライブラリを見つけられない問題の対処
    # https://github.com/phpbrew/phpbrew/issues/966#issuecomment-453427216
    phpbrew install --jobs=$(sysctl -n hw.ncpu) $1 \
        +default +mysql +sqlite \
        +iconv="$(brew --prefix libiconv)" \
        +bz2="$(brew --prefix bzip2)" \
        +zlib="$(brew --prefix zlib)"
}

#amesh
alias amesh='docker run -e TERM_PROGRAM --rm otiai10/amesh'

# zargs
autoload -U zargs

# phpstan
alias phpstan='docker run -v $PWD:/app --rm phpstan/phpstan'

# phan
phan() { docker run -v $PWD:/mnt/src --rm -u "$(id -u):$(id -g)" cloudflare/phan:latest $@; return $? }

# ocaml
alias ocaml='rlwrap ocaml'
test -r ~/.opam/opam-init/init.zsh && . ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# sail
alias sail='bash vendor/bin/sail'

# less
alias less='less -R'

# mise
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi

__zshrc::debug_print zshrc end
#zprof
