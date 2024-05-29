extends Polygon2D


#region vars
@onready var garrison = $Garrison
@onready var settlement = $Settlement

var mainland = null
var grid = null
var conqueror = null
var neighbors = {}
var trails = {}
var areas = {}
var directions = {}
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
		settlement.set_attributes(input)
	
		for key in Global.arr.state:
			state[key] = null
	
	set_vertexs()
	set_remoteness()


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


func set_remoteness() -> void:
	var x = abs(Global.num.mainland.col / 2 - grid.x)
	var y = abs(Global.num.mainland.row / 2 - grid.y)
	remoteness.center = x + y


func paint_based_on_garrison_index() -> void:
	var h = float(garrison.index.get_value()) / Global.num.index.area
	var s = 0.75
	var v = 1
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func paint_based_on_state_type_index(type_: String) -> void:
	if state[type_] != null and state[type_] != mainland.liberty:
		var h = float(state[type_].index) / Global.num.index.state[type_]
		var s = 0.75
		var v = 1
		var color_ = Color.from_hsv(h,s,v)
		set_color(color_)
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


func get_neighbor_areas_without_state(type_: String) -> Array:
	var result = []
	
	for area in areas:
		if area.state[type_] == null:
			result.append(area)
	
	return result
