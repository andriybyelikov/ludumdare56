extends ConfirmationDialog


const CONFIG_PATH: String = "user://config.cfg"


const ASPECT_RATIOS = [
    "16:9",
    "16:10",
    "21:9",
    "21.5:9",
    "32:9",
    "5:4",
]


const RESOLUTIONS: Array[Vector2i] = [
    Vector2i(960, 540),
    Vector2i(1280, 720),
    Vector2i(1360, 768),
    Vector2i(1366, 768),
    Vector2i(1600, 900),
    Vector2i(1920, 1080),
    Vector2i(2560, 1440),
    Vector2i(3840, 2160),
    Vector2i(1280, 800),
    Vector2i(1440, 900),
    Vector2i(1680, 1050),
    Vector2i(1920, 1200),
    Vector2i(2560, 1600),
    Vector2i(2880, 1800),
    Vector2i(1280, 1024),
    Vector2i(2560, 1080),
    Vector2i(3440, 1440),
    Vector2i(5120, 1440),
]


var resolution_dict: Dictionary


func init_resolutions() -> void:
    resolution_dict = {}
    
    var screen_resolution: Vector2i = DisplayServer.screen_get_size()
    for resolution in RESOLUTIONS:
        if not (
            resolution.x <= screen_resolution.x
        and resolution.y <= screen_resolution.y):
            continue
        
        var aspect_ratio: float = resolution.x / float(resolution.y)
        for aspect_ratio_key in ASPECT_RATIOS:
            var aspect_ratio_split: PackedStringArray = (
                aspect_ratio_key.split(":"))
            var w: float = float(aspect_ratio_split[0])
            var h: float = float(aspect_ratio_split[1])
            var a: float = w / h
            if abs(a - aspect_ratio) < 0.01:
                if not resolution_dict.has(aspect_ratio_key):
                    resolution_dict[aspect_ratio_key] = {}
                resolution_dict[aspect_ratio_key]["{width}×{height}".format({
                    "width": resolution.x,
                    "height": resolution.y,
                })] = resolution

    for aspect_ratio_key in resolution_dict:
        %AspectRatioOptionButton.add_item(aspect_ratio_key)
    
    _on_aspect_ratio_option_button_item_selected(0)


var _config: ConfigFile


func dump_gui_to_config() -> void:
    #region interface
    self._config.set_value("interface", "language",
        %InterfaceLanguageOptionButton.selected)
    self._config.set_value("interface", "text_speed",
        int(%TextSpeedSpinBox.value))
    self._config.set_value("interface", "scale",
        int(%ScaleSpinBox.value))
    #endregion
    #region video
    self._config.set_value("video", "full_screen_mode",
        %FullScreenModeCheckBox.button_pressed)
    var resolution_text_split: PackedStringArray = (
        %ResolutionOptionButton.text.split("×"))
    self._config.set_value("video", "resolution_w",
        int(resolution_text_split[0]))
    self._config.set_value("video", "resolution_h",
        int(resolution_text_split[1]))
    self._config.set_value("video", "vsync",
        %VSyncCheckBox.button_pressed)
    #endregion
    #region audio
    self._config.set_value("audio", "language",
        %AudioLanguageOptionButton.selected)
    #endregion
    
    
func dump_config_to_gui() -> void:
    #region interface
    %ScaleSpinBox.value = self._config.get_value(
        "interface", "scale")
    #endregion
    #region video
    %FullScreenModeCheckBox.button_pressed = self._config.get_value(
        "video", "full_screen_mode")
    %AspectRatioOptionButton.disabled = self._config.get_value(
        "video", "full_screen_mode")
    %ResolutionOptionButton.disabled = self._config.get_value(
        "video", "full_screen_mode")
    %VSyncCheckBox.button_pressed = self._config.get_value(
        "video", "vsync")
    #endregion
    
    
