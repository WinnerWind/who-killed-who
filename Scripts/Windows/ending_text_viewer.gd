extends TextViewer
class_name EndingTextViewer

@export var credits_scene:PackedScene

func _ready() -> void:
	super()
	titlebar.close_button.pressed.connect(start_credits_scene)
	

func start_credits_scene():
	print("CREDIT START")
