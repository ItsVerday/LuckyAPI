extends "res://Reel_Reel.gd"

onready var modloader: Reference = get_tree().modloader

func load_icons():
    for icon_type in icon_types:
        modloader.check_missing_symbol(icon_type)
    .load_icons()