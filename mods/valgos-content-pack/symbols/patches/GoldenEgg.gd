extends "res://modloader/SymbolPatcher.gd"

func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "golden_egg"

func patch_values(values):
    values.push_back(1)
    return values

func patch_description(description):
    return join(description, "Has a <color_E14A68><value_1>%<end> chance to grow into <icon_golden_goose>.")

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(0).change_type("golden_goose").animate("shake"))