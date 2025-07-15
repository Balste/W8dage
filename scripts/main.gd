extends Node

const TICK_INTERVAL := 1.0

var time_passed := 0.0
var resource_manager
var save_system

@onready var hud = $HUD

func _ready():
	resource_manager = preload("res://Scripts/resource_manager.gd").new()
	save_system = preload("res://Scripts/save_system.gd").new()

	add_child(resource_manager)
	add_child(save_system)

	save_system.load_game()
	hud.update_resources(resource_manager.get_all_resources())

	hud.build_button_pressed.connect(_on_build_button_pressed)
	hud.pause_button_pressed.connect(_on_pause_button_pressed)
	hud.build_menu.build_house.connect(_on_build_house)

func _process(delta):
	time_passed += delta
	if time_passed >= TICK_INTERVAL:
		time_passed = 0.0
		_game_tick()

func _game_tick():
	resource_manager.process_production()
	hud.update_resources(resource_manager.get_all_resources())
	save_system.save_game()

func _on_build_button_pressed():
	hud.toggle_build_menu()

func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused

func _on_build_house():
	print("Build house action triggered")
