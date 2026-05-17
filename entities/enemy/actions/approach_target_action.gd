@tool
extends ActionLeaf
## Get closer to a target until min range is reached. Needs a target to work.

enum TargetType { POSITION, NODE }

## How close the enemy is to target to succeed
@export var min_range: float = 3
@export var blackboard_key: StringName = &"query_result"
@export var target_type: TargetType

var current_target: Vector3
var final_target

func before_run(actor: Node, blackboard: Blackboard) -> void:
	final_target = blackboard.get_value(blackboard_key)
	match target_type:
			TargetType.POSITION:
				actor.nav_agent.target_position = final_target
			TargetType.NODE:
				actor.nav_agent.target_position = final_target.global_position

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_pos: Vector3
	match target_type:
		TargetType.POSITION:
			target_pos = final_target
		TargetType.NODE:
			target_pos = final_target.global_position
	
	if target_type == TargetType.NODE:
		actor.nav_agent.target_position = final_target.global_position
	current_target = actor.nav_agent.get_next_path_position()
	actor.move_to_target(current_target)
	
	if actor.global_position.distance_to(target_pos) < min_range:
		return SUCCESS
	return RUNNING
