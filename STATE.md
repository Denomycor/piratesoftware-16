# Project State

Last updated: 2026-05-26

---

## Current Milestone: 8 — QA / Performance Validation

---

## Milestone Status

| # | Name | Status | Notes |
|---|------|--------|-------|
| 1 | Migration & Stabilization | ✅ Done | See details below |
| 2 | Performance Foundation | ✅ Done | See details below |
| 3 | Enemy Spawn System Fixes | ✅ Done | See details below |
| 4 | Grappling Hook Completion | ✅ Done | See details below |
| 5 | Meta Progression Foundation | ✅ Done | See details below |
| 6 | Boost System Expansion | ✅ Done | See details below |
| 7 | Game Flow Polish | ✅ Done | See details below |

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
| `CLAUDE.md` | Said "Godot 4.3" | Updated to "Godot 4.6" |
| `assets/scripts/utils/polygon_random_point_generator.gd:9` | `_ready()` with only `@warning_ignore` as body — parse error in 4.6, cascaded to break `arena.gd` → `level.gd` → `level_context.gd` | Removed dead `_ready()`, moved annotation to correct position in `_init()` |
| `assets/scenes/game.tscn:7` | Loading screen ext_resource used invented placeholder UID `uid://cls3x8p7q2mn4e` instead of Godot-assigned `uid://cixkgltprk5x3` | Updated to match real UID |
| `C:\Users\vsousa\AppData\Roaming\Godot\editor_settings-4.6.tres:421` | `run/window_placement/screen = 1` — game window placed on non-existent second monitor, causing 4× `p_screen out of bounds` errors on every F5 run | Set to `screen = 0` |

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

## Milestone 3 — Enemy Spawn System Fixes

**Status: ✅ Done (manual validation pending)**

### What was done

All changes in `assets/scripts/enemies/manager/enemies-manager.gd`:

- **Retry limit + fallback**: `_position_near_target()` now caps at `MAX_SPAWN_RETRIES = 30` iterations.  
  On exhaustion, falls back to `_fallback_spawn_position()` which calls `arena.get_random_free_point_inside_polygon(BLOCK_RADIUS)` and runs up to 5 additional tries to ensure the result is at least `MIN_PLAYER_DISTANCE = 3000` units from the player and off-screen.
- **Spawn visibility check**: New `_is_in_viewport(pos)` helper computes the camera's world-space viewport rect (`viewport_size / camera.zoom` centred on `camera.get_screen_center_position()`) and returns `true` if `pos` is inside it.  
  Both `_position_near_target()` and the fallback reject visible positions, so enemies never pop in on-screen.  
  Camera path: `LevelContext.level.get_node_or_null("World/Car/BoomArm/Camera2D")`.
- **Difficulty time scale**: `time_for_max_difficulty` changed from `60 * 5` (5 min) → `60 * 15` (15 min), matching the intended 15-minute survival loop.
- **Spawn rate scaling**: `_spawn_enemy()` sets `spawn_timer.wait_time = lerpf(0.2, 0.1, difficulty)` on each timeout.  
  At difficulty 0 the interval is 0.2 s (unchanged); at difficulty 1 it halves to 0.1 s.  
  The new value takes effect on the next timer cycle.

### What was NOT done (scope deferred)
- Object pooling for enemies — still deferred to a later pass
- Arena spawn regions (sub-zone biases) — not needed yet
- Nav-validity checks beyond `can_place()` — overkill until navmesh is added

### Manual validation needed
- [ ] No enemies visibly pop in on screen (watch first 30 s of a run)
- [ ] Game does not hang/freeze in early game (no infinite spawn loop)
- [ ] Difficulty ramp feels ~15 minutes to max (check at 5, 10, 15 min marks)
- [ ] Enemy density increases smoothly over first few minutes

---

## Milestone 4 — Grappling Hook Completion

**Status: ✅ Done (manual validation pending)**

### What was done

All changes in `assets/scripts/projectiles/hook_projectile.gd` and `assets/scenes/projectiles/hook_projectile.tscn`.

**Wall attachment**
- `target is StaticBody2D` → in `_physics_process`, `car.apply_central_force()` pulls the Car toward the anchor point on the wall each frame.  
  Force: `WALL_PULL_FORCE = 6000.0` N (tunable constant). Walls never move.

