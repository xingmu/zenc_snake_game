# 窗体版本贪吃蛇游戏 - 架构设计

## 🎯 设计目标

1. **美观的窗体界面** - 告别控制台
2. **跨平台支持** - Windows/Linux/macOS
3. **代码复用** - 共用核心游戏逻辑
4. **易于维护** - 清晰的架构分离

## 📁 项目结构

```
src/
├── core/                    # 核心游戏逻辑 (共用)
│   ├── game_logic.zc       # 游戏状态、移动、碰撞检测
│   ├── game_state.zc       # 数据结构定义
│   └── game_constants.zc   # 游戏常量
├── windows/                # Windows窗体版本
│   ├── main_win32.zc       # Win32主程序
│   ├── window_ui.zc        # 窗体界面
│   └── graphics_win32.zc   # GDI绘图
├── linux/                  # Linux窗体版本
│   ├── main_gtk.zc         # GTK主程序
│   ├── window_ui.zc        # 窗体界面
│   └── graphics_gtk.zc     # GTK绘图
├── macos/                  # macOS窗体版本
│   ├── main_cocoa.zc       # Cocoa主程序
│   ├── window_ui.zc        # 窗体界面
│   └── graphics_cocoa.zc   # Cocoa绘图
└── common/                 # 平台无关代码
    ├── input_handler.zc    # 输入处理
    ├── timer.zc            # 游戏计时器
    └── utils.zc            # 工具函数

build/
├── build_windows.bat       # Windows构建脚本
├── build_linux.sh          # Linux构建脚本
└── build_macos.sh          # macOS构建脚本
```

## 🔧 技术选型

### Windows版本
- **框架**: Win32 API (原生Windows)
- **图形**: GDI (Graphics Device Interface)
- **优势**: 原生Windows体验，无依赖
- **文件**: `main_win32.zc`

### Linux版本
- **框架**: GTK3 (GIMP Toolkit)
- **图形**: Cairo绘图库
- **优势**: 现代Linux桌面集成
- **文件**: `main_gtk.zc`

### macOS版本
- **框架**: Cocoa (原生macOS)
- **图形**: Core Graphics
- **优势**: 原生macOS体验
- **文件**: `main_cocoa.zc`

## 🎮 核心游戏逻辑 (共用)

### 数据结构
```zc
struct GameState {
    snake: Snake,
    food: Position,
    score: i32,
    game_over: bool,
    paused: bool,
    window_width: i32,
    window_height: i32
}

struct Snake {
    body: [MAX_LENGTH]Position,
    length: i32,
    direction: Direction,
    color: Color
}

struct Position {
    x: i32,
    y: i32
}

enum Direction {
    Up,
    Down,
    Left,
    Right
}

struct Color {
    r: u8,
    g: u8,
    b: u8
}
```

### 核心函数
```zc
// 游戏初始化
fn init_game(game: &mut GameState)

// 更新游戏状态
fn update_game(game: &mut GameState)

// 处理输入
fn handle_input(game: &mut GameState, key: KeyCode)

// 检查碰撞
fn check_collision(game: &GameState) -> bool

// 生成食物
fn generate_food(game: &mut GameState)
```

## 🖼️ 窗体界面设计

### 窗口布局
```
+-----------------------------------+
|  Zen-C Snake Game                |
+-----------------------------------+
|                                   |
|  +-----------------------------+  |
|  |                             |  |
|  |        游戏区域              |  |
|  |                             |  |
|  +-----------------------------+  |
|                                   |
|  分数: 100     等级: 3           |
|  长度: 15      速度: 中等        |
|                                   |
|  [暂停] [重新开始] [退出]        |
+-----------------------------------+
```

### 视觉元素
1. **蛇**: 渐变颜色，圆角矩形
2. **食物**: 苹果图标，动画效果
3. **背景**: 网格或渐变背景
4. **UI控件**: 现代扁平化设计
5. **分数显示**: 大字体，醒目位置

## 🔄 游戏循环

```
初始化游戏
创建窗体
加载资源

主循环:
  处理窗口消息
  处理用户输入
  更新游戏状态
  绘制游戏画面
  控制帧率(60FPS)

游戏结束:
  显示最终分数
  提供重新开始选项
```

## 📦 依赖管理

