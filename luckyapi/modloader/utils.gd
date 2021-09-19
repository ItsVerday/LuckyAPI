extends Reference

var modloader: Reference

func nvl(a, b = 0, keep_falsy := true):
    if keep_falsy:
        if a in ["", 0, false, [], {}]:
            return a
    return a if a else b

func random(lower: float, upper: float):
    randomize()
    return rand_range(lower, upper)

func match_value(value: String, match_against):
    if match_against is String:
        if match_against == "*":
            return true
        
        return value == match_against
    elif match_against is Array:
        for element in match_against:
            if match_value(value, element):
                return true
        
        return false
    
    return false
    
func check_extends(script, base):
    var check_script := script
    while check_script != null:
        if check_script.resource_path == base:
            return true
        
        check_script = check_script.get_base_script()
    
    return false

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    OS.alert("LuckyAPI Modloader has encountered an error!\n" + message + "\nJoin our discord at https://discord.gg/7ZncdvbXp7 for assistance.")
    var n = null
    n.fail_runtime_check()



func add_translation(key: String, value: String, locale := "en"):
    var translation := modloader.translations[locale]
    if translation == null:
        translation = Translation.new()
        translation.locale = locale
        TranslationServer.add_translation(translation)
        modloader.translations[locale] = translation
    
    translation.add_message(key, value)

func translate(key: String, fix := true):
    var locale := TranslationServer.get_locale()
    if modloader.translations.has(locale):
        var translation := modloader.translations[locale]
        var messages = translation.get_message_list()
        for check_key in messages:
            if key == check_key:
                var tr := translation.get_message(key)
                if fix:
                    tr = fix_translation(tr)
                return tr
    
    var tr := TranslationServer.translate(key)
    if fix:
        tr = fix_translation(tr)
    return tr

func join(a: String, b: String, delimeter := " ") -> String:
    if a.length() == 0:
        return b
    
    if b.length() == 0:
        return a
    
    return a + delimeter + b

func splice(string, start, end, replace):
    return string.substr(0, start) + replace + string.substr(end)

func fix_translation(string):
    return fix_all_tags(string)

func fix_all_tags(string):
    var regex_all := RegEx.new()
    regex_all.compile("<all_(and|or|na)_([a-zA-Z0-9_]+)>")
    var result_all := regex_all.search(string)
    while result_all != null:
        var join : String
        if result_all.get_string(1) == "na":
            join = ""
        else:
            join = result_all.get_string(1) + " "
        var id := result_all.get_string(2)
        var group_members := get_group_members(id)
        var replace := "<group_" + id + "> " + join + "<last_" + id + ">"
        if group_members.size() == 0:
            replace = "none"
        if group_members.size() == 1:
            replace = "<icon_" + group_members[0] + ">"
        
        string = splice(string, result_all.get_start(), result_all.get_end(), replace)
        result_all = regex_all.search(string)
    
    return string
    
func get_names_list(arr: Array):
    if arr.size() == 0:
        return "N/A"
    elif arr.size() == 1:
        return arr[0]
    elif arr.size() == 2:
        return arr[0] + " and " + arr[1]
    
    var string := ""
    var index := arr.size() - 1
    for name in arr:
        if index == 0:
            string += "and "
        string += name
        if index > 0:
            string += ", "
        index -= 1
    
    return string



func subtract(a: Array, b: Array) -> Array:
    var result := []
    var bag := {}
    for item in b:
        if not bag.has(item):
            bag[item] = 0
        bag[item] += 1
    for item in a:
        if bag.has(item):
            bag[item] -= 1
            if bag[item] == 0:
                bag.erase(item)
        else:
            result.append(item)
    return result

func merge(a: Array, b: Array) -> Array:
    var result := a
    if result.size() == 0:
        return b
    for item in b:
        if not item in a:
            result.push_back(item)
    return result

func array_pick(arr: Array):
    return arr[floor(random(0, arr.size()))]



func get_group_members(id):
    if modloader.databases.group_database.symbols.has(id):
        return modloader.databases.group_database.symbols[id]
    
    if modloader.databases.group_database.items.has(id):
        return modloader.databases.group_database.items[id]
    
    return []

