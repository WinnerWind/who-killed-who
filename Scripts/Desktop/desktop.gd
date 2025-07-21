@tool
@icon("res://Art/Pictures/Editor Only/desktop.svg")
extends Control
class_name Desktop

@export var theme_switch_nodes:Array[Control]
## Do this clockwise, starting from top. [br] Top, Right, Bottom, Left
@export var active_edges:Array[int] = [1,1,1,1] #Store active edges to be used for window to be moved into the viewprt.
@export var app_icon_container:BoxContainer
@export var wallpaper_node:TextureRect
@export var users_panel:UsersPanel
@export var dictionary_key:String
@export_subgroup("Icons And Themes")
## Use this theme when the user is using Light Mode
@export var light_theme:Theme
## Use this theme when the user is using Dark Mode
@export var dark_theme:Theme

@export var light_icons:DesktopIcons
@export var dark_icons:DesktopIcons

@export var is_dark_theme:bool
#use for savedata
@export var is_default_dark_theme:bool

@export var use_inverted_icons_when_titlebar_focused:bool

@export var use_alternate_icon_for_power_prompt:bool
@export_subgroup("System Information")
@export var system_name:String
@export var system_version:String
@export_multiline var system_information:String


@export_subgroup("User Data")
var users:Array[UserMetadata]
@export var current_user:UserMetadata
@export var chat_username:String
@export var chat_realname:String
@export var personal_chat_messages:Array[ChatMessage]:
	get:
		if not Engine.is_editor_hint():
			var returning_chat_messages:Array[ChatMessage] = personal_chat_messages.duplicate()
			for message in returning_chat_messages:
				message.content = message.content.replace(chat_username,"$m") # Replaces all instances of chat username with the [ME]: Label
				# Makes it so that the same resource can store the chat data for Person A and
				# Person B and shows Person A's name if Person B is viewing the chat and vice
				# versa
				if message.name == chat_realname:
					message.name = message.alternate_name
			return returning_chat_messages
		else:
			return personal_chat_messages
@export var group_chat_messages:Array[ChatMessage]:
	get:
		if not Engine.is_editor_hint():
			var returning_chat_messages:Array[ChatMessage] = group_chat_messages.duplicate()
			for message in returning_chat_messages:
				message.content = message.content.replace(chat_username,"$m") # Replaces all instances of chat username with the [ME]: Label
				# Shouldn't be needed but just in case.
				if message.name == chat_realname:
					message.name = message.alternate_name
			return returning_chat_messages
		else:
			return group_chat_messages

@export_tool_button("Sort Emails by Date (Oldest -> Newest)","RandomNumberGenerator") var email_sort_action = _sort_emails_by_date
@export_tool_button("Sort Emails by Date (Newest -> Oldest)","RandomNumberGenerator") var email_sort_reverse = _sort_emails_by_date_reverse
func _sort_emails_by_date():
	emails.sort_custom(func(email1:Email,email2:Email): return email1.date_comparable<email2.date_comparable)
	print("Sorted!")
func _sort_emails_by_date_reverse():
	emails.sort_custom(func(email1:Email,email2:Email): return email1.date_comparable>email2.date_comparable)
	print("Sorted!")
@export var emails:Array[Email]

#Define all windows
@export_subgroup("Windows")
@export var file_manager_window:PackedScene
@export var image_viewer_window:PackedScene
@export var text_viewer_window:PackedScene
@export var video_player_window:PackedScene
@export var music_player_window:PackedScene
@export var document_viewer_window:PackedScene
@export var chat_app_window:PackedScene
@export var email_app_window:PackedScene
@export var calculator_window:PackedScene
@export var system_information_window:PackedScene
@export var settings_window:PackedScene
@export var notepad_window:PackedScene
@export var remote_connection_window:PackedScene
@export var game_list_window:PackedScene
@export var web_radio_window:PackedScene
@export var answer_input_window:PackedScene
@export_subgroup("Windows/Games")
@export var dungeon_explorer:PackedScene
@export var dungeon_explorer_autoplay:PackedScene

@export_subgroup("Misc. Windows and Icons")
@export var virtual_notification:PackedScene
@export var popup:PackedScene
@export var password_prompt:PackedScene
@export var app_tray_icon:PackedScene
@export var users_password_prompt:PackedScene
@export_file("*.tscn") var bootup_scene_path:String
var bootup_scene:
	get:
		return load(bootup_scene_path)
