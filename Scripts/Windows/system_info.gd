extends VirtualWindow

@export var title:Label
@export var version:Label
@export var more_information:RichTextLabel
@export var system_icon:TextureRect

func set_icons():
	super()
	system_icon.texture = fetch_icon(&"system_icon",true)
