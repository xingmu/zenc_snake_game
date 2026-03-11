#!/bin/bash
# 贪吃蛇 DIY - Linux 编译脚本

echo "======================================"
echo "    贪吃蛇 DIY - Linux 编译脚本"
echo "======================================"
echo

# 检查 gcc
if ! command -v gcc &> /dev/null; then
    echo "[错误] 未找到 GCC 编译器"
    echo "请运行: sudo apt install gcc"
    exit 1
fi

# 检查源文件
if [ ! -f "src/snake/console/snake.c" ]; then
    echo "[错误] 找不到源文件 src/snake/console/snake.c"
    exit 1
fi

echo "[1/2] 正在编译..."
gcc -o snake src/snake/console/snake.c -Wall

if [ $? -ne 0 ]; then
    echo "[错误] 编译失败！"
    exit 1
fi

echo "[2/2] 编译成功！"
echo
echo "======================================"
echo "    运行游戏: ./snake"
echo "======================================"
echo

./snake

echo
echo "游戏结束！"