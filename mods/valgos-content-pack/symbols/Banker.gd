extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
    self.modloader = modloader

    self.id = "banker"
    self.value = 3
    self.values = [2]
    self.rarity = "rare"
    self.groups = ["organism", "human"]
    add_sfx_redirect("mrs_fruit")

    self.texture = load_texture("res://valgos-content-pack/symbols/banker.png")
    self.name = "Banker"
    self.description = "Adjacent <icon_bank> give <color_E14A68><value_1>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "bank"}], "anim": "bounce", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_multiplier", "diff": values[0]})