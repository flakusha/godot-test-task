extends Button

func _on_Load_Model_pressed():
	UiSignals.emit_signal("load_model")
