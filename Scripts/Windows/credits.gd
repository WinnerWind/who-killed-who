extends VirtualWindow

@export var replacements:ReplacementList

@export var contents_node:RichTextLabel

func _ready() -> void:
	super()
	#Replacements
	for replacement in replacements.replacements:
		contents_node.text = contents_node.text.replace(replacement, replacements.replacements[replacement])


func _on_contents_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
