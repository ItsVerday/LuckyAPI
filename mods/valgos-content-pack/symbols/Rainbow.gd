extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "rainbow"
    self.value = 4
    self.values = [4]
    self.rarity = "very_rare"
    self.groups = ["cloudlikes", "pot_of_gold_likes", "thunder_cloud_rainbow"]
    self.sfx = ["shine"]

    self.texture = load_texture("res://valgos-content-pack/symbols/rainbow.png")
    self.name = "Rainbow"
    self.description = "If every <color_E14A68>adjacent symbol<end> is <color_E14A68>different<end>, adjacent symbols give <color_E14A68><value_1>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    var adjacent_symbols := []
    var adjacent_positions := []
    var all_different := true
    for adjacent_symbol in adjacent:
        if adjacent_symbol.type == "empty":
            continue
        if adjacent_symbols.find(adjacent_symbol.type) != -1:
            all_different = false
            break
        adjacent_symbols.push_back(adjacent_symbol.type)
    
    if all_different:
        var animate := [symbol]
        for i in adjacent:
            if i.type == "empty":
                continue
            symbol.add_effect_for_symbol(i, effect().change_value_multiplier(values[0]))
            animate.push_back(i)
        symbol.add_effect(effect().animate("circle", 0, animate))