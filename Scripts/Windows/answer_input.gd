extends VirtualWindow

@export var questions:Array[SingleQNA]
var current_question:SingleQNA:
	get:
		return questions[question_number]

## Int format is [Number of Correct Answers, Unlocked Number of Users]
@export var endings_dictionary:Dictionary[PackedInt32Array,UserMetadata]
@export var main_input_field:Control
@export var title_node:Label
@export var ending_confirmation:Panel
@export var next_button:Button
@export var previous_button:Button
@export var answer_confirmation_row:PackedScene
var correct_answers:int:
	get:
		var number_of_correct_answers:int = 0
		for question in questions:
			number_of_correct_answers += int(question.is_correct)
		return number_of_correct_answers

var question_number:int = 0:#stores which question number we are on
	set(new_value):
		question_number = clampi(new_value,0,questions.size()-1)
		if new_value == questions.size():
			end_questions()
		elif new_value == questions.size()-1: #Last question
			next_button.text = "End Investigation"
		elif new_value <= 0: #First question
			previous_button.disabled = true
		else: #Default everything
			next_button.text = "Next Question"
			previous_button.disabled = false
			ending_confirmation.hide()
func _ready():
	super()
	
	#Load in the first question
	add_new_question(questions[0])

func add_new_question(question:SingleQNA):
	title_node.text = question.title
	for child in main_input_field.get_children():
		child.queue_free()
	match question.type:
		SingleQNA.types.MCQ: make_mcq(question)
		SingleQNA.types.TEXTINPUT: make_textinput()
		SingleQNA.types.NUMBERINPUT: make_numberinput()

func make_mcq(question:SingleQNA):
	# Evaluate number of options
	var number_of_questions:int = -1 #No questions. Start this way or else we accidentally have one extra question.
	for number in 6: #Maximum 6 questions
		number_of_questions += int(not question.get("option%s_text"%[number]) == "")
	
	# Make the main input a control
	var gridcontainer = GridContainer.new()
	gridcontainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Figure out optimal number of columns
	match number_of_questions:
		4: gridcontainer.columns = 2
		6: gridcontainer.columns = 3
		_: gridcontainer.columns = 1

	main_input_field.replace_by(gridcontainer)
	main_input_field = gridcontainer #So we can refer to it
	
	for number in number_of_questions:
		var question_name = question.get("option%s_text"%[number+1])
		var new_button = Button.new()
		new_button.text = question_name
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		new_button.pressed.connect(mcq_submitted.bind(number)) #So we can deal with options
		main_input_field.add_child(new_button)

func make_textinput():
	var new_lineedit = LineEdit.new()
	var center_container = Control.new()
	# Set center container settings
	center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	#Set Line edit settings
	new_lineedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_lineedit.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	new_lineedit.text_changed.connect(func(text:String): current_question.submitted_text = text)
	new_lineedit.text_submitted.connect(func(_text): progress_question()) #Do nothing with the text
	new_lineedit.text = current_question.submitted_text
	
	# Replace
	main_input_field.replace_by(center_container)
	main_input_field = center_container #So we can refer to it
	
	# Add child
	main_input_field.add_child(new_lineedit)

func make_numberinput():
	var new_lineedit = SpinBox.new()
	var center_container = Control.new()
	# Set center container settings
	center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	#Set Line edit settings
	new_lineedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_lineedit.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	new_lineedit.value_changed.connect(func(val:float): current_question.submitted_number = int(val)) #Sets number whenever it is changed
	new_lineedit.value = current_question.submitted_number
	
	# Replace
	main_input_field.replace_by(center_container)
	main_input_field = center_container #So we can refer to it
	
	# Add child
	main_input_field.add_child(new_lineedit)

func mcq_submitted(option:int):
	questions[question_number].submitted_option = option
	progress_question()
func text_submitted(text:String):
	questions[question_number].submitted_text = text
func number_submitted(number:int):
	questions[question_number].submitted_number = number

func progress_question():
	question_number += 1
	add_new_question(current_question)

func go_back():
	question_number -= 1
	add_new_question(current_question)

func end_questions():
	ending_confirmation.show()
	var ending_sorter:BoxContainer = ending_confirmation.get_node("MarginContainer/Sorter/ScrollContainer/Answer Row Sorter")
	for child in ending_sorter.get_children(): #Empties it out before we start working.
		child.queue_free()
	
	for question in questions:
		var new_confirm_row = answer_confirmation_row.instantiate()
		new_confirm_row.get_node("Number").text = str(questions.find(question)+1)+"."
		new_confirm_row.get_node("Question").text = question.title
		match question.type:
			SingleQNA.types.MCQ:
				var qna_name:String = question.get("option%s_text"%[question.submitted_option+1])
				new_confirm_row.get_node("Answer").text = qna_name
			SingleQNA.types.NUMBERINPUT: new_confirm_row.get_node("Answer").text = str(question.submitted_number)
			SingleQNA.types.TEXTINPUT: new_confirm_row.get_node("Answer").text = question.submitted_text
		
		ending_sorter.add_child(new_confirm_row)

func ending_confirmed():
	# The ending has been confirmed, so start the user into their ending.
	var ending_index:PackedInt32Array
	ending_index.append(correct_answers)
	ending_index.append(SaveData.game_users.size())
	var ending_user = endings_dictionary[ending_index]
	desktop.power_strip_pressed(&"ending",ending_user)
