@tool
extends EditorScript

func _run():
	if Engine.is_editor_hint():
		print("Hello World")
	
