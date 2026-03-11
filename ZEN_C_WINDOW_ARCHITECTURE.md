# Zen-C窗体版本架构设计

## 🚨 问题识别
当前窗体版本使用了原生语言（C/C/Objective-C），违反了用户的核心要求：
**"不管是开发哪个平台，都要使用指定的zenc开发语言，而不是c"**

## 🎯 解决方案：真正的Zen-C窗体架构

### 核心原则
1. **所有平台使用Zen-C语言** - 没有单独的C语言版本
2. **条件编译处理平台差异** - 使用`#if IS_WINDOWS`等宏
3. **统一的Zen-C代码库** - 所有平台共用同一份Zen-C源代码
4. **平台特定API封装** - 在Zen-C中调用平台API

### 架构设计

```
src/
├── main.zc                    # 主入口点，包含平台检测
├── game_logic.zc              # 核心游戏逻辑（平台无关）
├── platform/
│   ├── windows_api.zc        # Windows API封装
│   ├── linux_api.zc          # Linux GTK/SDL封装
│   ├── macos_api.zc          # macOS Cocoa封装
│   └── common_api.zc         # 跨平台API抽象
└── ui/
    ├── window.zc             # 窗口管理抽象
    ├── graphics.zc           # 图形绘制抽象
    └── input.zc              # 输入处理抽象
```

### Zen-C平台API封装示例

```zc
// windows_api.zc - Zen-C封装Win32 API
#if IS_WINDOWS

import std.ffi;

// 定义Windows类型
type HWND = *void;
type HDC = *void;
type HINSTANCE = *void;

// 导入Windows API函数
extern "user32.dll" fn CreateWindowExA(
    dwExStyle: u32,
    lpClassName: *const i8,
    lpWindowName: *const i8,
    dwStyle: u32,
    x: i32,
    y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: HWND,
    hMenu: *void,
    hInstance: HINSTANCE,
    lpParam: *void
) -> HWND;

// Zen-C友好的窗口创建函数
fn create_window(title: string, width: i32, height: i32) -> HWND {
    let hwnd = CreateWindowExA(
        0,
        "STATIC",  // 简单窗口类
        title.c_str(),
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT,
        width, height,
        null,
        null,
        GetModuleHandleA(null),
        null
    );
    return hwnd;
}

#endif
```

### 构建系统

```makefile
# Makefile - 所有平台使用zc编译器
TARGET = snake_game
ZC = zc
ZCFLAGS = --platform=auto

# 检测平台
UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
    PLATFORM = linux
    ZCFLAGS += --define=IS_LINUX
else ifeq ($(UNAME),Darwin)
    PLATFORM = macos
    ZCFLAGS += --define=IS_MACOS
else
    PLATFORM = windows
    ZCFLAGS += --define=IS_WINDOWS
endif

all: $(TARGET)

$(TARGET): src/main.zc src/game_logic.zc src/platform/*.zc
    $(ZC) $(ZCFLAGS) -o $@ $^

clean:
    rm -f $(TARGET)
```

### 实现步骤

1. **创建平台检测宏** - 在Zen-C中检测当前平台
2. **封装平台API** - 为每个平台创建Zen-C封装
3. **统一游戏逻辑** - 所有平台使用相同的游戏逻辑
4. **条件编译UI** - 根据平台选择不同的UI实现
5. **测试所有平台** - 确保Zen-C代码在所有平台编译运行

### 优势

1. **真正的Zen-C代码** - 没有C语言文件
2. **代码复用最大化** - 90%代码在所有平台共用
3. **维护简单** - 只有一个代码库
4. **符合用户要求** - 所有平台使用指定的Zen-C语言
5. **现代化架构** - 使用Zen-C的现代特性

### 立即行动

1. 删除所有C语言文件（`*.c`, `*.m`）
2. 创建Zen-C平台API封装
3. 重构游戏逻辑为纯Zen-C
4. 更新构建系统使用`zc`编译器
5. 测试跨平台编译

**目标：所有平台使用同一份Zen-C源代码，通过条件编译处理平台差异！**