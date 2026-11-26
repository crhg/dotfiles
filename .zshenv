#zshenv_t0=$(print -P %D{%s.%10.})

CCL_DEFAULT_DIRECTORY=$HOME/ccl
export CCL_DEFAULT_DIRECTORY

# path設定はzshenvで行うように統一する
# macは/etc/zprofileでpathを上書きするので読み込みを抑止
case $OSTYPE in
    darwin*)
        if [[ -o LOGIN && -o GLOBAL_RCS ]]; then
            unsetopt GLOBAL_RCS
            restore_global_rcs=1
        fi
        ;;
esac

typeset -U path PATH
if [ -z "$PATH_SET" ]; then

    # macの/etc/zprofileから内容を移動
    if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/libexec/path_helper -s`
    fi

    path=(
        # User utilities
        ~/.local/share/mise/shims
        ~/.local/bin
        ~/bin
        ~/vendor/bin

        # Language package managers
        ~/.cargo/bin        # Rust
        ~/go/bin            # Go
        ~/.cabal/bin        # Haskell
        ~/.ghcup/bin        # GHC / Haskell toolchain

        # Package manager overrides
        /opt/homebrew/bin

        # Existing system PATH
        $path

        # Additional system locations
        /snap/bin
        /usr/local/sbin
        /usr/sbin
        /sbin
    )

    path=(
        # allow directories only (-/)
        # reject world-writable directories (^W)
        ${^path}(N-/^W)
    )
    export PATH_SET=1
fi

# ubuntuは/etc/zsh/zshrcでcompinitをするが不要なので抑止
skip_global_compinit=1

#zshenv_t1=$(print -P %D{%s.%10.})
#printf "zshenv %f\\n" $(( ( $zshenv_t1 - $zshenv_t0 ) * 1000 ))

case "$TERM" in
    xterm-256color)
        if [[ -n "$WSLENV" ]]; then
            export TERM=xterm
            export COLORTERM=truecolor
        fi
        ;;
esac
