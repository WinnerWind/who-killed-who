@tool
@icon("Object")
extends Node
## Base class for VirtualFile and Virtual Folder
class_name VirtualObject

@export_tool_button("Add new file as sibling","File") var add_file_action = add_new_file_as_sibling
@export_tool_button("Add new folder as sibling","FolderCreate") var add_folder_action = add_new_folder_as_sibling
func add_new_file_as_sibling():
	var new_file = VirtualFile.new()
	add_sibling(new_file,true)
	new_file.owner = get_tree().edited_scene_root
func add_new_folder_as_sibling():
	var new_folder = VirtualFolder.new()
	add_sibling(new_folder,true)
	new_folder.owner = get_tree().edited_scene_root

# enum 0 and 1 is the reserved type for folders.
enum AllTypes {FOLDER, LOCKEDFOLDER, FILE,VIDEO,TEXT,IMAGE,MUSIC,DOCUMENT,UNOPENABLE}
var type:AllTypes
@export var custom_type:String


# Date and Time
@export var has_date_time:bool = true
@export var use_child_date_time:bool = true

@export_group("Date and Time")
@export_tool_button("Sync time from children", "Time") var sync_function = sync_time_from_children

func sync_time_from_children():
	var children = get_children()
	var array_of_dates:Array[int]
	
	if children.size() == 0:
		return
		
	for child:VirtualObject in children:
		child.sync_time_from_children()
		array_of_dates.append(child.unix_date_time)
	
	# Sort the array so index -1 is the most recent date.
	array_of_dates.sort()
	var dict = Time.get_datetime_dict_from_unix_time(array_of_dates[-1])
	year = dict["year"]-2000
	month = dict["month"]-1
	day = dict["day"]
	hour = dict["hour"]
	minute = dict["minute"]
	
## Follow format DD/MM/YY HH:MM AM/PM
var modification_date:String:
	get:
		if has_date_time:
			return "%02d/%02d/%02d %02d:%02d %s"%[day,month+1,year,hour_formatted,minute,meridian]
		else:
			return ""

var unix_date_time:
	get:
		var dict = {
			"year": year+2000,
			"month": month+1,
			"day": day,
			"hour": hour,
			"minute": minute,
			"second":0
		}
		return Time.get_unix_time_from_datetime_dict(dict)
@export var year:int = 25
@export_enum("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec") var month:int = 0
@export_range(1,31) var day:int = 1
@export_range(0,23) var hour:int = 0
var hour_formatted:int:
	get:
		if SaveData.ram_save["settings_use_24h_clock"]:
			return hour
		else: #use 12 hour clock so format differently
			if hour >12:
				return hour - 12
			else:
				return hour
@export_range(0,59) var minute:int = 0
var meridian:String:
	get:
		if not SaveData.ram_save["settings_use_24h_clock"] and hour >= 12:
			return "PM"
		elif not SaveData.ram_save["settings_use_24h_clock"]:
			return "AM"
		else:
			return ""
