extends CharacterBody3D

const SPEED := 6.0
const INPUT_THRESHOLD := 0.15
const CAMERA_SENSITIVITY := 0.0035
const MIN_PITCH := deg_to_rad(-65.0)
const MAX_PITCH := deg_to_rad(80.0)
const ZOOM_STEP := 0.12
const THIRD_PERSON_FOV := 70.0
const FIRST_PERSON_FOV := 55.0

const ATTACK_INPUTS := {
	"attack_pi": "pi",
	"attack_dian": "dian",
	"attack_liao": "liao",
	"attack_gua": "gua",
	"attack_beng": "beng"
}

@onready var _sword := $Sword
@onready var _camera_pivot: Node3D = $CameraRig/Pivot
@onready var _camera: Camera3D = $CameraRig/Pivot/Camera3D
@onready var _third_person_anchor: Node3D = $CameraRig/Pivot/ThirdPersonAnchor
@onready var _first_person_anchor: Node3D = $CameraRig/Pivot/FirstPersonAnchor

var _yaw := 0.0
var _pitch := -0.35
var _zoom_t := 0.0
var _third_person_offset := Vector3.ZERO
var _first_person_offset := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_third_person_offset = _third_person_anchor.position
	_first_person_offset = _first_person_anchor.position
	_update_camera()

func _physics_process(_delta: float) -> void:
	var move_input := _get_move_vector()
	var world_move := _to_world_direction(move_input)
	velocity.x = world_move.x * SPEED
	velocity.z = world_move.z * SPEED
	velocity.y = 0.0
	move_and_slide()

	rotation.y = _yaw

	if _sword:
		var aim_dir := -global_transform.basis.z.normalized()
		_sword.update_move_direction(aim_dir)
		_handle_attack_inputs()

	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw = wrapf(_yaw - event.relative.x * CAMERA_SENSITIVITY, -PI, PI)
		_pitch = clamp(_pitch - event.relative.y * CAMERA_SENSITIVITY, MIN_PITCH, MAX_PITCH)
		_update_camera()
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_adjust_zoom(ZOOM_STEP)
			MOUSE_BUTTON_WHEEL_DOWN:
				_adjust_zoom(-ZOOM_STEP)
			MOUSE_BUTTON_LEFT:
				if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _get_move_vector() -> Vector3:
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
		dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W):
		dir.z -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		dir.z += 1.0

	if dir.length() < INPUT_THRESHOLD:
		return Vector3.ZERO

	return dir.normalized()

func _to_world_direction(local_dir: Vector3) -> Vector3:
	if local_dir == Vector3.ZERO:
		return Vector3.ZERO
	var basis := Basis(Vector3.UP, _yaw)
	return basis * local_dir

func _handle_attack_inputs() -> void:
	for action_name in ATTACK_INPUTS.keys():
		if Input.is_action_just_pressed(action_name):
			_sword.queue_attack(ATTACK_INPUTS[action_name])

func _adjust_zoom(step: float) -> void:
	_zoom_t = clamp(_zoom_t + step, 0.0, 1.0)
	_update_camera()

func _update_camera() -> void:
	_camera_pivot.rotation.x = _pitch
	var target_offset := _third_person_offset.lerp(_first_person_offset, _zoom_t)
	_camera.position = target_offset
	_camera.fov = lerp(THIRD_PERSON_FOV, FIRST_PERSON_FOV, _zoom_t)
