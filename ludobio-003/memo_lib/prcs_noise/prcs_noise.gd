extends Node


# noise strength = timer in seconds before a letter is updated on the screen
var noise_max_speed: float = 1.0
# how long does the letter stay changed 
var noise_max_duration: float = 0.3

var noisy_souvenirs_array:Array
var noise_timer:Timer
#nb max of souvenirs affected 
var noise_max_strength: int = 4
var restore_timer:Timer
var souvenirs_array: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in get_tree().get_nodes_in_group("souvenir"):
		souvenirs_array.append(x)

		noise_timer = Timer.new()
	add_child(noise_timer)
	noise_timer.wait_time = randf_range(0.1, noise_max_speed)
	noise_timer.timeout.connect(create_noise)
	noise_timer.one_shot = true
	noise_timer.start()
	
	restore_timer = Timer.new()
	add_child(restore_timer)
	restore_timer.wait_time = randf_range(0.1, noise_max_duration)
	restore_timer.timeout.connect(restore_noise)
	restore_timer.one_shot = true


func create_noise() -> void:
	if(MemoryPool.instance.start_processing == true):
		#PREVENT A BUG + WARNING
		if(noise_max_strength > len(MemoryPool.instance.souvenirs_array)):
			noise_max_strength = len(MemoryPool.instance.souvenirs_array)
			print("WARNING: Noise potential value bigger than number of souvenirs.")
		# how many souvenirs are we gonna add noise to
		var nb_noisy_souvenirs:int = randi_range(1, noise_max_strength)
		# randomly find this many souvenirs in the array of souvenirs
		for i in range(nb_noisy_souvenirs):
			var noisy_souvenir_index = randi() % len(souvenirs_array)
			while (noisy_souvenirs_array.has(noisy_souvenir_index)):
				noisy_souvenir_index = randi() % len(souvenirs_array)
			# and add their index to the array of noisy souvnirs (nothing done yet)
			noisy_souvenirs_array.append(noisy_souvenir_index)
			# find a random index for the letters affected (no need to store it because we just clean them all after)
			var noise_letter_index: int = randi_range(0, MemoryPool.instance.souvenirs_length - 1)
			# store noisy souvenirs in an array for later cleaning
			souvenirs_array[noisy_souvenir_index].add_noise(noise_letter_index)

	# random duration before restore
	restore_timer.wait_time = randf_range(0.1, noise_max_duration)
	restore_timer.start()

func restore_noise() -> void:
	if(MemoryPool.instance.start_processing == true):
		# clear all souvenirs then clean the array of noisy souvenirs
		for noisy_souvenir_index in noisy_souvenirs_array:
			souvenirs_array[noisy_souvenir_index].stop_noise()
		noisy_souvenirs_array.clear()

	# random duration before noise again
	noise_timer.wait_time = randf_range(0.1, noise_max_speed)
	noise_timer.start()
