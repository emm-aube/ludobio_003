extends Node2D

# PROCESSES VARIABLES
# recollection process variables 
@export var recollection_target:float
var recollection_shader_value:float
var is_recollected:bool
# clarity process
# is_unclear is only for optim to reset (from process) when leaving the souvenir 
var clarity_needed:float = 0.8
var is_clear:bool
var is_unclear:bool
var clarity_shader_value:float
# to never be at 100% clarity NOT USED NOW
# var clear_clarity_ratio:float = 0.95
# association process
# asso_target is a duplicate of reco target that can is modified during asso process
@export var association_array:Array[Node2D]
var association_target:float

# ASCII VARIABLES 
# original content 
var original_souvenir:String
var letters_array:Array
# ascii = wrong letters when recollected, enpty = noise or wrong letters when NOT recollected
var ascii: String = "@BAOPBÇQDR"
var ascii_empty: String = " . ,  -^¨"


# ACTIVATE SOUVENIR FROM POOL
func initiate() -> void:
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
			"current_letter" : character,
			"status": "[color=#ffffff50]", 
			"end_status": "[/color]",
			# noise are just temp parameters that revert to current so keep separated
			"noise_letter" : "",
			"noise_status": "[color=#ffffffff]",
			"position": char_size * Vector2(x_i, y_i) + Vector2(position.x - $RichTextLabel.size.x /2, position.y - $RichTextLabel.size.y /2)
		}
		letters_array.append(char_dico)

# PROCESS CLARITY
func process_clarity(current_aim:Vector2, clarity_threshold:int, clarity_tolerance:int):
	# create empty var to fill with each letter for the souvenir
	var txt_to_display = ""
	var clear_letters:int = 0
	# parse dico of letters
	for char_i in range(MemoryPool.instance.souvenirs_length):		
		# next lines are just to check central letter distance to mourse pos to check if WHOLE SOUVENIR clear or NOT
		# should be changed with a calcul on letters 
		var letter_distance = letters_array[char_i]["position"].distance_to(current_aim)
		# check each letter distance to mouse pos
		# if under threshold, check if under tolerance 
		if(letter_distance <= clarity_threshold):
			# for letter that will NOT be under tolerance, set % of chance to sill be clear (based on pos between threshold and tolerance)
			clarity_shader_value = (clarity_threshold - letter_distance) / (clarity_threshold - clarity_tolerance)
			# if under tolerance of if "lucky" with % of chance
			if(letter_distance <= clarity_tolerance) or (randf() < clarity_shader_value):
				# if under tolerance, clarify letter 
				letters_array[char_i]["status"] = "[color=#ffffffff]"
				# make sure the LETTER is recollected (not the souvenir)
				if(ascii.contains(letters_array[char_i]["current_letter"])):
					letters_array[char_i]["current_letter"] = letters_array[char_i]["origin_letter"]
					#clear_letters += 1
			else:
				# give it the "vague" color 
				letters_array[char_i]["status"] = "[color=#ffffff80]"
				#if currently have a "good" letter, revert it to a placeholder 

				# if origin letter is an "empty" one, give it another empty 
				if(ascii_empty.contains(letters_array[char_i]["origin_letter"])): 
					letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
				# else give it another "real" letter
				else:
					# check if the LETTER is recollected (not the souvenir) OR if we currently have a right letter to rever to vague
					if((ascii.contains(letters_array[char_i]["current_letter"]) or (letters_array[char_i]["current_letter"]) == letters_array[char_i]["origin_letter"])):
						letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
						
		# concatenate letters before display
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	# check if enough letters clear to define the whhole souvenir as clear
	is_clear = float(clear_letters)/float(MemoryPool.instance.souvenirs_length) < clarity_needed
	# update the text with concatenated letters and rich labels
	$RichTextLabel.text = txt_to_display
	
# RESET LETTERS TO UNCLEAR
# to avoid processing every letter (both optim and visual) we reset souvenirs and mark them resetted (from prcs)
func reset_clarity():
	# create empty var to fill with each letter for the souvenir
	var txt_to_display:String = ""
	# just put each letter to dark
	for char_i in range(MemoryPool.instance.souvenirs_length):
		letters_array[char_i]["status"] = "[color=#ffffff50]"
		# if origin letter is an "empty" one, give it another empty 
		if(ascii_empty.contains(letters_array[char_i]["origin_letter"])): 
			letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
		# else give it another "real" letter
		else:
			# check if the LETTER is recollected (not the souvenir) OR if we currently have a right letter to rever to vague
			if((ascii.contains(letters_array[char_i]["current_letter"]) or (letters_array[char_i]["current_letter"]) == letters_array[char_i]["origin_letter"])):
				letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
		# concatenate letters 
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	# update the text with concatenated letters and rich labels
	$RichTextLabel.text = txt_to_display

# PROCESS RECOLLECTION
# defines if the current level of focus of memory is within range of current recollection level 
func process_recollection(current_depth:int, recollection_threshold:int, recollection_tolerance:int):
	# create empty string for future display
	var txt_to_display:String = ""
	# find current distance to recollection
	var recollection_distance = abs(current_depth - recollection_target)
	# if under threshold 
	if(recollection_distance < recollection_threshold):
		# if under tolerance, souvenir is recollected and apperas completely (may be unclear)
		if(recollection_distance < recollection_tolerance):
			recollection_shader_value = 1
			is_recollected = true
		# otherwise, NOT recollecte and appears partially depending on recollection value
		else:
			# recollection vallue based on threshold on position betwwn threshold and distance
			# the smaller the distsance, the bigger the value
			recollection_shader_value = recollection_threshold - recollection_distance
			recollection_shader_value = float(recollection_shader_value/recollection_threshold)
			is_recollected = false
	else:
		#if out of threshold, NOT appears at all
		recollection_shader_value = 0
		is_recollected = false
	# then check if the souvenir is an actual one or just empty stuff, if NOT empty stuff, change the letter
	if !is_in_group("empty"):
		for char_i in range(MemoryPool.instance.souvenirs_length):
			# for each letter, percentage of chance to be clear depends on souvenir recollection level 
			if(randf() < recollection_shader_value):
				letters_array[char_i]["current_letter"] = ascii[randi()% len(ascii)]
			else:
				letters_array[char_i]["current_letter"] = ascii_empty[randi()% len(ascii_empty)]
			# concatenate letteers and rich labels
			txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
		# display updated text 
		$RichTextLabel.text = txt_to_display
		

# PROCESS NOISE: ADD (from Memory Pool)
func add_noise(char_index:int):
	# chose how many chars to 
	var nb_chars_to_noisify:int = randi_range(0, 3)
	for i in range(0, nb_chars_to_noisify):
		# need to shield from possible out of index if goes overs array length with the loop (full < because length calculation != index )
		if((char_index + i) < len(letters_array)):
			letters_array[char_index + i]["noise_letter"] = ascii[randi()% len(ascii)]
	
	var txt_to_display : String = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):
		if(letters_array[char_i]["noise_letter"] != ""):
			txt_to_display += letters_array[char_i]["noise_status"] + letters_array[char_i]["noise_letter"] + letters_array[char_i]["end_status"]
		else:
			txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	
	$RichTextLabel.text = txt_to_display

# PROCESS NOISE: REMOVE (from Memory Pool)
func stop_noise():

	var txt_to_display:String = ""
	for char_i in range(MemoryPool.instance.souvenirs_length):
		letters_array[char_i]["noise_letter"] = ""
		txt_to_display += letters_array[char_i]["status"] + letters_array[char_i]["current_letter"] + letters_array[char_i]["end_status"]
	
	$RichTextLabel.text = txt_to_display
