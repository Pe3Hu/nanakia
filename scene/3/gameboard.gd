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
	for sin in Global.dict.card.rarity["common"]:
		for title in Global.dict.card.rarity["common"][sin]:
			for specialty in Global.dict.card.rarity["common"][sin][title]:
				var description = Global.dict.card.rarity["common"][sin][title][specialty]
				
				for _i in description.request.replica:
					var input = {}
					input.sin = sin
					input.title = title
					input.specialty = specialty
					input.description = description
					add_card(input)
	
	discharged.reshuffle_all_cards()


func add_card(input_: Dictionary) -> void:
	input_.proprietor = self
	input_.area = "discharged"
	input_.cost = 0
	input_.authorities = {}
	
	for authority in input_.description:
		#var data = {}
		#data.subtype = description_.resource
		#data.value = description_.value
		#input.resources.append(data)
		input_.authorities[authority] = input_.description[authority]

	var card = Global.scene.card.instantiate()
	discharged.cards.add_child(card)
	card.set_attributes(input_)
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
