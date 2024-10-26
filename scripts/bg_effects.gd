extends TextureRect


@export var shake: bool
@export_range(0, 10, 0.01, "or_greater", "or_less") var shake_intensity: float


var _original_position: Vector2i
var _time_accumulator: float


func _ready() -> void:
    self._original_position = self.position


func _physics_process(delta: float) -> void:
    if shake:
        self.position.x = self._original_position.x + sin(self._time_accumulator * self.shake_intensity * 16)
        self._time_accumulator += delta
