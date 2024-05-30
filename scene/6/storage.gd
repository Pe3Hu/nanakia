extends MarginContainer


#region vars
@onready var prestige = $Resources/Peaceful/Prestige
@onready var glory = $Resources/Peaceful/Glory
@onready var supply = $Resources/Peaceful/Supply
@onready var gold = $Resources/Peaceful/Gold
@onready var soul = $Resources/Lethal/Soul
@onready var bone = $Resources/Lethal/Bone
@onready var meat = $Resources/Lethal/Meat
@onready var blood = $Resources/Lethal/Blood

var god = null
var market = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_resources()


func init_resources() -> void:
	for type in Global.arr.resource:
		for subtype in Global.arr[type]:
			var input = {}
			input.proprietor = self
			input.type = "resource"
			input.subtype = subtype
			input.value = 0
			
			var resource = get(subtype)
			resource.set_attributes(input)


func reset() -> void:
	for type in Global.arr.resource:
		for subtype in Global.arr[type]:
			var resource = get(subtype)
			resource.set_value(0)
#endregion


func change_resource_value(subtype_: String, value_: int) -> void:
	var resource = get(subtype_)
	resource.change_value(value_)
