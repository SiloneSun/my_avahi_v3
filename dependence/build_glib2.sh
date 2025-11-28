#!/bin/bash
set -e

# 全局路径（固定）
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
GLIB_DIR="/home/sunxilong/work/mycode/my_avahi_v3/dependence/src/glib-2.66.7"


# 1. 检查依赖
echo "【1/4】检查依赖..."
[ ! -d "${GLIB_DIR}" ] && echo "错误：glib源码目录不存在" && exit 1


# 2. 生成交叉配置文件
echo "【2/4】生成交叉配置..."
cd "${GLIB_DIR}"
cat > cross_arm.txt << EOF
[binaries]
c = '${TOOLCHAIN}/${HOST_ARCH}-gcc'
cpp = '${TOOLCHAIN}/${HOST_ARCH}-g++'
ar = '${TOOLCHAIN}/${HOST_ARCH}-ar'
pkg-config = '${TOOLCHAIN}/${HOST_ARCH}-pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'armv7'
endian = 'little'
EOF


# 3. 清理旧构建
echo "【3/4】清理旧环境..."
rm -rf builddir


# 4. 编译（移除未知的python选项）
echo "【4/4】编译glib..."
export PKG_CONFIG_PATH="${DEP_INSTALL}/lib/pkgconfig"

# 仅保留glib-2.66.7支持的选项
meson setup builddir --cross-file cross_arm.txt --prefix="${DEP_INSTALL}" --default-library=static -Dnls=disabled -Diconv=libc

ninja -C builddir
ninja -C builddir install


echo -e "\n✅ glib-2.66.7 编译完成！"