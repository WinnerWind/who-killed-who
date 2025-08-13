extends VirtualWindow

@export var replacements:ReplacementList

@export var contents_node:RichTextLabel

@export var debug_mode:bool = false

func _ready() -> void:
	super()
	titlebar.close_button.queue_free()
	titlebar.minimize_button.queue_free()
	#Replacements
	for replacement in replacements.replacements:
		contents_node.text = contents_node.text.replace(replacement, replacements.replacements[replacement])
	
	roll_credits()

@export var current_scroll_count:float:
	set(new_value):
		current_scroll_count = new_value
		contents_node.get_v_scroll_bar().value = new_value

func roll_credits():
	await create_tween().tween_interval(2).finished
	var tween:Tween = create_tween()
	var scroll_bar:VScrollBar = contents_node.get_v_scroll_bar()
	#var content_height = 1335 #unfortunately contents_node.get_content_height() returns a wrong value.
	var content_height = 1344
	
	var acceleration_ratio:float = 3.0/25.0
	var deceleration_ratio:float = 3.0/25.0
	
	var acceleration_distance := 25
	var deceleration_distance := 50
	
	var acceleration_time = acceleration_ratio * acceleration_distance
	var deceleration_time = deceleration_ratio * deceleration_distance
	#var acceleration_time = 1.5
	#var deceleration_time = 3
	var scroll_time:float = 20
	
	tween.tween_property(scroll_bar, "value", acceleration_distance, acceleration_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(scroll_bar, "value", content_height - deceleration_distance, scroll_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(scroll_bar, "value", content_height, deceleration_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if debug_mode: print(contents_node.get_content_height())
func _on_contents_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
