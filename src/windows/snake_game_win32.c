// Windows窗体版本贪吃蛇游戏 - Win32 API
// 使用纯Win32 API，无外部依赖

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

// ==================== 游戏常量 ====================

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600
#define GRID_SIZE 20
#define GRID_WIDTH 30
#define GRID_HEIGHT 20
#define CELL_SIZE (GRID_SIZE)
#define MAX_SNAKE_LENGTH 100
#define INITIAL_SNAKE_LENGTH 3
#define GAME_SPEED 150

// 颜色定义 (RGB)
#define SNAKE_HEAD_COLOR RGB(46, 204, 113)
#define SNAKE_BODY_COLOR RGB(39, 174, 96)
#define FOOD_COLOR RGB(231, 76, 60)
#define BACKGROUND_COLOR RGB(52, 73, 94)
#define GRID_COLOR RGB(44, 62, 80)
#define TEXT_COLOR RGB(236, 240, 241)
#define UI_BACKGROUND RGB(41, 128, 185)

// ==================== 数据结构 ====================

typedef enum {
    DIR_UP,
    DIR_DOWN,
    DIR_LEFT,
    DIR_RIGHT
} Direction;

typedef struct {
    int x;
    int y;
} Position;

typedef struct {
    Position body[MAX_SNAKE_LENGTH];
    int length;
    Direction direction;
} Snake;

typedef struct {
    Snake snake;
    Position food;
    int score;
    bool game_over;
    bool paused;
    int level;
    int speed;
} GameState;

// ==================== 全局变量 ====================

static GameState game;
static HWND hwnd;
static HDC hdc;
static PAINTSTRUCT ps;
static RECT clientRect;
static HFONT hFont;
static HFONT hBigFont;
static bool running = true;

// ==================== 游戏逻辑函数 ====================

void init_game() {
    // 初始化蛇
    game.snake.length = INITIAL_SNAKE_LENGTH;
    game.snake.direction = DIR_RIGHT;
    
    // 蛇的初始位置
    for (int i = 0; i < game.snake.length; i++) {
        game.snake.body[i].x = 5 + i;
        game.snake.body[i].y = GRID_HEIGHT / 2;
    }
    
    // 生成食物
    srand((unsigned int)time(NULL));
    game.food.x = rand() % GRID_WIDTH;
    game.food.y = rand() % GRID_HEIGHT;
    
    // 初始化游戏状态
    game.score = 0;
    game.game_over = false;
    game.paused = false;
    game.level = 1;
    game.speed = GAME_SPEED;
}

void generate_food() {
    bool valid_position = false;
    int attempts = 0;
    const int MAX_ATTEMPTS = 100;
    
    while (!valid_position && attempts < MAX_ATTEMPTS) {
        game.food.x = rand() % GRID_WIDTH;
        game.food.y = rand() % GRID_HEIGHT;
        
        // 检查食物是否与蛇身重叠
        valid_position = true;
        for (int i = 0; i < game.snake.length; i++) {
            if (game.snake.body[i].x == game.food.x &&
                game.snake.body[i].y == game.food.y) {
                valid_position = false;
                break;
            }
        }
        
        attempts++;
    }
}

void update_game() {
    if (game.game_over || game.paused) {
        return;
    }
    
    // 移动蛇
    Position new_head = game.snake.body[0];
    
    switch (game.snake.direction) {
        case DIR_UP: new_head.y--; break;
        case DIR_DOWN: new_head.y++; break;
        case DIR_LEFT: new_head.x--; break;
        case DIR_RIGHT: new_head.x++; break;
    }
    
    // 检查边界碰撞
    if (new_head.x < 0 || new_head.x >= GRID_WIDTH ||
        new_head.y < 0 || new_head.y >= GRID_HEIGHT) {
        game.game_over = true;
        return;
    }
    
    // 检查自身碰撞
    for (int i = 0; i < game.snake.length; i++) {
        if (game.snake.body[i].x == new_head.x &&
            game.snake.body[i].y == new_head.y) {
            game.game_over = true;
            return;
        }
    }
    
    // 移动蛇身
    for (int i = game.snake.length - 1; i > 0; i--) {
        game.snake.body[i] = game.snake.body[i - 1];
    }
    game.snake.body[0] = new_head;
    
    // 检查是否吃到食物
    if (new_head.x == game.food.x && new_head.y == game.food.y) {
        // 增加蛇长
        if (game.snake.length < MAX_SNAKE_LENGTH) {
            game.snake.length++;
        }
        
        // 生成新食物
        generate_food();
        
        // 增加分数
        game.score += 10;
        
        // 每100分升一级，加快速度
        if (game.score % 100 == 0) {
            game.level++;
            game.speed = game.speed > 50 ? game.speed - 20 : 50;
        }
    }
}

