extends "res://modloader/utils.gd"

var tree: SceneTree
const ModSymbol = preload("res://modloader/ModSymbol.gd")
const SymbolPatcher = preload("res://modloader/SymbolPatcher.gd")

const modloader_version := "v0.2.0"
const expected_versions := ["v0.6.6", "v0.6.7", "v0.6.8", "v0.6.9"]
var game_version: String = "<game version not determined yet>"

var exe_dir := OS.get_executable_path().get_base_dir()

var mods := {}
var mod_info := {}
var mod_load_order := []
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
    var script := load(path)
    var mod_symbol := script.new()
    mod_symbol.init(self, params)
    var id := mod_symbol.id
    mod_symbols[id] = mod_symbol
    mod_symbol.mod_name = current_mod_name
    _assert(script.get_base_script() == "res://modloader/ModSymbol.gd", "Mod symbol " + id + " does not extend ModSymbol.gd!")

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
    if mod_symbol.rarity != null:
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
    var script := load(path)
    var symbol_patch := script.new()
    symbol_patch.init(self, params)
    var id := symbol_patch.id
    if not symbol_patches.has(id):
        symbol_patches[id] = []
    symbol_patches[id].push_back(symbol_patch)
    symbol_patch.mod_name = current_mod_name
    _assert(script.get_base_script() == "res://modloader/SymbolPatcher.gd", "Symbol patcher " + id + " does not extend SymbolPatcher.gd!")

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
        var name := symbol_patch.patch_name()
        mod_symbol.name = name
        if name is String:
            add_translation(id, name)
        elif name is Dictionary:
            for locale in name.keys():
                add_translation(id, name[locale], locale)
    else:
        var name := TranslationServer.translate(id)
        if name == id:
            name = ""
        name = symbol_patch.patch_name(name)
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
        var description := TranslationServer.translate(id + "_desc")
        if description == id + "_desc":
            description = ""
        description = symbol_patch.patch_description(description)
        add_translation(id + "_desc", description, TranslationServer.get_locale())


func before_start():
    print("LuckyAPI MODLOADER > Initializing LuckyAPI " + modloader_version + "...")
    ensure_dir_exists("user://mods")

    var main_script := extract_script(load("res://Main.tscn"), "Main").source_code
    var regex := RegEx.new()
    regex.compile("\\s*var\\s*content_patch_num\\s*=\\s*(\\d*)\\n\\s*var\\s*hotfix_num\\s*=\\s*(\\d*)")
    var matched_version := regex.search(main_script)
    _assert(matched_version != null, "Version check failed: Unable to determine game version. This modloader is for game versions " + str(expected_versions) + "!")

    game_version = "v0." + str(matched_version.get_string(1)) + "." + str(matched_version.get_string(2))
    print("LuckyAPI MODLOADER > Game version " + game_version)
    _assert(expected_versions.find(game_version) > -1, "Version mismatch: This modloader is for version '" + str(expected_versions) + "' but the game is running version '" + game_version + "'!")

    patch_preload()

func patch_preload():
    print("LuckyAPI MODLOADER > Beginning patching process...")

    var packer := PCKPacker.new()
    _assert(packer.pck_start("user://_luckyapi_patched/preload.pck") == OK, "Opening preload.pck for writing failed!")
    patch("res://Main.tscn", ["res://modloader/patches/Main.gd", "res://modloader/patches/Title.gd"], ["Main", "Title"], packer)
    patch("res://Slot Icon.tscn", ["res://modloader/patches/SlotIcon.gd"], ["Slot Icon"], packer)
    patch("res://Tooltip.tscn", ["res://modloader/patches/Tooltip_Card.gd"], ["Card"], packer)
    patch("res://Card.tscn", ["res://modloader/patches/Card.gd"], ["Card"], packer)
    patch("res://Pop-up.tscn", ["res://modloader/patches/Pop-up.gd"], ["Pop-up"], packer)

    _assert(packer.flush(true) == OK, "Failed to write to preload.pck")
    
    print("LuckyAPI MODLOADER > Loading patched code...")
    
    _assert(ProjectSettings.load_resource_pack("user://_luckyapi_patched/preload.pck", true), "Failed to load patched code!")
    force_reload("res://Main.tscn")
    force_reload("res://Slot Icon.tscn")
    force_reload("res://Tooltip.tscn")
    force_reload("res://Card.tscn")
    force_reload("res://Pop-up.tscn")

    print("LuckyAPI MODLOADER > Patching game code complete!")


func after_start():
    load_mods()

    print("LuckyAPI MODLOADER > Initialization complete!")

    datadump()

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
                var mod_script := load("res://" + found_name + "/mod.gd")
                var mod := mod_script.new()
                var info := load_info("res://" + found_name + "/mod.json", found_name)

                mods[found_name] = mod
                mod_info[found_name] = info
                mod_count += 1
                print("LuckyAPI MODLOADER > Mod loaded: " + found_name)
                                
            found_name = _dir.get_next()
    
    for mod_id in mod_info.keys():
        add_mod_to_load_order(mod_id, mod_load_order)
        for dependency in mod_info[mod_id].dependencies:
            _assert(mods.has(dependency), "Mod " + mod_id + " requires a dependency which wasn't found: " + dependency + "!")
    
    print("LuckyAPI MODLOADER > Running load method on mods...")
    for mod_name in mod_load_order:
        var mod := mods[mod_name]
        var info := mod_info[mod_name]
        if mod.has_method("load"):
            current_mod_name = mod_name
            mod.load(self, info, tree)
        print("LuckyAPI MODLOADER > " + info.name + " " + info.version + " by " + get_names_list(info.authors) + " loaded!")
    current_mod_name = ""
    print("LuckyAPI MODLOADER > Loading mods complete!")

func datadump():
    print("LuckyAPI MODLOADER > Creating Data Dump...")

    var datadump := load("res://modloader/datadump.gd").new()
    datadump.init(self)
    datadump.go()

    print("LuckyAPI MODLOADER > Data Dump creation complete!")

func translate(key: String):
    var locale := TranslationServer.get_locale()
    if translations.has(locale):
        var translation := translations[locale]
        var messages = translation.get_message_list()
        for check_key in messages:
            if key == check_key:
                return translation.get_message(key)
    
    return TranslationServer.translate(key)

func add_mod_to_load_order(mod_id: String, load_order: Array, tree := []):
    _assert(tree.find(mod_id) == -1, "Circular 'load_after' for mods!")
    if load_order.find(mod_id) != -1:
        return

    var new_tree := tree.duplicate()
    new_tree.push_back(mod_id)

    for load_after in mod_info[mod_id].load_after:
        add_mod_to_load_order(load_after, load_order, new_tree)
    
    load_order.push_back(mod_id)