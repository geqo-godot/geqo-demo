@tool
extends ActionLeaf
## Get closer to a target until min range is reached. Needs a target to work.

## How close the enemy is to target to succeed
@export var min_range: float = 3
@export var blackboard_key: String = "query_result"

var current_target: Vector3
var final_target: Vector3

func before_run(actor: Node, blackboard: Blackboard) -> void:
	final_target = blackboard.get_value(blackboard_key)
	actor.nav_agent.target_position = final_target

func tick(actor: Node, blackboard: Blackboard) -> int:
	current_target = actor.nav_agent.get_next_path_position()
	actor.move_to_target(current_target)
	
	if actor.global_position.distance_to(final_target) < min_range:
		return SUCCESS
	return RUNNING
