@tool
extends Resource
class_name ChatMessage

@export_multiline var content:String
@export var icon:CompressedTexture2D
@export var name:String:
	set(new_name):
		name = new_name
		resource_name = new_name + " - " + alternate_name #Makes it more readable in the editor with 300 resources.
@export var alternate_name:String #Use this in case the name of the desktop matches, eg. personal chats.
@export var last_message:String
