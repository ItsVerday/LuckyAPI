extends "res://modloader/utils.gd"

var tree: SceneTree
const ModSymbol = preload("res://modloader/ModSymbol.gd")
const SymbolPatcher = preload("res://modloader/SymbolPatcher.gd")

const modloader_version := "v0.3.0"
const expected_versions := ["v0.11"]
var game_version: String = "<game version not determined yet>"

var exe_dir := OS.get_executable_path().get_base_dir()

var mods := {}
var mod_info := {}
var mod_load_order := []
var mod_content := {}
var mod_count := 0
var current_mod_name := ""

var databases := {}
var globals := {}

var mod_symbols := {}
var symbol_patches := {}
var translations := {}
var starting_symbols := []
var dynamic_groups := {}
var update_dynamic_groups := false

func _init(tree: SceneTree):
    self.tree = tree

func add_mod_symbol(path: String, params := {}):
    var script := load(path)
    var mod_symbol := script.new()
    mod_symbol.init(self, params)
    var id := mod_symbol.id
    mod_symbols[id] = mod_symbol
    if current_mod_name != "":
        mod_symbol.mod_name = current_mod_name
        mod_content[current_mod_name].symbols.push_back(mod_symbol)
    
    _assert(check_extends(script, "res://modloader/ModSymbol.gd"), "Mod symbol " + id + " does not extend ModSymbol.gd!")

    databases.icon_texture_database[id] = mod_symbol.texture
    for extra_texture_key in mod_symbol.extra_textures.keys():
        databases.icon_texture_database[id + "_" + extra_texture_key] = mod_symbol.extra_textures[extra_texture_key]
    
    databases.tile_database[id] = {
        "type": id,
        "value": mod_symbol.value,
        "values": mod_symbol.values,
        "groups": mod_symbol.groups,
        "rarity": mod_symbol.rarity,
        "sfx": mod_symbol.sfx,
    }

    databases.sfx_database.symbols[id] = mod_symbol.sfx
    if mod_symbol.rarity != null:
        databases.rarity_database.symbols[mod_symbol.rarity].push_back(id)

    for group in mod_symbol.groups:
        if not databases.group_database.symbols.has(group):
            databases.group_database.symbols[group] = []
        
        databases.group_database.symbols[group].push_back(id)

        if dynamic_groups.has(group):
            dynamic_groups[group].symbol_overrides[id] = true
    
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
    
        update_symbol_dynamic_groups(id)
    
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
    if current_mod_name != "":
        symbol_patch.mod_name = current_mod_name
        mod_content[current_mod_name].symbol_patches.push_back(symbol_patch)
    
    _assert(check_extends(script, "res://modloader/SymbolPatcher.gd"), "Symbol patcher " + id + " does not extend SymbolPatcher.gd!")

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
    
    var values := symbol_patch.patch_values(database_entry.values, database_entry.values.size())
    database_entry.values = values
    if mod_symbol != null:
        mod_symbol.values = values
    
    var rarity := database_entry.rarity
    if rarity != null:
        databases.rarity_database.symbols[rarity].erase(id)
    rarity = symbol_patch.patch_rarity(rarity)
    if rarity != null:
        databases.rarity_database.symbols[rarity].push_back(id)
    database_entry.rarity = rarity
    if mod_symbol != null:
        mod_symbol.rarity = rarity
    
    var groups := database_entry.groups
    var patched_groups := symbol_patch.patch_groups(groups.duplicate())

    for group in groups:
        databases.group_database.symbols[group].erase(id)
        if not patched_groups.has(group) and dynamic_groups.has(group):
            dynamic_groups[group].symbol_overrides[id] = false
    
    for group in patched_groups:
        if not databases.group_database.symbols.has(group):
            databases.group_database.symbols[group] = []
        
        database_entry.groups = patched_groups
        databases.group_database.symbols[group].push_back(id)
        if not groups.has(group) and dynamic_groups.has(group):
            dynamic_groups[group].symbol_overrides[id] = true
    
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
    
    var sfx: Array = nvl(databases.sfx_database.symbols[id], [])
    if mod_symbol != null:
        sfx = symbol_patch.patch_sfx(mod_symbol.sfx)
        mod_symbol.sfx = sfx
    else:
        sfx = symbol_patch.patch_sfx(sfx)
    databases.sfx_database.symbols[id] = sfx
    if sfx:
        database_entry.sfx = sfx
    
    var sfx_overrides : Dictionary
    if mod_symbol != null:
        sfx_overrides = symbol_patch.patch_sfx_overrides(mod_symbol.sfx_overrides)
        mod_symbol.sfx_overrides = sfx_overrides
    else:
        sfx_overrides = symbol_patch.patch_sfx_overrides(symbol_patch.sfx_overrides)
        symbol_patch.sfx_overrides = sfx_overrides
    
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
    
    update_symbol_dynamic_groups(id)

