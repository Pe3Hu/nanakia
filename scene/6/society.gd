extends MarginContainer


#region vars
@onready var army = $VBox/Army
@onready var civilian = $VBox/Civilian
@onready var militia = $VBox/Army/Militia
@onready var ghost = $VBox/Army/Ghost
@onready var skeleton = $VBox/Army/Skeleton
@onready var werewolf = $VBox/Army/Werewolf
@onready var vampire = $VBox/Army/Vampire
@onready var noble = $VBox/Civilian/Noble
@onready var peasant = $VBox/Civilian/Peasant
@onready var beggar = $VBox/Civilian/Beggar
@onready var slave = $VBox/Civilian/Slave

var god = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()


func init_tokens() -> void:
	var types = ["army", "civilian"]
	var input = {}
	input.proprietor = self
	input.value = 0
	
	for type in types:
		input.type = type
		
		for subtype in Global.arr[type]:
			input.subtype = subtype
			var token = get(subtype)
			token.set_attributes(input)
#endregion


func consider_area(sign_: int, area_: Polygon2D) -> void:
	var types = ["army", "civilian"]
	var input = {}
	input.proprietor = self
	input.value = 0
	
	for type in types:
		input.type = type
		
		for subtype in Global.arr[type]:
			input.subtype = subtype
			var token = get(subtype)
			var value = int(sign_)
			
			match type:
				"army":
					value *= area_.garrison.get_troop_value(subtype)
				"civilian":
					value *= area_.settlement.get_resident_value(subtype)
			
			token.change_value(value)
