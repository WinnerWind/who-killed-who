extends HBoxContainer

var is_hovering_over:bool

var text:String
var sender:String
var recipient:String
var date:String
var subject:String

signal open_email
func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("Click") and is_hovering_over:
			open_email.emit(text,sender,recipient,subject,date)

func _on_mouse_entered():
	is_hovering_over = true
	$Highlight.theme_type_variation = "FakeButtonHover"


func _on_mouse_exited():
	is_hovering_over = false
	$Highlight.theme_type_variation = "FakeButton"
