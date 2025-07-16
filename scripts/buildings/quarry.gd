extends "res://Scripts/buildings/building.gd"

func _ready():
    resource_type = "stone"
    source_tile_ids = [2] # ID de la tuile "roche"
    worker_count = 0
    max_workers = 4
    bonus_radius = 5
    ._ready()
