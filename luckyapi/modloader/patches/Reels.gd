extends "res://Main_Reels.gd"

onready var modloader: Reference = get_tree().modloader

func update_icon_types():
    .update_icon_types()

    for r in reels:
        for i in r.icons:
            r.saved_icon_data[i.grid_position.y].persistent_data = i.persistent_data
            i.has_effects = false

func spin():
    modloader.starting_symbols = []
    
    .spin()

func swap_icon_positions(i1, i2):
    var values_to_keep = ["persistent_data"]
    var i1_data = {}
    var i2_data = {}
	
    for v in values_to_keep:
        i1_data[v] = i1[v]
        i2_data[v] = i2[v]
    
    .swap_icon_positions(i1, i2)
    
    for v in values_to_keep:
        i1[v] = i2_data[v]
        i2[v] = i1_data[v]
