#!/bin/bash

if [ -f "~/.author" ]
then
   cp dot.author ~/.author
fi

cp ~/.vimrc ~/.vimrc.bak
cp ./dot.vimrc ~/.vimrc
mkdir ~/.vim
cp -R ./dot.vim ~/.vim 

if [ -f "~/.gdbinit" ]
then
   cp dot.gdbinit ~/.gdbinit
fi

if [ -f "~/.uncrustify.cfg" ]
then 
   cp dot.uncrustify.cfg ~/.uncrustify.cfg
fi
