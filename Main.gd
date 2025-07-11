extends Node2D

# Grid settings
const GRID_SIZE = 20
const TILE_SIZE = 64 # Pixels for isometric tiles (adjust for sprite size)
const ISO_OFFSET_X = 32 # Isometric offset for x (half tile width)
const ISO_OFFSET_Y = 16 # Isometric offset for y (half tile height)

# Terrain types
enum Terrain { PLAIN, FOREST, RIVER, MINE }
var grid = [] # 20x20 array storing terrain types

# Resources
var resources = {
	"wood": 0,
	"stone": 0,
	"food": 0,
	"metal": 0,
	"water": 0
}

# Building data
var building_types = {
	"lumber_camp": {"produces": "wood", "optimal_terrain": Terrain.FOREST, "max_workers": 4, "stock": 0},
	"quarry": {"produces": "stone", "optimal_terrain": Terrain.MINE, "max_workers": 4, "stock": 0},
	"farm": {"produces": "food", "optimal_terrain": Terrain.PLAIN, "max_workers": 4, "stock": 0},
	"house": {"produces": "population", "optimal_terrain": Terrain.PLAIN, "max_workers": 0, "stock": 0},
	"well": {"produces": "water", "optimal_terrain": Terrain.RIVER, "max_workers": 4, "stock": 0},
	"mine": {"produces": "metal", "optimal_terrain": Terrain.MINE, "max_workers": 4, "stock": 0}
}

# Building instances
var buildings = [] # Array of {type, x, y, workers, stock}
var population = 0 # Total population
var available_workers = 0 # Free workers

# UI elements (to be linked to UI.tscn)
var resource_label
var population_label
var build_menu
var pause_menu

func _ready():
	# Initialize fixed 20x20 map (0=Plain, 1=Forest, 2=River, 3=Mine)
	grid = [
		[0,0,0,1,1,1,1,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,1,1,1,1,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,1,1,1,1,0,0,0,0,0,2,2,2,0,0,0,0,0,3,3],
		[0,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,0,3,3],
		[0,0,0,0,0,0,0,3,3,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,3,3,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0
