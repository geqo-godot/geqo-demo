@tool
extends ConditionLeaf

@export var target_key: StringName = &"target_player"
## How close target should be for condition to succeed
@export var min_distance: float = 3

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target: Node3D = blackboard.get_value(target_key)
	if target.global_position.distance_to(actor.global_position) <= min_distance:
		return SUCCESS
	return FAILURE
