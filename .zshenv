MANPATH=/opt/local/share/man:/usr/share/man
export MANPATH

CCL_DEFAULT_DIRECTORY=$HOME/ccl
export CCL_DEFAULT_DIRECTORY

CLICOLOR=1
export CLICOLOR

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

export EDITOR=vim

export GROOVY_HOME=/usr/local/opt/groovy/libexec
