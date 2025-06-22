extends RichTextLabel

var steps_since_start:int


func move_finished():
	steps_since_start += 1
	set_move_text()

func set_move_text():
	text = "[wave][font_size=26]Distance Travelled: "+str(steps_since_start*5)+"m"
