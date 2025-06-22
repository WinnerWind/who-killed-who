extends VirtualWindow

var playtime:float 
@export var station_names:PackedStringArray
@export var station_urls:PackedStringArray
var current_url_index:int:
	set(new_index):
		if new_index > station_urls.size()-1: #Overflow
			new_index = 0
		elif new_index < 0: #Underflow
			new_index = station_urls.size()-1
		current_url_index = new_index
var current_url:
	get:
		return station_urls[current_url_index]
@export_group("Nodes")
@export var previous_button:Button
@export var play_pause_button:Button
@export var next_button:Button
@export var name_label:Label
@export var url_label:RichTextLabel
@export var listening_time_label:RichTextLabel
@export var count_label:Label
@export var current_player:WebRadioStreamPlayer

func _ready() -> void:
	set_all_text()
	
	titlebar.add_button(Titlebar.sorters.LEFT,_volume_up,&"volume_up")
	titlebar.add_button(Titlebar.sorters.LEFT,_volume_down,&"volume_down")
	super()

func _process(delta: float) -> void:
	super(delta)
	if current_player.should_play:
		playtime += delta
		update_playtime()

func set_icons():
	super()
	#reset icons
	next_button.icon = fetch_icon(&"volume_down",true)
	play_pause_button.icon = fetch_icon(&"pause_button",true)
	previous_button.icon = fetch_icon(&"loop_off",true)
	titlebar.custom_titlebar_items[&"volume_down"].icon = fetch_icon(&"volume_down",false)
	titlebar.custom_titlebar_items[&"volume_up"].icon = fetch_icon(&"volume_up",false)
	
func _play_pause():
	current_player.should_play = !current_player.should_play
	if current_player.should_play: play_pause_button.icon = fetch_icon(&"pause_button",true)
	else: play_pause_button.icon = fetch_icon(&"play_button",true)

func _volume_up():
	current_player.volume_db += 5
func _volume_down():
	current_player.volume_db -= 5
func _previous_player():
	current_url_index -=1 
	current_player.combined_url = current_url
	set_all_text()
func _next_player():
	current_url_index +=1
	current_player.combined_url = current_url
	set_all_text()

func set_all_text():
	name_label.text = station_names[current_url_index]
	url_label.text = "[color=gray]%s"%station_urls[current_url_index]
func update_playtime():
	var playtime_int = int(playtime)
	var hour = playtime_int/3600.0
	var minute = playtime_int/60.0
	var second = playtime_int%60
	listening_time_label.text = "[color=gray]Time Spent Listening in this Session: %02d:%02d:%02d"%[hour,minute,second]

func loaded():
	update_playtime()
func unloaded():
	listening_time_label.text = "Loading..."
