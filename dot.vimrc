"set t_Co=256
syntax on
"colorscheme xoria256
"colorscheme desert256
"colorscheme zenburn
set number
"set cursorline
"colo chlordane

set textwidth=80
set history=50
set background=dark
"setlocal spell spelllang=en_us
"autocmd BufNewFile,BufRead *.txt,*.html,README set spell

if has("cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif


autocmd FileType * set tabstop=2|set shiftwidth=2|set noexpandtab
autocmd FileType python set nospell tabstop=4|set shiftwidth=4|set expandtab

augroup filetype
        au!
        au! BufRead,BufNewFile *.pc    set filetype=cpp
augroup END

augroup C
				autocmd BufRead *.c set cinoptions={.5s,:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s formatoptions=croql cindent shiftwidth=4 tabstop=8
        autocmd BufRead *.c set cindent shiftwidth=4 tabstop=8 noexpandtab
        autocmd BufRead *.d set cindent shiftwidth=4 tabstop=8 noexpandtab
augroup END

set viminfo='10,\"100,:20,%,n~/.viminfo
    au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm'\"")|else|exe "norm $"|endif|endif

set backspace=2
set nocompatible
