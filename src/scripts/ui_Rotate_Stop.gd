extends Button

func _ready():
	UiSignals.connect("continuous_rotation_pr", self, "on_continuous_toggle")

func _on_Rotate_Stop_pressed():
	UiSignals.emit_signal("rotate_stop")

# Button is disabled, unless it's continuous rotation mode.
# Кнопка отключена, когда не включен режим продолжительного вращения.
func on_continuous_toggle():
	if self.get_parent().get_parent().\
	get_node("Ticks/Rotate_Continuous").pressed:
		self.disabled = false
	else:
		self.disabled = true
