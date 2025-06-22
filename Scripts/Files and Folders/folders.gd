@tool
@icon("res://Art/Pictures/Editor Only/li_folder.svg")
extends VirtualObject
## A folder for the virtual file system.

class_name VirtualFolder

@export_tool_button("Add new file as child","File") var add_new_file = add_new_file_as_child
@export_tool_button("Add new folder as child","FolderCreate") var add_new_folder = add_new_folder_as_child
@export_tool_button("Sort Children Alphabetically", "RandomNumberGenerator") var sort_function = sort_children_alphabetically
@export_tool_button("Sort Children Reverse Alphabetically", "RandomNumberGenerator") var rev_sort_function = reverse_sort_children_alphabetically
@export_tool_button("Sort Children Alphabetically Recursively", "RandomNumberGenerator") var rec_sort_function = recursive_sort
@export_tool_button("Sort Children Reverse Alphabetically Recursively", "RandomNumberGenerator") var rev_rec_sort_function = reverse_recursive_sort
func recursive_sort():
	sort_children_alphabetically()
	for child in get_children():
		if child is VirtualFolder:
			child.recursive_sort()

func reverse_recursive_sort():
	reverse_sort_children_alphabetically()
	for child in get_children():
		if child is VirtualFolder:
			child.reverse_recursive_sort()

func sort_children_alphabetically():
	var sorted_children = get_children()
	#sorted_children.sort_custom(func(a,b):return str(a.name) < str(b.name))
	sorted_children.sort_custom(func(a,b):return a.name.naturalnocasecmp_to(b.name) < 0)
	
	for child in get_children():
		move_child(child, sorted_children.find(child))

func reverse_sort_children_alphabetically():
	var sorted_children = get_children()
	sorted_children.sort_custom(func(a,b):return a.name.naturalnocasecmp_to(b.name) > 0)
	
	for child in get_children():
		move_child(child, sorted_children.find(child))

func add_new_file_as_child():
	var new_file = VirtualFile.new()
	add_child(new_file,true)
	new_file.owner = get_tree().edited_scene_root
func add_new_folder_as_child():
	var new_folder = VirtualFolder.new()
	add_child(new_folder,true)
	new_folder.owner = get_tree().edited_scene_root

@export var password:String

@export_subgroup("Misc")
@export_subgroup("Misc/Delays")
@export var additional_delay:float
@export var special_reading_prefix:String
@export_subgroup("Misc/Toast")
@export var toast_name:String
@export var toast_text:String
@export_subgroup("Misc/Toast after Delay")
@export var after_delay_toast_name:String
@export var after_delay_toast_text:String

func _ready():
	if password == "":# no password, so its unlocked
		type = AllTypes.FOLDER
	else:
		type = AllTypes.LOCKEDFOLDER
