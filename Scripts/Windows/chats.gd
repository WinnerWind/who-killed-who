extends VirtualWindow

@export var direct_messages:Array[ChatMessage]
@export var group_messages:Array[ChatMessage]

@export_category("Internal")
@export var single_recipient_row:PackedScene
@export_subgroup("Direct Messages")
@export var main_text:RichTextLabel
@export var recipients_sorter:VBoxContainer
@export var message_sender_direct:LineEdit
@export var title_direct:Label
@export_subgroup("Group Messages")
@export var group_main_text:RichTextLabel
@export var groups_sorter:VBoxContainer
@export var message_sender_group:LineEdit
@export var title_group:Label

func _ready():
	super()
	message_sender_group.hide()
	message_sender_direct.hide() #Don't want text on intro
	
	desktop.open_popup("No write permission!","It appears that you do not have write permission on this system. Launching in read-only mode.", "Doctor Konqui")
	# load messages from the desktop.
	direct_messages = desktop.personal_chat_messages
	group_messages = desktop.group_chat_messages
	
	for message in direct_messages: #Deals with all direct messages
		var new_recipient_row:HBoxContainer = single_recipient_row.instantiate()
		new_recipient_row.get_node("Text/Name").text = message.name
		new_recipient_row.get_node("Text/Last Message").text = message.last_message
		new_recipient_row.tooltip_text =  message.name+"\n\n"+message.last_message
		new_recipient_row.get_node("Icon Margins/Icon").texture = message.icon
		new_recipient_row.open_chat.connect(set_main_text)
		new_recipient_row.text = message.content #Sets the text content on the message row itself as it will call upon this node when its time to set the text
		new_recipient_row.username = message.name
		recipients_sorter.add_child(new_recipient_row)
	
	for message in group_messages:
		var new_recipient_row:HBoxContainer = single_recipient_row.instantiate()
		new_recipient_row.get_node("Text/Name").text = message.name
		new_recipient_row.get_node("Text/Last Message").text = message.last_message
		new_recipient_row.tooltip_text = message.name+"\n\n"+message.last_message #so we can hover over it.
		new_recipient_row.get_node("Icon Margins/Icon").texture = message.icon
		new_recipient_row.open_chat.connect(set_main_text)
		new_recipient_row.text = message.content #Sets the text content on the message row itself as it will call upon this node when its time to set the text
		new_recipient_row.username = message.name
		new_recipient_row.is_group = true #Tells them that theyre groups.
		groups_sorter.add_child(new_recipient_row)

@export_category("Replacements")
@export var replacements:ReplacementList
@export var name_replacements:ReplacementList
func set_main_text(username:String,new_text:String, is_group:bool = false):
	# We're using a replacement version of the string to make it 
	# easier to type shit out.
	var replaced_text:String = new_text #start off with new text
	var string_replacements = replacements.replacements
	
	replaced_text = find_dates(replaced_text) #Needs to happen before everything else.
	replaced_text = find_times(replaced_text)
	
	for replacement_trigger in string_replacements.keys():
		#iterate over the replaced text. 
		replaced_text = replaced_text.replace(replacement_trigger,string_replacements[replacement_trigger])
	for name_replacement in name_replacements.replacements.keys():
		replaced_text = replaced_text.replace(name_replacement,name_replacements.replacements[name_replacement])
	
	if is_group:
		group_main_text.text = replaced_text
		title_group.text = username
		message_sender_group.show()
	else:
		main_text.text = replaced_text
		title_direct.text = username
		message_sender_direct.show() #Small inefficiency that this is called every single time the view is changed, but who really cares

func find_dates(source_text:String) -> String:
	const DATEREGEXP = "\n<d.*>" # Selects \n<d 190324>. \n so i can organise better.
	var regex = RegEx.new()
	regex.compile(DATEREGEXP)
	var results = regex.search_all(source_text) # Selects all those with the date format.
	
	for result:RegExMatch in results:
		var date_format_match:String = result.get_string()
		var matched_date:String = date_format_match.trim_suffix("\n<d ").trim_suffix("<d").trim_prefix(">") #Removes the <d and the > so we have just the date.
		#print(matched_date)
		var date_parts:PackedStringArray = matched_date.split("-") #We use ISO date format.
		var year:int = int(date_parts[0])
		var month:int = int(date_parts[1])
		var month_name:Callable = func():
		# Lambda function to return the month in words
			match month:
				1: return "January"
				2: return "February"
				3: return "March"
				4: return "April"
				5: return "May"
				6: return "June"
				7: return "July"
				8: return "August"
				9: return "September"
				10: return "October"
				11: return "November"
				12: return "December"
		var day:int = int(date_parts[2])
		
		var replaced_date:String = "<d> %s %s %s </d>"%[day,month_name.call(),year]
		source_text = source_text.replace(date_format_match,replaced_date)
	
	return source_text

func find_times(source_text:String) -> String:
	const TIMEREGEXP = "<t.*>" # Selects <t 19:70>
	var regex = RegEx.new()
	regex.compile(TIMEREGEXP)
	
	var results = regex.search_all(source_text)
	
	for result:RegExMatch in results:
		var time_format_match:String = result.get_string()
		var matched_time:String = time_format_match.trim_suffix(">").trim_prefix("<t ") #Removes the <d and the > so we have just the date.
		var time_parts:PackedStringArray = matched_time.split(":")
		var hour = int(time_parts[0])
		var hour_formatted = func():
			if SaveData.ram_save["settings_use_24h_clock"]:
				return hour
			else: #use 12 hour clock
				if hour > 12: #1PM onwards
					return hour-12
				elif hour == 12: #Exactly 12PM
					return hour
				elif hour == 0:
					return 12 #12AM
				else: #Before 12PM
					return hour
		var meridian = func():
			if SaveData.ram_save["settings_use_24h_clock"]:
				return ""
			else: #use 12 hour clock
				if hour > 12: #1PM onwards
					return " PM"
				elif hour == 12: #Exactly 12PM
					return " PM"
				else: #Before 12PM
					return " AM"
		var minute = time_parts[1]
		
		var replaced_time = "<t>%s:%s%s</t>"%[hour_formatted.call(),minute,meridian.call()]
		#var replaced_time = "[center] - %s:%s - [/center]"%[hour,minute]
		source_text = source_text.replace(time_format_match,replaced_time)
	return source_text
