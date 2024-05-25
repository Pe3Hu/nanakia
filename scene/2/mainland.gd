extends MarginContainer


#region var
@onready var areas = $Areas
@onready var trails = $Trails
@onready var regions = $Regions
@onready var biomes = $Biomes

var planet = null
var policy = null
var grids = {}

var states = []
var earldoms = []
var dukedoms = []
var kingdoms = []
var empires = []
var layer = 0
var corners = {}
var liberty = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.mainland
	policy = planet.policy
	init_offsets()
	init_areas()
	init_trails()
	
	init_states()
	
	#init_regions()
	#init_biomes()
	#policy.init_communities()
	#paint_areas("region")
	
	layer = 1
	shift_layer(0)
	
	
	#for area in areas.get_children():
		#var n = area.remoteness.center
		#var h = 1 - float(n) / (Global.num.area.n- 1)
		#area.color = Color.from_hsv(h, 1.0, 1.0)
		


func init_offsets() -> void:
	var offest = Global.vec.size.garrison * 1
	var keys = ["trails", "areas"]
	
	for key in keys:
		var node = get(key)
		node.position = offest


func init_areas() -> void:
	var _corners = {}
	_corners.x = [0, Global.num.mainland.col - 1]
	_corners.y = [0, Global.num.mainland.row - 1]
	
	for _i in Global.num.mainland.row:
		for _j in Global.num.mainland.col:
			var input = {}
			input.mainland = self
			input.grid = Vector2i(_j, _i)
			
			if _corners.y.has(_i) or _corners.x.has(_j):
				if _corners.y.has(_i) and _corners.x.has(_j):
					input.type = "corner"
				else:
					input.type = "edge"
			else:
				input.type = "center"
	
			var area = Global.scene.area.instantiate()
			areas.add_child(area)
			area.set_attributes(input)


func init_trails() -> void:
	for area in areas.get_children():
		for direction in Global.dict.direction.windrose:
			var grid = area.grid + direction

			if grids.has(grid):
				var neighbor = grids[grid]
				
				if !area.neighbors.has(neighbor):
					add_trail(area, neighbor, direction)
	
	clear_intersecting_trails()
	clear_redundant_trails()


func add_trail(first_: Polygon2D, second_: Polygon2D, direction_: Vector2i) -> void:
	var input = {}
	input.mainland = self
	input.areas = [first_, second_]

	var trail = Global.scene.trail.instantiate()
	trails.add_child(trail)
	trail.set_attributes(input)

	first_.neighbors[second_] = trail
	second_.neighbors[first_] = trail
	first_.trails[trail] = second_
	second_.trails[trail] = first_
	first_.areas[second_] = trail
	second_.areas[first_] = trail
	first_.directions[direction_] = trail
	var index = Global.dict.direction.windrose.find(direction_)
	var n = Global.dict.direction.windrose.size()
	index = (index + n / 2) % n
	second_.directions[Global.dict.direction.windrose[index]] = trail


func clear_intersecting_trails() -> void:
	var n = Global.num.mainland.n - 1
	var k = Global.num.mainland.n - 2
	var exceptions = []
	exceptions.append(Vector2i(0, 0))
	exceptions.append(Vector2i(k, 0))
	exceptions.append(Vector2i(k, k))
	exceptions.append(Vector2i(0, k))
	var directions = []
	directions.append(Vector2i(1, -1))
	directions.append(Vector2i(1, 1))
	directions.append(Vector2i(1, -1))
	directions.append(Vector2i(1, 1))
	var offsets = []
	offsets.append(Vector2i(0, 1))
	offsets.append(Vector2i(0, 0))
	offsets.append(Vector2i(0, 1))
	offsets.append(Vector2i(0, 0))
	
	for _i in n:
		for _j in n:
			var grid = Vector2i(_j, _i)
			
			if !exceptions.has(grid):
				var options = []
				var area = grids[grid]
				var direction = Vector2i(1, 1)
				var trail = area.directions[direction]
				options.append(trail)
				
				grid.x += 1
				area = grids[grid]
				direction = Vector2i(-1, 1)
				trail = area.directions[direction]
				options.append(trail)
				
				trail = options.pick_random()
				trail.crush()
	
	for _i in exceptions.size():
		var grid = exceptions[_i] + offsets[_i]
		var area = grids[grid]
		var direction = directions[_i]
		var trail = area.directions[direction]
		trail.crush()