func can_find_symbol(type):
    var displayed_icons := modloader.globals.reels.displayed_icons
    var mod_symbols := modloader.mod_symbols
    if mod_symbols.has(type):
        if not mod_symbols[type].can_find_symbol(displayed_icons):
            return false
    
    var patches := modloader.symbol_patches
    if patches.has(type):
        for patch in patches[type]:
            if not patch.can_find_symbol(displayed_icons):
                return false
    
    return true

func get_symbol_groups(symbol_id: String):
    var groups := []
    for group_id in modloader.databases.group_database.symbols:
        if symbol_id in modloader.databases.group_database.symbols[group_id]:
            groups.push_back(group_id)
    
    return groups

func get_symbol_rarity(symbol_id: String):
    for rarity in modloader.databases.rarity_database.symbols:
        if symbol_id in modloader.databases.rarity_database.symbols[rarity]:
            return rarity
    
    return null

func check_symbol_condition(symbol_id: String, condition):
    var negate := false
    if condition.has("negate"):
        negate = condition.negate
    
    if condition.has("and"):
        for inner_condition in condition["and"]:
            if not symbol_condition(symbol_id, inner_condition):
                return negate
        
        return not negate

    if condition.has("or"):
        for inner_condition in condition["or"]:
            if symbol_condition(symbol_id, inner_condition):
                return not negate
        
        return negate

    if condition.has("type"):
        if not match_value(symbol_id, condition.type):
            return negate

    if condition.has("not_type"):
        if match_value(symbol_id, condition.not_type):
            return negate

    if condition.has("group"):
        var group_match := false
        var groups := get_symbol_groups(symbol_id)

        if groups.size() > 0:
            for symbol_group in groups:
                if match_value(symbol_group, condition.group):
                    group_match = true
                    break
        else:
            group_match = match_value("nogroup", condition.group)
        
        if not group_match:
            return negate
    
    if condition.has("not_group"):
        var group_match := false
        var groups := get_symbol_groups(symbol_id)

        if groups.size() > 0:
            for symbol_group in groups:
                if match_value(symbol_group, condition.not_group):
                    group_match = true
                    break
        else:
            group_match = match_value("nogroup", condition.not_group)
        
        if group_match:
            return negate

    if condition.has("rarity"):
        if not match_value(get_symbol_rarity(symbol_id), condition.rarity):
            return negate

    if condition.has("not_rarity"):
        if match_value(get_symbol_rarity(symbol_id), condition.not_rarity):
            return negate
    
    if condition.has("value"):
        if not match_value(modloader.databases.tile_database[symbol_id].value, condition.value):
            return negate
    
    if condition.has("not_value"):
        if match_value(modloader.databases.tile_database[symbol_id].value, condition.not_value):
            return negate
    
    if condition.has("min_value"):
        var value := modloader.databases.tile_database[symbol_id].value
        if value < condition.min_value:
            return negate
    
    if condition.has("max_value"):
        var value := modloader.databases.tile_database[symbol_id].value
        if value > condition.max_value:
            return negate
    
    return not negate

func get_symbol_list(group := "*", rarity := "*", ignore_can_find := false):
    var symbols := []
    for symbol_key in modloader.databases.tile_database.keys():
        var symbol := modloader.databases.tile_database[symbol_key]
        var group_match := false

        if symbol.groups.size() > 0:
            for symbol_group in symbol.groups:
                if match_value(symbol_group, group):
                    group_match = true
                    break
        else:
            group_match = match_value("nogroup", group)
        
        if not group_match:
            continue
        
        if match_value(symbol.rarity, rarity) and (can_find_symbol(symbol.type) or ignore_can_find):
            symbols.push_back(symbol.type)
    
    return symbols

