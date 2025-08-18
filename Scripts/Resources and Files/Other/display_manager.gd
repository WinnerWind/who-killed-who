extends Node

@export var set_resolutions:bool = true
@export var display_resolutions:Array[Vector2]
@export var display_scales_with_resolutions:Array[float]
@export var custom_display_scales:Array[float]

func change_resolution(index:int):
	if set_resolutions:
		var viewport:Viewport = get_viewport()
		var window:Viewport = get_tree().root
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		get_window().size = Vector2.ONE*900
		var resolution:Vector2 = display_resolutions[index]
		viewport.set_content_scale_size(resolution)
		viewport.content_scale_factor = display_scales_with_resolutions[index]
		window.size = resolution

func change_display_type(index:int):
	var display_modes = [Window.MODE_WINDOWED,Window.MODE_FULLSCREEN,Window.MODE_EXCLUSIVE_FULLSCREEN]
	get_window().mode = display_modes[index]
	print(display_modes[index] as Window.Mode)
	SaveData.ram_save["settings_display_type"] = index
	SaveData.save()

func change_display_scale(index:int):
	get_viewport().content_scale_factor = custom_display_scales[index]
	SaveData.ram_save["settings_display_scale"] = index
	SaveData.save()
