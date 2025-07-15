extends Node

# Ressources disponibles
var resources := {
    "wood": 0,
    "food": 0,
    "stone": 0,
    "metal": 0,
    "water": 0
}

# Liste des bâtiments de production actifs (ajoutés dynamiquement)
var production_buildings := []

# Production brute par ressource et par bâtiment (valeurs de base, ajustables)
var base_production := {
    "wood": 5,
    "food": 5,
    "stone": 4,
    "metal": 3,
    "water": 6
}

func _ready():
    pass # Pour extension future (ex: chargement de paramètres)

func register_building(building):
    if not production_buildings.has(building):
        production_buildings.append(building)

func unregister_building(building):
    if production_buildings.has(building):
        production_buildings.erase(building)

func process_production():
    for building in production_buildings:
        var res_type = building.resource_type
        var worker_count = building.worker_count
        var efficiency = get_efficiency(worker_count)
        var base = base_production.get(res_type, 0)

        var produced = int(base * efficiency * building.get_resource_bonus())
        add_resource(res_type, produced)

func add_resource(type: String, amount: int):
    if resources.has(type):
        resources[type] += amount

func get_resource_amount(type: String) -> int:
    return resources.get(type, 0)

func get_efficiency(workers: int) -> float:
    match workers:
        1:
            return 0.5
        2:
            return 0.7
        3:
            return 0.85
        4:
            return 1.0
        _:
            return 0.0
