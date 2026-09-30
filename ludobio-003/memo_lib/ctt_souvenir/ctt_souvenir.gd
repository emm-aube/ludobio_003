extends Node2D

@export var recollection_target:int
@export var clarity_target_offset:Vector2
@export var nb_chars_per_line:int
#@export var nb_lines:int

var clarity_target:Vector2
var clarity_modifier_min_step:float
var is_recollected:bool
var is_clear:bool
var recollection_shader_value:float
var clarity_shader_value:float
var ascii: String = "awijbfqoklqjsfnc hurbnqpasqpqwefnXXX;&&&3240hn qé.dc"

var original_souvenir:String
var original_souvenir_length:int
var wait_till_ready:bool

#temp for test
var max_print_info:int = 0; 

var temp_test:bool = false

func _ready() -> void:
	clarity_target = Vector2(position.x,position.y)
	clarity_target += clarity_target_offset
	#material = material.duplicate()
	original_souvenir = $RichTextLabel.text
	original_souvenir_length = original_souvenir.length()
	wait_till_ready = true
	

# CALLED FROM RECOLLECTION PROCESS
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
	
	#material.set_shader_parameter("reco_strength", recollection_shader_value)


# CALLED FROM CLARITY PROCESS
func process_clarity(current_aim:Vector2, clarity_threshold:int, clarity_tolerance:int ):
	if(wait_till_ready == true):
		var clarity_distance = current_aim.distance_to(clarity_target)
		# 1 is clear, 0 is totally unclear
		if(clarity_distance <= clarity_threshold):
			if(clarity_distance <= clarity_tolerance):
				clarity_shader_value = 1
			else:
				clarity_shader_value = clarity_threshold - clarity_distance
				clarity_shader_value = float(clarity_shader_value / clarity_threshold)
		else:
			clarity_shader_value = 0
		update_souvenir()

# UPDATE LETTERS BASED ON CLARITY VALUE
func update_souvenir() -> void:
	var x_i: int = 0
	var y_i: int = 1
	for char_i in range(original_souvenir_length):
		x_1 += 1
		if x_i == nb_chars_per_line :
			x_i = 1
			y_i += 1
	var unclear_souvenir:String = ""
	if(clarity_shader_value == 0):
		#for i in range(original_souvenir_length):
		#	unclear_souvenir += ascii[randi()% len(ascii)]
		#$RichTextLabel.text = unclear_souvenir
		unclear_souvenir = original_souvenir
	elif(clarity_shader_value == 1):
		unclear_souvenir = original_souvenir
		#$RichTextLabel.text = original_souvenir
	else:
		clarity_shader_value = round(clarity_shader_value *10)
		if(clarity_shader_value == 0):
			clarity_shader_value = 1
		unclear_souvenir = original_souvenir
		#for i in range (0, original_souvenir_length, clarity_shader_value):
			#unclear_souvenir = unclear_souvenir.substr(0, i) + ascii[randi()% len(ascii)] + unclear_souvenir.substr(i +1)
		#$RichTextLabel.text = unclear_souvenir
	update_visibility(unclear_souvenir)
	
# UPDATE LETTERS VISIBILITY BASED ON CLARITY VALUE
func update_visibility(txt:String) -> void:
	#print(txt)
	var next_txt: String = ""
	#counting starts at 0, and index of string starts at 0, and length countein at 1 so being under is fine
	for char_i in range(original_souvenir_length):
		var char_to_update:String = txt.substr(char_i, 1)
		next_txt += "[pulse freq=2 ease=-2]" + char_to_update + "[/pulse]"
		if(max_print_info < 10):
			max_print_info += 1
			print(char_i)
			print(char_to_update)
		#print(next_txt)
	$RichTextLabel.text = next_txt
	#print($RichTextLabel.text)
