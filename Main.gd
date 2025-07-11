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
	# Initialize grid
	for x in range(GRID_SIZE):
		grid.append([])
		for y in range(GRID_SIZE):
			# Simplified terrain: 25% each type (adjust later for fixed map)
			var terrain = randi() % 4
			grid[x].append(terrain)
	
	# Setup UI
	resource_label = $UI/ResourceLabel
	population_label = $UI/PopulationLabel
	build_menu = $UI/BuildMenu
	pause_menu = $UI/PauseMenu
	
	# Setup production timer
	var timer = Timer.new()
	timer.wait_time = 5.0 # Produce every 5 seconds
	timer.connect("timeout", Callable(self, "_on_production_timer"))
	add_child(timer)
	timer.start()

func _process(delta):
	# Handle touch input for building placement
	if Input.is_action_just_pressed("ui_touch"):
		var pos = get_global_mouse_position()
		var grid_pos = screen_to_grid(pos)
		if is_valid_grid_pos(grid_pos.x, grid_pos.y) and build_menu.visible:
			place_building(build_menu.selected_type, grid_pos.x, grid_pos.y)
	
	# Update UI
	update_ui()

func screen_to_grid(pos):
	# Convert screen position to isometric grid
	var x = int((pos.x / (TILE_SIZE * 0.5) + pos.y / (TILE_SIZE * 0.25)) / 2)
	var y = int((pos.y / (TILE_SIZE * 0.25) - pos.x / (TILE_SIZE * 0.5)) / 2)
	return Vector2(x, y)

func is_valid_grid_pos(x, y):
	return x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE and not is_occupied(x, y)

func is_occupied(x, y):
	for b in buildings:
		if b.x == x and b.y == y:
			return true
	return false

func place_building(type, x, y):
	if type == "house":
		population += 2
		available_workers += 2
	else:
		assign_workers(type, x, y)
	
	buildings.append({"type": type, "x": x, "y": y, "workers": 0 if type == "house" else 1, "stock": 0})
	
	# Draw building
	var building = preload("res://Building.tscn").instantiate()
	building.position = grid_to_screen(x, y)
	add_child(building)

func assign_workers(type, x, y):
	if available_workers > 0:
		for b in buildings:
			if b.workers < building_types[b.type].max_workers and available_workers > 0:
				b.workers += 1
				available_workers -= 1

func grid_to_screen(x, y):
	# Convert grid to isometric screen position
	var screen_x = (x - y) * ISO_OFFSET_X
	var screen_y = (x + y) * ISO_OFFSET_Y
	return Vector2(screen_x, screen_y)

func _on_production_timer():
	# Produce resources based on proximity and workers
	for b in buildings:
		if b.type != "house":
			var terrain = grid[b.x][b.y]
			var distance = calculate_distance(b.x, b.y, building_types[b.type].optimal_terrain)
			var production_modifier = max(0, 1.0 - (distance / 5.0)) # 100% at 1 tile, 0% at 5+
			var worker_modifier = get_worker_modifier(b.workers)
			var production = 10 * production_modifier * worker_modifier # Base production: 10 units
			b.stock += production
			if b.stock > 200:
				b.stock = 200 # Cap at 200
			resources[building_types[b.type].produces] += b.stock
			b.stock = 0 # Reset stock after transfer

func calculate_distance(x, y, optimal_terrain):
	# Find nearest tile of optimal_terrain
	var min_distance = INF
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == optimal_terrain:
				var dist = abs(x - i) + abs(y - j)
				min_distance = min(min_distance, dist)
	return min_distance

func get_worker_modifier(workers):
	# Production scaling: 1=50%, 2=70%, 3=85%, 4=100%
	if workers == 1: return 0.5
	if workers == 2: return 0.7
	if workers == 3: return 0.85
	if workers == 4: return 1.0
	return 0.0

func update_ui():
	# Update resource and population display
	var text = "Wood: %d\nStone: %d\nFood: %d\nMetal: %d\nWater: %d" % [
		resources.wood, resources.stone, resources.food, resources.metal, resources.water
	]
	resource_label.text = text
	population_label.text = "Population: %d" % population

# UI button signals
func _on_build_button_pressed(type):
	build_menu.selected_type = type
	build_menu.visible = true

func _on_pause_button_pressed():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = pause_menu.visible
