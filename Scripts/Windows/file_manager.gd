extends VirtualWindow
class_name FileManagerWindow

@export var sorter:VBoxContainer #Sorting node
@export var file_manager_row:PackedScene #Scene that shows the rows for the file manager
@export var directory_label:PackedScene #Scene that shows the current directory in a label

@export_group("Tuning")
@export var maximum_path_length:int = 45

func _ready():
	titlebar.add_button(titlebar.sorters.LEFT,change_directory.bind(true),&"back_button", "Go Back")
	super()
	call_deferred("read_files")

@onready var files_root_path:String = desktop.files_path #Root in desktop.
var dir_path:String #Returns a simplified and actual dir path
var absolute_dir_path: #Returns absolute directory path in game
	get:
		return files_root_path+"/"+dir_path
var dir_node:VirtualFolder:
	get:
		return get_node(absolute_dir_path) #Returns the directory object

func change_directory(is_going_back:bool, path_appendix:String = ""):
	if not currently_reading_files:
		if is_going_back:
			#Ensures that the new directory is not a parent of the files root path
			if dir_path.find("/") == -1: #Not a subdirectory
				dir_path = "" #Empties it out, effectively making the root.
			else:
				dir_path = dir_path.substr(0, dir_path.rfind("/")).trim_suffix("/").trim_prefix("/") #Goes back to the parent directory
		else: #Must be going forward
			if dir_path.length() == 0: #Checks if its empty, if so, we're in the root.
				dir_path = path_appendix #Just set it as it is
			else:
				dir_path += "/"+path_appendix #Add slash so it can act like a nodepath
		
		#check if it needs to send a toast
		if dir_node.toast_name != "":
			if not is_going_back:
				desktop.notify_send(dir_node.toast_text, dir_node.toast_name)
		
		clear_view()
		await read_files(!is_going_back)
		
		# Send toast after reading all files
		if dir_node.after_delay_toast_name != "":
			desktop.notify_send(dir_node.after_delay_toast_text, dir_node.after_delay_toast_name)

func deal_with_unknown_object(path:String):
	# A function to deal with an object of unknown type.
	var new_object_path:String = dir_path +"/"+path
	var new_object_absolute_path:String = files_root_path +"/"+new_object_path
	var new_object_node:Node = get_node(new_object_absolute_path)
	
	if new_object_node is VirtualFile:
		# Hand off to desktop as its a file
		desktop.hand_over_file(new_object_absolute_path)
		return
	elif new_object_node is VirtualFolder:
		if new_object_node.password == "": #No password
			if new_object_node.custom_type == "":
				change_directory(false,path)
			else: #Deal with permanentally unopenable folders.
				desktop.open_popup("Error!","You cannot open this folder over an Anytable connection")
		else: #Has password
			desktop.open_password_prompt(new_object_absolute_path,new_object_node.password)

func clear_view():
	for row in sorter.get_children():
		row.queue_free()


var currently_reading_files:bool = false
func read_files(enforce_delay:bool = true):
	print("Reading new file")
	currently_reading_files = true
	
	var reading_prefix:String = "Reading... "
	
	# Applies a special reading prefix if it has any
	if not dir_node.special_reading_prefix == "":
		reading_prefix = dir_node.special_reading_prefix
	
	
	var new_directory_label = directory_label.instantiate()
	
	if dir_path == "": #Sitting in root directory
		new_directory_label.text = reading_prefix+">> /"
	else: #Not sitting in root
		new_directory_label.text = reading_prefix+">> "+("/"+dir_path+"/").right(maximum_path_length)
		
	sorter.add_child(new_directory_label)
	if dir_node.get_child_count() == 0: #No children, so add a special label
		var show_empty_label:Label = directory_label.instantiate()
		show_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		show_empty_label.text = "NO FILES HERE!"
		sorter.add_child(show_empty_label)
		new_directory_label.text = ">> "+new_directory_label.text.get_slice(">>",1) #Removes reading prefix as its done
		currently_reading_files = false
		return #End executing early. No need to do anything else.
	
	#Directory has asked for a specific delay
	if dir_node.additional_delay != 0 and not SaveData.ram_save["settings_fm_instant_load"] and enforce_delay:
		await get_tree().create_timer(dir_node.additional_delay).timeout
	
	for object in dir_node.get_children():
		#print(object.name)
		if not SaveData.ram_save["settings_fm_instant_load"]: #Add the requested delay
			await get_tree().create_timer(randf_range(0.005,0.01)).timeout
		make_new_file_manager_row(object.get_index()+1,object.name,object.type,object.modification_date,object.custom_type)
	
	new_directory_label.text = " %s Objects >> %s"%[dir_node.get_child_count(),new_directory_label.text.get_slice(" >> ",1)] #Removes reading prefix as its done
	
	for row in sorter.get_children().slice(1): #Tell the rows that its time to display
		if not row is Label:
			row.ready_to_display = true
	
	currently_reading_files = false #Allows us to go back and stuff after executing has finished.
	
func make_new_file_manager_row(index:int, object_name:String,file_type:int,modification_date:String,custom_type_name:String):
		var new_row:HBoxContainer = file_manager_row.instantiate()
		#new_row.change_dir.connect(read_files) #Connects required signals
		#new_row.clear_view.connect(clear_view)
		#Set Icon
		var icon_to_be_fetched:StringName
		
		new_row.change_dir.connect(deal_with_unknown_object)
		match file_type:
			0: icon_to_be_fetched = &"folder_icon" #Folder
			1: icon_to_be_fetched = &"locked_folder_icon" #Locked Folder
			2: icon_to_be_fetched = &"file_icon" #file
			3: icon_to_be_fetched = &"video_icon" #video
			4: icon_to_be_fetched = &"file_icon" #text document
			5: icon_to_be_fetched = &"image_icon" #image
			6: icon_to_be_fetched = &"audio_icon" #Music
			7: icon_to_be_fetched = &"document_icon" #Document
			8: icon_to_be_fetched = &"file_icon" #unopenable
		
		new_row.get_node("Icon").texture = fetch_icon(icon_to_be_fetched,true)
		new_row.get_node("Index").text = str(index) + "."
		new_row.get_node("Name").text = object_name
		#must be unopenable or has a custom type
		if not custom_type_name == "":  new_row.get_node("Type").text = custom_type_name
		else: new_row.get_node("Type").text = determine_file_type(file_type)
		
		if not modification_date == "": new_row.get_node("Center Container/File Modification Date").text = "[right]"+modification_date
		else: new_row.get_node("Center Container/File Modification Date").text = "[right]<--empty-->"
		
		#adds an extra line if the user wants larger icons. Hack to make the entire thing bigger.
		if SaveData.ram_save["settings_larger_file_manager_icons"]:
				new_row.custom_minimum_size.y += 40 #40 because why not
		sorter.add_child(new_row) #Finally adds the row

func determine_file_type(file_type_index:int):
	match file_type_index:
		0: return "Folder"#Must be FOLDER
		1: return "Locked" #Must be LOCKED_FOLDER
		2: return "File"#Must be FILE
		3: return "Video" #Must be VIDEO
		4: return "Text" #MUST BE TEXT
		5: return "Image" #Must be IMAGE
		6: return "Audio" #Must be AUDIO
		7: return "Document" #Must be DOCUMENT
		8: return "UNOPENABLE"  #must be unopenable

func set_icons():
	super()
	titlebar.custom_titlebar_items[&"back_button"].icon = fetch_icon(&"back")
