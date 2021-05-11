extends SceneTree

var modloader = null
var exe_dir := OS.get_executable_path().get_base_dir()

func _initialize():
    print("LuckyAPI BOOTSTRAP > Executable directory: " + exe_dir)
    print("LuckyAPI BOOTSTRAP > Godot version: " + Engine.get_version_info().string)

    _assert(ProjectSettings.load_resource_pack(exe_dir.plus_file("luckyapi/modloader.zip"), true), "Failed to load LuckyAPI internals")

    print("LuckyAPI BOOTSTRAP > Running modloader...")
    modloader = load("res://modloader/modloader.gd").new(self)
    modloader.before_start()

    print("LuckyAPI BOOTSTRAP > Starting game...")
    change_scene(ProjectSettings.get_setting("application/run/main_scene"))

    connect("node_added", self, "after_start", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func after_start(node: Node):
    modloader.after_start()

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI BOOTSTRAP > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()