set number
set scroll=1
set so=1 "context lines
set autowrite
set nobackup
set hls
set ignorecase
set incsearch
set nowrap
set history=1000
set nocompatible
set ruler
set ts=3
set shiftwidth=3
set nodigraph
set encoding=utf-8
set listchars=tab:»·,trail:·
set list
set backspace=indent,eol,start
set noautoindent
set nocindent
let g:netrw_liststyle = 3 "use with :Lexplore
colors koehler

syn on
"set dir=/tmp "swap file dir

fun! FocusLost_SaveFiles()
    if expand('%:t') == "notes.txt"
        exe ":au FocusLost" expand("%") ":wa"
        set autowriteall
    endif
endfun

:call FocusLost_SaveFiles()

set guifont=Source\ Code\ Pro\ 12
"set guifont="Monospace 12"
if has("gui_running")
	set mouse=a
	"set guifont="DejaVu Sans Mono 12"
    "set cursorcolumn
	"set lines=37 columns=149
endif

"set guifont=DejaVu\ Sans\ Mono\ 10

fun! CaptalizeCharUp()
	let s:word = expand('<cword>')
	:exe 'windo! %s/' . s:word . '/\u&/ge'
	:unlet! s:word
endfun

fun! CaptalizeCharLow()
  let s:word = expand('<cword>')
  :exe 'windo! %s/' . s:word . '/\l&/ge'
  :unlet! s:word
endfun

"map! <C-r> = t('.', default: "<ESC>lx$a")<ESC>F(lla
"map! <C-e> t('.', default: <ESC>F.li
"map! <C-e> #{_('<ESC>$a')}
"map! <D-e> #{_("<ESC>$a")}
"map! <C-r> #{_(<ESC>f'f'a)}
"map! <D-r> #{_(<ESC>f"f"a)}
map! <C-d> _(<ESC>f'f'a)
map! <C-f> _(<ESC>f"f"a)

map \u :call CaptalizeCharUp()<CR>
map \l :call CaptalizeCharLow()<CR>
"map \U <Esc>gUiw`]a
"map \L :exe windo <Esc>guiw

cnoremap sudow w !sudo tee % >/dev/null
"so ~/.vim/indent/*.vim

"set paste "usar para colar texto no terminal
hi StatusLine   term=bold,reverse cterm=bold ctermfg=red ctermbg=white gui=bold guifg=blue guibg=white
hi StatusLineNC term=reverse ctermfg=white ctermbg=darkblue guifg=white guibg=blue

"PEP8 indent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=150
set expandtab
set autoindent
set fileformat=unix
set shell=/bin/bash
"set shellcmdflag="-c"

"autocmd BufRead,BufNewFile *.tf set tabstop=2 softtabstop=2 shiftwidth=2

autocmd FileType yaml set tabstop=2 softtabstop=2 shiftwidth=2
