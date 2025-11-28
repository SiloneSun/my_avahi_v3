#!/bin/bash
set -e  # 命令失败立即退出，避免隐藏错误

# -------------------------- 全局常量（硬编码，避免变量错误） --------------------------
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"  # 目标架构（开发板）
BUILD_ARCH="x86_64-pc-linux-gnu" # 宿主架构（当前PC）
DEP_SRC="/home/sunxilong/work/mycode/my_avahi_v3/dependence/src"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
LIBDAEMON_VER="0.14"
LIBDAEMON_DIR="${DEP_SRC}/libdaemon-${LIBDAEMON_VER}"


# -------------------------- 1. 清理旧环境 --------------------------
echo "【1/5】清理旧环境..."
rm -rf "${LIBDAEMON_DIR}" "${DEP_INSTALL}/lib/libdaemon*" "${DEP_INSTALL}/include/daemon.h"
mkdir -p "${DEP_SRC}" "${DEP_INSTALL}"


# -------------------------- 2. 下载并解压源码 --------------------------
echo "【2/5】下载+解压libdaemon-${LIBDAEMON_VER}..."
cd "${DEP_SRC}"
wget -c "https://0pointer.de/lennart/projects/libdaemon/libdaemon-${LIBDAEMON_VER}.tar.gz" || exit 1
tar -zxf "libdaemon-${LIBDAEMON_VER}.tar.gz" || exit 1
cd "${LIBDAEMON_DIR}"


# -------------------------- 3. 替换旧版config文件（解决架构识别） --------------------------
echo "【3/5】替换架构识别配置文件..."
wget -O config.sub "https://git.savannah.gnu.org/cgit/config.git/plain/config.sub" || exit 1
wget -O config.guess "https://git.savannah.gnu.org/cgit/config.git/plain/config.guess" || exit 1
chmod +x config.sub config.guess


# -------------------------- 4. 设置交叉编译环境变量 --------------------------
echo "【4/5】设置交叉编译环境变量..."
export ac_cv_prog_cc_works="yes"
export ac_cv_prog_cxx_works="yes"
export ac_cv_prog_cc_cross="yes"
export ac_cv_prog_cxx_cross="yes"
export ac_cv_file__dev_zero="yes"
export ac_cv_func_setpgrp_void="yes"


# -------------------------- 5. 配置+编译+安装 --------------------------
echo "【5/5】配置+编译+安装..."
./configure \
  --build="${BUILD_ARCH}" \
  --host="${HOST_ARCH}" \
  --target="${HOST_ARCH}" \
  --prefix="${DEP_INSTALL}" \
  --disable-shared \
  --enable-static \
  --disable-lynx \
  --disable-checking \
  --disable-executable-checks \
  CC="${TOOLCHAIN}/${HOST_ARCH}-gcc" \
  CXX="${TOOLCHAIN}/${HOST_ARCH}-g++" \
  AR="${TOOLCHAIN}/${HOST_ARCH}-ar" \
  RANLIB="${TOOLCHAIN}/${HOST_ARCH}-ranlib" \
  CFLAGS="-fPIC" \
  LDFLAGS="-static" || exit 1

make -j$(nproc) || exit 1
make install || exit 1


# -------------------------- 编译完成提示 --------------------------
echo -e "\n======================================"
echo "libdaemon-${LIBDAEMON_VER} 编译完成！"
echo "静态库：${DEP_INSTALL}/lib/libdaemon.a"
echo "头文件：${DEP_INSTALL}/include/daemon.h"
echo "======================================"