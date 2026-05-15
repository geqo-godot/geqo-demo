@tool
extends ActionLeaf
## Sets up the current desired target into an actual target.

func tick(_actor: Node, blackboard: Blackboard) -> int:
	var desired_target = blackboard.get_value("desired_target")
	if not desired_target:
		print_debug("No desired target.")
		return FAILURE

	blackboard.set_value("target", desired_target)
	return SUCCESS
