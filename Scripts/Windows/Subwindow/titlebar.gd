extends Panel
class_name Titlebar
# Handles Titlebar behaviour

@export var close_button:Button
@export var minimize_button:Button
@export var titlebar_text:Label

#Stores name and nodepath
var custom_titlebar_items = {}

@export_subgroup("Sorters")
@export var left_sorter:HBoxContainer
@export var center_sorter:HBoxContainer
@export var right_sorter:HBoxContainer

func change_text(new_text:String):
	titlebar_text.text = new_text

enum sorters {LEFT,CENTER,RIGHT}

func add_button(sorter:sorters,callable:Callable,button_name:StringName,shortcut:StringName = ""):
	var new_button = make_new_button()
	# set shortcut
	if not shortcut == "":
		var new_inputevent = InputEventAction.new()
		new_inputevent.action = shortcut #set the shortkut name
		new_button.shortcut = Shortcut.new() #need this in order to add a new shortcut to it
		new_button.shortcut.events.append(new_inputevent)
	
	new_button.pressed.connect(callable)
	match sorter:
		sorters.LEFT:
			left_sorter.add_child(new_button)
		sorters.RIGHT:
			right_sorter.add_child(new_button)
			right_sorter.move_child(new_button,0) #Moves to start so technically it's on the left side.
		sorters.CENTER:
			center_sorter.add_child(new_button)
	# Adds it to the array for further reference.
	custom_titlebar_items[button_name] = get_node(new_button.get_path())

func remove_minimize_button(): #For the Popup window
	minimize_button.queue_free()

func add_label(sorter:sorters,label_name:StringName):
	var new_label:Label = Label.new()
	match sorter:
		sorters.LEFT:
			left_sorter.add_child(new_label)
		sorters.RIGHT:
			right_sorter.add_child(new_label)
		sorters.CENTER:
			center_sorter.add_child(new_label)
	
	custom_titlebar_items[label_name] = get_node(new_label.get_path())

func make_new_button() ->Button:
	var new_button = Button.new()
	new_button.flat = true
	new_button.expand_icon = true
	new_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_button.custom_minimum_size = Vector2(32,24)
	return new_button
