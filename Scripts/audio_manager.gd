extends Node

func _ready() -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	if SaveData.ram_save["settings_enable_window_sfx"]: AudioServer.set_bus_mute(sfx_index,false)
	else: AudioServer.set_bus_mute(sfx_index,true)
