extends "res://Main_Reels.gd"

onready var modloader: Reference = get_tree().modloader

func update_icon_types():
    .update_icon_types()
    for r in reels:
        for i in r.icons:
            r.saved_icon_data[i.grid_position.y].persistent_data = i.persistent_data