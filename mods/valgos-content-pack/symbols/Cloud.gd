extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "cloud"
    self.value = 2
    self.values = [2, 10]
    self.rarity = "uncommon"
    self.groups = []
    add_sfx_redirect("mrs_fruit")
    add_sfx_redirect("rain", "default", "transform")

    self.texture = load_texture("res://valgos-content-pack/symbols/cloud.png")
    self.name = "Cloud"
    self.description = "Adjacent <icon_rainbow> give <color_E14A68><value_1>x<end> more <icon_coin>. Has a <color_E14A68><value_2>%<end> chance of transforming into <icon_thunder_cloud>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_type("rainbow").change_value_multiplier(values[0]).animate("bounce", "default", [symbol, i]))
    symbol.add_effect(effect().if_value_random(1).change_type("thunder_cloud").animate("shake", "transform"))