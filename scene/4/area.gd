extends Polygon2D


#region vars
@onready var garrison = $Garrison

var mainland = null
var grid = null
var neighbors = {}
var trails = {}
var areas = {}
var directions = {}
var region = null
var remoteness = {}

var state = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	grid = input_.grid

	init_basic_setting()


func init_basic_setting() -> void:
	if grid != null:
		position = grid * Global.num.mainland.a
		mainland.grids[grid] = self
		
		var input = {}
		input.area = self
		garrison.set_attributes(input)
	
		for key in Global.arr.state:
			state[key] = null
	
	set_vertexs()


func set_vertexs() -> void:
	var order = "odd"
	var corners = 4
	var r = Global.num.garrison.r
	var vertexs = []

	for corner in corners:
		var vertex = Global.dict.corner.vector[corners][order][corner] * r
		vertexs.append(vertex)
		garrison.position += vertex

	set_polygon(vertexs)
	
	garrison.position = vertexs[3]


func set_region(region_: Node2D) -> void:
	if region != null:
		region.areas.erase(self)
	
	region = region_
	region.areas.append(self)
	
	paint_to_match("region")


func paint_to_match(layer_: String) -> void:
	match layer_:
		"region":
			color = Global.color.region[region.type]
		"wilderness":
			var v = 1 - float(remoteness.settlement) / Global.num.remoteness.danger
			color = Color.from_hsv(0, 0, v)


func paint_based_on_state_type_index(type_: String) -> void:
	if state[type_] != null and state[type_] != mainland.liberty:
		var h = float(state[type_].index) / Global.num.index.state[type_]
		var s = 0.75
		var v = 1
		var color_ = Color.from_hsv(h,s,v)
		set_color(color_)
		
		state[type_].hub.visible = true
	else:
		paint_gray()


func paint_gray() -> void:
	var color_ = Color.GRAY
	set_color(color_)
#endregion


func get_trails_around_socket_perimeter() -> Array:
	var _areas = []

	for direction in Global.dict.neighbor.diagonal:
		var _grid = grid + direction
		var area = mainland.grids.area[_grid]
		_areas.append(area)

	var _trails = mainland.get_trails_based_on_areas(_areas)
	return _trails
