extends Button

@export var desktop:Desktop
var associated_window:NodePath

func _ready():
	pivot_offset = Vector2(size.x/2,size.y/2) #Calculate pivot offset so it scales up properly in mouse hover

func _on_pressed():
	var window:VirtualWindow = desktop.get_node(associated_window)
	if not window.visible:
		window.position.y = -300
	window.show()
	window.focus_window()



func _on_mouse_exited():
	$AnimationPlayer.play("mouse_exit")


func _on_mouse_entered():
	$AnimationPlayer.play("mouse_enter")
