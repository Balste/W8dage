extends Node

# ID des tuiles (à adapter selon l'ordre dans le TileSet terrain_tileset.tres)
const TILE_GRASS  = 0
const TILE_FOREST = 1
const TILE_ROCK   = 2
const TILE_RIVER  = 3
const TILE_METAL  = 4

const MAP_WIDTH  = 20
const MAP_HEIGHT = 20

var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()
    generate_world()

func generate_world():
    var tilemap = get_node("../WorldTileMap") # dépend de la hiérarchie de ton main.tscn
    for x in MAP_WIDTH:
        for y in MAP_HEIGHT:
            var tile_type = get_random_tile()
            tilemap.set_cell(0, Vector2i(x, y), tile_type)

func get_random_tile() -> int:
    var roll = rng.randi_range(0, 99)
    if roll < 50:
        return TILE_GRASS
    elif roll < 70:
        return TILE_FOREST
    elif roll < 85:
        return TILE_ROCK
    elif roll < 95:
        return TILE_RIVER
    else:
        return TILE_METAL
