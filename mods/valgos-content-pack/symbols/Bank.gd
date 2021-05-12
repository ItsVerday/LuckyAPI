extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
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
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 0, "rand": true}], "sfx_type": "spawn", "anim": "circle", "tiles_to_add": [{"type": "coin"}]})

    symbol.add_effect({"comparisons": [{"a": "times_displayed", "b": values[1], "greater_than_eq": true}], "value_to_change": "permanent_bonus", "diff": values[2]})
    symbol.add_effect({"comparisons": [{"a": "times_displayed", "b": values[1], "greater_than_eq": true}], "anim": "shake", "value_to_change": "times_displayed", "diff": 0, "overwrite": true})

func update_value_text(symbol, values):
    symbol.value_text = symbol.permanent_bonus
    symbol.value_text_color = "<color_FBF236>"