case $OSTYPE in
    darwin*)
        if [[ -v restore_global_rcs ]]; then
            setopt GLOBAL_RCS
        fi
        ;;
esac

if [ -d /opt/homebrew ]; then
        export HOMEBREW_PREFIX="/opt/homebrew";
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
    export HOMEBREW_REPOSITORY="/opt/homebrew";
    export HOMEBREW_SHELLENV_PREFIX="/opt/homebrew";
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi

export PATH="$PATH:/Users/matsui/Library/Application Support/JetBrains/Toolbox/scripts"

# wslのときはkeychainを使う
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    if command -v keychain >/dev/null 2>&1; then
        eval "$(keychain --eval --quiet --nogui ~/.ssh/id_rsa)"
    fi
fi
