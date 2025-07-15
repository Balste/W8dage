extends "res://Scripts/building.gd"

func _ready():
    resource_type = "wood"
    worker_count = 0
    max_workers = 4
    resource_range = 1
    bonus_radius = 5
    ._ready()  # appel au parent pour inscription

# Surcharge la méthode pour reconnaître les tuiles de forêt (par ex. tile_id == 1)
func is_matching_resource(tile_id: int) -> bool:
    # Supposons que le tile_id 1 = forêt (forest.png)
    return tile_id == 1
