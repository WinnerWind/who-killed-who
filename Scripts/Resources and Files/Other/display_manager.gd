extends Node

@export var set_resolutions:bool = true
@export var display_resolutions:Array[Vector2]
@export var display_scales:Array[float]

func change_resolution(index:int):
	if set_resolutions:
		var viewport:Viewport = get_viewport()
		var window:Viewport = get_tree().root
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		get_window().size = Vector2.ONE*900
		var resolution:Vector2 = display_resolutions[index]
		viewport.set_content_scale_size(resolution)
		viewport.content_scale_factor = display_scales[index]
		window.size = resolution

func change_display_type(index:int):
	if set_resolutions:
		var display_modes = [Window.MODE_WINDOWED,Window.MODE_FULLSCREEN,Window.MODE_EXCLUSIVE_FULLSCREEN]
		get_window().mode = display_modes[index]
		SaveData.ram_save["settings_display_type"] = index
		SaveData.save()
