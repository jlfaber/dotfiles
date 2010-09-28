#!/bin/sh

cp ~/.vimrc ~/.vimrc.bak
cp ./dot.vimrc ~/.vimrc
mkdir ~/.vim
cp -R ./dot.vim ~/.vim 
# cp dot.gdbinit ~/.gdbinit
