extends Reference

static func get_or_default(obj: Object, property: String, default):
    return obj.get(property) if (property in obj) else default

static func ensure_dir_exists(dir_path: String):
    var dir := Directory.new()
    if !dir.dir_exists(dir_path):
        _assert(dir.make_dir(dir_path) == OK, "Failed to create directory " + dir_path + "!")

static func read_text(file_path: String) -> String:
    var data_file := File.new()
    _assert(data_file.open(file_path, File.READ) == OK, "Failed to open " + file_path + "!")
    var text := data_file.get_as_text()
    data_file.close()
    return text

static func read_json(file_path: String):
    var parse_result := JSON.parse(read_text(file_path))
    _assert(parse_result.error == OK, "Failed to parse " + file_path + " as JSON!")
    return parse_result.result

func _assert(condition: bool, message: String):
    if !condition:
        _halt(message)

func _halt(message: String):
    push_error("LuckyAPI MODLOADER > Runtime Error: " + message)

    var n = null
    n.fail_runtime_check()