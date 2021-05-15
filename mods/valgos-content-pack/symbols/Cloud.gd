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
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "rainbow"}], "anim": "bounce", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_multiplier", "diff": values[0]})
    
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 1, "rand": true}], "anim": "shake", "sfx_type": "transform", "value_to_change": "type", "diff": "thunder_cloud", "push_front": true})