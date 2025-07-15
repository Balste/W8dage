extends "res://Scripts/building.gd"

func _ready():
    resource_type = "metal"
    source_tile_ids = [3] # ID de la tuile "minerai"
    worker_count = 0
    max_workers = 4
    bonus_radius = 5
    ._ready()