func clear_redundant_trails() -> void:
	var redundants = {}
	var exceptions = []
	var maximum = 0
	
	for area in areas.get_children():
		var n = area.trails.keys().size()
		
		if n > Global.num.trail.min:
			if !redundants.has(n):
				redundants[n] = []
				
				if maximum < n:
					maximum = int(n)
			
			redundants[n].append(area)
		else:
			exceptions.append(area)
	
	#remove trails from areas with a maximum number of links
	while maximum > Global.num.trail.max:
		if redundants[maximum].is_empty():
			redundants.erase(maximum)
			maximum -= 1
		else:
			var area = redundants[maximum].pick_random()
			var options = []
			
			for trail in area.trails:
				if !exceptions.has(area.trails[trail]):
					options.append(trail)
			
			if !options.is_empty():
				var trail = options.pick_random()
				var flag = true
				
				for _area in trail.areas:
					if exceptions.has(_area):
						flag = false
			
				if flag:
					var keys = redundants.keys()
					keys.sort()
					
					for _area in trail.areas:
						for _i in keys:
							if redundants[_i].has(_area):
								redundants[_i].erase(_area)
								var _j = _i - 1
								
								if _j > Global.num.trail.min:
									redundants[_j].append(_area)
								else:
									exceptions.append(_area)
					
					trail.crush()
			else:
				redundants[maximum].erase(area)
	
	#add trails for areas with a minimum number of links
	var datas = []
	
	for area in areas.get_children():
		if !redundants[Global.num.trail.max].has(area):
			var data = {}
			data.area = area
			data.areas = []
			
			for _area in area.neighbors:
				if !redundants[Global.num.trail.max].has(_area) and !area.areas.has(_area):
					if !check_intersecting(area, _area):
						data.areas.append(_area)
			
			datas.append(data)
	
	datas.sort_custom(func(a, b): return a.areas.size() < b.areas.size())
	
	while !datas.is_empty():
		var data = datas.pop_front()
		
		if !data.areas.is_empty():
			var options = []
			
			for _data in datas:
				if _data.areas.has(data.area):
					options.append(_data)
			
			if !options.is_empty():
				options.sort_custom(func(a, b): return a.areas.size() < b.areas.size())
				var option = options.pop_front()
				datas.erase(option)
				var _areas = [data.area, option.area]
				
				for _data in datas:
					for area in _areas:
						if _data.areas.has(area):
							_data.areas.erase(area)
				
				var direction = _areas.back().grid - _areas.front().grid
				add_trail(_areas.front(), _areas.back(), direction)
	
	#for area in areas.get_children():
		#var n = area.trails.keys().size() - Global.num.trail.min
		#var hue = float(n) / 6
		#area.color = Color.from_hsv(hue, 0.9, 0.9)
		#
		#if n == -1:
			#area.color = Color.BLACK


func check_intersecting(first_: Polygon2D, second_: Polygon2D) -> bool:
	var direction = second_.grid - first_.grid
	var grid = first_.grid + Vector2i(direction.x, 0)
	var first = grids[grid]
	grid = first_.grid + Vector2i(0, direction.y)
	var second = grids[grid]
	
	return first.areas.has(second)


func init_regions() -> void:
	for type in Global.arr.region:
		add_region(type)


func add_region(type_: String) -> void:
	var input = {}
	input.mainland = self
	input.type = type_
	
	var region = Global.scene.region.instantiate()
	regions.add_child(region)
	region.set_attributes(input)


