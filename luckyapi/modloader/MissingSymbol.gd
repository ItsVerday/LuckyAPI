extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = params.id
    self.value = 0
    self.values = []
    self.rarity = null
    self.groups = []

    self.texture = load_texture("res://modloader/missing_symbol.png")
    self.name = params.id + " (Missing Symbol)"
    self.description = "This symbol was not found in any of your mods or the base game. This was either caused by a bug or a mod which was uninstalled."