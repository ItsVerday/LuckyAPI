extends "res://modloader/SymbolPatcher.gd"

var value_index: int
func init(modloader: Reference, params):
    self.modloader = modloader
    self.id = "coconut"

func patch_groups(groups):
    groups.push_back("coconut_tree_adds")
    return groups