extends "res://Slot Icon_Slot Icon.gd"

onready var modloader: Reference = get_tree().modloader
var mod_symbol := null

var value_text
var multiplier_text
var bonus_text
var value_text_color := "<color_E14A68>"
var multiplier_text_color := "<color_E14A68>"
var bonus_text_color := "<color_E14A68>"
var has_effects := false
var persistent_data := {}
var non_persistent_data := {}
var old_translate := 0

func _ready():
    ._ready()
    update_mod_symbol(self.type)

func _input(event):
    if hovering and event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT and not modloader.globals.main.lmb_down:
        if modloader.globals.pop_up.emails.size() == 0:
            if mod_symbol and mod_symbol.has_method("on_click"):
                mod_symbol.on_click(self, mod_symbol)
    ._input(event)

func change_type(p_type: String, need_cond_effects: bool):
    update_mod_symbol(p_type)
    .change_type(p_type, need_cond_effects)
    persistent_data = {}
    non_persistent_data = {}
    set_texture(modloader.databases.icon_texture_database[self.type])
    update_value_text()

func update_mod_symbol(new_type: String):
    mod_symbol = modloader.mod_symbols[new_type] if modloader.mod_symbols.has(new_type) else null

func start_animation(anim):
    .start_animation(anim)

    var animation_to_modify := self.queued_anims[0]
    for mod_id in modloader.mod_load_order:
        var mod := modloader.mods[mod_id]
        if mod.has_method("modify_animation"):
            animation_to_modify = mod.modify_animation(animation_to_modify)
    self.queued_anims[0] = animation_to_modify

    if animation_to_modify == "ordered_texture_cycle" and animation_to_modify.anim_timer == 0:
        var arrow_order := [1, 2, 3, 5, 8, 7, 6, 4]
        texture = extra_textures[arrow_order[(int(queued_anims[0].anim_result) % int(extra_textures.size()))] - 1]
        if texture != null:
            set_texture(texture)

func play_sfx(symbol, sfx_type):
    if modloader.globals.options.animation_speed == 0 and reels.sfx_timer > 0:
        delayed_sfx.push_back([symbol, sfx_type])
        return
    var player = symbol.sfx_player
    var symbol_type = symbol.type
    if symbol.prev_data.size() > 0:
        symbol_type = symbol.prev_data[symbol.prev_data.size() - 1].type
    
    var new_mod_symbol = modloader.mod_symbols[symbol_type] if modloader.mod_symbols.has(symbol_type) else mod_symbol
    var patches = modloader.symbol_patches[symbol_type]
    
    if !new_mod_symbol and !patches:
        .play_sfx(symbol, sfx_type)
        return
    
    sfx_type = sfx_type if sfx_type else new_mod_symbol.default_sound
    var sfx_directory : String = ""
    
    if new_mod_symbol:
        if new_mod_symbol.sfx.has(sfx_type):
            if new_mod_symbol.sfx_overrides.has(sfx_type):
                if new_mod_symbol.sfx_overrides[sfx_type].path_override:
                    sfx_directory += new_mod_symbol.mod_name + "/"
        else:
            .play_sfx(symbol, sfx_type)
            return
    
    if patches:
        patches.invert() # we only care about applying the last patch that updates this value
        var found = false
        for patch in patches:
            if patch.sfx_overrides.has(sfx_type):
                found = true
                var redirect := sfx_type
                if patch.sfx_overrides[sfx_type].has("to"):
                    redirect = patch.sfx_overrides[sfx_type].to
                if patch.sfx_overrides[sfx_type].path_override:
                    sfx_directory += patch.mod_name + "/"
                else:
                    .play_sfx(symbol, redirect)
                    return
                sfx_type = redirect
                break
        if !found:
            .play_sfx(symbol, sfx_type)
            return
    
    var db = modloader.databases.sfx_database["symbols"]
    var sfx_total_num = db[sfx_type] if db.has(sfx_type) else 0
    var sfx_string = sfx_type + str(floor(rand_range(0, sfx_total_num)))
    var full_path = "res://%ssfx/%s.wav" % [sfx_directory, sfx_string]
    var f = File.new()
    var sfx
    if f.file_exists(full_path):
        sfx = modloader.load_wav(full_path)
    else:
        .play_sfx(symbol, sfx_type)
	
    if sfx != null:
        player.set_stream(sfx)
        if sfx_type == "dogpet":
            player.stream.loop_begin = 15159
            player.stream.loop_end = 46494
        else:
            player.stream.loop_begin = 0
            player.stream.loop_end = 0
        player.volume_db = modloader.globals.options.sfx.goal_volume
        if player.volume_db > -80 and not (modloader.globals.options.mute_while_in_background and not modloader.globals.main.window_focus):
            player.play()
            reels.sfx_timer = 1

func set_texture(texture):
    .set_texture(texture)
    update_scaling(texture)

func update_scaling(texture):
    var scaling_factor := 12 / float(max(texture.get_width(), texture.get_height()))
    scale = Vector2(scaling_factor, scaling_factor)
    var translate := (1 - scaling_factor) * 14
    self.offset = Vector2(self.offset.x + translate - old_translate, self.offset.y + translate - old_translate)
    self.base_offset = Vector2(self.base_offset.x + translate - old_translate, self.base_offset.y + translate - old_translate)
    old_translate = translate

