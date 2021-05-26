extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "black_hole"
    self.value = 0
    self.values = [10]
    self.rarity = "very_rare"
    self.groups = []
    add_sfx_redirect("hex_of_destruction")

    self.texture = load_texture("res://valgos-content-pack/symbols/black_hole.png")
    self.name = "Black Hole"
    self.description = "<color_E14A68>Destroys<end> a random <color_E14A68>adjacent symbol<end>, giving <icon_coin> equal to <color_E14A68><value_1>x<end> the destroyed symbol's <color_E14A68>base value<end>."

func add_conditional_effects(symbol, adjacent):
    if symbol.has_effects:
        return

    var targets := []
    for symbol in adjacent:
        if symbol.type != "empty":
            targets.push_back(symbol)
    if targets.size() == 0:
        return
    
    var target := array_pick(targets)
    symbol.add_effect(effect().animate("rotate", "default", [symbol, target]))
    symbol.add_effect(effect().change_value_bonus(target.value * values[0]))
    symbol.add_effect_for_symbol(target, effect().set_destroyed())