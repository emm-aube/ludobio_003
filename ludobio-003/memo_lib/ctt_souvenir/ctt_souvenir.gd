extends Node2D

# ORIGINAL CONTENT
@export var souvenir_ID:String
var original_souvenir:String
var letters_array:Array

var first:bool

# RECOLLECTION PROCESS
@export var recollection_target:float
var recollection_level:float

# CLARITY PROCESS
var is_clear:bool
var is_unclear:bool

# ASSOCIATION PROCESS 
# asso_target is a duplicate of reco target that can is modified during asso process
@export var association_array:Array[Node2D]
var is_associated:bool
var is_associating:bool 
var needs_association:bool

# ASCII VARIABLES 
var ascii: String = "@BAOPBÇQDR"
var ascii_empty: String = " - ^¨ "
var status_clear:String = "[color=#ffffffff]"
var status_vague:String = "[color=#ffffff60]"
var status_unclear:String = "[color=#ffffff20]"
var status_noise:String = "[color=#ffffffff]"
var status_selected:String = "[shake][color=#42F527ff]"
var end_status:String = "[/color]"
var end_status_selected:String = "[/color][/shake]"



# ACTIVATE SOUVENIR FROM POOL
func initialize() -> void:
	# store the inspector data
	original_souvenir = $RichTextLabel.text
	# find char size to then find each letter position 
	var char_size = Vector2($RichTextLabel.size) / Vector2(MemoryPool.instance.souvenir_nb_char, MemoryPool.instance.souvenir_nb_lines)
	var x_i: int = 0
	var y_i: int = 1
	# create a dico with data for each lettter
	for character in original_souvenir:
		x_i += 1
		if x_i > MemoryPool.instance.souvenir_nb_char:
			x_i = 1
			y_i += 1
		var char_dico = {
			"origin_letter" : character,
			"clarity_level" : 0.0,
			"current_letter" : " ",
			"is_recollected": souvenir_ID == "Origin",
			"status": status_unclear, 
			"end_status": end_status,
			# noise are just temp parameters that revert to current so keep separated
			"noise_letter" : "",
			"noise_status": status_clear,
			"position": char_size * Vector2(x_i, y_i) + Vector2(position.x - $RichTextLabel.size.x /2, position.y - $RichTextLabel.size.y /2)
		}
		letters_array.append(char_dico)
	

# PROCESS CLARITY
func process_clarity(reset:bool, current_aim:Vector2, clarity_threshold:float, clarity_tolerance:float):
	for char_i in range(MemoryPool.instance.souvenirs_length):
		var letter_distance = letters_array[char_i]["position"].distance_to(current_aim)	
		if(reset or letter_distance > clarity_threshold):
			letters_array[char_i]["clarity_level"] = 0.0
		else:
			if(letter_distance <= clarity_tolerance):
				letters_array[char_i]["clarity_level"] = 1
			else:
				letters_array[char_i]["clarity_level"] = (clarity_threshold - letter_distance) / (clarity_threshold - clarity_tolerance)
	update_letters(false)

# PROCESS RECOLLECTION
func process_recollection(current_depth:int, recollection_threshold:int, recollection_tolerance:int):
	var recollection_distance = abs(current_depth - recollection_target)
	if(recollection_distance < recollection_threshold):
		if(recollection_distance < recollection_tolerance):
			recollection_level = 1
		else:
			recollection_level = 1.0 - (recollection_distance / recollection_threshold)
	else:
		recollection_level = 0
	update_letters(true)

# PROCESS ASSOCIATION		
func process_association(process_choice:String):
	if process_choice == "check":
		if is_clear or is_associating:
			return(self)
		#else:
		#	return(null)
	elif process_choice == "activate":
		is_associating = true
		update_letters(false)
	elif process_choice == "clean":
		is_associating = false			
		update_letters(false)
		

# UPDATE EACH LETTER EACH FRAME DEPENDING ON RECOLLECTION AND CLARITY LEVELS 
func update_letters(include_recollection:bool):
	var clear_letters:int = 0
	var txt_to_display = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):
		if(is_associating):
			letters_array[char_i]["status"] = status_selected
			letters_array[char_i]["end_status"] = end_status_selected
		else:
			letters_array[char_i]["end_status"] = end_status
			if letters_array[char_i]["clarity_level"] == 1 or randf() < letters_array[char_i]["clarity_level"] :
				letters_array[char_i]["status"] = status_clear
			elif letters_array[char_i]["clarity_level"] == 0:
				letters_array[char_i]["status"] = status_unclear
			else:
				letters_array[char_i]["status"] = status_vague
			if(!needs_association or is_associated):
				
				
				if(include_recollection):
					letters_array[char_i]["is_recollected"] = recollection_level == 1 or randf() < recollection_level

				if(letters_array[char_i]["is_recollected"]):
					if letters_array[char_i]["status"] == status_clear:
						letters_array[char_i]["current_letter"] = letters_array[char_i]["origin_letter"]
						clear_letters += 1
					else: 
						if ascii_empty.contains(letters_array[char_i]["origin_letter"]):
							letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
						else:
							letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
				else:
					letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
			else:
				letters_array[char_i]["current_letter"] = ascii_empty[randi() % len(ascii_empty)]
				#letters_array[char_i]["status"] = status_unclear
				#letters_array[char_i]["end_status"] = end_status
			
		if (float(clear_letters) / float(MemoryPool.instance.souvenirs_length) > 0.7):
			is_clear = true
		else:
			is_clear = false
		
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]

	$RichTextLabel.text = txt_to_display			


# PROCESS NOISE: ADD (from Memory Pool)
func process_noise(reset:bool, char_index:int, nb_chars_to_noisify:int):
	var txt_to_display : String = ""
	if(reset):
		for char_i in range(MemoryPool.instance.souvenirs_length):
			letters_array[char_i]["noise_letter"] = ""
			txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	else:
		if !is_associating:
		# chose how many chars to change
			for i in range(0, nb_chars_to_noisify):
				# need to shield from possible out of index if goes overs array length with the loop (full < because length calculation != index )
				if((char_index + i) < len(letters_array)):
					letters_array[char_index + i]["noise_letter"] = ascii[randi()% len(ascii)]
			for char_i in range(MemoryPool.instance.souvenirs_length):
				if(letters_array[char_i]["noise_letter"] != ""):
					txt_to_display += letters_array[char_i]["noise_status"] + letters_array[char_i]["noise_letter"] + letters_array[char_i]["end_status"]
				else:
					txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	$RichTextLabel.text = txt_to_display