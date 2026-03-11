// Linux窗体版本贪吃蛇游戏 - GTK3
// 使用GTK3和Cairo绘图库

#include <gtk/gtk.h>
#include <cairo.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>

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

// 颜色定义 (RGBA)
#define SNAKE_HEAD_COLOR_R 46.0/255.0
#define SNAKE_HEAD_COLOR_G 204.0/255.0
#define SNAKE_HEAD_COLOR_B 113.0/255.0

#define SNAKE_BODY_COLOR_R 39.0/255.0
#define SNAKE_BODY_COLOR_G 174.0/255.0
#define SNAKE_BODY_COLOR_B 96.0/255.0

#define FOOD_COLOR_R 231.0/255.0
#define FOOD_COLOR_G 76.0/255.0
#define FOOD_COLOR_B 60.0/255.0

#define BACKGROUND_COLOR_R 52.0/255.0
#define BACKGROUND_COLOR_G 73.0/255.0
#define BACKGROUND_COLOR_B 94.0/255.0

#define GRID_COLOR_R 44.0/255.0
#define GRID_COLOR_G 62.0/255.0
#define GRID_COLOR_B 80.0/255.0

#define TEXT_COLOR_R 236.0/255.0
#define TEXT_COLOR_G 240.0/255.0
#define TEXT_COLOR_B 241.0/255.0

#define UI_BACKGROUND_R 41.0/255.0
#define UI_BACKGROUND_G 128.0/255.0
#define UI_BACKGROUND_B 185.0/255.0

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
static GtkWidget *window;
static GtkWidget *drawing_area;
static guint timer_id;
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
            
            // 更新定时器
            if (timer_id > 0) {
                g_source_remove(timer_id);
                timer_id = g_timeout_add(game.speed, (GSourceFunc)update_game_callback, NULL);
            }
        }
    }
}

gboolean update_game_callback(gpointer data) {
    update_game();
    gtk_widget_queue_draw(drawing_area);
    return TRUE;
}

void handle_input(guint keyval) {
    switch (keyval) {
        // 方向键和WASD
        case GDK_KEY_w:
        case GDK_KEY_W:
        case GDK_KEY_Up:
            if (game.snake.direction != DIR_DOWN) {
                game.snake.direction = DIR_UP;
            }
            break;
            
        case GDK_KEY_s:
        case GDK_KEY_S:
        case GDK_KEY_Down:
            if (game.snake.direction != DIR_UP) {
                game.snake.direction = DIR_DOWN;
            }
            break;
            
        case GDK_KEY_a:
        case GDK_KEY_A:
        case GDK_KEY_Left:
            if (game.snake.direction != DIR_RIGHT) {
                game.snake.direction = DIR_LEFT;
            }
            break;
            
        case GDK_KEY_d:
        case GDK_KEY_D:
        case GDK_KEY_Right:
            if (game.snake.direction != DIR_LEFT) {
                game.snake.direction = DIR_RIGHT;
            }
            break;
            
        // 空格键 - 暂停/继续
        case GDK_KEY_space:
            game.paused = !game.paused;
            break;
            
        // R键 - 重新开始
        case GDK_KEY_r:
        case GDK_KEY_R:
            if (game.game_over) {
                init_game();
            }
            break;
            
        // ESC键 - 退出游戏
        case GDK_KEY_Escape:
            running = false;
            gtk_main_quit();
            break;
    }
}

// ==================== 绘图函数 ====================

void draw_grid(cairo_t *cr, double offsetX, double offsetY) {
    cairo_set_source_rgb(cr, GRID_COLOR_R, GRID_COLOR_G, GRID_COLOR_B);
    cairo_set_line_width(cr, 1.0);
    
    // 绘制垂直线
    for (int x = 0; x <= GRID_WIDTH; x++) {
        cairo_move_to(cr, offsetX + x * CELL_SIZE, offsetY);
        cairo_line_to(cr, offsetX + x * CELL_SIZE, offsetY + GRID_HEIGHT * CELL_SIZE);
    }
    
    // 绘制水平线
    for (int y = 0; y <= GRID_HEIGHT; y++) {
        cairo_move_to(cr, offsetX, offsetY + y * CELL_SIZE);
        cairo_line_to(cr, offsetX + GRID_WIDTH * CELL_SIZE, offsetY + y * CELL_SIZE);
    }
    
    cairo_stroke(cr);
}

