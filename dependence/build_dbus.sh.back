#!/bin/bash
set -e  # 命令失败立即退出

# -------------------------- 全局常量（适配你已有的dbus-1.12.20） --------------------------
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_SRC="/home/sunxilong/work/mycode/my_avahi_v3/dependence/src"  # 源码存放目录（含zip包和解压后的源码）
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
DBUS_VER="1.12.20"
DBUS_ZIP="dbus-${DBUS_VER}.tar.gz"  # 你已下载的源码包文件名
DBUS_ZIP_PATH="${DEP_SRC}/${DBUS_ZIP}"  # 已下载的源码包路径
DBUS_DIR="${DEP_SRC}/dbus-${DBUS_VER}"  # 解压后的源码目录
BOARD_DBUS_CONFIG="/customer/etc/dbus-1/system.conf"  # 板端配置路径

# 显式定义工具完整路径（避免拼接错误）
CC="${TOOLCHAIN}/${HOST_ARCH}-gcc"
CXX="${TOOLCHAIN}/${HOST_ARCH}-g++"
AR="${TOOLCHAIN}/${HOST_ARCH}-ar"
RANLIB="${TOOLCHAIN}/${HOST_ARCH}-ranlib"


# -------------------------- 1. 检查已下载的源码包+解压逻辑（不删除zip，不重新下载） --------------------------
echo "【1/4】检查DBus源码是否可用..."
if [ -d "${DBUS_DIR}" ]; then
  echo "✅ 已找到解压后的源码目录：${DBUS_DIR}，直接使用"
else
  if [ -f "${DBUS_ZIP_PATH}" ]; then
    echo "✅ 已找到源码包：${DBUS_ZIP_PATH}，开始解压..."
    tar -zxf "${DBUS_ZIP_PATH}" -C "${DEP_SRC}"
    echo "✅ 解压完成，源码目录：${DBUS_DIR}"
  else
    echo "❌ 错误：未找到DBus源码包和解压目录！"
    echo "请将已下载的 ${DBUS_ZIP} 放到以下路径：${DEP_SRC}/"
    exit 1
  fi
fi


# -------------------------- 2. 清理旧编译产物（仅清理安装目录，不碰源码） --------------------------
echo "【2/4】清理旧编译安装文件..."
rm -rf "${DEP_INSTALL}/lib/libdbus*" \
       "${DEP_INSTALL}/include/dbus" \
       "${DEP_INSTALL}/bin/dbus*" \
       "${DEP_INSTALL}/libexec" \
       "${DEP_INSTALL}/share/dbus-1" \
       "${DEP_INSTALL}/etc/dbus-1"
mkdir -p "${DEP_INSTALL}"


# -------------------------- 3. 替换旧config文件+设置环境变量 --------------------------
echo "【3/4】配置交叉编译环境..."
cd "${DBUS_DIR}"

# 替换旧的config.sub/config.guess（仅首次执行）
# if [ ! -f "config.sub.bak" ]; then
#   echo "📥 下载适配的config文件（仅首次执行）..."
#   cp config.sub config.sub.bak
#   cp config.guess config.guess.bak
#   wget -O config.sub "https://git.savannah.gnu.org/cgit/config.git/plain/config.sub" || exit 1
#   wget -O config.guess "https://git.savannah.gnu.org/cgit/config.git/plain/config.guess" || exit 1
#   chmod +x config.sub config.guess
# else
#   echo "✅ 已存在适配的config文件，跳过下载"
# fi
cp /home/sunxilong/work/mycode/my_avahi_v3/config.sub .
cp /home/sunxilong/work/mycode/my_avahi_v3/config.guess .
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


# -------------------------- 4. 配置+编译+安装（关键修改：修复工具路径+抑制警告） --------------------------
echo "【4/4】编译安装DBus-${DBUS_VER}..."
./configure \
  --build="${BUILD_ARCH}" \
  --host="${HOST_ARCH}" \
  --target="${HOST_ARCH}" \
  --prefix="/customer" \
  --sysconfdir=/customer/etc \
  --disable-shared \
  --enable-static \
  --disable-tests \
  --disable-xml-docs \
  --disable-selinux \
  --disable-systemd \
  --with-expat=builtin \
  --without-x \
  --with-system-config-file="${BOARD_DBUS_CONFIG}" \
  # 关键1：显式指定工具路径（避免libtool解析错误）
  CC="${CC}" \
  CXX="${CXX}" \
  AR="${AR}" \
  RANLIB="${RANLIB}" \
  # 关键2：添加 -Wno-cast-align 抑制对齐警告，-fpermissive 兼容旧语法
  CFLAGS="-fPIC -Os -Wno-cast-align -fpermissive" \
  LDFLAGS="-static" || exit 1

make -j$(nproc) || exit 1
mkdir -p $PWD/staging
make DESTDIR=$PWD/staging install || exit 1  # 重点是这里，指定安装目录，避免污染宿主机环境；从staging目录下拷贝到最终运行的环境（板端）


# -------------------------- 完成提示 --------------------------
echo -e "\n======================================"
echo "🎉 DBus-${DBUS_VER} 编译安装完成！"
echo "======================================"
echo "📁 关键路径说明："
echo "  - 源码包（已保留）：${DBUS_ZIP_PATH}"
echo "  - 源码目录（已保留）：${DBUS_DIR}"
echo "  - 静态库：${DEP_INSTALL}/lib/libdbus-1.a"
echo "  - 板端默认配置路径：${BOARD_DBUS_CONFIG}"
echo "======================================"