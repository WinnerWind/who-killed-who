@tool
extends Resource
class_name Email

@export_multiline var content:String
@export var subject:String:
	set(new_subject):
		#changed.connect(func(): 
			#set_block_signals(true)
			#resource_name = new_subject
			#set_block_signals(false))
		#changed.emit()
		resource_name = new_subject #Makes it more readable in the editor with 300 resources.
		subject = new_subject
		
@export var sender:String
@export var recipient:String
@export_range(0,23) var hour:int = 0
@export_range(0,59) var minute:int = 0
@export_range(1,31) var day:int = 1
@export_enum("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec") var month:int = 0
@export var year:int = 2025
var date:String:
	get:
		var month_name = func():
			match month:
				0: return "Jan"
				1: return "Feb"
				2: return "Mar"
				3: return "Apr"
				4: return "May"
				5: return "Jun"
				6: return "Jul"
				7: return "Aug"
				8: return "Sep"
				9: return "Oct"
				10: return "Nov"
				11: return "Dec"
		return "%02d %s %d  %02d:%02d"%[day,month_name.call(),year,hour,minute]

var date_comparable:int:
	get:
		var date_time_dict = Time.get_datetime_dict_from_system().duplicate()
		date_time_dict["year"] = year
		date_time_dict["month"] = month+1
		date_time_dict["day"] = day
		date_time_dict["hour"] = hour
		date_time_dict["minute"] = minute
		return Time.get_unix_time_from_datetime_dict(date_time_dict)
