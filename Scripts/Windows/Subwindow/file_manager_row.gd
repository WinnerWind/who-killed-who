extends Node


var is_hovering_over:bool
var ready_to_display:bool

signal change_dir
func _input(event):
	if event is InputEventMouseButton:
		if is_hovering_over and ready_to_display and event.double_click:
			change_dir.emit($Name.text)

func _on_mouse_entered():
	is_hovering_over = true
	$Highlight.theme_type_variation = "FakeButtonHover"

func _on_mouse_exited():
	is_hovering_over = false
	$Highlight.theme_type_variation = "FakeButton"
