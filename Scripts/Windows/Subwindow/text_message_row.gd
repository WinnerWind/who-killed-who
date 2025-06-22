extends HBoxContainer

var is_hovering_over:bool
var username:String
var text:String
var is_group:bool
signal open_chat

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("Click") and is_hovering_over:
			open_chat.emit(username,text,is_group)

func _on_mouse_entered():
	is_hovering_over = true
	$Highlight.theme_type_variation = "FakeButtonHover"

func _on_mouse_exited():
	is_hovering_over = false
	$Highlight.theme_type_variation = "FakeButton"
