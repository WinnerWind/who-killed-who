extends VirtualWindow

@export var unlockable_users:Array[UserMetadata]

#Compute these three from unlockable_users for easy comparison.
var list_of_passwords:Array[String] 
var list_of_usernames:Array[String]
var list_of_ip_addresses:Array[String]

@export_subgroup("Internal Nodes")
@export var username_input:LineEdit
@export var password_input:LineEdit
@export_subgroup("Internal Nodes/IP Addresses")
@export var ip_address_inputs:HBoxContainer

func _ready():
	super()
	for user in unlockable_users:
		list_of_passwords.append(user.password)
		list_of_usernames.append(user.username)
		list_of_ip_addresses.append(user.ip_address)

func _on_clear_button_pressed():
	for spinbox:SpinBox in ip_address_inputs.get_children():
		spinbox.value = 0
	username_input.text = ""
	password_input.text = ""

func _on_submit_button_pressed():
	var ip_values:Array[int]
	for spinbox:SpinBox in ip_address_inputs.get_children():
		ip_values.append(int(spinbox.value))
		
	var submitted_ip_address:String = "%s.%s.%s.%s"%[ip_values[0],ip_values[1],ip_values[2],ip_values[3]]
	var submitted_username:String = username_input.text
	var submitted_password:String = password_input.text
	
	var password_wrong:bool = false
	var username_wrong:bool = false
	var ip_address_wrong:bool = false
	if not list_of_ip_addresses.has(submitted_ip_address):
		ip_address_wrong = true
	if not list_of_passwords.has(submitted_password):
		password_wrong = true
	if not list_of_usernames.has(submitted_username):
		username_wrong = true
	
	# Evaluate what exactly went wrong
	if not ip_address_wrong: #IP Address is correct
		if username_wrong:
			desktop.open_popup("User not found","There was no user with the username %s on that system."%[submitted_username])
		else: #username is correct
			if password_wrong:
				desktop.open_popup("Incorrect Password","The provided password was wrong")
			else: #everything is correct, so we can add the new user
				var user_to_be_added:UserMetadata = unlockable_users[list_of_ip_addresses.find(submitted_ip_address)] #hacky solution to get the index of the user from the ip addresses, which are hopefully unique.
				desktop.open_popup("Registered the user.","Registration complete.","Success!", fetch_icon(&"user_add"))
				SaveData.register_user(user_to_be_added) #register the user. The savedata script will make the necessary checks.
				desktop.refresh_user_panel()
	else: #ip address is wrong
		desktop.open_popup("No Route to Host","We could not find a route to host. Sorry.","SSH")

#var old_text:String
#var old_caret_position:int
#func sanitize_ip_address_input(new_text:String):
	#var regex = RegEx.new()
	#regex.compile("^[0-9.]*$")
	#if not regex.search(new_text): 
		#ip_address_input.text = old_text 
		#ip_address_input.caret_column = old_caret_position
	#else:
		#old_text = new_text
		#old_caret_position = ip_address_input.caret_column
