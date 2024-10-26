extends TextureButton


@export var destination_stage_id: int


func _ready() -> void:
    self.pressed.connect(_request_travel)


func _request_travel() -> void:
    get_tree().change_scene_to_file("res://scenes/credits.tscn")
