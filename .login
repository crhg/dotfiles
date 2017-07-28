if ( -x /bin/zsh ) then
    if ( -f $HOME/.i_want_to_use_zsh ) then
        unsetenv SHELL
        setenv SHLVL 0
        exec zsh -l
    else
        alias exec_zsh='unsetenv SHELL; setenv SHLVL 0; exec zsh -l'
    endif
endif
