extends Panel

# Signaux émis quand un bouton construction est pressé
signal build_house
signal build_wood_camp
signal build_quarry
signal build_mine
signal build_farm
signal build_well

func _ready():
	$VBoxContainer/HouseButton.pressed.connect(_on_house_pressed)
	$VBoxContainer/WoodCampButton.pressed.connect(_on_wood_camp_pressed)
	$VBoxContainer/QuarryButton.pressed.connect(_on_quarry_pressed)
	$VBoxContainer/MineButton.pressed.connect(_on_mine_pressed)
	$VBoxContainer/FarmButton.pressed.connect(_on_farm_pressed)
	$VBoxContainer/WellButton.pressed.connect(_on_well_pressed)

func _on_house_pressed():
	emit_signal("build_house")

func _on_wood_camp_pressed():
	emit_signal("build_wood_camp")

func _on_quarry_pressed():
	emit_signal("build_quarry")

func _on_mine_pressed():
	emit_signal("build_mine")

func _on_farm_pressed():
	emit_signal("build_farm")

func _on_well_pressed():
	emit_signal("build_well")
