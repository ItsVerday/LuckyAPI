extends "res://Pop-up_Pop-up.gd"

onready var modloader: Reference = get_tree().modloader

func option_is_findable(type):
    return modloader.can_find_symbol(type)

func add_cards(f_rarities):
    var email = emails[0]
    var database

    if not visible:
        var card_pool
        var r_chances
        if email.type == "add_tile":
            if email.extra_values.has("forced_group"):
                card_pool = $"/root/Main/".rarity_database["symbols"].duplicate(true)
                for c in card_pool.keys():
                    var c_tbe = []
                    for i in card_pool[c]:
                        if $"/root/Main/".group_database["symbols"][email.extra_values.forced_group].find(i) == -1:
                            c_tbe.push_back(i)
                    for z in c_tbe:
                        card_pool[c].erase(z)
            else:
                card_pool = $"/root/Main/".rarity_database["symbols"].duplicate(true)
                if not reels.can_add_highlander():
                    card_pool["very_rare"].erase("highlander")
            for c in card_pool.keys():
                for i in card_pool[c].duplicate(true):
                    if not option_is_findable(i):
                        card_pool[c].erase(i)
            r_chances = $"/root/Main/".rarity_chances["symbols"].duplicate(true)
            database = $"/root/Main/".tile_database
            for r in r_chances.keys():
                r_chances[r] *= rarity_bonuses["symbols"][r]
        elif email.type == "add_item":
            symbols_to_choose_from = 3
            database = $"/root/Main/".item_database
            card_pool = $"/root/Main/".rarity_database["items"].duplicate(true)
            for i in $"/root/Main/Items".items:
                card_pool[i.rarity].erase(i.type)
            for i in $"/root/Main/Items".destroyed_items:
                card_pool[database[i].rarity].erase(i)
            r_chances = $"/root/Main/".rarity_chances["items"].duplicate(true)
            for r in r_chances.keys():
                r_chances[r] *= rarity_bonuses["items"][r]
            if comfy_pillow_trigger:
                email.extra_values = {"forced_rarity": []}
                for i in range($"/root/Main".item_database["comfy_pillow"].values[1]):
                    email.extra_values.forced_rarity.push_back("rare")
                comfy_pillow_trigger = false
                
        for c in range(symbols_to_choose_from):
            var rarity
            var card = preload("res://Card.tscn").instance()
            if email.type == "add_item":
                card.item = true
            if saved_card_types.size() < symbols_to_choose_from or (c < saved_card_types.size() - 1 and saved_card_types[c] == null):
                randomize()
                var rand_num = rand_range(0, 1)
                
                var forced_rarity_arr = []
                if email.extra_values.has("forced_rarity"):
                    forced_rarity_arr = email.extra_values.forced_rarity
                    if c == 0:
                        forced_rarity_arr.shuffle()
                
                if c < forced_rarity_arr.size() and ((email.extra_values.has("or_better") and not email.extra_values.or_better) or (not email.extra_values.has("or_better"))) and card_pool[forced_rarity_arr[c]].size() > 0:
                    rarity = forced_rarity_arr[c]
                elif rand_num < r_chances.very_rare and card_pool["very_rare"].size() > 0:
                    rarity = "very_rare"
                elif rand_num < r_chances.very_rare + r_chances.rare and card_pool["rare"].size() > 0:
                    rarity = "rare"
                elif rand_num < r_chances.very_rare + r_chances.rare + r_chances.uncommon and card_pool["uncommon"].size() > 0:
                    rarity = "uncommon"
                elif card_pool["common"].size() > 0:
                    rarity = "common"
                    
                if rarity != null:
                    if c < forced_rarity_arr.size() and email.extra_values.has("or_better") and email.extra_values.or_better:
                        var rarity_order = ["common", "uncommon", "rare", "very_rare"]
                        if rarity_order.find(forced_rarity_arr[c]) > rarity_order.find(rarity):
                            rarity = forced_rarity_arr[c]
                    
                    randomize()
                    var c_type = card_pool[rarity][floor(rand_range(0, card_pool[rarity].size()))]
                    card.data = database[c_type]
                    card_pool[rarity].erase(card.data.type)
                elif email.type == "add_item":
                    if c < forced_rarity_arr.size() and ((email.extra_values.has("or_better") and not email.extra_values.or_better) or (not email.extra_values.has("or_better"))):
                        rarity = forced_rarity_arr[c]
                    elif rand_num < r_chances.very_rare:
                        rarity = "very_rare"
                    elif rand_num < r_chances.very_rare + r_chances.rare:
                        rarity = "rare"
                    elif rand_num < r_chances.very_rare + r_chances.rare + r_chances.uncommon:
                        rarity = "uncommon"
                    else:
                        rarity = "common"
                    match rarity:
                        "very_rare":
                            card.data = database["four_leaf_clover"]
                        "rare":
                            card.data = database["bowling_ball"]
                        "uncommon":
                            card.data = database["horseshoe"]
                        "common":
                            card.data = database["pool_ball"]
                else:
                    card.data = database["coin"]
                
                saved_card_types.push_back(card.data.type)
                cards.push_back(card)
            else:
                card.data = database[saved_card_types[c]]
                cards.push_back(card)
        $"/root/Main".save_game()
        var total_card_width = 0
        var tallest_height = 0
        for c in cards:
            container.add_child(c)
            total_card_width += 79
            if tallest_height < (c.background.rect_size.y + 2) / 2:
                tallest_height = (c.background.rect_size.y + 2) / 2
        total_card_width -= 2
        var width_so_far = 0
        for c in cards:
            c.rect_position.x = rect_size.x - total_card_width / 2 + width_so_far
            c.rect_position.y = container.rect_size.y / 2 - tallest_height
            width_so_far += 79
        card_pool.clear()

func update_rent_values():
    .update_rent_values()
    modify_rent_values()

func modify_rent_values():
    for mod_id in modloader.mod_load_order:
        var mod := modloader.mods[mod_id]
        if mod.has_method("modify_rent_cost"):
            rent_values[0] = mod.modify_rent_cost(rent_values[0], times_rent_paid + 1)

    for mod_id in modloader.mod_load_order:
        var mod := modloader.mods[mod_id]
        if mod.has_method("modify_rent_spins"):
            rent_values[1] = mod.modify_rent_spins(rent_values[1], times_rent_paid + 1)