extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "banker"
    self.value = 3
    self.values = [2]
    self.rarity = "rare"
    self.groups = ["organism", "human"]
    self.sfx = ["growmoney"]

    self.texture = load_texture("res://valgos-content-pack/symbols/banker.png")
    self.name = "Banker"
    self.description = "Adjacent <all_and_bankerlikes> give <color_E14A68><value_1>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_group("bankerlikes").change_value_multiplier(values[0]).animate("bounce", 0, [symbol, i]))