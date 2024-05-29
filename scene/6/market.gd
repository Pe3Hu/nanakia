extends MarginContainer


#region vars
@onready var cards = $Cards

var planet = null
var capacity = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	capacity.current = 6
	capacity.limit = 6
	refill_cards()


func refill_cards() -> void:
	while cards.get_child_count() < capacity.current:
		add_card()


func add_card() -> void:
	var input = {}
	input.proprietor = self
	input.cost = roll_cost()
	input.resources = roll_resources(input.cost)
	input.area = "self"

	var card = Global.scene.card.instantiate()
	cards.add_child(card)
	card.set_attributes(input)


func roll_cost() -> int:
	var weights = {}
	weights[3] = 9
	weights[4] = 7
	weights[5] = 5
	weights[6] = 3
	weights[7] = 1
	
	var cost = Global.get_random_key(weights)
	return cost


func roll_resources(cost_: int) -> Dictionary:
	var weight = int(cost_)
	var weights = {}
	weights["gold"] = 0.9
	weights["power"] = 1.3
	
	var resources = {}
	resources["gold"] = 0
	resources["power"] = 0
	
	while !weights.keys().is_empty():
		var resource = Global.get_random_key(weights)
		resources[resource] += 1
		weight -= weights[resource]
		
		for _i in range(weights.keys().size()-1,-1,-1):
			var key = weights.keys()[_i]
			
			if weights[key] > weight:
				weights.erase(key)
	
	for _i in range(resources.keys().size()-1,-1,-1):
		var key = resources.keys()[_i]
		
		if resources[key] == 0:
			resources.erase(key)
	
	return resources
#endregion


func get_all_constituents(budget_: int) -> Array:
	var datas = []
	
	for card in cards.get_children():
		var data = {}
		data.card = card
		data.value = card.cost.get_value()
		datas.append(data)
	
	var constituents = Global.get_all_constituents_based_on_limit(datas, budget_)
	var result = []
	
	for key in constituents:
		for constituent in constituents[key]:
			var _cards = []
			
			for data in constituent:
				_cards.append(data.card)
			
			result.append(_cards)
	
	return result


func card_delivery(card_: MarginContainer, gameboard_: MarginContainer) -> void:
	card_.set_gameboard_as_proprietor(gameboard_)
	refill_cards()


func get_selected_cards_count() -> int:
	var result = 0
	
	for card in cards.get_children():
		if card.selected:
			result += 1
	
	return result
