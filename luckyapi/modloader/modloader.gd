extends Reference

var tree: SceneTree
const Utils = preload("res://modloader/utils.gd")
const ModSymbol = preload("res://modloader/ModSymbol.gd")

const modloader_version := "v0.1.0"
const expected_version := "v0.6.3"
var game_version: String = "<game version not determined yet>"

var exe_dir := OS.get_executable_path().get_base_dir()

var mods := {}
var mod_count := 0
var databases := {}
var globals := {}
var mod_symbols := {}
var symbol_patches := {}
var translations := {}
var current_mod_name := ""

func _init(tree: SceneTree):
    self.tree = tree

func add_mod_symbol(path: String, params := {}):
    var mod_symbol := load(path).new()
    mod_symbol.init(self, params)
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
    
    if symbol_patches.has(id):
        for symbol_patch in symbol_patches[id]:
            patch_symbol(symbol_patch, id)
    
    print("LuckyAPI MODLOADER > Mod Symbol added: " + id)
    return mod_symbol

func add_symbol_patch(path: String, params := {}):
    var symbol_patch := load(path).new()
    symbol_patch.init(self, params)
    var id := symbol_patch.id
    if not symbol_patches.has(id):
        symbol_patches[id] = []
    symbol_patches[id].push_back(symbol_patch)

    if databases.tile_database.has(id):
        patch_symbol(symbol_patch, id)
    
    print("LuckyAPI MODLOADER > Symbol patched: " + id)
    return symbol_patch

func patch_symbol(symbol_patch, id):
    var mod_symbol := mod_symbols[id]
    var database_entry := databases.tile_database[id]

    var value := symbol_patch.patch_value(database_entry.value)
    database_entry.value = value
    if mod_symbol != null:
        mod_symbol.value = value
    
    var values := symbol_patch.patch_values(database_entry.values)
    database_entry.values = values
    if mod_symbol != null:
        mod_symbol.values = values

    var rarity := symbol_patch.patch_rarity(database_entry.rarity)
    database_entry.rarity = rarity
    if mod_symbol != null:
        mod_symbol.rarity = rarity
    
    var groups := symbol_patch.patch_groups(database_entry.groups)
    database_entry.groups = groups
    if mod_symbol != null:
        mod_symbol.groups = groups

    var texture := symbol_patch.patch_texture(databases.icon_texture_database[id])
    databases.icon_texture_database[id] = texture
    if mod_symbol != null:
        mod_symbol.texture = texture

    if mod_symbol != null:
        var extra_textures := symbol_patch.patch_extra_textures(mod_symbol.extra_textures)
        mod_symbol.extra_textures = extra_textures
        for extra_texture_key in extra_textures.keys():
            databases.icon_texture_database[id + "_" + extra_texture_key] = extra_textures[extra_texture_key]
    
        var sfx := symbol_patch.patch_sfx(mod_symbol.sfx)
        mod_symbol.sfx = sfx
        databases.sfx_database.symbols[id] = sfx
    
        var sfx_redirects := symbol_patch.patch_sfx_redirects(mod_symbol.sfx_redirects)
        mod_symbol.sfx_redirects = sfx_redirects
    
    if mod_symbol != null:
        var name := symbol_patch.patch_name(mod_symbol.name)
        mod_symbol.name = name
        if name is String:
            add_translation(id, name)
        elif name is Dictionary:
            for locale in name.keys():
                add_translation(id, name[locale], locale)
    else:
        var name := symbol_patch.patch_name(TranslationServer.translate(id))
        add_translation(id, name, TranslationServer.get_locale())

    if mod_symbol != null:
        var description := symbol_patch.patch_description(mod_symbol.description)
        mod_symbol.description = description
        if description is String:
            add_translation(id + "_desc", description)
        elif description is Dictionary:
            for locale in description.keys():
                add_translation(id + "_desc", description[locale], locale)
    else:
        var description := symbol_patch.patch_description(TranslationServer.translate(id + "_desc"))
        add_translation(id + "_desc", description, TranslationServer.get_locale())

func add_translation(key: String, value: String, locale := "en"):
    var translation := translations[locale]
    if translation == null:
        translation = Translation.new()
        translation.locale = locale
        TranslationServer.add_translation(translation)
        translations[locale] = translation
    
    translation.add_message(key, value)


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
    Utils.ensure_dir_exists("user://_luckyapi_patched")

    var main_script := extract_script(load("res://Main.tscn"), "Main").source_code
    var regex := RegEx.new()
    regex.compile("\\s*var\\s*content_patch_num\\s*=\\s*(\\d*)\\n\\s*var\\s*hotfix_num\\s*=\\s*(\\d*)")
    var matched_version := regex.search(main_script)
    _assert(matched_version != null, "Version check failed: Unable to determine game version. This modloader is for game version " + expected_version + "!")

    game_version = "v0." + str(matched_version.get_string(1)) + "." + str(matched_version.get_string(2))
    print("LuckyAPI MODLOADER > Game version " + game_version)
    _assert(expected_version == game_version, "Version mismatch: This modloader is for version '" + expected_version + "' but the game is running version '" + game_version + "'!")

    patch_preload()

func patch_preload():
    print("LuckyAPI MODLOADER > Beginning patching process...")

    var packer := PCKPacker.new()
    _assert(packer.pck_start("user://_luckyapi_patched/preload.pck") == OK, "Opening preload.pck for writing failed!")
    patch("res://Main.tscn", ["res://modloader/patches/Main.gd", "res://modloader/patches/Title.gd"], ["Main", "Title"], packer)
    patch("res://Slot Icon.tscn", ["res://modloader/patches/SlotIcon.gd"], ["Slot Icon"], packer)

    _assert(packer.flush(true) == OK, "Failed to write to preload.pck")
    
    print("LuckyAPI MODLOADER > Loading patched code...")
    
    _assert(ProjectSettings.load_resource_pack("user://_luckyapi_patched/preload.pck", true), "Failed to load patched code!")
    force_reload("res://Main.tscn")
    force_reload("res://Slot Icon.tscn")
    
    print("LuckyAPI MODLOADER > Patching game code complete!")


func after_start():
    load_mods()

    print("LuckyAPI MODLOADER > Initialization complete!")

func load_mods():
    print("LuckyAPI MODLOADER > Loading mods...")
    var mods_dir := "user://mods/"
    var _dir := Directory.new()
    if _dir.open(mods_dir) == OK:
        _assert(_dir.list_dir_begin(true) == OK, "list_dir_began failed!")
        var found_name := _dir.get_next()
        while found_name != "":
            if _dir.current_is_dir():
                print("LuckyAPI MODLOADER > Mod found: " + found_name)
                load_folder(mods_dir.plus_file(found_name), found_name, "mod_" + found_name)
                var mod_name := found_name.trim_suffix(".zip")
                var mod_script := load("res://" + mod_name + "/mod.gd")
                var mod := mod_script.new()

                mods[mod_name] = mod
                mod_count += 1
                print("LuckyAPI MODLOADER > Mod loaded: " + mod_name)
                                
            found_name = _dir.get_next()

    print("LuckyAPI MODLOADER > Running load method on mods...")
    for mod_name in mods.keys():
        var mod := mods[mod_name]
        if mod.has_method("load"):
            current_mod_name = mod_name
            mod.load(self, tree)
    
    recursive_folder_delete("user://_luckyapi_patched")
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

func patch(target_path: String, new_script_path: Array, node_name: Array, packer: PCKPacker):
    var scene := load(target_path)
    for i in range(new_script_path.size()):
        replace_script_and_pack_original(packer, scene, node_name[i], new_script_path[i])
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

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()