#!/bin/bash
set -e  # 命令失败立即退出

# -------------------------- 全局常量 --------------------------
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_SRC="/home/sunxilong/work/mycode/my_avahi_v3/dependence/src"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
LIBNL_VER="3.5.0"
LIBNL_DIR="${DEP_SRC}/libnl-${LIBNL_VER}"


# -------------------------- 1. 检查源码 --------------------------
echo "【1/4】检查libnl源码..."
[ ! -d "${LIBNL_DIR}" ] && echo "错误：libnl源码目录不存在" && exit 1


# -------------------------- 2. 清理旧环境 --------------------------
echo "【2/4】清理旧环境..."
rm -rf "${DEP_INSTALL}/lib/libnl-"* "${DEP_INSTALL}/include/netlink"
rm -rf "${DEP_INSTALL}/lib/pkgconfig/libnl"*
mkdir -p "${DEP_INSTALL}"


# -------------------------- 3. 替换config文件+设置环境变量 --------------------------
echo "【3/4】配置环境..."
cd "${LIBNL_DIR}"
wget -O config.sub "https://git.savannah.gnu.org/cgit/config.git/plain/config.sub" || exit 1
wget -O config.guess "https://git.savannah.gnu.org/cgit/config.git/plain/config.guess" || exit 1
chmod +x config.sub config.guess

export ac_cv_prog_cc_works="yes"
export ac_cv_prog_cxx_works="yes"
export ac_cv_file__dev_zero="yes"
export PKG_CONFIG_PATH="${DEP_INSTALL}/lib/pkgconfig"  # 用系统pkg-config+自定义路径


# -------------------------- 4. 配置+编译+安装（修复核心问题） --------------------------
echo "【4/4】编译libnl..."
# 移除PKG_CONFIG参数（工具链无对应文件），修正语法格式
./configure \
  --build="${BUILD_ARCH}" \
  --host="${HOST_ARCH}" \
  --prefix="${DEP_INSTALL}" \
  --disable-shared \
  --enable-static \
  --disable-cli \
  --disable-debug \
  --disable-doc \
  --without-route \
  --without-bridge \
  --without-neigh \
  CC="${TOOLCHAIN}/${HOST_ARCH}-gcc" \
  CXX="${TOOLCHAIN}/${HOST_ARCH}-g++" \
  AR="${TOOLCHAIN}/${HOST_ARCH}-ar" \
  RANLIB="${TOOLCHAIN}/${HOST_ARCH}-ranlib" \
  CFLAGS="-fPIC -Os" \
  LDFLAGS="-static"

# 检查configure是否成功
if [ $? -ne 0 ]; then
  echo "libnl configure失败"
  exit 1
fi

# 编译+安装
make -j$(nproc) || { echo "libnl编译失败"; exit 1; }
make install || { echo "libnl安装失败"; exit 1; }


# -------------------------- 完成提示 --------------------------
echo -e "\n======================================"
echo "✅ libnl-${LIBNL_VER} 编译完成！"
echo "静态库：${DEP_INSTALL}/lib/libnl-3.a"
echo "头文件：${DEP_INSTALL}/include/netlink/"
echo "======================================"