extends Control

var users:Array[UserMetadata]

@export var default_user:UserMetadata
@export_category("Internal")
@export var users_row:PackedScene
@export_file("*.tscn") var bootup_scene_path:String
@export var user_container:VBoxContainer
@export var login_container:VBoxContainer
@export var login_image:TextureRect
@export var login_name:Label
@export var login_subtitle:Label
@onready var login_password_node = $MarginContainer/HBoxContainer/Login/Password

func _ready():
	SaveData.register_user(default_user) #Just to be safe, and to make sure that the player has at least ONE user
	for user:UserMetadata in SaveData.user_list:
		if not user.scene.get_state().get_node_name(0) == name: #Checks that the scene is not our own's scene. That causes recursion.
			users.append(user)
			
	for user in users:
		var new_user_row = users_row.instantiate()
		new_user_row.user = user #Sets user
		new_user_row.change_user.connect(change_users) #We're gonnat ake the data from here
		user_container.add_child(new_user_row)
	$AnimationPlayer.play("intro_animation")

var current_user:UserMetadata
func change_users(user:UserMetadata):
	current_user = user #Swaps current user
	
	login_container.show()
	$"MarginContainer/HBoxContainer/Incorrect Password".hide() #Hides the incorrect password prompt
	login_name.text = current_user.name
	login_subtitle.text = current_user.subtext
	login_image.texture = current_user.image
	if current_user.password == "": #User has no password, so login directly using a button
		var new_button = Button.new()
		new_button.text = "Login"
		new_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_button.pressed.connect(login_button_pressed)
		login_password_node.replace_by(new_button) #Change it to a button
		login_password_node = new_button #Doing this allows us to refer to it again.
		
	else: #password is not empty, so the user has a password.
		var new_lineedit = LineEdit.new()
		new_lineedit.placeholder_text = "Password Here"
		new_lineedit.secret = true
		new_lineedit.text_submitted.connect(password_submitted)
		login_password_node.replace_by(new_lineedit) #Change it to a lineEdit
		login_password_node = new_lineedit

func login_button_pressed():
	animate_out_and_change_scene(current_user.boot_sequence,current_user.scene)

func password_submitted(password:String):
	if password == current_user.password:
		animate_out_and_change_scene(current_user.boot_sequence,current_user.scene)
	else: #password is wrong
		$"MarginContainer/HBoxContainer/Incorrect Password".show()
		$"MarginContainer/HBoxContainer/Incorrect Password/Timer".start()
		login_password_node.text = "" #Empties the text
		login_container.hide()
		
func animate_out_and_change_scene(boot_sequence:BootupSequence,scene:PackedScene): #Recieves data from change_users
	$AnimationPlayer.play("outro_animation")
	await $AnimationPlayer.animation_finished #Wait for it to finish		
	var new_bootup = load(bootup_scene_path).instantiate()
	new_bootup.sequence = boot_sequence
	new_bootup.scene_to_start = scene
	get_tree().root.add_child(new_bootup)
	queue_free() #Time to be removed.
