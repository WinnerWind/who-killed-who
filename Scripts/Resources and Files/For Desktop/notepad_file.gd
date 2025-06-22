extends Resource
class_name NotepadFile

@export var file_name:String = "New File"
@export var contents:String =  ""

func to_dict() -> Dictionary:
	return {
		"file_name": file_name,
		"contents":contents
		}

func from_dict(dict:Dictionary) -> void:
	file_name = dict["file_name"]
	contents = dict["contents"]
