extends Node

# Ressources disponibles
var resources := {
    "wood": 1000,    # départ
    "food": 0,
    "stone": 100,    # départ (rock)
    "metal": 100,    # départ
    "water": 0
}

var population := 0
var max_population := 10

# Dictionnaire des coûts de construction
var build_costs := {
    "farm": {"wood": 10},
    "wood_camp": {"wood": 100, "stone": 50},
    "house": {"wood": 100, "stone": 50},
    "mine": {"wood": 100},
    "quarry": {"wood": 100, "stone": 100},
    "well": {"stone": 50, "metal": 50}
}

# Production brute par ressource et par bâtiment (valeurs de base, ajustables)
var base_production := {
    "wood": 5,
    "food": 5,
    "stone": 4,
    "metal": 3,
    "water": 6
}

# Liste des bâtiments de production actifs (ajoutés dynamiquement)
var production_buildings := []

func _ready():
    pass

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

func get_building_count_for_resource(res_type: String) -> int:
    var count = 0
    for building in production_buildings:
        if building.resource_type == res_type:
            count += 1
    return count

func get_storage_max(res_type: String) -> int:
    # 200 de stockage par bâtiment de production de cette ressource
    var n = get_building_count_for_resource(res_type)
    return n * 200

func add_resource(type: String, amount: int):
    if not resources.has(type):
        return
    var max_stock = get_storage_max(type)
    # Si stockage max = 0, on autorise quand même l'augmentation (cas départ sans bâtiment)
    if max_stock > 0:
        resources[type] = min(resources[type] + amount, max_stock)
    else:
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

# Vérifie si on a assez de ressources pour construire ce bâtiment
func can_afford(building_name: String) -> bool:
    if !build_costs.has(building_name):
        return false
    var cost = build_costs[building_name]
    for k in cost.keys():
        if resources.get(k, 0) < cost[k]:
            return false
    return true

# Déduit les ressources nécessaires à la construction
func pay_for_building(building_name: String):
    if !build_costs.has(building_name):
        return
    var cost = build_costs[building_name]
    for k in cost.keys():
        resources[k] -= cost[k]
