#!/bin/sh

#  build.sh
#  Builds all supported architectures of FFmpeg for Android.
#  Created by Ilja Kosynkin on 28/07/2018.

# Used to build ffmpeg 3.2.14 with ndk 19.

set -e
set -x

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NDK="/opt/android-ndk-r17c"
#NDK="/opt/android-ndk-r19b"
#NDK="/home/rafaelrs/AddProgs/android-sdk/ndk/17.2.4988734"
#NDK="/home/rafaelrs/AddProgs/android-sdk/ndk/21.4.7075529"

BUILD_PLATFORM="linux-x86_64"
#BUILD_PLATFORM="darwin-x86_64"
LLVM_PREBUILT="$NDK/toolchains/llvm/prebuilt/$BUILD_PLATFORM"
LLVM_TOOLCHAIN="$LLVM_PREBUILT/bin"
SYSROOT="$NDK/sysroot"

CFLAGS="-O3  -fPIC"
LDFLAGS="-lc"

# Takes three arguments:
# First: ARCH, supported values: armeabi-v7a, arm64-v8a
# Second: platform level. Range: 14-19, 21-24, 26-28

function build () {
    ARCH=$1
    LEVEL=$2
    LIB_FOLDER="lib"

    case $ARCH in
        "armeabi-v7a")
            TARGET="arm-linux-androideabi"

            CC_FLAGS="-target thumbv7-none-linux-androideabi -mfpu=vfpv3-d16 -mfloat-abi=soft"

            LDFLAGS="--fix-cortex-a8 $LDFLAGS"
            PLATFORM_ARCH="arm"
        ;;
        "arm64-v8a")
            TARGET="aarch64-linux-android"

            CC_FLAGS="-target aarch64-none-linux-android -mfpu=neon -mfloat-abi=soft"

            PLATFORM_ARCH="arm64"
        ;;
    esac
    TOOLCHAIN_FOLDER="$TARGET-4.9"

    TOOLCHAIN=$NDK/toolchains/$TOOLCHAIN_FOLDER/prebuilt/$BUILD_PLATFORM/bin
    PREBUILT=$NDK/toolchains/$TOOLCHAIN_FOLDER/prebuilt/$BUILD_PLATFORM
    
    CROSS=$TARGET
    CROSS_PREFIX=${TOOLCHAIN}/${CROSS}-
    
    CC=$LLVM_TOOLCHAIN/clang
    CXX=$LLVM_TOOLCHAIN/clang++
    AS=$CC

    AR=$TOOLCHAIN/$TARGET-ar
    LD=$TOOLCHAIN/$TARGET-ld
    STRIP=$TOOLCHAIN/$TARGET-strip

    PREFIX="android/$ARCH"

    ./configure \
        --prefix=$PREFIX \
        --arch=$PLATFORM_ARCH \
        --target-os=android \
        --ar=$AR \
        --ld=$LD --cc=$CC --cxx=$CXX --as=$AS \
        --extra-cflags="$CC_FLAGS -I$SYSROOT/usr/include/$TARGET -I$SYSROOT/usr/ $CFLAGS" \
        --extra-ldflags="-rpath-link=$NDK/platforms/android-$LEVEL/arch-$PLATFORM_ARCH/usr/$LIB_FOLDER -L$NDK/toolchains/$TOOLCHAIN_FOLDER/prebuilt/$BUILD_PLATFORM/lib/gcc/$TARGET/4.9.x -L$NDK/platforms/android-$LEVEL/arch-$PLATFORM_ARCH/usr/$LIB_FOLDER $LDFLAGS" \
        --sysroot=$SYSROOT \
        --sysinclude=$SYSROOT/usr/include \
        --extra-libs=-lgcc \
        --ranlib=$PREBUILT/$TARGET/bin/ranlib \
        --disable-indev=v4l2 \
        --disable-gpl --disable-nonfree \
        --enable-runtime-cpudetect \
        --disable-gray \
        --disable-swscale-alpha \
        --disable-postproc \
        --disable-dxva2 \
        --disable-vaapi \
        --disable-vdpau \
        --disable-encoders \
        --disable-decoders --enable-decoder=aac --enable-decoder=h264 \
        --disable-muxers --enable-muxer=rtp --enable-muxer=mp4 --enable-muxer=h264 \
        --disable-demuxers --enable-demuxer=aac --enable-demuxer=h264 --enable-demuxer=rtsp \
        --disable-parsers --enable-parser=aac --enable-parser=h264 \
        --disable-bsfs \
        --disable-protocols --enable-protocol=async --enable-protocol=rtp --enable-protocol=file \
        --disable-devices \
        --disable-filters \
        --disable-iconv  \
        --disable-asm \
        --cross-prefix=$CROSS_PREFIX \
        --enable-cross-compile \
        --enable-static \
        --disable-ffplay \
        --disable-ffprobe \
        --enable-neon \
        --disable-avdevice \
        --disable-symver \
        --disable-doc \
        --enable-pic \
        --enable-small \
        --enable-jni \
        --enable-mediacodec \
        --enable-decoder=h264_mediacodec \
        --enable-hwaccel=h264_mediacodec


    $NDK/prebuilt/$BUILD_PLATFORM/bin/make clean
    $NDK/prebuilt/$BUILD_PLATFORM/bin/make -j4
    $NDK/prebuilt/$BUILD_PLATFORM/bin/make install
}

build "armeabi-v7a" "23"
#build "arm64-v8a" "23"