func scale_theme(scale: int) -> void:
    var theme: Theme = ThemeDB.get_project_theme()
    theme.default_font_size = 16 * scale
    theme.set_font_size("font_size", "Title", 80 * scale)
    
    theme.set_constant("margin_bottom", "Margin16", 16 * scale)
    theme.set_constant("margin_left", "Margin16", 16 * scale)
    theme.set_constant("margin_right", "Margin16", 16 * scale)
    theme.set_constant("margin_top", "Margin16", 16 * scale)
    
    theme.set_constant("margin_bottom", "Margin8", 8 * scale)
    theme.set_constant("margin_left", "Margin8", 8 * scale)
    theme.set_constant("margin_right", "Margin8", 8 * scale)
    theme.set_constant("margin_top", "Margin8", 8 * scale)
    
    theme.get_stylebox("embedded_border", "Window").expand_margin_top = 32 * scale
    theme.set_constant("title_height", "Window", 36 * scale)
    theme.set_constant("close_v_offset", "Window", 24 * scale)
    theme.set_font_size("font_size", "TextMiddle", 32 * scale)
    theme.set_font_size("font_size", "DialogText", 24 * scale)
    theme.set_font_size("font_size", "TextSmall", 12 * scale)
    theme.set_constant("separation", "StatusContainer", 32 * scale)
    theme.get_stylebox("panel", "AutosaveIndicatorPanel").corner_radius_top_left = 8 * scale
    theme.get_stylebox("panel", "AutosaveIndicatorPanel").corner_radius_top_right = 8 * scale
    self.size = Vector2i(480 * scale, 360 * scale)
    
    
func apply_configuration() -> void:
    if self._config.get_value("video", "full_screen_mode"):
        DisplayServer.window_set_mode(
            DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
        # do not set resolution on exclusive full screen mod
    else:
        DisplayServer.window_set_mode(
            DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
        # set resolution on windowed mode
        get_tree().root.size = Vector2i(
            int(self._config.get_value("video", "resolution_w")),
            int(self._config.get_value("video", "resolution_h")))
    
    if self._config.get_value("video", "vsync"):
        DisplayServer.window_set_vsync_mode(
            DisplayServer.VSyncMode.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(
            DisplayServer.VSyncMode.VSYNC_DISABLED)
    
    var scale: int = int(%ScaleSpinBox.value)
    if scale == 0:
        self._on_size_changed()
    else:
        self.scale_theme(int(%ScaleSpinBox.value))
    
    
func _ready() -> void:
    # delay applying the theme scale on boot so that the
    # correct resolution is detected after resizing
    get_tree().root.connect("size_changed", _on_size_changed)
    init_resolutions()
    
    self._config = ConfigFile.new()
    if self._config.load(CONFIG_PATH) != OK:
        self.dump_gui_to_config()
        self._config.save(CONFIG_PATH)
    else:
        self.dump_config_to_gui()
    
    self.apply_configuration()
    
    %InterfaceLanguageOptionButton.grab_focus()


func get_max_scale() -> int:
    var viewport_height: int = get_tree().root.size.y
    var default_height: int = ProjectSettings.get_setting(
            "display/window/size/viewport_height")
    var max_scale: int = viewport_height / default_height
    return max_scale


func get_scale() -> int:
    var scale: int = int(%ScaleSpinBox.value)
    if scale == 0:
        scale = self.get_max_scale()
    return scale

    
func _on_size_changed() -> void:
    var max_scale: int = self.get_max_scale()
    %ScaleSpinBox.max_value = max_scale
    
    var scale: int = int(%ScaleSpinBox.value)
    
    # auto scale
    if scale == 0 or scale > max_scale:
        self.scale_theme(max_scale)


func _on_confirmed() -> void:
    self.dump_gui_to_config()
    self.apply_configuration()
    self._config.save(CONFIG_PATH)
    
    
func _on_canceled() -> void:
    self.dump_config_to_gui()


func _on_aspect_ratio_option_button_item_selected(index: int) -> void:
    %ResolutionOptionButton.clear()
    for resolution in resolution_dict[
        %AspectRatioOptionButton.get_item_text(index)]:
        %ResolutionOptionButton.add_item(resolution)


func _on_full_screen_mode_check_box_toggled(toggled_on: bool) -> void:
    %AspectRatioOptionButton.disabled = toggled_on
    %ResolutionOptionButton.disabled = toggled_on


func get_aspect_ratio() -> float:
    var ratio_string_split: PackedStringArray = (
        %AspectRatioOptionButton.get_item_text(
            %AspectRatioOptionButton.selected
    )).split(":")
    return float(ratio_string_split[0]) / float(ratio_string_split[1])
