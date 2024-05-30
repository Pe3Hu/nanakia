extends MarginContainer


#region vars
@onready var gameboard = $HBox/Gameboard
@onready var society = $HBox/VBox/Society
@onready var storage = $HBox/VBox/Storage

var pantheon = null
var planet = null
var conqueror = null
var steward = null
var opponents = []
var index = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	pantheon = input_.pantheon
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.god = self
	gameboard.set_attributes(input)
	society.set_attributes(input)
	storage.set_attributes(input)
	conqueror = Classes.Conqueror.new(input)
	steward = Classes.Steward.new(input)
	
	index = int(Global.num.index.god)
	Global.num.index.god += 1
#endregion


func pick_opponent() -> MarginContainer:
	var opponent = opponents.pick_random()
	return opponent


func concede_defeat() -> void:
	planet.loser = self