func add_dynamic_group(name, dynamic_group):
    dynamic_groups[name] = dynamic_group
    dynamic_group.name = name
    dynamic_group.modloader = self

    if databases.group_database.symbols.has(name):
        for symbol in databases.group_database.symbols[name]:
            dynamic_group.symbol_overrides[symbol] = true
    
    update_dynamic_group(name)

func update_dynamic_group(dynamic_group_name, depth := 0):
    var should_redo := false

    for symbol in databases.tile_database.keys():
        var did_update := update_symbol_in_dynamic_group(symbol, dynamic_group_name, depth)

        if did_update:
            update_symbol_dynamic_groups(symbol, depth + 1)

func update_symbol_dynamic_groups(symbol, depth := 0):
    var should_redo := false

    for dynamic_group_name in dynamic_groups.keys():
        var did_update := update_symbol_in_dynamic_group(symbol, dynamic_group_name, depth)

        if did_update:
            should_redo = true
    
    if should_redo and depth < 10:
        update_symbol_dynamic_groups(symbol, depth + 1)

func update_symbol_in_dynamic_group(symbol, dynamic_group_name):
    var dynamic_group := dynamic_groups[dynamic_group_name]
    var old_cache_entry := dynamic_group.cache[symbol]
    var is_included := dynamic_group.check_symbol(symbol)

    if old_cache_entry != is_included:
        if not databases.group_database.symbols.has(dynamic_group_name):
            databases.group_database.symbols[dynamic_group_name] = []
        
        if is_included:
            databases.tile_database[symbol].groups.push_back(dynamic_group_name)
            databases.group_database.symbols[dynamic_group_name].push_back(symbol)
        else:
            databases.tile_database[symbol].groups.erase(dynamic_group_name)
            databases.group_database.symbols[dynamic_group_name].erase(symbol)
        
        return true
    
    return false



func check_missing_symbol(id):
    if id == null:
        return
    
    if not databases.tile_database.has(id):
        add_mod_symbol("res://modloader/MissingSymbol.gd", {"id": id})

func generate_starting_symbols():
    var symbols := ["coin", "cherry", "pearl", "flower", "cat"]
    if globals.pop_up.current_floor >= 5:
        symbols.push_back("dud")
    if globals.pop_up.current_floor >= 7:
        symbols.push_back("dud")
    if globals.pop_up.current_floor >= 11:
        symbols.push_back("dud")

    for mod_id in modloader.mod_load_order:
        var mod := modloader.mods[mod_id]
        if mod.has_method("modify_starting_symbols"):
            symbols = mod.modify_starting_symbols(symbols)
    
    starting_symbols = symbols

func before_start():
    print("LuckyAPI MODLOADER > Initializing LuckyAPI " + modloader_version + "...")
    ensure_dir_exists("user://mods")

    var main_script := extract_script(load("res://Main.tscn"), "Main").source_code
    var regex := RegEx.new()
    regex.compile("\\s*content_patch_num\\s*=\\s*(\\d*)")
    var matched_version := regex.search(main_script)
    _assert(matched_version != null, "Version check failed: Unable to determine game version. This modloader is for game versions " + str(expected_versions) + "!")

    game_version = "v0." + str(matched_version.get_string(1))
    print("LuckyAPI MODLOADER > Game version " + game_version)
    _assert(expected_versions.find(game_version) > -1, "Version mismatch: This modloader is for version '" + str(expected_versions) + "' but the game is running version '" + game_version + "'!")

    find_mods()
    patch_preload()