@export var power_prompt:PackedScene
@export var login_scene:PackedScene

var array_of_windows:Array[VirtualWindow] #An array of every single window in game
var previous_array_of_windows:Array[VirtualWindow] #An array of every window in the game for the last frame to be used for comparisons

func _ready():
	if not Engine.is_editor_hint():
		sfx_node = %SFX #Do it here so it doesnt trigger on editor start
		
		# Get users from savedata
		refresh_user_panel()
		SaveData.register_user(current_user) #Just to be safe
		
		if SaveData.ram_save["settings_desktop_use_default_theme"]: #use default theme
			if is_default_dark_theme: #default is the dark theme
				is_dark_theme = true
			else:
				is_dark_theme = false #default is the light theme
		else: #revert back to whatever they were using
			if SaveData.ram_save[dictionary_key+"_is_theme_dark"]: #use dark theme
				is_dark_theme = true
			else:
				is_dark_theme = false
		
		set_desktop_theme()
		
		
		$AnimationPlayer.play("intro_animation") #Play intro animation
	

#region App Behavior
@onready var files_path:String = %Files.get_path()
func hand_over_file(path:String):
	var actual_file:VirtualFile = get_node(path)
	if actual_file == null: #Quit early if the file is not found.
		open_popup("File not found","The file this links to was not found.")
		return
	
	var all_file_types = actual_file.AllTypes
	# Determines type
	var new_window:VirtualWindow

	if actual_file.type == all_file_types.VIDEO: #Must be a video
		new_window = video_player_window.instantiate()
		new_window.video = actual_file.video
		new_window.subtitles = actual_file.video_subtitles
		
		
	elif actual_file.type == all_file_types.IMAGE:
		new_window = image_viewer_window.instantiate()
		new_window.image = actual_file.image
		new_window.location = actual_file.name
		
	elif actual_file.type == all_file_types.TEXT:
		new_window = text_viewer_window.instantiate()
		new_window.text = actual_file.text
		new_window.directory_label.text = ">> "+str(actual_file.get_path()).trim_prefix("/root/"+name+"/Files") + ".txt"
		
		
	elif actual_file.type == all_file_types.MUSIC:
		new_window = music_player_window.instantiate()
		new_window.audio = actual_file.music
		new_window.audio_subtitles = actual_file.audio_subtitles
		if not actual_file.title == "":
			new_window.title = actual_file.title
		else:
			new_window.title = "/"+str(get_node(files_path).get_path_to(actual_file)) + ".mp3" #/root/name/files so that we can rename the root node without shit breaking
		new_window.subtitle = actual_file.subtitle
		new_window.modification_date = actual_file.modification_date
		
		#Check is here so that it can properly override the image
		if not actual_file.icon ==null: #If it is null, keep the image default as defined in the scene itself
			new_window.image = actual_file.icon
			
	elif actual_file.type == all_file_types.DOCUMENT:
		new_window = document_viewer_window.instantiate()
		new_window.images_array = actual_file.document
		new_window.doc_name = actual_file.name
	
	# Deal with placeholder AND custom, unopenable files.
	elif actual_file.type == all_file_types.UNOPENABLE or actual_file.type == all_file_types.FILE: 
		open_popup("Error!","You cannot open this file over an Anytable connection")

	if not new_window == null:
		new_window.desktop = self
		add_child(new_window,true)

var sfx_node:Node
func play_sound(sound_name:StringName):
	var sound_path = StringName(sound_name)
	sfx_node.get_node(sound_path).play()

func notify_send(text:String, app_name:String = "Notification"):
	var notification_container = $"Notifications Container" #Just for neatness
	var new_notification:Panel = virtual_notification.instantiate()
	new_notification.position.y += notification_container.get_children().size() * 125 #Moves them according to the number of notifications
	new_notification.title.text = app_name	
	new_notification.app_text.text = text 
	new_notification.image.texture = fetch_icon(&"notification_icon")
	notification_container.add_child(new_notification,true) #Adds the child

func open_popup(title:String,subtitle:String,titlebar_text:String = "Alert!",image:CompressedTexture2D = null):
	var new_popup:VirtualWindow = popup.instantiate()
	new_popup.title.text = title
	new_popup.subtitle.text = subtitle
	if not image == null:
		new_popup.image_node.texture = image
	else:
		new_popup.image_node.texture = fetch_icon(&"stop")
	new_popup.desktop = self
	new_popup.icon = image
	add_child(new_popup,true)
	new_popup.change_titlebar_text(titlebar_text)

