@tool
extends ActionLeaf

@export var target: StringName = &"query_result"

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_node: Node3D = blackboard.get_value(target)
	if target_node:
		target_node.queue_free()
		return SUCCESS
	return FAILURE
