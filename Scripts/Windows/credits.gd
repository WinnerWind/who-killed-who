@tool
extends VirtualWindow
class_name CreditsWindow

@export var replacements:ReplacementList

@export var contents_node:RichTextLabel
@export var scroll_container:ScrollContainer

@export var debug_mode:bool = false

@export_multiline var text:String
@export_tool_button("Compile Text") var compile_func = compile_text

@export var initial_delay:float

func compile_text():
	contents_node.text = text
	for replacement in replacements.replacements:
		contents_node.text = contents_node.text.replace(replacement, replacements.replacements[replacement])

func _ready() -> void:
	if not Engine.is_editor_hint():
		super()
		position.x = desktop.size.x + 500 #Desktop's size reflects the game size.
		titlebar.close_button.queue_free()
		titlebar.minimize_button.queue_free()
		#Replacements
		#for replacement in replacements.replacements:
			#contents_node.text = contents_node.text.replace(replacement, replacements.replacements[replacement])
		
		roll_credits()

func animate_to_view(_to:int = 0) -> void:
	pass
	# Do not animate to view.

func _process(delta) -> void:
	if debug_mode: print(contents_node.get_content_height())
	if not Engine.is_editor_hint():
		super(delta)

func roll_credits():
	await get_tree().process_frame
	await create_tween().tween_interval(initial_delay).finished
	
	if debug_mode: print(contents_node.get_content_height())
	
	var tween:Tween = create_tween()
	var scroll_bar:VScrollBar = scroll_container.get_v_scroll_bar()
	#var content_height = 1335 #unfortunately contents_node.get_content_height() returns a wrong value.
	#var content_height = 1344
	# calculate scroll height using workaround
	scroll_bar.value = 9999999
	var content_height = scroll_bar.value
	scroll_bar.value = 0
	
	var acceleration_ratio:float = 3.0/25.0
	var deceleration_ratio:float = 3.0/25.0
	
	var acceleration_distance := 25
	var deceleration_distance := 50
	
	var acceleration_time = 0.5*acceleration_ratio * acceleration_distance
	var deceleration_time = 0.5*deceleration_ratio * deceleration_distance
	#acceleration_time = 1.5
	#deceleration_time = 3
	var scroll_time:float = 25
	
	tween.tween_property(scroll_bar, "value", acceleration_distance, acceleration_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(scroll_bar, "value", content_height - deceleration_distance, scroll_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(scroll_bar, "value", content_height, deceleration_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	desktop.open_popup("Congratulations!","You've beat the game! There's nothing else to do. You will be sent back in 15 seconds.","Ending",CompressedTexture2D.new())
	desktop.credits_ended()

func _on_contents_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