**Barrel drag**
- Barrel scene root (`barrel1/2/3.tscn`) is a `RigidBody2D` with class `Barrel`.  
  `target is Barrel` → in `_physics_process`, `barrel.rigid_body.apply_central_force()` drags the barrel toward the Car.  
  Force: `BARREL_PULL_FORCE = 4000.0` N. Barrel is released (hook destroys) when it arrives within `BARREL_ARRIVAL_DISTANCE = 250 px`. Barrel's explosion behavior is unchanged.

**Repair/boost retrieval**
- `Repair` is an `Area2D` — `move_and_collide()` can't detect it.  
  A runtime `Area2D` sensor (`_pickup_sensor`, `collision_mask=1`, `radius=80`) is created lazily on the first `_process` frame (not in `_ready()` — see bug notes below). Each `_process` frame while flying, `get_overlapping_areas()` is polled (more reliable than `area_entered` signals at high speed). On match, `connect_hook(area, area.global_position)` is called.  
  In `connect_hook`, the Repair's HitBoxComponent monitoring is disabled (prevents double-heal).  
  In `_physics_process`, `target.global_position` is moved toward the Car at `REPAIR_PULL_SPEED = 2000 px/s`. When within `REPAIR_ARRIVAL_DISTANCE = 250 px`, the Car is healed directly (`car.hurt_box.take_damage(-350.0)`) and the Repair's `_on_collision(0.0)` is triggered for VFX, then the hook destroys.

**Enemy hook (preserved + cleaned up)**
- Existing logic retained verbatim. No regressions.

**`connect_hook()` additions**
- Disables `_pickup_sensor.monitoring` once attached (prevent duplicate grabs).
- `scale_tween` null guard added (`if scale_tween != null:` before `.kill()`).
- All `target` / `anchor` access uses `is_instance_valid()` throughout.

### Bugs fixed during M4 (3 additional commits after initial implementation)

| Commit | Bug | Fix |
|--------|-----|-----|
| `b3c48ec` | Initial implementation overrode `_ready()` with `super._ready()`, conflicting with `LinearProjectile._ready()` (which sets up `timer` / `scale_tween`). This destabilised class_name registration. | Removed `_ready()` override entirely; moved `_pickup_sensor` creation to lazy init at top of `_process()`. |
| `1a3ab87` | `if target:` / `if not target:` — in Godot 4, freed Objects are still non-null, so bare truthiness checks allowed accessing `anchor.global_position` on a freed node → crash. Also, `hook_projectile.tscn` script ext_resource had no `uid=` attribute. | Replaced all with `is_instance_valid(target)` / `is_instance_valid(anchor)`. Added `uid="uid://xqg4l0dpca8"` to `.tscn` script reference. |
| `2f980d9` | **Root cause of the persistent crash**: `get_overlapping_areas()` returns `Array[Area2D]`, so the loop variable was statically typed `Area2D`. GDScript 4.6's type-narrowing checker rejected `if area is Repair` (Repair extends `CollisionObject2D`, not `Area2D` — neither is a subtype of the other). This **parse error** prevented the script from loading at all, causing `instantiate()` to return a bare `CharacterBody2D` and triggering the "type 'hook_projectile.gd'" crash in `hook.gd:33`. | Widened loop variable: `var col: CollisionObject2D = area` — both `Area2D` and `Repair` share `CollisionObject2D` as an ancestor, so the narrowing `col is Repair` is valid and the parse error disappears. |

### What was NOT done (scope deferred)
- Hook state machine enum (idle/fired/attached/etc.) — implicit states via `frozen`/`target` flags are sufficient. Formal enum would be a refactor with no behavior change; deferred.
- Cooldown mechanic — not specified in roadmap requirements.
- Wall type filtering (not all StaticBody2D are walls) — only walls exist in the arena as StaticBody2D, so no filter needed yet.

### Force tuning notes
All forces are named constants at the top of `hook_projectile.gd`:  
`WALL_PULL_FORCE`, `BARREL_PULL_FORCE`, `BARREL_ARRIVAL_DISTANCE`, `REPAIR_PULL_SPEED`, `REPAIR_ARRIVAL_DISTANCE`.  
Tune in-editor; no architecture changes needed.

### Manual validation needed
- [ ] Hook fires and attaches to a wall → Car is pulled toward it
- [ ] Hook fires and attaches to a barrel → barrel slides toward Car, hook releases on arrival
- [ ] Hook fires and attaches to a Repair item → Repair travels to Car, Car is healed, item disappears
- [ ] Enemy pull still works as before
- [ ] Right-click releases hook in all attach scenarios
- [ ] No physics explosions or jitter when pulling

---

## Milestone 5 — Meta Progression Foundation

