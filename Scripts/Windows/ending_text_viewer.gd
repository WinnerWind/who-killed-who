extends TextViewer
class_name EndingTextViewer

func _ready() -> void:
	super()
	titlebar.close_button.pressed.connect(start_credits_scene)
	

func start_credits_scene():
	print("CREDIT START")
	desktop.call_thread_safe(&"roll_credits")
