extends "res://modloader/SymbolPatcher.gd"

var value_index: int
func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "banana"

func patch_groups(groups):
    groups.push_back("banana_tree_adds")
    return groups