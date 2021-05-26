extends "res://modloader/utils.gd"

var symbols := {}
var groups := {}

func init(modloader: Reference):
    self.modloader = modloader

func tr(key):
    return modloader.translate(key)

func go():
    ensure_dir_exists("user://datadump")
    create_symbols_database()
    save_symbols_database()
    save_symbols_reference()

func create_symbols_database():
    print_dd("Creating symbols database...")

    for symbol_id in modloader.databases.tile_database.keys():
        var symbol := modloader.databases.tile_database[symbol_id]
        var mod_symbol := modloader.mod_symbols[symbol_id]
        if symbol.type == "hover_coin":
            continue

        var symbol_data := {
            "id": symbol.type,
            "value": symbol.value,
            "values": symbol.values,
            "rarity": symbol.rarity,
            "groups": symbol.groups
        }

        if mod_symbol == null:
            symbol_data.mod = "vanilla"
        else:
            symbol_data.mod = mod_symbol.mod_name
        
        symbol_data.name = translate(symbol_data.id, false)
        symbol_data.description = translate(symbol_data.id + "_desc", false)
        if symbol_data.description == symbol_data.id + "_desc":
            symbol_data.description = ""

        symbols[symbol_data.id] = symbol_data

        for group in symbol_data.groups:
            if not groups.has(group):
                groups[group] = []
            
            groups[group].push_back(symbol_data.id)
    
    print_dd("Symbols database created!")

func save_symbols_database():
    write_json("user://datadump/symbols.json", {
        "symbols": symbols,
        "groups": groups
    })

func save_symbols_reference():
    var data := "# Symbols\n\n"
    for symbol_id in symbols.keys():
        data += symbol_reference(symbols[symbol_id])
    
    data += "# Groups\n\n"
    for group_id in groups.keys():
        data += "<a name=\"group_" + group_id + "\"></a>Group `" + group_id + "`: "
        for symbol_id in groups[group_id]:
            data += "[" + symbols[symbol_id].name + "](#symbol_" + symbol_id + "), "
        data = data.substr(0, data.length() - 2)
        data += "\n\n"
    
    write_text("user://datadump/symbols.md", data)

func symbol_reference(symbol):
    var data := "### <a name=\"symbol_" + symbol.id + "\"></a>" + symbol.name + " `(" + symbol.id + ")`\n"
    data += symbol.rarity.capitalize() + ", Gives " + str(symbol.value) + "¢. From mod `" + symbol.mod + "`. In groups: `" + get_names_list(symbol.groups) + "`.\n\n"
    if symbol.description == "":
        data += "*No description...*\n\n"
    else:
        data += fix_description(symbol.description, symbol) + "\n\n"
    return data

func fix_description(description, symbol):
    var fixed_description := description

    var regex_color := RegEx.new()
    regex_color.compile("<color_[0-9A-Fa-f]+>")
    var result_color := regex_color.search(fixed_description)
    while result_color != null:
        fixed_description = splice(fixed_description, result_color.get_start(), result_color.get_end(), "")
        result_color = regex_color.search(fixed_description)

    var regex_end := RegEx.new()
    regex_end.compile("<end>")
    var result_end := regex_end.search(fixed_description)
    while result_end != null:
        fixed_description = splice(fixed_description, result_end.get_start(), result_end.get_end(), "")
        result_end = regex_end.search(fixed_description)

    var regex_coin := RegEx.new()
    regex_coin.compile("<icon_coin>")
    var result_coin := regex_coin.search(fixed_description)
    while result_coin != null:
        fixed_description = splice(fixed_description, result_coin.get_start(), result_coin.get_end(), "¢")
        result_coin = regex_coin.search(fixed_description)

    var regex_hover_coin := RegEx.new()
    regex_hover_coin.compile("<icon_hover_coin>")
    var result_hover_coin := regex_hover_coin.search(fixed_description)
    while result_hover_coin != null:
        fixed_description = splice(fixed_description, result_hover_coin.get_start(), result_hover_coin.get_end(), "<icon_coin>")
        result_hover_coin = regex_hover_coin.search(fixed_description)

    var regex_split := RegEx.new()
    regex_split.compile("(<icon_[a-zA-Z0-9_]+>|<value_[0-9]+>)(<icon_[a-zA-Z0-9_]+>|<value_[0-9]+>)")
    var result_split := regex_split.search(fixed_description)
    while result_split != null:
        fixed_description = splice(fixed_description, result_split.get_start(), result_split.get_end(), join(result_split.get_string(1), result_split.get_string(2)))
        result_split = regex_split.search(fixed_description)

    var regex_token := RegEx.new()
    regex_token.compile("<icon_([a-zA-Z0-9_]+)_token>")
    var result_token := regex_token.search(fixed_description)
    while result_token != null:
        var type := result_token.get_string(1).capitalize()
        fixed_description = splice(fixed_description, result_token.get_start(), result_token.get_end(), "`" + type + " Token`")
        result_token = regex_token.search(fixed_description)
        
    var regex_icon := RegEx.new()
    regex_icon.compile("<icon_([a-zA-Z0-9_]+)>")
    var result_icon := regex_icon.search(fixed_description)
    while result_icon != null:
        var ref := result_icon.get_string(1)
        if symbols.has(ref):
            var name = symbols[ref].name
            fixed_description = splice(fixed_description, result_icon.get_start(), result_icon.get_end(), "[" + name + "](#symbol_" + ref + ")")
        else:
            fixed_description = splice(fixed_description, result_icon.get_start(), result_icon.get_end(), "`icon_" + ref + "`")
        result_icon = regex_icon.search(fixed_description)

    var regex_value := RegEx.new()
    regex_value.compile("<value_([0-9]+)>")
    var result_value := regex_value.search(fixed_description)
    while result_value != null:
        var ref := int(float(result_value.get_string(1))) - 1
        fixed_description = splice(fixed_description, result_value.get_start(), result_value.get_end(), str(symbol.values[ref]))
        result_value = regex_value.search(fixed_description)

    var regex_group := RegEx.new()
    regex_group.compile("<group_([a-zA-Z0-9_]+)>.*?<last_\\1>")
    var result_group := regex_group.search(fixed_description)
    while result_group != null:
        var ref := result_group.get_string(1)
        var name := "Group `" + ref + "`"
        fixed_description = splice(fixed_description, result_group.get_start(), result_group.get_end(), "[" + name + "](#group_" + ref + ")")
        result_group = regex_group.search(fixed_description)

    var regex_all := RegEx.new()
    regex_all.compile("<all_(and|or)_([a-zA-Z0-9_]+)>")
    var result_all := regex_all.search(fixed_description)
    while result_all != null:
        var ref := result_all.get_string(2)
        var name := "Group `" + ref + "`"
        fixed_description = splice(fixed_description, result_all.get_start(), result_all.get_end(), "[" + name + "](#group_" + ref + ")")
        result_all = regex_all.search(fixed_description)
    
    return fixed_description

func print_dd(message: String):
    print("LuckyAPI DATADUMP > " + message)