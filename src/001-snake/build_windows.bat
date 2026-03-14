@echo off
REM Zen-C Snake Game Windows构建脚本
REM 需要安装zc编译器和MinGW

echo Zen-C贪吃蛇游戏 - Windows构建脚本
echo ========================================

REM 检查zc编译器
where zc >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: zc编译器未安装
    echo 请从 https://github.com/z-libs/Zen-C 安装zc编译器
    echo.
    echo 安装步骤:
    echo 1. git clone https://github.com/z-libs/Zen-C.git
    echo 2. cd Zen-C
    echo 3. make install
    pause
    exit /b 1
)

REM 检查gcc编译器
where gcc >nul 2>nul
if %errorlevel% neq 0 (
    echo 警告: gcc编译器未安装
    echo 建议安装MinGW或MSYS2
    echo.
    echo 安装MinGW:
    echo 1. 下载 https://sourceforge.net/projects/mingw/
    echo 2. 安装并添加gcc到PATH
    pause
)

REM 显示编译器版本
echo.
echo 编译器信息:
zc --version
if %errorlevel% equ 0 (
    echo zc编译器: 已安装
) else (
    echo zc编译器: 未正确安装
)

REM 创建构建目录
if not exist build mkdir build

REM 编译Zen-C代码
echo.
echo 正在编译Zen-C代码...
zc build -o build\snake_game.exe src\main_window.zc

if %errorlevel% equ 0 (
    echo 编译成功!
    echo.
    echo 运行游戏:
    echo build\snake_game.exe
    echo.
    echo 或者直接运行:
    echo snake_game.exe
) else (
    echo 编译失败!
    echo 请检查错误信息
)

pause