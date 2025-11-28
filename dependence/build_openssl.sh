#!/bin/bash
set -e
# 路径配置（复用你的工具链和依赖目录）
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
OPENSSL_VER="1.1.1w"  # 稳定版本

# 下载并编译OpenSSL
cd /home/sunxilong/work/mycode/my_avahi_v3/dependence/src
mkdir -p openssl_build && cd openssl_build
# wget https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz
tar -xf openssl-${OPENSSL_VER}.tar.gz
cd openssl-${OPENSSL_VER}


./Configure linux-armv4 \  # 基础ARM目标（避免目标识别问题）
  --prefix="${DEP_INSTALL}" \
  no-shared \  # 仅编译静态库
  no-dso \
  CC="${TOOLCHAIN}/${HOST_ARCH}-gcc -marm -march=armv7-a" \  # 直接指定完整编译器路径+架构
  AR="${TOOLCHAIN}/${HOST_ARCH}-ar" \
  RANLIB="${TOOLCHAIN}/${HOST_ARCH}-ranlib"

# 编译+安装（仅静态库）
make -j$(nproc)
make install_sw  # 仅安装库和头文件，不安装文档

echo "✅ OpenSSL-${OPENSSL_VER} 编译完成，libcrypto已安装到 ${DEP_INSTALL}"
