extends CanvasLayer

@onready var wood_label = $TopLeft/Resources/WoodLabel
@onready var food_label = $TopLeft/Resources/FoodLabel
@onready var stone_label = $TopLeft/Resources/StoneLabel
@onready var metal_label = $TopLeft/Resources/MetalLabel
@onready var water_label = $TopLeft/Resources/WaterLabel

@onready var population_label = $TopRight/PopulationLabel

@onready var build_button = $BottomRight
@onready var pause_button = $BottomLeft

@onready var build_menu = $BuildMenu  # Référence au menu de construction

# Signaux principaux pour le HUD
signal build_button_pressed
signal pause_button_pressed

# Signaux de construction relayés du build_menu
signal build_house
signal build_wood_camp
signal build_quarry
signal build_mine
signal build_farm
signal build_well

func _ready():
	build_button.pressed.connect(_on_build_pressed)
	pause_button.pressed.connect(_on_pause_pressed)

	# Relai des signaux du menu construction
	build_menu.build_house.connect(_emit_build_house)
	build_menu.build_wood_camp.connect(_emit_build_wood_camp)
	build_menu.build_quarry.connect(_emit_build_quarry)
	build_menu.build_mine.connect(_emit_build_mine)
	build_menu.build_farm.connect(_emit_build_farm)
	build_menu.build_well.connect(_emit_build_well)

func update_resources(resources: Dictionary):
	wood_label.text = "Wood: %d" % resources.get("wood", 0)
	food_label.text = "Food: %d" % resources.get("food", 0)
	stone_label.text = "Stone: %d" % resources.get("stone", 0)
	metal_label.text = "Metal: %d" % resources.get("metal", 0)
	water_label.text = "Water: %d" % resources.get("water", 0)

func update_population(current: int, max: int):
	population_label.text = "Population: %d / %d" % [current, max]

func _on_build_pressed():
	build_menu.visible = !build_menu.visible
	emit_signal("build_button_pressed")

func _on_pause_pressed():
	emit_signal("pause_button_pressed")

# Fonctions relais pour les signaux de build_menu
func _emit_build_house():
	emit_signal("build_house")

func _emit_build_wood_camp():
	emit_signal("build_wood_camp")

func _emit_build_quarry():
	emit_signal("build_quarry")

func _emit_build_mine():
	emit_signal("build_mine")

func _emit_build_farm():
	emit_signal("build_farm")

func _emit_build_well():
	emit_signal("build_well")
