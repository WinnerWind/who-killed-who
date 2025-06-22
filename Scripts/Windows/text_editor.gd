extends VirtualWindow

@export var padding_size:Vector2 = Vector2(10,10)
@export_multiline var text:String

@export var main_text:RichTextLabel
@export var directory_label:RichTextLabel
func _ready():
	super()
	#$Contents/Margin.size = $Contents.size - padding_size # Reduces size by padding
	#$Contents/Margin.position.x = padding_size.x/2 # Re aligns text according to spacer
	main_text.text = text # Sets the main text content
