#!/bin/bash
NDK_BUNDLE=$ANDROID_HOME/ndk-bundle-bak-14.1
SYSROOT=$NDK_BUNDLE/platforms/android-23/arch-arm/
TOOLCHAIN=$NDK_BUNDLE/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/
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
    --target-os=android \
    --arch=arm \
    --enable-cross-compile \
    --enable-jni \
    --enable-mediacodec \
    --enable-decoder=h264 \
    --enable-decoder=h264_mediacodec \
    --enable-hwaccel=h264_mediacodec \
    --enable-libopenh264 \
    --enable-neon \
    --sysroot=$SYSROOT \
    --extra-cflags="$CFLAGS_ANDROID -I$ANDROID_INCLUDE" \
    --extra-ldflags='-Wl, --fix-cortex-a8' \
    $ADDITIONAL_CONFIGURE_FLAG
make clean
make -j8
make install
}
CPU=arm-v7a
PREFIX=$(pwd)/android/$CPU

CFLAGS1="-DANDROID -DANDROID_MULTINETWORK=1 -DHAVE_SYS_UIO_H=1"
CFLAGS2="-Dipv6mr_interface=ipv6mr_ifindex -fpic -fasm -Wno-psabi -fno-short-enums"
CFLAGS3="-fno-strict-aliasing -finline-limit=300 -mvectorize-with-neon-quad -ffast-math"
CFLAGS4="-O3 -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU -mfpu=neon"

CFLAGS_ANDROID="$CFLAGS1 $CFLAGS2 $CFLAGS3 $CFLAGS4"

build_one
