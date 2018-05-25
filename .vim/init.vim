set nocompatible

syntax on

colorscheme elflord

set expandtab
set shiftwidth=4
set tabstop=8
"setl binary noendofline "ファイル末尾に改行を補わない

set smartindent

set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%

" 文字コード
set encoding=utf8
set fileencodings=ucs-bom,utf8,iso-2022-jp,cp932,euc-jp

" UTF-8の□や○でカーソル位置がずれないようにする
if exists("&ambiwidth")
  set ambiwidth=double
endif

" 改行コードの自動認識
set fileformats=unix,dos,mac

" 検索
set ignorecase
set smartcase
set incsearch
set hlsearch

" ESC2回で(検索の)ハイライトを解除する
noremap <esc><esc> :noh<cr>

" OSのクリップボードを使う設定
if has('mac') && ! exists("$SSH_CLIENT")
    if has('nvim')
        set clipboard=unnamedplus
    else
        set clipboard=unnamed,autoselect
    endif
endif

" 文字列に埋め込まれたSQLやHTMLの色づけ
let php_sql_query=1
let php_htmlInString=1

" ~.vim/usreautoload以下の読み込み
runtime! userautoload/init/*.vim
runtime! userautoload/plugins/*.vim

" メニューの色
hi Pmenu ctermbg=4
hi PmenuSel ctermbg=1
hi PmenuSbar ctermbg=4

" ステータスラインを常時表示(lightline.vimのため)
set laststatus=2

" tagジャンプの複数表示
nnoremap <C-]> g<C-]>

" マウス
set mouse=a

" 保存しなくてもバッファを切り替えられるようにする
set hidden

" コマンド履歴
set history=2000

" filetypeの設定は最後にした方がいいらしい
" http://d.hatena.ne.jp/wiredool/20120618/1340019962
filetype off
filetype indent plugin off
filetype on
filetype indent plugin on