**Status: ✅ Done (manual validation pending)**

### What was done

**New autoloads (registered in `project.godot`)**

| Autoload | Script | Role |
|----------|--------|------|
| `SaveManager` | `managers/save_manager.gd` | JSON persistence at `user://save_data.json`. Handles load, save, migration (version field). Exposes typed getters/setters for alien XP, car XP, levels, skill points, unlocked nodes. |
| `ProgressionManager` | `managers/progression_manager.gd` | XP math, leveling, skill unlock logic, skill node registry. `award_run_xp(kills, time_survived)` awards XP, recomputes levels, grants skill points, saves. |

**XP formula (unbalanced by design — tune in a later pass)**
- Alien XP = `kills × 10`
- Car XP = `floor(time_survived / 10) × 5`

**Level curve:** advancing from level N to N+1 costs `(N+1) × 100` XP.

**SkillNode Resource** (`resources/skill_node.gd`)
- Fields: `id`, `display_name`, `description`, `track` (ALIEN/CAR), `prerequisites`, `cost`, `effect_key`, `effect_value`
- Instances created programmatically in `ProgressionManager._register_skill_nodes()`
- Gameplay effects (`effect_key`/`effect_value`) are **not applied during M5** — structure only

**8 placeholder skill nodes defined:**

| Track | ID | Name | Effect key |
|-------|----|------|-----------|
| Alien | `alien_sharp_claws` | Sharp Claws | `weapon_damage_multiplier` 1.1 |
| Alien | `alien_battle_hardened` | Battle Hardened | `max_hp_bonus` 20 |
| Alien | `alien_quick_reload` | Quick Reload (req: Sharp Claws) | `cooldown_multiplier` 0.9 |
| Alien | `alien_hunters_eye` | Hunter's Eye (req: Battle Hardened) | `range_multiplier` 1.15 |
| Car | `car_tuned_engine` | Tuned Engine | `speed_multiplier` 1.1 |
| Car | `car_reinforced_frame` | Reinforced Frame | `car_max_hp_bonus` 25 |
| Car | `car_slick_tires` | Slick Tires (req: Tuned Engine) | `drift_multiplier` 1.1 |
| Car | `car_nitro_boost` | Nitro Boost (req: Reinforced Frame) | `knockback_multiplier` 1.05 |

**ProgressionScreen** (`ui/progression_screen.gd`)
- `VBoxContainer` embedded as tab 3 in `MainMenu`'s TabContainer
- All UI built programmatically in `_ready()` — no complex `.tscn` needed
- Inner `TabContainer` with Alien / Car tabs
- Each tab: Level label, XP progress (`current / needed`), skill points available, scrollable list of skill rows
- Skill rows show name, description, prerequisites, cost, Unlock button (disabled if locked/already unlocked/insufficient points)
- `refresh()` called whenever the tab becomes visible

**Main menu integration**
- Added "Progression" button to main menu tab 0 (between Credits and Quit)
- Tab 3 in `MainMenu` TabContainer = ProgressionScreen
- Back button returns to tab 0

**Game-over XP display**
- `GameOverMenu.set_stats()` now calls `ProgressionManager.award_run_xp(kills, time_survived)`
- Adds "Alien XP: +N XP (Lv.X)" and "Car XP: +N XP (Lv.X)" rows below existing stats
- Level-up is highlighted with "▲ LEVEL UP → X" suffix if applicable

### What was NOT done (scope deferred)
- Gameplay effects from skill nodes (reading `effect_key`/`effect_value`) — M6/M7 scope
- Respec system — explicitly out of scope per roadmap
- XP balancing — roadmap explicitly says don't balance yet

### Manual validation needed
- [ ] SaveManager loads/saves without errors (check Output panel on first run)
- [ ] Game-over screen shows "Alien XP:" and "Car XP:" rows after a run
- [ ] XP persists between sessions (kill enemies, die, restart — XP should accumulate)
- [ ] Main menu → Progression button opens skill tree screen
- [ ] Both Alien and Car tabs display Level, XP, Skill Points
- [ ] After earning enough XP to level up, skill points appear (available_pts > 0)
- [ ] Clicking Unlock (when points available) decrements points and marks skill as ✓ Unlocked
- [ ] Prerequisite skills are shown as "Locked" until prerequisite is unlocked
- [ ] Back button returns to main menu

---

## Milestone 6 — Boost System Expansion

**Status: ✅ Done (manual validation pending)**

### What was done

**New autoload**

