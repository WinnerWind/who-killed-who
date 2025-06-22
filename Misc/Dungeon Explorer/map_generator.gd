extends GridMap

@export var max_size:Vector2i
@export var distance_to_render:Vector2i
@export var distance_to_clear:float
func _ready():
	for length in max_size.x:
		for breadth in max_size.y:
			var cell_position:Vector3 = Vector3(length - max_size.x/2.0,0,breadth - max_size.y/2.0) #Ensures grid starts in center.
			set_cell_item(cell_position,randi_range(0,1)) #Picks between the wall and rotated wall

func _on_player_on_move_end():
	# Gets player position with respect to the cell size, effectively returning the player position in the grid
	var player_pos_in_grid:Vector2i = Vector2i(snapped(%Player.position.x/cell_size.x,1),snapped(%Player.position.z/cell_size.z,1))
	
	var relative_distance_to_render:Vector2i = player_pos_in_grid + distance_to_render/2
	
	var used_cells:Array[Vector3i] = get_used_cells()
	
	for xblock in distance_to_render.x:
		for yblock in distance_to_render.y:
			var cell_position:Vector3i = Vector3i(-xblock + relative_distance_to_render.x, 0 , -yblock + relative_distance_to_render.y)
			if get_cell_item(cell_position) == INVALID_CELL_ITEM:
				set_cell_item(cell_position,randi_range(0,1))
	
	for cell in used_cells:
		if cell.distance_to(%Player.position/cell_size) >= distance_to_clear:
			set_cell_item(cell,INVALID_CELL_ITEM)
