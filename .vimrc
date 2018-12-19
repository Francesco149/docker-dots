syntax on
set relativenumber
colorscheme desert
hi LineNr ctermfg=darkgrey
set hlsearch

set clipboard=unnamedplus
set shiftwidth=2
set smarttab
set tabstop=2
set autoindent
set nowrap
set modeline
set modelines=5
set noswapfile

function NoTabs()
    set expandtab
    set softtabstop=0
    set listchars=tab:>~,nbsp:_,trail:.
    set list
endfunction

function Tabs()
    set noexpandtab
    set softtabstop=4
    set listchars=tab:\ \ ,nbsp:_,trail:.
    set list
endfunction

function Columns(n)
    set textwidth=0
    let &colorcolumn=join(range(a:n + 1,200),",")
    highlight ColorColumn ctermbg=8
endfunction

function NoColumns()
    highlight ColorColumn ctermbg=0
endfunction

call NoTabs()
call Columns(75)

set wildmenu
set path+=**
let g:netrw_liststyle=3

command! -nargs=1 Columns call Columns(<f-args>)
command! NoColumns call NoColumns()
command! NoTabs call NoTabs()
command! Tabs call Tabs()
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

au BufRead,BufNewFile,Bufenter *.ms set syntax=groff
