extends Node


@onready var sketch = $Sketch


func _ready() -> void:
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	pass


func _input(event) -> void:
	if event is InputEventKey:
		var planet = sketch.universe.planets.get_child(0)
		
		match event.keycode:
			KEY_A:
				if event.is_pressed() && !event.is_echo():
					planet.mainland.shift_layer("affiliation", -1)
			KEY_D:
				if event.is_pressed() && !event.is_echo():
					planet.mainland.shift_layer("affiliation", 1)
			KEY_Q:
				if event.is_pressed() && !event.is_echo():
					planet.mainland.shift_layer("detail", -1)
			KEY_E:
				if event.is_pressed() && !event.is_echo():
					planet.mainland.shift_layer("detail", 1)



