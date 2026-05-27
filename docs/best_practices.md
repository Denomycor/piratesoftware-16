# GDScript Best Practices

A reference for writing clean, consistent, and maintainable GDScript in Godot 4.

## 1. Static Typing

Always annotate types. Static types catch bugs before running, enable autocompletion, and serve as inline documentation.

```gdscript
var health: float = 100.0
var move_speed: float = 200.0

# Use := only when the type is obvious from the right-hand side
var damage := 10.5
var direction := Vector2.ZERO

# ❌ Avoid — ambiguous and breaks autocompletion
var damage = 10.5
```

Always type function parameters and return values:

```gdscript
func take_damage(amount: float) -> void:
    health -= amount

func get_child_at(idx: int) -> Node:
    return get_child(idx)
```

Type arrays and use `as` for safe casting:

```gdscript
var enemies: Array[CharacterBody2D] = []
const MAX_ENEMIES: int = 20

func _on_body_entered(body: Node2D) -> void:
    var character := body as CharacterBody2D
    if character:
        character.take_damage(damage)
```

## 2. Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Classes / Nodes | `PascalCase` | `PlayerController`, `EnemySpawner` |
| Variables / Functions | `snake_case` | `current_health`, `apply_damage()` |
| Constants | `ALL_CAPS_SNAKE` | `MAX_LIVES`, `GRAVITY_SCALE` |
| Signals | `snake_case`, past tense | `died`, `health_changed`, `item_collected` |
| Private variables | `_snake_case` | `_cooldown_timer`, `_is_grounded` |
| Private functions | `_snake_case` | `_recalculate_path()`, `_update_ui()` |
| Enum members | `ALL_CAPS` | `State.IDLE`, `State.ATTACK` |
| Files / scenes | `snake_case` | `player_controller.gd`, `main_menu.tscn` |

Past-tense signals read naturally at the connection site:
`enemy.died.connect(...)`, `player.health_changed.connect(...)`.

## 3. File & Class Structure Order

```gdscript
@tool                           # 1. annotations

class_name PlayerController extends CharacterBody2D  # 2. class_name + extends

## Handles player input, movement, and state transitions.  # 3. doc comment

signal died                     # 4. signals
signal health_changed(new_health: float)

enum State { IDLE, RUNNING, JUMPING, DEAD }  # 5. enums

const MAX_HEALTH: float = 100.0  # 6. constants

static var instance_count: int = 0  # 7. static variables

@export var move_speed: float = 300.0  # 8. @export variables

var current_state: State = State.IDLE  # 9. public variables

var _jump_count: int = 0         # 10. private variables

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # 11. @onready

func _ready() -> void: ...       # 12. built-in virtual methods (lifecycle order)
func _physics_process(delta: float) -> void: ...
func _input(event: InputEvent) -> void: ...

func take_damage(amount: float) -> void: ...  # 13. public methods

func _update_animations() -> void: ...       # 14. private methods

class AttackData: ...             # 15. inner classes (rare; prefer separate files)
```

## 4. Signals — Decoupled Communication

```gdscript
signal jumped
signal health_changed(new_health: float)
signal enemy_spawned(enemy: CharacterBody2D, position: Vector2)
```

```gdscript
func _ready() -> void:
    health_changed.connect(_on_health_changed)
    died.connect(func(): get_tree().reload_current_scene())

func take_damage(amount: float) -> void:
    _health -= amount
    health_changed.emit(_health)
    if _health <= 0.0:
        died.emit()
```

| Situation | Use |
|---|---|
| Child notifying parent | Signal |
| Sibling notifying sibling | Signal (connected by common parent) |
| Parent driving child | Direct call — parent owns child |
| Completely unrelated nodes | Autoload or event bus |

## 5. Design Patterns

### 5.1 Component Pattern

Break repeated functionality into small, reusable child nodes instead of deep inheritance chains.

