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
var selected_building_name: String = ""

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
# Exemple : 1 = water, 2 = rock, 3 = metal, 4 = forest
var forbidden_tiles := [1, 2, 3, 4]

func _ready():
    # Chargement et ajout des systèmes
    resource_manager = preload("res://Scripts/resource_manager.gd").new()
    time_manager = preload("res://Scripts/time_manager.gd").new()
    save_system = preload("res://Scripts/save_system.gd").new()

    add_child(resource_manager)
    add_child(time_manager)
    add_child(save_system)

    # Connexions du HUD (incluant les relai des signaux de construction)
    hud.build_button_pressed.connect(_on_build_button_pressed)
    hud.pause_button_pressed.connect(_on_pause_button_pressed)
    hud.build_house.connect(_on_build_house)
    hud.build_wood_camp.connect(_on_build_wood_camp)
    hud.build_quarry.connect(_on_build_quarry)
    hud.build_mine.connect(_on_build_mine)
    hud.build_farm.connect(_on_build_farm)
    hud.build_well.connect(_on_build_well)

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

# Fonctions pour sélectionner le bâtiment à construire
func _on_build_house():
    select_building("house")
func _on_build_wood_camp():
    select_building("wood_camp")
func _on_build_quarry():
    select_building("quarry")
func _on_build_mine():
    select_building("mine")
func _on_build_farm():
    select_building("farm")
func _on_build_well():
    select_building("well")

func select_building(building_name: String):
    if building_scenes.has(building_name):
        selected_building_scene = building_scenes[building_name]
        selected_building_name = building_name
        print("Sélection du bâtiment :", building_name)

func _unhandled_input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if selected_building_scene != null:
            var mouse_pos = get_viewport().get_mouse_position()
            # Adapter selon ta caméra et ton tilemap !
            var world_pos = tilemap.to_local(get_viewport().get_camera_2d().get_screen_to_world(mouse_pos))
            var tile_pos = tilemap.local_to_map(world_pos)

            # Vérifie la tuile à cet endroit
            var cell_id = tilemap.get_cell_source_id(0, tile_pos)
            if forbidden_tiles.has(cell_id):
                # Tuile interdite
                return

            # Vérifie les ressources nécessaires
            if not resource_manager.can_afford(selected_building_name):
                # Pas assez de ressources
                return

            # Déduit les ressources et construit
            resource_manager.pay_for_building(selected_building_name)
            var building = selected_building_scene.instantiate()
            building.position = tilemap.map_to_local(tile_pos)
            tilemap.add_child(building)
            print("Bâtiment construit à :", tile_pos)
            selected_building_scene = null
            selected_building_name = ""
