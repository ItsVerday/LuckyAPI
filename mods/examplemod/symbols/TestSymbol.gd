extends "res://modloader/ModSymbol.gd"

func init(modloader: Reference, params):
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
    symbol.add_effect(effect().add_symbol_type("eldritch_beast").animate("shake"))