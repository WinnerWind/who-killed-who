extends Panel
## A node that simulates a window like in a real desktop.
class_name VirtualWindow

# Weird way of getting the desktop node. Also ensures that I dont fuck up and
# Run a window as it is without a Desktop Environment
#UPDATE
# Desktop node reference is given by desktop.gd in the open_window()
# Can be provided by export if needed.
@export var desktop:Desktop

@export var starting_size:Vector2
#region Dragging Variables
var is_mouse_in_window:bool #Is the mouse inside the window
var dragging:bool #Is being dragged currently 
var where_to_drag_from:Vector2 #Variable to make it so that the user can drag from any part of window
var dragging_from_top:bool #Checks if its being dragged from the titlebar
@export var titlebar_size:float = 35# Size of the titlebar
#endregion
var viewport_size:Vector2:
	get:
		return get_viewport().size

@onready var titlebar:Titlebar = $Sorter/Titlebar
@export_subgroup("Window Metadata")
@export var icon:CompressedTexture2D
@export var window_icon_name:StringName

var is_current_window_foucused:
	get:
		return titlebar.theme_type_variation == "TitlebarFocused" # Hacky solution by making the titlebar store the focused state.

func _ready():
	# Connect minimize and close button signals
	titlebar.close_button.pressed.connect(close_window)
	titlebar.minimize_button.pressed.connect(minimize_window)
	
	#Gets viewport size for later maths
	get_tree().get_root().size_changed.connect(game_resized) 
	
	
	#await get_tree().create_timer(1.0).timeout
	#set_deferred("size",starting_size)
	
	#$Titlebar.set_deferred("size",Vector2(starting_size.x,titlebar_size))
	#$Contents.set_deferred("size",size)
	#$Contents.set_deferred("position",Vector2($Contents.position.x,titlebar_size))
	
	#$Contents.set_deferred("size",Vector2(size.x,size.y-titlebar_size)) #Fixes weird glitches with the system information class. CHECK THIS LINE IF IMG VIEWER BREAKS
	
	#$Titlebar.size.y = titlebar_size # Makes titlebar the same size
	#$Titlebar.size.x = size.x #Safety check to ensure the titlebar is the same size
	#$Contents.size.y = size.y - titlebar_size # Makes the contents as big as window minus space taken by titlebar
	#$Contents.size.x = size.x # Safety check to ensure contents are as big as window
	#$Contents.position.y = $Titlebar.position.y+titlebar_size #Moves the contents properly
	change_titlebar_text(name) #Sets title bar text but doesnt rename it
	
	position.x = -3000 #Prepare for animation
	animate_to_view(20)
	
	desktop.theme_changed.connect(set_icons) #connect so when theme changed we get to know.
	set_icons()
	# Ensures it's on top
	await get_tree().create_timer(0.1).timeout
	desktop.move_child(self,-1) #-2 so that it doesnt get shadowed by the panels
	set_deferred("size",starting_size)


func _process(delta):
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	#region Dragging
	# Gets position to be dragged from.
	if Input.is_action_just_pressed("Click") and is_mouse_in_window:
		# Ensures that the user can drag from top part of window only (titlebar)
		# By getting the position of the mouse with respect to the panel
		where_to_drag_from = position - mouse_position # Local position of dragging action
		dragging_from_top = where_to_drag_from.y > -titlebar_size #Checks if only dragging from top part
		
	# Checks for dragging action
	if Input.is_action_pressed("Click") and is_mouse_in_window and dragging_from_top:
		# Normal dragging action if its inside the window
		dragging = true
		position = mouse_position + where_to_drag_from #Changes position with respect to position of mouse at start of drag
	elif Input.is_action_pressed("Click") and dragging:
		# Makes it so that we can drag in the opposite direction too
		dragging = true
		position = mouse_position + where_to_drag_from
	else:
		# User is not trying to drag right now
		dragging = false
		if visible:
			move_inside_viewport(delta) #it being here prevents stuttering if the user is still trying to drag
	#endregion

func _input(_event):
	## Ensures we don't accidentally check position of a button press
	## As it crashes the game.
	#if event is InputEventMouseButton:

	if (Input.is_action_just_pressed("Click") or SaveData.ram_save["settings_rollover_window_focus"]) and is_mouse_in_window: #Ensures we can only make it the foreground if the user clicks it.
		# A solution that took me too long to find
		# Moves the window to the bottom of the scene tree so it takes
		# Precedence in being shown
		# I am so angry that this took me 3 hours to figure out
		# Also fixes weird bug where the window that was above in the 
		# Scene tree would not be highlighted unless the mouse went outside
		# Then inside the window.
		focus_window()

