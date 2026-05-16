@tool
extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.velocity = Vector3.ZERO
	#print_debug("Idled")
	return SUCCESS
