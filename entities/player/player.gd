class_name Player
extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const DECAY: float = 8.0

@export var mouse_sensitivity: float = 0.002
@export var min_boundary: float = -80.0
@export var max_boundary: float = 15.0
@export var animation_decay: float = 20.0
# Stores the x/y direction the player is trying to look in
var _look: Vector2 = Vector2.ZERO

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var body: Node3D = $Body
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback
var start_position: Vector3


func _ready() -> void:
	anim_state = anim_tree["parameters/playback"]
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	start_position = global_position

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	var direction: Vector3 = get_movement_direction()
	handle_idle_physics_frame(delta, direction)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("home_button"):
		# Go back to spawn position
		global_position = start_position
	if event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look = -event.relative * mouse_sensitivity

func get_movement_direction() -> Vector3:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward"
	)
	var input_vector: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	return horizontal_pivot.global_transform.basis * input_vector

func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)

	vertical_pivot.rotation.x = clampf(
		vertical_pivot.rotation.x, deg_to_rad(min_boundary), deg_to_rad(max_boundary)
	)
	_look = Vector2.ZERO

func look_toward_direction(direction: Vector3, delta: float) -> void:
	var target_transform: Transform3D = body.global_transform.looking_at(
		body.global_position - direction, Vector3.UP, true
	)
	body.global_transform = body.global_transform.interpolate_with(
		target_transform, 1.0 - exp(-animation_decay * delta)
	)

func handle_idle_physics_frame(delta: float, direction: Vector3) -> void:
	velocity.x = exponential_decay(velocity.x, direction.x * SPEED, DECAY, delta)
	velocity.z = exponential_decay(velocity.z, direction.z * SPEED, DECAY, delta)
	anim_state.travel("idle")
	
	anim_tree["parameters/move/blend_position"] = velocity.length() / SPEED
	if direction:
		anim_state.travel("move")
		look_toward_direction(direction, delta)

func exponential_decay(a: float, b: float, decay: float, delta: float) -> float:
	return b + (a - b) * exp(-decay * delta)
