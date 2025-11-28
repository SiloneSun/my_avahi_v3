#!/bin/bash
set -e

# 🔴 更新后的工具链路径
TOOLCHAIN=/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin
TARGET=arm-linux-gnueabihf
DEP_SRC=/home/sunxilong/work/mycode/my_avahi_v3/dependence/src
DEP_INSTALL=/home/sunxilong/work/mycode/my_avahi_v3/dependence/install

cd $DEP_SRC
wget -c https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz
tar -zxf expat-2.5.0.tar.gz
cd expat-2.5.0

./configure \
  --host=$TARGET \
  --prefix=$DEP_INSTALL \
  --enable-shared \
  --disable-static \
  --without-docbook \
  CC=$TOOLCHAIN/$TARGET-gcc \
  CXX=$TOOLCHAIN/$TARGET-g++ \
  AR=$TOOLCHAIN/$TARGET-ar \
  RANLIB=$TOOLCHAIN/$TARGET-ranlib \
  CFLAGS="-fPIC"

make -j$(nproc)
make install

echo "expat 2.5.0 交叉编译完成！"