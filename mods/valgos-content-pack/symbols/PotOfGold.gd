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
    self.description = "Adjacent <icon_rainbow> give <color_E14A68><value_1>x<end> more <icon_coin>. Worth <color_E14A68><value_2>x<end> more for every adjacent <icon_rainbow>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "rainbow"}], "anim": "bounce", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_multiplier", "diff": values[0]})
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "rainbow"}], "anim": "circle", "anim_targets": [symbol], "target": symbol, "value_to_change": "value_multiplier", "diff": values[1]})