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
		limit = int(Global.num.state.n)
		
		if type == "earldom":
			take_area(input_.area)
		else:
			take_state(input_.state)
		
		fill_to_limit()


	func take_area(area_: Polygon2D) -> void:
		if areas.size() < limit:
			if !areas.has(area_):
				areas.append(area_)
				area_.state[type] = self
		else:
			pass


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


	func take_state(state_: State) -> void:
		if vassals.size() < limit:
			if !vassals.has(state_):
				vassals.append(state_)
				state_.senor = self
				
				for area in state_.areas:
					areas.append(area)
					area.state[type] = self
				
				var notify_senor = senor
				
				while notify_senor != null:
					for area in state_.areas:
						senor.areas.append(area)
					
					notify_senor = notify_senor.senor
		else:
			pass


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
		
		var notify_senor = senor
		
		while notify_senor != null:
			for area in state_.areas:
				senor.areas.erase(area)
			
			notify_senor = notify_senor.senor
 

	func fill_to_limit() -> void:
		if type == "earldom":
			while areas.size() < limit and !mainland.reset:
				encroach_area()
		else:
			while vassals.size() < limit and !mainland.reset:
				encroach_state()


	func encroach_area() -> void:
		var accessible_areas = get_accessible_areas()
		
		if !accessible_areas.is_empty():
			var weights = {}
			var minimum = 8
			
			for area in accessible_areas:
				if !weights.has(area):
					weights[area] = area.get_neighbor_areas_without_state(type).size()
					
					if minimum > weights[area]:
						minimum = weights[area]
			
			var options = []
		
			for area in weights:
				if weights[area] == minimum:
					options.append(area)
			
			var area = options.pick_random()
			take_area(area)
		else:
			limit = areas.size()
			pass


	func get_accessible_areas() -> Array:
		var accessible_areas = []
		
		for area in areas:
			for neighbor_area in area.areas:
				if neighbor_area.state[type] == null and !accessible_areas.has(neighbor_area):
					accessible_areas.append(neighbor_area)
		
		return accessible_areas


	func encroach_state() -> void:
		var accessible_vassals = get_accessible_vassals()
		
		if accessible_vassals.is_empty():
			mainland.reset = true
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


	func find_nearest_empire() -> MarginContainer:
		var datas = []
		
		for empire in mainland.empires.get_children():
			if empire != areas.front().state["empire"]:
				var data = {}
				data.empire = empire
				#data.d = hub.position.distance_to(empire.hub.position)
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


	func crush() -> void:
		mainland.states.erase(self)
		var states = mainland.get(type+"s")
		states.erase(self)
		
		Global.num.index.state[type] -= 1
		
		for area in areas:
			area.state[type] = null


class Challenge:
	var mainland = null
	var offensive = null
	var defensive = null
	var trail = null


	func _init(input_: Dictionary) -> void:
		for key in input_:
			set(key, input_[key])
	
		init_basic_setting()


	func init_basic_setting() -> void:
		mainland.challenges.append(self)
		mainland.planet.encounter.set_challenge(self)


class Conqueror:
	var god = null
	var mainland = null
	var areas = []


	func _init(input_: Dictionary) -> void:
		for key in input_:
			set(key, input_[key])
	
		init_basic_setting()


	func init_basic_setting() -> void:
		pass


	func annex_area(area_: Polygon2D) -> void:
		area_.conqueror = self
		areas.append(area_)
		god.society.consider_area(1, area_)


	func forfeit_area(area_: Polygon2D) -> void:
		area_.conqueror = null
		areas.erase(area_)
		god.society.consider_area(-1, area_)


class Steward:
	var god = null
	var conqueror = null
	var storage = null
	var society = null


	func _init(input_: Dictionary) -> void:
		for key in input_:
			set(key, input_[key])
	
		init_basic_setting()


	func init_basic_setting() -> void:
		conqueror = god.conqueror
		storage = god.storage
		society = god.society


	func update_resources() -> void:
		#tax_collection()
		#provide_population()
		var purposes = ["income", "expense"]
		
		for purpose in purposes:
			var description = Global.dict.resource.purpose[purpose]
			
			for resource_title in description:
				for meeple_title in description[resource_title]:
					var multiplier = description[resource_title][meeple_title]
					
					match purpose:
						"expense":
							multiplier *= -1
					
					var meeple = society.get(meeple_title)
					
					if meeple != null:
						var value = meeple.get_value() * multiplier
						
						if meeple_title == "beggar":
							value = ceil(value)
						else:
							value = ceil(value)
						
						if value != 0:
							storage.change_resource_value(resource_title, value)


	func tax_collection() -> void:
		var description = Global.dict.resource.purpose.income
		
		for resource_title in description:
			for meeple_title in description[resource_title]:
				var multiplier = description[resource_title][meeple_title]
				var meeple = society.get(meeple_title)
				var value = meeple.get_value() * multiplier
				var resource = storage.get(resource_title)
				resource.change_value(value)


	func provide_population() -> void:
		var description = Global.dict.resource.purpose.expense
		
		for resource_title in description:
			for meeple_title in description[resource_title]:
				var multiplier = description[resource_title][meeple_title]
				var meeple = society.get(meeple_title)
				var value = meeple.get_value() * multiplier
				var resource = storage.get(resource_title)
				resource.change_value(value)
