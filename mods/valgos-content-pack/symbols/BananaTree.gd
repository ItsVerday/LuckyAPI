extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "banana_tree"
    self.value = 2
    self.values = [20]
    self.rarity = "uncommon"
    self.groups = ["farmerlikes", "plant"]
    self.sfx = ["farmer"]

    self.texture = load_texture("res://valgos-content-pack/symbols/banana_tree.png")
    self.name = "Banana Tree"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of <color_E14A68>adding<end> <all_or_banana_tree_adds>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(0).add_symbol_group("banana_tree_adds").animate("bounce", 0))