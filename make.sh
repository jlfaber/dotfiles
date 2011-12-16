#!/bin/sh

gcc ob.c -o bin/ob -levent
mkdir ./tmp
(cd tmp; git clone git://github.com/ellzey/trafan.git)
(cd tmp/trafan ; ./bootstrap ; ./configure --prefix=$PWD/bin/ ; make ; make install)
rm -rf ./tmp
