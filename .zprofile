# macは/etc/zprofileでPATHの設定をするのでこのタイミングで行う
typeset -U path PATH
if [ -z "$PATH_SET" ]; then

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
