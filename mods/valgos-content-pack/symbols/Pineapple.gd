extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
    self.modloader = modloader

    self.id = "pineapple"
    self.value = 2
    self.values = [1]
    self.rarity = "uncommon"
    self.groups = ["farmerlikes", "fruitlikes", "monkeylikes", "plant", "food", "fruit"]
    add_sfx_redirect("mrs_fruit")

    self.texture = load_texture("res://valgos-content-pack/symbols/pineapple.png")
    self.name = "Pineapple"
    self.description = "Adjacent <group_fruit> and <last_fruit> give <icon_coin><color_FBF236><value_1><end> more."

func add_conditional_effects(symbol, adjacent):
    for i in adjacent:
        symbol.add_effect_for_symbol(i, effect().if_group("fruit").change_value_bonus(values[0]).animate("bounce", "default", [symbol, i]))