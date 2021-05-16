extends "res://Card_Card.gd"

func tr(key):
    var modloader := get_tree().modloader
    return modloader.translate(key)