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
		match event.keycode:
			KEY_A:
				if event.is_pressed() && !event.is_echo():
					var planet = sketch.universe.planets.get_child(0)
					planet.mainland.shift_layer(-1)
			KEY_D:
				if event.is_pressed() && !event.is_echo():
					var planet = sketch.universe.planets.get_child(0)
					planet.mainland.shift_layer(1)




