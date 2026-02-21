extends CharacterBody2D

const SPEED := 220.0
const INPUT_THRESHOLD := 0.15

const ATTACK_INPUTS := {
	"attack_pi": "pi",
	"attack_dian": "dian",
	"attack_liao": "liao",
	"attack_gua": "gua",
	"attack_beng": "beng"
}

@onready var _sword := $Sword

func _physics_process(_delta: float) -> void:
	var move_vector := _get_move_vector()
	velocity = move_vector * SPEED
	move_and_slide()

	if _sword:
		_sword.update_move_direction(move_vector)
		_handle_attack_inputs()

func _get_move_vector() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
		dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W):
		dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		dir.y += 1.0

	if dir.length() < INPUT_THRESHOLD:
		return Vector2.ZERO

	return dir.normalized()

func _handle_attack_inputs() -> void:
	for action_name in ATTACK_INPUTS.keys():
		if Input.is_action_just_pressed(action_name):
			_sword.queue_attack(ATTACK_INPUTS[action_name])
