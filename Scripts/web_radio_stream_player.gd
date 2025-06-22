extends AudioStreamPlayer
class_name WebRadioStreamPlayer

signal loaded
signal unloaded

##Set this in case you don't want to manually set the path and all.
@export var combined_url:String:
	set(new_var):
		combined_url = new_var
		unloaded.emit()
@export var root_url:String
@export var path:String
@export var port:int #Some shitty websites like putting a port after url. Boils my soul.

## Define whether the player should play at all or no.
@export var should_play:bool:
	set(new_var):
		should_play = new_var
		stream_paused = !new_var

var http_client:HTTPClient

var buffer: PackedByteArray #Stores the data in the last buffer_length seconds.

var kickstart_timer: Timer #Restarts the buffer reading after its done reading.

@export var buffer_length:float = 2 #Stores the audio data for this many seconds.
func _ready() -> void:
	if combined_url:
		_parse_url(combined_url) #Deal with the combined URL if set, automatically setting port and other data.
	
	http_client = HTTPClient.new()
	
	# 320 kilobytes per second
	# 8 makes kilobytes into kilobits
	# 1024 makes kilobits into bits
	# multiplying with buffer length gives us a (hopefully) constant size.
	http_client.read_chunk_size = int(320.0 / 8.0 * 1024.0 * buffer_length)
	
	
	http_client.connect_to_host(root_url,port)
	
	kickstart_timer = Timer.new()
	kickstart_timer.timeout.connect(_kickstart_callback)
	self.call_deferred("add_child", kickstart_timer, true)

func _process(_delta: float) -> void:
	if should_play:
		http_client.poll()
		
		var status = http_client.get_status()
		
		if status == HTTPClient.STATUS_BODY:
			_add_to_buffer() #Add to buffer data because buffer is already existing.
		elif status == HTTPClient.STATUS_CONNECTED:
			http_client.request(HTTPClient.METHOD_GET, "/"+path, []) # Get the buffer data.
		elif status == HTTPClient.STATUS_CANT_CONNECT || status == HTTPClient.STATUS_CANT_RESOLVE || status == HTTPClient.STATUS_CONNECTION_ERROR || status == HTTPClient.STATUS_TLS_HANDSHAKE_ERROR || status == HTTPClient.STATUS_DISCONNECTED:
			push_error(str("Error with connection to stream: ", root_url))

func _add_to_buffer() -> void:
	if !http_client.has_response():
		print("No response")
		return
	if kickstart_timer != null:
		if kickstart_timer.is_stopped():
			kickstart_timer.start(buffer_length) #Restart timer
	else:
		_ready() #The timer doesn't exist so the stream abruptly stops. This restarts ALL execution.
	
	if http_client.get_status() == HTTPClient.STATUS_BODY: #Required safety check or else non fatal errors.
		var data = http_client.read_response_body_chunk()
		buffer.append_array(data)

func _play_buffer() -> void:
	var audio_stream = AudioStreamMP3.new()
	if not buffer == PackedByteArray():
		audio_stream.data = buffer #Set the raw data to this
		buffer.clear() #Or else our RAM gets fucked up with data (BAD!)
		stream = audio_stream
		
		play() #The stream should hopefully be in sync. Due to clock shenanegans it rarely is.
		
		loaded.emit()

func _kickstart_callback() -> void:
	kickstart_timer.queue_free() #Prevent skipping ahead, this timer is regenerated.
	call_deferred("_play_buffer")

func _parse_url(url: String) -> void:
	# https://github.com/jefvaia/Godot-WebRadio/blob/77f2f803ae8975390c3726adff208cdf2411de63/addons/webradio/node_types/httpclientinstance.gd#L53-L82
	# Match: scheme://host:port/path
	var regex = RegEx.new()
	regex.compile(r"^(https?)://([^/:]+)(?::(\d+))?(.*)$")
	
	var _match = regex.search(url)
	if _match:
		#result.scheme = _match.get_string(1)
		#result.domain = _match.get_string(2)
		root_url = _match.get_string(1)+"://"+_match.get_string(2)
		#result.port = int(_match.get_string(3)) if _match.get_string(3) != "" else (443 if result.scheme == "https" else 80)
		port = int(_match.get_string(3)) if _match.get_string(3) != "" else (443 if _match.get_string(1) else 80)
		#result.path = _match.get_string(4) if _match.get_string(4) != "" else "/"
		path = _match.get_string(4) if _match.get_string(4) != "" else "/"
	else:
		push_error("Invalid URL format: " + url)

func unload_all_tracks():
	buffer.clear()
	call_deferred(&"stop")
	stream = null
