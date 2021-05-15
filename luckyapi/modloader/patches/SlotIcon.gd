extends "res://Slot Icon_Slot Icon.gd"

onready var modloader: Reference = get_tree().modloader
var mod_symbol := null

var value_text := 0
var value_text_color = "<color_E14A68>"

func _ready():
    ._ready()
    update_mod_symbol(self.type)

func change_type(p_type: String, need_cond_effects: bool):
    .change_type(p_type, need_cond_effects)
    update_mod_symbol(p_type)
    set_texture($"/root/Main".icon_texture_database[self.type])

func update_mod_symbol(new_type: String):
    var mod_symbols := modloader.mod_symbols
    if mod_symbols.has(new_type):
        mod_symbol = mod_symbols[new_type]
    else:
        mod_symbol = null

func play_sfx(symbol, sfx_type):
    var player := symbol.sfx_player
    var sfx_total_num := 0
    var db := $"/root/Main".sfx_database["symbols"]
    var symbol_type := symbol.type

    if symbol.prev_data.size() > 0:
        symbol_type = symbol.prev_data[symbol.prev_data.size() - 1].type
	
    var mod_symbols := modloader.mod_symbols
    var mod_symbol := null
    if mod_symbols.has(symbol_type):
        mod_symbol = mod_symbols[symbol_type]
    
    if mod_symbol == null:
        if db.has(symbol_type) and db[symbol_type].has(sfx_type):
            sfx_total_num = db[symbol_type][sfx_type]
    else:
        sfx_total_num = mod_symbol.sfx[sfx_type]

    var sfx_directory := ""
    var sfx_redirect := null
    if mod_symbol != null:
        sfx_directory = mod_symbol.mod_name + "/"

        for test_sfx_redirect in mod_symbol.sfx_redirects:
            if sfx_type == test_sfx_redirect.new_sfx:
                sfx_redirect = test_sfx_redirect
    
    var sfx := null
    if sfx_redirect == null:
        var sfx_string := symbol_type + "-" + sfx_type + str(floor(rand_range(0, sfx_total_num)))
        if sfx_directory == "":
            sfx = load("res://sfx/%s.wav" % (str(sfx_string)))
        else:
            sfx = modloader.load_wav("res://" + sfx_directory + "sfx/%s.wav" % (str(sfx_string)))
    else:
        symbol_type = sfx_redirect.old_symbol
        var new_sfx_type := sfx_redirect.old_sfx
        sfx_total_num = db[symbol_type][new_sfx_type]
        var sfx_string := symbol_type + "-" + new_sfx_type + str(floor(rand_range(0, sfx_total_num)))
        sfx = load("res://sfx/%s.wav" % (str(sfx_string)))

    if sfx != null:
        player.set_stream(sfx)
        if symbol_type == "dog":
            player.stream.loop_begin = 15159
            player.stream.loop_end = 46494
        else:
            player.stream.loop_begin = 0
            player.stream.loop_end = 0
        player.volume_db = $"/root/Main/Options Sprite/Options".sfx.goal_volume
        if player.volume_db > -80 and not ($"/root/Main/Options Sprite/Options".mute_while_in_background and not $"/root/Main".window_focus):
            player.play()

func get_adjacent_icons():
    var grid_position := self.grid_position
    var adjacent := .get_adjacent_icons()
    var symbol_grid := self.reels.displayed_icons
    var patches := modloader.symbol_patches

    if mod_symbol != null and mod_symbol.modifies_self_adjacency:
        adjacent = mod_symbol.modify_self_adjacency(self, grid_position, adjacent, symbol_grid)
    if patches.has(self.type):
        for patch in patches[self.type]:
            if patch.modifies_self_adjacency:
                adjacent = patch.modify_self_adjacency(self, grid_position, adjacent, symbol_grid)
    
    var check_modifies_adjacent_adjacency := []
    for symbol in adjacent:
        check_modifies_adjacent_adjacency.push_back(symbol)
    
    for symbol in check_modifies_adjacent_adjacency:
        if symbol.mod_symbol != null and symbol.mod_symbol.modifies_adjacent_adjacency:
            adjacent = symbol.mod_symbol.modify_adjacent_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
        if patches.has(symbol.type):
            for patch in patches[symbol.type]:
                if patch.modifies_adjacent_adjacency:
                    adjacent = patch.modify_adjacent_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
    
    for row in symbol_grid:
        for symbol in row:
            if symbol.mod_symbol != null and symbol.mod_symbol.modifies_global_adjacency:
                adjacent = symbol.mod_symbol.modify_global_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
            if patches.has(symbol.type):
                for patch in patches[symbol.type]:
                    if patch.modifies_global_adjacency:
                        adjacent = patch.modify_global_adjacency(self, grid_position, symbol, symbol.grid_position, adjacent, symbol_grid)
    
    adjacent.erase(self)
    return adjacent

func update_value_text():
    if mod_symbol != null:
        mod_symbol.update_value_text(self, self.values)
        if self.value_text > 0 and not destroyed:
            get_child(1).raw_string = self.value_text_color + str(self.value_text) + "<end>"
            get_child(1).force_update = true
            displayed_text_value = str(self.value_text)
        else:
            get_child(1).raw_string = ""
            displayed_text_value = ""
    else:
        .update_value_text()

    var patches := modloader.symbol_patches[self.type]
    if patches != null:
        for patch in patches:
            if patch.has_method("update_value_text"):
                patch.update_value_text(self, self.values)
                if self.value_text > 0 and not destroyed:
                    get_child(1).raw_string = self.value_text_color + str(self.value_text) + "<end>"
                    get_child(1).force_update = true
                    displayed_text_value = str(self.value_text)
                else:
                    get_child(1).raw_string = ""
                    displayed_text_value = ""

func add_conditional_effects():
    var adj_icons := self.get_adjacent_icons()
    if mod_symbol != null:
        mod_symbol.add_conditional_effects(self, adj_icons)
        add_effect({"comparisons": [{"a": "destroyed", "b": true, "not_prev": true}], "value_to_change": "type", "diff": "empty", "push_front": true})
    else:
        .add_conditional_effects()
    
    var patches := modloader.symbol_patches[self.type]
    if patches != null:
        for patch in patches:
            if patch.has_method("add_conditional_effects"):
                patch.add_conditional_effects(self, adj_icons)