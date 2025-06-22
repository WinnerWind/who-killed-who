extends Button

var mouse_in_panel:bool

@export var icon_name:StringName

@onready var panel = $Panel 

@onready var desktop:Desktop = get_owner() #get desktop node

@export var animation_player:AnimationPlayer
func _ready():
	#animation_player.play("close_panel")
	desktop.theme_changed.connect(set_icon)
	set_icon()

func _on_pressed():
	if panel.visible:
		animation_player.play("close_panel")
	else:
		animation_player.play("open_panel")

func _input(_event):
	if Input.is_action_pressed("Click") and not mouse_in_panel:
		animation_player.play("close_panel")

func _on_panel_mouse_entered():
	# Connect button mouse enter & panel mouse enter
	mouse_in_panel = true

func _on_panel_mouse_exited():
	# Connect button mouse exit & panel mouse exit
	mouse_in_panel = false

func set_icon():
	if desktop.is_dark_theme:
		icon = desktop.dark_icons.get(icon_name)
	else:
		icon = desktop.light_icons.get(icon_name)
