extends Resource
class_name UserMetadata

@export var is_part_of_main_game:bool = true
@export var image:CompressedTexture2D
@export var name:String
@export var subtext:String
@export var password:String
@export_file("*.tscn") var scene_path:String
var scene:
	get:
		return load(scene_path)
@export var boot_sequence:BootupSequence
@export var shutdown_sequence:BootupSequence
@export_subgroup("First Time Login")
@export var ip_address:String
@export var username:String
