# macは/etc/zprofileでPATHの設定をするのでこのタイミングで行う
if [ -z "$PATH_SET" ]; then
    export PATH=$COMPOSER_HOME/vendor/bin:$GOPATH/bin:$GOROOT/bin:~/lib/activator:~/.cabal/bin:~/bin:$CCL_DEFAULT_DIRECTORY/scripts:/usr/local/sbin:/usr/sbin:/sbin:$PATH
#    export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
    export PATH_SET=1
fi
