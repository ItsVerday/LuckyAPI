extends SceneTree

var modloader = null
var exe_dir := OS.get_executable_path().get_base_dir()

# The main function for the bootstrap. Called automatically by the engine.
func _initialize():
    print("LuckyAPI BOOTSTRAP > Executable directory: " + exe_dir)
    print("LuckyAPI BOOTSTRAP > Godot version: " + Engine.get_version_info().string)

    # Make sure the patching directory exists and is ready to go.
    ensure_dir_exists("user://_luckyapi_patched")

    # Load the files in the luckyapi/modloader folder into the game.
    load_folder(exe_dir.plus_file("luckyapi/modloader"), "modloader")

    # Initialize the modloader, and run its before_start() method.
    print("LuckyAPI BOOTSTRAP > Running modloader...")
    modloader = load("res://modloader/modloader.gd").new(self)
    modloader.modloader = modloader
    modloader.before_start()

    # Start the actual game.
    print("LuckyAPI BOOTSTRAP > Starting game...")
    change_scene(ProjectSettings.get_setting("application/run/main_scene"))

    # Setup the after_start listener so the modloader's after_start() method can be called appropriately.
    connect("node_added", self, "after_start", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

# Ensure a given directory exists.
func ensure_dir_exists(dir_path: String):
    var dir := Directory.new()
    if not dir.dir_exists(dir_path):
        _assert(dir.make_dir(dir_path) == OK, "Failed to create directory " + dir_path + "!")

# Load a folder's files into the engine's res:// folder via a .pck file.
func load_folder(path: String, folder: String):
    # Create the .pck file that will be used to load the folder's content.
    var pck_file := "user://_luckyapi_patched".plus_file("content.pck")

    # Create the packer to pack files.
    var packer := PCKPacker.new()
    _assert(packer.pck_start(pck_file) == OK, "Opening content.pck for writing failed!")
    
    # Recursively pack any files and subdirectories of the folder to be loaded into the packer.
    recursive_pack(packer, path, "res://".plus_file(folder))

    # Write the .pck to the file system and load it.
    _assert(packer.flush(true) == OK, "Failed to write to content.pck!")
    _assert(ProjectSettings.load_resource_pack(pck_file, true), "Failed to load content.pck!")

# Recursively packs files and subdirectories into a PCKPacker.
func recursive_pack(packer: PCKPacker, path: String, packer_path: String):
    # Create a new directory object.
    var dir := Directory.new()

    if dir.open(path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()

        # Loop over every file and subdirectory in this directory.
        while file_name != "":
            if file_name != "." and file_name != "..":
                if dir.current_is_dir():
                    # Traverse this new subdirectory for more files.
                    recursive_pack(packer, path.plus_file(file_name), packer_path.plus_file(file_name))
                else:
                    # Add this file to the packer.
                    packer.add_file(packer_path.plus_file(file_name), path.plus_file(file_name))
            file_name = dir.get_next()

func after_start(node: Node):
    modloader.after_start()

# Used to ensure that certain runtime conditions are met.
func _assert(condition: bool, message: String):
    if not condition:
        _halt(message)

# When called, will halt the game with an error message.
func _halt(message: String):
    push_error("LuckyAPI BOOTSTRAP > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()