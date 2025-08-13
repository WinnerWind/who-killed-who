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
	
