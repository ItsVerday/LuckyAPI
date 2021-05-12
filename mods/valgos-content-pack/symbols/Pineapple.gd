extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
    self.modloader = modloader

    self.id = "pineapple"
    self.value = 2
    self.values = [1]
    self.rarity = "uncommon"
    self.groups = ["piratelikes", "farmerlikes", "fruitlikes", "monkeylikes", "plant", "food", "fruit"]
    add_sfx_redirect("mrs_fruit")

    self.texture = load_texture("res://valgos-content-pack/symbols/pineapple.png")
    self.name = "Pineapple"
    self.description = "Adjacent <group_fruit> and <last_fruit> give <icon_coin><color_FBF236><value_1><end> more."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_to_symbol(i.grid_position.y, i.grid_position.x, {"comparisons": [{"a": "groups", "b": "fruit"}], "anim": "bounce", "anim_targets": [symbol, self.modloader.globals.reels.displayed_icons[i.grid_position.y][i.grid_position.x]], "value_to_change": "value_bonus", "diff": values[0]})