extends Button

func _on_Rotate_Left_pressed():
	UiSignals.emit_signal("rotate_left")
