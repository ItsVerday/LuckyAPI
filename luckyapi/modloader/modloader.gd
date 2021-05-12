extends Reference

var tree: SceneTree
const Utils = preload("res://modloader/utils.gd")
const ModSymbol = preload("res://modloader/ModSymbol.gd")

const modloader_version := "v0.1.0"
const expected_version := "Content Patch #6 -- Hotfix #2"
var game_version: String = "<game version not determined yet>"

var exe_dir := OS.get_executable_path().get_base_dir()

var databases := {}
var globals := {}
var mod_symbols := {}
var mods := {}
var current_mod_name := ""

func _init(tree: SceneTree):
    self.tree = tree

func add_mod_symbol(path: String):
    var mod_symbol := load(path).new()
    mod_symbol.init(self)
    var id := mod_symbol.id
    mod_symbols[id] = mod_symbol
    mod_symbol.mod_name = current_mod_name

    databases.icon_texture_database[id] = mod_symbol.texture
    for extra_texture_key in mod_symbol.extra_textures.keys():
        databases.icon_texture_database[id + "_" + extra_texture_key] = mod_symbol.extra_textures[extra_texture_key]
    
    databases.tile_database[id] = {
        "type": id,
        "value": mod_symbol.value,
        "values": mod_symbol.values,
        "groups": mod_symbol.groups,
        "rarity": mod_symbol.rarity
    }

    databases.sfx_database.symbols[id] = mod_symbol.sfx
    databases.rarity_database.symbols[mod_symbol.rarity].push_back(id)

    for group in mod_symbol.groups:
        if not databases.group_database.symbols.has(group):
            databases.group_database.symbols[group] = []
        
        databases.group_database.symbols[group].push_back(id)
    
    if mod_symbol.name is String:
        add_translation(id, mod_symbol.name)
    elif mod_symbol.name is Dictionary:
        for locale in mod_symbol.name.keys():
            add_translation(id, mod_symbol.name[locale], locale)
    
    if mod_symbol.description is String:
        add_translation(id + "_desc", mod_symbol.description)
    elif mod_symbol.description is Dictionary:
        for locale in mod_symbol.description.keys():
            add_translation(id + "_desc", mod_symbol.description[locale], locale)
    
    print("LuckyAPI MODLOADER > Mod Symbol added: " + id)

func add_translation(key: String, value: String, locale := "en"):
    var translation := Translation.new()
    translation.locale = locale
    translation.add_message(key, value)
    TranslationServer.add_translation(translation)


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
    var symbols := []
    for symbol in databases.tile_database:
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
        if $"/root/Main".rarity_database["symbols"]["common"].has(symbol):
            possible_symbol_counts["common"] += 1
        elif $"/root/Main".rarity_database["symbols"]["uncommon"].has(symbol):
            possible_symbol_counts["uncommon"] += 1
        elif $"/root/Main".rarity_database["symbols"]["rare"].has(symbol):
            possible_symbol_counts["rare"] += 1
        elif $"/root/Main".rarity_database["symbols"]["very_rare"].has(symbol):
            possible_symbol_counts["very_rare"] += 1

    var rarity_chances := $"/root/Main/".rarity_chances["symbols"].duplicate(true)
    rarity_chances.uncommon *= globals.pop_up.rarity_bonuses.symbols.uncommon
    if (possible_symbol_counts.uncommon == 0):
        rarity_chances.uncommon = 0

    rarity_chances.rare *= globals.pop_up.rarity_bonuses.symbols.rare
    if (possible_symbol_counts.rare == 0):
        rarity_chances.rare = 0

    rarity_chances.very_rare *= globals.pop_up.rarity_bonuses.symbols.very_rare
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
        if databases.rarity_database.symbols[picked_rarity].has(symbol):
            possible_symbols.push_back(symbol)
    
    randomize()
    return possible_symbols[floor(rand_range(0, possible_symbols.size()))]


