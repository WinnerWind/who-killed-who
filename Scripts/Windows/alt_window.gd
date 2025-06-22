extends Panel
class_name VirtualWindow_Alt

var is_mouse_in_window:bool
var dragging:bool
var where_to_drag_from:Vector2
var dragging_from_top:bool
@export var titlebar_size:float = 50
var mouse_position:Vector2

func _process(delta):
	#region Dragging
	if Input.is_action_just_pressed("Click") and is_mouse_in_window:
		where_to_drag_from = position - mouse_position
		dragging_from_top = where_to_drag_from.y > -titlebar_size

	if Input.is_action_pressed("Click") and is_mouse_in_window and dragging_from_top:
		dragging = true
		z_index = 1  # Bring to front when dragging starts
		position = mouse_position + where_to_drag_from
		get_parent().move_child(self, get_parent().get_child_count() - 1)  # Move to the end of the children list
	elif Input.is_action_pressed("Click") and dragging:
		dragging = true
		position = mouse_position + where_to_drag_from
	else:
		dragging = false
		if not is_mouse_in_window:  # Only reset z_index when mouse leaves
			z_index = -1 
			if get_parent().currently_dragged_window == name:
				get_parent().currently_dragged_window = "" 

	#endregion

func _input(event):
	if Input.is_action_pressed("Click"):
		mouse_position = event.position

func _on_mouse_entered():
	if not Input.is_action_pressed("Click") and get_parent().currently_dragged_window != name:
		is_mouse_in_window = true
		z_index = 0 
func _on_mouse_exited():
	is_mouse_in_window = false

func _ready():
	# Set initial z_index to -1 to ensure it's behind other panels by default
	z_index = -1
