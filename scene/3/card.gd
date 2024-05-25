extends MarginContainer


#region vars
@onready var bg = $BG

var proprietor = null
var area = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	area = input_.area
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.card
	init_bg()


func init_bg() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.SLATE_GRAY
	bg.set("theme_override_styles/panel", style)


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
	
	if !market:
		advance_area()
#endregion

