@tool
extends ActionLeaf
## Get closer to a target until min range is reached. Needs a target to work.

## How close the enemy is to target to succeed
@export var min_range: float = 3


var current_target: Node3D

func before_run(actor: Node, blackboard: Blackboard) -> void:
	current_target = blackboard.get_value("target")

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not current_target:
		print_debug("Target needed.")
		return FAILURE
	actor.move_to_target(current_target)
	actor.state_label.text = "Approaching Target"
	
	if actor.global_position.distance_to(blackboard.get_value("target").global_position) < min_range:
		return SUCCESS
	return RUNNING
