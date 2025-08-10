extends VBoxContainer

@onready var desktop:Desktop = get_owner() #get_tree().root.get_child(1)

enum window_types {FILE_MANAGER,CHAT,EMAIL,CALCULATOR,SYSTEM_INFORMATION,SETTINGS,NOTEPAD,SSH,GAME_LIST,ANSWER_INPUT,WEB_RADIO}
@export var type:window_types
@export var custom_code:int

enum IconTypes {THEME_BASED,USE_LIGHT,USE_DARK}
@export var icon_type:IconTypes
@export var icon_name:StringName
@export var text:String
@export var tooltip:String
@export var open_file_instead:bool
@export var file_path:String = "Desktop/"
@export var autoshift:bool = false

var original_position:Vector2
func _ready():
	set_icon()
	original_position = position
	$Label.text = text
	tooltip_text = tooltip
	desktop.theme_changed.connect(set_icon)
	
	get_tree().root.size_changed.connect(size_changed)
	
	pivot_offset = Vector2(size.x/2,size.y/2) #Calculate pivot offset so it scales up properly in mouse hover

func _process(delta):
	if autoshift:
		move_inside_viewport(delta)

func size_changed():
	position = original_position

func move_inside_viewport(delta)->void:
	## A little function to keep the window within the viewport by moving it back to position
	var viewport_size:Vector2 = get_tree().root.size
	
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
		

func _on_pressed():
	$AnimationPlayer.play("pressed")
	if not open_file_instead:
		if not custom_code == 0:
			desktop.open_window(custom_code)
		else:
			desktop.open_window(type)
	else:
		#Checks whether the path given is a file or a folder and opens accordingly
		var file_or_folder = desktop.get_node(desktop.files_path+"/"+file_path)
		if file_or_folder is VirtualFile:
			desktop.hand_over_file(desktop.files_path+"/"+file_path)
		else: #must be virtual folder
			desktop.open_file_manager(desktop.files_path+"/"+file_path)

func set_icon():
	$Button.icon = fetch_icon()

func fetch_icon():
	if icon_type == IconTypes.THEME_BASED:
		if desktop.is_dark_theme:
			return desktop.dark_icons.get(icon_name)
		else:
			return desktop.light_icons.get(icon_name)
	elif icon_type == IconTypes.USE_LIGHT:
		return desktop.light_icons.get(icon_name)
	elif icon_type == IconTypes.USE_DARK:
		return desktop.dark_icons.get(icon_name)


func _on_mouse_entered():
	$AnimationPlayer.play("mouse_enter")


func _on_mouse_exited():
	$AnimationPlayer.play("mouse_exit")