### Windows
- 无外部依赖 (Win32 API是Windows SDK的一部分)

### Linux
```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-dev

# Fedora
sudo dnf install gtk3-devel
```

### macOS
- 无外部依赖 (Cocoa是macOS SDK的一部分)

## 🚀 构建系统

每个平台有独立的构建脚本：

### Windows构建脚本 (`build_windows.bat`)
```batch
@echo off
echo Building Windows Windowed Snake Game...
zc build src/windows/main_win32.zc -o build/snake_game_win32.exe
echo Build complete!
```

### Linux构建脚本 (`build_linux.sh`)
```bash
#!/bin/bash
echo "Building Linux Windowed Snake Game..."
zc build src/linux/main_gtk.zc -o build/snake_game_linux \
    -lgtk-3 -lgdk-3 -lpangocairo-1.0 -lpango-1.0 -lharfbuzz -latk-1.0 \
    -lcairo-gobject -lcairo -lgdk_pixbuf-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0
echo "Build complete!"
```

### macOS构建脚本 (`build_macos.sh`)
```bash
#!/bin/bash
echo "Building macOS Windowed Snake Game..."
zc build src/macos/main_cocoa.zc -o build/snake_game_macos \
    -framework Cocoa -framework CoreGraphics
echo "Build complete!"
```

## 🎨 视觉设计规范

### 颜色方案
```zc
// 蛇的颜色 (渐变)
const SNAKE_HEAD_COLOR = Color { r: 46, g: 204, b: 113 }  // 绿色
const SNAKE_BODY_COLOR = Color { r: 39, g: 174, b: 96 }   // 深绿色

// 食物颜色
const FOOD_COLOR = Color { r: 231, g: 76, b: 60 }         // 红色

// 背景颜色
const BACKGROUND_COLOR = Color { r: 52, g: 73, b: 94 }    // 深蓝色
const GRID_COLOR = Color { r: 44, g: 62, b: 80 }          // 网格颜色

// UI颜色
const UI_BACKGROUND = Color { r: 41, g: 128, b: 185 }     // 蓝色
const UI_TEXT_COLOR = Color { r: 236, g: 240, b: 241 }    // 白色
```

### 动画效果
1. **蛇移动**: 平滑过渡动画
2. **食物出现**: 缩放动画
3. **分数变化**: 数字滚动效果
4. **游戏结束**: 淡入淡出效果

## 📱 响应式设计

### 窗口大小适应
- 游戏区域自动缩放
- UI元素重新布局
- 字体大小调整

### 键盘快捷键
```
方向键/WASD: 控制蛇移动
空格键: 暂停/继续
R键: 重新开始
ESC键: 退出游戏
P键: 暂停游戏
```

## 🔧 开发计划

### 第一阶段: 核心游戏逻辑
1. 创建共用游戏逻辑模块
2. 实现数据结构
3. 编写单元测试

### 第二阶段: Windows版本
1. 实现Win32窗体
2. 集成GDI绘图
3. 添加输入处理

### 第三阶段: Linux版本
1. 实现GTK窗体
2. 集成Cairo绘图
3. 添加Linux特定功能

### 第四阶段: macOS版本
1. 实现Cocoa窗体
2. 集成Core Graphics
3. 添加macOS特定功能

### 第五阶段: 优化和测试
1. 性能优化
2. 跨平台测试
3. 用户界面美化

## 📊 性能目标

- **帧率**: 稳定60FPS
- **内存使用**: < 50MB
- **启动时间**: < 2秒
- **输入延迟**: < 50ms

## 🎯 用户体验目标

1. **直观操作**: 无需教程即可上手
2. **流畅动画**: 无卡顿的视觉体验
3. **美观界面**: 现代扁平化设计
4. **跨平台一致性**: 各平台体验相似

## 🔒 安全考虑

1. **输入验证**: 防止缓冲区溢出
2. **资源管理**: 正确释放内存和资源
3. **错误处理**: 优雅处理异常情况
4. **权限控制**: 最小权限原则

---

这个架构设计实现了你的要求：
1. ✅ **窗体界面** - 告别控制台
2. ✅ **三个版本** - Windows/Linux/macOS
3. ✅ **共用代码** - 核心游戏逻辑复用
4. ✅ **易于维护** - 清晰的架构分离

现在开始实现！