func find_mods():
    print("LuckyAPI MODLOADER > Finding mods...")
    var mods_dir := "user://mods/"
    var _dir := Directory.new()
    if _dir.open(mods_dir) == OK:
        _assert(_dir.list_dir_begin(true) == OK, "list_dir_began failed!")
        var found_name := _dir.get_next()
        while found_name != "":
            var mod_name := found_name
            if _dir.current_is_dir():
                load_folder(mods_dir.plus_file(found_name), found_name, "mod_" + found_name)
            elif found_name.get_extension() == "zip":
                load_zip(mods_dir.plus_file(found_name), found_name.get_basename(), "mod_" + found_name.get_basename())
                mod_name = found_name.get_basename()
            elif found_name.get_extension() == "pck":
                load_pck(mods_dir.plus_file(found_name), found_name.get_basename())
                mod_name = found_name.get_basename()
            else:
                continue
            
            print("LuckyAPI MODLOADER > Mod found: " + mod_name)
            var info := load_info("res://" + mod_name + "/mod.json", mod_name)
            mod_info[mod_name] = info

            print("LuckyAPI MODLOADER > Read mod info for mod: " + mod_name)

            mod_count += 1
            found_name = _dir.get_next()
    
    for mod_id in mod_info.keys():
        add_mod_to_load_order(mod_id, mod_load_order)
        for dependency in mod_info[mod_id].dependencies:
            _assert(mod_info.has(dependency), "Mod " + mod_id + " requires a dependency which wasn't found: " + dependency + "!")
            
func add_mod_to_load_order(mod_id: String, load_order: Array, tree := []):
    _assert(tree.find(mod_id) == -1, "Circular 'load_after' for mods!")
    if load_order.find(mod_id) != -1:
        return

    var new_tree := tree.duplicate()
    new_tree.push_back(mod_id)

    for load_after in mod_info[mod_id].load_after:
        add_mod_to_load_order(load_after, load_order, new_tree)
    
    load_order.push_back(mod_id)

func patch_preload():
    print("LuckyAPI MODLOADER > Beginning patching process...")

    var packer := PCKPacker.new()
    _assert(packer.pck_start("user://_luckyapi_patched/preload.pck") == OK, "Opening preload.pck for writing failed!")
    var force_reload := []
    patch_tscn("res://Main.tscn", ["res://modloader/patches/Main.gd", "res://modloader/patches/Title.gd", "res://modloader/patches/Reels.gd"], ["Main", "Title", "Reels"], packer, force_reload)
    patch_tscn("res://Slot Icon.tscn", ["res://modloader/patches/SlotIcon.gd"], ["Slot Icon"], packer, force_reload)
    patch_tscn("res://Tooltip.tscn", ["res://modloader/patches/Tooltip_Card.gd"], ["Card"], packer, force_reload)
    patch_tscn("res://Card.tscn", ["res://modloader/patches/Card.gd"], ["Card"], packer, force_reload)
    patch_tscn("res://Pop-up.tscn", ["res://modloader/patches/Pop-up.gd"], ["Pop-up"], packer, force_reload)
    patch_tscn("res://Reel.tscn", ["res://modloader/patches/Reel.gd"], ["Reel"], packer, force_reload)

    _assert(packer.flush(true) == OK, "Failed to write to preload.pck")
    print("LuckyAPI MODLOADER > Loading patched code...")
    
    _assert(ProjectSettings.load_resource_pack("user://_luckyapi_patched/preload.pck", true), "Failed to load patched code!")
    for to_reload in force_reload:
        force_reload(to_reload)

    apply_mod_patches()

    print("LuckyAPI MODLOADER > Patching game code complete!")

func apply_mod_patches():
    for mod_name in mod_load_order:
        var info := mod_info[mod_name]
        var patches := info.patches

        if patches.size() == 0:
            continue
        
        print("LuckyAPI MODLOADER > Beginning patching process for mod " + mod_name + "...")

        var packer_name := "user://_luckyapi_patched/mod_patches_" + mod_name + ".pck"
        var packer := PCKPacker.new()
        _assert(packer.pck_start(packer_name) == OK, "Opening mod_patches_" + mod_name + ".pck for writing failed!")
        var force_reload := []

        for patch_info in patches:
            if patch_info.type == "tscn":
                var scripts := []
                var names := []

                for name in patch_info.scripts.keys():
                    scripts.push_back(patch_info.scripts[name])
                    names.push_back(name)
                
                patch_tscn(patch_info.to_patch, scripts, names, packer, force_reload, true)
            elif patch_info.type == "gd":
                patch_gd(patch_info.to_patch, patch_info.scripts.main, packer, force_reload)
        
        _assert(packer.flush(true) == OK, "Failed to write to mod_patches_" + mod_name + ".pck")
        print("LuckyAPI MODLOADER > Loading patched code for " + mod_name + "...")

        _assert(ProjectSettings.load_resource_pack(packer_name, true), "Failed to load patched code!")
        for to_reload in force_reload:
            force_reload(to_reload)

