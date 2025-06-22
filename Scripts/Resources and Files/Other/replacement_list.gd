@tool
extends Resource
class_name ReplacementList
## A resource to store a list of replacements/hotkeys for names and such.

@export var replacements:Dictionary[String,String]

@export_category("Functions")
@export_group("Rename")
@export var key_to_be_renamed:String
@export var rename_key_to:String
@export_tool_button("Run Rename","Rename") var rename_action = run_rename
func run_rename():
	if Engine.is_editor_hint():
		if replacements.has(key_to_be_renamed):
			var replacement_value = replacements[key_to_be_renamed]
			replacements.erase(key_to_be_renamed)
			replacements[rename_key_to] = replacement_value
		else: #Key doesnt exist
			printerr("Key to be renamed not found!")

@export_group("Sort")
@export var key_to_be_moved:String
@export var index_to_be_moved_to:int:
	set(new_value):
		if Engine.is_editor_hint():
			if not new_value >= replacements.size():
				index_to_be_moved_to = new_value
@export_tool_button("Run Re-Sort","Sort") var resort_action = run_re_sort
func run_re_sort():
	if Engine.is_editor_hint():
		var keys = replacements.keys()
		
		if not key_to_be_moved in keys:
			printerr("Key is not in the dictionary")
			return
		
		var original_key_index = keys.find(key_to_be_moved)
		keys.remove_at(original_key_index)
		
		keys.insert(index_to_be_moved_to,key_to_be_moved)
		
		var new_replacements:Dictionary[String, String]
		for key in keys:
			new_replacements[key] = replacements[key]
		replacements = new_replacements.duplicate()
