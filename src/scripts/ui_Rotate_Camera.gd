extends CheckBox

func _on_Rotate_Camera_toggled(button_pressed):
	UiSignals.emit_signal("camera_switch_rotation", button_pressed)
