extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "banana_tree"
    self.value = 3
    self.values = [30]
    self.rarity = "uncommon"
    self.groups = ["farmerlikes", "plant"]
    add_sfx_redirect("farmer")

    self.texture = load_texture("res://valgos-content-pack/symbols/banana_tree.png")
    self.name = "Banana Tree"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of <color_E14A68>adding<end> <icon_banana>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 0, "rand": true}], "anim": "bounce", "tiles_to_add": [{"type": "banana"}]})