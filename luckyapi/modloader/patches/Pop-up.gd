extends "res://Pop-up_Pop-up.gd"

onready var modloader: Reference = get_tree().modloader

func option_is_findable(type):
    return modloader.can_find_symbol(type)

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
    
    if times_rent_paid >= 3 and times_rent_paid % 2 == 1:
        for mod_id in modloader.mod_load_order:
            var mod := modloader.mods[mod_id]
            if mod.has_method("modify_reroll_tokens"):
                comrade_values[0] = mod.modify_reroll_tokens(comrade_values[0], times_rent_paid + 1)

        for mod_id in modloader.mod_load_order:
            var mod := modloader.mods[mod_id]
            if mod.has_method("modify_removal_tokens"):
                comrade_values[1] = mod.modify_removal_tokens(comrade_values[1], times_rent_paid + 1)