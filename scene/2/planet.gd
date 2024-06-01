extends MarginContainer


#region var
@onready var hbox = $HBox/VBox/HBox
@onready var moon = $HBox/VBox/Moon
@onready var mainland = $HBox/Mainland
@onready var encounter = $HBox/Encounter

var universe = null
var gods = []
var loser = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	universe = input_.universe
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.planet = self
	moon.set_attributes(input)
	encounter.set_attributes(input)
	mainland.set_attributes(input)
	moon.set_attributes(input)


func add_god(god_: MarginContainer) -> void:
	god_.pantheon.gods.remove_child(god_)
	hbox.add_child(god_)
	
	if gods.is_empty():
		hbox.move_child(god_, 0)
	
	gods.append(god_)
	god_.planet = self
	god_.conqueror.mainland = mainland
#endregion


func start_race() -> void:
	init_gods_opponents()
	init_gods_areas()
	#roll_gods_order()
	
	#for god in gods:
	#	god.gameboard.refill_hand()
	
	#moon.follow_phase()


func init_gods_opponents() -> void:
	for _i in gods.size():
		var god = gods[_i]
		
		for _j in range(_i + 1, gods.size(), 1):
			var opponent = gods[_j]
			
			if god.pantheon != opponent.pantheon:
				god.opponents.append(opponent)
				opponent.opponents.append(god)


func roll_gods_order() -> void:
	moon.god = gods.pick_random()
	var order = gods.find(moon.god) + 1
	moon.order.set_value(order)


func init_gods_areas() -> void:
	var options = []
	options.append_array(mainland.earldoms)
	
	for god in gods:
		var earldom = options.pick_random()
		options.erase(earldom)
		var area = earldom.areas.pick_random()
		god.conqueror.annex_area(area)
		
		god.storage.refill_authority()
		god.gameboard.refill_hand()
		#god.steward.update_resources()
	
	mainland.layer.affiliation = "conqueror"
	mainland.shift_layer("affiliation", 0)
