#!/bin/bash
set -e
# 路径配置（复用你的交叉工具链和依赖目录）
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
LIBBSD_VER="0.11.7"  # 选择稳定版本

# 下载并编译libbsd
cd /home/sunxilong/work/mycode/my_avahi_v3/dependence/src
mkdir -p libbsd_build && cd libbsd_build
# wget https://libbsd.freedesktop.org/releases/libbsd-${LIBBSD_VER}.tar.xz
# tar -xf libbsd-${LIBBSD_VER}.tar.xz
cd libbsd-${LIBBSD_VER}

# 配置+编译+安装到依赖目录
# ./configure --build=x86_64-pc-linux-gnu --host=arm-linux-gnueabihf --prefix=/home/sunxilong/work/mycode/my_avahi_v3/dependence/install --disable-shared --enable-static --disable-dependency-tracking CC="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc -marm" --with-libmd-dir=/home/sunxilong/work/mycode/my_avahi_v3/dependence/install
./configure --build=x86_64-pc-linux-gnu --host=arm-linux-gnueabihf --prefix=/home/sunxilong/work/mycode/my_avahi_v3/dependence/install --disable-shared --enable-static --disable-dependency-tracking --without-sysroot CC="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc -marm" CPP="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-cpp" CFLAGS="-I/home/sunxilong/work/mycode/my_avahi_v3/dependence/install/include" LDFLAGS="-L/home/sunxilong/work/mycode/my_avahi_v3/dependence/install/lib -lmd"
# ./configure \
#   --build="${BUILD_ARCH}" \
#   --host="${HOST_ARCH}" \
#   --prefix="${DEP_INSTALL}" \
#   --disable-shared \
#   --enable-static \
#   --disable-md5 \  # 新增：禁用MD5功能，绕开OpenSSL依赖
#   CC="${TOOLCHAIN}/${HOST_ARCH}-gcc" \
#   CXX="${TOOLCHAIN}/${HOST_ARCH}-g++" \
#   CFLAGS="-fPIC -Os -marm" \
#   LDFLAGS="-static -lc"

make -j$(nproc)
make install

echo "✅ libbsd-${LIBBSD_VER} 编译完成，已安装到 ${DEP_INSTALL}"