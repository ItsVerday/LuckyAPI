extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "bank"
    self.value = 1
    self.values = [5, 5, 1]
    self.rarity = "uncommon"
    self.groups = []
    add_sfx_redirect("oyster", "default", "spawn")

    self.texture = load_texture("res://valgos-content-pack/symbols/bank.png")
    self.name = "Bank"
    self.description = "Permanently gives <icon_coin><color_FBF236><value_3><end> more after every <color_E14A68><value_2> turns<end>. Has a <color_E14A68><value_1>%<end> chance of <color_E14A68>adding<end> <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(0).add_symbol_type("coin").animate("bounce", "spawn"))
    symbol.add_effect(effect().if_property_at_least("times_displayed", values[1]).add_permanent_bonus(values[2]))
    symbol.add_effect(effect().if_property_at_least("times_displayed", values[1]).set_value("times_displayed", 0).animate("shake"))

func update_value_text(symbol, values):
    symbol.value_text = symbol.permanent_bonus
    symbol.value_text_color = "<color_FBF236>"