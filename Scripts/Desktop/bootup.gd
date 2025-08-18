extends Control

@export var main_text_label:RichTextLabel
@export var plymouth:MarginContainer
@export var plymouth_image:TextureRect
@export var plymouth_looper:TextureRect
@export var sequence:BootupSequence

@export var scene_to_start:PackedScene
func _ready():
	# set these without thinking
	plymouth_image.texture = sequence.plymouth_image
	plymouth_looper.texture = sequence.plymouth_looper
	
	if sequence.is_intro: #sequence is intro
		intro() #do bootup sequence
	else: #sequence is not intro
		outro() #do shutdown sequence

#region Basics
func add_new_line(text:String,type:int,delay:float = 0):
	var new_text = text #Store for later logic
	match type:
		0: #failed
			new_text = new_text.insert(0,"[[color=red]FAILED[/color]] ")
		1: #okay
			new_text = new_text.insert(0,"[  [color=green]OK[/color]  ] ")
		2: #none
			pass
		
	main_text_label.append_text(new_text) #Append that shit.
	main_text_label.append_text("\n") #Adds a new line
	await get_tree().create_timer(delay).timeout #Does delay
	return

func change_to_plymouth():
	main_text_label.hide() #Hides the text 
	plymouth.show() #shows plymouth
	plymouth.get_node("Timer").start()

func change_to_text():
#endregion
	plymouth.hide()
	main_text_label.show()

func intro():
	#for line in sequence.array_of_bootup_text: #reads every line
		#await add_new_line(line.text,line.type,line.delay) #waits for it to finish
	#change_to_plymouth() #switch to plymouth
	#await plymouth.get_node("Timer").timeout #Waits for it to finish
	get_tree().root.call_deferred("add_child",scene_to_start.instantiate()) #Changes scene
	queue_free() #to be safe. For some reason, despite the docs saying it will, the previous line doesn't get rid of the scene.
	## comment appendix : the reason the change_scene_to_packed does not work is because the current scene is null due to how the desktop does the bootup scene's instantiation
	## see desktop.gd:216

func outro():
	#change_to_plymouth() #Starts with plymouth
	#await plymouth.get_node("Timer").timeout #Waits for it to finish
	#change_to_text() #Switches to text
	#for line in sequence.array_of_bootup_text: #Starts text sequence
		#await add_new_line(line.text,line.type,line.delay)
	get_tree().quit() #Quits game
