extends Reference

func load(modloader: Reference, tree: SceneTree):
    print("Test Mod loaded!")

    modloader.add_mod_symbol("res://examplemod/symbols/TestSymbol.gd")
    modloader.add_mod_symbol("res://examplemod/symbols/TestSymbol2.gd")