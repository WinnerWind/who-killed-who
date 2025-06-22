extends Panel

@export var use_alternate_icon:bool
@export var image_to_use:CompressedTexture2D
@export var main_text:Label
@export var title:Label
@export var icon:TextureRect
@export var alternate_icon:TextureRect
@export var yes_button:Button
@export var no_button:Button

func _ready():
	if use_alternate_icon:
		alternate_icon.texture = image_to_use
		icon.get_parent().queue_free()
	else:
		icon.texture = image_to_use
