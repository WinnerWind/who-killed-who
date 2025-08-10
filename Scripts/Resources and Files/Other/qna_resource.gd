extends Resource
class_name SingleQNA

enum types {TEXTINPUT,MCQ,NUMBERINPUT}
@export var type:types
@export var title:String
@export_group("TextInput")
@export var correct_answer:String
@export var submitted_text:String
@export_group("MCQ")
@export var option1_text:String
@export var option2_text:String
@export var option3_text:String
@export var option4_text:String
@export var option5_text:String
@export var option6_text:String
@export var correct_option:int
@export var submitted_option:int
@export_group("NumberInput")
@export var correct_number:int
@export var submitted_number:int
var is_correct:bool:
	get:
		return (correct_number == submitted_number) and (correct_option == submitted_option) and\
		(correct_answer.to_lower() == submitted_text.to_lower().strip_edges())
