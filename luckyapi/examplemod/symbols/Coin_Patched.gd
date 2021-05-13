extends "res://modloader/SymbolPatch.gd"

func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "coin"

func patch_value(value):
    return 100

func patch_name(name):
    return name + " (Patched)"

func patch_description(description):
    return "Cool symbol :)"