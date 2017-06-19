# macは/etc/zprofileでPATHの設定をするのでこのタイミングで行う
typeset -U path PATH
if [ -z "$PATH_SET" ]; then

    export PATH=$COMPOSER_HOME/vendor/bin:$GOPATH/bin:$GOROOT/bin:~/lib/activator:~/.cabal/bin:~/bin:$CCL_DEFAULT_DIRECTORY/scripts:/usr/local/sbin:/usr/sbin:/sbin:$PATH
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

    path=(
        # allow directories only (-/)
        # reject world-writable directories (^W)
        ${^path}(N-/^W)
    )
    export PATH_SET=1
fi
