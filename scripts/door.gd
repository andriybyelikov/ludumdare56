extends TextureButton


@export var destination_stage_id: int


func _ready() -> void:
    self.pressed.connect(_request_travel)


func _request_travel() -> void:
    owner.request_travel(destination_stage_id)
