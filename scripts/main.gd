extends Node

const TICK_INTERVAL := 1.0 # temps entre deux cycles de production (en secondes)

var time_passed := 0.0

# Références aux autres systèmes
var resource_manager
var time_manager
var save_system

@onready var hud = $HUD

func _ready():
    # Chargement des systèmes
    resource_manager = preload("res://Scripts/resource_manager.gd").new()
    time_manager = preload("res://Scripts/time_manager.gd").new()
    save_system = preload("res://Scripts/save_system.gd").new()

    add_child(resource_manager)
    add_child(time_manager)
    add_child(save_system)

    # Connexion des boutons HUD
    hud.build_button_pressed.connect(_on_build_button_pressed)
    hud.pause_button_pressed.connect(_on_pause_button_pressed)

    # Charger les données sauvegardées si disponibles
    save_system.load_game()

    print("Game Ready")

func _process(delta):
    time_passed += delta
    if time_passed >= TICK_INTERVAL:
        time_passed = 0.0
        _game_tick()

    update_ui()

func _game_tick():
    # Exécute un cycle de jeu
    time_manager.advance_time()
    resource_manager.process_production()
    save_system.save_game()

func update_ui():
    hud.update_resources(resource_manager.resources)
    hud.update_population(resource_manager.population, resource_manager.max_population)

func _on_build_button_pressed():
    print("Build menu clicked — to implement")

func _on_pause_button_pressed():
    print("Pause menu clicked — to implement")
