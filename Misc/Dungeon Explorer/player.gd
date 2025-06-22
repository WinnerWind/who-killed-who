extends Node3D

@export var forward_raycast:RayCast3D
@export var backward_raycast:RayCast3D

@export_subgroup("Modifiers")
## The distance to travel per button press
@export_custom(PROPERTY_HINT_NONE,"suffix:m") var distance_to_travel:float = 5
## The speed of movement.
@export_custom(PROPERTY_HINT_NONE,"suffix:m/s") var speed:float = 25
## The speed of rotation
@export_custom(PROPERTY_HINT_NONE,"suffix:deg/s") var rotation_speed:float = 360
## The amount to rotate per button press
@export_custom(PROPERTY_HINT_NONE,"suffix:deg") var rotation_angle:float = 90
## Time to wait before player do anything after motion
@export_custom(PROPERTY_HINT_NONE,"suffix:s") var move_cooldown_time:float = 0
## Time to wit before player can do anything after rotation.
@export_custom(PROPERTY_HINT_NONE,"suffix:s") var rotation_cooldown_time:float = 0.05
#@export var distance_to_travel:float = 4
#@export var speed:float = 15
#@export var rotation_speed:float = 6
#@export var rotation_angle:float = 90
#@export var move_cooldown_time:float = 0.05
#@export var rotation_cooldown_time:float = 0.05

var moving:bool #store whether we're still moving
var rotating:bool #'' rotating

var last_move_position:Vector3 #store the position when the last move was taken
var last_rotation:Quaternion #store last rotation

var direction:Vector3 #store direction of current motion
var direction_of_rotation:Vector3 #store direction of current rotation

var move_cooldown:bool #prevents motion if in cooldown


#signals

signal on_move_start
signal on_move_end
## Plays when the movement could not be fulfilled (eg. a wall is in the way)
signal on_move_fail 
signal on_rotation_start
signal on_rotation_end
func _ready():
	forward_raycast.target_position.z = -distance_to_travel
	backward_raycast.target_position.z = distance_to_travel

func _process(delta):
#region Movement
#just do this if movement couldn't be satisfied due to wall or something.
	if (Input.is_action_pressed("Game Forward") or Input.is_action_pressed("Game Backward")) and not move_cooldown and not forward_raycast.get_collider() == null:
		on_move_fail.emit()
	#last check checks so that there isnt a wall or object blocking movement.
	elif Input.is_action_pressed("Game Forward") and not move_cooldown and forward_raycast.get_collider() == null:
		if not moving:
			last_move_position = position
			direction = Vector3.FORWARD
			on_move_start.emit()
		moving = true
		move_cooldown = true
	elif Input.is_action_pressed("Game Backward") and not move_cooldown and backward_raycast.get_collider() == null:
		if not moving: #dont reset it if it's already set
			last_move_position = position
			direction = Vector3.BACK
			on_move_start.emit()
		moving = true
		move_cooldown = true
#endregion
#region Rotation
	if Input.is_action_pressed("Game Right") and not move_cooldown:
		if not rotating:
			last_rotation = quaternion
			direction_of_rotation = Vector3.DOWN
			on_rotation_start.emit()
		rotating = true
		move_cooldown = true
	if Input.is_action_pressed("Game Left") and not move_cooldown:
		if not rotating:
			last_rotation = quaternion
			direction_of_rotation = Vector3.UP
			on_rotation_start.emit()
		rotating = true
		move_cooldown = true
#endregion
		
	if moving:
		translate_object_local(direction*speed*delta)
		check_position()
	elif rotating:
		rotate(direction_of_rotation,deg_to_rad(rotation_speed*delta))
		check_rotation()

func check_position():
	if last_move_position.distance_to(position) >= distance_to_travel: #ensure that we havent crossed the distance
		on_move_end.emit()
		#error correction
		position = last_move_position #sends it back to the previous position
		translate_object_local(distance_to_travel*direction) #moves it
		moving = false
		await get_tree().create_timer(move_cooldown_time).timeout
		move_cooldown = false

func check_rotation():
	if quaternion.angle_to(last_rotation) >= deg_to_rad(rotation_angle):
		on_rotation_end.emit()
		rotating = false
		#error correction by fucking magic
		rotation_degrees.y = snapped(rotation_degrees.y,rotation_angle)
		await get_tree().create_timer(rotation_cooldown_time).timeout #slight delay
		move_cooldown = false
		
		
		#if direction_of_rotation == Vector3.UP: #rotate left, works okay
			#rotation_degrees.y -= fposmod(rotation_degrees.y,90)
		#else: #rotate right
			#rotation_degrees.y += fposmod(-rotation_degrees.y,90)
