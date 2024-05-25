extends Node


class State:
	var mainland = null
	var type = null
	var limit = null
	var index = null
	var areas = []
	var vassals = []
	var neighbors = []
	var senor = null
	var hub = null
	var capital = null
	var realm = null


	func _init(input_: Dictionary) -> void:
		mainland = input_.mainland
		type = input_.type
	
		init_basic_setting(input_)


	func init_basic_setting(input_: Dictionary) -> void:
		mainland.states.append(self)
		var states = mainland.get(type+"s")
		states.append(self)
		
		index = Global.num.index.state[type]
		Global.num.index.state[type] += 1
		limit = 3
		
		if type == "earldom":
			take_area(input_.area)
		else:
			take_state(input_.state)
			
		fill_to_limit()


	func take_area(area_: Polygon2D) -> void:
		if !areas.has(area_):
			areas.append(area_)
			area_.state[type] = self
			
			if areas.size() > limit:
				limit = areas.size()
			
			if limit == 4:
				split_earldom()


	func split_earldom() -> void:
		var union = {}
		union.cores = []
		union.deadends = []
		
		for area in areas:
			var connects = []
			
			for seam in area.neighbors:
				var neighbor = area.neighbors[seam]
				
				if areas.has(neighbor):
					connects.append(neighbor)
			
			if connects.size() == 1:
				union.deadends.append(area)
			else:
				union.cores.append(area)
		
		if union.cores.size() == 1:
			var deadend = union.deadends.pick_random()
			detach_area(deadend)


	func detach_area(area_: Polygon2D) -> void:
		areas.erase(area_)
		area_.state[type] = null
		limit = areas.size()


	func take_state(state_: State) -> void:
		if !vassals.has(state_):
			vassals.append(state_)
			state_.senor = self
			
			for area in state_.areas:
				areas.append(area)
				area.state[type] = self
			
			if vassals.size() > limit:
				limit = vassals.size()
			
			var notify_senor = senor
			
			while notify_senor != null:
				for area in state_.areas:
					senor.areas.append(area)
				
				notify_senor = notify_senor.senor
				
			if limit == 4 and type != "empire":
				split_senor()


	func split_senor() -> void:
		var union = {}
		union.cores = []
		union.deadends = []
		
		for vassal in vassals:
			var connects = []
			
			for neighbor in vassal.neighbors:
				if vassals.has(neighbor):
					connects.append(neighbor)
			
			if connects.size() == 1:
				union.deadends.append(vassal)
			else:
				union.cores.append(vassal)
		
		if union.cores.size() == 1 and  union.deadends.size() == 3:
			var deadend = union.deadends.pick_random()
			detach_state(deadend)


	func detach_state(state_: State) -> void:
		vassals.erase(state_)
		state_.senor = null
		
		for area in state_.areas:
			area.state[type] = null
		
		limit = vassals.size()
		
		var notify_senor = senor
		
		while notify_senor != null:
			for area in state_.areas:
				senor.areas.erase(area)
			
			notify_senor = notify_senor.senor
	 

	func fill_to_limit() -> void:
		if type == "earldom":
			while areas.size() < limit:
				encroach_area()
		else:
			while vassals.size() < limit:
				encroach_state()


	func encroach_area() -> void:
		var accessible_areas = get_accessible_areas()
		
		if accessible_areas.is_empty():
			limit = areas.size()
		else:
			var area = accessible_areas.pick_random()
			take_area(area)


	func get_accessible_areas() -> Array:
		var accessible_areas = []
		
		for area in areas:
			for neighbor in area.neighbors:
				if neighbor.state[type] == null and !accessible_areas.has(neighbor):
					accessible_areas.append(neighbor)
		
		return accessible_areas


	func encroach_state() -> void:
		var accessible_vassals = get_accessible_vassals()
		
		if accessible_vassals.is_empty():
			limit = vassals.size()
			
			if limit == 1:
				var a = null
		else:
			var vassal = accessible_vassals.pick_random()
			take_state(vassal)


	func get_accessible_vassals() -> Array:
		var accessible_vassals = []
		
		for vassal in vassals:
			for neighbor in vassal.neighbors:
				if neighbor.senor == null and !accessible_vassals.has(neighbor):
					accessible_vassals.append(neighbor)
		
		return accessible_vassals


	func absorb_neighbor_state(neighbor_state_: State) -> void:
		if neighbors.has(neighbor_state_):
			neighbors.erase(neighbor_state_)
			
			for neighbor in neighbor_state_.neighbors:
				if neighbor != self:
					neighbor.neighbors.append(self)
					neighbors.append(neighbor)
			
			while !neighbor_state_.vassals.is_empty():
				var vassal = neighbor_state_.vassals.pop_front()
				take_state(vassal)
			
			var node = mainland.get(neighbor_state_.type + "s")
			
			#print([neighbor_state_.index])
			for state in node.get_children():
				if state.index > neighbor_state_.index:
					#print(state.index, " > ", state.index - 1)
					state.index -= 1
				
				if state.neighbors.has(neighbor_state_):
					state.neighbors.erase(neighbor_state_)
			
			node.remove_child(neighbor_state_)
			Global.num.index.state[neighbor_state_.type] = node.get_child_count() + 1
			neighbor_state_.queue_free()


	func init_hub() -> void:
		var input = {}
		input.type = "hub"
		input.mainland = mainland
		input.position = Vector2()
		
		for area in areas:
			input.position += area.lair.position
		
		input.position /= areas.size()
		hub = Global.scene.knob.instantiate()
		mainland.knobs.add_child(hub)
		hub.set_attributes(input)


	func find_nearest_empire() -> MarginContainer:
		var datas = []
		
		for empire in mainland.empires.get_children():
			if empire != areas.front().state["empire"]:
				var data = {}
				data.empire = empire
				data.d = hub.position.distance_to(empire.hub.position)
				datas.append(data)
		
		datas.sort_custom(func(a, b): return a.d < b.d)
		return datas.front().empire


	func repossess_earldom(recipient_: MarginContainer, earldom_: MarginContainer) -> void:
		earldom_.senor.detach_state(earldom_)
		
		for neighbor in earldom_.neighbors:
			var empire = neighbor.areas.front().state["empire"]
			
			if empire == recipient_:
				neighbor.senor.take_state(earldom_)
		
		
		#earldom_.senor = mainland.liberty


	func recolor_based_on_index() -> void:
		for area in areas:
			#for flap in area.flaps:
			area.visible = false


	#func hide_areas() -> void:
		#for area in areas:
			#area.hide_flaps()
#
#
	#func paint_areas(color_: Color) -> void:
		#for area in areas:
			#area.paint_flaps(color_)
