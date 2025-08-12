extends Desktop

@export var credits_window:PackedScene

func roll_credits():
	add_child(credits_window.instantiate())
