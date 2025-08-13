@tool
extends Desktop
class_name EndingDesktop

@export var credits_window:PackedScene

func _ready() -> void:
	super()
	play_sound("EndingSong")

func roll_credits():
	var credits:CreditsWindow = credits_window.instantiate()
	credits.desktop = self
	add_child(credits)
	

@export var game_restart_user:UserMetadata
func credits_ended():
	await get_tree().create_timer(15).timeout
	# scene thingamagic
	# gets this from user row 
	var new_bootup = bootup_scene.instantiate()
	new_bootup.sequence = game_restart_user.boot_sequence
	new_bootup.scene_to_start = game_restart_user.scene
	get_tree().root.add_child(new_bootup)
	queue_free() #Time to be removed.
