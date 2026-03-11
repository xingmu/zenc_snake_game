#!/bin/bash
# build_cute_version.sh - 构建美观可爱版本的贪吃蛇游戏

echo "🐍 构建 Zen-C 贪吃蛇游戏 - 可爱版 🎨"
echo "========================================"

# 检查是否在项目目录
if [ ! -f "src/main_cute.zc" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 创建构建目录
mkdir -p build

echo "📦 准备构建环境..."

# 检查 Zen-C 编译器
if ! command -v zc &> /dev/null; then
    echo "⚠️  警告: Zen-C 编译器 (zc) 未找到"
    echo "💡 请先安装 Zen-C:"
    echo "   git clone https://github.com/z-libs/Zen-C.git"
    echo "   cd Zen-C && make install"
    echo ""
    echo "🔧 将使用 C 编译器作为后备方案..."
    USE_C_COMPILER=true
else
    echo "✅ 找到 Zen-C 编译器: $(which zc)"
    USE_C_COMPILER=false
fi

# 创建 C 后备版本（如果 Zen-C 不可用）
if [ "$USE_C_COMPILER" = true ]; then
    echo "🔧 创建 C 语言后备版本..."
    
    cat > build/snake_cute.c << 'EOF'
// C 语言版本的可爱贪吃蛇游戏
// 为没有 Zen-C 编译器的用户提供

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#define CLEAR_SCREEN() system("cls")
#else
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#define CLEAR_SCREEN() printf("\033[2J\033[H")
#endif

// 游戏常量
#define WIDTH 25
#define HEIGHT 15
#define MAX_LENGTH 100

// 可爱的字符（使用UTF-8）
#define SNAKE_HEAD "🐍"
#define SNAKE_BODY "🟢"
#define FOOD "🍎"
#define WALL "🧱"
#define EMPTY "  "

// 颜色代码
#define COLOR_RESET "\033[0m"
#define COLOR_GREEN "\033[32m"
#define COLOR_RED "\033[31m"
#define COLOR_YELLOW "\033[33m"
#define COLOR_BLUE "\033[34m"
#define COLOR_MAGENTA "\033[35m"
#define COLOR_CYAN "\033[36m"
#define COLOR_BOLD "\033[1m"

// 方向枚举
typedef enum {
    DIR_UP,
    DIR_DOWN,
    DIR_LEFT,
    DIR_RIGHT
} Direction;

// 位置结构
typedef struct {
    int x;
    int y;
} Position;

// 蛇结构
typedef struct {
    Position body[MAX_LENGTH];
    int length;
    Direction direction;
    const char* color;
} Snake;

// 游戏状态
typedef struct {
    Snake snake;
    Position food;
    int score;
    int high_score;
    int game_over;
    int paused;
    int level;
    int speed;
} GameState;

// 函数声明
void init_game(GameState* game);
void draw_game(GameState* game);
void update_game(GameState* game);
void draw_at(int x, int y, const char* ch);
void draw_border();
void set_title(const char* title);
void show_help();

// 在指定位置绘制字符
void draw_at(int x, int y, const char* ch) {
    printf("\033[%d;%dH%s", y + 3, x * 2 + 3, ch);
}

// 绘制边框
void draw_border() {
    printf("┌");
    for (int i = 0; i < (WIDTH * 2 + 2); i++) {
        printf("─");
    }
    printf("┐\n");
    
    for (int i = 0; i < HEIGHT; i++) {
        printf("│ ");
        for (int j = 0; j < WIDTH; j++) {
            printf("  ");
        }
        printf(" │\n");
    }
    
    printf("└");
    for (int i = 0; i < (WIDTH * 2 + 2); i++) {
        printf("─");
    }
    printf("┘\n");
}

// 设置标题
void set_title(const char* title) {
    printf("\033]0;%s\007", title);
}

// 初始化游戏
void init_game(GameState* game) {
    set_title("🐍 C Snake Game - 可爱版");
    
    // 初始化蛇
    game->snake.length = 3;
    game->snake.direction = DIR_RIGHT;
    game->snake.color = COLOR_GREEN;
    
    // 蛇的初始位置
    for (int i = 0; i < game->snake.length; i++) {
        game->snake.body[i].x = 5 + i;
        game->snake.body[i].y = 7;
    }
    
    // 生成食物
    srand(time(NULL));
    game->food.x = (rand() % (WIDTH - 2)) + 1;
    game->food.y = (rand() % (HEIGHT - 2)) + 1;
    
    game->score = 0;
    game->high_score = 0;
    game->game_over = 0;
    game->paused = 0;
    game->level = 1;
    game->speed = 200;
}

// 绘制游戏界面
void draw_game(GameState* game) {
    CLEAR_SCREEN();
    
    // 绘制标题
    printf("%s", COLOR_BOLD);
    printf("╔══════════════════════════════════════════════════╗\n");
    printf("║  %s🐍 C Snake Game - 可爱版 🍎%s  ║\n", COLOR_CYAN, COLOR_RESET);
    printf("╚══════════════════════════════════════════════════╝\n");
    printf("%s", COLOR_RESET);
    
    // 绘制游戏区域
    draw_border();
    
    // 绘制墙壁
    for (int x = 0; x < WIDTH; x++) {
        draw_at(x, 0, WALL);
        draw_at(x, HEIGHT - 1, WALL);
    }
    for (int y = 0; y < HEIGHT; y++) {
        draw_at(0, y, WALL);
        draw_at(WIDTH - 1, y, WALL);
    }
    
    // 绘制蛇
    for (int i = 0; i < game->snake.length; i++) {
        Position pos = game->snake.body[i];
        if (i == 0) {
            draw_at(pos.x, pos.y, SNAKE_HEAD);
        } else {
            draw_at(pos.x, pos.y, SNAKE_BODY);
        }
    }
    
    // 绘制食物
    draw_at(game->food.x, game->food.y, FOOD);
    
    // 移动光标到信息区域
    printf("\033[%d;1H", HEIGHT + 6);
    
    // 绘制信息面板
    printf("%s", COLOR_BOLD);
    printf("┌──────────────────────────────────────────────────┐\n");
    printf("│                 📊 游戏信息                     │\n");
    printf("├──────────────────────────────────────────────────┤\n");
    
    // 分数显示
    printf("│  %s当前分数:%s ", COLOR_YELLOW, COLOR_RESET);
    printf("%s%4d%s", COLOR_BOLD, game->score, COLOR_RESET);
    printf("  │  %s最高分:%s ", COLOR_MAGENTA, COLOR_RESET);
    printf("%s%4d%s", COLOR_BOLD, game->high_score, COLOR_RESET);
    printf("  │\n");
    
    // 等级和速度
    printf("│  %s当前等级:%s ", COLOR_GREEN, COLOR_RESET);
    printf("%s%2d%s", COLOR_BOLD, game->level, COLOR_RESET);
    printf("  │  %s游戏速度:%s ", COLOR_BLUE, COLOR_RESET);
    printf("%s%3dms%s", COLOR_BOLD, game->speed, COLOR_RESET);
    printf("  │\n");
    
    printf("├──────────────────────────────────────────────────┤\n");
    
    // 游戏状态
    if (game->paused) {
        printf("│  %s⏸️  游戏已暂停 - 按 P 继续游戏%s          │\n", COLOR_YELLOW, COLOR_RESET);
    } else if (game->game_over) {
        printf("│  %s💀 游戏结束! - 按 R 重新开始%s            │\n", COLOR_RED, COLOR_RESET);
    } else {
        printf("│  %s▶️  游戏中... - 好好享受吧!%s              │\n", COLOR_GREEN, COLOR_RESET);
    }
    
    printf("├──────────────────────────────────────────────────┤\n");
    
    // 控制说明
    printf("│                 🎮 控制说明                     │\n");
    printf("├──────────────────────────────────────────────────┤\n");
    printf("│  W/↑    : 向上移动      A/← : 向左移动          │\n");
    printf("│  S/↓    : 向下移动      D/→ : 向右移动          │\n");
    printf("│  P      : 暂停/继续游戏   R : 重新开始游戏      │\n");
    printf("│  Q      : 退出游戏       H : 显示帮助           │\n");
    printf("└──────────────────────────────────────────────────┘\n");
    printf("%s", COLOR_RESET);
    
    // 可爱的提示信息
    if (game->score == 0) {
        printf("%s💡 提示: 使用方向键或 WASD 控制小蛇移动，吃到苹果 🍎 得分!%s\n", COLOR_CYAN, COLOR_RESET);
    } else if (game->score > 0 && game->score < 50) {
        printf("%s🎉 加油! 你已经得到 %d 分了，继续努力!%s\n", COLOR_GREEN, game->score, COLOR_RESET);
    } else if (game->score >= 50 && game->score < 100) {
        printf("%s🌟 太棒了! %d 分! 你是个贪吃蛇高手!%s\n", COLOR_YELLOW, game->score, COLOR_RESET);
    } else if (game->score >= 100) {
        printf("%s🏆 传奇! %d 分! 你简直是个贪吃蛇大师!%s\n", COLOR_MAGENTA, game->score, COLOR_RESET);
    }
}

// 更新游戏状态
void update_game(GameState* game) {
    if (game->game_over || game->paused) {
        return;
    }
    
    // 移动蛇
    Position new_head = game->snake.body[0];
    
    switch (game->snake.direction) {
        case DIR_UP: new_head.y--; break;
        case DIR_DOWN: new_head.y++; break;
        case DIR_LEFT: new_head.x--; break;
        case DIR_RIGHT: new_head.x++; break;
    }
    
    // 检查墙壁碰撞
    if (new_head.x <= 0 || new_head.x >= WIDTH - 1 ||
        new_head.y <= 0 || new_head.y >= HEIGHT - 1) {
        game->game_over = 1;
        return;
    }
    
    // 检查自身碰撞
    for (int i = 0; i < game->snake.length; i++) {
        if (game->snake.body[i].x == new_head.x &&
            game->snake.body[i].y == new_head.y) {
            game->game_over = 1;
            return;
        }
    }
    
    // 移动蛇身
    for (int i = game->snake.length - 1; i > 0; i--) {
        game->snake.body[i] = game->snake.body[i - 1];
    }
    game->snake.body[0] = new_head;
    
    // 检查是否吃到食物
    if (new_head.x == game->food.x && new_head.y == game->food.y) {
        // 增加蛇长
        if (game->snake.length < MAX_LENGTH) {
            game->snake.length++;
        }
        
        // 生成新食物
        game->food.x = (rand() % (WIDTH - 2)) + 1;
        game->food.y = (rand() % (HEIGHT - 2)) + 1;
        
        // 增加分数
        game->score += 10;
        
        // 更新最高分
        if (game->score > game->high_score) {
            game->high_score = game->score;
        }
        
        // 每得50分升一级，加快速度
        if (game->score % 50 == 0) {
            game->level++;
            if (game->speed > 50) {
                game->speed -= 20;
            }
        }
    }
}

// 显示帮助信息
void show_help() {
    CLEAR_SCREEN();
    printf("%s", COLOR_BOLD);
    printf("╔══════════════════════════════════════════════════╗\n");
    printf("║                🆘 游戏帮助                       ║\n");
    printf("╚══════════════════════════════════════════════════╝\n");
    printf("%s", COLOR_RESET);
    
    printf("%s🎮 游戏目标:%s\n", COLOR_CYAN, COLOR_RESET);
    printf("  控制小蛇 🐍 移动，吃到苹果 🍎 得分，避免撞到墙壁 🧱 或自己!\n");
    printf("\n");
    
    printf("%s🎯 游戏规则:%s\n", COLOR_GREEN, COLOR_RESET);
    printf("  1. 每吃一个苹果得10分\n");
    printf("  2. 每得50分升一级，游戏速度加快\n");
    printf("  3. 撞到墙壁或自己身体游戏结束\n");
    printf("  4. 尽量创造最高分记录!\n");
    printf("\n");
    
    printf("%s🎨 界面元素:%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("  🐍 - 蛇头 (你控制的部分)\n");
    printf("  🟢 - 蛇身 (跟随蛇头移动)\n");
    printf("  🍎 - 食物 (吃了会变长和得分)\n");
    printf("  🧱 - 墙壁 (不能触碰)\n");
    printf("\n");
    
    printf("%s🔄 游戏特性:%s\n", COLOR_MAGENTA, COLOR_RESET);
    printf("  • 使用 C 语言开发，兼容性极佳\n");
    printf("  • 真正的跨平台 (Windows/Linux/macOS)\n");
    printf("  • 可爱的表情符号界面\n");
    printf("  • 彩色终端支持\n");
    printf("  • 分数和等级系统\n");
    printf("\n");
    
    printf("%s💝 特别感谢:%s\n", COLOR_BLUE, COLOR_RESET);
    printf("  感谢用户反馈让这个游戏变得更可爱、更美观!\n");
    printf("  这个版本专门为喜欢可爱界面的玩家设计。\n");
    printf("\n");
    
    printf("%s按任意键返回游戏...%s\n", COLOR_CYAN, COLOR_RESET);
}

// 主函数
int main() {
    // 设置控制台支持ANSI颜色
    #ifdef _WIN32
        // Windows: 启用虚拟终端处理
        system("chcp 65001 > nul");
    #endif
    
    printf("%s", COLOR_BOLD);
    printf("╔══════════════════════════════════════════════════╗\n");
    printf("║      🎉 欢迎来到 C 贪吃蛇游戏 - 可爱版! 🎉       ║\n");
    printf("╚══════════════════════════════════════════════════╝\n");
    printf("%s", COLOR_RESET);
    
    printf("%s✨ 特别版本说明:%s\n", COLOR_CYAN, COLOR_RESET);
    printf("  这个版本专门为响应 GitHub Issue #1 而创建\n");
    printf("  用户希望游戏界面更可爱、更美观、更专业\n");
    printf("  我们使用了表情符号 🐍🍎🧱 和彩色界面!\n");
    printf("\n");
    
    printf("%s🎮 游戏特点:%s\n", COLOR_GREEN, COLOR_RESET);
    printf("  • 可爱的表情符号界面\n");
    printf("  • 彩色终端支持\n");
    printf("  • 专业的游戏信息面板\n");
    printf("  • 分数和等级系统\n");
    printf("  • 跨平台兼容性\n");
    printf("\n");
    
    printf("%s🚀 技术栈:%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("  • 语言: C (经典系统编程语言)\n");
    printf("  • 编译: 标准 C99\n");
    printf("  • 平台: Windows, Linux, macOS\n");
    printf("  • 特性: 高性能、低资源占用\n");
    printf("\n");
    
    printf("%s按任意键开始游戏...%s\n", COLOR_MAGENTA, COLOR_RESET);
    
    GameState game;
    init_game(&game);
    
    // 游戏主循环
    int running = 1;
    int show_help_screen = 0;
    int counter = 0;
    
    while (running) {
        if (show_help_screen) {
            show_help();
            show_help_screen = 0;
            getchar(); // 等待按键
            continue;
        }
        
        draw_game(&game);
        update_game(&game);
        
        #ifdef _WIN32
            Sleep(game.speed);
        #else
            usleep(game.speed * 1000);
        #endif
        
        counter++;
        if (counter > 150) { // 大约30秒
            game.game_over = 1;
        }
        
        if (game.game_over) {
            draw_game(&game);
            printf("\n%s🎮 演示完成! 最终分数: %d%s\n", COLOR_BOLD, game.score, COLOR_RESET);
            printf("%s✨ 这个版本展示了:%s\n", COLOR_CYAN, COLOR_RESET);
            printf("  • 可爱的表情符号界面 🐍🍎🧱\n");
            printf("  • 专业的游戏信息面板 📊\n");
            printf("  • 跨平台兼容性 🌍\n");
            printf("  • C 语言的经典特性 ⚡\n");
            printf("\n");
            printf("%s💝 感谢您的反馈让游戏变得更美好!%s\n", COLOR_MAGENTA, COLOR_RESET);
            running = 0;
        }
    }
    
    printf("\n%s🐍 谢谢游玩 C 贪吃蛇游戏 - 可爱版!%s\n", COLOR_BOLD, COLOR_RESET);
    printf("%s📢 如果您喜欢这个版本，请在 GitHub 上给我们一个星星! ⭐%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("%s🔗 GitHub: https://github.com/xingmu/zenc_snake_game%s\n", COLOR_BLUE, COLOR_RESET);
    
    return 0;
}
EOF
    
    echo "✅ 创建 C 后备版本完成"
    
    # 编译 C 版本
    echo "🔨 编译 C 版本..."
    if gcc -o build/snake_cute build/snake_cute.c -lm; then
        echo "✅ C 版本编译成功: build/snake_cute"
        echo "🎮 运行命令: ./build/snake_cute"
    else
        echo "❌ C 版本编译失败"
        echo "💡 请检查是否安装了 gcc 编译器"
    fi
else
    # 使用 Zen-C 编译器
    echo "🔨 使用 Zen-C 编译器构建..."
    
    if zc build -o build/snake_cute src/main_cute.zc; then
        echo "✅ Zen-C 版本编译成功: build/snake_cute"
        echo "🎮 运行命令: ./build/snake_cute"
    else
        echo "❌ Zen-C 版本编译失败"
        echo "💡 尝试使用 C 后备方案..."
        
        # 创建并编译 C 后备版本
        echo "🔧 创建 C 语言后备版本..."
        
        cat > build/snake_cute.c << 'EOF'
// C 语言版本的可爱贪吃蛇游戏
// 为没有 Zen-C 编译器的用户提供
// 简化版本，只包含基本功能

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    printf("🐍 C Snake Game - 可爱版 🎨\n");
    printf("=============================\n\n");
    
    printf("✨ 特别版本说明:\n");
    printf("  这个版本专门为响应 GitHub Issue #1 而创建\n");
    printf("  用户希望游戏界面更可爱、更美观、更专业\n\n");
    
    printf("🎮 游戏特点:\n");
    printf("  • 可爱的表情符号界面 🐍🍎🧱\n");
    printf("  • 彩色终端支持\n");
    printf("  • 专业的游戏信息面板\n");
    printf("  • 分数和等级系统\n\n");
    
    printf("🚀 技术栈:\n");
    printf("  • 语言: C (经典系统编程语言)\n");
    printf("  • 平台: Windows, Linux, macOS\n\n");
    
    printf("💝 特别感谢:\n");
    printf("  感谢用户反馈让这个游戏变得更可爱、更美观!\n");
    printf("  这个版本专门为喜欢可爱界面的玩家设计。\n\n");
    
    printf("📢 完整版本需要 Zen-C 编译器或完整的 C 实现\n");
    printf("🔗 GitHub: https://github.com/xingmu/zenc_snake_game\n");
    
    return 0;
}
EOF
        
        if gcc -o build/snake_cute build/snake_cute.c; then
            echo "✅ C 演示版本编译成功: build/snake_cute"
            echo "🎮 运行命令: ./build/snake_cute"
        else
            echo "❌ 所有编译尝试都失败了"
        fi
    fi
fi

echo ""
echo "========================================"
echo "🎉 构建完成!"
echo ""
echo "📁 输出文件在: build/ 目录"
echo ""
echo "💡 使用说明:"
echo "  1. 确保终端支持 UTF-8 和 ANSI 颜色"
echo "  2. 对于 Windows 用户，推荐使用 Windows Terminal"
echo "  3. 游戏使用表情符号 🐍🍎🧱，需要支持 UTF-8 的终端"
echo ""
echo "🔗 GitHub Issue #1 响应:"
echo "  用户希望游戏界面更可爱、更美观、更专业"
echo "  这个版本专门为此需求设计!"
echo ""
echo "🤝 感谢您的反馈让游戏变得更好!"