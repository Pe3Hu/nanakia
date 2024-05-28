extends MarginContainer


#region vars
@onready var index = $Troops/Index
@onready var human = $Troops/Human
@onready var sky = $Troops/Sky
@onready var ground = $Troops/Ground

var area = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	area = input_.area

	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.garrison
	init_tokens()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "garrison"
	input.subtype = "index"
	input.value = Global.num.index.area
	index.set_attributes(input)
	Global.num.index.area += 1
	
	input.value = 0
	
	for type in Global.arr.garrison:
		input.subtype = Global.arr[type].pick_random()
		var token = get(type)
		token.set_attributes(input)


func set_troop_value(kind_: String, value_: int) -> void:
	var type = Global.dict.kind.troop[kind_]
	var troop = get(type)
	
	if troop.subtype != kind_:
		troop.set_subtype(kind_)
	
	troop.set_value(value_)


func change_troop_value(kind_: String, value_: int) -> void:
	var type = Global.dict.kind.troop[kind_]
	var troop = get(type)
	
	if troop.subtype != kind_:
		troop.set_subtype(kind_)
		troop.set_value(0)
	
	troop.change_value(value_)
#endregion
