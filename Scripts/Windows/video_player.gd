extends VirtualWindow
class_name VideoPlayerWindow

@export var video:VideoStream
var initial_size:Vector2

@export var slider:HSlider
@export var player:VideoStreamPlayer
var seeking:bool

@export_group("Subtitles")
@export var subtitles_shown:bool
@export var subtitle_text_node:RichTextLabel
@export var subtitles:UnifiedSubtitles
@export var subtitle_replacements:ReplacementList

func _ready():
	titlebar.add_button(titlebar.sorters.LEFT,_player_change_state,&"play_pause","Playback Control")
	titlebar.add_label(titlebar.sorters.LEFT,&"timestamp")
	titlebar.add_button(titlebar.sorters.LEFT,increase_volume,&"volume_up","Volume Up")
	titlebar.add_button(titlebar.sorters.LEFT,decrease_volume,&"volume_down", "Volume Down")
	titlebar.add_button(titlebar.sorters.RIGHT,increase_size,&"increase_size", "Zoom In")
	titlebar.add_button(titlebar.sorters.RIGHT,decrease_size,&"decrease_size", "Zoom Out")
	titlebar.add_button(titlebar.sorters.RIGHT,change_subtitle_state,&"change_subtitle_state")
	super()
	initial_size = size
	player.stream = video
	player.play()
	slider.max_value = player.get_stream_length()
	slider.value = player.stream_position
	
	# Use independent.
	subtitles_shown = SaveData.ram_save["settings_subtitles_shown"]
	if not subtitles_shown:
		subtitle_text_node.visible = false #Hide it if its disabled.

#region Seeking
func _process(delta):
	super(delta)
	if not seeking:
		slider.value = player.stream_position
	titlebar.custom_titlebar_items[&"timestamp"].text = convert_time(player.stream_position)
	

	set_subtitles(player.stream_position)

func change_subtitle_state():
	if subtitles_shown == true: #hide subs
		subtitles_shown = false
		subtitle_text_node.visible = false
		desktop.notify_send("Subtitles have been disabled",name)
	else:
		subtitles_shown = true
		desktop.notify_send("Subtitles have been enabled",name)

func set_subtitles(stream_position:float):
	var int_pos = int(stream_position)
	var all_subs = subtitles.subtitles
	if all_subs.has(int_pos):
		var text_to_display:String = all_subs[int_pos]
		print(text_to_display)
		if subtitles_shown or text_to_display.begins_with("<f>"):
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
	else:
		subtitle_text_node.visible = false

func _on_seekbar_value_changed(value):
	if seeking:
		player.set_stream_position(value)
		player.paused = false
		await get_tree().create_timer(0.1).timeout
		player.paused = player_state_on_drag_start
		_player_change_state()
		_player_change_state()

var player_state_on_drag_start:bool
func _on_seekbar_drag_started():
	seeking = true
	player_state_on_drag_start = player.paused

func _on_seekbar_drag_ended(_value_changed):
	seeking = false
	
#endregion

#region Size Modification
func increase_size():
	if not size.x/initial_size.x >= 1.3224:#1.3224 because it kept stuttering with move_to_view() to keep it in place at 1.3225 du
		size *= 1.15
func decrease_size():
	# Prevents window from breaking if its too small.
	if not size/1.15 <= initial_size-Vector2.ONE*2: #Last subtraction fixes some rounding errors.
		size /= 1.15
#endregion


#region Pausing/Playing
func _player_change_state():
	if not player.paused: #Player is playing
		# Set pause
		titlebar.custom_titlebar_items[&"play_pause"].icon = fetch_icon(&"play_button")
		player.set_paused(true)
	else: #Not playing
		titlebar.custom_titlebar_items[&"play_pause"].icon = fetch_icon(&"pause_button")
		player.set_paused(false)
#endregion
		

func convert_time(time) -> String:
	# A function to convert the time into beautiful time.
	var working_time_in_seconds:int = snapped(time,1) #Gets rid of decimals cause yuck!
	#var seconds:int = working_time_in_seconds%60 #Modulo because we want remainder of seconds
	#var minutes:int = snapped(working_time_in_seconds/60,1) 
	#var hours:int = snapped(minutes/60,1)
	#return "%02d:%02d:%02d" % [hours,minutes,seconds] #Smart padding
	return Time.get_time_string_from_unix_time(working_time_in_seconds) # Smarter padding

func increase_volume():
	player.volume_db += 5
func decrease_volume():
	player.volume_db -= 5

func focus_window():
	super()
	titlebar.custom_titlebar_items[&"timestamp"].theme_type_variation = "TitlebarTextFocused"
	set_icons()

func unfocus_window():
	super()
	titlebar.custom_titlebar_items[&"timestamp"].theme_type_variation = "TitlebarText"
	set_icons()

func set_icons():
	super()
	#Sets titlebar icons
	titlebar.custom_titlebar_items[&"volume_up"].icon = fetch_icon(&"volume_up")
	titlebar.custom_titlebar_items[&"volume_down"].icon = fetch_icon(&"volume_down")
	titlebar.custom_titlebar_items[&"decrease_size"].icon = fetch_icon(&"zoom_out")
	titlebar.custom_titlebar_items[&"increase_size"].icon = fetch_icon(&"zoom_in")
	titlebar.custom_titlebar_items[&"play_pause"].icon = fetch_icon(&"pause_button")
	titlebar.custom_titlebar_items[&"change_subtitle_state"].icon = fetch_icon(&"subtitles_button")
