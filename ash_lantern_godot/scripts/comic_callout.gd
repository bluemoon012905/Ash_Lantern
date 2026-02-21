extends Label

@export var hold_time := 0.9
var _tween: Tween

func show_move(text_value: String) -> void:
	if text_value == "":
		return
	text = text_value
	visible = true
	scale = Vector2.ONE
	modulate = Color.WHITE
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.18)
	_tween.tween_interval(max(hold_time - 0.18, 0.2))
	_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.finished.connect(func(): visible = false)
