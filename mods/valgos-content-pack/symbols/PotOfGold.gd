extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "pot_of_gold"
    self.value = 5
    self.values = [3, 2]
    self.rarity = "very_rare"
    self.groups = []
    add_sfx_redirect("king_midas")

    self.texture = load_texture("res://valgos-content-pack/symbols/pot_of_gold.png")
    self.name = "Pot of Gold"
    self.description = "Adjacent <all_and_pot_of_gold_likes> give <color_E14A68><value_1>x<end> more <icon_coin>. Worth <color_E14A68><value_2>x<end> more for every adjacent <icon_rainbow>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_group("pot_of_gold_likes").change_value_multiplier(values[0]).animate("bounce", "default", [symbol, i]))
        symbol.add_effect_for_symbol(i, effect().if_group("pot_of_gold_likes").set_target(symbol).change_value_multiplier(values[1]).animate("circle"))