#zshenv_t0=$(print -P %D{%s.%10.})

CCL_DEFAULT_DIRECTORY=$HOME/ccl
export CCL_DEFAULT_DIRECTORY


export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec

export COMPOSER_HOME=$HOME/.composer

if [ -z "$SSH_AUTH_SOCK" -a -f $HOME/.ssh/SSH_ENV ]; then
    . $HOME/.ssh/SSH_ENV > /dev/null
fi

# if [ -z "$ORACLE_HOME" ]; then
#     export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server
#     export PATH=$ORACLE_HOME/bin:$PATH
# fi

# if [ -z "$JAVA_HOME" ]; then
#     export JAVA_HOME=~/jdk
#     export PATH=$JAVA_HOME/bin:$PATH
# fi

export GROOVY_HOME=/usr/local/opt/groovy/libexec

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
        ~/vendor/bin
        ~/.local/bin
        /usr/local/opt/coreutils/libexec/gnubin
        /usr/local/opt/bison/bin
        $COMPOSER_HOME/vendor/bin
        $GOPATH/bin
        $GOROOT/bin
        ~/lib/activator
        ~/.cabal/bin
        ~/bin
        $CCL_DEFAULT_DIRECTORY/scripts
        $path
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
