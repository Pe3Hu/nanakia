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
var challenges = []
var layer = {}
var corners = {}
var liberty = null
var reset = false
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.mainland
	init_offsets()
	init_areas()
	init_trails()
	
	init_states()
	refill_garrisons()
	refill_settlements()
	init_challenges()
	
	layer = {}
	layer.affiliation = Global.arr.layer.affiliation[1]
	layer.detail = Global.arr.layer.detail[0]
	shift_layer("affiliation", 0)
	shift_layer("detail", 0)


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


func refill_garrisons() -> void:
	for area in areas.get_children():
		random_fill_garrison(area.garrison)


func random_fill_garrison(garrison_: MarginContainer) -> void:
	var limit = int(Global.num.garrison.base)
	var kinds = {}
	
	for type in Global.arr.garrison:
		var options = Global.arr[type]
		var kind = options.pick_random()
		kinds[kind] = Global.arr.army.find(kind) + 1
		
		if kind != "human":
			garrison_.set_troop_value(kind, 0)
	
	while limit > 0 and !kinds.is_empty():
		var kind = kinds.keys().pick_random()#Global.get_random_key(kinds)
		var power = Global.dict.kind.power[kind]
		
		if limit >= power:
			Global.rng.randomize()
			var value = Global.rng.randi_range(1, 3)
			value = min(floor(float(limit)/power), value)
			
			limit -= value * power
			garrison_.change_troop_value(kind, value)
		else:
			kinds.erase(kind)
	
	balance_militia_garrison(garrison_)


func balance_militia_garrison(garrison_: MarginContainer) -> void:
	if garrison_.balance < 0:
		var types = ["ground", "sky"]
		var base = 12
		var weights = {}
			
		for type in types:
			var troop = garrison_.get(type)
			
			if garrison_.get_troop_value(troop.subtype) > 0:
				weights[troop.subtype] = base - Global.dict.kind.power[troop.subtype]
		
		while garrison_.balance < 0 and !weights.keys().is_empty():
			var kind = Global.get_random_key(weights)
			garrison_.change_troop_value(kind, -1)
			garrison_.change_troop_value("militia", 1)
			
			if garrison_.get_troop_value(kind) == 0:
				weights.erase(kind)
		
		var reinforcement = floor((Global.num.garrison.base - garrison_.get_power_value()) / Global.dict.kind.power["militia"])
		garrison_.change_troop_value("militia", reinforcement)




func refill_settlements() -> void:
	for state in earldoms:
		random_fill_state_settlements(state)


func random_fill_state_settlements(state_: Classes.State) -> void:
	var limit = 100
	var weights = {}
	weights["noble"] = 2
	weights["peasant"] = 9
	weights["beggar"] = 3
	weights["slave"] = 1
	var _areas = []
	
	while limit > 0:
		if _areas.is_empty():
			_areas.append_array(state_.areas)
			_areas.shuffle()
		
		var area = _areas.pop_front()
		var kind = Global.get_random_key(weights)
		Global.rng.randomize()
		var value = Global.rng.randi_range(1, ceil(float(limit) / 10))
		area.settlement.change_resident_value(kind, value)
		limit -= value
	
	for area in state_.areas:
		while area.settlement.population * Global.num.settlement.noble < area.settlement.noble.get_value():
			area.settlement.elevator("noble", "peasant")


func init_challenges() -> void:
	var input = {}
	input.mainland = self
	input.offensive = areas.get_child(0).garrison
	input.defensive = areas.get_child(1).garrison
	#var _challenge = Classes.Challenge.new(input)


func check_intersecting(first_: Polygon2D, second_: Polygon2D) -> bool:
	var direction = second_.grid - first_.grid
	var grid = first_.grid + Vector2i(direction.x, 0)
	var first = grids[grid]
	grid = first_.grid + Vector2i(0, direction.y)
	var second = grids[grid]
	
	return first.areas.has(second)


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
	
	reinit_states()


func reinit_states() -> void:
	reset = false
	reset_states()
	
	for type in Global.arr.state:
		lay_foundation_of_states(type)
		spread_states(type)
		set_state_neighbors(type)
	
	if reset:
		reinit_states()
	
	#absorb_smaller_empires()
	#update_seam_boundaries()


func reset_states() -> void:
	for type in Global.arr.state:
		var _states = get(type+"s")
		
		while !_states.is_empty():
			var state = _states.front()
			state.crush()