func get_region(windrose_: String) -> Variant:
	for region in regions.get_children():
		if region.type == windrose_:
			return region
	
	return null


func get_area_based_on_grid(grid_: Vector2i) -> Variant:
	grid_.x = int(grid_.x)
	grid_.y = int(grid_.y)
	
	
	if grids.has(grid_):
		return grids[grid_]
	
	return null
#endregion


#region state
func init_states() -> void:
	liberty = Node2D.new()
	corners.area = []
	
	for area in areas.get_children():
		if area.neighbors.keys().size() == 3:
			corners.area.append(area)
	
	for key in Global.arr.state:
		Global.num.index.state[key] = 0
		
	var type = Global.arr.state.front()
	lay_foundation_of_states(type)
	#spread_states(type)
	#set_earldom_neighbors(type)
	#
	#for _i in range(1, Global.arr.state.size()):
		#type = Global.arr.state[_i]
		#lay_foundation_of_states(type)
		#spread_states(type)
		#set_state_neighbors(type)
	#
	#absorb_smaller_empires()
	#update_seam_boundaries()


func do_dukedom():
	var type = Global.arr.state[1]
	add_new_senor(type)
	shift_layer(0)


func lay_foundation_of_states(type_: String) -> void:
	for area in corners.area:
		var input = {}
		input.mainland = self
		input.type = type_
		
		if type_ == "earldom":
			input.area = area
		else:
			var index = Global.arr.state.find(type_) - 1
			var vassal = Global.arr.state[index]
			input.state = area.state[vassal]
		
		var _state = Classes.State.new(input)


func spread_states(type_: String) -> void:
	if type_ == "earldom":
		var end = add_new_earldom()
		
		while !end:
			end = add_new_earldom()
	else:
		var end = add_new_senor(type_)
		
		while !end:
			end = add_new_senor(type_)


func add_new_earldom() -> bool:
	var type = "earldom"
	var undeveloped = []
	var node = get(type+"s")
	
	for state in node.get_children():
		var accessible = state.get_accessible_areas()
		undeveloped.append_array(accessible)
	
	if !undeveloped.is_empty():
		var input = {}
		input.type = type
		input.mainland = self
		var neighbors = {}
		neighbors.accessible = []
		neighbors.big = []
		neighbors.small = []
		input.area = undeveloped.pick_random()
		
		for seam in input.area.neighbors:
			var neighbor = input.area.neighbors[seam]
			
			if neighbor.state[type] == null:
				neighbors.accessible.append(neighbor)
			else:
				match neighbor.state[type].limit:
					2:
						neighbors.small.append(neighbor)
					3:
						neighbors.big.append(neighbor)
		
		if neighbors.accessible.is_empty():
			var occupied_area = null
			
			if neighbors.small.is_empty():
				if !neighbors.big.is_empty():
					occupied_area = neighbors.big.pick_random()
				else:
					input.area.state[type] = liberty
			else:
				occupied_area = neighbors.small.pick_random()
			
			if occupied_area != null:
				occupied_area.state[type].take_area(input.area)
		else:
			var state = Global.scene.state.instantiate()
			node.add_child(state)
			state.set_attributes(input)
		return false
	
	return true


func add_new_senor(type_: String) -> bool:
	var node = get(type_+"s")
	var undeveloped = []
	
	for state in node.get_children():
		var accessible_vassals = state.get_accessible_vassals()
		undeveloped.append_array(accessible_vassals)
	
	if !undeveloped.is_empty():
		var input = {}
		input.type = type_
		input.mainland = self
		var neighbors = {}
		neighbors.accessible = []
		neighbors.big = []
		neighbors.small = []
		
		input.state = undeveloped.pick_random()
		
		for neighbor in input.state.neighbors:
			if neighbor.senor == null and neighbor.type == input.state.type:
				neighbors.accessible.append(neighbor)
			else:
				match neighbor.senor.limit:
					2:
						neighbors.small.append(neighbor.senor)
					3:
						neighbors.big.append(neighbor.senor)
		
		if neighbors.accessible.is_empty():# and (type_ != "empire" or empires.get_child_count() < Global.num.size.empire.limit):
			var occupied_state = null
			
			if neighbors.small.is_empty():
				if !neighbors.big.is_empty():
					occupied_state = neighbors.big.pick_random()
			else:
				occupied_state = neighbors.small.pick_random()
			
			if occupied_state != null:
				occupied_state.take_state(input.state)
			else:
				input.state.senor = liberty
		else:
			var state = Global.scene.state.instantiate()
			node.add_child(state)
			state.set_attributes(input)
		
		return false
	
	return true


