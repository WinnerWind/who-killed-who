extends VirtualWindow

@export var audio:AudioStream
@export var subtitles_enabled_size:Vector2i

@export_group("Nodes")
@export var player:AudioStreamPlayer
@export var slider:HSlider
@export var loop_button:Button
@export var volume_up_button:Button
@export var volume_down_button:Button
@export var pause_button:Button
@export var title_node:Label
@export var subtitle_node:Label #Not to be confused with subtitle_text_node. This is for the subtitle of the song title.
@export var modification_date_node:Label
@export var icon_node:TextureRect
@export var subtitle_text_node:RichTextLabel

var seeking:bool #A bool to check whethr we are seeking or not
var will_loop:bool #A bool to check whether the user has opted to loop or not

# Variables for all the data
@export_group("Data")
@export var title:String = ""
@export var subtitle:String = ""
@export var modification_date:String = ""
@onready var image:CompressedTexture2D = fetch_icon(&"audio_player")

@export_group("Subtitles")
@export var subtitles_shown:bool
@export var audio_subtitles:UnifiedSubtitles
@export var subtitle_replacements:ReplacementList
func _ready():
	titlebar.add_button(titlebar.sorters.RIGHT,change_subtitle_state,&"change_subtitle_state")
	super()
	titlebar.add_label(titlebar.sorters.LEFT,&"time_label")
	
	player.stream = audio #Set stream
	player.play()
	slider.max_value = audio.get_length() #Ensure that the slider is of the correct length
	#Set texts
	title_node.text = title
	subtitle_node.text = subtitle
	modification_date_node.text = modification_date
	set_image()
	
	# Use independent.
	subtitles_shown = !SaveData.ram_save["settings_subtitles_shown"] #Essentially reverse it so the next function can set it to normal.
	call_deferred(&"change_subtitle_state")

func change_subtitle_state():
	if subtitles_shown == true: #hide subs
		set_deferred(&"size",starting_size)
		#size = starting_size
		subtitles_shown = false
		subtitle_text_node.hide()
		desktop.notify_send("Subtitles have been disabled",name)
	else:
		subtitle_text_node.show()
		#size = subtitles_enabled_size
		set_deferred(&"size",subtitles_enabled_size)
		subtitles_shown = true
		desktop.notify_send("Subtitles have been enabled",name)

func set_subtitles(stream_position:float):
	var int_pos = int(stream_position)
	var all_subs = audio_subtitles.subtitles
	if all_subs.has(int_pos):
		var text_to_display:String = all_subs[int_pos]
		#print(text_to_display)
		if subtitles_shown or text_to_display.begins_with("<f>"):
			#size = subtitles_enabled_size
			set_deferred(&"size",subtitles_enabled_size)
			# Replace all names if they happen to exist.
			for replacement in subtitle_replacements.replacements.keys(): #Used for names and stuff
				if SaveData.ram_save["settings_subtitles_show_names"]:
					text_to_display = text_to_display.replace(replacement,subtitle_replacements.replacements[replacement])
				else: #Empty out all names if they happen to exist
					text_to_display = text_to_display.replace(replacement,"")
			
			# Check if the line is a closed caption. If it is, hide the subtitle and stop executing.
			if text_to_display.begins_with("<cc>") and not SaveData.ram_save["settings_subtitles_use_cc"]:
				subtitle_text_node.visible = false
				return
			else:
				text_to_display = text_to_display.replace("<cc> ","[i]")
				text_to_display = text_to_display.replace("<f> ","")
				subtitle_text_node.visible = true
				subtitle_text_node.text = text_to_display
				
				#Set its size according to the number of lines
				var line_count = subtitle_text_node.get_line_count()
				var font_size = subtitle_text_node.get_theme_default_font_size()
				var margin:int = 10 #Adds a slight margin to make it look better
				subtitle_text_node.custom_minimum_size.y = line_count*font_size + margin
		else:
			subtitle_text_node.visible = false
			#size = starting_size
			set_deferred(&"size",starting_size)
	else:
		if not subtitles_shown:
			#size = starting_size
			set_deferred(&"size",starting_size)
		subtitle_text_node.visible = false

func set_image():
	#I need a delay so that it gets set properly.
	await get_tree().create_timer(0.1).timeout
	#print(image)
	icon_node.texture = image

#region Seeking
func _process(delta):
	super(delta)
	#$Contents.size = Vector2(size.x,size.y-titlebar_size)
	if not seeking:
		slider.value = player.get_playback_position()
	#Returns time, yay
	titlebar.custom_titlebar_items[&"time_label"].text = Time.get_time_string_from_unix_time(snapped(player.get_playback_position(),1))
	
	set_subtitles(player.get_playback_position())

func _on_seekbar_value_changed(value):
	if seeking:
		player.seek(value)

func _on_seekbar_drag_started():
	seeking = true

func _on_seekbar_drag_ended(_value_changed):
	seeking = false
#endregion

#region State Changes/Loops
func _state_change():
	#Pauses it and plays it if button is pressed
	if player.stream_paused or not player.is_playing():
		pause_button.icon = fetch_icon(&"pause_button",true) 
		player.set_stream_paused(false)
	else:
		pause_button.icon = fetch_icon(&"play_button",true) 
		player.set_stream_paused(true)


func _loop_state_change():
	if will_loop:
		loop_button.icon = fetch_icon(&"loop_on",true) 
		will_loop = false
	else:
		loop_button.icon = fetch_icon(&"loop_off",true) 
		will_loop = true
		

func _on_audio_finished():
	pause_button.icon = fetch_icon(&"play_button",true)
	if will_loop:
		pause_button.icon = fetch_icon(&"pause_button",true)
		player.play()
	else:
		# A bit of a hack to make it so that the user can play after shit is done
		player.play()
		player.set_stream_paused(true)
#endregion

func increase_volume():
	player.volume_db += 5
func decrease_volume():
	player.volume_db -= 5


func focus_window():
	super()
	titlebar.custom_titlebar_items[&"time_label"].theme_type_variation = "TitlebarTextFocused"
func unfocus_window():
	super()
	titlebar.custom_titlebar_items[&"time_label"].theme_type_variation = "TitlebarText"
func set_icons():
	super()
	#reset icons
	volume_down_button.icon = fetch_icon(&"volume_down",true)
	pause_button.icon = fetch_icon(&"pause_button",true)
	loop_button.icon = fetch_icon(&"loop_off",true)
	volume_up_button.icon = fetch_icon(&"volume_up",true)
	titlebar.custom_titlebar_items[&"change_subtitle_state"].icon = fetch_icon(&"subtitles_button")