func focus_window():
	desktop.move_child(self,-1)
	desktop.unfocus_other_windows() #Unfocuses all other windows
	titlebar.theme_type_variation = "TitlebarFocused"
	titlebar.titlebar_text.theme_type_variation = "TitlebarTextFocused"
	set_icons() #small inefficiency but who cares

func unfocus_window():
	titlebar.theme_type_variation = "Titlebar"
	titlebar.titlebar_text.theme_type_variation = "TitlebarText"
	set_icons()

#region Mouse Inside Window Checker
# Checks whether the mouse is inside the window or not
func _on_mouse_entered():
	# Check ensures that one doesn't accidentally drag two windows at once
	if not Input.is_action_pressed("Click"):
		is_mouse_in_window = true
func _on_mouse_exited():
	is_mouse_in_window = false
#endregion

func move_inside_viewport(delta)->void:
	## A little function to keep the window within the viewport by moving it back to position
	
	var speed:int = 1000
	var blocked_edges:Array[int] = desktop.active_edges
	#Ensures right edge doesn't bleed out
	if position.x+size.x > viewport_size.x - blocked_edges[1]: 
		position.x -= speed * delta
	elif position.x<= blocked_edges[3]: #Ensures left edge doesnt bleed out
		position.x += speed * delta
	else:
		pass
	
	#Esnures bottom edge doesnt bleed out
	if position.y + size.y > viewport_size.y - blocked_edges[2]: 
		position.y -=speed*delta
	elif position.y <= blocked_edges[0]: #Ensures top edge doesnt bleed out
		position.y += speed * delta
	else:
		pass
		
func animate_to_view(to:int = 0)->void:
	# A function that moves the window into view from the left when it starts and goes there
	# When it's closed
	var tween = create_tween()
	tween.tween_property(self,"position:x",to,0.3)
	
func change_titlebar_text(new_name:String):
	name = new_name #Changes name of node
	titlebar.change_text(name) #Sets titlebar text to the new name
	
func close_window(): 
	animate_to_view(-1500)
	await get_tree().create_timer(0.5).timeout #Delay or else the window is poofed instantly
	queue_free()
func minimize_window():
	var tween = create_tween()
	tween.tween_property(self,"position:y",-1500,0.4)
	await get_tree().create_timer(0.5).timeout
	hide()

func game_resized():
	viewport_size = get_viewport().size
	size = starting_size

func set_icons():
	# sets the icon to be given from the desktop itself.
	
	#story time
	#so this call was below the small delay below this line. the problem was that 
	#the app tray icons would not be set properly because there was a 0.1s delay before
	# the window actually got it's icon. 
	#solution was to move the call above the timer lol.
	
	# MAKE SURE ITS ALIGNED PROPERLY DAMN IT!!!
	icon = fetch_icon(window_icon_name,true)
	
	# Set all titlebar icons
	if not titlebar.close_button == null:
		titlebar.close_button.icon = fetch_icon(&"close_button")
	if not titlebar.minimize_button == null: #Safety check to ensure that this doesnt break on the popup window class
		titlebar.minimize_button.icon = fetch_icon(&"minimize_button")

func fetch_icon(id:StringName = &"missing_texture",return_normal_icon:bool = false) -> CompressedTexture2D:
	# fetches icons from the desktop.
	# Return Normal Icon returns the icon with regards to the theme regardless of window focus state.
	var returning_icon
	if desktop.is_dark_theme:
		if desktop.use_inverted_icons_when_titlebar_focused and is_current_window_foucused and not return_normal_icon:
			returning_icon = desktop.light_icons.get(id)
		else:
			returning_icon = desktop.dark_icons.get(id)
	else:
		if desktop.use_inverted_icons_when_titlebar_focused and is_current_window_foucused and not return_normal_icon:
			returning_icon = desktop.dark_icons.get(id)
		else:
			returning_icon = desktop.light_icons.get(id)
	
	# Returns the null icon if the icon was not defined for whatever reason.
	if returning_icon == null:
		return fetch_icon(&"missing_texture")
	else:
		return returning_icon
