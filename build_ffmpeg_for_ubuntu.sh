#!/bin/bash

function build_one
{
	./configure \
	    --prefix=$PREFIX \
	    --disable-shared \
	    --disable-doc \
	    --enable-gpl \
	    --disable-decoder=opus \
	    --enable-encoder=libopenh264 \
	    --enable-decoder=h264 \
	    --disable-audiotoolbox \
	    --disable-videotoolbox	\
	    --disable-coreimage		\
	    --disable-appkit		\
	    --disable-avfoundation	\
	    --disable-autodetect 
	
	make clean	
	make -j8
	sudo make install
}

PREFIX=$(pwd)/build
CFLAGS_EXTRA="-02"

build_one
