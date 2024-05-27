extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_scene()
	init_font()


func init_arr() -> void:
	arr.region = ["ne", "se", "sw", "nw", "nesw"]
	arr.terrain = ["swamp", "forest", "mountain", "plain"]
	arr.garrison = ["human", "sky", "ground"]
	arr.state = ["earldom", "dukedom", "kingdom", "empire"]
	
	arr.layer = {}
	arr.layer.mainland = ["area", "earldom", "dukedom", "kingdom"]


func init_num() -> void:
	num.index = {}
	num.index.area = 0
	num.index.trail = 0
	num.index.state = {}
	
	for state in arr.state:
		num.index.state[state] = 0
	
	num.troop = {}
	num.troop.a = 16
	
	num.garrison = {}
	num.garrison.a = num.troop.a * 2
	num.garrison.r = num.garrison.a * sqrt(2)
	
	num.mainland = {}
	num.mainland.n = 9
	num.mainland.col = num.mainland.n
	num.mainland.row = num.mainland.n
	num.mainland.a = num.garrison.a * 2.5
	
	num.area = {}
	num.area.nesw = 4
	
	num.state = {}
	num.state.n = 3
	
	num.trail = {}
	num.trail.min = 3
	num.trail.max = 4
	
	num.hand = {}
	num.hand.n = 4
	
	num.settlement = {}
	num.settlement.n = (arr.region.size() - 1) * 2


func init_dict() -> void:
	init_direction()
	init_season()
	init_area()
	init_corner()
	init_region()


func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.direction.linear2 = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2i( 1,-1),
		Vector2i( 1, 1),
		Vector2i(-1, 1),
		Vector2i(-1,-1)
	]
	dict.direction.zero = [
		Vector2i( 0, 0),
		Vector2i( 1, 0),
		Vector2i( 1, 1),
		Vector2i( 0, 1)
	]
	dict.direction.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]
	
	dict.direction.windrose = []
	
	for _i in dict.direction.linear2.size():
		var direction = dict.direction.linear2[_i]
		dict.direction.windrose.append(direction)
		direction = dict.direction.diagonal[_i]
		dict.direction.windrose.append(direction)


func init_season() -> void:
	dict.season = {}
	dict.season.phase = {}
	dict.season.phase["spring"] = ["incoming"]
	dict.season.phase["summer"] = ["selecting", "outcoming"]
	dict.season.phase["autumn"] = ["wounding"]
	dict.season.phase["winter"] = ["wilting", "sowing"]


func init_area() -> void:
	dict.area = {}
	dict.area.next = {}
	dict.area.next[null] = "discharged"
	dict.area.next["discharged"] = "available"
	dict.area.next["available"] = "hand"
	dict.area.next["hand"] = "discharged"
	dict.area.next["broken"] = "discharged"
	
	dict.area.prior = {}
	dict.area.prior["available"] = "discharged"
	dict.area.prior["hand"] = "available"


func init_corner() -> void:
	dict.order = {}
	dict.order.pair = {}
	dict.order.pair["even"] = "odd"
	dict.order.pair["odd"] = "even"
	var corners = [4]
	dict.corner = {}
	dict.corner.vector = {}
	
	for corners_ in corners:
		dict.corner.vector[corners_] = {}
		dict.corner.vector[corners_].even = {}
		
		for order_ in dict.order.pair.keys():
			dict.corner.vector[corners_][order_] = {}
		
			for _i in corners_:
				var angle = 2 * PI * _i / corners_ - PI / 2
				
				if order_ == "odd":
					angle += PI/corners_
				
				var vertex = Vector2(1,0).rotated(angle)
				dict.corner.vector[corners_][order_][_i] = vertex


func init_region() -> void:
	dict.region = {}
	dict.region.corner = {}
	dict.region.corner.ne = Vector2i(Global.num.mainland.col - 1, 0)
	dict.region.corner.se = Vector2i(Global.num.mainland.col - 1, Global.num.mainland.row - 1)
	dict.region.corner.sw = Vector2i(0, Global.num.mainland.row - 1)
	dict.region.corner.nw = Vector2i(0, 0)
	
	dict.region.direction = {}
	dict.region.direction.ne = Vector2i(-1, 1)
	dict.region.direction.se = Vector2i(-1, -1)
	dict.region.direction.sw = Vector2i(1, -1)
	dict.region.direction.nw = Vector2i(1, 1)


