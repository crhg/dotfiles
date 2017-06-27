# macは/etc/zprofileでPATHの設定をするのでこのタイミングで行う
typeset -U path PATH
if [ -z "$PATH_SET" ]; then

    path=(
        /usr/local/opt/coreutils/libexec/gnubin
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
