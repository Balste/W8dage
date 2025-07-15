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

signal build_button_pressed
signal pause_button_pressed

func _ready():
	build_button.pressed.connect(_on_build_pressed)
	pause_button.pressed.connect(_on_pause_pressed)

	# Connecter les signaux du menu construction
	build_menu.connect("build_house", self, "_on_build_house")
	build_menu.connect("build_wood_camp", self, "_on_build_wood_camp")
	build_menu.connect("build_quarry", self, "_on_build_quarry")
	build_menu.connect("build_mine", self, "_on_build_mine")
	build_menu.connect("build_farm", self, "_on_build_farm")
	build_menu.connect("build_well", self, "_on_build_well")

func update_resources(resources: Dictionary):
	wood_label.text = "Wood: %d" % resources.get("wood", 0)
	food_label.text = "Food: %d" % resources.get("food", 0)
	stone_label.text = "Stone: %d" % resources.get("stone", 0)
	metal_label.text = "Metal: %d" % resources.get("metal", 0)
	water_label.text = "Water: %d" % resources.get("water", 0)

func update_population(current: int, max: int):
	population_label.text = "Population: %d / %d" % [current, max]

func _on_build_pressed():
	# Affiche ou masque le menu construction
	build_menu.visible = !build_menu.visible
	emit_signal("build_button_pressed")

func _on_pause_pressed():
	emit_signal("pause_button_pressed")

# Ces fonctions seront appelées quand on appuie sur les boutons de construction
func _on_build_house():
	print("Build House clicked")
	# Ici tu vas appeler la fonction pour construire la maison

func _on_build_wood_camp():
	print("Build Wood Camp clicked")

func _on_build_quarry():
	print("Build Quarry clicked")

func _on_build_mine():
	print("Build Mine clicked")

func _on_build_farm():
	print("Build Farm clicked")

func _on_build_well():
	print("Build Well clicked")
