extends Reference

var modloader: Reference
var id: String

func init(modloader: Reference, params):
    self.modloader = modloader
    print("No initialization behavior for symbol patch defined in " + self.get_script().get_path())

func patch_value(value: int) -> int:
    return value

func patch_values(values: Array) -> Array:
    return values

func patch_rarity(rarity: String) -> String:
    return rarity

func patch_groups(groups: Array) -> Array:
    return groups

func patch_texture(texture: ImageTexture) -> ImageTexture:
    return texture

func load_texture(path: String) -> ImageTexture:
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

# Currently, patching names and descriptions doesn't work. Will have to figure out a way to do so.
func patch_name(name: String) -> String:
    return name

func patch_description(description: String) -> String:
    return description

func add_conditional_effects(symbol, adjacent):
    pass


func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()