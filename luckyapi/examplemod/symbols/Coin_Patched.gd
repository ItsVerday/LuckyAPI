extends "res://modloader/SymbolPatcher.gd"

func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "coin"

func patch_name(name):
    return name + " (Patched)"

func patch_description(description):
    return "Cool symbol :)"