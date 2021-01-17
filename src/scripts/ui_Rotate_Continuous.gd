extends CheckBox

func _on_Rotate_Continuous_toggled(button_pressed):
	UiSignals.emit_signal("continuous_rotation", button_pressed)

func _on_Rotate_Continuous_pressed():
	UiSignals.emit_signal("continuous_rotation_pr")