void handle_input(WPARAM wParam) {
    switch (wParam) {
        // 方向键和WASD
        case 'W':
        case 'w':
        case VK_UP:
            if (game.snake.direction != DIR_DOWN) {
                game.snake.direction = DIR_UP;
            }
            break;
            
        case 'S':
        case 's':
        case VK_DOWN:
            if (game.snake.direction != DIR_UP) {
                game.snake.direction = DIR_DOWN;
            }
            break;
            
        case 'A':
        case 'a':
        case VK_LEFT:
            if (game.snake.direction != DIR_RIGHT) {
                game.snake.direction = DIR_LEFT;
            }
            break;
            
        case 'D':
        case 'd':
        case VK_RIGHT:
            if (game.snake.direction != DIR_LEFT) {
                game.snake.direction = DIR_RIGHT;
            }
            break;
            
        // 空格键 - 暂停/继续
        case VK_SPACE:
            game.paused = !game.paused;
            break;
            
        // R键 - 重新开始
        case 'R':
        case 'r':
            if (game.game_over) {
                init_game();
            }
            break;
            
        // ESC键 - 退出游戏
        case VK_ESCAPE:
            running = false;
            PostMessage(hwnd, WM_CLOSE, 0, 0);
            break;
    }
}

// ==================== 绘图函数 ====================

void draw_grid(HDC hdc, int offsetX, int offsetY) {
    HPEN hGridPen = CreatePen(PS_SOLID, 1, GRID_COLOR);
    HPEN hOldPen = (HPEN)SelectObject(hdc, hGridPen);
    
    // 绘制垂直线
    for (int x = 0; x <= GRID_WIDTH; x++) {
        MoveToEx(hdc, offsetX + x * CELL_SIZE, offsetY, NULL);
        LineTo(hdc, offsetX + x * CELL_SIZE, offsetY + GRID_HEIGHT * CELL_SIZE);
    }
    
    // 绘制水平线
    for (int y = 0; y <= GRID_HEIGHT; y++) {
        MoveToEx(hdc, offsetX, offsetY + y * CELL_SIZE, NULL);
        LineTo(hdc, offsetX + GRID_WIDTH * CELL_SIZE, offsetY + y * CELL_SIZE);
    }
    
    SelectObject(hdc, hOldPen);
    DeleteObject(hGridPen);
}

void draw_snake(HDC hdc, int offsetX, int offsetY) {
    // 绘制蛇身
    HBRUSH hBodyBrush = CreateSolidBrush(SNAKE_BODY_COLOR);
    HBRUSH hOldBrush = (HBRUSH)SelectObject(hdc, hBodyBrush);
    
    for (int i = 1; i < game.snake.length; i++) {
        int x = offsetX + game.snake.body[i].x * CELL_SIZE;
        int y = offsetY + game.snake.body[i].y * CELL_SIZE;
        Rectangle(hdc, x, y, x + CELL_SIZE, y + CELL_SIZE);
    }
    
    SelectObject(hdc, hOldBrush);
    DeleteObject(hBodyBrush);
    
    // 绘制蛇头
    HBRUSH hHeadBrush = CreateSolidBrush(SNAKE_HEAD_COLOR);
    hOldBrush = (HBRUSH)SelectObject(hdc, hHeadBrush);
    
    int headX = offsetX + game.snake.body[0].x * CELL_SIZE;
    int headY = offsetY + game.snake.body[0].y * CELL_SIZE;
    Rectangle(hdc, headX, headY, headX + CELL_SIZE, headY + CELL_SIZE);
    
    SelectObject(hdc, hOldBrush);
    DeleteObject(hHeadBrush);
}

