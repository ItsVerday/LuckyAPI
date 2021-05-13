extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
    self.modloader = modloader

    self.id = "golden_goose"
    self.value = 4
    self.values = [50, 3]
    self.rarity = "very_rare"
    self.groups = ["organism", "animal", "bird"]
    add_sfx_redirect("goose")
    add_sfx_redirect("mrs_fruit", "default", "boost")

    self.texture = load_texture("res://valgos-content-pack/symbols/golden_goose.png")
    self.name = "Golden Goose"
    self.description = "Has a <color_E14A68><value_1>%<end> chance of <color_E14A68>adding<end> <icon_golden_egg>. Adjacent <icon_golden_egg> give <color_E14A68><value_2>x<end> more <icon_coin>."

func add_conditional_effects(symbol, adjacent):
    symbol.add_effect({"comparisons": [{"a": "values", "value_num": 0, "rand": true}], "anim": "shake", "tiles_to_add": [{"type": "golden_egg"}]})

    for i in adjacent:
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "type", "b": "golden_egg"}], "anim": "bounce", "sfx_type": "boost", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_multiplier", "diff": values[1]})