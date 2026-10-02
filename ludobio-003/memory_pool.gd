class_name MemoryPool
extends Node

@export var souvenir_width:int = 200
@export var souvenir_height:int = 200
@export var souvenir_nb_char:int = 17
@export var souvenir_nb_lines:int = 8
# noise strength = timer in seconds before a letter is updated on the screen
@export var noise_speed: float = 0.5
# how long does the letter stay changed 
@export var noise_duration: float = 0.2
@export var souvenirs_length:int = 136

@export var start_processing:bool = false
var noise_souvenir_index:int
var noise_timer:Timer
var restore_timer:Timer
var souvenirs_array = []
static var instance: MemoryPool

func _enter_tree() -> void:
	MemoryPool.instance = self


# ON START JUST CREATE ARRAY OF ALL SOUVENIRS PER CELL 
func _ready() -> void:
	await get_tree().process_frame

	souvenirs_length = souvenir_nb_lines * souvenir_nb_char
	for x in (get_tree().get_nodes_in_group("souvenir")):
		souvenirs_array.append(x)
	for x in souvenirs_array:
		x.initiate()

	start_processing = true

	noise_timer = Timer.new()
	add_child(noise_timer)
	noise_timer.wait_time = noise_speed
	noise_timer.timeout.connect(create_noise)
	noise_timer.one_shot = true
	noise_timer.start()
	
	restore_timer = Timer.new()
	add_child(restore_timer)
	restore_timer.wait_time = noise_duration
	restore_timer.timeout.connect(restore_noise)
	restore_timer.one_shot = true


func create_noise() -> void:
	noise_souvenir_index = randi() % len(souvenirs_array)
	var noise_letter_index: int = randi_range(0, souvenirs_length - 1)
	souvenirs_array[noise_souvenir_index].add_noise(noise_letter_index)
	restore_timer.start()

func restore_noise() -> void:
	souvenirs_array[noise_souvenir_index].stop_noise()
	noise_timer.start()
