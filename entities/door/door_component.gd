@tool
class_name DoorComponent extends Node
enum DoorType {ROTATING, SLIDING}
enum ForwardDirection {X, Y, Z}
enum DoorStatus {OPEN, CLOSED}

signal opened
signal closed

@export_group("Door Settings")
@export var door_type: DoorType
@export var forward_direction: ForwardDirection
@export var movement_direction: Vector3
@export var rotation: Vector3 = Vector3(0, 1, 0)
@export var rotation_amount: float = 90.0
@export var door_size: Vector3
## Open door depending on what side player is standing
@export var use_player_position: bool = true
# Override adjustment when nos using player position
@export var override_rotation_adjustment: float = 1.0
@export_group("Close Settings")
@export var close_time: float = 2.0
@export var close_automatically: bool = true
@export_group("Tween Settings")
@export var speed: float = 0.5
@export var transition: Tween.TransitionType
@export var easing: Tween.EaseType

var parent: Node3D
var orig_pos: Vector3
var orig_rot: Vector3
var rotation_adjustment: float
var door_direction: Vector3
var door_status: DoorStatus = DoorStatus.CLOSED

func _ready() -> void:
	if Engine.is_editor_hint():
		parent = get_parent()
		if !parent.child_order_changed.is_connected(_on_parent_children_changed):
			parent.child_order_changed.connect(_on_parent_children_changed)
		tree_entered.connect(_on_tree_entered)
		return
	parent = get_parent()
	orig_pos = parent.position # Original pos of door
	orig_rot = parent.rotation
	parent.ready.connect(connect_parent) # Wait for parent to load to connect interaction signal

func connect_parent() -> void:
	parent.connect("interacted", Callable(self, "check_door")) # "interacted" from interaction component

func check_door(player: Player, type: InteractionRaycast.InteractionType) -> void:
	if type != InteractionRaycast.InteractionType.INTERACT:
		return
	match forward_direction:
		ForwardDirection.X:
			door_direction = parent.global_transform.basis.x
		ForwardDirection.Y:
			door_direction = parent.global_transform.basis.y
		ForwardDirection.Z:
			door_direction = parent.global_transform.basis.z

	var door_position: Vector3 = parent.global_position
	
	if use_player_position == false:
		rotation_adjustment = override_rotation_adjustment

	else:
		var player_position: Vector3 = player.global_position
		var direction_to_player: Vector3 = door_position.direction_to(player_position)
		var door_dot: float = direction_to_player.dot(door_direction)
		if door_dot < 0:
			rotation_adjustment = -1
		else:
			rotation_adjustment = 1

	match door_status:
		DoorStatus.CLOSED:
			open_door()
		DoorStatus.OPEN:
			close_door()

func open_door() -> void:
	door_status = DoorStatus.OPEN
	var tween = get_tree().create_tween()
	tween.tween_callback(func(): opened.emit())
	match door_type:
		DoorType.SLIDING:
			tween.tween_property(parent, "position", orig_pos + (movement_direction *
			door_size), speed).set_trans(transition).set_ease(easing)
		DoorType.ROTATING:
			tween.tween_property(parent, "rotation", orig_rot + (rotation *
			rotation_adjustment * deg_to_rad(rotation_amount)),
			speed).set_trans(transition).set_ease(easing)
	
	if close_automatically:
		tween.tween_interval(close_time)
		tween.tween_callback(close_door) # Close door after set time

func close_door() -> void:
	door_status = DoorStatus.CLOSED
	var tween = get_tree().create_tween()
	match door_type:
		DoorType.SLIDING:
			tween.tween_property(parent, "position", orig_pos, speed).set_trans(transition).set_ease(easing)
		DoorType.ROTATING:
			tween.tween_property(parent, "rotation", orig_rot, speed).set_trans(transition).set_ease(easing)
	tween.tween_callback(func(): closed.emit())

"""Editor functions"""

func _on_tree_entered() -> void:
	parent = get_parent()
	if !parent.child_order_changed.is_connected(_on_parent_children_changed):
		parent.child_order_changed.connect(_on_parent_children_changed)
	update_configuration_warnings()

func _on_parent_children_changed() -> void:
	var is_child: bool = false

	for child in parent.get_children():
		if child == self:
			is_child = true

	if !is_child:
		parent.child_order_changed.disconnect(_on_parent_children_changed)
		return
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	var has_interact: bool = false
	for child in get_parent().get_children():
		if child is InteractionComponent:
			has_interact = true
	
	if has_interact == false:
		warnings.append("DoorComponent needs InteractionComponent to work.")
	
	return warnings
