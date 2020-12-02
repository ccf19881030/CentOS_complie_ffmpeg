# install required software package
#yum install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel

mkdir ~/ffmpeg_sources

INSTALL_PATH=/usr/local

# build and install nasm
# An assembler used by some libraries. Highly recommended or your resulting build may be very slow.
cd ~/ffmpeg_sources
curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2
tar xjvf nasm-2.14.02.tar.bz2
cd nasm-2.14.02
./autogen.sh
./configure --prefix="$INSTALL_PATH" --bindir="$INSTALL_PATH/bin"
make
make install

# build and install Yasm
# An assembler used by some libraries. Highly recommended or your resulting build may be very slow.
cd ~/ffmpeg_sources
curl -O -L https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$INSTALL_PATH" --bindir="$INSTALL_PATH/bin"
make
make install


# build and install libx264
# H.264 video encoder. See the H.264 Encoding Guide for more information and usage examples.
# Requires ffmpeg to be configured with --enable-gpl --enable-libx264.
cd ~/ffmpeg_sources
git clone --depth 1 https://code.videolan.org/videolan/x264.git
curl -O -L http://anduin.linuxfromscratch.org/BLFS/x264/x264-20200819.tar.xz
xz -d x264-20200819.tar.xz
tar -xvf x264-20200819.tar
mv x264-20200819 x264
cd x264
PKG_CONFIG_PATH="$INSTALL_PATH/lib/pkgconfig" ./configure --prefix="$INSTALL_PATH" --bindir="$INSTALL_PATH/bin" --enable-static
make
make install

# build and install libx265
# H.265/HEVC video encoder. See the H.265 Encoding Guide for more information and usage examples.
# Requires ffmpeg to be configured with --enable-gpl --enable-libx265.
cd ~/ffmpeg_sources
# hg clone https://bitbucket.org/multicoreware/x265
curl -O -L http://anduin.linuxfromscratch.org/BLFS/x265/x265_3.4.tar.gz
tar -xzvf x265_3.4.tar.gz
mv x265_3.4 x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" -DENABLE_SHARED:bool=off ../../source
make
make install


# build and install libfdk_aac
# AAC audio encoder. See the AAC Audio Encoding Guide for more information and usage examples.
# Requires ffmpeg to be configured with --enable-libfdk_aac (and --enable-nonfree if you also included --enable-gpl).
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$INSTALL_PATH" --disable-shared
make
make install

# build and install libmp3lame
# MP3 audio encoder.
# Requires ffmpeg to be configured with --enable-libmp3lame.
cd ~/ffmpeg_sources
curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$INSTALL_PATH" --bindir="$INSTALL_PATH/bin" --disable-shared --enable-nasm
make
make install

# build and install libopus
# Opus audio decoder and encoder.
# Requires ffmpeg to be configured with --enable-libopus.
cd ~/ffmpeg_sources
curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
tar xzvf opus-1.3.1.tar.gz
cd opus-1.3.1
./configure --prefix="$INSTALL_PATH" --disable-shared
make
make install

# libvpx
# VP8/VP9 video encoder and decoder. See the VP9 Video Encoding Guide for more information and usage examples.
# Requires ffmpeg to be configured with --enable-libvpx.
cd ~/ffmpeg_sources
# git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
curl -O -L https://github.com/webmproject/libvpx/archive/v1.9.0/libvpx-1.9.0.tar.gz
tar xzvf libvpx-1.9.0.tar.gz
cd libvpx-1.9.0
./configure --prefix="$INSTALL_PATH" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make
make install

# sdl
# for ffplay binary, build and install sdl libary
cd ~/ffmpeg_sources
wget http://libsdl.org/release/SDL-1.2.15.tar.gz
tar zxvf SDL-1.2.15.tar.gz
cd SDL-1.2.15
./configure --prefix=/usr/local
sudo make
sudo make install

# build and install FFmpeg
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$INSTALL_PATH/bin:$PATH" PKG_CONFIG_PATH="$INSTALL_PATH/lib/pkgconfig" ./configure \
  --prefix="$INSTALL_PATH" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$INSTALL_PATH/include" \
  --extra-ldflags="-L$INSTALL_PATH/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$INSTALL_PATH/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
make
make install
hash -d ffmpeg
