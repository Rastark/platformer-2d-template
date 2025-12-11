# Platformer 2D Template

A simple 2D platformer template for Level Design students. Build your own levels without writing code!

---

## Quick Start (5 Steps)

1. **Open Level 1**: Go to `scenes/levels/level_1.tscn`
2. **Build platforms**: Select `TerrainTileMapLayer` and paint tiles
3. **Place enemies**: Drag `slime_enemy_character.tscn` or `ladybug_enemy_character.tscn` from `scenes/enemy_characters/`
4. **Place coins**: Drag coin scenes from `scenes/collectibles/coins/`
5. **Press F5** to test your level!

---

## What Each Scene Does

| Scene | Location | Purpose |
|-------|----------|---------|
| **level_1.tscn** | `scenes/levels/` | The main level - this is where you design! |
| **player_character.tscn** | `scenes/player_character/` | The player (already placed in level) |
| **slime_enemy_character.tscn** | `scenes/enemy_characters/` | Enemy that pushes you back |
| **ladybug_enemy_character.tscn** | `scenes/enemy_characters/` | Enemy that hurts AND pushes you |
| **bronze/silver/gold_coin_collectible.tscn** | `scenes/collectibles/coins/` | Coins worth 1, 5, or 10 points |

---

## Values You Can Change (Inspector)

### Player Character
| Property | What It Does | Safe Range |
|----------|--------------|------------|
| `knockback_strength` | How hard enemies push you | 100-1000 |
| `knockback_duration` | How long the push lasts | 0.1-1.0 seconds |

### Enemy Character
| Property | What It Does | Safe Range |
|----------|--------------|------------|
| `speed` | How fast the enemy moves | 50-300 |
| `direction` | Starting direction (-1=left, 1=right) | -1 or 1 |
| `hurts_player` | Does touching this enemy hurt you? | ON/OFF |
| `pushes_player` | Does touching this enemy push you? | ON/OFF |
| `push_strength` | How hard this enemy pushes | 0.5-3.0 |

### Collectible (Coins)
| Property | What It Does | Safe Range |
|----------|--------------|------------|
| `score_value` | Points awarded when collected | 1-100 |

---

## How to Create Your Level

### Adding Platforms
1. Select `TerrainTileMapLayer` in the Scene tree
2. Use the TileMap editor at the bottom of the screen
3. Click tiles in the palette, then paint in the viewport

### Adding Enemies
1. Open the FileSystem panel
2. Navigate to `scenes/enemy_characters/`
3. Drag an enemy scene into your level
4. Position it on a platform
5. (Optional) Select it and adjust `speed` in the Inspector

### Adding Coins
1. Navigate to `scenes/collectibles/coins/`
2. Drag a coin scene into your level
3. Position it where players can reach it

### Setting the Start Position
1. Find `PlayerSpawnMarker` in the Scene tree
2. Move it to where you want the player to spawn

### Setting the Goal
1. Find `Goal` in the Scene tree
2. Move it to where you want the level to end
3. When the player reaches the goal, the win screen appears!

---

## Enemy Types

| Enemy | Behavior | Use For |
|-------|----------|---------|
| **Slime** | Pushes only (no damage) | Obstacles, bouncy hazards |
| **Ladybug** | Hurts + Pushes | Dangerous enemies |

You can create your own variants by duplicating an enemy scene and changing its properties!

---

## Tips for Level Design

- **Test often**: Press F5 to play your level
- **Vary enemy placement**: Mix slimes and ladybugs
- **Create flow**: Guide players with coin trails
- **Use height**: Platforms at different levels add interest
- **Place the goal**: Make sure players can reach the finish!

---

## Project Structure

```
platformer-2d-template/
├── assets/              # Images and sounds (don't edit)
│   ├── audio/           # Sound effects
│   └── sprites/         # Character and tile sprites
├── data/                # Animation data (don't edit)
│   ├── custom_resources/# Enemy variant resources
│   └── sprite_frames/   # Animation frame definitions
├── scenes/              # Game objects - WORK HERE!
│   ├── collectibles/    # Coins and items
│   ├── enemy_characters/# Enemy types
│   ├── levels/          # Your levels!
│   └── player_character/# The player
└── scripts/             # Code (don't edit)
```

---

## Controls

| Key | Action |
|-----|--------|
| **Arrow Keys** or **WASD** | Move left/right |
| **Space** or **W** or **Up** | Jump |

---

## How the Game Works

1. **Start**: Player spawns at `PlayerSpawnMarker`
2. **Play**: Collect coins, avoid/overcome enemies
3. **Win**: Reach the goal flag to see your final score
4. **Lose**: Fall into hazards or get hurt by enemies = restart

---

## Need Help?

- **Game won't start?** Make sure `level_1.tscn` is set as the main scene
- **Player falls through floor?** Check that platforms are on the `Terrain` layer
- **Enemies don't move?** They need to be placed on platforms
- **Coins don't work?** Make sure they're in the `Collectibles` group
