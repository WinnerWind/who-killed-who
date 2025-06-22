extends HBoxContainer

var is_hovering_over:bool
@export var game_id:int

signal pressed(id:int)
func _ready():
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.pressed.connect(get_owner().desktop.open_window.bind(game_id))
	$Highlight.theme_type_variation = "FakeButton"

func _on_mouse_entered():
	is_hovering_over = true
	$Highlight.theme_type_variation = "FakeButtonHover"

func _on_mouse_exited():
	is_hovering_over = false
	$Highlight.theme_type_variation = "FakeButton"

func _input(event):
	if event is InputEventMouseButton:
		if is_hovering_over and event.double_click:
			pressed.emit()