func pick_symbol(group := "*", rarity := "*", ignore_rarity := false, ignore_can_find := false):
    var symbol_list := get_symbol_list(group, rarity, ignore_can_find)

    if symbol_list.size() == 0:
        return null
    
    if ignore_rarity:
        return array_pick(symbol_list)
    
    var possible_symbol_counts := { "common": 0, "uncommon": 0, "rare": 0, "very_rare": 0 }
    for symbol in symbol_list:
        if modloader.databases.rarity_database["symbols"]["common"].has(symbol):
            possible_symbol_counts["common"] += 1
        elif modloader.databases.rarity_database["symbols"]["uncommon"].has(symbol):
            possible_symbol_counts["uncommon"] += 1
        elif modloader.databases.rarity_database["symbols"]["rare"].has(symbol):
            possible_symbol_counts["rare"] += 1
        elif modloader.databases.rarity_database["symbols"]["very_rare"].has(symbol):
            possible_symbol_counts["very_rare"] += 1
    
    var rarity_chances := modloader.globals.main.rarity_chances.symbols.duplicate(true)
    if possible_symbol_counts.common == 0:
        rarity_chances.common = 0
        rarity_chances.uncommon = 1
        if possible_symbol_counts.uncommon == 0:
            rarity_chances.uncommon = 0
            rarity_chances.rare = 1
            if possible_symbol_counts.rare == 0:
                rarity_chances.rare = 0
                rarity_chances.very_rare = 1
    
    rarity_chances.uncommon *= modloader.globals.pop_up.rarity_bonuses.symbols.uncommon
    if possible_symbol_counts.uncommon == 0:
        rarity_chances.uncommon = 0

    rarity_chances.rare *= modloader.globals.pop_up.rarity_bonuses.symbols.rare
    if possible_symbol_counts.rare == 0:
        rarity_chances.rare = 0

    rarity_chances.very_rare *= modloader.globals.pop_up.rarity_bonuses.symbols.very_rare
    if possible_symbol_counts.very_rare == 0:
        rarity_chances.very_rare = 0

    var picked_rarity := ""
    var rarity_picker := random(0, 1)
    if rarity_picker < rarity_chances.very_rare:
        picked_rarity = "very_rare"
    else:
        rarity_picker -= rarity_chances.very_rare
    
    if rarity_picker < rarity_chances.rare and picked_rarity == "":
        picked_rarity = "rare"
    else:
        rarity_picker -= rarity_chances.rare
    
    if rarity_picker < rarity_chances.uncommon and picked_rarity == "":
        picked_rarity = "uncommon"
    
    if picked_rarity == "":
        picked_rarity = "common"

    var possible_symbols := []
    for symbol in symbol_list:
        if modloader.databases.rarity_database.symbols[picked_rarity].has(symbol):
            possible_symbols.push_back(symbol)
    
    return array_pick(possible_symbols)

func list_symbols(source, filters := {}):
    var symbols := source

    if symbols == "inventory":
        symbols = []
        for r in modloader.globals.reels.reels:
            for i in r.icons:
                symbols.push_back(i)
    elif symbols == "reels":
        symbols = []
        for r in modloader.globals.reels.displayed_icons:
            for i in r:
                symbols.push_back(i)
    
    _assert(symbols is Array, "list_symbols source is not a valid string or symbol array!")

    var new_symbols := []
    for symbol in symbols:
        if check_symbol_condition(symbol.type, filters):
            new_symbols.push_back(symbol)

    return new_symbols

func count_symbols(source, filters := {}):
    return list_symbols(source, filters).size()

func get_mod_symbols(mod_id: String):
    return modloader.mod_content[mod_id].symbols

func get_mod_symbol_patches(mod_id: String):
    return modloader.mod_content[mod_id].symbol_patches

func add_symbol(type):
    modloader.globals.reels.symbol_queue.push_back(type)

func add_item(type):
    modloader.globals.items.add_item(type)

func mod_installed(mod_id: String):
    return modloader.mods.has(mod_id)



func load_texture(path: String) -> Texture:
    var image := Image.new()
    var err := image.load(path)
    _assert(err == OK, "Texture " + path + " failed to load!")
    var texture := ImageTexture.new()
    texture.create_from_image(image, 0)

    return texture

func load_wav(path):
    var file = File.new()
    file.open(path, File.READ)
    var buffer = file.get_buffer(file.get_len())
    file.close()
    
    var stream = AudioStreamSample.new()
    stream.format = AudioStreamSample.FORMAT_16_BITS
    stream.data = buffer
    stream.mix_rate = 44100
    stream.stereo = true
    
    return stream

func load_pck(path: String, name := "content"):
    _assert(ProjectSettings.load_resource_pack(path, true), "Failed to load " + name + "!")

