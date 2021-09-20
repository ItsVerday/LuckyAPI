extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "golden_goose"
    self.value = 4
    self.values = [10, 3]
    self.rarity = "very_rare"
    self.groups = ["organism", "animal", "bird", "golden_egg_adds"]
    self.sfx = ["honk", "jump"]

    self.texture = load_texture("res://valgos-content-pack/symbols/golden_goose.png")
    self.name = "Golden Goose"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of <color_E14A68>adding<end> <all_or_golden_goose_adds>. Adjacent <all_and_golden_goose_likes> give <color_E14A68><value_2>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(0).add_symbol_group("golden_goose_adds").animate("shake", 0))
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_group("golden_goose_likes").change_value_multiplier(values[1]).animate("bounce", 1, [symbol, i]))