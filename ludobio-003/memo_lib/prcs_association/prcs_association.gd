extends Node


var souvenirs_array:Array
var current_souvenir_associating:Node2D
var associating_souvenirs_chain:Array[Node2D]
var linking_souvenirs_chain:Array[Node2D]
var links_per_segment:Array[int] = []

# INIT FROM POOL
func initialize(souvenirs:Array):
	souvenirs_array = souvenirs
	for souvenir in souvenirs_array:
		#check every souvenir that is in another souvenir array to check if they need to be associated to be recollecter 
		for associated_souvenir in souvenir.association_array:
			if associated_souvenir.name != "Origin":
				associated_souvenir.needs_association = true
		# make sure the original souvenir does NOT need association (to be recollectable from start )
		if souvenir.name == "Origin":
			souvenir.needs_association = false
			
# UPDATE SOUVENIRS ON RECOLLECT
func _input(event: InputEvent) -> void:
	if !MemoryPool.instance.start_processing:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_viewport().get_canvas_transform().affine_inverse() * event.position
			# CHECK IF CLICKED A SOUVENIR (and not empty)
			for souvenir in souvenirs_array:
				var label = souvenir.get_node("RichTextLabel")
				if label.get_global_rect().has_point(mouse_pos):
					var souvenir_clicked = souvenir.process_association("check")
					if souvenir_clicked != null:
						# REMOVE MENU STUFF
						if souvenir.name == "Origin" and MemoryPool.instance.menu_removed == false:
							MemoryPool.instance.remove_menu()
						# ENDING 
						if souvenir_clicked.is_in_group("end"):
							MemoryPool.instance.ending(souvenir_clicked)
						# CLICK NEW SOUVENIR: START CHAIN
						if current_souvenir_associating == null:
							current_souvenir_associating = souvenir_clicked
							associating_souvenirs_chain.append(souvenir_clicked)
							current_souvenir_associating.process_association("activate")
							# make associated souvenirs recollectable
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = true
						# CLICKED LAST: REMOVE FROM CHAIN
						elif current_souvenir_associating == souvenir_clicked:
							current_souvenir_associating.process_association("clean")
							associating_souvenirs_chain.pop_back()
							# make associated souvenirs NOT recollectable ANYMORE
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = false
							# if chain still exist, change current + make associated souvenirs recollectable 
							if(!associating_souvenirs_chain.is_empty()):
								current_souvenir_associating = associating_souvenirs_chain[len(associating_souvenirs_chain) -1]
								for associated_souvenir in current_souvenir_associating.association_array:
									if !associating_souvenirs_chain.has(associated_souvenir):
										associated_souvenir.is_associated = true
								# update the links (remove them)
								update_chain("clean")
							# else no more chain
							else:
								current_souvenir_associating = null
								# RE ADD MENU & TUTO STUFF
								MemoryPool.instance.add_menu()
						# CLICKED OTHER: EXTEND CHAIN
						elif !associating_souvenirs_chain.has(souvenir_clicked):
							associating_souvenirs_chain.append(souvenir_clicked)
							# make obsolete associated souvenirs NOT recollectable ANYMORE
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = false 
							current_souvenir_associating = souvenir_clicked
							current_souvenir_associating.process_association("activate")
							# make NEW associated souvenirs recollectable souvenirs
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = true
							# update the links (add one)
							update_chain("add")
						# CLICKED ALREADY IN CHAIN BUT NOT LAST: DO NOTHING
						else:
							pass
					# UPDATE CAMERA POS
					var camera_tween = create_tween()
					# IF there IS a souvenir, focus on last
					if current_souvenir_associating != null:
						camera_tween.tween_property(MemoryPool.instance.get_node("Camera2D"), "global_position", current_souvenir_associating.global_position, 0.3)
					# ELSE, center 
					else:
						camera_tween.tween_property(MemoryPool.instance.get_node("Camera2D"), "global_position", get_viewport().get_visible_rect().size / 2, 0.3)

# MANAGE CHAIN OF LINKS BETWEEN SOUVENIRS TO CREATE A THREAD
func update_chain(need:String):
	# just do not update chain if game over
	if(MemoryPool.instance.end_reached == false):
		# if new souvenir 
		if need == "add":
			# create a var to check how many links created
			var nb_last_links = 0
			# check which souvenirs positions to link
			var where_to:Vector2 = current_souvenir_associating.global_position
			var where_from:Vector2 = associating_souvenirs_chain[len(associating_souvenirs_chain) - 2].global_position
			# then make a loop starting with the start X position
			var i = where_from.x
			# step depends on widht/height (to move fron one to another)
			var step:int = current_souvenir_associating.get_node("RichTextLabel").size.x
			# while not on the current one
			while i != where_to.x:
				# move toward it
				i = move_toward(i, where_to.x, step)
				# check if souvenirs under this step
				for souvenir in souvenirs_array:
					var label = souvenir.get_node("RichTextLabel")
					# IF there is one on
					if label.get_global_rect().has_point(Vector2(i, where_from.y)):
						# AND if NOT the same pos, make an horizontal link
						if souvenir.is_associating == false:
							if(i != where_to.x):
								souvenir.make_link("h")
							# ELSE 
							else:
								# check if NOT on the current souvenir actually, and then make an angle link
								if(souvenir != current_souvenir_associating):
									if(where_to.x < where_from.x):
										if(where_to.y < where_from.y):
											souvenir.make_link("left-up")
										else:
											souvenir.make_link("left-down")
									else:
										if(where_to.y < where_from.y):
											souvenir.make_link("right-up")
										else:
											souvenir.make_link("right-down")
							# store the linking souvenir in the chain
							linking_souvenirs_chain.append(souvenir)
							# add it to the nb of linking souvenir chained for this segment
							nb_last_links += 1
			# THEN do the same for the Y direction (without the angle of course)
			var j = where_from.y
			while j != where_to.y:
				j = move_toward(j, where_to.y, step)
				if(j != where_to.y):
					for souvenir in souvenirs_array:
						var label = souvenir.get_node("RichTextLabel")
						if label.get_global_rect().has_point(Vector2(where_to.x, j)):
							if souvenir.is_associating == false:
								souvenir.make_link("v")
								linking_souvenirs_chain.append(souvenir)
								nb_last_links += 1
			# at the end of the chain, store in links per segment array how many links total in this segment (for cleaning)
			links_per_segment.append(nb_last_links)
		# when removing a chained souvenir, remove all the links
		elif need == "clean":
			# check how many links to remove based on the segment array
			var nb_to_clean = links_per_segment.pop_back()
			# clean as many souvenirs in the array as the nb stored in segment
			for i in range(nb_to_clean, 0, -1):
				linking_souvenirs_chain[len(linking_souvenirs_chain)-1].make_link("clean")
				linking_souvenirs_chain.pop_back()
