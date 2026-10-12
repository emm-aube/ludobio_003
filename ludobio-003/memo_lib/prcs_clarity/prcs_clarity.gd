extends Node

@export var clarity_tolerance:int
@export var clarity_threshold:int
@export var clarity_expected:float

var clarity_timer: Timer
var min_clarity_time:float = 0.5
var max_clarity_time:float = 2.0
var souvenirs_array:Array = []
var mouse_is_moving:bool = false

# INIT FROM POOL
func initialize(souvenirs:Array):
	souvenirs_array = souvenirs 
	# create a timer to make sure there is still some movement even if we don't move mouse
	clarity_timer = Timer.new()
	add_child(clarity_timer)
	clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
	clarity_timer.timeout.connect(timer_timeout)

# START FROM POOL (distinct from INIT because of timer)
func start():
	update_clarity()
	clarity_timer.start()

# ON TIMER CLICKS > UPDATE
func timer_timeout() -> void:
#	if mouse_is_moving == false: (removed because does not create conflict AND make sure things are updated)
	clarity_timer.wait_time = randf_range(min_clarity_time, max_clarity_time)
	update_clarity()
	
# ON MOUSE MOVEMENT > UPDATE
func _input(_event: InputEvent) -> void:
	if(MemoryPool.instance.start_processing != true):
		return
	#mouse_is_moving = true
	update_clarity()

# UPDATE CLARITY 
func update_clarity() -> void:
	if(MemoryPool.instance.start_processing == true):
		# get GLOBAL (because screen moves) mouse position
		var mouse_pos = get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
		# update clarity in each souvenir depending on distance  
		for x in souvenirs_array:
			if(x.position.distance_to(mouse_pos) <= clarity_threshold):
				x.process_clarity(false, mouse_pos, clarity_threshold, clarity_tolerance)
				# if INSIDE the threshold, label it unclear so we can clean it on leaving
				x.is_unclear = false
			else:
				# if OUT of threshold, just clean (was not updated perfectly with just regular tests especially on fast movements)
				# is handled in the souvenir 
				if(!x.is_unclear):
					x.process_clarity(true, mouse_pos, clarity_threshold, clarity_tolerance)
					x.is_unclear = true