func load_zip(path: String, load_folder: String, name := "content"):
    var gdunzip := load("res://modloader/lib/gdunzip.gd").new()
    
    var folder := "user://_luckyapi_patched/unzipped".plus_file(name)
    _assert(gdunzip.load(path), "Failed to unzip " + name + "!")
    ensure_dir_exists("user://_luckyapi_patched/unzipped")
    ensure_dir_exists(folder)

    for file in gdunzip.files:
        var trimmed := file.trim_prefix(load_folder.plus_file(""))
        var uncompressed := gdunzip.uncompress(file)

        if not uncompressed:
            continue
        
        ensure_dir_exists(folder.plus_file(trimmed.get_base_dir()))
        write_buffer(folder.plus_file(trimmed), uncompressed)
    
    load_folder(folder, load_folder, name)

func load_folder(path: String, folder: String, name := "content"):
    var pck_file := "user://_luckyapi_patched".plus_file(name + ".pck")

    var packer := PCKPacker.new()
    _assert(packer.pck_start(pck_file) == OK, "Opening " + name + " for writing failed!")
    recursive_pack(packer, path, "res://".plus_file(folder))
    _assert(packer.flush(true) == OK, "Failed to write to " + name + "!")
    _assert(ProjectSettings.load_resource_pack(pck_file, true), "Failed to load " + name + "!")

