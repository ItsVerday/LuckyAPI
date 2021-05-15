extends Reference

var modloader: Reference
var id: String

var modifies_self_adjacency := false
var modifies_adjacent_adjacency := false
var modifies_global_adjacency := false

func init(modloader: Reference, params):
    self.modloader = modloader
    print("No initialization behavior for symbol patch defined in " + self.get_script().get_path())

func patch_value(value: float) -> float:
    return value

func patch_values(values: Array) -> Array:
    return values

func patch_rarity(rarity: String) -> String:
    return rarity

func patch_groups(groups: Array) -> Array:
    return groups

func patch_texture(texture: Texture) -> Texture:
    return texture

func load_texture(path: String) -> Texture:
    var image := Image.new()
    var err := image.load(path)
    _assert(err == OK, "Texture named " + id + " failed to load!")
    var texture := ImageTexture.new()
    texture.create_from_image(image, 0)

    return texture

func patch_extra_textures(extra_textures: Dictionary) -> Dictionary:
    return extra_textures

func patch_sfx(sfx: Dictionary) -> Dictionary:
    return sfx

func patch_sfx_redirects(sfx_redirects: Array) -> Array:
    return sfx_redirects

func patch_name(name: String) -> String:
    return name

func patch_description(description: String) -> String:
    return description

func translation_join(a: String, b: String, delimeter := "  ") -> String:
    if a.length() == 0:
        return b
    
    return a + delimeter + b

func modify_self_adjacency(myself, grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_adjacent_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func modify_global_adjacency(myself, my_grid_position, to_modify, to_modify_grid_position, currently_adjacent, symbol_grid):
    return currently_adjacent

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()