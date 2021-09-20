extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "dragon"
    self.value = 4
    self.values = [3, 2]
    self.rarity = "very_rare"
    self.groups = ["organism", "animal"]
    self.sfx = ["beastmaster"]

    self.texture = load_texture("res://valgos-content-pack/symbols/dragon.png")
    self.name = "Dragon"
    self.description = "Adjacent <icon_dragon> give <color_E14A68><value_1>x<end> more <icon_coin>. <color_E14A68>Destroys<end> adjacent <all_and_dragonlikes>. Permanently gives <icon_coin><color_FBF236><value_2><end> for each symbol <color_E14A68>destroyed<end>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_type("dragon").change_value_multiplier(values[0]).animate("circle", 0, [symbol, i]))
        symbol.add_effect_for_symbol(i, effect().if_group("dragonlikes").set_destroyed())
        symbol.add_effect_for_symbol(i, effect().if_destroyed().if_group("dragonlikes").set_target(symbol).add_permanent_bonus(values[1]).animate("shake", 0, [symbol, i]))