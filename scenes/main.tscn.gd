extends Control


func _ready() -> void:
    var stage_id: int = %Save.save.get_value(
        "progression", "scene_id")
    self._set_stage(stage_id)
    
    # old
    %SkipDialogIndicator.visible = false
    %AutosaveIndicator.visible = false
    # old (end)
    
    get_tree().root.connect("size_changed", _on_size_changed)
    self._on_size_changed()


func _get_stage() -> Node:
    return %StageSlot.get_child(1)


func _set_stage(stage_id: int) -> void:
    if %StageSlot.get_children().size() > 1:
        var stage: Node = self._get_stage()
        # disconnect all signals before queueing free
        if stage.is_connected("cutscene_finished", _on_cutscene_finished):
            stage.disconnect("cutscene_finished", _on_cutscene_finished)
        if stage.is_connected("travel_request", _on_travel_request):
            stage.disconnect("travel_request", _on_travel_request)
        if stage.is_connected("start_sequence_request", _on_start_sequence_request):
            stage.disconnect("start_sequence_request", _on_start_sequence_request)
        stage.queue_free()
    
    var stage_path: String = (
        "res://scenes/stages/stage{stage_id}.tscn"
            .format({"stage_id": stage_id}))
    var stage_scene: PackedScene = load(stage_path)
    var stage: Node = stage_scene.instantiate()
    stage.connect("cutscene_finished", _on_cutscene_finished)
    stage.connect("travel_request", _on_travel_request)
    stage.connect("start_sequence_request", _on_start_sequence_request)
    %StageSlot.add_child(stage)
    
    var is_cutscene: bool = stage.cutscene
    %InterfaceBackground.visible = not is_cutscene
    %InterfaceContentAspectRatioContainer.visible = not is_cutscene
    
    # BGM
    if not is_cutscene:
        if not %BGM.playing:
            %BGM.play()
    
    self._on_size_changed()
    self._scale_stage_content(stage)
    self._reset_dialog()
    %FadeAnimationPlayer.play("fade_in")
    %Save.save.set_value("progression", "scene_id", stage_id)
    %Save.write_save_file()


func _on_size_changed() -> void:
    var default_height: int = ProjectSettings.get_setting(
            "display/window/size/viewport_height")
    var viewport_height: int = get_tree().root.size.y
    var scale_ratio: float = viewport_height / float(default_height)
    # substract integer scaling of the UI
    scale_ratio = scale_ratio / $OptionsDialog.get_scale()
    %InterfaceContentAspectRatioContainer.ratio = 4.0 / (3.0 * scale_ratio)
    # scale mugshots
    
    
    self._scale_stage_content(self._get_stage())
    %MapTextureRect.size.y = 1 << int(floor(log(%InterfaceContentContainer.size.y) / log(2)))
    
    var ms: int = max($OptionsDialog.get_scale(), 1)
    %Mugshot.scale = Vector2(ms, ms)

func _scale_stage_content(stage: Node) -> void:
    var dialog_height: int = 0
    if %InterfaceContentAspectRatioContainer.visible:
        dialog_height = %InterfaceContentContainer.size.y

    stage.scale_content(dialog_height)


func _reset_dialog() -> void:
    %DialogTextLabel._init_line("")
    

#region Stage Event Handlers

func _on_cutscene_finished() -> void:
    self._set_stage(self._get_stage().next_stage)


func _on_travel_request(stage_id: int) -> void:
    %FadeAnimationPlayer.play("fade_out")
    %FadeAnimationPlayer.animation_finished.connect(
        _on_travel_request_fade_out_finished.bind(stage_id),
        CONNECT_ONE_SHOT)


func _on_travel_request_fade_out_finished(anim_name: StringName, stage_id: int) -> void:
    self._set_stage(stage_id)
    


func _on_start_sequence_request(sequence_id: int) -> void:
    self._get_stage().set_interactables_disabled(true)
    %DialogTextLabel.start_sequence(sequence_id)
    %DialogTextLabel.set_physics_process(true)
    %InventoryContent.visible = false

#endregion


#region simple_events
func _on_options_pressed() -> void:
    $OptionsDialog.show()


func _on_back_pressed() -> void:
    %PauseMenu.visible = false


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        %PauseMenu.visible = not %PauseMenu.visible


func _on_return_to_title_pressed() -> void:
    %LoseProgressConfirmationDialog.show()


func _on_lose_progress_confirmation_dialog_visibility_changed() -> void:
    %LoseProgressConfirmationDialog.size = Vector2i(457, 106) * $OptionsDialog._config.get_value(
        "interface", "scale")
    %LoseProgressConfirmationDialog.move_to_center()


var _dialog_process_stack: Array[bool] = []
func _on_pause_menu_visibility_changed() -> void:
    if %PauseMenu.visible:
        self._dialog_process_stack.push_front(
            %DialogTextLabel.is_physics_processing())
        %DialogTextLabel.set_physics_process(false)
    else:
        %DialogTextLabel.set_physics_process(
            self._dialog_process_stack.pop_front())


func _on_options_dialog_confirmed() -> void:
    self._on_size_changed()


func _on_lose_progress_confirmation_dialog_confirmed() -> void:
    get_tree().change_scene_to_file("res://scenes/title.tscn")

#endregion
