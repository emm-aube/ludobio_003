extends Node2D

@export var recollection_target:int
var clarity_target:Vector2

var recollection_shader_value:float
var is_recollected:bool
var clarity_shader_value:float
var is_clear:bool

var letters_array:Array

# list of chars to use for random
var ascii: String = "awijbfqoklqjsfnchurbnqpasqpqwefnXXX&&&3240hnqédc"
var ascii_empty: String = " . ,-^¨"

# original content 
var original_souvenir:String
var char_size:Vector2


# ACTIVATE SOUVENIR 
func initiate() -> void:
	original_souvenir = $RichTextLabel.text

	char_size = Vector2($RichTextLabel.size) / Vector2(MemoryPool.instance.souvenir_nb_char, MemoryPool.instance.souvenir_nb_lines)
	var x_i: int = 0
	var y_i: int = 1
	
	for character in original_souvenir:
		x_i += 1
		if x_i > MemoryPool.instance.souvenir_nb_char:
			x_i = 1
			y_i += 1
		var char_dico = {
			"origin_letter" : character,
			"current_letter" : character,
			"noise_letter" : "",
			"status": "[color=#ffffff50]", 
			"end_status": "[/color]",
			"noise_status": "[color=#ffffffff]",
			"position": char_size * Vector2(x_i, y_i) + Vector2(position.x - $RichTextLabel.size.x /2, position.y - $RichTextLabel.size.y /2)
		}
		letters_array.append(char_dico)
#TO UPDATE LATER WAIT TO HANDLE ALPHA 
			#var alpha = 0.5
			#var color = Color(1, 1, 1, alpha)
			#var txt = "[color=#%s]A[/color]" % color.to_html()

# PROCESS CLARITY
func process_clarity(current_aim:Vector2, clarity_threshold:int, clarity_tolerance:int):
	print("processing clarity")
	var txt_to_display = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):		
		var letter_distance = letters_array[char_i]["position"].distance_to(current_aim)
		if(letter_distance <= clarity_threshold):
			if(letter_distance <= clarity_tolerance):
				letters_array[char_i]["status"] = "[color=#ffffffff]"
				letters_array[char_i]["current_letter"] = letters_array[char_i]["origin_letter"]
			else:
				clarity_shader_value = (clarity_threshold - letter_distance) / (clarity_threshold - clarity_tolerance)
				letters_array[char_i]["status"] = "[color=#ffffff80]"
				if(randf() < clarity_shader_value):	
					letters_array[char_i]["current_letter"] = letters_array[char_i]["origin_letter"]
				else:
					if (ascii_empty.contains(letters_array[char_i]["origin_letter"])): 
						letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
					else:
						letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
		else:
			pass
			#letters_array[char_i]["status"] = "[color=#ffffff50]"
			#if(ascii_empty.contains(["origin_letter"]):
			#	letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
			#else:
			#	letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
			
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	
	#queue_redraw()
	$RichTextLabel.text = txt_to_display

#func _draw():
#	for letter in letters_array:
#		draw_circle(letter["position"] - position, 2.0, Color.RED)

# PROCESS RECOLLECTION
# defines if the current level of focus of memory is the same plane 
func process_recollection(current_depth:int, recollection_threshold:int, recollection_tolerance:int):
	var recollection_distance = abs(current_depth - recollection_target)
	if(recollection_distance < recollection_threshold):
		if(recollection_distance < recollection_tolerance):
			recollection_shader_value = 1
			is_recollected = true
		else:
			recollection_shader_value = recollection_threshold - recollection_distance
			recollection_shader_value = float(recollection_shader_value/recollection_threshold)
			is_recollected = false
	else:
		recollection_shader_value = 0
		is_recollected = false
	
	modulate.a = recollection_shader_value

# PROCESS NOISE
# Add noise (called from Memory Pool)
func add_noise(char_index:int):
	var noise:String = ""
	var nb_chars_to_noisify:int = randi_range(0, 3)
	for i in range(nb_chars_to_noisify):
		noise += ascii[randi()% len(ascii)]
	letters_array[char_index]["noise_letter"] = noise
	
	var txt_to_display : String = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):
		if(letters_array[char_i]["noise_letter"] != ""):
			txt_to_display += letters_array[char_i]["noise_status"] + letters_array[char_i]["noise_letter"] + letters_array[char_i]["end_status"]
		else:
			txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	$RichTextLabel.text = txt_to_display
# Remove noise (called from Memory Pool)
func stop_noise():
	var txt_to_display:String = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):
		letters_array[char_i]["noise_letter"] = ""
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	$RichTextLabel.text = txt_to_display