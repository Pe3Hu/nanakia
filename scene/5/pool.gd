extends MarginContainer


#region vars
@onready var dices = $Dices

var encounter = null
var role = null
var result = null
var rolls = []
var fixed = false
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	encounter = input_.encounter
	role = input_.role


func add_dices(kind_: String, dices_: int) -> void:
	for _i in dices_:
		add_dice(kind_)


func add_dice(kind_: String) -> void:
	var input = {}
	input.pool = self
	input.kind = kind_
	
	var dice = Global.scene.dice.instantiate()
	dices.add_child(dice)
	dice.set_attributes(input)


func roll_dices() -> void:
	rolls = []
	result = null
	
	for dice in dices.get_children():
		rolls.append(dice)
	
	for dice in dices.get_children():
		dice.skip = false
		dice.roll()


func dice_stopped(dice_: MarginContainer) -> void:
	rolls.erase(dice_)
	
	if rolls.is_empty():
		sort_dices()
		encounter.pool_stopped(self)


func sort_dices() -> void:
	result = 0
	
	var datas = {}
	
	for _i in range(dices.get_child_count()-1,-1,-1):
		var dice = dices.get_child(_i)
		
		if !rolls.has(dice):
			dices.remove_child(dice)
			var power = dice.get_current_facet_value()
			
			if !datas.has(power):
				datas[power] = []
			
			datas[power].append(dice)
	
	var powers = datas.keys()
	powers.sort_custom(func(a, b): return a > b)
	
	for power in powers:
		datas[power].sort_custom(func(a, b): return Global.arr.initiative.find(a) < Global.arr.initiative.find(b))
	
		while !datas[power].is_empty():
			var dice = datas[power].pop_front()
			dices.add_child(dice)


func reset() -> void:
	fixed = false
	result = 0
	rolls = []
	
	while dices.get_child_count() > 0:
		var dice = dices.get_child(0)
		dices.remove_child(dice)
		dice.queue_free()


func set_fixed_value(value_: int) -> void:
	var dice = dices.get_child(0)
	dice.flip_to_value(value_)
#endregion
