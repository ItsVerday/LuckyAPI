extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "lightning_bolt"
    self.value = 2
    self.values = [2, 3]
    self.rarity = "rare"
    self.groups = ["thunder_cloud_lightning"]
    add_sfx_redirect("sun", "default", "default")

    self.texture = load_texture("res://valgos-content-pack/symbols/lightning_bolt.png")
    self.name = "Lightning Bolt"
    self.description = "<color_E14A68>Destroys<end> itself after <color_E14A68><value_2><end> turns. Adjacent symbols give <color_E14A68><value_1>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    var animate := [symbol]
    for i in adjacent:
        if i.type == "empty":
            continue
        symbol.add_effect_for_symbol(i, effect().change_value_multiplier(values[0]))
        animate.push_back(i)
    symbol.add_effect(effect().animate("shake", "default", animate))
    symbol.add_effect(effect().if_property_at_least("times_displayed", values[1]).set_destroyed().animate("shake"))

func update_value_text(symbol, values):
    symbol.value_text = values[1] - symbol.times_displayed
    symbol.value_text_color = "<color_E14A68>"