extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
    self.modloader = modloader

    self.id = "dragon"
    self.value = 7
    self.values = [3, 1]
    self.rarity = "very_rare"
    self.groups = ["organism", "animal"]
    add_sfx_redirect("beastmaster")

    self.texture = load_texture("res://valgos-content-pack/symbols/dragon.png")
    self.name = "Dragon"
    self.description = "Adjacent <icon_dragon> give <color_E14A68><value_1>x<end> more <icon_coin>. <color_E14A68>Destroys<end> adjacent <icon_dragonfruit>. Permanently gives <icon_coin><color_FBF236><value_2><end> for each symbol <color_E14A68>destroyed<end>."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "dragon"}], "anim": "circle", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_multiplier", "diff": values[0]})

        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "dragonfruit"}], "value_to_change": "destroyed", "diff": true})
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "destroyed", "b": true}, {"a": "type", "b": "dragonfruit"}], "anim": "shake", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "target": symbol, "value_to_change": "permanent_bonus", "diff": values[1]})

func update_value_text(symbol, values):
    symbol.value_text = symbol.permanent_bonus
    symbol.value_text_color = "<color_FBF236>"