extends Node2D
class_name Building

var resource_type := ""       # Exemple : "wood", "stone"
var worker_count := 0
var max_workers := 4
var bonus_radius := 5         # Rayon de recherche autour du bâtiment (en cases)

var source_tile_ids := []     # À définir dans les classes enfants

func _ready():
    get_node("/root/Main").resource_manager.register_building(self)

func _exit_tree():
    get_node("/root/Main").resource_manager.unregister_building(self)

func get_resource_bonus() -> float:
    var tilemap = get_node("/root/Main/WorldTileMap")
    var center = tilemap.local_to_map(global_position)
    var closest_distance = INF

    for dx in range(-bonus_radius, bonus_radius + 1):
        for dy in range(-bonus_radius, bonus_radius + 1):
            var pos = center + Vector2i(dx, dy)
            var tile_id = tilemap.get_cell_source_id(0, pos)

            if is_matching_resource(tile_id):
                var dist = center.distance_to(pos)
                if dist < closest_distance:
                    closest_distance = dist

    if closest_distance == INF:
        return 0.1  # Pas de ressource détectée

    if closest_distance <= 1:
        return 1.0
    if closest_distance >= 5:
        return 0.1

    # Interpolation linéaire entre 1 (bonus 1.0) et 5 (bonus 0.1)
    var t = (closest_distance - 1.0) / 4.0
    return lerp(1.0, 0.1, t)

func is_matching_resource(tile_id: int) -> bool:
    return source_tile_ids.has(tile_id)
