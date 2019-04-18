syntax on
set relativenumber
hi LineNr ctermfg=darkgrey
set hlsearch

set background=dark
set clipboard=unnamedplus
set shiftwidth=2
set smarttab
set tabstop=2
set autoindent
set nowrap
set modeline
set modelines=5
set noswapfile
set undodir=~/.vim/undo/
set undofile
set t_Co=256

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
    let &colorcolumn=join(range(a:n + 1,a:n + 1),",")
    highlight ColorColumn ctermbg=8
endfunction

function NoColumns()
    set colorcolumn=0
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
nnoremap <silent> <F5>
  \ :let _s=@/ <Bar>
  \ :%s/\s\+$//e <Bar>
  \ :let @/=_s <Bar>
  \ :nohl <Bar>
  \ :unlet _s <CR>
map <leader>r :source ~/.vimrc<CR>
map <leader>h :nohl<CR>

au BufRead,BufNewFile,Bufenter *.ms set syntax=groff
au BufRead,BufNewFile,Bufenter *.vs set syntax=c
au BufRead,BufNewFile,Bufenter *.fs set syntax=c
au BufRead,BufNewFile,Bufenter *.glsl set syntax=c
au BufRead,BufNewFile,Bufenter *.v set syntax=go
au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile
