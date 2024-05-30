extends MarginContainer


#region vars
@onready var power = $Troops/Power
@onready var human = $Troops/Human
@onready var sky = $Troops/Sky
@onready var ground = $Troops/Ground

var area = null
var balance = 0
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
	input.type = "army"
	input.subtype = "power"
	input.value = 0
	power.set_attributes(input)
	
	for type in Global.arr.garrison:
		input.subtype = Global.arr[type].pick_random()
		var token = get(type)
		token.set_attributes(input)


func set_troop_value(kind_: String, value_: int) -> void:
	var type = Global.dict.kind.troop[kind_]
	var troop = get(type)
	var value = troop.get_value()
	
	if troop.subtype != kind_:
		balance += value
		value *= Global.dict.kind.power[troop.subtype] * -1
		power.change_value(value)
		
		troop.set_subtype(kind_)
	
	troop.set_value(value_)
	value = value_ * Global.dict.kind.power[kind_]
	power.change_value(value)
	
	if type == "human":
		balance += value_
	else: 
		balance -= value_


func change_troop_value(kind_: String, value_: int) -> void:
	var type = Global.dict.kind.troop[kind_]
	var troop = get(type)
	var value = troop.get_value()
	
	if troop.subtype != kind_:
		balance += value
		value *= Global.dict.kind.power[troop.subtype] * -1
		power.change_value(value)
		
		troop.set_subtype(kind_)
		troop.set_value(0)
	
	troop.change_value(value_)
	value = value_ * Global.dict.kind.power[kind_]
	power.change_value(value)
	
	if type == "human":
		balance += value_
	else: 
		balance -= value_


func get_troop_value(kind_: String) -> int:
	var type = Global.dict.kind.troop[kind_]
	var troop = get(type)
	
	if troop.subtype == kind_:
		return troop.get_value()
	
	return 0


func get_power_value() -> int:
	var troop = get("power")
	return troop.get_value()
#endregion
