@echo off
echo ========================================
echo   Zen-C 贪吃蛇游戏 - Windows窗体版构建脚本
echo ========================================
echo.

REM 检查是否安装了MinGW
where gcc >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到MinGW GCC编译器
    echo.
    echo 请安装MinGW:
    echo 1. 下载: https://sourceforge.net/projects/mingw/
    echo 2. 安装时选择: mingw32-base, mingw32-gcc-g++
    echo 3. 添加C:\MinGW\bin到系统PATH
    echo.
    pause
    exit /b 1
)

echo ✅ 找到MinGW GCC编译器
echo.

REM 设置编译选项
set SOURCE_FILE=src\windows\snake_game_win32.c
set OUTPUT_FILE=build\snake_game_win32.exe
set COMPILE_OPTIONS=-O2 -Wall -Wextra -mwindows -DUNICODE -D_UNICODE

REM 创建构建目录
if not exist build mkdir build

echo 🔨 正在编译Windows窗体版贪吃蛇游戏...
echo 源文件: %SOURCE_FILE%
echo 输出文件: %OUTPUT_FILE%
echo.

REM 编译游戏
gcc %COMPILE_OPTIONS% %SOURCE_FILE% -o %OUTPUT_FILE%

if %errorlevel% neq 0 (
    echo ❌ 编译失败!
    echo 请检查错误信息
    pause
    exit /b 1
)

echo ✅ 编译成功!
echo.
echo 📁 输出文件: %OUTPUT_FILE%
echo 📏 文件大小: 
for %%F in (%OUTPUT_FILE%) do echo        %%~zF 字节
echo.

REM 检查依赖
echo 🔍 检查运行时依赖...
dumpbin /dependents %OUTPUT_FILE% | findstr ".dll"
echo.

REM 创建运行脚本
echo 📝 创建运行脚本...
echo @echo off > build\run_game.bat
echo echo 正在启动Zen-C贪吃蛇游戏... >> build\run_game.bat
echo echo ======================================== >> build\run_game.bat
echo %OUTPUT_FILE% >> build\run_game.bat
echo pause >> build\run_game.bat

echo 🎮 游戏已准备就绪!
echo.
echo 运行方式:
echo 1. 双击 build\run_game.bat
echo 2. 或直接运行 %OUTPUT_FILE%
echo.
echo 🎯 游戏控制:
echo   方向键/WASD: 移动蛇
echo   空格键: 暂停/继续
echo   R键: 重新开始
echo   ESC键: 退出游戏
echo.
echo 🖼️ 游戏特性:
echo   - 美观的窗体界面
echo   - 彩色图形显示
echo   - 分数和等级系统
echo   - 网格背景
echo   - 专业UI面板
echo.

REM 测试运行
echo 🧪 是否要测试运行游戏? (Y/N)
set /p TEST_RUN=
if /i "%TEST_RUN%"=="Y" (
    echo.
    echo 🚀 启动游戏...
    echo.
    start "" "%OUTPUT_FILE%"
    echo 游戏已启动!
)

echo.
echo ========================================
echo   构建完成! 按任意键退出...
echo ========================================
pause >nul