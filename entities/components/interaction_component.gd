class_name InteractionComponent
extends Node

signal player_interacted(object: Node3D, player: Player)

## Specify mesh to highlight. If not then first found mesh will be chosen.
@export var mesh: MeshInstance3D

@export var context: String
@export var override_icon: bool = false
@export var new_icon: Texture2D
@export var show_context: bool = true

var highlight_material: Material = preload("res://assets/materials/interactable_highlight.tres")
var parent: Node3D

func _ready() -> void:
	parent = get_parent()
	connect_parent()
	call_deferred("set_default_mesh")


func in_range() -> void:
	if show_context:
		mesh.material_overlay = highlight_material
		print_debug(parent)

func not_in_range() -> void:
	if show_context:
		mesh.material_overlay = null


func on_interact(player: Player) -> void:
	player_interacted.emit(parent, player)
	print_debug(parent.name)

func remove_highlight():
	mesh.material_overlay = null

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted", [{ "name": "player", "type": Player }])
	
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interacted", Callable(self, "on_interact"))

func set_default_mesh() -> void:
	if mesh:
		return
	for i in parent.get_children():
		if i is MeshInstance3D:
			mesh = i
