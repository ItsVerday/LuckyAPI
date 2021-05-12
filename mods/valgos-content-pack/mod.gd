extends Reference

func load(modloader: Reference, tree: SceneTree):
    print("Loading Valgo's Content Pack...")

    modloader.add_mod_symbol("res://valgos-content-pack/symbols/Pineapple.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/BananaTree.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/CoconutTree.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/Bank.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/Banker.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/TotemPole.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/Rainbow.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/Cloud.gd")
    modloader.add_mod_symbol("res://valgos-content-pack/symbols/ThunderCloud.gd")