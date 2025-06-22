extends RichTextLabel

@export var panel:Panel

#region Mouse Input
var mouse_in_panel:bool = false

func _on_panel_mouse_entered():
	# Connect button mouse enter & panel mouse enter
	mouse_in_panel = true

func _on_panel_mouse_exited():
	# Connect button mouse exit & panel mouse exit
	mouse_in_panel = false

@export var animation_player:AnimationPlayer
func _input(_event):
	if Input.is_action_pressed("Click") and not mouse_in_panel:
		animation_player.play("close_animation")

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and not panel.visible: #must be a mouse click, also the event is a press not a release. Also the panel is not viisble
		animation_player.play("open_animation")
	elif event is InputEventMouseButton and event.pressed and panel.visible: #same as before but HIDE if the panel is already shown.
		animation_player.play("close_animation")
#endregion

#region Calendar
@export var month_container:GridContainer
@export var year_label:Label
@export var month_label:Label
var calendar_date = Calendar.Date
var year:int = calendar_date.today().year
var month:int = calendar_date.today().month:
	set(new_amount):
		if new_amount > 12: #tried to exceed the year
			year += 1
			month = 1
		elif new_amount < 1: #tried to go backwards
			year -= 1
			month = 12
		else:
			month = new_amount
		#set text
		year_label.text = str(year)
		month_label.text = calendar.get_month_formatted(month)

var calendar = Calendar.new()
func _ready():
	#animation_player.play("close_animation")
	#set text
	year_label.text = str(year)
	month_label.text = calendar.get_month_formatted(month)
	
	#populate calendar
	populate_calendar()
	
func populate_calendar():
	for label in month_container.get_children(): #clear all children if any
		label.queue_free()
		
	var current_month_days = calendar.get_calendar_month(year,month,true,true)
	
	for week in current_month_days:
		var first_date = week[0]
		var week_number:String = str(calendar.get_week_number(first_date.year,first_date.month,first_date.day))
		var new_week_label = create_new_date_label(week_number)
		new_week_label.theme_type_variation = "WeekNumberLabel"
		month_container.add_child(new_week_label)
		
		for date in week:
			var new_day_label
			new_day_label = create_new_date_label(str(date.day))
			if date.month != month: #not part of current month
				new_day_label.theme_type_variation = "WeekNumberLabel"
			elif str(date) == str(calendar_date.today()): #is today
				new_day_label.theme_type_variation = "TodayDayLabel"
			else: #is not today but is part of current month
				match date.get_weekday():
					0: #Is Sunday
						new_day_label.theme_type_variation = "SundayLabel"
					6: #is Saturday
						new_day_label.theme_type_variation = "SaturdayLabel"
			var weekday_text = func():
				match date.get_weekday():
					Time.WEEKDAY_SUNDAY: return "Sunday"
					Time.WEEKDAY_MONDAY: return "Monday"
					Time.WEEKDAY_TUESDAY: return "Tuesday"
					Time.WEEKDAY_WEDNESDAY: return "Wednesday"
					Time.WEEKDAY_THURSDAY: return "Thursday"
					Time.WEEKDAY_FRIDAY: return "Friday"
					Time.WEEKDAY_SATURDAY: return "Saturday"
					_: return "" #this edge cases prevents a crash for some reason.
			new_day_label.tooltip_text = weekday_text.call()
			
			month_container.add_child(new_day_label)

func _change_year(amount:int = 0):
	year += amount
	year_label.text = str(year)
	populate_calendar()
func _change_month(amount:int = 0):
	month += amount
	month_label.text = calendar.get_month_formatted(month)
	populate_calendar()
	
func create_new_date_label(label_text:String)->Label:
	# function to simplify the process of making a label
	var new_label = Label.new()
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	new_label.text = label_text
	new_label.mouse_filter = Control.MOUSE_FILTER_PASS #Must be PASS so that the tooltip can be displayed
	return new_label

func _on_today_button_pressed():
	year = calendar_date.today().year
	month = calendar_date.today().month
	populate_calendar()

#endregion

#region Clock

func set_time():
	var date_time_dict = Time.get_datetime_dict_from_system()
	var weekday = func():
		# Lambda function to return the weekday in words.
		match date_time_dict["weekday"]:
			0: return "Sunday"
			1: return "Monday"
			2: return "Tuesday"
			3: return "Wednesday"
			4: return "Thursday"
			5: return "Friday"
			6: return "Saturday"
	
	var month_name = func():
		# Lambda function to return the month in words
		match date_time_dict["month"]:
			1: return "Jan"
			2: return "Feb"
			3: return "Mar"
			4: return "Apr"
			5: return "May"
			6: return "Jun"
			7: return "Jul"
			8: return "Aug"
			9: return "Sepr"
			10: return "Oct"
			11: return "Nov"
			12: return "Dec"
	
	var time_string:String
	var hour = date_time_dict["hour"]
	var minute = date_time_dict["minute"]
	var second = date_time_dict["second"]

	if SaveData.ram_save["settings_use_24h_clock"]:
		time_string = "%02d:%02d:%02d"%[hour,minute,second]
	else: #use 12 hour clock
		if hour > 12: #1PM onwards
			time_string = "%02d:%02d:%02d PM"%[hour-12,minute,second]
		elif hour == 12: #Exactly 12PM
			time_string = "%02d:%02d:%02d PM"%[hour,minute,second]
		else: #Before 12PM
			time_string = "%02d:%02d:%02d AM"%[hour,minute,second]
	
	#Sets text
	
	text = "[center][font_size=16]"+time_string+"[p][center]%s, %02d %s %s"% \
	[weekday.call(),date_time_dict["day"],month_name.call(),date_time_dict["year"]]

func _process(_delta):
	set_time()

#endregion