func before_start():
    print("LuckyAPI MODLOADER > Initializing LuckyAPI " + modloader_version + "...")
    _assert(ProjectSettings.load_resource_pack(exe_dir.plus_file("luckyapi/modloader.zip"), true), "Failed to load LuckyAPI internals!")

    Utils.ensure_dir_exists("user://_luckyapi_patched")

    var main_script := extract_script(load("res://Main.tscn"), "Main").source_code
    var regex := RegEx.new()
    regex.compile("\\sversion_str\\s*=\\s*\"(.*?)\"")
    var matched_version := regex.search(main_script)
    _assert(matched_version != null, "Version check failed: Unable to determine game version. This modloader is for game version " + expected_version + "!")

    game_version = matched_version.strings[1]
    print("LuckyAPI MODLOADER > Game version " + game_version)
    _assert(expected_version == game_version, "Version mismatch: This modloader is for version '" + expected_version + "' but the game is running version '" + game_version + "'!")

    patch_preload()

func patch_preload():
    print("LuckyAPI MODLOADER > Beginning patching process...")

    var packer := PCKPacker.new()
    _assert(packer.pck_start("user://_luckyapi_patched/preload.pck") == OK, "Opening preload.pck for writing failed!")
    patch("res://Main.tscn", "res://modloader/patches/Main.gd", "Main", packer)
    patch("res://Slot Icon.tscn", "res://modloader/patches/SlotIcon.gd", "Slot Icon", packer)

    _assert(packer.flush(true) == OK, "Failed to write to preload.pck")
    
    print("LuckyAPI MODLOADER > Loading patched code...")
    
    _assert(ProjectSettings.load_resource_pack("user://_luckyapi_patched/preload.pck", true), "Failed to load patched code!")
    force_reload("res://Main.tscn")
    force_reload("res://Slot Icon.tscn")
    
    print("LuckyAPI MODLOADER > Patching game code complete!")


func after_start():
    load_mods()

    print("LuckyAPI MODLOADER > Adding UI overlay...")
    
    var overlay := load("res://modloader/MainMenuOverlay.tscn").instance()
    tree.root.get_node(overlay.expected_parent_node_path).add_child(overlay)
    overlay.set_version("LuckyAPI " + modloader_version)
    overlay.set_counts(mods.values().size())

    print("LuckyAPI MODLOADER > Initialization complete!")

func load_mods():
    print("LuckyAPI MODLOADER > Loading mods...")
    var mods_dir := "user://mods/"
    var _dir := Directory.new()
    if _dir.open(mods_dir) == OK:
        _assert(_dir.list_dir_begin(true) == OK, "list_dir_began failed!")
        var found_name := _dir.get_next()
        while found_name != "":
            if !_dir.current_is_dir():
                print("LuckyAPI MODLOADER > Mod found: " + found_name)
                _assert(ProjectSettings.load_resource_pack(mods_dir.plus_file(found_name), true), "Failed to load mod " + found_name)
                var mod_name := found_name.trim_suffix(".zip")
                var mod_script := load("res://" + mod_name + "/mod.gd")
                var mod := mod_script.new()

                mods[mod_name] = mod
                print("LuckyAPI MODLOADER > Mod loaded: " + mod_name)
                                
            found_name = _dir.get_next()

    print("LuckyAPI MODLOADER > Running load method on mods...")
    for mod_name in mods.keys():
        var mod := mods[mod_name]
        if mod.has_method("load"):
            current_mod_name = mod_name
            mod.load(self, tree)
    
    print("LuckyAPI MODLOADER > Loading mods complete!")


static func extract_script(scene: PackedScene, node_name: String) -> GDScript:
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

func patch(target_path: String, new_script_path: String, node_name: String, packer: PCKPacker):
    var scene := load(target_path)
    replace_script_and_pack_original(packer, scene, node_name, new_script_path)
    save_and_pack_resource(packer, scene, target_path)

func replace_script_and_pack_original(packer: PCKPacker, scene: PackedScene, node_name: String, new_script_path: String):
    var script := extract_script(scene, node_name)
    var old_script := script.duplicate()
    script.source_code = Utils.read_text(new_script_path)
    save_and_pack_resource(packer, old_script, scene.resource_path.get_basename() + "_" + node_name + ".gd")

func save_and_pack_resource(packer: PCKPacker, res: Resource, target_path: String):
    var save_path := "user://_luckyapi_patched/" + target_path.trim_prefix("res://").replace("/", "_").replace("\\", "_")
    _assert(ResourceSaver.save(save_path, res) == OK, "Failed to save resource to " + save_path + "!")
    _assert(packer.add_file(target_path, save_path) == OK, "Failed to pack resource to " + target_path + "!")

func force_reload(resource_path: String):
    var new := ResourceLoader.load(resource_path, "", true)
    new.take_over_path(resource_path)

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()