| Autoload | Script | Role |
|----------|--------|------|
| `BoostManager` | `managers/boost_manager.gd` | Tracks active timed boosts; ticks duration; deactivates on expiry; manages aura Area2D; exposes `points_multiplier`. |

**Generic Boost Framework**

- `BoostPickup` (`boosts/abstract/boost_pickup.gd`) — base `Area2D` class
  - `collision_layer = 1` → hook pickup sensor detects it
  - `collision_mask = 2` → car body triggers `body_entered` auto-collect
  - `expire_time` timer: pickup self-destructs if not collected
  - `disable_auto_collect()` / `deliver_to_car()` — hook retrieval interface
  - Virtual `activate(car)` / `deactivate(car)` / `get_boost_id()` for subclasses
  - On collect: removes visual/collision children; node stays alive for effect lifecycle

**Three new boost types**

| Class | File | Effect | Duration | Color |
|-------|------|--------|----------|-------|
| `TwoPointsBoost` | `boosts/two_points_boost.gd` | `BoostManager.points_multiplier = 2.0` | 10 s | Gold |
| `ImmunityBoost` | `boosts/immunity_boost.gd` | `car.hurt_box.monitoring = false` | 8 s | Cyan |
| `AuraBoost` | `boosts/aura_boost.gd` | Area2D on car damages enemies at 20 DPS, r=400 | 12 s | Purple |

**Aura collision mask = 36** (layer 3 enemies=4, layer 6 crawlers=32)

**Drop system**

- `EnemiesManager._try_drop_boost(pos)` — 5% chance per enemy death, random boost type
- Connected via `enemy_instance.died` signal in `_spawn_enemy()`
- Uses `GDScript.new()` directly (no PackedScene required)
- Dropped boosts are children of EnemiesManager

**Hook retrieval extended**
- `hook_projectile.gd` now detects `BoostPickup` alongside `Repair` in the pickup sensor loop
- Tow logic mirrors Repair: move toward car, `deliver_to_car()` on arrival
- `connect_hook()` calls `disable_auto_collect()` to freeze expire timer during flight

**Points multiplier wired**
- `Stats.add_points()` multiplies `amount` by `BoostManager.points_multiplier`
- Applies to both time-based score and kill-based points

**HUD boost timer strip**
- `Overlay` builds a `VBoxContainer` programmatically at top-center
- `add_boost_display(id, name, color, duration)` / `update_boost_timer(...)` / `remove_boost_display(id)` — called by BoostManager each frame
- Each active boost shows `"Name  X.Xs"` in its boost color with dark outline

### What was NOT done (scope deferred)
- Boost VFX (pickup animation, aura visual on car) — M7/polish pass
- Audio feedback for pickup — no suitable sound file available; add when SFX acquired
- Boost balancing — same as skills: intentionally deferred

### Manual validation needed
- [ ] Kill enemies until a boost drops — pickup appears at death position
- [ ] Walk car over boost → HUD strip shows timer row in correct color
- [ ] Timer counts down and row disappears when expired
- [ ] 2x Points: score gains double while active (watch Points label)
- [ ] Immunity: car takes no damage from enemies/walls while active
- [ ] Aura Damage: enemies near car take damage over time while active
- [ ] Multiple boosts simultaneously display multiple rows
- [ ] Collecting same boost type while active resets (extends) duration
- [ ] Hook grabs a boost, tows it to car, activates on delivery
- [ ] On level exit and restart: no stale boost effects carry over

---

## Milestone 7 — Game Flow Polish

**Status: ✅ Done (manual validation pending)**

### What was done

**Victory condition**
- `Stats` — added `const VICTORY_TIME: float = 900.0` (15 minutes) and `var _victory_triggered: bool`.
  In `_physics_process`, once `time_survived >= VICTORY_TIME` (and not already triggered), sets
  `is_game_over = true` and calls `LevelContext.level.set_victory()` — stopping the stats ticker
  and showing the victory screen in the same frame.

**VictoryMenu** (`ui/victory_menu.gd` + `scenes/ui/victory_menu.tscn`)
- Identical structure to `GameOverMenu` — same `set_stats()` signature, same unique-name nodes
  (`%Points`, `%TimeSurvived`, `%Kills`, `%MaxSpeed`, `%MaxDriftDuration`, `%AlienXPLabel`, `%CarXPLabel`, `%quit`)
- Title label: **"Victory!"** in green (`Color(0.2, 0.8, 0.2, 1)`)
- `process_mode = 3` (PROCESS_MODE_ALWAYS) so it renders while tree is paused
- `set_stats()` calls `ProgressionManager.award_run_xp()` — same as game-over path (mutually exclusive, no double-award)
- Quit button text: "Return to Menu"

