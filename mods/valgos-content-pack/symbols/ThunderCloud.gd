extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "thunder_cloud"
    self.value = 3
    self.values = [15, 25, 30, 2]
    self.rarity = "rare"
    self.groups = []
    add_sfx_redirect("sun", "default", "transform")

    self.texture = load_texture("res://valgos-content-pack/symbols/thunder_cloud.png")
    self.name = "Thunder Cloud"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of turning into <icon_cloud>. When turning into <icon_cloud>, has a <color_E14A68><value_4>%<end> chance of adding <icon_rainbow>. Has a <color_E14A68><value_2>%<end> chance of <color_E14A68>adding<end> <icon_rain>. Also has a <color_E14A68><value_3>%<end> chance of <color_E14A68>adding<end> <icon_lightning_bolt>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect(effect().if_value_random(1).add_symbol_type("rain").animate("shake"))
    symbol.add_effect(effect().if_value_random(2).add_symbol_type("lightning_bolt").animate("shake"))
    randomize()
    if values[0] > rand_range(0, 100):
        symbol.add_effect(effect().change_type("cloud").animate("circle"))
        symbol.add_effect(effect().if_value_random(3).add_symbol_type("rainbow"))