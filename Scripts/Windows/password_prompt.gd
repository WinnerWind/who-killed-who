extends VirtualWindow
class_name PasswordPromptWindow

var correct_password:String
var path:String

@export var body_text:RichTextLabel
@export var password_entry:LineEdit
func password_submitted(new_text):
	if new_text == correct_password:
		desktop.open_file_manager(path)
		close_window()
	else: #Password must be wrong
		password_entry.text = ""
		password_entry.placeholder_text = "Password Incorrect"
