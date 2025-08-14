extends VirtualWindow

@export var email_list:Array[Email]

@export var email_row:PackedScene

@export var right_side_sorter:VBoxContainer
@export var left_side_sorter:VBoxContainer

@export var email_replacements:ReplacementList
@export var content_replacements:ReplacementList
func _ready():
	super()
	#load emails from the desktop
	email_list = desktop.emails
	
	
	for email in email_list:
		var new_email_row = email_row.instantiate()
		
		new_email_row.mouse_entered.connect(desktop.play_sound.bind("Hover"))
		
		var email_hotkeys = email_replacements.replacements
		var content_hotkeys = content_replacements.replacements
		#Replaces based on hotkeys
		for email_replacement in email_hotkeys.keys():
			email.sender = email.sender.replace(email_replacement,email_hotkeys[email_replacement]) 
			email.recipient = email.recipient.replace(email_replacement,email_hotkeys[email_replacement]) 
		
		for content_replacement in content_hotkeys.keys():
			email.content = email.content.replace(content_replacement,content_hotkeys[content_replacement])
		new_email_row.get_node("Text/Subject").text = email.subject
		new_email_row.get_node("Text/Sender").text = email.sender
		new_email_row.get_node("Text/Date").text = email.date
		new_email_row.open_email.connect(set_main_content)
		# Set all it's variables
		new_email_row.text =  email.content
		new_email_row.sender = email.sender
		new_email_row.recipient = email.recipient
		
		#Set tooltip_text
		new_email_row.tooltip_text = required_tooltip_text(email.subject,email.content)
		
		new_email_row.subject = email.subject
		new_email_row.date = email.date
		right_side_sorter.add_child(new_email_row)
		right_side_sorter.add_child(HSeparator.new()) #Adds seperator too because it looks ugly

func required_tooltip_text(subject:String, text:String):
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_length:int = 50
	var subject_length:int = 25
	#below 2 if statements adds elipsis if the text is too long.
	if subject.length() >= subject_length:
		subject = subject.left(subject_length) + "..."
	if text.length() >= text_length:
		text = text.left(text_length) + "..."
	return subject + "\n\n" + regex.sub(text,"",true)

func set_main_content(content:String,sender:String,recipient:String,subject:String,date:String):
	left_side_sorter.get_node("Subject").text = "Subject: "+subject
	left_side_sorter.get_node("To").text = "To: "+recipient
	left_side_sorter.get_node("From").text = "From: "+sender
	left_side_sorter.get_node("Date").text = "On: "+date
	left_side_sorter.get_node("Main Text").text = content

func compose_button_pressed():
	desktop.open_popup("Could not write to Drafts","Your user is missing the required permission to write files.","Tsunderebird")
