extends "res://Scripts/buildings/building.gd"

func _ready():
    resource_type = "wood"
    source_tile_ids = [1]  # ID de la tuile "forest" dans ton terrain_tileset
    worker_count = 0
    max_workers = 4
    bonus_radius = 5
    ._ready()  # appel de la _ready() du parent pour l'enregistrement