func init_scene() -> void:
	scene.token = load("res://scene/0/token.tscn")
	
	scene.pantheon = load("res://scene/1/pantheon.tscn")
	scene.god = load("res://scene/1/god.tscn")
	
	scene.planet = load("res://scene/2/planet.tscn")
	scene.mainland = load("res://scene/2/mainland.tscn")
	
	scene.card = load("res://scene/3/card.tscn")
	
	scene.area = load("res://scene/4/area.tscn")
	scene.trail = load("res://scene/4/trail.tscn")
	scene.region = load("res://scene/4/region.tscn")
	scene.biome = load("res://scene/4/biome.tscn")
	
	scene.settlement = load("res://scene/5/settlement.tscn")
	scene.community = load("res://scene/5/community.tscn")
	scene.borderland = load("res://scene/5/borderland.tscn")
	
	


func init_vec():
	vec.size = {}
	vec.size.sixteen = Vector2(16, 16)
	vec.size.number = Vector2(vec.size.sixteen)
	
	vec.size.token = Vector2(32, 32)
	vec.size.card = Vector2(vec.size.token.x * 2, vec.size.token.y * 4)
	vec.size.gameboard = Vector2(vec.size.token)# * 6, vec.size.token.y * 5)
	
	vec.size.garrison = Vector2.ONE * num.garrison.a
	vec.size.mainland = vec.size.garrison * 2 + (Vector2(Global.num.mainland.col, Global.num.mainland.row) - Vector2.ONE) * num.mainland.a
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	var h = 360.0
	
	color.card = {}
	color.card.selected = {}
	color.card.selected[true] = Color.from_hsv(160 / h, 0.4, 0.7)
	color.card.selected[false] = Color.from_hsv(60 / h, 0.2, 0.9)
	
	color.indicator = {}
	color.indicator.health = {}
	color.indicator.health.fill = Color.from_hsv(0 / h, 0.9, 0.7)
	color.indicator.health.background = Color.from_hsv(0 / h, 0.5, 0.9)
	color.indicator.endurance = {}
	color.indicator.endurance.fill = Color.from_hsv(270 / h, 0.9, 0.7)
	color.indicator.endurance.background = Color.from_hsv(270 / h, 0.5, 0.9)
	
	color.region = {}
	color.region.ne = Color.from_hsv(0 / h, 0.9, 0.9)
	color.region.se = Color.from_hsv(72 / h, 0.9, 0.9)
	color.region.sw = Color.from_hsv(144 / h, 0.9, 0.9)
	color.region.nw = Color.from_hsv(216 / h, 0.9, 0.9)
	color.region.nesw = Color.from_hsv(288 / h, 0.9, 0.9)
	


func init_font():
	dict.font = {}
	dict.font.size = {}
	dict.font.size["basic"] = 18
	dict.font.size["aspect"] = 24
	dict.font.size["card"] = 24
	dict.font.size["season"] = 18
	dict.font.size["phase"] = 18
	dict.font.size["moon"] = 18


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()


func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null


func get_all_constituents_based_on_limit(array_: Array, limit_: int) -> Dictionary:
	var constituents = {}
	constituents[0] = []
	constituents[1] = []
	
	for child in array_:
		constituents[0].append(child)
		
		if child.value <= limit_:
			constituents[1].append([child])
	
	for _i in array_.size()-2:
		set_constituents_based_on_size_and_limit(constituents, _i+2, limit_)
	
	var value = 0
	
	for constituent in array_:
		value += constituent.value
	
	if value <= limit_:
		constituents[array_.size()] = [constituents[0]]
	
	constituents.erase(0)
	
	for _i in range(constituents.keys().size()-1,-1,-1):
		var key = constituents.keys()[_i]
		
		if constituents[key].is_empty():
			constituents.erase(key)
	
	return constituents


func set_constituents_based_on_size_and_limit(constituents_: Dictionary, size_:int, limit_: int) -> void:
	var parents = constituents_[size_-1]
	constituents_[size_] = []
	
	for parent in parents:
		var value = 0
		
		for constituent in parent:
			value += constituent.value
		
		for child in constituents_[0]:
			if !parent.has(child) and value + child.value <= limit_:
				var constituent = []
				constituent.append_array(parent)
				constituent.append(child)
				constituent.sort_custom(func(a, b): return constituents_[0].find(a) < constituents_[0].find(b))
				
				if !constituents_[size_].has(constituent):
					constituents_[size_].append(constituent)
