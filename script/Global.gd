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
	arr.garrison = ["human", "ground", "sky"]
	arr.state = ["earldom", "dukedom", "kingdom", "empire"]
	arr.role = ["offensive", "defensive"]
	
	arr.human = ["militia"]
	arr.ground = ["ghost", "skeleton"]
	arr.sky = ["werewolf", "vampire"]
	arr.army = ["militia", "ghost", "skeleton", "werewolf", "vampire"]
	arr.civilian = ["noble", "peasant", "beggar", "slave"]
	arr.initiative = ["vampire", "werewolf", "skeleton", "ghost", "militia"]
	
	arr.resource = ["peaceful", "lethal", "authority"]
	arr.peaceful = ["prestige", "glory", "supply", "gold"]
	arr.lethal = ["soul", "bone", "meat", "blood"]
	arr.authority = ["request", "order"]
	arr.victim = ["noble", "peasant", "beggar", "slave", "militia"]
	
	arr.layer = {}
	arr.layer.affiliation = ["area", "conqueror", "earldom", "dukedom", "kingdom"]
	arr.layer.detail = ["garrison", "settlement"]


func init_num() -> void:
	num.index = {}
	num.index.area = 0
	num.index.trail = 0
	num.index.state = {}
	num.index.god = 0
	
	for state in arr.state:
		num.index.state[state] = 0
	
	num.troop = {}
	num.troop.a = 16
	
	num.garrison = {}
	num.garrison.a = num.troop.a * 2
	num.garrison.r = num.garrison.a * sqrt(2)
	num.garrison.base = 60
	
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
	num.settlement.noble = 1.0 / 10


func init_dict() -> void:
	init_direction()
	init_season()
	init_area()
	init_corner()
	
	init_dice()
	init_resource()
	init_card()


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


func init_dice() -> void:
	dict.kind = {}
	dict.kind.power = {}
	dict.dice = {}
	dict.dice.kind = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/nanakia_dice.json"
	var array = load_data(path)
	
	for dice in array:
		dict.kind.power[dice.title] = 0
		var data = {}
		
		for key in dice:
			if !exceptions.has(key) and dice[key] > 0:
				data[int(key)] = dice[key]
				dict.kind.power[dice.title] += int(key) * dice[key]
	
		dict.dice.kind[dice.title] = data
	
	dict.kind.troop = {}
	dict.kind.troop["militia"] = "human"
	dict.kind.troop["ghost"] = "ground"
	dict.kind.troop["skeleton"] = "ground"
	dict.kind.troop["werewolf"] = "sky"
	dict.kind.troop["vampire"] = "sky"
	
	dict.kind.facet = {}
	dict.kind.facet["militia"] = "finger"
	dict.kind.facet["ghost"] = "glow"
	dict.kind.facet["skeleton"] = "bone"
	dict.kind.facet["werewolf"] = "claw"
	dict.kind.facet["vampire"] = "fang"
	
	dict.role = {}
	dict.role.opponent = {}
	dict.role.opponent["offensive"] = "defensive"
	dict.role.opponent["defensive"] = "offensive"


func init_resource() -> void:
	dict.resource = {}
	dict.resource.purpose = {}
	#var exceptions = ["title"]
	
	var path = "res://asset/json/nanakia_resource.json"
	var array = load_data(path)
	
	for resource in array:
		#var data = {}
		
		#for key in resource:
		#	data[key] = resource[key]
		
		if !dict.resource.purpose.has(resource.purpose):
			dict.resource.purpose[resource.purpose] = {}
		
		if !dict.resource.purpose[resource.purpose].has(resource.subtype):
			dict.resource.purpose[resource.purpose][resource.subtype] = {}
		
		dict.resource.purpose[resource.purpose][resource.subtype][resource.title] = resource.value
	
		#dict.resource.title[resource.title] = data


func init_card() -> void:
	dict.card = {}
	dict.card.rarity = {}
	
	var path = "res://asset/json/nanakia_card.json"
	var array = load_data(path)
	var exceptions = ["rarity", "sin", "title", "specialty", "authority"]
	
	for card in array:
		var data = {}
		data.victim = {}
		
		for key in card:
			if !exceptions.has(key):
				if !arr.victim.has(key):
					data[key] = card[key]
				else:
					data.victim[key] = card[key]
		
		if data.victim.keys().is_empty():
			data.erase("victim")
		
		if !dict.card.rarity.has(card.rarity):
			dict.card.rarity[card.rarity] = {}
		
		if !dict.card.rarity[card.rarity].has(card.sin):
			dict.card.rarity[card.rarity][card.sin] = {}
		
		if !dict.card.rarity[card.rarity][card.sin].has(card.title):
			dict.card.rarity[card.rarity][card.sin][card.title] = {}
		
		if !dict.card.rarity[card.rarity][card.sin][card.title].has(card.specialty):
			dict.card.rarity[card.rarity][card.sin][card.title][card.specialty] = {}
		
		dict.card.rarity[card.rarity][card.sin][card.title][card.specialty][card.authority] = data
	


func init_scene() -> void:
	scene.token = load("res://scene/0/token.tscn")
	scene.couple = load("res://scene/0/couple.tscn")
	
	scene.pantheon = load("res://scene/1/pantheon.tscn")
	scene.god = load("res://scene/1/god.tscn")
	
	scene.planet = load("res://scene/2/planet.tscn")
	scene.mainland = load("res://scene/2/mainland.tscn")
	
	scene.card = load("res://scene/3/card.tscn")
	scene.skill = load("res://scene/3/skill.tscn")
	
	scene.area = load("res://scene/4/area.tscn")
	scene.trail = load("res://scene/4/trail.tscn")
	
	scene.dice = load("res://scene/5/dice.tscn")
	scene.facet = load("res://scene/5/facet.tscn")
	
	


func init_vec():
	vec.size = {}
	vec.size.sixteen = Vector2(16, 16)
	vec.size.number = Vector2(vec.size.sixteen)
	
	vec.size.token = Vector2(32, 32)
	
	vec.size.garrison = Vector2.ONE * num.garrison.a
	vec.size.mainland = vec.size.garrison * 2 + (Vector2(Global.num.mainland.col, Global.num.mainland.row) - Vector2.ONE) * num.mainland.a
	
	var n = 6
	vec.size.mark = Vector2(vec.size.token) * 0.75
	vec.size.power = Vector2(vec.size.token) * 0.75
	vec.size.facet = vec.size.mark + vec.size.power * 0.75
	vec.size.encounter = Vector2(vec.size.facet.x * (2 * n + 1), vec.size.facet.y * n)
	
	vec.size.couple = Vector2(vec.size.token) * 0.75
	vec.size.cost = Vector2(vec.size.token) * 0.75
	vec.size.card = Vector2(vec.size.couple.x + vec.size.cost.x, vec.size.couple.y * 2)
	vec.size.skill = Vector2(vec.size.token) 
	vec.size.gameboard = Vector2(vec.size.card.x * 5, vec.size.card.y)# * 6, vec.size.token.y * 5)
	
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
	
	color.card.profit = {}
	color.card.profit[true] = Color.from_hsv(120 / h, 0.4, 0.7)
	color.card.profit[false] = Color.from_hsv(0 / h, 0.2, 0.9)


func init_font():
	dict.font = {}
	dict.font.size = {}
	dict.font.size["basic"] = 18
	dict.font.size["aspect"] = 24
	dict.font.size["cost"] = 18
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
