extends Reference

var modloader: Reference

var id: String
var value := 1
var values := []
var rarity := "common"
var groups := []
var texture: ImageTexture
var extra_textures := {}
var name: String
var description: String

var value_text := 0
var value_text_color = "<color_E14A68>"

var modifies_self_adjacency := false
var modifies_adjacent_adjacency := false
var modifies_global_adjacency := false

func init(modloader: Reference):
    print("No initialization behavior for custom symbol defined in " + self.get_script().get_path())

func load_texture(path: String) -> ImageTexture:
    var image := Image.new()
    var err := image.load(path)
    _assert(err == OK, "Texture named " + id + " failed to load!")
    texture = ImageTexture.new()
    texture.create_from_image(image, 0)

    return texture


func modify_self_adjacency(myself, grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_adjacent_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_global_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func update_value_text(symbol, values):
    pass

func add_conditional_effects(adjacent):
    pass

func add_symbol(type):
    modloader.globals.reels.symbol_queue.push_back(type)

func add_item(type):
    modloader.globals.items.add_item(type)


func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()