extends VirtualWindow

var first_value:float = 0#Value stored by user
var current_value:float = 0#Value being edited by user

enum operators {NONE,ADD,SUBTRACT,DIVIDE,MULTIPLY,REMAINDER}
var current_operator:operators

@export var input_bar:LineEdit
@export var operator_bar:Label
@export var stored_value_bar:LineEdit

var current_value_string:String # a version of the current value that's a string
		
func change_text():
	input_bar.text = str(current_value)
	#match and set operator bar text
	match current_operator:
		operators.ADD:
			operator_bar.text = "+"
		operators.SUBTRACT:
			operator_bar.text = "-"
		operators.DIVIDE:
			operator_bar.text = "/"
		operators.MULTIPLY:
			operator_bar.text = "*"
		operators.REMAINDER:
			operator_bar.text = "%"
		operators.NONE:
			operator_bar.text = " "
	stored_value_bar.text = str(first_value) #show stored value
	
	
#region Buttons
func _number_button_pressed(number:int):
	current_value_string += str(number).trim_suffix(".0") #Append	
	current_value = float(current_value_string) #Store appended value as float.
	change_text()


func _all_clear_pressed():
	current_value = 0 #empties the expression
	first_value = 0
	current_operator = operators.NONE #Set it to no operator
	current_value_string = "" #reset current value
	change_text()


func _eval_pressed():
	#do the maths based on the current operator
	match current_operator:
		operators.ADD:
			first_value += current_value
		operators.SUBTRACT:
			first_value -= current_value
		operators.DIVIDE:
			first_value /= current_value
		operators.MULTIPLY:
			first_value *= current_value
		operators.REMAINDER:
			first_value = fmod(first_value,current_value)
		operators.NONE:
			desktop.notify_send("No operator selected!","Calulcator")
	if not current_operator == operators.NONE: #dont reset current value if the user forgot to select an operator
		current_value = 0 #reset current value for new maths
		current_value_string = ""
	
	current_operator = operators.NONE #reset operators too
	change_text()


func _add_symbol(symbol:int):
	current_operator = symbol as operators #Hopefully I aligned the buttons right
	
	if first_value == 0: #Basically its empty
		first_value = current_value #set the saved value to be the current value
		current_value = 0
		current_value_string = "" #Reset the values
	change_text()

func _add_decimal():
	current_value_string = str(current_value)
	var has_decimal:bool = false #start by assuming that it's not a decimal
	
	for chr in current_value_string: #check if has decimal
		if chr == ".": #must be having a decimal
			has_decimal = true
		else: #do nothing if it is a number
			pass
	
	if not has_decimal:
		current_value_string += "." #add a decimal point
	current_value = float(current_value_string) #covert the new thing back to float and store it
	change_text()


func _on_backspace_button_pressed():
	current_value_string = current_value_string.left(-1) #reduce last letter
	current_value = float(current_value_string)
	change_text()

func _swap_pressed():
	#Swap the input and the stored value.
	#stores these so that we can ovverride them easily
	var first_value_temporary = first_value
	var current_value_temporary = current_value 
	
	first_value = current_value_temporary
	current_value = first_value_temporary
	current_value_string = str(current_value)
	change_text()
#endregion
