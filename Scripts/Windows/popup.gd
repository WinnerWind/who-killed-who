extends VirtualWindow

@export var image_node:TextureRect
@export var title:Label
@export var subtitle:Label

func _ready():
	super()
	titlebar.remove_minimize_button()
	position.y = 400
