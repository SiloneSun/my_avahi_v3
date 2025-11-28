#!/bin/bash
set -e  # 命令失败立即退出

# -------------------------- 全局常量（适配你已有的dbus-1.12.20） --------------------------
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_SRC="/home/sunxilong/work/mycode/my_avahi_v3/dependence/src"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
DBUS_VER="1.12.20"  # 改为你已有的版本
DBUS_DIR="${DEP_SRC}/dbus-${DBUS_VER}"  # 确保你的源码放在这个目录


# -------------------------- 1. 前置准备（确认你已有的源码存在） --------------------------
echo "【1/4】检查dbus-1.12.20源码是否存在..."
if [ ! -d "${DBUS_DIR}" ]; then
  echo "错误：请将已下载的dbus-1.12.20源码解压到 ${DBUS_DIR}"
  exit 1
fi


# -------------------------- 2. 清理旧环境 --------------------------
echo "【2/4】清理dbus旧环境..."
rm -rf "${DEP_INSTALL}/lib/libdbus*" "${DEP_INSTALL}/include/dbus"
rm -rf "${DEP_INSTALL}/bin/dbus*" "${DEP_INSTALL}/libexec"
mkdir -p "${DEP_INSTALL}"


# -------------------------- 3. 替换旧config文件+设置环境变量 --------------------------
echo "【3/4】替换架构配置+设置环境变量..."
cd "${DBUS_DIR}"

# 替换旧config.sub/config.guess（解决架构识别）
wget -O config.sub "https://git.savannah.gnu.org/cgit/config.git/plain/config.sub" || exit 1
wget -O config.guess "https://git.savannah.gnu.org/cgit/config.git/plain/config.guess" || exit 1
chmod +x config.sub config.guess

# 导出交叉编译环境变量
export ac_cv_prog_cc_works="yes"
export ac_cv_prog_cxx_works="yes"
export ac_cv_prog_cc_cross="yes"
export ac_cv_prog_cxx_cross="yes"
export ac_cv_file__dev_zero="yes"
export ac_cv_func_posix_getpwnam_r="yes"
export dbus_cv_have_abstract_sockets="yes"
export dbus_cv_epoll="yes"


# -------------------------- 4. 配置+编译+安装 --------------------------
echo "【4/4】配置+编译+安装dbus-1.12.20..."
./configure \
  --build="${BUILD_ARCH}" \
  --host="${HOST_ARCH}" \
  --target="${HOST_ARCH}" \
  --prefix="${DEP_INSTALL}" \
  --disable-shared \
  --enable-static \
  --disable-tests \
  --disable-xml-docs \
  --disable-selinux \
  --disable-systemd \
  --with-expat=builtin \
  --without-x \
  CC="${TOOLCHAIN}/${HOST_ARCH}-gcc" \
  CXX="${TOOLCHAIN}/${HOST_ARCH}-g++" \
  AR="${TOOLCHAIN}/${HOST_ARCH}-ar" \
  RANLIB="${TOOLCHAIN}/${HOST_ARCH}-ranlib" \
  CFLAGS="-fPIC -Os" \
  LDFLAGS="-static" || exit 1

make -j$(nproc) || exit 1
make install || exit 1


# -------------------------- 完成提示 --------------------------
echo -e "\n======================================"
echo "dbus-1.12.20 编译完成！"
echo "静态库：${DEP_INSTALL}/lib/libdbus-1.a"
echo "头文件：${DEP_INSTALL}/include/dbus-1.0/"
echo "======================================"