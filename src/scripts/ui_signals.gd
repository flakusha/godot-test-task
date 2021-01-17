extends Node

# UI signal for model loading.
# Сигнал из UI для загрузки модели.
signal load_model

# UI signal for continuous camera or object rotation. True == continuous.
# Сигнал из UI для продолжительного вращения камеры или объекта. 
signal continuous_rotation_pr
signal continuous_rotation(mode)

# UI signal to switch camera and object rotation.
# Сигнал из UI для переключения между вращением камеры и объекта.
signal camera_switch_rotation(mode)

# UI signal to rotate left.
# Сигнал из UI для вращения влево.
signal rotate_left

# UI signal to rotate right.
# Сигнал из UI для вращения вправо.
signal rotate_right

# UI signal to stop rotation.
# Сигнал из UI для прекращения вращения.
signal rotate_stop
