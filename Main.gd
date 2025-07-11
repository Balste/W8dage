extends Node2D

# Grid settings
const GRID_SIZE = 20
const TILE_SIZE = 64 # Pixels for isometric tiles
const ISO_OFFSET_X = 32 # Isometric offset for x
const ISO_OFFSET_Y = 16 # Isometric offset for y

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

# v0.2 features
var game_speed = 1.0 # x1, x2, x3
var day_night_timer = 0.0 # Tracks 5-min day/night cycle (300 sec)
var is_day = true # Day (true) or night (false)
var cloud_timer = 0.0 # Time until next cloud spawn
var destroying = false # Toggle for destroy mode

# UI elements
var resource_label
var population_label
var build_menu
var pause_menu
var speed_label
var canvas_modulate # For day/night tint

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
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,3,3,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,3,3,0,0,0],
		[1,1,1,0,0,0,0,0,0,0,2,2,2,0,0,0,1,1,1,0],
		[1,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,1,1,1,0]
	]
	
	# Setup UI
	resource_label = $UI/ResourceLabel
	population_label = $UI/PopulationLabel
	build_menu = $UI/BuildMenu
	pause_menu = $UI/PauseMenu
	speed_label = $UI/SpeedLabel
	
	# Setup production timer
	var prod_timer = Timer.new()
	prod_timer.wait_time = 5.0 / game_speed # Adjusted by speed
	prod_timer.connect("timeout", Callable(self, "_on_production_timer"))
	add_child(prod_timer)
	prod_timer.start()
	
	# Setup day/night
	canvas_modulate = $CanvasModulate
	canvas_modulate.color = Color(1, 1, 1) # Day (white)
	
	# Setup cloud timer
	var cloud_spawn_timer = Timer.new()
	cloud_spawn_timer.wait_time = 30.0 # Clouds every 30 sec
	cloud_spawn_timer.connect("timeout", Callable(self, "_on_cloud_spawn_timer"))
	add_child(cloud_spawn_timer)
	cloud_spawn_timer.start()

func _process(delta):
	# Adjust delta for game speed
	delta *= game_speed
	
	# Handle touch input for building placement or destruction
	if Input.is_action_just_pressed("ui_touch"):
		var pos = get_global_mouse_position()
		var grid_pos = screen_to_grid(pos)
		if is_valid_grid_pos(grid_pos.x, grid_pos.y) and build_menu.visible and not destroying:
			place_building(build_menu.selected_type, grid_pos.x, grid_pos.y)
		elif destroying:
			destroy_building(grid_pos.x, grid_pos.y)
	
	# Update day/night
	day_night_timer += delta
	if day_night_timer >= 300: # 5 min = 300 sec
		day_night_timer = 0.0
		is_day = !is_day
		canvas_modulate.color = Color(1, 1, 1) if is_day else Color(0.5, 0.5, 0.7) # Day: white, Night: blue tint
	
	# Update cloud timer
	cloud_timer += delta
	if cloud_timer >= 30.0:
		cloud_timer = 0.0
	
	# Update UI
	update_ui()

func screen_to_grid(pos):
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
	
	var building = preload("res://Building.tscn").instantiate()
	building.position = grid_to_screen(x, y)
	add_child(building)

func assign_workers(type, x, y):
	if available_workers > 0:
		for b in buildings:
			if b.workers < building_types[b.type].max_workers and available_workers > 0:
				b.workers += 1
				available_workers -= 1

func destroy_building(x, y):
	for i in range(buildings.size()):
		if buildings[i].x == x and buildings[i].y == y:
			if buildings[i].type == "house":
				population -= 2
				available_workers -= 2
			else:
				available_workers += buildings[i].workers
			buildings.remove_at(i)
			get_child(i + 2).queue_free() # Skip TileMap, CanvasModulate
			break

func grid_to_screen(x, y):
	var screen_x = (x - y) * ISO_OFFSET_X
	var screen_y = (x + y) * ISO_OFFSET_Y
	return Vector2(screen_x, screen_y)

func _on_production_timer():
	for b in buildings:
		if b.type != "house":
			var terrain = grid[b.x][b.y]
			var distance = calculate_distance(b.x, b.y, building_types[b.type].optimal_terrain)
			var production_modifier = max(0, 1.0 - (distance / 5.0))
			var worker_modifier = get_worker_modifier(b.workers)
			var production = 10 * production_modifier * worker_modifier
			b.stock += production
			if b.stock > 200:
				b.stock = 200
			resources[building_types[b.type].produces] += b.stock
			b.stock = 0

func calculate_distance(x, y, optimal_terrain):
	var min_distance = INF
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == optimal_terrain:
				var dist = abs(x - i) + abs(y - j)
				min_distance = min(min_distance, dist)
	return min_distance

func get_worker_modifier(workers):
	if workers == 1: return 0.5
	if workers == 2: return 0.7
	if workers == 3: return 0.85
	if workers == 4: return 1.0
	return 0.0

func _on_cloud_spawn_timer():
	var cloud = preload("res://Cloud.tscn").instantiate()
	cloud.position = Vector2(-100, randf_range(50, 200)) # Start off-screen left
	add_child(cloud)

func update_ui():
	var text = "Wood: %d\nStone: %d\nFood: %d\nMetal: %d\nWater: %d" % [
		resources.wood, resources.stone, resources.food, resources.metal, resources.water
	]
	resource_label.text = text
	population_label.text = "Population: %d" % population
	speed_label.text = "Speed: x%.1f" % game_speed

func _on_build_button_pressed(type):
	build_menu.selected_type = type
	build_menu.visible = true
	destroying = false

func _on_pause_button_pressed():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = pause_menu.visible

func _on_speed_button_pressed(speed):
	game_speed = speed
	$Timer.wait_time = 5.0 / game_speed # Adjust production timer
	update_ui()

func _on_destroy_button_pressed():
	destroying = !destroying
	build_menu.visible = false

func _on_save_button_pressed():
	var save_data = {
		"resources": resources,
		"population": population,
		"available_workers": available_workers,
		"buildings": buildings
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func _on_load_button_pressed():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		resources = save_data.resources
		population = save_data.population
		available_workers = save_data.available_workers
		for b in buildings:
			get_child(buildings.find(b) + 2).queue_free()
		buildings = save_data.buildings
		for b in buildings:
			var building = preload("res://Building.tscn").instantiate()
			building.position = grid_to_screen(b.x, b.y)
			add_child(building)
		update_ui()
