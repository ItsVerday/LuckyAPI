extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "totem_pole"
    self.value = 1
    self.values = [4]
    self.rarity = "common"
    self.groups = ["totem_pole_likes"]

    self.texture = load_texture("res://valgos-content-pack/symbols/totem_pole.png")
    self.name = "Totem Pole"
    self.description = "Gives <icon_coin><color_FBF236><value_1><end> more for <color_E14A68>each other<end> <all_and_totem_pole_likes> in the same column."

func add_conditional_effects(symbol, adjacent):
    for y in range(modloader.globals.reels.reel_height):
        if y != symbol.grid_position.y:
            symbol.add_effect_to_symbol(y, symbol.grid_position.x, effect().if_group("totem_pole_likes").change_value_bonus(values[0]))