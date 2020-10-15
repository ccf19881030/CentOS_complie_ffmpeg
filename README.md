# centOS_build_ffmpeg
Compile FFmpeg on CentOS

This guide is based on a minimal installation of the latest CentOS release, and will provide a local, non-system installation of FFmpeg with support for several common external encoding libraries. These instructions should also work for recent Red Hat Enterprise Linux (RHEL) and Fedora.

## 一、CentOs7下编译FFMpeg相关资料
   找到一篇关于在CentOS7下编译FFMPEG源代码的文章，地址为：[Compile FFmpeg on CentOS](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)
   ![Compile FFmpeg on CentOS](https://img-blog.csdnimg.cn/2020101415164324.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)
有需要的话可以跟着做一下。另外，像编译ffmpeg源代码所需要的一些解码库x264,x265,libvpx等软件源代码包的下载，可以直接从[www.linuxfromscratch.org](http://www.linuxfromscratch.org/blfs/view/svn/index.html)上面下载，如下图所示：
![linuxfromscratch](https://img-blog.csdnimg.cn/20201014171234332.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)

![Video and Audio Utilities](https://img-blog.csdnimg.cn/20201014172442152.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)

![libvpx-1.9.0](https://img-blog.csdnimg.cn/20201014171333911.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)
![x265-3.4](https://img-blog.csdnimg.cn/20201014171412422.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)
![x264-20200819](https://img-blog.csdnimg.cn/20201014171443742.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2NjZjE5ODgxMDMw,size_16,color_FFFFFF,t_70#pic_center)
在Linux使用源代码安装软件时，有时候需要安装对应的依赖，从[http://www.linuxfromscratch.org/blfs/view/svn/index.html](http://www.linuxfromscratch.org/blfs/view/svn/index.html)这上面下载对应的软件源代码十分方便。

## 二、CentOS7下编译和安装ffmpeg以及相关依赖库的脚本
### 1、准备工作
在编译安装ffmpeg以及相关依赖包之前，需要确保安装下列编译工具：
```shell
yum install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
```

### 2、一键式`Shell`编译脚本`build_ffmpeg_all.sh`
编译脚本如下：
```shell
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

```

### 3、执行脚本`build_ffmpeg_all.sh`
执行脚本前需要保证使用`root`账户或者超级账户权限，然后为`build_ffmpeg_all.sh`添加可执行权限：
```shell
chmod +x build_ffmpeg_all.sh
```
最后，执行脚本
```shell
sh build_ffmpeg_all.sh
```

## 三、参考资料
- [Compile FFmpeg on CentOS](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)
- [http://www.linuxfromscratch.org/blfs/view/svn/index.html](http://www.linuxfromscratch.org/blfs/view/svn/index.html)
- [H.265/HEVC Video Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.265)
- [H.264 Video Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.264)
- [AAC Audio Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/AAC)
