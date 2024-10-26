extends Control


func _ready() -> void:
    %ContinueButton.disabled = (%Save.save == null)
    %NewGameButton.grab_focus()
    
    
func _on_quit_pressed() -> void:
    get_tree().quit()


func _on_options_button_pressed() -> void:
    $OptionsDialog.show()


func _on_new_game_confirmation_dialog_confirmed() -> void:
    %Save.write_empty_save_data()
    %Save.write_save_file()
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_new_game_button_pressed() -> void:
    if %Save.save != null:
        %NewGameConfirmationDialog.show()
    else:
        _on_new_game_confirmation_dialog_confirmed()
    

func _on_new_game_confirmation_dialog_visibility_changed() -> void:
    %NewGameConfirmationDialog.size = Vector2i(521, 106) * $OptionsDialog._config.get_value(
        "interface", "scale")
    %NewGameConfirmationDialog.move_to_center()


func _on_continue_button_pressed() -> void:
    %Save.read_save_file()
    get_tree().change_scene_to_file("res://scenes/main.tscn")
