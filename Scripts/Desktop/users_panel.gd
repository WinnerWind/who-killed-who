extends Node
class_name UsersPanel

@onready var desktop:Desktop = get_owner()

@export var slice:int = 1 #Determines what index onwards to not remove from the panel.
@export var users_row:PackedScene

@export var sorter:BoxContainer
func add_users():
	for user_row in sorter.get_children().slice(slice):
		user_row.queue_free()
		
	for user in desktop.users:
		var new_user_row = users_row.instantiate()
		new_user_row.user = user
		new_user_row.change_user.connect(desktop.change_users)
		sorter.add_child(new_user_row)