func set_earldom_neighbors(type_: String) -> void:
	var node = get(type_+"s")
	
	for state in node.get_children():
		for area in state.areas:
			for seam in area.neighbors:
				var neighbor = area.neighbors[seam]
				var neighbor_state = neighbor.state[type_]
				
				if !state.neighbors.has(neighbor_state) and neighbor_state != state and neighbor_state != liberty:
					state.neighbors.append(neighbor_state)
					neighbor_state.neighbors.append(state)


func set_state_neighbors(type_: String) -> void:
	var node = get(type_+"s")
	
	for state in node.get_children():
		for vassal in state.vassals:
			for neighbor in vassal.neighbors:
				if neighbor.senor != null and neighbor.senor != liberty:
					if !state.neighbors.has(neighbor.senor) and neighbor.senor != state and neighbor.senor.type == state.type:
						state.neighbors.append(neighbor.senor)


func expand_empires() -> void:
	for empire in empires.get_children():
		empire.limit += 1
		empire.fill_to_limit()
		empire.limit = empire.vassals.size()


func absorb_smaller_empires() -> void:
	while empires.get_child_count() > Global.num.size.empire.limit:
		var datas = []
		
		for empire in empires.get_children():
			var data = {}
			data.empire = empire
			data.areas = empire.areas.size()
			datas.append(data)
		
		datas.sort_custom(func(a, b): return a.areas < b.areas)
		
		var smaller_empire = datas.front().empire
		
		for data in datas:
			if smaller_empire.neighbors.has(data.empire):
				data.empire.absorb_neighbor_state(smaller_empire)
				break
#endregion


#region paint
func shift_layer(shift_: int) -> void:
	var index = 9 
	
	if layer != null:
		index = Global.arr.layer.mainland.find(layer)
		index = (index + shift_ + Global.arr.layer.mainland.size()) % Global.arr.layer.mainland.size()
	
	layer = Global.arr.layer.mainland[index]
	
	#for knob in knobs.get_children():
		#if knob.type == "hub" :
			#knob.visible = false
		#else:
			#if knob.type != "lair" and knob.type != "capital":
				#knob.visible = false
	
	for area in areas.get_children():
		match layer:
			"area":
				area.paint_based_on_index()
			"earldom":
				area.paint_based_on_state_type_index(layer)
			#"dukedom":
				#area.paint_based_on_state_type_index(layer)
			#"kingdom":
				#area.paint_based_on_state_type_index(layer)
			#"empire":
				#area.paint_based_on_state_type_index(layer)
			#"realm":
				#area.paint_based_on_terrain()
				##area.paint_based_on_realm_terrain()
	#
	#for seam in seams.get_children():
		#if Global.arr.state.has(layer):
			#seam.visible = seam.boundary.state[layer]
		#else:
##			if layer == "terrain":
##				seam.visible = !seam.boundary.realms.is_empty()
##			else:
			#if layer == "realm":
				#seam.visible = !seam.boundary.realms.is_empty()
			#else:
				#seam.visible = seam.boundary.area


func paint_areas(layer_: String) -> void:
	reset_areas_color()
	
	for area in areas.get_children():
		match layer_:
			"region":
				area.paint_to_match("region")


func reset_areas_color() -> void:
	for area in areas.get_children():
		area.color = Color.GRAY
#endregion
