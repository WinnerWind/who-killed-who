extends VirtualWindow
# I pray I never have to look at this fucking piece of code ever again
# Worst part is that I had to compromise by setting the fucking image rescaling
# Setting to strech, which actually burns my soul, but there is nothin that we can do
# I'll live with it and adapt.
#Fuck images man
@export var image:CompressedTexture2D

@export var image_node:TextureRect

func _ready():
	titlebar.add_button(titlebar.sorters.LEFT,decrease_size,&"decrease_size","Zoom Out")
	titlebar.add_button(titlebar.sorters.LEFT,increase_size,&"increase_size","Zoom In")
	super()
	#Fixes the image node sizes.
	#image_node.size.y = image.get_size().y/10
	image_node.texture = image
	#image_node.set_deferred("size",size)
	image_node.position.y = titlebar_size+30	
	
func _process(delta):
	super(delta)
	image_node.position = Vector2(0,titlebar_size)
	image_node.size = size
	
func increase_size():
	if not size.x/starting_size.x > 1.5:
		size *= 1.25
func decrease_size():
	if size/1.25 >= starting_size:
		size /= 1.25
	
func game_resized():
	super()
	#image_node.size.y = image.get_size().y/10
	image_node.texture = image
	image_node.size = size
	image_node.position.y = titlebar_size

func set_icons():
	super()
	#Sets titlebar icon
	titlebar.custom_titlebar_items[&"decrease_size"].icon = fetch_icon(&"zoom_out")
	titlebar.custom_titlebar_items[&"increase_size"].icon = fetch_icon(&"zoom_in")
