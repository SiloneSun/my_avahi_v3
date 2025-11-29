#!/bin/bash
set -e  # 命令失败立即退出，便于排查问题
set -u  # 未定义变量直接报错，避免隐蔽bug

# -------------------------- 核心路径配置（和你之前成功时保持一致） --------------------------
TOOLCHAIN="/home/sunxilong/work/disk4T/code/sxw0505/tools/gcc-11.1.0-20210608-sigmastar-glibc-x86_64_arm-linux-gnueabihf/bin"
HOST_ARCH="arm-linux-gnueabihf"
BUILD_ARCH="x86_64-pc-linux-gnu"
DEP_INSTALL="/home/sunxilong/work/mycode/my_avahi_v3/dependence/install"
AVAHI_SRC_DIR="/home/sunxilong/work/mycode/my_avahi_v3/src"
AVAHI_INSTALL_DIR="/home/sunxilong/work/mycode/my_avahi_v3/src/avahi-0.7/staging"
AVAHI_VER="0.7"
AVAHI_DIR="${AVAHI_SRC_DIR}/avahi-${AVAHI_VER}"
CONFIG_FILE_DIR="/home/sunxilong/work/mycode/my_avahi_v3"

# -------------------------- 1. 清理（只清编译产物，不碰源码，和之前成功时一致） --------------------------
echo -e "\n【1/6】🔧 清理avahi旧编译环境..."
rm -rf "${AVAHI_INSTALL_DIR:?}/"* || true
rm -rf "${AVAHI_DIR}/.deps" "${AVAHI_DIR}/.libs" "${AVAHI_DIR}/*.o" \
       "${AVAHI_DIR}/config.log" "${AVAHI_DIR}/config.status" "${AVAHI_DIR}/Makefile" || true
mkdir -p "${AVAHI_SRC_DIR}" "${AVAHI_INSTALL_DIR}"

# -------------------------- 2. 检查本地源码（和之前一致） --------------------------
echo -e "\n【2/6】📁 检查avahi本地源码..."
cd "${AVAHI_SRC_DIR}"
if [ ! -d "${AVAHI_DIR}" ]; then
  echo "❌ 错误：未找到avahi源码目录！请放置源码到 ${AVAHI_DIR}"
  exit 1
fi
cd "${AVAHI_DIR}"
echo "✅ 本地源码验证通过：${AVAHI_DIR}"

# -------------------------- 3. 复制config文件（和之前一致） --------------------------
echo -e "\n【3/6】⚙️  配置架构识别文件..."
if [ ! -f "${CONFIG_FILE_DIR}/config.sub" ] || [ ! -f "${CONFIG_FILE_DIR}/config.guess" ]; then
  echo "❌ 错误：未找到本地config文件！请放置到 ${CONFIG_FILE_DIR}"
  exit 1
fi
cp -f "${CONFIG_FILE_DIR}/config.sub" ./
cp -f "${CONFIG_FILE_DIR}/config.guess" ./
chmod +x config.sub config.guess
echo "✅ 架构识别文件配置完成"
# -------------------------- 4. 关键修复：正确禁用QT组件+隔离系统pkg-config + 变量初始化 --------------------------
echo -e "\n【4/6】🌐 配置环境（正确禁用QT组件+隔离系统依赖+变量初始化）..."
# 核心1：强制pkg-config只查询你的依赖目录（不查系统目录！避免系统QT3干扰）
export PKG_CONFIG_LIBDIR="${DEP_INSTALL}/lib/pkgconfig"  # 只查依赖目录的.pc文件
export PKG_CONFIG_PATH=""  # 清空路径，避免冲突
export PKG_CONFIG_DISABLE_UNINSTALLED=1  # 禁用未安装的库查询

# 核心2：静态编译和线程配置（保留你之前成功时的配置）
export ac_cv_func_pthread_create_static=yes
export ac_cv_lib_pthread_pthread_create=yes
export ac_cv_header_pthread_h=yes
export ac_cv_func_pthread_create=yes
export ac_cv_test_shared=no
export ac_cv_check_lib_shared=no
export ac_cv_prog_cc_shared=no

# 核心3：QT相关变量清空（双重保障）
export QT3_CFLAGS=""
export QT3_LIBS=""
export QT4_CFLAGS=""
export QT4_LIBS=""

# 新增：初始化 CFLAGS/LDFLAGS（避免 set -u 报错，默认加优化参数）
export CFLAGS="-Os"  # -Os：优化编译体积（嵌入式常用，可改为 -O2 或空值）
export LDFLAGS=""    # 初始为空，后续拼接DBus库路径
echo "✅ 环境配置完成（已隔离系统pkg-config，变量初始化完成）"

# -------------------------- 5. 修复版 configure（强制交叉编译+工具链完整路径） --------------------------
echo -e "\n【5/6】修复版 configure（强制交叉编译+工具链完整路径）..."

# 定义工具链完整路径（直接写死，无变量替换，100%正确）
CC_FULL="${TOOLCHAIN}/arm-linux-gnueabihf-gcc"
CPP_FULL="${TOOLCHAIN}/arm-linux-gnueabihf-cpp"
AR_FULL="${TOOLCHAIN}/arm-linux-gnueabihf-ar"
RANLIB_FULL="${TOOLCHAIN}/arm-linux-gnueabihf-ranlib"
LD_FULL="${TOOLCHAIN}/arm-linux-gnueabihf-ld"

