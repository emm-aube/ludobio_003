extends Node2D

# ORIGINAL CONTENT
var original_souvenir:String
var letters_array:Array

# RECOLLECTION PROCESS
@export var recollection_target:float
var recollection_level:float

# CLARITY PROCESS
var is_clear:bool
var is_unclear:bool
#passed on from CLARITY PROCESS
var clarity_needed:float

# ANCHOR PROCESS 
# asso_target is a duplicate of reco target that can is modified during asso process
#@export var anchors_array: Array[Anchor] = []
var is_anchored:bool 
#var association_array:Array[Node2D]
#var is_associated:bool

#var needs_association:bool

# ASCII VARIABLES 
var ascii: String = "@BAOPBÇQDR"
var ascii_empty: String = "`-^¨.$$$$$$$$$$"
var status_clear:String = "[color=#ffffffff]"
var status_dark:String = "[color=#ffffff00]"
var status_vague:String = "[color=#ffffff70]"
var status_unclear:String = "[color=#ffffff25]"
var status_noise:String = "[color=#ffffffff]"
#var status_selected:String = "[shake][rainbow]"
var end_status:String = "[/color]"
#var end_status_selected:String = "[/rainbow][/shake]"

# ACTIVATE SOUVENIR FROM POOL
func initialize(clarity_value:float) -> void:
	# store the inspector data
	original_souvenir = $RichTextLabel.text
	fill_letters(original_souvenir)
	# clarity needed
	clarity_needed = clarity_value

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
	update_letters()

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
	update_letters()

# PROCESS ANCHORING
func process_anchoring(reset:bool, content:String, weight:float):
	if(reset):
		letters_array.clear()
		fill_letters(original_souvenir)
		recollection_target = -1000
		recollection_level = 0.0
		is_anchored = false
	else:
		letters_array.clear()
		is_anchored = true
		fill_letters(content)
		# NEED TO CHANGE LATER 
		# right now the reco direction is random
		# but I think it should be more diary VS memory or sthing similar
		var random_bool: bool = randf() < 0.5
		if(random_bool):
			recollection_target = weight * 1000.0 / 2.0
		else:
			recollection_target = 1000 - (weight * 1000.0 / 2.0)

# FILL LETTERS FROM INIT OR AFTER SEARCH
func fill_letters(content:String):
	# find char size to then find each letter position
	var char_size = Vector2($RichTextLabel.size) / Vector2(MemoryPool.instance.souvenir_nb_char, MemoryPool.instance.souvenir_nb_lines)
	var x_i: int = 0
	var y_i: int = 1
	# create a dico with data for each lettter
	for character in content:
		x_i += 1
		if x_i > MemoryPool.instance.souvenir_nb_char:
			x_i = 1
			y_i += 1
		var char_dico = {
			"origin_letter" : character,
			"clarity_level" : 0.0,
			"current_letter" : " ",
			"letter_link" : "",
			"is_recollected": false,
			"status": status_unclear, 
			"end_status": end_status,
			# noise are just temp parameters that revert to current so keep separated
			"noise_letter" : "",
			"noise_status": status_clear,
			#"position": char_size * Vector2(x_i, y_i) + Vector2(position.x - $RichTextLabel.size.x /2, position.y - $RichTextLabel.size.y /2)
			"position": char_size * Vector2(x_i, y_i) + global_position - $RichTextLabel.size / 2
		}
		letters_array.append(char_dico)
	while len(letters_array) < 136:
		var char_dico = {
			"origin_letter" : " ",
			"clarity_level" : 0.0,
			"current_letter" : " ",
			"letter_link" : "",
			"is_recollected": false,
			"status": status_unclear, 
			"end_status": end_status,
			# noise are just temp parameters that revert to current so keep separated
			"noise_letter" : "",
			"noise_status": status_clear,
			#"position": char_size * Vector2(x_i, y_i) + Vector2(position.x - $RichTextLabel.size.x /2, position.y - $RichTextLabel.size.y /2)
			"position": char_size * Vector2(x_i, y_i) + global_position - $RichTextLabel.size / 2
		}
		letters_array.append(char_dico)


# UPDATE EACH LETTER EACH FRAME DEPENDING ON RECOLLECTION AND CLARITY LEVELS 
func update_letters():	
	# init important vars
	var clear_letters:int = 0
	var txt_to_display = ""
	# go through EACH letter 
	for char_i in range(MemoryPool.instance.souvenirs_length):
		if letters_array[char_i]["clarity_level"] == 1 or randf() < letters_array[char_i]["clarity_level"] :
			letters_array[char_i]["status"] = status_clear
		elif letters_array[char_i]["clarity_level"] == 0:
			letters_array[char_i]["status"] = status_unclear
		else:
			letters_array[char_i]["status"] = status_vague
			# check if the souvenir is recollectable 
			# IE EITHER empty but never reaches because of recollection value in inspector
			# OR is associated (meaning a souvenir it depends on is "selected")
		if(is_anchored):
			# check recollection for EACH letter based on % chances (0 if not in threshold, vague if in between, 1 if in tolerance)
			letters_array[char_i]["is_recollected"] = recollection_level == 1 or randf() < recollection_level
			if(letters_array[char_i]["is_recollected"]):
				# then IF recollected + in the clarity area, we can put origin letter + count it as clear
				if letters_array[char_i]["status"] == status_clear:
					letters_array[char_i]["current_letter"] = letters_array[char_i]["origin_letter"]
					clear_letters += 1
				# if RECOLLECTED BUT NOT CLEAR 
				# if it's an empty letter to start with (just all who have - as origin) give ascii enmpty
				else: 
					if(letters_array[char_i]["origin_letter"] == "-"):
						letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
					# else, give it a random not empty 
					else:
						letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
			else:
				# if NOT RECOLLECTED
				# give empty letters to everything (wheter empty or good)
				letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
		# IF it needs to be associated, then we cannot do anything then it's empty anwyays
		else:
			letters_array[char_i]["current_letter"] = ascii_empty[randi() % len(ascii_empty)]
	# depending on how many clear letters and the clarity needed (to be clicked on), define if WHOLE souvenir is Clear or NOT
		is_clear = (float(clear_letters) / float(MemoryPool.instance.souvenirs_length) > clarity_needed)
		# FAKE SPACES
		# because space break the lines, use other symbol for the noise (defined in ascii enpty) and paint it dark
		if(letters_array[char_i]["current_letter"] == "$"):
			letters_array[char_i]["status"] = status_dark
		# add each letter with its look to the final text
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	# and update the label with final text
	$RichTextLabel.text = txt_to_display
				

# PROCESS NOISE: ADD (from Memory Pool)
func process_noise(reset:bool, char_index:int, nb_chars_to_noisify:int):
	# do not modify a souvenir that is selected 
	#if(!is_associating):
	# create empty text
	var txt_to_display : String = ""
	# if we call a reset put everybletter back to its current status
	if(reset):
		for char_i in range(MemoryPool.instance.souvenirs_length):
			letters_array[char_i]["noise_letter"] = ""
			txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	# else, just add random noise based on values defined in the process
	else:
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
