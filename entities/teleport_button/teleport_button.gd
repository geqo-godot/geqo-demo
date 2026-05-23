extends StaticBody3D

@export var teleport_message: String
@export var teleport_target: Node3D

func _ready() -> void:
	$Label3D.text = teleport_message

func _on_interaction_component_player_interacted(object: Node3D, player: Player) -> void:
	player.global_position = teleport_target.global_position
