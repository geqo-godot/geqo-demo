@tool
extends ActionLeaf

enum ResultType {POSITION, NODE}

@export var environment_query: EnvironmentQuery3D
@export var result_type: ResultType

var result: QueryResult3D = null

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	if not actor.env_query:
		actor.set_up_query()
	environment_query.query_finished.connect(_on_query_finished, CONNECT_ONE_SHOT)
	environment_query.request_query()

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if result:
		if result.has_result():
			blackboard.set_value(&"query_result", get_result())
			return SUCCESS
		else:
			return FAILURE
	return RUNNING

func after_run(actor: Node, blackboard: Blackboard) -> void:
	result = null

func _on_query_finished(query_result: QueryResult3D):
	result = query_result

func get_result():
	match result_type:
		ResultType.POSITION:
			return result.get_highest_score_position()
		ResultType.NODE:
			return result.get_highest_score_node()