func after_start():
    add_default_dynamic_groups()
    load_mods()
    add_all_tags_in_descriptions()
    datadump()
    post_initialize()

    print("LuckyAPI MODLOADER > Initialization complete!")

func add_default_dynamic_groups():
    var piratelikes := create_dynamic_group("piratelikes")
    piratelikes.add_symbols({
        "group": "chest"
    })
    
    var food := create_dynamic_group("food")
    food.add_symbols({
        "group": ["fruit", "booze"]
    })
    food.symbol_overrides["coconut"] = false

    var witchlikes := create_dynamic_group("witchlikes")
    witchlikes.add_symbols({
        "group": "hex"
    })

    var farmerlikes := create_dynamic_group("farmerlikes")
    farmerlikes.add_symbols({
        "group": ["fruit", "plant", "chickenstuff"]
    })
    farmerlikes.symbol_overrides["coconut_half"] = false

    var organism := create_dynamic_group("organism")
    organism.add_symbols({
        "group": ["human", "animal"]
    })
    organism.symbol_overrides["billionaire"] = false

    var doglikes := create_dynamic_group("doglikes")
    doglikes.add_symbols({
        "group": ["human"]
    })
    doglikes.symbol_overrides["billionaire"] = false
    
    var fruitlikes := create_dynamic_group("fruitlikes")
    fruitlikes.add_symbols({
        "group": "fruit",
        "rarity": ["common", "uncommon"]
    })

    var darkhumor := create_dynamic_group("darkhumor")
    darkhumor.add_symbols({
        "group": "spiritbox"
    })

    var anvillikes := create_dynamic_group("anvillikes")
    anvillikes.add_symbols({
        "group": ["dwarflikes", "minerlikes"]
    })

    var archlikes := create_dynamic_group("archlikes")
    archlikes.add_symbols({
        "group": ["gem", "minerlikes"],
        "rarity": ["common", "uncommon"]
    })

    var box := create_dynamic_group("box")
    box.add_symbols({
        "group": ["chest", "spiritbox"]
    })

    var robinlikes := create_dynamic_group("robinlikes")
    robinlikes.add_symbols({
        "group": ["arrow"]
    })
    robinlikes.add_symbols({
        "type": "thief"
    })

    var fossillikes := create_dynamic_group("fossillikes")
    fossillikes.add_symbols({
        "group": "hex"
    })

func load_mods():
    print("LuckyAPI MODLOADER > Running load method on found mods...")

    for mod_name in mod_load_order:
        var info := mod_info[mod_name]

        var mod_script := load("res://" + mod_name + "/" + info.main_script)
        var mod := mod_script.new()
        mods[mod_name] = mod
        mod_content[mod_name] = {
            "symbols": [],
            "symbol_patches": []
        }

        print("LuckyAPI MODLOADER > Attempting to load " + info.name + " " + info.version + "...")

        if mod.has_method("load"):
            current_mod_name = mod_name
            mod.load(self, info, tree)
        
        print("LuckyAPI MODLOADER > " + info.name + " " + info.version + " by " + get_names_list(info.authors) + " loaded!")
    
    current_mod_name = ""
    print("LuckyAPI MODLOADER > Loading mods complete!")

func add_all_tags_in_descriptions():
    for symbol_id in databases.tile_database.keys():
        var description := translate(symbol_id + "_desc")
        if description == symbol_id + "_desc":
            continue
        
        var regex_group := RegEx.new()
        regex_group.compile("<group_([a-zA-Z0-9_]+)> (and|or) <last_\\1>")
        var result_group := regex_group.search(description)
        while result_group != null:
            var id := result_group.get_string(1)
            var join := result_group.get_string(2)
            description = splice(description, result_group.get_start(), result_group.get_end(), "<all_" + join + "_" + id + ">")
            result_group = regex_group.search(description)
        
        add_translation(symbol_id + "_desc", description, TranslationServer.get_locale())

func datadump():
    print("LuckyAPI MODLOADER > Creating Data Dump...")

    var datadump := load("res://modloader/datadump.gd").new()
    datadump.init(self)
    datadump.go()

    print("LuckyAPI MODLOADER > Data Dump creation complete!")

func post_initialize():
    for mod_id in mod_load_order:
        var mod := mods[mod_id]
        if mod.has_method("on_post_initialize"):
            mod.on_post_initialize(self, tree)