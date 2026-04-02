# Tetris Game

A classic Tetris game implemented using Godot 4.6 engine.

## Features

- Classic Tetris gameplay mechanics
- Keyboard controls
- Gamepad support
- Score system with level progression
- Save/load functionality
- Pause menu
- Game over screen
- High score tracking
- Abandon run confirmation dialog
- Improved collision detection
- Smooth rotation mechanics

## Technical Stack

- Godot 4.6
- GDScript
- 2D graphics

## Play Online

You can play the game directly in your browser at: [https://zml9167.github.io/tetris/Tetris.html](https://zml9167.github.io/tetris/Tetris.html)

## Installation

1. Download and install [Godot 4.6](https://godotengine.org/download)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/tetris.git
   ```
3. Open project in Godot by selecting `project.godot` file
4. Press play button to start game

## Controls

### Keyboard
- **Left Arrow/A**: Move left
- **Right Arrow/D**: Move right
- **Down Arrow/S**: Move down (soft drop)
- **Up Arrow/W/E**: Rotate clockwise
- **Q**: Rotate counterclockwise
- **Escape**: Pause game

### Gamepad
- **D-pad Left/Right**: Move left/right
- **D-pad Down**: Move down
- **A Button**: Rotate clockwise
- **B Button**: Rotate counterclockwise
- **Start Button**: Pause game

## Game Mechanics

- Blocks fall from the top of the screen
- Complete lines to score points
- The game speeds up as you level up
- The game ends when blocks reach the top of the screen
- Rotation is blocked when it would cause blocks to go below the bottom boundary
- Fast drop can be activated by holding the down arrow

## Project Structure

```
tetris/
├── assets/          # Game assets
│   └── block.png    # Block sprite
├── prefab/          # Tetromino prefabs
│   ├── prefab0.tres
│   ├── prefab1.tres
│   └── ...
├── scene/           # Game scenes
│   ├── block/       # Block component
│   ├── global/      # Global game state
│   ├── main/        # Main game scene
│   ├── pause_menu/  # Pause menu
│   └── title/       # Title screen
├── script/          # Game scripts
│   ├── controller.gd  # Block controller
│   ├── prefab.gd      # Tetromino prefab
│   └── save_data.gd   # Save data management
├── project.godot    # Project configuration
└── README.md        # This file
```

## How to Play

1. Press any key on title screen to start a new game
2. Use controls to move and rotate the falling blocks
3. Try to complete horizontal lines to score points
4. The game gets faster as your score increases
5. Press Escape to pause the game
6. The game ends when blocks stack up to the top

## Saving and Loading

- The game automatically saves your progress when you pause
- You can continue your game from the title screen
- You can abandon your current run from the title screen (with confirmation)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
