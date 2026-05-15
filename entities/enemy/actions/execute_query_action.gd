@tool
extends ActionLeaf

enum ResultType {POSITION, NODE}

@export var environment_query: EnvironmentQuery3D
@export var result_type: ResultType
var result = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	environment_query.query_finished.connect(_on_query_finished)

func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	environment_query.request_query()

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if result:
		blackboard.set_value("query_result", result)
		result = null
		return SUCCESS
	return RUNNING

func _on_query_finished(query_result: QueryResult3D):
	match result_type:
		ResultType.POSITION:
			result = query_result.get_highest_score_position()
		ResultType.NODE:
			result = query_result.get_highest_score_node()
