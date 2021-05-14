extends "res://Main_Main.gd"

var modloader := null
func _ready():
    ._ready()

    modloader = get_tree().modloader
    load_globals(modloader)

func load_globals(modloader: Reference):
    print("LuckyAPI MODLOADER > Loading globals...")
    modloader.databases.icon_texture_database = self.icon_texture_database
    modloader.databases.tile_database = self.tile_database
    modloader.databases.item_database = self.item_database
    modloader.databases.sfx_database = self.sfx_database
    modloader.databases.rarity_database = self.rarity_database
    modloader.databases.rarity_chances = self.rarity_chances
    modloader.databases.group_database = self.group_database

    modloader.globals.main = $"/root/Main"
    modloader.globals.items = $"/root/Main/Items"
    modloader.globals.reels = $"/root/Main/Reels"
    modloader.globals.pop_up = $"/root/Main/Pop-up Sprite/Pop-up"