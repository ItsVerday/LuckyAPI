extends "res://modloader/utils.gd"

var id: String
var mod_name: String
var value := 1
var values := []
var rarity := "common"
var groups := []
var texture: ImageTexture
var extra_textures := {}
var sfx := []
var sfx_override := {}
var name: String
var description: String
var findable := true
var default_sound := "jump"

var modifies_self_adjacency := false
var modifies_adjacent_adjacency := false
var modifies_global_adjacency := false

func init(modloader: Reference, params):
    self.modloader = modloader
    print("No initialization behavior for custom symbol defined in " + self.get_script().get_path())
  
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

func can_find_symbol(symbol_grid):
    return findable