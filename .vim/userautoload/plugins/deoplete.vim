let g:deoplete#enable_at_startup = 1
let g:python_host_prog = '/Users/matsui/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '/Users/matsui/.pyenv/versions/neovim3/bin/python'

let g:deoplete#complete_method = "complete"

let g:deoplete#ignore_sources = {}
let g:deoplete#ignore_sources.ocaml = ['buffer', 'around', 'member', 'tag']

let g:deoplete#auto_complete_delay = 0

if !exists('g:deoplete#omni_patterns')
    let g:deoplete#omni#inputpatterns = {}
endif
let g:deoplete#omni#inputpatterns.ocaml = '[^. *\t]\.\w*|\s\w*|#'
