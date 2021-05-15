extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "lightning_bolt"
    self.value = 2
    self.values = [1.5, 3]
    self.rarity = "rare"
    self.groups = []
    add_sfx_redirect("sun", "default", "default")

    self.texture = load_texture("res://valgos-content-pack/symbols/lightning_bolt.png")
    self.name = "Lightning Bolt"
    self.description = "<color_E14A68>Destroys<end> itself after <color_E14A68><value_2><end> turns. Adjacent symbols give <color_E14A68><value_1>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    var animate := [symbol]
    for i in adjacent:
        if i.type == "empty":
            continue
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [], "value_to_change": "value_multiplier", "diff": values[0]})
        animate.push_back(i)
    symbol.add_effect({"comparisons": [], "sfx_type": "default", "anim": "shake", "anim_targets": animate})
    symbol.add_effect({"comparisons": [{"a": "times_displayed", "b": values[1], "greater_than_eq": true}], "anim": "shake", "value_to_change": "destroyed", "diff": true})

func update_value_text(symbol, values):
    symbol.value_text = values[1] - symbol.times_displayed
    symbol.value_text_color = "<color_E14A68>"