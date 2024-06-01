extends MarginContainer


#region vars
@onready var prestige = $Resources/VBox/Peaceful/Prestige
@onready var glory = $Resources/VBox/Peaceful/Glory
@onready var supply = $Resources/VBox/Peaceful/Supply
@onready var gold = $Resources/VBox/Peaceful/Gold
@onready var soul = $Resources/VBox/Lethal/Soul
@onready var bone = $Resources/VBox/Lethal/Bone
@onready var meat = $Resources/VBox/Lethal/Meat
@onready var blood = $Resources/VBox/Lethal/Blood
@onready var request = $Resources/Authority/Request
@onready var order = $Resources/Authority/Order

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
			input.type = "tag"
			input.subtype = subtype
			input.value = 0
			
			var resource = get(subtype)
			resource.set_attributes(input)


func refill_authority() -> void:
	var values = {}
	values.request = 2
	values.order = 1
	
	for subtype in values:
		var value = values[subtype]
		var resource = get(subtype)
		resource.set_value(value)


func reset() -> void:
	for type in Global.arr.resource:
		for subtype in Global.arr[type]:
			var resource = get(subtype)
			resource.set_value(0)
#endregion


func change_resource_value(subtype_: String, value_: int) -> void:
	var resource = get(subtype_)
	resource.change_value(value_)
