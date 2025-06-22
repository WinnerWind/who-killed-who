extends VirtualWindow
class_name DocumentViewer

@export var images_array:Array[CompressedTexture2D]
@export var doc_name:String
@export_group("Nodes")
@export var pages_container:VBoxContainer
@export var page_number_node:Label
@export var doc_name_node:Label
var page_height:int = 390 #Should be calculated but i couldnt figure out how. Apparantly its always 390.
func _ready():
	super()
	
	doc_name_node.text = doc_name+".ods"
	for page in images_array:
		make_new_imagecontainer(page)
func _process(delta):
	super(delta)
	page_number_node.text = "Page %s of %s"%[calculate_page_number(),images_array.size()]
func calculate_page_number():
	var scrollbar:VScrollBar = pages_container.get_parent().get_v_scroll_bar()
	var page_number:int = snappedi(scrollbar.value/page_height,1)+1 #+1 so we get the correct aswer
	return page_number
func make_new_imagecontainer(image:CompressedTexture2D):
	var new_texturerect = TextureRect.new()
	# set settings
	new_texturerect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	new_texturerect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	new_texturerect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pages_container.add_child(new_texturerect)
	new_texturerect.texture = image
