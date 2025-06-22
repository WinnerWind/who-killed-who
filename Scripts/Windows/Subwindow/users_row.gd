extends HBoxContainer

var is_hovering_over:bool
signal change_user

#misc cata
var user:UserMetadata

func _ready():
	$"Icon Margins/Icon".texture = user.image
	$Text/Name.text = user.name
	$Text/Subtext.text = user.subtext
	$Highlight.theme_type_variation = "FakeButton"
	
func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("Click") and is_hovering_over:
			change_user.emit(user) #send required data to desktop

func _on_mouse_entered():
	is_hovering_over = true
	$Highlight.theme_type_variation = "FakeButtonHover"

func _on_mouse_exited():
	is_hovering_over = false
	$Highlight.theme_type_variation = "FakeButton"
