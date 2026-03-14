# Minesweeper File Management Scheme

## 1. Overview
The file management system handles all data persistence for the Minesweeper game, including scores, configurations, saved games, and logs.

## 2. Directory Structure

```
%APPDATA%\Minesweeper\
├── data\
│   ├── scores.dat       # High scores and best times
│   └── config.properties # User preferences
├── games\
│   ├── save_001.dat     # Auto-saved game states
│   ├── save_002.dat
│   └── ...
├── logs\
│   └── game.log         # Game event logs
└── backup\              # Backup files
    └── ...
```

## 3. File Formats

### 3.1 scores.dat (Binary Format)
- Header: "MSCR" (4 bytes)
- Version: int (4 bytes)
- Entry Count: int (4 bytes)
- Entries: difficulty, name[32], time, date

### 3.2 config.properties (Text Format)
```
difficulty=Easy
tile_size=16
sound_enabled=true
first_click_safe=true
auto_reveal=true
```

### 3.3 save_*.dat (Binary Format)
- Header: "MSAV" (4 bytes)
- Timestamp, Difficulty, Game State, Grid Data

### 3.4 game.log (Text Format)
- Timestamped event logs

## 4. FileManager Functions

| Function | Description |
|----------|-------------|
| init() | Create directory structure |
| read_scores() | Load top scores |
| write_scores() | Save high scores |
| read_config() | Load preferences |
| write_config() | Save preferences |
| save_game() | Save game state |
| load_game() | Load game state |
| log_event() | Write log entry |

## 5. Error Handling

| Code | Meaning |
|------|---------|
| 0 | Success |
| -1 | File not found |
| -2 | Permission denied |
| -3 | Corrupted data |
