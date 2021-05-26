extends "res://modloader/SymbolPatcher.gd"

var value_index: int
func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "golden_egg"

func patch_values(values, value_index):
    self.value_index = value_index
    values.push_back(1)
    return values

func patch_description(description):
    return join(description, "Has a <color_E14A68><value_" + str(value_index + 1) + ">%<end> chance to grow into <all_or_golden_egg_adds>.")

func patch_groups(groups):
    groups.push_back("golden_goose_likes")
    groups.push_back("golden_goose_adds")
    return groups

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(value_index).change_group("golden_egg_adds").animate("shake"))