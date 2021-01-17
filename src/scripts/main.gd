extends Spatial

# Float comparison accuracy.
# Точность сравнения float значений.
const EPSILON: float = 0.0001
# Transform matrix default (IDENTITY).
# Стандартное значение матрицы объекта.
const DEF_MAT: Transform = Transform()
# Object or camera can be in one of this states: no rotation, rotating left,
# rotating right.
# Объект или камера в текущий момент времени могут быть только в одном из данных
# состояний: нет вращения, вращение влево, вращение вправо.
enum RotationDir {
	STOP,
	LEFT,
	RIGHT,
}
# Select object or camera for rotation.
# Выбрать объект для вращения: модель или камеру.
enum RotationObj {
	OBJECT,
	CAMERA,
}
# Object or camera can rotate using steps or continuously.
# Модель или камера могут вращаться пошагово или продолжительно.
enum RotationMode {
	STEP,
	CONTINUOUS,
}

var rot_speed: float = deg2rad(1)
var rot_speed_c: float = rot_speed * 10.0
var rotation_dir: int = RotationDir["STOP"]
var rotation_obj: int = RotationObj["OBJECT"]
var rotation_mode: int = RotationMode["STEP"]
var rotation_node: Spatial

# There is one scene to load at the moment,
# it's possible just to preload it.
# Т.к. в данный момент существует только одна сцена для загрузки, можно
# выполнить её предзагрузку в память.
var MODEL_SPACESHIP := preload("res://src/scenes/model_spaceship.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# NOTE initial setup in class definition
	# self.rotation_dir = RotationDir["STOP"]
	# self.rotation_obj = RotationObj["OBJECT"]
	self.rotation_node = self.get_node("model_root")

	UiSignals.connect("load_model", self, "on_model_load")
	UiSignals.connect("continuous_rotation", self, "set_continuous_rotation")
	UiSignals.connect("camera_switch_rotation", self, "switch_rotating_obj")
	UiSignals.connect("rotate_left", self, "on_rotate_left")
	UiSignals.connect("rotate_right", self, "on_rotate_right")
	UiSignals.connect("rotate_stop", self, "on_rotate_stop")

# Adds instance of model scene under "model_root" Spatial node.
# Добавляет экземпляр сцены с моделью под Пространственный (Spatial)
# узел "model_root".
func on_model_load():
	var scene_loaded = MODEL_SPACESHIP.instance()
	# Get model's longest axis using AABB.
	# Получить наибольший размер модели по ограничивающему параллелепипеду.
	var longest_axis_i: int = scene_loaded.get_child(0).get_aabb().\
		get_longest_axis_index()
	# Move camera away from model for AABB biggest size and additional distance.
	# Передвинуть камеру из центра сцены на величину большего размера +
	# дополнительной дистанции.
	var translate_pos: float = scene_loaded.get_child(0).get_aabb().\
		size[longest_axis_i] + 1.0
	print_debug(longest_axis_i, " ", translate_pos)
	var camera = self.get_node("camera_root").get_node("Camera")
	if not is_close(camera.translation, Vector3(0, 0, translate_pos)):
		camera.transform =\
			camera.transform.translated(Vector3(0, 0, translate_pos))
	print_debug(camera.transform)

	# Add model into the scene, remove models from node if present.
	# This is needed in case other models will be added in future.
	# Добавить новую модель, если в узле уже есть модели, удалить их.
	# Это нужно только для того, чтобы добавлять
	# какие-то новые модели в будущем.
	if self.get_node("model_root").get_child_count() > 0:
		for child in self.get_node("model_root").get_children():
			child.queue_free()

	self.get_node("model_root").add_child(scene_loaded)
	print_debug("Model is loaded")
	# print_tree_pretty()

func set_continuous_rotation(mode: bool):
	self.rotation_dir = RotationDir["STOP"]

	if mode:
		self.rotation_mode = RotationMode["CONTINUOUS"]
	elif not mode:
		self.rotation_mode = RotationMode["STEP"]

func switch_rotating_obj(mode: bool):
	self.rotation_dir = RotationDir["STOP"]

	if mode:
		self.rotation_obj = RotationObj["CAMERA"]
		self.rotation_node = self.get_node("camera_root")
		print_debug("Camera is rotating")
		print_debug(self.rotation_node.name)
	elif not mode:
		self.rotation_obj = RotationObj["OBJECT"]
		self.rotation_node = self.get_node("model_root")
		print_debug("Model is rotating")
		print_debug(self.rotation_node.name)

func on_rotate_left():
	if self.rotation_mode == 0 and rotation_node.get_child_count() > 0:
		self.rotation_node.transform = self.rotation_node.transform.rotated(
			Vector3(0, 1, 0), -rot_speed * 10)
	elif self.rotation_mode == 1:
		self.rotation_dir = RotationDir["LEFT"]

func on_rotate_right():
	if self.rotation_mode == 0 and rotation_node.get_child_count() > 0:
		self.rotation_node.transform = self.rotation_node.transform.rotated(
			Vector3(0, 1, 0), rot_speed * 10)
	elif self.rotation_mode == 1:
		self.rotation_dir = RotationDir["RIGHT"]

func on_rotate_stop():
	self.rotation_dir = RotationDir["STOP"]

# Float comparison function.
# Функция для сравнения float значений.
static func is_close(v0, v1, eps: float = EPSILON):
	if typeof(v0) == TYPE_REAL and typeof(v1) == TYPE_REAL:
		return abs(v0 - v1) <= eps
	elif typeof(v0) == TYPE_VECTOR3 and typeof(v1) == TYPE_VECTOR3:
		var res := [false, false, false]
		for index in range(3):
			res[index] = is_close(v0[index], v1[index], eps)
		if false in res:
			return false
		else:
			return true
	else:
		return ERR_INVALID_PARAMETER

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Physics process is not called every frame.
# Check conditions and rotate model accordingly.__data__
# Физ процесс не выполняется каждый кадр.
# Проверять условия и выполнять вращение.
# Альтернативно процесс можно реализовать в функции, не завязанной на delta,
# использовать таймер для поворота через короткие промежутки времени. 
func _physics_process(delta):
	# RotationDir["STOP"], RotationMode["CONTINUOUS"]
	if self.rotation_dir != 0 and self.rotation_mode != 0:
		if self.get_node("model_root").get_child_count() > 0:
			if self.rotation_dir == 1: # RotationDir["LEFT"]
				self.rotation_node.transform =\
					self.rotation_node.transform.rotated(
						Vector3(0, 1, 0), -self.rot_speed_c * delta)
			elif self.rotation_dir == 2: # RotationDir["RIGHT"]
				self.rotation_node.transform =\
					self.rotation_node.transform.rotated(
						Vector3(0, 1, 0), self.rot_speed_c * delta)
