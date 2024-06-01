extends MarginContainer


#region vars
@onready var bg = $BG
@onready var cost = $Cost
@onready var skills = $Skills

var proprietor = null
var area = null
var selected = false
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	area = input_.area
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Global.vec.size.card
	init_tokens(input_)
	init_bg()


func init_tokens(input_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	input.type = "card"
	input.subtype = "cost"
	input.value = input_.cost
	cost.set_attributes(input)
	
	input = {}
	input.card = self
	
	for authority in input_.authorities:
		input.authority = authority
		input.promotion = input_.authorities[authority].promotion
		input.tag = input_.authorities[authority].tag
		input.value = input_.authorities[authority].value
		
		if input_.authorities[authority].has("penalty"):
			input.penalty = input_.authorities[authority].penalty
		
		var skill = Global.scene.skill.instantiate()
		skills.add_child(skill)
		skill.set_attributes(input)


func init_bg() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.SLATE_GRAY
	bg.set("theme_override_styles/panel", style)
	set_selected(false)


func advance_area() -> void:
	var cardstack = null
	
	if area == null:
		area = Global.dict.area.next[area]
		advance_area()
	else:
		cardstack = proprietor.get(area)
		cardstack.cards.remove_child(self)
	
		area = Global.dict.area.next[area]
		cardstack = proprietor.get(area)
		cardstack.cards.add_child(self)


func set_gameboard_as_proprietor(gameboard_: MarginContainer) -> void:
	var cardstack = proprietor.get(area)
	var market = false
	
	if cardstack == null:
		cardstack = proprietor
		market = true
	
	cardstack.cards.remove_child(self)
	proprietor = gameboard_
	area = "discharged"
	
	cardstack = proprietor.get(area)
	cardstack.cards.add_child(self)
	
	set_selected(false)
	
	if !market:
		advance_area()


func set_selected(selected_: bool) -> void:
	selected = selected_
	var style = bg.get("theme_override_styles/panel")
	style.bg_color = Global.color.card.selected[selected_]
#endregion


func move_resources_into_storage() -> void:
	var storage = proprietor.god.storage
	
	for  skill in skills.get_children():
		var subtype =  skill.tag.designation.subtype
		var value =  skill.tag.get_value()
		
		storage.change_resource_value(subtype, value)
