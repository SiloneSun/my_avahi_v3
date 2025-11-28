#!/bin/bash
set -e
# 路径配置（复用你的工具链和依赖目录）
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
LIBMD_VER="1.0.4"  # 轻量级稳定版本

# 下载并编译libmd
cd /home/sunxilong/work/mycode/my_avahi_v3/dependence/src
mkdir -p libmd_build
cd libmd_build
# wget https://archive.hadrons.org/software/libmd/libmd-${LIBMD_VER}.tar.xz
# tar -xf libmd-${LIBMD_VER}.tar.xz
cd libmd-${LIBMD_VER}

# 配置+编译+安装
./configure --build=x86_64-pc-linux-gnu --host=arm-linux-gnueabihf --prefix=/home/sunxilong/work/mycode/my_avahi_v3/dependence/install --disable-shared --enable-static --disable-dependency-tracking --without-sysroot CC="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc -marm"

make -j$(nproc)
make install

echo "✅ libmd-${LIBMD_VER} 编译完成，已提供MD5函数支持"