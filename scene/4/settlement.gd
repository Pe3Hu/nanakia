extends MarginContainer


#region vars
@onready var aristocrat = $Residents/Aristocrat
@onready var peasant = $Residents/Peasant
@onready var beggar= $Residents/Beggar
@onready var slave = $Residents/Slave

var area = null
var population = 0
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
	input.type = "civilian"
	input.subtype = "civilian"#Global.arr[type].pick_random()
	input.value = 0
	
	for type in Global.arr.civilian:
		var token = get(type)
		token.set_attributes(input)


func set_resident_value(type_: String, value_: int) -> void:
	var resident = get(type_)
	population -= resident.get_value()
	resident.set_value(value_)
	population += value_


func change_resident_value(type_: String, value_: int) -> void:
	var resident = get(type_)
	resident.change_value(value_)
	population += value_


func get_resident_value(type_: String) -> int:
	var resident = get(type_)
	return resident.get_value()


func elevator(from_: String, where_: String) -> void:
	var value = 1
	var resident = {}
	resident.from = get(from_)
	resident.where = get(where_)
	resident.from.change_value(-value)
	resident.where.change_value(value)
#endregion