void draw_food(HDC hdc, int offsetX, int offsetY) {
    HBRUSH hFoodBrush = CreateSolidBrush(FOOD_COLOR);
    HBRUSH hOldBrush = (HBRUSH)SelectObject(hdc, hFoodBrush);
    
    int foodX = offsetX + game.food.x * CELL_SIZE;
    int foodY = offsetY + game.food.y * CELL_SIZE;
    
    // 绘制圆形食物
    Ellipse(hdc, foodX, foodY, foodX + CELL_SIZE, foodY + CELL_SIZE);
    
    SelectObject(hdc, hOldBrush);
    DeleteObject(hFoodBrush);
}

void draw_ui(HDC hdc) {
    // 设置文本颜色
    SetTextColor(hdc, TEXT_COLOR);
    SetBkMode(hdc, TRANSPARENT);
    
    // 绘制游戏区域背景
    HBRUSH hGameBgBrush = CreateSolidBrush(BACKGROUND_COLOR);
    RECT gameRect = {50, 50, 50 + GRID_WIDTH * CELL_SIZE, 50 + GRID_HEIGHT * CELL_SIZE};
    FillRect(hdc, &gameRect, hGameBgBrush);
    DeleteObject(hGameBgBrush);
    
    // 绘制游戏区域边框
    HPEN hBorderPen = CreatePen(PS_SOLID, 2, TEXT_COLOR);
    HPEN hOldPen = (HPEN)SelectObject(hdc, hBorderPen);
    SelectObject(hdc, GetStockObject(NULL_BRUSH));
    Rectangle(hdc, gameRect.left, gameRect.top, gameRect.right, gameRect.bottom);
    SelectObject(hdc, hOldPen);
    DeleteObject(hBorderPen);
    
    // 绘制网格
    draw_grid(hdc, 50, 50);
    
    // 绘制蛇和食物
    draw_snake(hdc, 50, 50);
    draw_food(hdc, 50, 50);
    
    // 绘制UI面板背景
    HBRUSH hUIBgBrush = CreateSolidBrush(UI_BACKGROUND);
    RECT uiRect = {50, gameRect.bottom + 20, gameRect.right, gameRect.bottom + 150};
    FillRect(hdc, &uiRect, hUIBgBrush);
    DeleteObject(hUIBgBrush);
    
    // 绘制UI面板边框
    hBorderPen = CreatePen(PS_SOLID, 2, TEXT_COLOR);
    hOldPen = (HPEN)SelectObject(hdc, hBorderPen);
    SelectObject(hdc, GetStockObject(NULL_BRUSH));
    Rectangle(hdc, uiRect.left, uiRect.top, uiRect.right, uiRect.bottom);
    SelectObject(hdc, hOldPen);
    DeleteObject(hBorderPen);
    
    // 绘制游戏信息
    char buffer[256];
    int yPos = uiRect.top + 20;
    
    // 使用大字体显示分数
    SelectObject(hdc, hBigFont);
    sprintf(buffer, "分数: %d", game.score);
    TextOut(hdc, uiRect.left + 20, yPos, buffer, (int)strlen(buffer));
    yPos += 40;
    
    // 使用普通字体显示其他信息
    SelectObject(hdc, hFont);
    sprintf(buffer, "等级: %d", game.level);
    TextOut(hdc, uiRect.left + 20, yPos, buffer, (int)strlen(buffer));
    
    sprintf(buffer, "长度: %d", game.snake.length);
    TextOut(hdc, uiRect.left + 150, yPos, buffer, (int)strlen(buffer));
    yPos += 30;
    
    sprintf(buffer, "速度: %d ms", game.speed);
    TextOut(hdc, uiRect.left + 20, yPos, buffer, (int)strlen(buffer));
    
    // 绘制游戏状态
    if (game.game_over) {
        SelectObject(hdc, hBigFont);
        TextOut(hdc, gameRect.left + 50, gameRect.top + 100, "游戏结束!", 12);
        SelectObject(hdc, hFont);
        TextOut(hdc, gameRect.left + 30, gameRect.top + 150, "按 R 键重新开始", 22);
    } else if (game.paused) {
        SelectObject(hdc, hBigFont);
        TextOut(hdc, gameRect.left + 80, gameRect.top + 100, "暂停", 6);
        SelectObject(hdc, hFont);
        TextOut(hdc, gameRect.left + 30, gameRect.top + 150, "按空格键继续", 18);
    }
    
    // 绘制控制说明
    yPos = uiRect.top + 90;
    TextOut(hdc, uiRect.left + 20, yPos, "控制:", 6);
    yPos += 25;
    TextOut(hdc, uiRect.left + 20, yPos, "W/A/S/D 或方向键: 移动", 28);
    yPos += 25;
    TextOut(hdc, uiRect.left + 20, yPos, "空格键: 暂停/继续", 22);
    yPos += 25;
    TextOut(hdc, uiRect.left + 20, yPos, "R键: 重新开始", 18);
    yPos += 25;
    TextOut(hdc, uiRect.left + 20, yPos, "ESC键: 退出游戏", 20);
}