void draw_snake(cairo_t *cr, double offsetX, double offsetY) {
    // 绘制蛇身
    cairo_set_source_rgb(cr, SNAKE_BODY_COLOR_R, SNAKE_BODY_COLOR_G, SNAKE_BODY_COLOR_B);
    
    for (int i = 1; i < game.snake.length; i++) {
        double x = offsetX + game.snake.body[i].x * CELL_SIZE;
        double y = offsetY + game.snake.body[i].y * CELL_SIZE;
        cairo_rectangle(cr, x, y, CELL_SIZE, CELL_SIZE);
        cairo_fill(cr);
    }
    
    // 绘制蛇头
    cairo_set_source_rgb(cr, SNAKE_HEAD_COLOR_R, SNAKE_HEAD_COLOR_G, SNAKE_HEAD_COLOR_B);
    
    double headX = offsetX + game.snake.body[0].x * CELL_SIZE;
    double headY = offsetY + game.snake.body[0].y * CELL_SIZE;
    cairo_rectangle(cr, headX, headY, CELL_SIZE, CELL_SIZE);
    cairo_fill(cr);
}

void draw_food(cairo_t *cr, double offsetX, double offsetY) {
    cairo_set_source_rgb(cr, FOOD_COLOR_R, FOOD_COLOR_G, FOOD_COLOR_B);
    
    double foodX = offsetX + game.food.x * CELL_SIZE;
    double foodY = offsetY + game.food.y * CELL_SIZE;
    
    // 绘制圆形食物
    cairo_arc(cr, foodX + CELL_SIZE/2, foodY + CELL_SIZE/2, CELL_SIZE/2, 0, 2 * M_PI);
    cairo_fill(cr);
}

void draw_text(cairo_t *cr, const char *text, double x, double y, double size, bool bold) {
    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                          bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, size);
    cairo_move_to(cr, x, y);
    cairo_show_text(cr, text);
}

void draw_ui(cairo_t *cr, int width, int height) {
    // 设置文本颜色
    cairo_set_source_rgb(cr, TEXT_COLOR_R, TEXT_COLOR_G, TEXT_COLOR_B);
    
    // 绘制游戏区域背景
    double gameX = 50;
    double gameY = 50;
    double gameWidth = GRID_WIDTH * CELL_SIZE;
    double gameHeight = GRID_HEIGHT * CELL_SIZE;
    
    cairo_set_source_rgb(cr, BACKGROUND_COLOR_R, BACKGROUND_COLOR_G, BACKGROUND_COLOR_B);
    cairo_rectangle(cr, gameX, gameY, gameWidth, gameHeight);
    cairo_fill(cr);
    
    // 绘制游戏区域边框
    cairo_set_source_rgb(cr, TEXT_COLOR_R, TEXT_COLOR_G, TEXT_COLOR_B);
    cairo_set_line_width(cr, 2.0);
    cairo_rectangle(cr, gameX, gameY, gameWidth, gameHeight);
    cairo_stroke(cr);
    
    // 绘制网格
    draw_grid(cr, gameX, gameY);
    
    // 绘制蛇和食物
    draw_snake(cr, gameX, gameY);
    draw_food(cr, gameX, gameY);
    
    // 绘制UI面板背景
    double uiX = gameX;
    double uiY = gameY + gameHeight + 20;
    double uiWidth = gameWidth;
    double uiHeight = 150;
    
    cairo_set_source_rgb(cr, UI_BACKGROUND_R, UI_BACKGROUND_G, UI_BACKGROUND_B);
    cairo_rectangle(cr, uiX, uiY, uiWidth, uiHeight);
    cairo_fill(cr);
    
    // 绘制UI面板边框
    cairo_set_source_rgb(cr, TEXT_COLOR_R, TEXT_COLOR_G, TEXT_COLOR_B);
    cairo_set_line_width(cr, 2.0);
    cairo_rectangle(cr, uiX, uiY, uiWidth, uiHeight);
    cairo_stroke(cr);
    
    // 绘制游戏信息
    char buffer[256];
    double textY = uiY + 30;
    
    // 使用大字体显示分数
    sprintf(buffer, "分数: %d", game.score);
    draw_text(cr, buffer, uiX + 20, textY, 24.0, true);
    textY += 40;
    
    // 使用普通字体显示其他信息
    sprintf(buffer, "等级: %d", game.level);
    draw_text(cr, buffer, uiX + 20, textY, 16.0, false);
    
    sprintf(buffer, "长度: %d", game.snake.length);
    draw_text(cr, buffer, uiX + 150, textY, 16.0, false);
    textY += 30;
    
    sprintf(buffer, "速度: %d ms", game.speed);
    draw_text(cr, buffer, uiX + 20, textY, 16.0, false);
    
    // 绘制游戏状态
    if (game.game_over) {
        draw_text(cr, "游戏结束!", gameX + 80, gameY + 120, 32.0, true);
        draw_text(cr, "按 R 键重新开始", gameX + 50, gameY + 170, 16.0, false);
    } else if (game.paused) {
        draw_text(cr, "暂停", gameX + 100, gameY + 120, 32.0, true);
        draw_text(cr, "按空格键继续", gameX + 50, gameY + 170, 16.0, false);
    }
    
    // 绘制控制说明
    textY = uiY + 90;
    draw_text(cr, "控制:", uiX + 20, textY, 16.0, false);
    textY += 25;
    draw_text(cr, "W/A/S/D 或方向键: 移动", uiX + 20, textY, 14.0, false);
    textY += 25;
    draw_text(cr, "空格键: 暂停/继续", uiX + 20, textY, 14.0, false);
    textY += 25;
    draw_text(cr, "R键: 重新开始", uiX + 20, textY, 14.0, false);
    textY += 25;
    draw_text(cr, "ESC键: 退出游戏", uiX + 20, textY, 14.0, false);
}

