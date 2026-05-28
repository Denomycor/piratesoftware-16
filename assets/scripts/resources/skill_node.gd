## Data-only resource describing a single skill tree node.
## Instances are created programmatically in ProgressionManager._register_skill_nodes().
## No gameplay effects are read from these during this milestone — they exist
## so the architecture is data-driven and expandable for future milestones.
class_name SkillNode extends Resource

enum Track { ALIEN = 0, CAR = 1 }

## Unique machine-readable identifier. Used in save data.
@export var id: StringName = &""
## Human-readable name shown in the skill tree UI.
@export var display_name: String = ""
## Short description of the skill's effect.
@export var description: String = ""
## Which progression track this node belongs to.
@export var track: Track = Track.ALIEN
## Other node IDs that must be unlocked before this one is available.
@export var prerequisites: Array[StringName] = []
## Skill points required to unlock.
@export var cost: int = 1
## Key for the gameplay effect (read in a future milestone).
@export var effect_key: StringName = &""
## Numeric value for the gameplay effect.
@export var effect_value: float = 0.0
