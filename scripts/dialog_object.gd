extends TextureButton


@export var dialog_sequence_id: int


func _ready() -> void:
    pressed.connect(_request_play_dialogue_sequence)


func _request_play_dialogue_sequence() -> void:
    owner.request_play_dialogue_sequence(dialog_sequence_id)
