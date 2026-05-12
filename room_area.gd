extends Area3D

signal player_entered(room: Node3D, player: Player)
@export var assigned_room: Node3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Player:
		print_debug("Acho a player")
		player_entered.emit(assigned_room, body)