func lay_foundation_of_states(type_: String) -> void:
	if !reset:
		#for area in corners.area:
		var area = corners.area.pick_random()
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
	if !reset:
		if type_ == "earldom":
			var end = add_new_earldom()
			
			while !end and !reset:
				end = add_new_earldom()
		else:
			var end = add_new_senor(type_)
			
			while !end and !reset:
				end = add_new_senor(type_)


func add_new_earldom() -> bool:
	var type = "earldom"
	var undeveloped = {}
	var extreme = {}
	extreme.isolation = 8
	extreme.edge = 0
	var _states = get(type + "s")
	
	for state in _states:
		var _areas = state.get_accessible_areas()
	
		for area in _areas:
			if !undeveloped.has(area):
				undeveloped[area] = area.get_neighbor_areas_without_state(type).size()
				
				if extreme.edge < area.remoteness.center:
					extreme.edge = area.remoteness.center
	
	if !undeveloped.keys().is_empty():
		var data = {}
		data.edges = []
		data.isolations = []
		
		for area in undeveloped:
			if area.remoteness.center == extreme.edge:
				data.edges.append(area)
				
				if extreme.isolation > undeveloped[area]:
					extreme.isolation = undeveloped[area]
		
		for area in data.edges:
			if undeveloped[area] == extreme.isolation:
				data.isolations.append(area)
		
		var input = {}
		input.type = type
		input.mainland = self
		input.area = data.isolations.pick_random()
		var _state = Classes.State.new(input)
		return false
	
	return true


func add_new_senor(type_: String) -> bool:
	var _states = get(type_ + "s")
	var undeveloped = {}
	var extreme = {}
	extreme.isolation = 8
	extreme.edge = 0
	
	for state in _states:
		var _areas = state.get_accessible_areas()
	
		for area in _areas:
			if !undeveloped.has(area):
				undeveloped[area] = area.get_neighbor_areas_without_state(type_).size()
				
				if extreme.edge < area.remoteness.center:
					extreme.edge = area.remoteness.center
	
	if !undeveloped.keys().is_empty():
		var data = {}
		data.isolations = []
		data.edges = []
		
		for area in undeveloped:
			if area.remoteness.center == extreme.edge:
				data.edges.append(area)
				
				if extreme.isolation > undeveloped[area]:
					extreme.isolation = undeveloped[area]
		
		for area in data.edges:
			if undeveloped[area] == extreme.isolation:
				data.isolations.append(area)
		
		var input = {}
		input.type = type_
		input.mainland = self
		input.area = data.edges.pick_random()
		
		var index = Global.arr.state.find(type_) - 1
		var vassal = Global.arr.state[index]
		input.state = input.area.state[vassal]
		var _state = Classes.State.new(input)
		return false
	
	return true


func set_earldom_neighbors() -> void:
	var type = "earldom"
	var _states = get(type+"s")
	
	if _states.size() != 27:
		#print("fail _states.size()")
		reset = true
		return
	
	for state in _states:
		for area in state.areas:
			for neighbor_area in area.areas:
				if !state.areas.has(neighbor_area):
					var neighbor_state = neighbor_area.state[type]
					
					if neighbor_state == null:
						#print("fail neighbor_state")
						reset = true
						return
				
					if !state.neighbors.has(neighbor_state) and neighbor_state != liberty:
						state.neighbors.append(neighbor_state)
						neighbor_state.neighbors.append(state)


func set_state_neighbors(type_: String) -> void:
	if !reset:
		if type_ == "earldom":
			set_earldom_neighbors()
		else:
			var _states = get(type_+"s")
			
			for state in _states:
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
func shift_layer(subtype_: String, shift_: int) -> void:
	var index = 0
	
	if layer != null:
		index = Global.arr.layer[subtype_].find(layer[subtype_])
		index = (index + shift_ + Global.arr.layer[subtype_].size()) % Global.arr.layer[subtype_].size()
	
	layer[subtype_] = Global.arr.layer[subtype_][index]
	
	for area in areas.get_children():
		match subtype_:
			"affiliation":
				match layer[subtype_]:
					"area":
						area.paint_based_on_garrison_index()
					"conqueror":
						area.paint_based_on_god_index()
					"earldom":
						area.paint_based_on_state_type_index(layer[subtype_])
					"dukedom":
						area.paint_based_on_state_type_index(layer[subtype_])
					"kingdom":
						area.paint_based_on_state_type_index(layer[subtype_])
					"empire":
						area.paint_based_on_state_type_index(layer[subtype_])
			"detail":
				area.set_detail(layer[subtype_])


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
