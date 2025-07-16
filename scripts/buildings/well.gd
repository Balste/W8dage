extends "res://Scripts/buildings/building.gd"

func _ready():
    resource_type = "water"
    source_tile_ids = [5] # ID de la tuile "eau" ou "rivière"
    worker_count = 0
    max_workers = 4
    bonus_radius = 5
    ._ready()