# 简化configure命令（关键参数不换行，避免截断）
${AVAHI_DIR}/configure --build="${BUILD_ARCH}" --host="${HOST_ARCH}" --target="${HOST_ARCH}" --prefix="/customer" --sysconfdir=/customer/etc --with-distro=none \
  --disable-qt3 --disable-qt4 --without-qt3 --without-qt4 --disable-avahi-ui --disable-gtk --disable-gtk2 --disable-gtk3 --without-x \
  --enable-dbus --with-dbus-sysconf-dir="${DEP_INSTALL}/etc/dbus-1/system.d" --with-dbus-service-dir="${DEP_INSTALL}/share/dbus-1/services" \
  --enable-static --disable-shared --disable-dependency-tracking --without-sysroot --disable-runpath \
  ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ac_cv_prog_cc_cross=yes ac_cv_prog_cxx_cross=yes \
  --disable-gdbm --disable-glib --disable-gobject --disable-cxx --disable-python --disable-mono --disable-perl --disable-tcl --disable-autoipd --disable-client \
  CC="${CC_FULL}" CPP="${CPP_FULL}" AR="${AR_FULL}" RANLIB="${RANLIB_FULL}" LD="${LD_FULL}" \
  CFLAGS="${CFLAGS} -I${DEP_INSTALL}/include -I${DEP_INSTALL}/include/dbus-1.0 -I${DEP_INSTALL}/lib/dbus-1.0/include" \
  LDFLAGS="${LDFLAGS} -L${DEP_INSTALL}/lib -ldbus-1 -lpthread -lc" \
  QT3_CFLAGS="${QT3_CFLAGS}" QT3_LIBS="${QT3_LIBS}" QT4_CFLAGS="${QT4_CFLAGS}" QT4_LIBS="${QT4_LIBS}"


# -------------------------- 6. 编译+安装（优化兼容性+修正说明） --------------------------
echo -e "\n【6/6】🔨 开始编译 avahi-${AVAHI_VER}（多线程模式）..."
# 确保在avahi源码目录执行编译（避免目录错乱导致make失败）
cd ${AVAHI_DIR} || exit 1

# 多线程编译（用系统最大可用线程，加快速度；失败时提示更精准）
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo -e "\n❌ avahi编译失败！"
  echo "  排查方向："
  echo "  1. 依赖库缺失：检查 ${DEP_INSTALL}/lib 是否有 libdbus-1.a（DBus静态库）"
  echo "  2. 链接顺序错误：确保 -ldbus-1 -lpthread 在avahi库之后"
  echo "  3. 工具链兼容性：若提示-marm/-mthumb冲突，可在CFLAGS中添加 -mthumb"
  exit 1
fi

mkdir -p $PWD/staging
# 安装（指定DESTDIR可避免权限问题，若安装目录有写入权限可直接make install）
make install DESTDIR="$PWD/staging"  # DESTDIR为空时直接安装到--prefix指定的目录
if [ $? -ne 0 ]; then
  echo -e "\n❌ avahi安装失败！"
  echo "  解决方案："
  echo "  1. 检查安装目录权限：sudo chmod -R 755 ${AVAHI_INSTALL_DIR}"
  echo "  2. 用sudo执行build.sh（仅安装阶段需要root权限）"
  exit 1
fi

cd $PWD/staging
ls -trlh

tar -zcvf avahi.tar.gz ./customer
cp avahi.tar.gz ~/work/tftp/

# -------------------------- 完成提示（修正核心修正说明，避免误解） --------------------------
echo -e "\n======================================"
echo -e "✅ 【编译成功】avahi-${AVAHI_VER} 部署完成！"
echo -e "======================================"
echo -e "📁 关键路径："
echo -e "  源码目录：${AVAHI_DIR}"
echo -e "  安装目录：${AVAHI_INSTALL_DIR}"
echo -e "  DBus依赖目录：${DEP_INSTALL}"
echo -e "\n🔧 核心修正说明（本次成功的关键）："
echo -e "  1. QT禁用：用avahi 0.7原生支持的 --disable-qt3 --without-qt3（而非--disable-avahi-qt3）"
echo -e "  2. 交叉编译：工具链写完整路径，避免变量替换错误；参数置顶确保解析"
echo -e "  3. 环境隔离：pkg-config只查你的依赖目录，杜绝系统QT3干扰"
echo -e "  4. 变量初始化：补全CFLAGS/LDFLAGS默认值，适配set -u严格模式"
echo -e "\n⚠️  链接顺序提示（项目集成时用）："
echo -e "  正确顺序：-lavahi-core -lavahi-client -lavahi-common -ldbus-1 -lpthread -lc"
echo -e "  备注：-lbsd -lmd 仅当系统缺少对应函数时需要（嵌入式通常无需添加）"
echo -e "\n🚀 启动步骤（嵌入式设备）："
echo -e "  1. 启动DBus：${DEP_INSTALL}/sbin/dbus-daemon --system --fork --config-file=${DEP_INSTALL}/etc/dbus-1/system.conf"
echo -e "  2. 启动avahi：${AVAHI_INSTALL_DIR}/sbin/avahi-daemon -D"
echo -e "  3. 验证：${AVAHI_INSTALL_DIR}/sbin/avahi-daemon --check（无报错则正常）"
echo -e "======================================"


md5sum ${AVAHI_INSTALL_DIR}/customer/sbin/avahi-daemon
