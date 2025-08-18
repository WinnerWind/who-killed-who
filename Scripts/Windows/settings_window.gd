extends VirtualWindow
class_name SettingsWindow

## Array of checkbox buttons in order to load the set values.
@export var checkbuttons_array:Array[CheckButton]
@export var current_desktop_theme_checkbutton:CheckButton
@export var option_box_array:Array[OptionButton]

func set_setting(value,key:String):
	if not SaveData.ram_save.has("settings_"+key):
		printerr("Key %s does not exist in the SaveData dictionary!"%["settings_"+key])
	SaveData.ram_save["settings_"+key] = value
	
	SaveData.save() #save immediately


func set_desktop_theme(value:bool):
	desktop.is_dark_theme = value
	SaveData.ram_save[desktop.dictionary_key+"_is_theme_dark"] = value
	SaveData.save()
	desktop.set_desktop_theme()

func change_resolution(index:int):
	DisplayManager.change_resolution(index)
	SaveData.ram_save["settings_display_resolution"] = index
	SaveData.save()

func change_display_type(index:int):
	DisplayManager.change_display_type(index)
	SaveData.ram_save["settings_display_type"] = index
	SaveData.save()

func change_display_scale(index:int):
	DisplayManager.change_display_scale(index)
	SaveData.ram_save["settings_display_scale"] = index
	SaveData.save()

func _ready():
	super()
	for checkbutton:CheckButton in checkbuttons_array:
		#hack to load it directly from the checkbutton name.
		checkbutton.button_pressed = SaveData.ram_save["settings_"+checkbutton.name]
	for optionbox in option_box_array:
		optionbox.selected = SaveData.ram_save["settings_"+optionbox.name]
	#Set button
	call_deferred("set_current_desktop_theme_button")
	
func set_current_desktop_theme_button():
	#special function to set the desktop theme button from the desktop theme setting
	current_desktop_theme_checkbutton.button_pressed = desktop.is_dark_theme