**`Level.set_victory()`**
- Pauses tree, sets `stats.is_game_over = true`, queue_frees `pause_menu`, then calls
  `victory_menu.set_stats(...)` + `victory_menu.show_victory_menu()`
- `VictoryMenu` is wired in `_ready()`: `victory_menu.quit_level.connect(quit_level)`

**Skill effects applied at level start** (`ProgressionManager.apply_skills_to_car(car)`)
Called from `Level._ready()` after `LevelContext.level = self`.

| Effect key | Target | Applied how |
|------------|--------|-------------|
| `car_max_hp_bonus` / `max_hp_bonus` | `car.max_health` | `+= value`; `car.health = car.max_health` |
| `speed_multiplier` | `weapon_vars[i].motor_strength` | `*= value` on all SubResources |
| `drift_multiplier` | `weapon_vars[i].drift_friction_strength` | `*= value` on all SubResources |
| `knockback_multiplier` | `weapon_vars[i].perpendicular_multiplier` + `.parallel_multiplier` | `*= value` on all SubResources |
| `cooldown_multiplier` | `ProjectileSpawnerComponent.fire_delay` | `*= value` on each weapon in WeaponList |

Multipliers applied to `weapon_vars` SubResources (not directly to `car.motor_strength`) so they
survive weapon switching. `set_car_vars(weapon_vars[current_idx])` re-applied immediately after.

### What was NOT done (scope deferred to M8 polish)
- `weapon_damage_multiplier` — would require per-projectile spawn-time injection (modifying every
  weapon lambda or adding a flag to `LinearProjectile`). Too architectural for M7.
- `range_multiplier` — same reason (affects `LinearProjectile.lifetime` at instantiation time).

### Manual validation needed
- [ ] Survive for ~15 minutes (or temporarily lower `VICTORY_TIME` in stats.gd) → VictoryMenu appears
- [ ] VictoryMenu shows same stats as GameOverMenu (Points, Time, Kills, XP rows)
- [ ] "Return to Menu" button returns to main menu correctly
- [ ] Death path (car reaches 0 HP) → GameOverMenu still shows (victory path doesn't interfere)
- [ ] Both paths award XP and persist it correctly (no double-award on repeated runs)
- [ ] Unlocked skills affect car stats: HP bonus visible in health bar, motor strength affects top speed

---

## Known Issues / Tech Debt

| Issue | File | Priority |
|-------|------|----------|
| `weapon_damage_multiplier` skill not applied | `progression_manager.gd` | M8 polish |
| `range_multiplier` skill not applied | `progression_manager.gd` | M8 polish |
| Boost pickup has no animation/VFX | `boost_pickup.gd` | Polish |
| No boost pickup audio | `boost_pickup.gd` | Polish |

---

## Architecture Reference

| System | Script | Notes |
|--------|--------|-------|
| Game root | `game.gd` | Flow: menu → loading → level → menu |
| Level | `level/level.gd` | Owns Car, Arena, Stats, Overlay; `set_game_over()` + `set_victory()` |
| LevelContext | `level/level_context.gd` | Autoload singleton |
| GameOptions | `game_options.gd` | Autoload singleton |
| SaveManager | `managers/save_manager.gd` | Autoload singleton; JSON save at `user://save_data.json` |
| ProgressionManager | `managers/progression_manager.gd` | Autoload singleton; XP math + skill definitions + `apply_skills_to_car()` |
| BoostManager | `managers/boost_manager.gd` | Autoload singleton; active boost tracking + aura area; `points_multiplier` |
| EnemiesManager | `enemies/manager/enemies-manager.gd` | Difficulty curves; cached enemy list; 5% boost drops |
| Arena | `arena/arena.gd` | Octagonal; `can_place()` for spawn validation |
| Car | `car/car.gd` | RigidBody2D; recoil-driven |
| LoadingScreen | `ui/loading_screen.gd` | CanvasLayer; async + shader warmup |
| HookProjectile | `projectiles/hook_projectile.gd` | Attaches to wall/barrel/repair/enemy/boost; lazy Area2D sensor for pickup detection |
| ProgressionScreen | `ui/progression_screen.gd` | VBoxContainer; tab 3 of MainMenu; skill tree UI |
| VictoryMenu | `ui/victory_menu.gd` | CanvasLayer; shown on 15-min survival; same XP award as GameOverMenu |
