case $OSTYPE in
    darwin*)
        if [[ -v restore_global_rcs ]]; then
            setopt GLOBAL_RCS
        fi
        ;;
esac

export PATH="$HOME/.cargo/bin:$PATH"
