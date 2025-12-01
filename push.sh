#!/bin/bash
set -euo pipefail

# 配置参数（板端已有配置，仅拷贝二进制程序）
SHARE_PATH=~/work/tftp  # TFTP共享目录
# 仅拷贝全静态二进制程序（无需库/配置）
BIN_FILES=(
    "./install/sbin/avahi-daemon"
    "./install/bin/avahi-publish"
    "./dependence/install/bin/dbus-daemon"
)

# 确保TFTP目录存在
if [ ! -d "$SHARE_PATH" ]; then
    echo "📁 创建TFTP目录：$SHARE_PATH"
    mkdir -p "$SHARE_PATH"
fi

# 用你的copy_file工具拷贝二进制程序（MD5校验）
echo "=== 拷贝全静态二进制程序到TFTP ==="
for bin_file in "${BIN_FILES[@]}"; do
    # echo "📤 处理：$bin_file"
    copy_file "$bin_file" "$SHARE_PATH"
done

# # 完成提示
# echo -e "\n✅ 拷贝完成！TFTP目录仅包含全静态程序："

# echo -e "\n🚀 板端部署步骤（复用已有配置）："
# echo "1. 从TFTP将程序拷贝到板端的 /usr/bin 或 /root/bin 目录（任意可执行路径）"
# echo "2. 启动顺序（板端执行）："
# echo "   - 先启动DBus：dbus-daemon --system --fork（板端默认配置）"
# echo "   - 再启动avahi：avahi-daemon -D（自动读取板端/etc/avahi/avahi-daemon.conf）"
# echo "3. 验证：ps | grep avahi-daemon（查看进程是否存在）"