func recursive_pack(packer: PCKPacker, path: String, packer_path: String):
    var dir := Directory.new()
    if dir.open(path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name != "." and file_name != "..":
                if dir.current_is_dir():
                    recursive_pack(packer, path.plus_file(file_name), packer_path.plus_file(file_name))
                else:
                    packer.add_file(packer_path.plus_file(file_name), path.plus_file(file_name))
            file_name = dir.get_next()

func recursive_folder_delete(path: String):
    var dir = Directory.new()
    if dir.open(path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name != "." and file_name != "..":
                if dir.current_is_dir():
                    recursive_folder_delete(path.plus_file(file_name))
                else:
                    dir.remove(file_name)
            file_name = dir.get_next()
    dir.remove("")

func ensure_dir_exists(dir_path: String):
    var dir := Directory.new()
    if !dir.dir_exists(dir_path):
        _assert(dir.make_dir(dir_path) == OK, "Failed to create directory " + dir_path + "!")

func read_text(file_path: String) -> String:
    var data_file := File.new()
    _assert(data_file.open(file_path, File.READ) == OK, "Failed to open " + file_path + " for reading!")
    var text := data_file.get_as_text()
    data_file.close()
    return text

func write_text(file_path: String, text: String):
    var data_file := File.new()
    _assert(data_file.open(file_path, File.WRITE_READ) == OK, "Failed to open " + file_path + " for writing!")
    data_file.store_string(text)
    data_file.close()

func write_buffer(file_path: String, buffer: PoolByteArray):
    var data_file := File.new()
    _assert(data_file.open(file_path, File.WRITE_READ) == OK, "Failed to open " + file_path + " for writing!")
    data_file.store_buffer(buffer)
    data_file.close()

func read_json(file_path: String):
    var parse_result := JSON.parse(read_text(file_path))
    _assert(parse_result.error == OK, "Failed to parse " + file_path + " as JSON!")
    return parse_result.result

func write_json(file_path: String, data, indent := "\t"):
    var json_text := JSON.print(data, indent)
    write_text(file_path, json_text)



func extract_script(scene: PackedScene, node_name: String) -> GDScript:
    var state: SceneState = scene.get_state()
    
    var node_idx := -1
    var node_count := state.get_node_count()
    for i in node_count:
        if state.get_node_name(i) == node_name:
            node_idx = i
            break
    _assert(node_idx != -1, "Node not found while extracting script from packed scene!")
    
    var extracted_script: GDScript = null
    var property_count := state.get_node_property_count(node_idx)
    for i in property_count:
        if state.get_node_property_name(node_idx, i) == "script":
            extracted_script = state.get_node_property_value(node_idx, i)
            break
    _assert(extracted_script is GDScript, "Extracted script is not GDScript!")
    _assert(extracted_script.has_source_code(), "Extracted script does not have source code!")
    
    return extracted_script

var target_index := 0
func patch_gd(target_path: String, new_script_path: String, packer: PCKPacker, force_reload: Array):
    var script := ResourceLoader.load(target_path, "", true)
    _assert(script is GDScript, "Script to be patched isn't a GDScript!")
    var old_script := script.duplicate()

    var extend := save_and_pack_resource(packer, old_script, target_path.trim_suffix(".gd") + str(target_index) + ".gd")
    target_index += 1

    script.source_code = read_text(new_script_path)
    script.source_code = "extends \"" + extend + "\"\n" + script.source_code
    save_and_pack_resource(packer, script, target_path)
    target_index += 1

    force_reload.push_back(target_path)
    force_reload.push_back(extend)

func patch_tscn(target_path: String, new_script_path: Array, node_name: Array, packer: PCKPacker, force_reload: Array, set_extends := false):
    var scene := load(target_path)
    for i in range(new_script_path.size()):
        replace_script_and_pack_original(packer, scene, node_name[i], new_script_path[i], set_extends)
    
    save_and_pack_resource(packer, scene, target_path)

    force_reload.push_back(target_path)

func replace_script_and_pack_original(packer: PCKPacker, scene: PackedScene, node_name: String, new_script_path: String, set_extends: bool):
    var script := extract_script(scene, node_name)
    var old_script := script.duplicate()
    script.source_code = read_text(new_script_path)
    var target_path := scene.resource_path.get_basename() + "_" + node_name + ".gd"
    if set_extends:
        target_path = scene.resource_path.get_basename() + "_" + node_name + str(target_index) + ".gd"
        target_index += 1

    var extend := save_and_pack_resource(packer, old_script, target_path)
    if set_extends:
        script.source_code = "extends \"" + extend + "\"\n" + script.source_code

func save_and_pack_resource(packer: PCKPacker, res: Resource, target_path: String):
    var save_path := "user://_luckyapi_patched/" + target_path.trim_prefix("res://").replace("/", "_").replace("\\", "_")
    
    _assert(ResourceSaver.save(save_path, res) == OK, "Failed to save resource to " + save_path + "!")
    _assert(packer.add_file(target_path, save_path) == OK, "Failed to pack resource to " + target_path + "!")

    return target_path

func force_reload(resource_path: String):
    var new := ResourceLoader.load(resource_path, "", true)
    new.take_over_path(resource_path)



func load_info(path: String, expected_id: String):
    var json := read_json(path)
    var mod_info := ModInfo.new()
    _assert(json.id == expected_id, "JSON-defined ID for mod " + expected_id + " is not the same as the mod folder name (" + expected_id + ")!")
    mod_info.id = json.id

    if json.has("version"):
        mod_info.version = "v" + json.version
    
    if json.has("authors"):
        mod_info.authors = json.authors
    elif json.has("author"):
        mod_info.authors = [json.author]
    
    if json.has("name"):
        mod_info.name = json.name
    else:
        mod_info.name = mod_info.id
    
    if json.has("description"):
        mod_info.description = json.description
    
    if json.has("dependencies"):
        mod_info.dependencies = json.dependencies
    
    if json.has("load-after"):
        mod_info.load_after = json["load-after"]
    
    if json.has("main"):
        mod_info.main_script = json.main
    
    if json.has("patches"):
        var patches := json.patches
        for patch_file in patches.keys():
            var patch_info := PatchInfo.new()
            patch_info.to_patch = patch_file
            if patch_file.ends_with(".tscn"):
                patch_info.type = "tscn"
                var scripts := patches[patch_file].scripts
                for name in scripts.keys():
                    patch_info.scripts[name] = scripts[name]
            else:
                patch_info.type = "gd"
                patch_info.scripts["main"] = patches[patch_file].script
            
            mod_info.patches.push_back(patch_info)
    
    return mod_info

class ModInfo:
    var id := ""
    var version := ""
    var authors := []
    var name := ""
    var description := ""
    var main_script := "mod.gd"
    var dependencies := []
    var load_after := []
    var patches := []

class PatchInfo:
    var type := ""
    var to_patch := ""
    var scripts := {}



# Effect Builder API
func effect(dict: Dictionary = {}):
	return SymbolEffect.new(dict)

class SymbolEffect:
    var effect_dictionary = {"comparisons": [], "tiles_to_add": [], "items_to_add": [], "sub_effects": []}
    
    func _init(dict : Dictionary = {}):
        effect_dictionary = dict if dict.keys().size() > 0 else effect_dictionary
    
    func if_value_random(value_index: int):
        effect_dictionary.comparisons.push_back({"a": "values", "value_num": value_index, "rand": true})
        return self
    
    func if_value_at_least(value_index: int, compare: int):
        effect_dictionary.comparisons.push_back({"a": "values", "value_num": value_index, "b": compare, "greater_than_eq": true})
        return self
    
    func if_value_equals(value_index: int, compare: int):
        effect_dictionary.comparisons.push_back({"a": "values", "value_num": value_index, "b": compare})
        return self
    
    func if_final_value_less_than(compare: int):
        effect_dictionary.comparisons.push_back({"a": "final_value", "b": compare, "less_than": true})
        return self

    func if_final_value_equals(compare: int):
        effect_dictionary.comparisons.push_back({"a": "final_value", "b": compare})
        return self
    
    func if_value_bonus_less_than(compare: int, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_bonus", "currency": currency, "b": compare, "less_than": true})
        return self

    func if_value_bonus_at_least(compare: int, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_bonus", "currency": currency, "b": compare, "greater_than_eq": true})
        return self
    
    func if_value_bonus_equals(compare: int, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_bonus", "currency": currency, "b": compare})
        return self

    func if_value_multiplier_less_than(compare: float, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_multiplier", "currency": currency, "b": compare, "less_than": true})
        return self

    func if_value_multiplier_at_least(compare: float, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_multiplier", "currency": currency, "b": compare, "greater_than_eq": true})
        return self
    
    func if_value_multiplier_equals(compare: float, currency := "coin"):
        effect_dictionary.comparisons.push_back({"a": "value_multiplier", "currency": currency, "b": compare})
        return self
    
    func if_type(type: String, not_prev := false):
        if not_prev:
            effect_dictionary.comparisons.push_back({"a": "type", "b": type, "not_prev": true})
        else:
            effect_dictionary.comparisons.push_back({"a": "type", "b": type})
        
        return self
    
    func if_group(group: String, not_prev := false):
        if not_prev:
            effect_dictionary.comparisons.push_back({"a": "groups", "b": group, "not_prev": true})
        else:
            effect_dictionary.comparisons.push_back({"a": "groups", "b": group})
        
        return self

    func if_destroyed(compare := true, not_prev := false):
        if not_prev:
            effect_dictionary.comparisons.push_back({"a": "destroyed", "b": compare, "not_prev": true})
        else:
            effect_dictionary.comparisons.push_back({"a": "destroyed", "b": compare})
        
        return self

    func if_tbd(compare := true, not_prev := false):
        if not_prev:
          effect_dictionary.comparisons.push_back({"a": "tbd", "b": compare, "not_prev": true})
        else:
          effect_dictionary.comparisons.push_back({"a": "tbd", "b": compare})
        
        return self

    func if_pointing_directions(compare):
        effect_dictionary.comparisons.push_back({"a": "pointing_directions", "b": compare})
        return self

    func if_grid_x(compare):
        effect_dictionary.comparisons.push_back({"a": "grid_position_x", "b": compare})
        return self

    func if_grid_y(compare):
        effect_dictionary.comparisons.push_back({"a": "grid_position_y", "b": compare})
        return self
    
    func if_has(property: String, value):
        effect_dictionary.comparisons.push_back({"a": property, "b": value})
        return self

    func if_not_has(property: String, value):
        effect_dictionary.comparisons.push_back({"a": property, "b": value, "not_have": true})
        return self

    func if_property_random(property: String):
        effect_dictionary.comparisons.push_back({"rand": true, "a": property})
        return self

    func if_property_less_than(property: String, compare: int):
        effect_dictionary.comparisons.push_back({"less_than": true, "a": property, "b": compare})
        return self

    func if_property_at_least(property: String, compare: int):
        effect_dictionary.comparisons.push_back({"greater_than_eq": true, "a": property, "b": compare})
        return self
    
    func if_property_equals(property: String, compare):
        effect_dictionary.comparisons.push_back({"a": property, "b": compare})
        return self
    
    func if_persistent_data_random(key: String, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_persistent": true, "lapi_default": default, "lapi_type": "rand",
            "a": "value", "b": 0
        })

        return self
    
    func if_persistent_data_less_than(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": true, "lapi_default": default, "lapi_type": "less_than",
            "a": "value", "b": 0
        })

        return self

    func if_persistent_data_at_least(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": true, "lapi_default": default, "lapi_type": "greater_than_eq",
            "a": "value", "b": 0
        })

        return self

    func if_persistent_data_equals(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": true, "lapi_default": default, "lapi_type": "equals",
            "a": "value", "b": 0
        })

        return self

    func if_non_persistent_data_random(key: String, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_persistent": false, "lapi_default": default, "lapi_type": "rand",
            "a": "value", "b": 0
        })

        return self
    
    func if_non_persistent_data_less_than(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": false, "lapi_default": default, "lapi_type": "less_than",
            "a": "value", "b": 0
        })

        return self

    func if_non_persistent_data_at_least(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": false, "lapi_default": default, "lapi_type": "greater_than_eq",
            "a": "value", "b": 0
        })

        return self

    func if_non_persistent_data_equals(key: String, value: float, default := 0):
        effect_dictionary.comparisons.push_back({
            "lapi_data": true, "lapi_key": key, "lapi_value": value, "lapi_persistent": false, "lapi_default": default, "lapi_type": "equals",
            "a": "value", "b": 0
        })

        return self
    
    func negate():
        effect_dictionary.comparisons[effect_dictionary.comparisons.size() - 1].negate = true
        return self
    
    
    func unconditional():
        effect_dictionary.unconditional = true
        return self
    
    func priority():
        effect_dictionary.push_front = true
        return self
    
    func add_symbol_type(type: String):
        effect_dictionary.tiles_to_add.push_back({"type": type})
        return self

    func add_symbol_group(group: String, min_rarity := ""):
        if min_rarity != "":
            effect_dictionary.tiles_to_add.push_back({"group": group, "min_rarity": min_rarity})
        else:
            effect_dictionary.tiles_to_add.push_back({"group": group})
        return self
    
    func add_symbols_of_type(arr: Array):
        for symbol in arr:
            add_symbol_type(symbol)
        return self
    
    func add_symbols_of_group(arr: Array, min_rarity := ""):
        for group in arr:
            add_symbol_group(group, min_rarity)
        return self
    
    func add_item_type(type: String):
        effect_dictionary.items_to_add.push_back({"type": type})
        return self

    func add_item_rarity(rarity: String):
        effect_dictionary.items_to_add.push_back({"rarity": rarity})
        return self
    
    func change_bonus_values(diff: int):
        effect_dictionary.value_to_change = "bonus_values"
        effect_dictionary.diff = diff
        return self

    func change_bonus_value_multipliers(diff: int):
        effect_dictionary.value_to_change = "bonus_value_multipliers"
        effect_dictionary.diff = diff
        return self

    func change_value_bonus(diff: int, currency := "coin", overwrite := false, giver := null):
        effect_dictionary.value_to_change = "value_bonus"
        effect_dictionary.diff = diff
        effect_dictionary.currency = currency
        if overwrite:
            effect_dictionary.overwrite = true
        if giver != null:
            effect_dictionary.giver = giver
        
        return self

    func change_value_multiplier(diff: int, currency := "coin", overwrite := false, giver := null):
        effect_dictionary.value_to_change = "value_multiplier"
        effect_dictionary.diff = diff
        effect_dictionary.currency = currency
        if overwrite:
            effect_dictionary.overwrite = true
        if giver != null:
            effect_dictionary.giver = giver
        
        return self

    func change_flat_value_bonus(diff: int):
        effect_dictionary.value_to_change = "flat_value_bonus"
        effect_dictionary.diff = diff
        return self

    func multiply_value(property: String, diff: int):
        effect_dictionary.value_to_change = property
        effect_dictionary.diff = diff
        effect_dictionary.multiply = true
        return self
    
    func change_type(type: String):
        effect_dictionary.value_to_change = "type"
        effect_dictionary.diff = type
        effect_dictionary.push_front = true
        return self
    
    func change_group(group: String, min_rarity := "common"):
        effect_dictionary.value_to_change = "type"
        effect_dictionary.group = group
        effect_dictionary.min_rarity = min_rarity
        return self

    func add_to_array(property: String, diff):
        effect_dictionary.add_to_array = true
        effect_dictionary.value_to_change = property
        effect_dictionary.diff = diff
        return self
    
    func set_destroyed(destroyed := true, overwrite_prev_data := false):
        effect_dictionary.value_to_change = "destroyed"
        effect_dictionary.diff = destroyed
        return self

    func set_drained(drained := true):
        effect_dictionary.value_to_change = "drained"
        effect_dictionary.diff = drained
        return self
    
    func set_pointing_directions(directions: Array):
        effect_dictionary.value_to_change = "pointing_directions"
        effect_dictionary.diff = directions
        return self
    
    func set_removed():
        effect_dictionary.value_to_change = "removed"
        effect_dictionary.diff = true
        return self
    
    func set_value(property: String, diff: int):
        effect_dictionary.value_to_change = property
        effect_dictionary.diff = diff
        effect_dictionary.overwrite = true
        return self

    func add_to_value(property: String, diff: int):
        effect_dictionary.value_to_change = property
        effect_dictionary.diff = diff
        return self
    
    func add_permanent_bonus(diff: int):
        return self.add_to_value("permanent_bonus", diff)
    
    func multiply_permanent_multiplier(diff: int):
        return self.multiply_value("permanent_multiplier", diff)
    
    func dynamic_symbol_value(symbol, value, final := false):
        effect_dictionary.dynamic_diff_target = symbol
        effect_dictionary.dynamic_diff_multiplier = value
        if final:
            effect_dictionary.dynamic_diff_key = "non_prev_final_value"
        else:
            effect_dictionary.dynamic_diff_key = "value"
        return self
    
    func animate(animation: String, sfx_type := 0, targets := []):
        effect_dictionary.anim = animation
        if sfx_type:
            effect_dictionary.sfx_type = sfx_type
        if targets.size() > 0:
            effect_dictionary.anim_targets = targets
        return self
    
    func set_target(target):
        effect_dictionary.target = target
        return self
    
    func set_giver(giver):
        effect_dictionary.giver = giver
        return self
    
    func set_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = true
        effect_dictionary.lapi_operation = "set"
        return self

    func add_to_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = true
        effect_dictionary.lapi_operation = "add"
        return self

    func multiply_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = false
        effect_dictionary.lapi_operation = "mult"
        return self

    func set_non_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = false
        effect_dictionary.lapi_operation = "set"
        return self

    func add_to_non_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = false
        effect_dictionary.lapi_operation = "add"
        return self

    func multiply_non_persistent_data(key: String, value):
        effect_dictionary.lapi_data = true
        effect_dictionary.lapi_key = key
        effect_dictionary.lapi_value = value
        effect_dictionary.lapi_persistent = false
        effect_dictionary.lapi_operation = "mult"
        return self
    
    func sub(sub_effect: SymbolEffect):
        effect_dictionary.sub_effects.push_back(sub_effect)
        return self



