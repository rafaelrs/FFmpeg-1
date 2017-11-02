#!/bin/bash
SYSROOT=$ANDROID_HOME/ndk-bundle/platforms/android-23/arch-arm/
TOOLCHAIN=$ANDROID_HOME/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/
ANDROID_INCLUDE=${SYSROOT}usr/include/

# Original URL: git://source.ffmpeg.org/ffmpeg.git
# Note: Change the TOOLCHAIN to match that available for your host system.
# darwin-x86_64 is for Mac OS X, but you knew that.
function build_one
{
./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --disable-linux-perf \
    --disable-doc \
    --disable-programs \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-avdevice \
    --disable-doc \
    --disable-symver \
    --cross-prefix=${TOOLCHAIN}bin/arm-linux-androideabi- \
    --target-os=linux \
    --arch=arm \
    --enable-cross-compile \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG
make clean
make -j8
make install
}
CPU=arm
PREFIX=$(pwd)/android/$CPU
ADDI_CFLAGS="-marm -I$ANDROID_INCLUDE -DANDROID_MULTINETWORK=1"
build_one
