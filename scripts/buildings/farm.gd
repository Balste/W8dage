extends "res://Scripts/building.gd"

func _ready():
    resource_type = "food"
    source_tile_ids = [4] # ID de la tuile "sol fertile"
    worker_count = 0
    max_workers = 4
    bonus_radius = 5
    ._ready()

