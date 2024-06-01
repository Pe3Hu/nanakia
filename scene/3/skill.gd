extends MarginContainer


#region vars
@onready var bg = $BG
@onready var authority = $HBox/Authority
@onready var victims = $HBox/Victims
@onready var tag = $HBox/Tag
@onready var penalty = $HBox/Penalty

var card = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	card = input_.card
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Global.vec.size.skill
	init_icons(input_)


func init_icons(input_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	input.type = "tag"
	#input.type = "authority"
	input.subtype = input_.authority
	input.value = input_.promotion
	authority.set_attributes(input)
	authority.custom_minimum_size = Global.vec.size.skill
	
	input.subtype = input_.tag
	input.value = input_.value
	tag.set_attributes(input)
	tag.set_bg_color(Global.color.card.profit[true])
	
	if input_.has("penalty"):
		input.type = "tag"
		input.subtype = "supply"
		input.value = input_.penalty
		penalty.set_attributes(input)
		penalty.set_bg_color(Global.color.card.profit[false])
#endregion
