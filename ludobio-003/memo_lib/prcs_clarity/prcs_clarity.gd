extends Node

@export var clarity_tolerance:int
@export var clarity_threshold:int
@export var clarity_expected:float

var clarity_timer: Timer
var min_clarity_time:float = 0.5
var max_clarity_time:float = 2.0
var souvenirs_array:Array = []
var mouse_is_moving:bool = false


func initialize(souvenirs:Array):
	souvenirs_array = souvenirs 
	
	clarity_timer = Timer.new()
	add_child(clarity_timer)
	clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
	clarity_timer.timeout.connect(timer_timeout)

func start():
	update_clarity()
	clarity_timer.start()

func timer_timeout() -> void:
	if mouse_is_moving == false:
		clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
		update_clarity()
	
func _input(_event: InputEvent) -> void:
	if(MemoryPool.instance.start_processing != true):
		return
	mouse_is_moving = true
	update_clarity()

func update_clarity() -> void:
	if(MemoryPool.instance.start_processing == true):
		var mouse_pos = get_viewport().get_mouse_position()
		for x in souvenirs_array:
			if(x.position.distance_to(mouse_pos) <= clarity_threshold):
				x.process_clarity(false, mouse_pos, clarity_threshold, clarity_tolerance)
				x.is_unclear = false
			else:
				if(!x.is_unclear):
					x.process_clarity(true, mouse_pos, clarity_threshold, clarity_tolerance)
					x.is_unclear = true
