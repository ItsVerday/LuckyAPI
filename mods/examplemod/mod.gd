extends Reference

func load(modloader: Reference, mod_info, tree: SceneTree):
    modloader.add_mod_symbol("res://examplemod/symbols/TestSymbol.gd")
    modloader.add_mod_symbol("res://examplemod/symbols/TestSymbol2.gd")

    modloader.add_symbol_patch("res://examplemod/symbols/Coin_Patched.gd")