extends Node

var save_path = "user://savedata.save" #Path of savedata
var save_backup_path = "user://savedata.savebak"

#Also acts as default save values.
var ram_save = {
	"notepad_data": [], 
	"notepad_active_file": 0,
	"users": [],
	# DEFINE DEFAULT THEME
	"demo_personal_user_is_theme_dark": false,
	"demo_robert_is_theme_dark": true,
	"user1_is_theme_dark": true,
	"ranmara_is_theme_dark": true,
	"satsu_is_theme_dark": false,
	"jeremy_is_theme_dark": true,
	"romila_is_theme_dark": true,
	"tutorial_is_theme_dark": false,
	# DEFINE SETTINGS:
	"settings_rollover_window_focus": false, #Focus windows on mouse hover only
	"settings_fm_instant_load" : false, #File manager loads entries instantly
	"settings_desktop_use_default_theme" : true, #Use whatever theme is defined by desktop
	"settings_use_24h_clock": false, #24h clock
	"settings_larger_file_manager_icons": false, #Larger icons
	"settings_display_resolution": 3, #Resolution from drop down selected by user
	"settings_display_type": 0, #Display type to be selected by user
	"settings_display_scale": 1.0, #Display scale.
	"settings_subtitles_shown": false, #Are subtitles shown
	"settings_subtitles_use_cc": false, #Are Closed Captions and on screen descriptons shown
	"settings_subtitles_show_names": false, #Show speaker names
	"settings_enable_window_sfx": true #Defines whether to play misc window sfx for opening closing etc.
}: #SaveData currently being accessed by the game
	set(new_save):
		ram_save = new_save
		SaveData.save()

var disk_save #SaveData from the system, on disk
func save():
	# Function to copy ram_save into disk_save
	#Make a backup
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		dir.copy(save_path,save_backup_path)
	
	disk_save = FileAccess.open(save_path,FileAccess.WRITE)
	disk_save.store_var(ram_save)
	disk_save.close()
	AudioManager._ready()

func delete_save():
	#Function to delete the save
	DirAccess.remove_absolute(save_path)

func load_save():
	if FileAccess.file_exists(save_path):
		disk_save = FileAccess.open(save_path,FileAccess.READ) #Open the disk save and save it
		
		var temp_save:Dictionary = disk_save.get_var()
		
		#Prevents conflict
		if not temp_save.keys() == ram_save.keys(): #Some keys are missing.
			var missing_keys:Array = ram_save.keys() #Assume all keys are missing
			for key in ram_save.keys():
				if temp_save.has(key):
					missing_keys.erase(key) #Erase the keys one by one which already exist.
			
			for key in missing_keys:
				temp_save[key] = ram_save[key] #Set them to be the default value.
		
		ram_save = temp_save # read from file. Also make ramsave = disksave, hence loading it.
		
		disk_save.close() #Close the disk save as we don't need it.
		user_id_list = ram_save["users"].duplicate()
		for id in user_id_list:
			user_list.append(load(all_user_ids[id]))
	else: #Save doesnt exist so just make one, lol
		save()


func _ready():
	#delete_save()
	load_save()
	DisplayManager.change_display_type(ram_save["settings_display_type"])
	DisplayManager.change_resolution(ram_save["settings_display_resolution"])
	DisplayManager.change_display_scale(ram_save["settings_display_scale"])

#region Game Specfic Functions
var user_id_list:Array[int] = []
var all_user_ids:Dictionary[int,String] = {
	#0: "res://Data and Resources/Users/demo_personal_computer.tres",
	#1: "res://Data and Resources/Users/demo_robert.tres",
	0: "res://Data and Resources/Users/ranmara.tres",
	1: "res://Data and Resources/Users/romila.tres",
	2: "res://Data and Resources/Users/jeremy.tres",
	3: "res://Data and Resources/Users/satsu.tres",
	4: "res://Data and Resources/Users/tutorial.tres",
}
var user_list:Array[UserMetadata]:
	get:
		var returning_array:Array[UserMetadata]
		for user_id in user_id_list:
			returning_array.append(load(all_user_ids[user_id]))
		return returning_array
var game_users:Array[UserMetadata]:
	get:
		var allowed_users:Array[UserMetadata]
		for user in user_list:
			if user.is_part_of_main_game:
				allowed_users.append(user)
		return allowed_users

var user_scene_path_list:Array[String]:
	get:
		var returning_path_list:Array[String]
		for user in user_list:
			returning_path_list.append(user.scene_path)
		return returning_path_list

func register_user(user:UserMetadata):
	if not user_id_list.has(all_user_ids.find_key(user.resource_path)): #make sure that it already is not in the array
		user_id_list.append(all_user_ids.find_key(user.resource_path))
	ram_save["users"] = user_id_list.duplicate() #save it to ram data
	SaveData.save() #save the ram to disk
#endregion
