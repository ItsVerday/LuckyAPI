extends "res://Slot Icon_Slot Icon.gd"

onready var modloader: Reference = get_tree().modloader
var mod_symbol := null

func _ready():
    update_mod_symbol(self.type)
    ._ready()

func change_type(p_type: String, need_cond_effects: bool):
    update_mod_symbol(p_type)
    .change_type(p_type, need_cond_effects)

func update_mod_symbol(new_type: String):
    var mod_symbols := modloader.mod_symbols
    if mod_symbols.has(new_type):
        mod_symbol = mod_symbols[new_type]
    else:
        mod_symbol = null

func get_adjacent_icons():
    var grid_position := self.grid_position
    var adjacent := .get_adjacent_icons()
    var symbol_grid := self.reels.displayed_icons

    if mod_symbol != null and mod_symbol.modifies_self_adjacency:
        adjacent = mod_symbol.modify_self_adjacency(self, grid_position, adjacent, symbol_grid)
    
    var check_modifies_adjacent_adjacency := []
    for symbol in adjacent:
        check_modifies_adjacent_adjacency.push_back(symbol)
    
    for symbol in check_modifies_adjacent_adjacency:
        if symbol.mod_symbol != null and symbol.mod_symbol.modifies_adjacent_adjacency:
            adjacent = symbol.mod_symbol.modify_adjacent_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
    
    for row in symbol_grid:
        for symbol in row:
            if symbol.mod_symbol != null and symbol.mod_symbol.modifies_global_adjacency:
                adjacent = symbol.mod_symbol.modify_global_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
    
    adjacent.erase(self)
    return adjacent

func update_value_text():
    if mod_symbol != null:
        mod_symbol.update_value_text(self, self.values)
        if mod_symbol.value_text > 0 and not destroyed:
            get_child(1).raw_string = mod_symbol.value_text_color + str(mod_symbol.value_text) + "<end>"
            get_child(1).force_update = true
            displayed_text_value = str(mod_symbol.value_text)
        else:
            get_child(1).raw_string = ""
            displayed_text_value = ""
    else:
        .update_value_text()

func add_conditional_effects():
    if mod_symbol != null:
        var adj_icons := self.get_adjacent_icons()
        mod_symbol.add_conditional_effects(self, adj_icons)
    else:
        .add_conditional_effects()