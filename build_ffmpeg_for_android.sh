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
    --enable-decoder=h264_mediacodec \
    --enable-hwaccel=h264_mediacodec \
    --enable-neon \
    --sysroot=$SYSROOT \
    --extra-cflags="$ADDI_CFLAGS $EXTRA_CFLAGS -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 " \
    --extra-ldflags="$ADDI_LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG
make clean
make -j8
make install
}
CPU=arm-v7a
PREFIX=$(pwd)/android/$CPU

ADDI_CFLAGS="-DANDROID -marm -I$ANDROID_INCLUDE -DANDROID_MULTINETWORK=1"
EXTRA_CFLAGS="-fPIC -ffunction-sections -funwind-tables -fstack-protector -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300"
build_one
