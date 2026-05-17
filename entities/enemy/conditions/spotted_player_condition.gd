@tool
extends ConditionLeaf

@export_flags_3d_physics var collision_mask: int

var raycast: RayCast3D
var player: Player

func before_run(actor: Node, blackboard: Blackboard) -> void:
	if not raycast:
		raycast = RayCast3D.new()
		actor.add_child(raycast)
		raycast.collision_mask = collision_mask
	else:
		raycast.enabled = true
	if not player:
		player = get_tree().get_first_node_in_group("player")

func tick(actor: Node, blackboard: Blackboard) -> int:
	raycast.target_position = raycast.to_local(player.global_position)
	raycast.force_raycast_update()
	if raycast.get_collider() == player:
		blackboard.set_value(&"target_player", player)
		return SUCCESS
	return FAILURE

func after_run(actor: Node, blackboard: Blackboard) -> void:
	raycast.enabled = false
