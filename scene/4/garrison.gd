extends MarginContainer


#region vars
@onready var index = $HBox/Index
@onready var human = $HBox/Troops/Human
@onready var sky = $HBox/Troops/Sky
@onready var ground = $HBox/Troops/Ground

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
	input.type = "index"
	input.subtype = "trail"
	input.value = Global.num.index.area
	index.set_attributes(input)
	Global.num.index.area += 1
	
	input.value = Global.num.index.area % 10
	
	for type in Global.arr.garrison:
		var token = get(type)
		token.set_attributes(input)
#endregion
