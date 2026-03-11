/*
 * Zen-C Snake Game - Windows兼容版本
 * 使用标准库，避免平台特定依赖
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>  // Windows特定头文件

// 游戏常量
#define WIDTH 20
#define HEIGHT 20
#define MAX_LENGTH 100

// 方向枚举
typedef enum {
    UP,
    DOWN,
    LEFT,
    RIGHT
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
} Snake;

// 游戏状态
typedef struct {
    Snake snake;
    Position food;
    int score;
    int game_over;
} GameState;

// 初始化游戏
void init_game(GameState *game) {
    // 初始化蛇
    game->snake.length = 3;
    game->snake.direction = RIGHT;
    
    // 蛇的初始位置（水平线）
    for (int i = 0; i < game->snake.length; i++) {
        game->snake.body[i].x = 5 + i;
        game->snake.body[i].y = 10;
    }
    
    // 生成食物
    srand((unsigned int)time(NULL));
    game->food.x = rand() % (WIDTH - 2) + 1;
    game->food.y = rand() % (HEIGHT - 2) + 1;
    
    game->score = 0;
    game->game_over = 0;
}

// 清屏函数（跨平台）
void clear_screen() {
    #ifdef _WIN32
        system("cls");
    #else
        system("clear");
    #endif
}

// 绘制游戏界面（使用ASCII字符）
void draw_game(const GameState *game) {
    clear_screen();
    
    // 绘制上边框
    printf("+");
    for (int i = 0; i < WIDTH; i++) printf("-");
    printf("+\n");
    
    // 绘制游戏区域
    for (int y = 0; y < HEIGHT; y++) {
        printf("|");
        for (int x = 0; x < WIDTH; x++) {
            int is_snake = 0;
            int is_head = 0;
            
            // 检查是否是蛇身
            for (int i = 0; i < game->snake.length; i++) {
                if (game->snake.body[i].x == x && game->snake.body[i].y == y) {
                    is_snake = 1;
                    if (i == 0) is_head = 1;
                    break;
                }
            }
            
            // 检查是否是食物
            if (game->food.x == x && game->food.y == y) {
                printf("*");  // 食物用*表示
            } else if (is_head) {
                printf("@");  // 蛇头用@表示
            } else if (is_snake) {
                printf("#");  // 蛇身用#表示
            } else {
                printf(" ");
            }
        }
        printf("|\n");
    }
    
    // 绘制下边框
    printf("+");
    for (int i = 0; i < WIDTH; i++) printf("-");
    printf("+\n");
    
    // 显示分数和指令
    printf("Score: %d\n", game->score);
    printf("Controls: W/A/S/D to move, Q to quit, R to restart\n");
    if (game->game_over) {
        printf("\nGAME OVER! Press R to restart\n");
    }
}

// 处理输入（Windows版本）
void process_input(GameState *game) {
    if (_kbhit()) {
        char ch = _getch();
        
        switch (ch) {
            case 'w': case 'W':
                if (game->snake.direction != DOWN)
                    game->snake.direction = UP;
                break;
            case 's': case 'S':
                if (game->snake.direction != UP)
                    game->snake.direction = DOWN;
                break;
            case 'a': case 'A':
                if (game->snake.direction != RIGHT)
                    game->snake.direction = LEFT;
                break;
            case 'd': case 'D':
                if (game->snake.direction != LEFT)
                    game->snake.direction = RIGHT;
                break;
            case 'q': case 'Q':
                game->game_over = 1;
                break;
            case 'r': case 'R':
                if (game->game_over) {
                    init_game(game);
                }
                break;
        }
    }
}

// 更新游戏状态
void update_game(GameState *game) {
    if (game->game_over) return;
    
    // 移动蛇
    Position new_head = game->snake.body[0];
    
    switch (game->snake.direction) {
        case UP:    new_head.y--; break;
        case DOWN:  new_head.y++; break;
        case LEFT:  new_head.x--; break;
        case RIGHT: new_head.x++; break;
    }
    
    // 检查边界碰撞
    if (new_head.x < 0 || new_head.x >= WIDTH ||
        new_head.y < 0 || new_head.y >= HEIGHT) {
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
    for (int i = game->snake.length; i > 0; i--) {
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
        game->food.x = rand() % (WIDTH - 2) + 1;
        game->food.y = rand() % (HEIGHT - 2) + 1;
        
        // 增加分数
        game->score += 10;
    }
}

// 主函数
int main() {
    GameState game;
    
    printf("Zen-C Snake Game - Windows Compatible Version\n");
    printf("Press any key to start...\n");
    _getch();
    
    init_game(&game);
    
    while (!game.game_over) {
        draw_game(&game);
        process_input(&game);
        update_game(&game);
        #ifdef _WIN32
            Sleep(100);  // Windows延迟
        #else
            usleep(100000);  // Unix延迟
        #endif
    }
    
    draw_game(&game);
    printf("\nGame Over! Final Score: %d\n", game.score);
    
    return 0;
}