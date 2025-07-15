extends Node

const TICK_INTERVAL := 1.0 # temps entre deux cycles de production (en secondes)

var time_passed := 0.0

# Références aux autres systèmes
var resource_manager
var time_manager
var save_system

func _ready():
    # Chargement des systèmes (à adapter si nécessaire selon la structure exacte)
    resource_manager = preload("res://Scripts/resource_manager.gd").new()
    time_manager = preload("res://Scripts/time_manager.gd").new()
    save_system = preload("res://Scripts/save_system.gd").new()

    add_child(resource_manager)
    add_child(time_manager)
    add_child(save_system)

    # Charger les données sauvegardées si disponibles
    save_system.load_game()

    print("Game Ready")

func _process(delta):
    time_passed += delta
    if time_passed >= TICK_INTERVAL:
        time_passed = 0.0
        _game_tick()

func _game_tick():
    # Exécute un cycle de jeu (production, temps, etc.)
    time_manager.advance_time()
    resource_manager.process_production()

    # Sauvegarde automatique simple pour la v0.1
    save_system.save_game()
