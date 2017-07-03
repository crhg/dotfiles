if ( -x /bin/zsh ) then
    unsetenv SHELL
    setenv SHLVL 0
    exec zsh -l
endif