func open_password_prompt(location:String,correct_password:String):	
	var new_prompt:VirtualWindow = password_prompt.instantiate()
	new_prompt.body_text.text = "Authentication is required to access [code]" + location.trim_prefix("/root/"+name+"/Files") + "[/code]\nPlease provide the required password."
	new_prompt.correct_password = correct_password
	new_prompt.path = location
	new_prompt.desktop = self
	add_child(new_prompt,true)
	

func open_file_manager(path:String):
	var new_file_manager:VirtualWindow = file_manager_window.instantiate()
	new_file_manager.desktop = self
	new_file_manager.absolute_dir_path = path
	new_file_manager.dir_path = get_node(files_path).get_path_to(get_node(path))
	add_child(new_file_manager,true)
	#if suppress_prompt:
		#new_file_manager.suppress_prompt = true #Enables suppress prompt so that some logic can be done
		#new_file_manager.change_titlebar_text("Admin File Manager")
	#await get_tree().create_timer(1.0).timeout
	#new_file_manager.directory_to_be_read_path = path
	#new_file_manager.clear_view()
	#new_file_manager.read_files()
	#new_file_manager.suppress_prompt = false
	
#endregion


func _process(_delta):
	# Who cares about minor inefficiencies?
	# Ensures it runs in the game only.
	if not Engine.is_editor_hint():
		get_windows()
		$Panels.move_to_front() # Makes sure it's over everything else, including the windows
		$"Notifications Container".move_to_front()
	
#region Window Management
func get_windows() ->void:
	#A function to quickly get all the available windows
	array_of_windows = [] #Also ensures that its empty when we start checking
	for node in get_children():
		if node is VirtualWindow:
			array_of_windows.append(node)
	# If the previous array of windows has changed, fix the tray too
	if not previous_array_of_windows == array_of_windows: #must've changed
		add_to_tray()
		previous_array_of_windows = array_of_windows
	else:
		pass

func add_to_tray():
	#A function to add all available windows to the tray, because yay
	for app_icon in app_icon_container.get_children():
		#Clears all icons
		app_icon.queue_free()
		
	array_of_windows.reverse() #Reverses the array so that the top most button is the most recently selected window
	for window in array_of_windows:
		var new_icon:Control = app_tray_icon.instantiate()
		new_icon.tooltip_text = window.name
		new_icon.icon = window.icon
		new_icon.associated_window = window.get_path()
		new_icon.desktop = self
		app_icon_container.add_child(new_icon)
	array_of_windows.reverse() #reverses back so that it doesn't fuck up with adding them back. Not doing this causes the array to be different when being checked in get_windows()
		

func unfocus_other_windows():
	for window:VirtualWindow in array_of_windows:
		window.unfocus_window()

func open_window(type:int):
	# Opens a window
	# Meant to be used for the Desktop Icons
	# Also handles logic for literally everything.
	# Efficient? No. Easy to code? Hell yeah
	var window_to_start:VirtualWindow
	match type:
		0: #File Manager
			window_to_start = file_manager_window.instantiate()
		1: #Chat App
			window_to_start = chat_app_window.instantiate()
		2: #email
			window_to_start = email_app_window.instantiate()
		3: #calculator
			window_to_start = calculator_window.instantiate()
		4: #System infromation. Do not ask why this is at index 4.
			var new_system_info_window = system_information_window.instantiate()
			new_system_info_window.title.text = system_name
			new_system_info_window.version.text = system_version
			new_system_info_window.more_information.text = system_information
			new_system_info_window.system_icon.texture = fetch_icon(&"system_icon")
			window_to_start = new_system_info_window
		5: #starts new settings window
			window_to_start = settings_window.instantiate()
		6: #notepad
			var notepad_window_name:String = notepad_window.instantiate().name
			if get_node_or_null(notepad_window_name) == null: #checks if an instance is already open
				window_to_start = notepad_window.instantiate()
			else:
				notify_send("You cannot have multiple instances of HIPTEXT","HIPTEXT")
		7: #ssh
			window_to_start = remote_connection_window.instantiate()
		8: #game list
			window_to_start = game_list_window.instantiate()
		9:
			window_to_start = answer_input_window.instantiate()
		10:
			window_to_start = web_radio_window.instantiate()
			
		101: #dungeon explorer
			window_to_start = dungeon_explorer.instantiate()
		102: #Autoplay dungeon explorer
			window_to_start = dungeon_explorer_autoplay.instantiate()
	if not window_to_start == null: #Safety check in case HIPTEXT was clicked twice
		window_to_start.desktop = self
	add_child(window_to_start,true)
