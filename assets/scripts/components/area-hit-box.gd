class_name AreaHitBoxComponent extends Area2D

@export var direct_damage: int
@export var area_damage: int
@export var explosion_radius : int
signal has_dealt_damage

func _ready() -> void:
    self.monitorable = false
    self.monitoring = true
    area_entered.connect(_on_area_entered)

func deal_direct_damage(area: Area2D) -> int:
    area.take_damage(direct_damage)
    return direct_damage

func deal_area_damage(area: Area2D) -> int:
    var blast_radius = create_explosion_radius(area)
    var total_area_damage = 0
    for a in blast_radius.get_overlapping_areas():
        if a != area:
            a.take_damage(area_damage)
            total_area_damage += area_damage
    
    return total_area_damage


func create_explosion_radius(area: Area2D) -> Area2D:
    var explosion_area = Area2D.new()
    
    #set up blast radius shape
    var collision_shape = CollisionShape2D.new()
    var circle_shape = CircleShape2D.new()
    circle_shape.radius = explosion_radius
    collision_shape.shape = circle_shape
    
    explosion_area.add_child(collision_shape)
    explosion_area.position = area.position
    
    return explosion_area

# signal
func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        var total_damage = 0
        total_damage += deal_direct_damage(area)
        total_damage += deal_area_damage(area)
        has_dealt_damage.emit(total_damage)

