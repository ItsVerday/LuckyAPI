extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "dragon"
    self.value = 5
    self.values = [3, 5]
    self.rarity = "very_rare"
    self.groups = ["organism", "animal"]
    add_sfx_redirect("beastmaster")

    self.texture = load_texture("res://valgos-content-pack/symbols/dragon.png")
    self.name = "Dragon"
    self.description = "Adjacent <icon_dragon> give <color_E14A68><value_1>x<end> more <icon_coin>. <color_E14A68>Destroys<end> adjacent <all_and_dragonlikes>. Permanently gives <icon_coin><color_FBF236><value_2><end> for each symbol <color_E14A68>destroyed<end>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_type("dragon").change_value_multiplier(values[0]).animate("circle", "default", [symbol, i]))
        symbol.add_effect_for_symbol(i, effect().if_group("dragonlikes").set_destroyed())
        symbol.add_effect_for_symbol(i, effect().if_destroyed().if_group("dragonlikes").set_target(symbol).add_permanent_bonus(values[1]).animate("shake", "default", [symbol, i]))

func update_value_text(symbol, values):
    symbol.value_text = symbol.permanent_bonus
    symbol.value_text_color = "<color_FBF236>"