#endregion

func change_users(user:UserMetadata):
	var new_password_window = users_password_prompt.instantiate()
	var new_password_window_script = new_password_window.get_node("Panel")
	# Set all the images and stuff
	new_password_window_script.image_node.texture = user.image
	new_password_window_script.name_label.text = user.username
	new_password_window_script.subtext_label.text = user.subtext
	add_child(new_password_window)
	# Wait for password to be given using await.
	# I'm so smart!
	var submitted_password = await new_password_window_script.input.text_submitted
	
	if submitted_password == user.password: #password correct
		new_password_window.queue_free()
		$AnimationPlayer.play("outro_animation")
		await $AnimationPlayer.animation_finished #Wait for animation to finish.
		
		# scene thingamagic
		# gets this from user row 
		var new_bootup = bootup_scene.instantiate()
		new_bootup.sequence = user.boot_sequence
		new_bootup.scene_to_start = user.scene
		get_tree().root.add_child(new_bootup)
		queue_free() #Time to be removed.
		
	else: #password must be wrong
		new_password_window.queue_free()
		notify_send("Password incorrect!","Authentication")

func refresh_user_panel():
	# Get users from savedata
	for user:UserMetadata in SaveData.user_list:
		if not user.scene.get_state().get_node_name(0) == name: #Checks that the scene is not our own's scene. That causes recursion.
			users.append(user)
	
	users_panel.add_users()

func power_strip_pressed(type:StringName,user:UserMetadata = null):
	for child in get_children():
		if child.name == "Power Prompt":
			child.free() #clears all previous power prompts
			
	var new_prompt = power_prompt.instantiate() #make new prompt
	var new_bootup = bootup_scene.instantiate() #prepare for bootup too
	
	var prompt_script = new_prompt.get_node("Panel") as Panel
	
	prompt_script.no_button.pressed.connect(new_prompt.queue_free) #Tell it to queue free if user says no
	
	#set icon
	prompt_script.image_to_use = fetch_icon(type)
	
	prompt_script.use_alternate_icon = use_alternate_icon_for_power_prompt
	match type: 
		&"power_off": #power off
			prompt_script.title.text = "Power Off?"
			new_bootup.sequence = current_user.shutdown_sequence
			new_bootup.scene_to_start = null
			prompt_script.main_text.text = "Are you sure you want to end your session and shut down?"
		&"restart": #restart
			prompt_script.title.text = "Restart?"
			new_bootup.sequence = current_user.boot_sequence
			new_bootup.scene_to_start = current_user.scene
			prompt_script.main_text.text = "Are you sure you want to restart? Your work will not be saved."
		&"logout": #logout
			prompt_script.title.text = "Logout?"
			new_bootup = login_scene.instantiate() #hackt o instantiate the login scene instead.
			prompt_script.main_text.text = "End your session and change users?"
		&"ending": #Special just for endings.
			prompt_script.title.text = "You must log-out."
			new_bootup.sequence = user.boot_sequence
			new_bootup.scene_to_start = user.scene
			prompt_script.main_text.text = "You must log out and see the ending."
	add_child(new_prompt) #show prompt
	
	await prompt_script.yes_button.pressed #when pressed, do below
	
	#get rid of prompt
	new_prompt.queue_free()
	
	#animate out
	for window in array_of_windows:
		window.close_window()
	$AnimationPlayer.play("outro_animation")
	await $AnimationPlayer.animation_finished #Wait for animation to finish.
	
	#prepare bootdown
	get_tree().root.add_child(new_bootup)
	queue_free() #Time to be removed.

func _on_theme_changed():
	for node in theme_switch_nodes:
		#cheap way of getting the icon from its name. Just remember to set the names accordingly.
		node.icon = fetch_icon(node.name)
	call_deferred("add_to_tray")

func set_desktop_theme():
	#set theme according to theme settings.
	if is_dark_theme:
		theme = dark_theme
		wallpaper_node.texture = fetch_icon(&"wallpaper")
	else:
		theme = light_theme
		wallpaper_node.texture = fetch_icon(&"wallpaper")

func fetch_icon(icon_name:StringName) -> CompressedTexture2D:
	if is_dark_theme:
		return dark_icons.get(icon_name)
	else:
		return light_icons.get(icon_name)
