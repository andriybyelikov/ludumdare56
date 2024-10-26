extends Node


const SAVE_PATH: String = "user://save.cfg"


var save: ConfigFile


func write_empty_save_data() -> void:
    self.save.set_value("revelations", "slime_coverage_revealed", false)
    self.save.set_value("revelations", "wound_consequences_revealed", false)
    self.save.set_value("status", "slime_coverage", false)
    self.save.set_value("status", "wounded", false)
    self.save.set_value("progression", "scene_id", 0)


func write_save_file() -> void:
    self.save.save(SAVE_PATH)


func read_save_file() -> void:
    self.save.load(SAVE_PATH)


func _ready() -> void:
    var save_file: ConfigFile = ConfigFile.new()
    save_file.load(SAVE_PATH)
    self.save = save_file