func dynamic_group(symbol_overrides = []):
    var group := DynamicGroup.new()

    if symbol_overrides is Array:
        for symbol in symbol_overrides:
            group.symbol_overrides[symbol] = true
    elif symbol_overrides is Dictionary:
        for symbol in symbol_overrides.keys():
            group.symbol_overrides[symbol] = symbol_overrides[symbol]
    
    return group

func create_dynamic_group(name, symbol_overrides = []):
    var group := dynamic_group(symbol_overrides)
    modloader.add_dynamic_group(name, group)

    return group

class DynamicGroup:
    var name := ""
    var cache := {}
    var conditions := []
    var symbol_overrides := {}
    var modloader := null

    func add_symbols(condition):
        conditions.push_back({
            "type": "add",
            "condition": condition
        })

        if modloader != null:
            modloader.update_dynamic_group(name)
        
        return self
    
    func remove_symbols(condition):
        conditions.push_back({
            "type": "remove",
            "condition": condition
        })

        if modloader != null:
            modloader.update_dynamic_group(name)
        
        return self
    
    func check_symbol(symbol):
        var included := false

        if symbol_overrides[symbol] != null:
            cache[symbol] = symbol_overrides[symbol]
            return symbol_overrides[symbol]

        for condition in conditions:
            if modloader.check_symbol_condition(symbol, condition.condition):
                if condition.type == "add":
                    included = true
                else:
                    included = false
        
        cache[symbol] = included
        return included
    
    func add_group(group):
        return self.add_symbols({
            "group": group
        })
    
    func remove_group(group):
        return self.remove_symbols({
            "group": group
        })