extends Reference

var _modloader := null

func load_modloader():
    if _modloader == null:
        _modloader = get_tree().modloader

func add_translation(key: String, value: String, locale := "en"):
    load_modloader()
    var translation := _modloader.translations[locale]
    if translation == null:
        translation = Translation.new()
        translation.locale = locale
        TranslationServer.add_translation(translation)
        _modloader.translations[locale] = translation
    
    translation.add_message(key, value)

func translate(key: String):
    load_modloader()
    var locale := TranslationServer.get_locale()
    if _modloader.translations.has(locale):
        var translation := _modloader.translations[locale]
        var messages = translation.get_message_list()
        for check_key in messages:
            if key == check_key:
                return translation.get_message(key)
    
    return TranslationServer.translate(key)

func tr(key):
    return translate(key)

func join(a: String, b: String, delimeter := " ") -> String:
    if a.length() == 0:
        return b
    
    return a + delimeter + b

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

func get_symbol_list(group := "*", rarity := "*"):
    load_modloader()
    var symbols := []
    for symbol in _modloader.databases.tile_database:
        var group_match := false

        for symbol_group in symbol.groups:
            if match_value(symbol_group, group):
                group_match = true
                break
        
        if not group_match:
            continue
        
        if match_value(symbol.rarity, rarity):
            symbols.add(symbol.type)
    
    return symbols

func pick_symbol(group := "*", rarity := "*", ignore_rarity := false):
    var symbol_list := get_symbol_list(group, rarity)

    if symbol_list.size() == 0:
        return null
    
    if ignore_rarity:
        randomize()
        return symbol_list[floor(rand_range(0, symbol_list.size()))]
    
    var possible_symbol_counts := { "common": 0, "uncommon": 0, "rare": 0, "very_rare": 0 }
    for symbol in symbol_list:
        if _modloader.databases.rarity_database["symbols"]["common"].has(symbol):
            possible_symbol_counts["common"] += 1
        elif _modloader.databases.rarity_database["symbols"]["uncommon"].has(symbol):
            possible_symbol_counts["uncommon"] += 1
        elif _modloader.databases.rarity_database["symbols"]["rare"].has(symbol):
            possible_symbol_counts["rare"] += 1
        elif _modloader.databases.rarity_database["symbols"]["very_rare"].has(symbol):
            possible_symbol_counts["very_rare"] += 1

    var rarity_chances := _modloader.databases.rarity_chances.symbols.duplicate(true)
    rarity_chances.uncommon *= _modloader.globals.pop_up.rarity_bonuses.symbols.uncommon
    if (possible_symbol_counts.uncommon == 0):
        rarity_chances.uncommon = 0

    rarity_chances.rare *= _modloader.globals.pop_up.rarity_bonuses.symbols.rare
    if (possible_symbol_counts.rare == 0):
        rarity_chances.rare = 0

    rarity_chances.very_rare *= _modloader.globals.pop_up.rarity_bonuses.symbols.very_rare
    if (possible_symbol_counts.very_rare == 0):
        rarity_chances.very_rare = 0

    var picked_rarity := ""
    randomize()
    var rarity_picker := rand_range(0, 1)
    if rarity_picker < rarity_chances.very_rare:
        picked_rarity = "very_rare"
    else:
        rarity_picker -= rarity_chances.very_rare
    
    if rarity_picker < rarity_chances.rare and rarity == "":
        picked_rarity = "rare"
    else:
        rarity_picker -= rarity_chances.rare
    
    if rarity_picker < rarity_chances.uncommon and rarity == "":
        picked_rarity = "uncommon"
    
    if rarity == "":
        picked_rarity = "common"

    var possible_symbols := []
    for symbol in symbol_list:
        if _modloader.databases.rarity_database.symbols[picked_rarity].has(symbol):
            possible_symbols.push_back(symbol)
    
    randomize()
    return possible_symbols[floor(rand_range(0, possible_symbols.size()))]

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

func add_symbol(type):
    load_modloader()
    _modloader.globals.reels.symbol_queue.push_back(type)

func add_item(type):
    load_modloader()
    _modloader.globals.items.add_item(type)

func patch(target_path: String, new_script_path: Array, node_name: Array, packer: PCKPacker):
    var scene := load(target_path)
    for i in range(new_script_path.size()):
        replace_script_and_pack_original(packer, scene, node_name[i], new_script_path[i])
    save_and_pack_resource(packer, scene, target_path)

func replace_script_and_pack_original(packer: PCKPacker, scene: PackedScene, node_name: String, new_script_path: String):
    var script := extract_script(scene, node_name)
    var old_script := script.duplicate()
    script.source_code = read_text(new_script_path)
    save_and_pack_resource(packer, old_script, scene.resource_path.get_basename() + "_" + node_name + ".gd")

func save_and_pack_resource(packer: PCKPacker, res: Resource, target_path: String):
    var save_path := "user://_luckyapi_patched/" + target_path.trim_prefix("res://").replace("/", "_").replace("\\", "_")
    _assert(ResourceSaver.save(save_path, res) == OK, "Failed to save resource to " + save_path + "!")
    _assert(packer.add_file(target_path, save_path) == OK, "Failed to pack resource to " + target_path + "!")

func force_reload(resource_path: String):
    var new := ResourceLoader.load(resource_path, "", true)
    new.take_over_path(resource_path)

func load_folder(path: String, folder: String, name := "content.pck"):
    var exe_dir := OS.get_executable_path().get_base_dir()
    var pck_file := exe_dir.plus_file("luckyapi").plus_file("content.pck")

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
    _assert(data_file.open(file_path, File.READ) == OK, "Failed to open " + file_path + "!")
    var text := data_file.get_as_text()
    data_file.close()
    return text

func read_json(file_path: String):
    var parse_result := JSON.parse(read_text(file_path))
    _assert(parse_result.error == OK, "Failed to parse " + file_path + " as JSON!")
    return parse_result.result

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()