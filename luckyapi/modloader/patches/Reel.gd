extends "res://Reel_Reel.gd"

onready var modloader: Reference = get_tree().modloader

func load_icons():
    for icon_type in icon_types:
        modloader.check_missing_symbol(icon_type)
    
    .load_icons()

func load_base_icons():
    if modloader.starting_symbols.size() == 0:
        modloader.generate_starting_symbols()

    var symbols := []
    var index := reel_num
    while index < modloader.starting_symbols.size():
        symbols.push_back(modloader.starting_symbols[index])
        index += parent.reel_width
    
    icon_types = [null, null, null, null]
    var insert_order := [2, 0, 3, 1]
    if reel_num % 2 == 1:
        insert_order = [1, 3, 2, 0]
    
    for symbol in symbols:
        var inserted = false

        for insert_index in insert_order:
            if icon_types[insert_index] == null:
                icon_types[insert_index] = symbol
                inserted = true
                break
        
        if not inserted:
            icon_types.push_back(symbol)
    
    max_icons = icon_types.size()
    if max_icons < 5:
        max_icons = 5

    load_icons()