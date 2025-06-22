extends Control

@export var one_halo:Panel
@export var max_count:int = 50

@onready var halo = one_halo.duplicate()
var holograms:Array[Panel] = []

var offsets:Array[Vector2]

var time_since_start:float

var viewport_size:
	get:
		return get_viewport_rect().size

func _ready():
	one_halo.queue_free()
	for panel in max_count:
		var halo_duplicate:Panel = one_halo.duplicate()
		halo_duplicate.global_position = Vector2(viewport_size.x/2,viewport_size.y/2)
		holograms.append(halo_duplicate)
		add_child(halo_duplicate)
		
		# Calculate misc data
		var offset:Vector2 = Vector2(randf_range(100,viewport_size.x),randf_range(100,viewport_size.y))
		offsets.append(offset)
		

func _process(delta):
	time_since_start += delta/20
	
	for halo_panel in holograms:
		var hologram_index:int = holograms.find(halo_panel)
		var position_to_go_x:float = sin(hologram_index + (time_since_start * offsets[hologram_index].length()/55))
		var position_to_go_y:float = cos(hologram_index + (time_since_start * offsets[hologram_index].length()/255))
		var position_to_go:Vector2 = Vector2(position_to_go_x,position_to_go_y)
		halo_panel.position = halo_panel.position.lerp(position_to_go * offsets[hologram_index].length() ,delta)
		
		var halo_panel_shader:ShaderMaterial = halo_panel.get_node("Stripes").material
		var color_to_lerp_to = Color8(28,44,87,int(halo_panel.position.length()))
		halo_panel.modulate = halo_panel.modulate.lerp(color_to_lerp_to,delta * 3)
		halo_panel_shader.set_shader_parameter("color_stripe",halo_panel.modulate.lerp(color_to_lerp_to,delta * 3))
