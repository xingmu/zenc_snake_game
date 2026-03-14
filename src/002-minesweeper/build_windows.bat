@echo off
REM Zen-C Minesweeper Game Windows Build Script
REM 使用zc编译器在Windows上构建游戏

echo ========================================
echo Zen-C Minesweeper 编译脚本
echo ========================================
echo.

REM 检查zc编译器
where zc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到zc编译器
    echo 请先安装Zen-C编译器
    echo 下载地址: https://github.com/z-libs/Zen-C
    echo.
    pause
    exit /b 1
)

REM 创建build目录
if not exist build mkdir build

REM 编译游戏
echo [编译中] 正在编译 minesweeper...
zc build -o build\minesweeper.exe src\main_window.zc

if %ERRORLEVEL% NEQ 0 (
    echo [错误] 编译失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo [成功] 编译完成!
echo 输出文件: build\minesweeper.exe
echo ========================================
echo.

REM 询问是否运行
set /p RUN=是否现在运行游戏? (Y/N): 
if /i "%RUN%"=="Y" (
    echo.
    cd build
    minesweeper.exe
)

pause
