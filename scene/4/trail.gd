extends Line2D


#region vars
@onready var index = $Index
@onready var first = $First
@onready var second = $Second

var mainland = null
var areas = []
var status = null
var side = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	areas = input_.areas

	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	set_vertexs()
	#advance_status()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "trail"
	input.subtype = "index"
	input.value = Global.num.index.trail
	index.set_attributes(input)
	Global.num.index.trail += 1
	
	input.proprietor = self
	input.type = "trail"
	input.subtype = "index"
	input.value = 0
	first.set_attributes(input)
	second.set_attributes(input)


func set_vertexs() -> void:
	for area in areas:
		var vertex = area.position
		add_point(vertex)
		index.position += vertex

	index.position /= areas.size()
	#index.position -= index.custom_minimum_size * 0.5
	
	var direction = index.position - areas.front().position
	first.position = index.position - direction * 0.25
	
	direction = index.position - areas.back().position
	second.position = index.position - direction * 0.25
	var keys = ["index", "first", "second"]
	
	for key in keys:
		var token = get(key)
		token.position -= index.custom_minimum_size * 0.25


func advance_status() -> void:
	status = Global.dict.chain.status[status]
	paint_to_match()


func paint_to_match() -> void:
	default_color = Global.color.trail[status]


func crush() -> void:
	for area in areas:
		for direction in area.directions:
			if area.directions[direction] == self:
				area.directions.erase(direction)
		
		for _area in area.areas:
			if area.areas[_area] == self:
				area.areas.erase(_area)
		
		area.trails.erase(self)
	
	mainland.trails.remove_child(self)
	queue_free()
#endregion


func get_another_area(area_: Polygon2D) -> Variant:
	if areas.has(area_):
		for area in areas:
			if area != area_:
				return area

	return null


func update_axis() -> void:
	for axis in Global.arr.axis:
		var flag = true

		for area in areas:
			flag = flag and mainland.axises.area[axis].has(area)

		if flag:
			mainland.axises.trail[axis].append(self)
			update_side()


func update_side() -> void:
	var sides = {}

	for area in areas:
		for _side in area.sides:
			if !sides.has(_side):
				sides[_side] = 0

			sides[_side] += 1

	for _side in sides:
		if sides[_side] == 2:
			side = _side
			mainland.sides.trail[side].append(self)
