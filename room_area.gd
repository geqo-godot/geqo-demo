extends Area3D

@export var assigned_room: Node3D
@export var spawn_point: Node3D
@export var enemy_scene: PackedScene
@export var environment_query: PackedScene
@export var behavior: PackedScene

var active_enemies: Array[QuerierEnemy]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body is not Player:
		return
	print_debug("Player entered room")
	if enemy_scene:
		var enemy_instance: QuerierEnemy = enemy_scene.instantiate()
		var env_query_instance: EnvironmentQuery3D = environment_query.instantiate()
		var behavior_instance: BeehaveTree = behavior.instantiate()
		spawn_point.add_child(enemy_instance)
		enemy_instance.add_child(env_query_instance)
		enemy_instance.add_child(behavior_instance)
		enemy_instance.env_query = env_query_instance
		behavior_instance.setup(env_query_instance)
		active_enemies.append(enemy_instance)

func _on_body_exited(body: Node3D):
	if body is Player:
		for e: QuerierEnemy in active_enemies:
			e.queue_free()
		active_enemies.clear()
