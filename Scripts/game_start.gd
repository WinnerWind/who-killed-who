extends Node

@export var tutorial_user_scene:PackedScene
@export var login_scene:PackedScene
func _ready() -> void:
	if SaveData.game_users.size() < 2: #Only at tutorial user or otherwise
		get_tree().call_deferred("change_scene_to_packed",tutorial_user_scene)
	else:
		get_tree().call_deferred("change_scene_to_packed",login_scene)
