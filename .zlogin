export PAGER=less
export EDITOR=vim
export LANG=C
export LC_CTYPE=ja_JP.UTF-8

if (( $+commands[nvim] )); then
    export EDITOR=nvim
else
    export EDITOR=vim
fi
