extends Label


var _current_sequence: int
var _current_line: int


func _ready() -> void:
    self.set_physics_process(false)


func _physics_process(delta: float) -> void:
    if self.visible_characters < self.text.length():
        self.visible_characters = self.visible_characters + 1
        if self._has_line_ended():
            self._on_line_end()


func _input(event: InputEvent) -> void:
    if not self.is_physics_processing():
        return
    if event.is_action_released("skip_dialog"):
        self.skip_line()


func _init_line(line: String):
    self.text = line
    self.visible_characters = 0
    %SkipDialogIndicatorAnimationPlayer.stop()
    %SkipDialogIndicator.visible = false
    

func _skip_line() -> void:
    var stage: Control = get_tree().root.get_node("Main")._get_stage()
    
    var last_line: int = stage.sequence_db[self._current_sequence]
    if self._current_line == last_line:
        self._init_line("")
        self._on_sequence_finished()
        return
    
    self._current_line = self._current_line + 1
    
    var line: String = stage.lines[self._current_line]
    self._init_line(line)


func _has_line_ended() -> bool:
    return self.visible_characters == self.text.length()


func skip_line() -> void:
    if not self._has_line_ended():
        return
    self._skip_line()


func _on_line_end() -> void:
    %SkipDialogIndicator.visible = true
    %SkipDialogIndicatorAnimationPlayer.play("skip_dialog_indicator_blink")


func _on_sequence_finished() -> void:
    self.set_physics_process(false)
    var stage: Control = get_tree().root.get_node("Main")._get_stage()
    stage.set_interactables_disabled(false)
    
    %SkipDialogIndicatorAnimationPlayer.stop()
    %SkipDialogIndicator.visible = false
    %InventoryContent.visible = true
    
    
func start_sequence(sequence_id: int) -> void:
    var stage: Control = get_tree().root.get_node("Main")._get_stage()
    
    self._current_sequence = sequence_id
    self._current_line = -1
    if self._current_sequence > 0:
        self._current_line = stage.sequence_db[sequence_id - 1]
    
    self._skip_line()