```gdscript
# health_component.gd
class_name HealthComponent extends Node

signal died
signal health_changed(new_value: float)

@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
    current_health = max_health

func take_damage(amount: float) -> void:
    current_health = maxf(current_health - amount, 0.0)
    health_changed.emit(current_health)
    if current_health == 0.0:
        died.emit()
```

Any node that can take damage just adds a `HealthComponent` child and connects to its signals. No inheritance required. Use this for shared behaviour (health, hitboxes, steering, sound) that appears in multiple unrelated node types.

### 5.2 Abstract Base + `assert()`

GDScript has no `abstract` keyword. Subclasses that forget to override crash immediately with a clear message.

```gdscript
class_name Enemy extends CharacterBody2D

## Subclasses MUST implement: attack(), update_movement(), die()

func attack() -> void:
    assert(false, "Enemy subclass must implement attack()")

func update_movement() -> void:
    assert(false, "Enemy subclass must implement update_movement()")

func die() -> void:
    assert(false, "Enemy subclass must implement die()")
```

Use for any family of nodes with a shared interface but diverging implementations (enemies, weapons, abilities).

### 5.3 Resources as Data Containers

Use `Resource` subclasses for data that is inspectable and tweakable in the editor.

```gdscript
class_name CharacterStats extends Resource

@export var max_health: float = 100.0
@export var move_speed: float = 300.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.5
```

Assign a resource per entity in the inspector — swap data without touching code. Use for: per-entity configuration, designer-tweakable values, anything that benefits from `.tres` serialization.

### 5.4 Autoloads (Singletons)

Reserve autoloads for truly global state with no natural owner.

```gdscript
# game_manager.gd  (autoload name: GameManager)
extends Node

signal game_paused(is_paused: bool)

var score: int = 0
var is_paused: bool = false:
    set(value):
        is_paused = value
        game_paused.emit(value)
        get_tree().paused = value
```

Rules:
- One responsibility each.
- Never `free()` or `queue_free()` them — causes a crash.
- Do not give the script a `class_name` matching the autoload name (Godot warns it hides the singleton).
- Good candidates: persistent settings, scene transitions, save/load, global event buses.

### 5.5 Scenes vs Scripts

| Use a **Scene** when | Use a **Script** when |
|---|---|
| Node has visual children / layout | Pure logic, no visual composition |
| Designers need to tweak it | Instantiated fully from code |
| The node is large or complex | Small helper or data class |

```gdscript
# Preload at class level — loads once at parse time
const EnemyScene: PackedScene = preload("res://scenes/enemies/goblin.tscn")

func spawn_enemy(pos: Vector2) -> void:
    var enemy: Enemy = EnemyScene.instantiate()
    add_child(enemy)
    enemy.global_position = pos
```

## 6. Node Communication Rules

Call *down* the tree; signal *up* the tree. Never reach upward with `get_parent()` chains — it creates fragile coupling to a specific scene structure.

```
        Level              ← calls children directly
       /     \
    Player   Arena         ← signal upward to Level
   /     \
Weapon  Health             ← signal upward to Player
```

| Direction | Mechanism |
|---|---|
| Parent → Child | Direct reference (`$Child`, `@onready var`) |
| Child → Parent | Signal |
| Sibling → Sibling | Signal wired by common parent |
| Any → Global | Autoload |

## 7. Process vs Physics Process

| Callback | Runs at | Use for |
|---|---|---|
| `_process(delta)` | Variable framerate | UI, animations, non-physics visuals |
| `_physics_process(delta)` | Fixed 60 Hz | Movement, collision, `move_and_slide()` |

```gdscript
func _physics_process(delta: float) -> void:
    velocity = direction * move_speed
    move_and_slide()

func _process(_delta: float) -> void:
    health_bar.value = health_component.current_health
```

Disable unused callbacks — every active process node costs CPU each frame. Call `set_process(false)` / `set_physics_process(false)` when a node temporarily has nothing to do.

## 8. @onready and @export

Always provide an explicit type on `@onready` variables:

