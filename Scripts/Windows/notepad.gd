extends VirtualWindow

@export var save_data_dictionary_key:String
@export var tab_container:TabContainer
func _ready():
	titlebar.add_button(titlebar.sorters.LEFT,_on_save_button_pressed,&"save","Save")
	titlebar.add_button(titlebar.sorters.LEFT,rename_file,&"rename","Rename")
	titlebar.add_button(titlebar.sorters.LEFT,new_file,&"new","New File")
	titlebar.add_button(titlebar.sorters.LEFT,delete_file,&"delete","Delete File")
	super()
	load_files()

func _input(event):
	super(event)
	if event.is_action_pressed("Cycle Tabs"):
		if tab_container.current_tab == tab_container.get_children().size() -1: #we're at the last tab
			tab_container.current_tab = 0
		else:
			tab_container.current_tab += 1

func _on_contents_text_changed(index:int):
	# Who cares about neatness?
	SaveData.ram_save["notepad_data"][index].contents = tab_container.get_child(index).text

func _on_save_button_pressed():
	SaveData.save()
	desktop.notify_send("Saved!","HIPTEXT")


#below two functions saves when window is closed.
func minimize_window():
	SaveData.save()
	super()

func close_window():
	SaveData.save()
	super()

func set_icons():
	super()
	titlebar.custom_titlebar_items[&"save"].icon = fetch_icon(&"save_button")
	titlebar.custom_titlebar_items[&"rename"].icon = fetch_icon(&"rename_button")
	titlebar.custom_titlebar_items[&"new"].icon = fetch_icon(&"new_file_button")
	titlebar.custom_titlebar_items[&"delete"].icon = fetch_icon(&"delete_button")
func _auto_save():
	#automatically saves after the timer runs out.
	SaveData.save()
	desktop.notify_send("Autosaved your notes.","HIPTEXT")

func create_new_file_text(index:int) -> TextEdit:
	# a helper function to create a new TextEdit using some nice settings.
	var new_textedit:TextEdit = TextEdit.new()
	new_textedit.placeholder_text = "^^^ Use that button to save"
	new_textedit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_textedit.scroll_smooth = true
	new_textedit.caret_blink = true
	new_textedit.highlight_current_line = true
	new_textedit.draw_tabs = true
	new_textedit.minimap_draw = true
	new_textedit.minimap_width = 40
	new_textedit.text_changed.connect(_on_contents_text_changed.bind(index))
	return new_textedit

#region File Management
## Below functions manage multiple files, including loading them entirely.
func delete_file():
	var active_file = tab_container.current_tab
	SaveData.ram_save["notepad_active_file"] = active_file
	$Confirmation.show()
	await $Confirmation/VBoxContainer/Yes.pressed #yes has been pressed
	SaveData.ram_save["notepad_data"].remove_at(active_file) #get rid of the file. Godot will handle the movement of everything
	SaveData.save()
	$Confirmation.hide()
	load_files()

func new_file():
	var active_file = tab_container.current_tab
	SaveData.ram_save["notepad_active_file"] = active_file #set the active file number
	SaveData.ram_save["notepad_data"].append(NotepadFile.new().to_dict()) #make a new file
	SaveData.save()
	load_files()

func rename_file():
	var active_file = tab_container.current_tab
	SaveData.ram_save["notepad_active_file"] = active_file
	$"Rename Prompt".show() #prompt user
	var entry:LineEdit = $"Rename Prompt/VBoxContainer/Entry"
	await entry.text_submitted #wait for data to be sent
	SaveData.ram_save["notepad_data"][active_file].file_name = entry.text #set data in the file
	$"Rename Prompt".hide()
	$"Rename Prompt/VBoxContainer/Entry".text = ""
	$"Rename Prompt/VBoxContainer/Entry".grab_focus()
	load_files() #just so that we can see the changes

func load_files():
	for child in tab_container.get_children(): #quickly clear everything just to be safe.
		child.free()

	if SaveData.ram_save["notepad_data"].size() == 0: #there is nothing, so lets make a new file
		SaveData.ram_save["notepad_data"].append(NotepadFile.new().to_dict())
	
	for entry_index in SaveData.ram_save["notepad_data"].size():
		var current_notepad_data:Dictionary = SaveData.ram_save["notepad_data"][entry_index] #get the notepad data from the array which contains everything
		var new_textedit = create_new_file_text(entry_index) 
		tab_container.add_child(new_textedit) #must be done before contents are applied
		new_textedit.name = current_notepad_data.file_name #set name
		new_textedit.text = current_notepad_data.contents #set contents
	
	#below is just for convenience and it doesn't really matter.
	tab_container.current_tab = SaveData.ram_save["notepad_active_file"] #set it to the active file, which godot remembers
#endregion
