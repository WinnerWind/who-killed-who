extends Panel

enum ButtonTypes {FILE_MANAGER,CHAT,EMAIL,CALCULATOR,SYSTEM_INFORMATION,SETTINGS,NOTEPAD,SSH,GAME_LIST,ANSWER_INPUT,WEB_RADIO}
@export var current_type:ButtonTypes
@export var main_text_string:String
@export var sub_text_string:String
@export var normal_size:float = 30
@export var hovered_size:float = 50
@export var normal_text_color:Color = Color.WHITE
@export var hovered_text_color:Color
@export var normal_text_color_light:Color
@export var hovered_text_color_light:Color = Color.WHITE
@export var speed:float = 15
@export_group("Nodes")
@export var main_text:Label
@export var sub_text:Label
@export var desktop:Desktop

func _ready():
	tooltip_text = sub_text_string
	
	desktop.theme_changed.connect(func():
		_on_hover_exit()
		) #QUickly changes themes by refreshing colors
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_hover_exit)
	
	
	sub_text.modulate = Color.TRANSPARENT
	if desktop.is_dark_theme:
		main_text.modulate = normal_text_color
	else:
		main_text.modulate = normal_text_color_light
	
	main_text.text = main_text_string
	sub_text.text = sub_text_string

var mouse_hovered:bool
func _on_hover():
	var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	if desktop.is_dark_theme:
		#main_text.modulate = main_text.modulate.lerp(hovered_text_color,delta * speed)
		#sub_text.modulate = sub_text.modulate.lerp(hovered_text_color,delta * speed)
		tween.tween_property(main_text,"modulate",hovered_text_color,speed)
		tween.tween_property(sub_text,"modulate",hovered_text_color,speed)
	else: #light theme
		tween.tween_property(main_text,"modulate",hovered_text_color_light,speed)
		tween.tween_property(sub_text,"modulate",hovered_text_color_light,speed)
	
	tween.tween_property(self,"custom_minimum_size:y",hovered_size,speed)
	mouse_hovered = true
	theme_type_variation = "FancyButtonHover"

func _on_hover_exit():
	var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	if desktop.is_dark_theme:
		#main_text.modulate = main_text.modulate.lerp(hovered_text_color,delta * speed)
		#sub_text.modulate = sub_text.modulate.lerp(hovered_text_color,delta * speed)
		tween.tween_property(main_text,"modulate",normal_text_color,speed)
		tween.tween_property(sub_text,"modulate",Color.TRANSPARENT,speed)
	else: #light theme
		tween.tween_property(main_text,"modulate",normal_text_color_light,speed)
		tween.tween_property(sub_text,"modulate",Color.TRANSPARENT,speed)
	
	tween.tween_property(self,"custom_minimum_size:y",normal_size,speed)
	mouse_hovered = false
	theme_type_variation = "FancyButton"

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Click") and mouse_hovered:
			desktop.open_window(current_type)


#func set_subtext_color(color:Color) -> void:
	#sub_text.add_theme_color_override("font_color", color)
#
#func set_maintext_color(color:Color) -> void:
	#main_text.add_theme_color_override("font_color", color)
#
#func get_subtext_color() -> Color:
	#return sub_text.get_theme_color("font_color")
#
#func get_maintext_color() -> Color:
	#return main_text.get_theme_color("font_color")