func update():
    .update()

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
    self.value_text = null
    self.multiplier_text = null
    self.bonus_text = null
    .update_value_text()
    
    if mod_symbol and mod_symbol.has_method("update_value_text"):
        _update_value_text_inner(mod_symbol)
    var patches = modloader.symbol_patches[self.type]
    if patches:
        for patch in patches:
            if patch.has_method("update_value_text"):
                _update_value_text_inner(patch)

func _update_value_text_inner(symbol):
    symbol.update_value_text(self, self.values)
    if self.value_text != null and not destroyed:
        get_child(1).raw_string = self.value_text_color + str(self.value_text) + "<end>"
        get_child(1).force_update = true
        displayed_text_value = str(self.value_text)
    if self.multiplier_text != null and not destroyed:
        get_child(2).raw_string = self.multiplier_text_color + "x" + str(self.multiplier_text) + "<end>"
        get_child(2).force_update = true
        displayed_multiplier_value = str(self.multiplier_text)
    if self.bonus_text != null and not destroyed:
        get_child(3).raw_string = self.bonus_text_color + "+" + str(self.bonus_text) + "<end>"
        get_child(3).force_update = true
        displayed_bonus_value = str(self.bonus_text)

func add_conditional_effects():
    var adj_icons := self.get_adjacent_icons()
    if mod_symbol != null:
        mod_symbol.add_conditional_effects(self, adj_icons)
        
    var patches := modloader.symbol_patches[self.type]
    if patches != null:
        for patch in patches:
            if patch.has_method("add_conditional_effects"):
                patch.add_conditional_effects(self, adj_icons)
    
    .add_conditional_effects()
    
    has_effects = true

func add_effect(effect):
    if effect.effect_dictionary != null:
        .add_effect(effect.effect_dictionary)
    else:
        .add_effect(effect)

func add_effect_to_symbol(y, x, effect):
    self.texture_type = self.type
    if effect.effect_dictionary != null:
        .add_effect_to_symbol(y, x, effect.effect_dictionary)
    else:
        .add_effect_to_symbol(y, x, effect)

func add_effect_for_symbol(symbol, effect):
    add_effect_to_symbol(symbol.grid_position.y, symbol.grid_position.x, effect)

func do_comparison(comparison, c, target, c_effects, c_tbe):
    var result := .do_comp(comparison, c, target, c_effects, c_tbe)

    var comparison_target = self
    if comparison.has("dynamic_a_target"):
        comparison_target = comparison.dynamic_a_target
    
    if comparison.has("lapi_data"):
        var key := comparison.lapi_key
        var value := comparison.lapi_value
        var persistent := comparison.lapi_persistent
        var default := comparison.lapi_default
        var comp
        if persistent:
            comp = comparison_target.get_persistent_data(key, default)
        else:
            comp = comparison_target.get_non_persistent_data(key, default)
        
        match comparison.lapi_type:
            "rand":
                if comp < modloader.random(0, 100):
                    return false
            "equals":
                if comp != value:
                    return false
            "less_than":
                if comp >= value:
                    return false
            "greater_than_eq":
                if comp < value:
                    return false
        return true
    
    return result

func do_comp(comparison, c, target, c_effects, c_tbe):
    var result := do_comparison(comparison, c, target, c_effects, c_tbe)
    if comparison.has("negate"):
        result = not result
    
    return result

func do_diff(c, target, c_tbe):
    .do_diff(c, target, c_tbe)

    if c.has("lapi_data"):
        var key := c.lapi_key
        var persistent := c.lapi_persistent
        match c.lapi_operation:
            "set":
                if persistent:
                    target.set_persistent_data(key, c.lapi_value)
                else:
                    target.set_non_persistent_data(key, c.lapi_value)
            "add":
                if persistent:
                    target.set_persistent_data(key, target.get_persistent_data(key, 0) + c.lapi_value)
                else:
                    target.set_non_persistent_data(key, target.get_non_persistent_data(key, 0) + c.lapi_value)
            "mult":
                if persistent:
                    target.set_persistent_data(key, target.get_persistent_data(key, 1) * c.lapi_value)
                else:
                    target.set_non_persistent_data(key, target.get_non_persistent_data(key, 1) * c.lapi_value)
    
    if c.has("sub_effects"):
        if c.sub_effects.size() > 0:
            var arr := []
            for sub in c.sub_effects:
                arr.push_back(sub.effect_dictionary)
            
            check_conditional_effects(arr)

func get_persistent_data(key: String, default := 0):
    if persistent_data.has(key):
        return persistent_data[key]
    
    return default

func set_persistent_data(key: String, value):
    persistent_data[key] = value

func get_non_persistent_data(key: String, default := 0):
    if non_persistent_data.has(key):
        return non_persistent_data[key]
    
    return default

func set_non_persistent_data(key: String, value):
    non_persistent_data[key] = value

func condition(cond):
    return modloader.symbol_condition(self.type, cond)