extends SceneTree

var modloader = null
var exe_dir := OS.get_executable_path().get_base_dir()

func _initialize():
    print("LuckyAPI BOOTSTRAP > Executable directory: " + exe_dir)
    print("LuckyAPI BOOTSTRAP > Godot version: " + Engine.get_version_info().string)

    load_folder(exe_dir.plus_file("luckyapi/modloader"), "modloader")

    print("LuckyAPI BOOTSTRAP > Running modloader...")
    modloader = load("res://modloader/modloader.gd").new(self)
    modloader.before_start()

    print("LuckyAPI BOOTSTRAP > Starting game...")
    change_scene(ProjectSettings.get_setting("application/run/main_scene"))

    connect("node_added", self, "after_start", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func load_folder(path: String, folder: String):
    var exe_dir := OS.get_executable_path().get_base_dir()
    var pck_file := exe_dir.plus_file("luckyapi").plus_file("content.pck")

    var packer := PCKPacker.new()
    _assert(packer.pck_start(pck_file) == OK, "Opening content.pck for writing failed!")
    recursive_pack(packer, path, "res://".plus_file(folder))
    _assert(packer.flush(true) == OK, "Failed to write to content.pck!")
    _assert(ProjectSettings.load_resource_pack(pck_file, true), "Failed to load content.pck!")

func recursive_pack(packer: PCKPacker, path: String, packer_path: String):
    var dir := Directory.new()
    if dir.open(path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name != "." and file_name != "..":
                if dir.current_is_dir():
                    recursive_pack(packer, path.plus_file(file_name), packer_path.plus_file(file_name))
                else:
                    packer.add_file(packer_path.plus_file(file_name), path.plus_file(file_name))
            file_name = dir.get_next()

func after_start(node: Node):
    modloader.after_start()

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI BOOTSTRAP > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()