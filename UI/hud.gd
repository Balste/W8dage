extends CanvasLayer

@onready var wood_label = $TopLeft/Resources/WoodLabel
@onready var food_label = $TopLeft/Resources/FoodLabel
@onready var stone_label = $TopLeft/Resources/StoneLabel
@onready var metal_label = $TopLeft/Resources/MetalLabel
@onready var water_label = $TopLeft/Resources/WaterLabel

@onready var population_label = $TopRight/PopulationLabel

@onready var build_button = $BottomRight
@onready var pause_button = $BottomLeft

signal build_button_pressed
signal pause_button_pressed

func _ready():
	build_button.pressed.connect(_on_build_pressed)
	pause_button.pressed.connect(_on_pause_pressed)

func update_resources(resources: Dictionary):
	wood_label.text = "Wood: %d" % resources.get("wood", 0)
	food_label.text = "Food: %d" % resources.get("food", 0)
	stone_label.text = "Stone: %d" % resources.get("stone", 0)
	metal_label.text = "Metal: %d" % resources.get("metal", 0)
	water_label.text = "Water: %d" % resources.get("water", 0)

func update_population(current: int, max: int):
	population_label.text = "Population: %d / %d" % [current, max]

func _on_build_pressed():
	emit_signal("build_button_pressed")

func _on_pause_pressed():
	emit_signal("pause_button_pressed")
