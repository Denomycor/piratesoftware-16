# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Tooling

Use the **Godot MCP** server to interact with the running Godot editor — inspect nodes, run scenes, query resources, and read editor state. Prefer MCP over guessing scene structure from file contents alone.

## Running the Game

Open the project in Godot 4.6 and press **F5** (or use the MCP to launch). The main scene is `assets/scenes/game.tscn`.  
There are no build steps, test runners, or CI pipelines — all iteration is through the Godot editor.

## Before Every Commit

**Always run the GDScript LSP checker before committing any `.gd` file changes:**

```powershell
node .claude/gdscript-check.mjs . --timeout 20
```

- Requires the Godot editor to be open (LSP runs on port 6005 automatically).
- Exit code 0 = clean. Exit code 1 = errors present — **do not commit**.
- Do NOT use `godot --headless --quit` as a parse check — it only loads autoloads and the main scene, missing most scripts entirely.

## Architecture

**Autoloads (singletons)**
- `LevelContext` (`assets/scripts/level/level_context.gd`) — holds a reference to the active `Level`. Used everywhere as `LevelContext.level`.
- `GameOptions` (`assets/scripts/game_options.gd`) — persistent audio/display settings.

**Scene flow**
`Game` (root) → shows `main_menu` → on play, instantiates `Level` → on game over/quit, destroys level and returns to menu.

**Level** (`assets/scripts/level/level.gd`) owns:
- `Car` — the player, a `RigidBody2D`. Movement is entirely driven by weapon knockback: weapons emit `fired(impulse: Vector2)`, and `Car.apply_knockback()` translates that into torque + lateral/longitudinal impulses.
- `Arena` — procedurally builds an octagonal arena of wall tiles and scattered props. Use `Arena.get_random_free_point_inside_polygon(border)` for safe spawn positions.
- `Stats` — tracks points, kills, speed, drift duration; writes to `Overlay` each physics frame.
- `Overlay` / `WeaponBar` / `Speedometer` — HUD nodes.

**Weapons**
Abstract base: `Weapon` (`assets/scripts/weapons/abstract/weapon.gd`). Signals: `fired`, `activated`, `deactivated`.  
`WeaponDock` manages a list of child `Weapon` nodes; scroll wheel or keys 1–5 switch weapons.  
Each concrete weapon (shotgun, hook, flamethrower, minigun, rocket_launcher, …) lives under `assets/scripts/weapons/`.  
`CarVars` resource controls per-weapon car physics tuning (motor strength, drift friction, torque multiplier).

**Enemies**
Abstract base: `Enemy` (`assets/scripts/enemies/abstract/enemy.gd`) — must implement `attack()`, `update_movement()`, `die()`, and `_take_dmg()`.  
`EnemiesManager` spawns enemies on a timer using difficulty-scaled `Curve` ratios; difficulty ramps from 0→1 over `time_for_max_difficulty` seconds based on `Stats.time_survived`.  
Enemies must be added to the `"enemies"` group for the manager to track them.

**Hit/hurt system**
`HitBoxComponent` → `HurtBoxComponent`. Enemies and the car each have a `HurtBoxComponent`; damage flows through `hurt_box.take_damage(amount)`.

## Physics Layers

| Layer | Name |
|-------|------|
| 1 | terrain |
| 2 | player |
| 3 | enemies |
| 4 | player_projectiles |
| 5 | enemy_projectiles |
| 6 | crawler |

Gravity is disabled globally (`2d/default_gravity=0`).
