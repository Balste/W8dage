extends Node2D

class_name Building

# Propriétés de base communes à tous les bâtiments
var resource_type := ""         # Exemple : "wood", "food"
var worker_count := 0          # De 0 à 4
var max_workers := 4
var resource_range := 1        # Distance optimale à la ressource (en cases)
var bonus_radius := 5          # Distance au-delà de laquelle il n’y a plus de bonus

# Pour que chaque bâtiment puisse s’inscrire à la production
func _ready():
    get_node("/root/Main").resource_manager.register_building(self)

func _exit_tree():
    get_node("/root/Main").resource_manager.unregister_building(self)

# Cette méthode calcule un bonus de production selon la proximité de la ressource
func get_resource_bonus() -> float:
    var tilemap = get_node("/root/Main").get_node("WorldTileMap")
    var position = global_position

    var nearby_bonus := 0.0
    var in_range := 0

    for x in range(-bonus_radius, bonus_radius + 1):
        for y in range(-bonus_radius, bonus_radius + 1):
            var check_pos = position + Vector2(x * 64, y * 32) # en pixels
            var cell = tilemap.world_to_map(check_pos)
            var tile_id = tilemap.get_cell_source_id(0, cell)

            if is_matching_resource(tile_id):
                var dist = position.distance_to(check_pos)
                if dist <= resource_range * 64:
                    nearby_bonus += 1.0
                    in_range += 1

    # Plus il y a de tuiles proches, plus le bonus est haut (max : 1.0)
    return clamp(nearby_bonus / 5.0, 0.0, 1.0)

# Cette méthode devra être redéfinie par chaque bâtiment enfant
func is_matching_resource(tile_id: int) -> bool:
    return false
