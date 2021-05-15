extends "res://modloader/utils.gd"

var modloader: Reference

var id: String
var value := 1
var values := []
var rarity := "common"
var groups := []
var texture: ImageTexture
var extra_textures := {}
var sfx := {}
var sfx_redirects := []
var name: String
var description: String
var mod_name: String

var modifies_self_adjacency := false
var modifies_adjacent_adjacency := false
var modifies_global_adjacency := false

func init(modloader: Reference, params):
    self.modloader = modloader
    print("No initialization behavior for custom symbol defined in " + self.get_script().get_path())

func add_sfx_redirect(old_symbol: String, old_sfx := "default", new_sfx := "default"):
    sfx_redirects.push_back({
        "old_symbol": old_symbol,
        "old_sfx": old_sfx,
        "new_sfx": new_sfx
    })

func modify_self_adjacency(myself, grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_adjacent_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_global_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func update_value_text(symbol, values):
    pass

func add_conditional_effects(adjacent):
    pass