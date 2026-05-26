# Project State

Last updated: 2026-05-26

---

## Current Milestone: 2 — Performance Foundation

---

## Milestone Status

| # | Name | Status | Notes |
|---|------|--------|-------|
| 1 | Migration & Stabilization | ✅ Done | See details below |
| 2 | Performance Foundation | ✅ Done | See details below |
| 3 | Enemy Spawn System Fixes | ⬜ Not Started | |
| 4 | Grappling Hook Completion | ⬜ Not Started | |
| 5 | Meta Progression Foundation | ⬜ Not Started | |
| 6 | Boost System Expansion | ⬜ Not Started | |
| 7 | Game Flow Polish | ⬜ Not Started | |

---

## Milestone 1 — Migration & Stabilization

**Status: ✅ Done (code fixes applied; manual validation pending)**

### What was done
- Confirmed project opened in Godot 4.6 (`project.godot` already has `config/features=["4.6", "Forward Plus"]`)
- Full API scan: no deprecated Godot 3 patterns found (no `yield`, no old `connect(obj, "method")`, no `rand_range`, no `KinematicBody2D`, etc.)
- Renderer confirmed: **Forward Plus**

### Bugs fixed
| File | Bug | Fix |
|------|-----|-----|
| `assets/scripts/enemies/giant.gd:21` | `charge_timer` referenced `$attack_timer` instead of `$charge_timer` — Giant charge cooldown was broken | Changed to `$charge_timer` |
| `assets/scripts/props/barrel.gd:21` | `_on_take_damage(amount: int)` — silent float→int truncation of incoming damage | Changed to `float` |
| `CLAUDE.md` | Said "Godot 4.3" | Updated to "Godot 4.6" (staged, needs manual `git commit`) |

### Manual validation needed (by you, in the editor)
- [ ] Game launches without errors (check Output panel for nulls / parse errors)
- [ ] Full loop: main menu → tutorial → run → death → return to menu
- [ ] All 5 weapons fire and produce knockback
- [ ] All 5 enemy types spawn and behave (Giant, Biker, Crawler, ExplodingCrawler, Gunhead)
- [ ] Hook attaches to enemies
- [ ] HUD (health, points, kills, speed) updates correctly
- [ ] No shader stutter on first run
- [ ] Audio works (music, engine, weapons)

---

## Milestone 2 — Performance Foundation

**Status: ✅ Done (manual validation pending)**

### What was done
- **LoadingScreen** — new scene at `assets/scenes/ui/loading_screen.tscn`
  - Uses `ResourceLoader.load_threaded_request` for async loading
  - Progress bar fills 0→85% during level load, 85→100% during shader warmup
  - Shader warmup: creates a hidden SubViewport, renders one instance of each
    ShaderMaterial for 2 frames, forcing GPU compilation before gameplay
  - Shaders warmed: `test_level`, `scrolling_texture`, `sonar`, `vignette`, `circle`
- **`game.gd`** — `switch_main_menu_to_level()` now routes through loading screen
  instead of direct `preload()` instantiation
- **`enemies-manager.gd`** — replaced `get_nodes_in_group("enemies")` (new Array
  allocation every physics frame) with an `_enemies` cache maintained via
  `tree_exiting` signal. High-impact at 100+ enemies.

### What was NOT done (scope deferred)
- Object pooling for enemies — deferred to Milestone 3
- Distance-based tick rate tuning — the existing `num_groups` round-robin in
  `EnemiesManager` already provides this; left as-is until benchmarks show need
- GPU particles audit — needs profiling with game running (manual task)

### Manual validation needed
- [ ] Loading screen appears when clicking Play (after tutorial)
- [ ] Progress bar advances and reaches 100%
- [ ] No shader stutter during first gameplay session after loading screen
- [ ] Enemy count stable at 100+ (use `num_groups` to tune if needed)

---

## Known Issues / Tech Debt

| Issue | File | Priority |
|-------|------|----------|
| `EnemiesManager._position_near_target()` has no retry limit — can infinite loop if arena has no valid spawn point | `enemies-manager.gd:51-62` | M3 |
| Hook can't attach to walls, barrels, or boosts — only enemies | `hook_projectile.gd` | M4 |
| No victory condition (15-min survival) | `level.gd` | M7 |
| No XP/save system | — | M5 |
| No boost system beyond health pack | `props/repair.gd` | M6 |

---

## Architecture Reference

| System | Script | Notes |
|--------|--------|-------|
| Game root | `game.gd` | Flow: menu → loading → level → menu |
| Level | `level/level.gd` | Owns Car, Arena, Stats, Overlay |
| LevelContext | `level/level_context.gd` | Autoload singleton |
| GameOptions | `game_options.gd` | Autoload singleton |
| EnemiesManager | `enemies/manager/enemies-manager.gd` | Difficulty curves; cached enemy list |
| Arena | `arena/arena.gd` | Octagonal; `can_place()` for spawn validation |
| Car | `car/car.gd` | RigidBody2D; recoil-driven |
| LoadingScreen | `ui/loading_screen.gd` | CanvasLayer; async + shader warmup |
