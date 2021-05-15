extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "dragonfruit"
    self.value = 3
    self.values = []
    self.rarity = "rare"
    self.groups = ["farmerlikes", "plant", "food", "fruit"]

    self.texture = load_texture("res://valgos-content-pack/symbols/dragonfruit.png")
    self.name = "Dragonfruit"
    self.description = ""