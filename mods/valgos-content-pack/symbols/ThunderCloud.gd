extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "thunder_cloud"
    self.value = 4
    self.values = [15, 25]
    self.rarity = "rare"
    self.groups = []
    add_sfx_redirect("sun", "default", "transform")

    self.texture = load_texture("res://valgos-content-pack/symbols/thunder_cloud.png")
    self.name = "Thunder Cloud"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of transforming into <icon_cloud>. Also has a <color_E14A68><value_2>%<end> chance of <color_E14A68>adding<end> <icon_rain>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 1, "rand": true}], "anim": "shake", "tiles_to_add": [{"type": "rain"}]})
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 0, "rand": true}], "sfx_type": "transform", "value_to_change": "type", "diff": "cloud", "push_front": true})