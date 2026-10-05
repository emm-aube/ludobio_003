extends Node

@export var clarity_tolerance:int
@export var clarity_threshold:int

var clarity_timer: Timer
var min_clarity_time:float = 0.5
var max_clarity_time:float = 2.0
var souvenirs_array:Array = []
var mouse_is_moving:bool = false
var clarity_activated:bool

func _ready() -> void:
	for x in get_tree().get_nodes_in_group("souvenir"):
		souvenirs_array.append(x)
		#x.process_clarity(get_viewport().get_mouse_position(), clarity_threshold, clarity_tolerance)
	
	clarity_timer = Timer.new()
	add_child(clarity_timer)
	clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
	#clarity_timer.timeout.connect(update_clarity)
	clarity_timer.timeout.connect(timer_timeout)
	clarity_timer.start()

func _process(_delta: float) -> void:
	mouse_is_moving = false
	if(clarity_activated == false):
		clarity_activated = true
		for x in souvenirs_array:
			update_clarity()

func timer_timeout() -> void:
	if mouse_is_moving == false:
		clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
		update_clarity()
	
func _input(_event: InputEvent) -> void:
	mouse_is_moving = true
	update_clarity()


func update_clarity() -> void:
	#clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
	if(MemoryPool.instance.start_processing == true):
		var mouse_pos = get_viewport().get_mouse_position()
		for x in souvenirs_array:
			if(x.position.distance_to(mouse_pos) <= clarity_threshold):
				x.process_clarity(mouse_pos, clarity_threshold, clarity_tolerance)
				x.is_unclear = false
			else:
				if(x.is_unclear == false):
					x.reset_clarity()
					x.is_unclear = true