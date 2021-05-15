extends "res://Card_Card.gd"

onready var modloader: Reference = get_tree().modloader

func tr(key):
    var modloader := get_tree().modloader
    return modloader.translate(key)