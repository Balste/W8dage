extends Node

const TICK_INTERVAL := 1.0
var time_passed := 0.0

# Systèmes
var resource_manager
var time_manager
var save_system

@onready var hud = $HUD
@onready var tilemap = $WorldTileMap

# Construction
var selected_building_scene: PackedScene = null

# Nom → scène de construction
var building_scenes := {
	"house": preload("res://Scenes/Building/house.tscn"),
	"wood_camp": preload("res://Scenes/Building/wood_camp.tscn"),
	"quarry": preload("res://Scenes/Building/quarry.tscn"),
	"mine": preload("res://Scenes/Building/mine.tscn"),
	"farm": preload("res://Scenes/Building/farm.tscn"),
	"well": preload("res://Scenes/Building/well.tscn")
}

# Liste des IDs de tuiles interdites à la construction (à adapter à ton TileSet)
var forbidden_tiles := [1, 2] # Exemple : 1 = eau, 2 = montagne

func _ready():
	# Chargement et ajout des systèmes
	resource_manager = preload("res://Scripts/resource_manager.gd").new()
	time_manager = preload("res://Scripts/time_manager.gd").new()
	save_system = preload("res://Scripts/save_system.gd").new()

	add_child(resource_manager)
	add_child(time_manager)
	add_child(save_system)

	# Connexions du HUD
	hud.build_button_pressed.connect(_on_build_button_pressed)
	hud.pause_button_pressed.connect(_on_pause_button_pressed)

	var build_menu = hud.get_node("BuildMenu")
	build_menu.build_house.connect(() => select_building("house"))
	build_menu.build_wood_camp.connect(() => select_building("wood_camp"))
	build_menu.build_quarry.connect(() => select_building("quarry"))
	build_menu.build_mine.connect(() => select_building("mine"))
	build_menu.build_farm.connect(() => select_building("farm"))
	build_menu.build_well.connect(() => select_building("well"))

	# Chargement de sauvegarde (optionnel en v0.1)
	save_system.load_game()

func _process(delta):
	time_passed += delta
	if time_passed >= TICK_INTERVAL:
		time_passed = 0.0
		_game_tick()

	update_ui()

func _game_tick():
	time_manager.advance_time()
	resource_manager.process_production()
	save_system.save_game()

func update_ui():
	hud.update_resources(resource_manager.resources)
	hud.update_population(resource_manager.population, resource_manager.max_population)

func _on_build_button_pressed():
	hud.get_node("BuildMenu").visible = not hud.get_node("BuildMenu").visible

func _on_pause_button_pressed():
	print("Pause — à implémenter")

func select_building(building_name: String):
	if building_scenes.has(building_name):
		selected_building_scene = building_scenes[building_name]
		print("Sélection du bâtiment :", building_name)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_building_scene != null:
			var mouse_pos = get_viewport().get_mouse_position()
			var world_pos = tilemap.to_local(get_viewport().get_camera_2d().get_screen_to_world(mouse_pos))
			var tile_pos = tilemap.local_to_map(world_pos)

			# Vérifie la tuile à cet endroit
			var tile_id = tilemap.get_cell_source_id(0, tile_pos)
			if tile_id in forbidden_tiles:
				print("Impossible de construire ici : terrain bloqué.")
				return

			var cell_pos = tilemap.map_to_local(tile_pos)
			var building = selected_building_scene.instantiate()
			building.position = cell_pos
			tilemap.add_child(building)

			resource_manager.register_building(building)
			selected_building_scene = null
			print("Bâtiment placé :", building.name)
