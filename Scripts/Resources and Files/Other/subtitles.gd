@tool
extends Resource
class_name UnifiedSubtitles

@export var subtitles:Dictionary[int,String]

@export_group("Change Time")
@export var time_to_be_changed:int
@export var change_time_to:int
@export_tool_button("Run Re-time","Time") var rename_action = run_retime
func run_retime():
	if Engine.is_editor_hint():
		if subtitles.has(time_to_be_changed):
			var replacement_value = subtitles[time_to_be_changed]
			if subtitles.has(change_time_to): #Don't delete user subtitle without asking
				printerr("time(%s) already has a subtitle!"%[change_time_to])
			else:
				subtitles.erase(time_to_be_changed)
				subtitles[change_time_to] = replacement_value
		else: #Key doesnt exist
			printerr("The specified time does not exist!")
@export_group("Sort")
@export var key_to_be_moved:int
@export var index_to_be_moved_to:int:
	set(new_value):
		if Engine.is_editor_hint():
			if not new_value >= subtitles.size():
				index_to_be_moved_to = new_value
@export_tool_button("Run Re-Sort","Sort") var resort_action = run_re_sort
@export_tool_button("Sort Numerically","Sort") var sort_action = sort_numerically
func run_re_sort():
	if Engine.is_editor_hint():
		var keys = subtitles.keys()
		
		if not key_to_be_moved in keys:
			printerr("Key is not in the dictionary")
			return
		
		var original_key_index = keys.find(key_to_be_moved)
		keys.remove_at(original_key_index)
		
		keys.insert(index_to_be_moved_to,key_to_be_moved)
		
		var new_replacements:Dictionary[String, String]
		for key in keys:
			new_replacements[key] = subtitles[key]
		subtitles = new_replacements.duplicate()
func sort_numerically():
	var numbers = subtitles.keys()
	numbers.sort_custom(func(a:int,b:int):return a<b)
	
	var new_dictionary:Dictionary[int,String]
	for time in numbers:
		new_dictionary[time] = subtitles[time]
	
	subtitles = new_dictionary.duplicate()
