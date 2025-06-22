extends Panel
class_name Notification

@onready var desktop:Desktop = get_owner()
@export var speed:float
@export var app_text:Label
@export var title:Label
@export var image:TextureRect
@export var initial_size:Vector2
var viewport_size:Vector2:
	get:
		return get_viewport().size
func _ready():
	size = initial_size
	position.x = viewport_size.x + 1500
	animate_to_view(int(viewport_size.x)-250)
	
	
func animate_to_view(to:int):
	var tween = create_tween()
	tween.tween_property(self,"position:x",to,speed)

func remove():
	animate_to_view(int(viewport_size.x)+ 1500)
	await get_tree().create_timer(speed*2).timeout
	queue_free()