// ==================== GTK回调函数 ====================

static gboolean on_draw(GtkWidget *widget, cairo_t *cr, gpointer data) {
    // 获取绘图区域大小
    GtkAllocation allocation;
    gtk_widget_get_allocation(widget, &allocation);
    int width = allocation.width;
    int height = allocation.height;
    
    // 绘制黑色背景
    cairo_set_source_rgb(cr, 0.1, 0.1, 0.1);
    cairo_paint(cr);
    
    // 绘制游戏界面
    draw_ui(cr, width, height);
    
    return FALSE;
}

static gboolean on_key_press(GtkWidget *widget, GdkEventKey *event, gpointer data) {
    handle_input(event->keyval);
    gtk_widget_queue_draw(drawing_area);
    return TRUE;
}

static void on_window_destroy(GtkWidget *widget, gpointer data) {
    running = false;
    if (timer_id > 0) {
        g_source_remove(timer_id);
    }
    gtk_main_quit();
}

// ==================== 主函数 ====================

int main(int argc, char *argv[]) {
    // 初始化GTK
    gtk_init(&argc, &argv);
    
    // 初始化游戏
    init_game();
    
    // 创建窗口
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Zen-C 贪吃蛇游戏 - Linux窗体版");
    gtk_window_set_default_size(GTK_WINDOW(window), WINDOW_WIDTH, WINDOW_HEIGHT);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
    gtk_window_set_resizable(GTK_WINDOW(window), FALSE);
    
    // 创建绘图区域
    drawing_area = gtk_drawing_area_new();
    gtk_container_add(GTK_CONTAINER(window), drawing_area);
    
    // 连接信号
    g_signal_connect(window, "destroy", G_CALLBACK(on_window_destroy), NULL);
    g_signal_connect(drawing_area, "draw", G_CALLBACK(on_draw), NULL);
    g_signal_connect(window, "key-press-event", G_CALLBACK(on_key_press), NULL);
    
    // 设置定时器
    timer_id = g_timeout_add(game.speed, (GSourceFunc)update_game_callback, NULL);
    
    // 显示所有部件
    gtk_widget_show_all(window);
    
    // 开始主循环
    gtk_main();
    
    return 0;
}