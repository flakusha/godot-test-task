extends Button

func _on_Rotate_Right_pressed():
	UiSignals.emit_signal("rotate_right")
