@tool
@icon("res://Art/Pictures/Editor Only/file.svg")
extends VirtualObject
## A file for the virtual file system. Note that adding a sub node to a VirtualFile will make all subnodes unreachable.

class_name VirtualFile

# Video and shit data
@export_group("Contents")
@export_multiline var text:String
@export var video:VideoStream 
@export var image:CompressedTexture2D
@export var music:AudioStream
@export var document:Array[CompressedTexture2D]

@export_group("Music Properties") 
@export var title:String
@export var subtitle:String
@export var icon:CompressedTexture2D
@export var audio_subtitles:UnifiedSubtitles

@export_group("Video Properties")
@export var video_subtitles:UnifiedSubtitles

func _ready():
	if audio_subtitles == null:
		audio_subtitles = UnifiedSubtitles.new()
	if video_subtitles == null:
		video_subtitles = UnifiedSubtitles.new()
	# Determine file type automatically because I am too lazy to do it in the inspector
	# Remember to not set the two properties of one file at once!
	if not video == null: #Video is not null so it must be a video
		type = AllTypes.VIDEO
	elif not text == "": #Text is not null so it must be text
		type = AllTypes.TEXT
	elif not image == null: # Too lazy to write, you know the drill
		type = AllTypes.IMAGE
	elif not music == null:
		type = AllTypes.MUSIC
	elif not document == []:
		type = AllTypes.DOCUMENT
	elif not custom_type == "": #Customt ype is set so ignore everything else and do this
		type = AllTypes.UNOPENABLE
	else:
		type = AllTypes.FILE
