#!/bin/bash
# Zen-C Snake Game macOS构建脚本

echo "Zen-C贪吃蛇游戏 - macOS构建脚本"
echo "========================================"

# 检查zc编译器
if ! command -v zc &> /dev/null; then
    echo "错误: zc编译器未安装"
    echo "请从 https://github.com/z-libs/Zen-C 安装zc编译器"
    echo ""
    echo "安装步骤:"
    echo "1. git clone https://github.com/z-libs/Zen-C.git"
    echo "2. cd Zen-C"
    echo "3. make install"
    exit 1
fi

# 检查gcc编译器
if ! command -v gcc &> /dev/null; then
    echo "警告: gcc编译器未安装"
    echo "建议安装Xcode Command Line Tools:"
    echo "xcode-select --install"
fi

# 显示编译器版本
echo ""
echo "编译器信息:"
zc --version
if [ $? -eq 0 ]; then
    echo "zc编译器: 已安装"
else
    echo "zc编译器: 未正确安装"
fi

# 创建构建目录
mkdir -p build

# 编译Zen-C代码
echo ""
echo "正在编译Zen-C代码..."
zc build -o build/snake_game src/main.zc

if [ $? -eq 0 ]; then
    echo "编译成功!"
    echo ""
    echo "运行游戏:"
    echo "./build/snake_game"
    echo ""
    echo "或者直接运行:"
    echo "./snake_game"
else
    echo "编译失败!"
    echo "请检查错误信息"
fi