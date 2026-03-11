#!/bin/bash
# build_zen_c.sh - Zen-C窗体版本构建脚本
# 所有平台使用同一份Zen-C源代码

set -e

echo "========================================"
echo "Zen-C 贪吃蛇游戏 - 窗体版本构建脚本"
echo "========================================"

# 检查zc编译器
if ! command -v zc &> /dev/null; then
    echo "错误: 未找到 zc 编译器"
    echo "请先安装 Zen-C 编译器:"
    echo "1. 访问 https://github.com/z-libs/Zen-C"
    echo "2. 按照说明安装 zc 编译器"
    echo "3. 确保 zc 在 PATH 中"
    exit 1
fi

echo "✓ 找到 zc 编译器: $(which zc)"

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$PROJECT_DIR/src"
BUILD_DIR="$PROJECT_DIR/build"
TARGET_NAME="snake_game_zen_c"

echo "项目目录: $PROJECT_DIR"
echo "源代码目录: $SRC_DIR"
echo "构建目录: $BUILD_DIR"

# 创建构建目录
mkdir -p "$BUILD_DIR"

# 检测平台
UNAME=$(uname -s)
echo "检测到平台: $UNAME"

# 设置平台特定参数
case "$UNAME" in
    Linux*)
        PLATFORM="linux"
        ZC_FLAGS="--define=IS_LINUX"
        TARGET="$BUILD_DIR/${TARGET_NAME}_linux"
        echo "平台: Linux"
        ;;
    Darwin*)
        PLATFORM="macos"
        ZC_FLAGS="--define=IS_MACOS"
        TARGET="$BUILD_DIR/${TARGET_NAME}_macos"
        echo "平台: macOS"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        PLATFORM="windows"
        ZC_FLAGS="--define=IS_WINDOWS"
        TARGET="$BUILD_DIR/${TARGET_NAME}_windows.exe"
        echo "平台: Windows"
        ;;
    *)
        echo "警告: 未知平台 $UNAME，使用通用配置"
        PLATFORM="generic"
        ZC_FLAGS=""
        TARGET="$BUILD_DIR/$TARGET_NAME"
        ;;
esac

# 构建命令
echo "构建命令: zc $ZC_FLAGS -o $TARGET $SRC_DIR/main_window.zc $SRC_DIR/game_logic.zc $SRC_DIR/platform_api.zc"

# 执行构建
echo "开始构建..."
zc $ZC_FLAGS -o "$TARGET" \
    "$SRC_DIR/main_window.zc" \
    "$SRC_DIR/game_logic.zc" \
    "$SRC_DIR/platform_api.zc"

# 检查构建结果
if [ $? -eq 0 ]; then
    echo "✓ 构建成功!"
    echo "生成的可执行文件: $TARGET"
    
    # 显示文件信息
    if [ -f "$TARGET" ]; then
        echo "文件大小: $(du -h "$TARGET" | cut -f1)"
        echo "文件类型: $(file "$TARGET" 2>/dev/null || echo "未知")"
    fi
    
    # 平台特定说明
    case "$PLATFORM" in
        windows)
            echo ""
            echo "Windows 用户说明:"
            echo "1. 双击 $TARGET 运行游戏"
            echo "2. 或使用命令行: $TARGET"
            echo "3. 确保有必要的运行时库"
            ;;
        linux)
            echo ""
            echo "Linux 用户说明:"
            echo "1. 运行: $TARGET"
            echo "2. 可能需要安装 GTK3 库:"
            echo "   Ubuntu/Debian: sudo apt-get install libgtk-3-dev"
            echo "   Fedora: sudo dnf install gtk3-devel"
            ;;
        macos)
            echo ""
            echo "macOS 用户说明:"
            echo "1. 运行: $TARGET"
            echo "2. 可能需要安装 Xcode 命令行工具:"
            echo "   xcode-select --install"
            ;;
    esac
    
    echo ""
    echo "游戏控制说明:"
    echo "  W/A/S/D 或方向键: 移动蛇"
    echo "  空格键: 暂停/继续游戏"
    echo "  R键: 重新开始游戏"
    echo "  ESC键: 退出游戏"
    
else
    echo "✗ 构建失败!"
    exit 1
fi

echo "========================================"
echo "构建完成!"
echo "========================================"