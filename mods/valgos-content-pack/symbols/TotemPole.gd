extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "totem_pole"
    self.value = 1
    self.values = [4]
    self.rarity = "common"
    self.groups = []
    add_sfx_redirect("beastmaster")

    self.texture = load_texture("res://valgos-content-pack/symbols/totem_pole.png")
    self.name = "Totem Pole"
    self.description = "Gives <icon_coin><color_FBF236><value_1><end> more for <color_E14A68>each other<end> <icon_totem_pole> in the same column."

func add_conditional_effects(symbol, adjacent):
    for y in range(modloader.globals.reels.reel_height):
        if y != symbol.grid_position.y:
            symbol.add_effect_to_symbol(y, symbol.grid_position.x, {"comparisons": [{"a": "type", "b": "totem_pole"}], "value_to_change": "value_bonus", "diff": values[0]})