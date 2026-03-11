#!/bin/bash
# macOS构建脚本 for Zen-C Snake Game

echo "Zen-C贪吃蛇游戏 - macOS构建脚本"
echo "================================"

# 检查编译器
if command -v gcc &> /dev/null; then
    echo "[INFO] 找到GCC编译器"
    COMPILER="gcc"
    CFLAGS="-Wall -Wextra -O2"
elif command -v clang &> /dev/null; then
    echo "[INFO] 找到Clang编译器"
    COMPILER="clang"
    CFLAGS="-Wall -Wextra -O2"
else
    echo "[ERROR] 未找到C编译器！"
    echo "请安装Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# 创建构建目录
mkdir -p build

# 编译
echo "[INFO] 编译游戏..."
$COMPILER $CFLAGS src/snake_game.c -o build/snake_game

if [ $? -ne 0 ]; then
    echo "[ERROR] 编译失败！"
    exit 1
fi

echo "[SUCCESS] 编译成功！"
echo ""
echo "运行游戏: ./build/snake_game"
echo "清理构建: rm -rf build"
echo ""

# 询问是否运行游戏
read -p "是否立即运行游戏？(y/n): " RUN_GAME
if [[ "$RUN_GAME" =~ ^[Yy]$ ]]; then
    echo "[INFO] 启动游戏..."
    ./build/snake_game
fi