```gdscript
# ✅
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health: HealthComponent = $HealthComponent

# ❌ Type is lost, autocompletion breaks
@onready var sprite = $Sprite
```

`@onready` variables are initialized just before `_ready()`, so they are always valid inside it.

Only export what a designer would meaningfully change — not implementation details:

```gdscript
@export var move_speed: float = 300.0
@export var patrol_radius: float = 150.0
@export var stats: CharacterStats
```

Use `%NodeName` (Scene Unique Name) for frequently accessed nodes — it survives scene tree reorganization:

```gdscript
@onready var health_bar: ProgressBar = %HealthBar
```

## 9. Null Safety and Type Checking

Use `is` when you only need a type check; `as` when you need to call methods on the result:

```gdscript
# Branch on type only
func _on_body_entered(body: Node2D) -> void:
    if body is Enemy:
        score += 10

# Need to use the typed reference
func _on_body_entered(body: Node2D) -> void:
    var enemy := body as Enemy
    if enemy:
        enemy.take_damage(damage)
```

Use `is_instance_valid()` instead of `!= null` when the object may have been `queue_free()`d — a freed object is not `null`, it's invalid:

```gdscript
func try_heal(target: Node) -> void:
    if not is_instance_valid(target):
        return
    var health := target.get_node_or_null("HealthComponent") as HealthComponent
    if health:
        health.heal(10.0)
```

## 10. super() in Overridden Methods

Call `super()` to extend parent behaviour; omit it to replace it entirely:

```gdscript
# Extending — call super() first
func _ready() -> void:
    super()
    _setup_ui()

func take_damage(amount: float) -> void:
    super(amount)
    _play_hurt_animation()

# Replacing — intentionally omit super()
func die() -> void:
    _play_death_effect()
    queue_free()
```

When overriding built-in virtual methods (`_ready`, `_process`, `_physics_process`, `_input`), always call `super()` unless you have a deliberate reason not to — omitting it can silently break engine internals or parent scripts.

## 11. await — Common Pitfalls

```gdscript
# ✅ Await a signal inside a coroutine
func show_cutscene() -> void:
    animation_player.play("intro")
    await animation_player.animation_finished
    dialogue.start()

# ✅ Await a one-shot timer
func flash() -> void:
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.2).timeout
    sprite.modulate = Color.WHITE

# ❌ Never await in _process — spawns a new coroutine every frame
func _process(_delta: float) -> void:
    await some_signal

# ❌ Code after await runs asynchronously — other input can fire in between
func _on_button_pressed() -> void:
    await transition.play_out()
    load_next_scene()   # guard against double-presses before this line
```

## 12. Performance Tips

| Practice | Why |
|---|---|
| `preload()` at class level | Loads once at parse time; no repeated disk I/O during gameplay |
| `@onready` over repeated `get_node()` | One lookup at startup vs. every frame |
| Disable `_process` when idle | `set_process(false)` — every active process node costs CPU |
| Group nodes for batch queries | `add_to_group("enemies")` → `get_tree().get_nodes_in_group(...)` |
| `queue_free()` over `free()` | Deferred deletion is safe mid-physics; `free()` can crash during callbacks |
| Typed arrays | `Array[Enemy]` skips per-element runtime type checks |
| Cache heavy lookups in `_ready()` | Never call `find_child()` or long `get_node()` paths in hot callbacks |

## 13. Code Style

```gdscript
# Spaces around operators
var total: float = base + bonus * multiplier

# No parentheses on if/while
if health <= 0.0:
    die()

# match over long if/elif chains
match current_state:
    State.IDLE:    _handle_idle()
    State.RUNNING: _handle_running()
    State.JUMPING: _handle_jumping()

# Lambdas for short one-off connections
animation_player.animation_finished.connect(func(): set_process(false))

# ## doc comments appear in editor tooltips
## Applies damage and emits [signal died] if health reaches zero.
func take_damage(amount: float) -> void:
    ...
```
