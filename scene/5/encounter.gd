extends MarginContainer


#region vars
@onready var offensive = $Pools/Offensive
@onready var defensive = $Pools/Defensive

var planet = null
var moon = null
var challenge = null
var pools = []
#endregion


#region vars
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.encounter
	
	init_pools()


func init_pools() -> void:
	var input = {}
	input.encounter = self
	
	for role in Global.arr.role:
		input.role = role
		var pool = get(role)
		pool.set_attributes(input)
#endregion


func prepare_dices() -> void:
	for role in Global.arr.role:
		var pool = get(role)
		var garrison = challenge[role]
		
		for type in Global.arr.garrison:
			var troop = garrison.get(type)
			var kind = troop.subtype
			var dices = troop.get_value()
			pool.add_dices(kind, dices)


func roll_dices() -> void:
	for role in Global.arr.role:
		var pool = get(role)
		pools.append(pool)
		
	for role in Global.arr.role:
		var pool = get(role)
		pool.roll_dices()


func pool_stopped(pool_: MarginContainer) -> void:
	pools.erase(pool_)
	
	if pools.is_empty():
		struggle()
	
	#moon.follow_phase()


func reset() -> void:
	for role in Global.arr.role:
		var pool = get(role)
		pool.reset()


func set_challenge(challenge_: Classes.Challenge) -> void:
	reset()
	challenge = challenge_
	
	prepare_dices()
	roll_dices()


func struggle() -> void:
	var roles = []
	roles.append_array(Global.arr.role)
	
	var order = []
	
	while !roles.is_empty():
		if order.is_empty():
			order.append_array(roles)
		
		var role = order.pop_front()
		var pool = get(role)
		
		if pool.dices.get_child_count() > 0:
			var dice = pool.dices.get_child(0)
			
			if dice.get_current_facet_value() > 0:
				find_victum(dice)
			else:
				roles.erase(role)
		else:
			roles.erase(role)


func find_victum(dice_: MarginContainer) -> void:
	var opponent = {}
	opponent.role = Global.dict.role.opponent[dice_.pool.role]
	opponent.pool = get(opponent.role)
	
	if opponent.pool.dices.get_child_count() > 0:
		opponent.dice = null
		
		for dice in opponent.pool.dices.get_children():
			if dice_.get_current_facet_value() > dice.get_current_facet_value():
				opponent.dice = dice
				break
		
		if opponent.dice != null:
			var kind = opponent.dice.kind
			challenge[opponent.role].change_troop_value(kind, -1)
			opponent.dice.crush()
			print([dice_.pool.role, dice_.kind, dice_.get_current_facet_value(), opponent.dice.kind, opponent.dice.get_current_facet_value()])
			dice_.crush()
	else:
		dice_.crush()
