syntax on
set title
set nocompatible
set mouse-=a
set textwidth=80
set history=50
set background=dark
set backspace=2
set noea
set tabstop=4
set noexpandtab

if $TERM == 'xterm-256color'
	set t_Co=256
	colorscheme jellybeans
	set cursorline
  set number
  hi CursorLine   cterm=NONE ctermbg=237
  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
endif

function s:Template(argument)
  %d
  if (a:argument == "c")
    0r ~/.vim/skeletons/template.c
    set ft=c
  endif
  silent %!~/.vim/do_header %
endfunction

command! -nargs=1 Template call s:Template(<f-args>)

autocmd FileType * set tabstop=2|set shiftwidth=2|set noexpandtab
autocmd FileType python set nospell tabstop=4|set shiftwidth=4|set expandtab
au BufNewFile,BufRead *.tac setfiletype python 

augroup filetype
        au!
        au! BufRead,BufNewFile *.pc    set filetype=cpp
augroup END

augroup C
  if has("autocmd")
    augroup autoinsert
    au!
      autocmd BufNewFile *.c call s:Template("c")
    augroup END
  endif
  autocmd BufRead *.c set cindent shiftwidth=4 tabstop=8 noexpandtab
  autocmd BufRead *.h set cindent shiftwidth=4 tabstop=8 noexpandtab
  autocmd BufRead *.d set cindent shiftwidth=4 tabstop=8 noexpandtab
augroup END

set viminfo='10,\"100,:20,%,n~/.viminfo
    au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm'\"")|else|exe "norm $"|endif|endif

function Toggle_numbers() 
	if &number 
		set nonumber
	else
		set number
	endif
endfunction

nmap + : vertical res +1<CR>
nmap _ : vertical res -1<CR>
nmap = :res +1<CR>
nmap - :res -1<CR>
nmap <C-a><C-n> :new<CR>
nmap <C-a><C-v> :vnew<CR>
nmap <Tab><Tab> :winc w<CR> 
nmap <F3> :call Toggle_numbers()<CR>
nmap <S-s><S-s> :SessionSave<CR>
nmap <F4> :SessionOpenLast<CR>
nmap <S-s><S-l> :SessionList<CR>
