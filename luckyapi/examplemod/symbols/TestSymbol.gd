extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference):
    self.modloader = modloader

    self.id = "test"
    self.value = 10
    self.values = [1]
    self.rarity = "common"
    self.groups = []

    self.texture = load_texture("res://examplemod/symbols/test.png")
    add_sfx_redirect("oyster")
    
    self.name = "Test Symbol"
    self.description = "A test symbol used to test LuckyAPI."

func add_conditional_effects(symbol, adjacent):
    # Testing the effect system built into the game
    var symbol_arr := []
    for i in range(self.values[0]):
        symbol_arr.push_back({"type": "eldritch_beast"})
    symbol.add_effect({"comparisons": [], "anim": "shake", "tiles_to_add": symbol_arr})