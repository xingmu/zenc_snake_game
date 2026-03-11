@echo off
chcp 65001 >nul
title 贪吃蛇 DIY - 编译

echo ======================================
echo    贪吃蛇 DIY - 编译脚本
echo ======================================
echo.

if not exist "src\snake\console\snake.c" (
    echo [错误] 找不到源文件 src\snake\console\snake.c
    pause
    exit /b 1
)

echo [1/2] 正在编译...
gcc -o snake.exe src\snake\console\snake.c -Wall 2>nul
if errorlevel 1 (
    echo [错误] 编译失败！
    echo 请确保已安装 GCC 编译器
    pause
    exit /b 1
)

echo [2/2] 编译成功！
echo.
echo ======================================
echo    运行游戏: snake.exe
echo ======================================
echo.

snake.exe

if errorlevel 1 (
    echo.
    echo 游戏结束！
)

pause