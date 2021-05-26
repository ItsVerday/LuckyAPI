extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "cloud"
    self.value = 2
    self.values = [2, 10]
    self.rarity = "uncommon"
    self.groups = ["thunder_cloud_adds"]
    add_sfx_redirect("mrs_fruit")
    add_sfx_redirect("rain", "default", "transform")

    self.texture = load_texture("res://valgos-content-pack/symbols/cloud.png")
    self.name = "Cloud"
    self.description = "Adjacent <all_and_cloudlikes> give <color_E14A68><value_1>x<end> more <icon_coin>. Has a <color_E14A68><value_2>%<end> chance of transforming into <all_or_cloud_adds>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_group("cloudlikes").change_value_multiplier(values[0]).animate("bounce", "default", [symbol, i]))
    symbol.add_effect(effect().if_value_random(1).change_group("cloud_adds").animate("shake", "transform"))