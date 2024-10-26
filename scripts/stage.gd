extends Control

@export var cutscene: bool
@export var next_stage: int
@export_multiline var lines: Array[String]
@export var sequence_db: Array[int]


signal cutscene_finished
signal travel_request(scene_id: int)
signal start_sequence_request(sequence_id: int)


func _ready() -> void:
    pass
    
    
func scale_content(interface_height: int) -> void:
    const CONTENT_SAFE_RECT: Vector2i = Vector2i(512, 288)
    var viewport_height: int = get_tree().root.size.y
    var available_height: int = viewport_height - interface_height 
    var scale_y: float = available_height / float(CONTENT_SAFE_RECT.y)
    var available_width: int = get_tree().root.size.x
    var post_width: int = available_height * 16.0 / 9.0
    var s: float = scale_y
    if post_width > available_width:
        s = available_width / float(CONTENT_SAFE_RECT.x)
    self.scale = Vector2(s, s)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    self.cutscene_finished.emit()


func request_travel(stage_id: int) -> void:
    self.travel_request.emit(stage_id)
    

func request_play_dialogue_sequence(sequence_id: int):
    self.start_sequence_request.emit(sequence_id)


func set_interactables_disabled(disabled: bool):
    %Interactables.visible = not disabled