// ==================== 窗口过程 ====================

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_CREATE:
            // 创建字体
            hFont = CreateFont(20, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                              DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                              DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Microsoft YaHei");
            
            hBigFont = CreateFont(32, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                                 DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                                 DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Microsoft YaHei");
            
            // 初始化游戏
            init_game();
            
            // 设置定时器
            SetTimer(hwnd, 1, game.speed, NULL);
            return 0;
            
        case WM_PAINT:
            hdc = BeginPaint(hwnd, &ps);
            GetClientRect(hwnd, &clientRect);
            
            // 绘制窗口背景
            HBRUSH hBgBrush = CreateSolidBrush(RGB(30, 30, 30));
            FillRect(hdc, &clientRect, hBgBrush);
            DeleteObject(hBgBrush);
            
            // 绘制游戏界面
            draw_ui(hdc);
            
            EndPaint(hwnd, &ps);
            return 0;
            
        case WM_KEYDOWN:
            handle_input(wParam);
            InvalidateRect(hwnd, NULL, TRUE);
            return 0;
            
        case WM_TIMER:
            if (!game.paused && !game.game_over) {
                update_game();
                InvalidateRect(hwnd, NULL, TRUE);
            }
            return 0;
            
        case WM_DESTROY:
            // 清理资源
            if (hFont) DeleteObject(hFont);
            if (hBigFont) DeleteObject(hBigFont);
            KillTimer(hwnd, 1);
            PostQuitMessage(0);
            return 0;
    }
    
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

// ==================== 主函数 ====================

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, 
                   LPSTR lpCmdLine, int nCmdShow) {
    // 注册窗口类
    const char CLASS_NAME[] = "SnakeGameWindow";
    
    WNDCLASS wc = {0};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    
    RegisterClass(&wc);
    
    // 创建窗口
    hwnd = CreateWindowEx(
        0,
        CLASS_NAME,
        "Zen-C 贪吃蛇游戏 - Windows窗体版",
        WS_OVERLAPPEDWINDOW & ~WS_THICKFRAME & ~WS_MAXIMIZEBOX,
        CW_USEDEFAULT, CW_USEDEFAULT, WINDOW_WIDTH, WINDOW_HEIGHT,
        NULL, NULL, hInstance, NULL
    );
    
    if (hwnd == NULL) {
        return 0;
    }
    
    // 显示窗口
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);
    
    // 消息循环
    MSG msg = {0};
    while (running && GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    
    return (int)msg.wParam;
}