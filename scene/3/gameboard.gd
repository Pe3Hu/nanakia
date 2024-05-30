extends MarginContainer


#region vars
@onready var available = $VBox/Cards/Available
@onready var discharged = $VBox/Cards/Discharged
@onready var broken = $VBox/Cards/Broken
@onready var hand = $VBox/Cards/Hand

var god = null
var capacity = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	input_.gameboard = self
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.gameboard
	capacity.current = 5
	capacity.limit = 10
	
	init_cardstacks()
	init_starter_kit_cards()
	
	
func init_cardstacks() -> void:
	var input = {}
	input.gameboard = self
	
	for type in Global.dict.area.next:
		if type != null:
			input.type = type
			var cardstack = get(type)
			cardstack.set_attributes(input)


func init_starter_kit_cards() -> void:
	for description in Global.dict.deck.price[0]:
		for _i in description.replica:
			add_card(description)
	
	discharged.reshuffle_all_cards()
	
	#for type in Global.dict.area.next:
		#if type != null:
			#var cardstack = get(type)
			#print([type, cardstack.cards.get_child_count()])


func add_card(description_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	input.area = "discharged"
	input.cost = description_.price
	input.resources = {}
	#var data = {}
	#data.subtype = description_.resource
	#data.value = description_.value
	#input.resources.append(data)
	input.resources[description_.resource] = description_.value

	var card = Global.scene.card.instantiate()
	discharged.cards.add_child(card)
	card.set_attributes(input)
	card.set_gameboard_as_proprietor(self)
#endregion


func refill_hand() -> void:
	var cardstack = get(Global.dict.area.prior[hand.type])
	
	while hand.cards.get_child_count() < capacity.current:
		cardstack.advance_random_card()
	
	for card in hand.cards.get_children():
		card.move_resources_into_storage()


func discard_hand() -> void:
	hand.advance_all_cards()
