extends SpringArm3D
@export var target: Node3D
@export var decay: float = 30.0

func _physics_process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(
		target.global_transform,
		1.0 - exp(-decay * delta)
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				spring_length = clamp(spring_length - 1, 2, 15)
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				spring_length = clamp(spring_length + 1, 2, 15)
