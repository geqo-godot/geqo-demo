extends Node3D

func _on_room_area_player_entered(room: Node3D, player: Player) -> void:
	for current_room: Node3D in get_children():
		if current_room is Area3D:
			continue
		if current_room == room:
			room.visible = true
			continue
		current_room.visible = false
