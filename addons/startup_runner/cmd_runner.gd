@tool
extends EditorPlugin

# CHANGE THIS IF YOU WANT TO MOVE THE ADDON TO SOMEPLACE ELSE
const commands_file_path:String = "res://addons/startup_runner/command.txt"

func _enter_tree() -> void: #Also runs on editor start.
	if not FileAccess.file_exists(commands_file_path): #Intercept the error with our own.
		push_error("STARTUP COMMAND RUNNER: Command file not found at %s. Was it moved or deleted?"%commands_file_path)
	else:
		# Get the contents of the file as a text and then split it by the line.
		var commands = FileAccess.open(commands_file_path,FileAccess.READ).get_as_text().split("\n")
		
		for command in commands:
			if not command.strip_edges() == "": #Don't execute a blank line on accident.
				var command_name:String = command.split(" ")[0]
				var command_arguments:PackedStringArray = command.split(" ").slice(1)
				OS.execute_with_pipe(command_name,command_arguments)
	

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass #No cleanup required.
