extends Area2D

signal queue_updated(queue: PackedStringArray)
signal action_started(action_id: String, display_name: String)
signal action_finished(action_id: String, display_name: String)

const HOLD_DISTANCE := 26.0
const RETURN_TO_HELD_DELAY := 0.75

enum Stage { IDLE, MOVING_TO_START, SWINGING, RECOVERING, RETURNING }

const POSES := {
	"OVERHEAD": {"pos": Vector2(0, -36), "rot": -PI / 2},
	"LOW_FRONT": {"pos": Vector2(6, 32), "rot": PI / 2},
	"FORWARD": {"pos": Vector2(34, -4), "rot": 0.0},
	"BLOCK": {"pos": Vector2(-8, 22), "rot": 2.45}
}

const ACTIONS := {
	"pi": {
		"display": "劈",
		"start_pose": "OVERHEAD",
		"end_pose": "LOW_FRONT",
		"prep": 0.18,
		"attack": 0.22,
		"recover": 0.18,
		"damage": 1
	},
	"dian": {
		"display": "点",
		"start_pose": "HELD",
		"end_pose": "FORWARD",
		"prep": 0.12,
		"attack": 0.18,
		"recover": 0.16,
		"damage": 1
	},
	"liao": {
		"display": "撩",
		"start_pose": "LOW_FRONT",
		"end_pose": "OVERHEAD",
		"prep": 0.14,
		"attack": 0.2,
		"recover": 0.16,
		"damage": 1
	},
	"gua": {
		"display": "挂",
		"start_pose": "BLOCK",
		"end_pose": "BLOCK",
		"prep": 0.1,
		"attack": 0.18,
		"recover": 0.24,
		"damage": 1
	},
	"beng": {
		"display": "崩",
		"start_pose": "LOW_FRONT",
		"end_pose": "BLOCK",
		"prep": 0.16,
		"attack": 0.22,
		"recover": 0.2,
		"damage": 1
	}
}

var _held_direction: Vector2 = Vector2.RIGHT
var _current_pose_name: String = "HELD"
var _stage: Stage = Stage.IDLE
var _stage_time := 0.0
var _stage_duration := 0.01
var _stage_start_pose: Dictionary = {"pos": Vector2.ZERO, "rot": 0.0}
var _stage_target_pose: Dictionary = {"pos": Vector2.ZERO, "rot": 0.0}
var _queued_actions: Array[String] = []
var _current_action_id: String = ""
var _current_action: Dictionary = {}
var _recover_timer := 0.0
var _time_since_action := 0.0

func _ready() -> void:
	_apply_pose(_resolve_pose("HELD"))

func _physics_process(delta: float) -> void:
	match _stage:
		Stage.IDLE:
			_time_since_action += delta
			if not _queued_actions.is_empty():
				_start_next_action()
				return
			if _time_since_action >= RETURN_TO_HELD_DELAY and _current_pose_name != "HELD":
				_start_return_to_held()
			elif _current_pose_name == "HELD":
				_apply_pose(_resolve_pose("HELD"))
		Stage.MOVING_TO_START, Stage.SWINGING, Stage.RETURNING:
			var previous_stage := _stage
			var finished := _advance_stage(delta)
			if finished:
				match previous_stage:
					Stage.MOVING_TO_START:
						_start_attack_swing()
					Stage.SWINGING:
						_start_recovery()
					Stage.RETURNING:
						_current_pose_name = "HELD"
						_stage = Stage.IDLE
		Stage.RECOVERING:
			_recover_timer -= delta
			if _recover_timer <= 0.0:
				_finish_action()

func update_move_direction(direction: Vector2) -> void:
	if direction.length() > 0.05:
		_held_direction = direction.normalized()
	if _stage == Stage.IDLE and _current_pose_name == "HELD":
		_apply_pose(_resolve_pose("HELD"))

func queue_attack(action_id: String) -> void:
	if not ACTIONS.has(action_id):
		return
	_queued_actions.append(action_id)
	emit_signal("queue_updated", _build_queue_display())
	if _stage == Stage.IDLE:
		_start_next_action()

func _start_next_action() -> void:
	if _queued_actions.is_empty() or _stage != Stage.IDLE:
		return
	var next_action_id: String = _queued_actions[0]
	_queued_actions.remove_at(0)
	_current_action_id = next_action_id
	_current_action = ACTIONS.get(_current_action_id, {})
	emit_signal("queue_updated", _build_queue_display())
	if _current_action.is_empty():
		_stage = Stage.IDLE
		return
	_stage = Stage.MOVING_TO_START
	_stage_time = 0.0
	_stage_duration = max(_current_action.get("prep", 0.1), 0.01)
	_stage_start_pose = {"pos": position, "rot": rotation}
	_stage_target_pose = _resolve_pose(_current_action.get("start_pose", "HELD"))
	emit_signal("action_started", _current_action_id, _current_action.get("display", ""))

func _start_attack_swing() -> void:
	_stage = Stage.SWINGING
	_stage_time = 0.0
	_stage_duration = max(_current_action.get("attack", 0.1), 0.01)
	_stage_start_pose = {"pos": position, "rot": rotation}
	_stage_target_pose = _resolve_pose(_current_action.get("end_pose", "HELD"))

func _start_recovery() -> void:
	_stage = Stage.RECOVERING
	_current_pose_name = _current_action.get("end_pose", "HELD")
	_recover_timer = _current_action.get("recover", 0.15)
	_apply_pose(_resolve_pose(_current_pose_name))

func _finish_action() -> void:
	var display_name: String = str(_current_action.get("display", ""))
	var action_id: String = _current_action_id
	_current_action_id = ""
	_current_action = {}
	_stage = Stage.IDLE
	_time_since_action = 0.0
	emit_signal("action_finished", action_id, display_name)
	emit_signal("queue_updated", _build_queue_display())
	if not _queued_actions.is_empty():
		_start_next_action()

func _start_return_to_held() -> void:
	_stage = Stage.RETURNING
	_stage_time = 0.0
	_stage_duration = 0.18
	_stage_start_pose = {"pos": position, "rot": rotation}
	_stage_target_pose = _resolve_pose("HELD")

func _advance_stage(delta: float) -> bool:
	_stage_time += delta
	var progress: float = clamp(_stage_time / _stage_duration, 0.0, 1.0)
	var start_pos: Vector2 = (_stage_start_pose.get("pos", position) as Vector2)
	var end_pos: Vector2 = (_stage_target_pose.get("pos", position) as Vector2)
	var start_rot: float = float(_stage_start_pose.get("rot", rotation))
	var end_rot: float = float(_stage_target_pose.get("rot", rotation))
	position = start_pos.lerp(end_pos, progress)
	rotation = lerp_angle(start_rot, end_rot, progress)
	return progress >= 1.0

func _resolve_pose(name: String) -> Dictionary:
	if name == "HELD":
		var dir := _held_direction
		if dir.length() <= 0.01:
			dir = Vector2.RIGHT
		return {"pos": dir * HOLD_DISTANCE, "rot": dir.angle()}
	return POSES.get(name, {"pos": Vector2.RIGHT * HOLD_DISTANCE, "rot": 0.0})

func _apply_pose(pose: Dictionary) -> void:
	var target_pos: Vector2 = (pose.get("pos", Vector2.ZERO) as Vector2)
	var target_rot: float = float(pose.get("rot", 0.0))
	position = target_pos
	rotation = target_rot

func _build_queue_display() -> PackedStringArray:
	var result: PackedStringArray = []
	for id in _queued_actions:
		var data: Dictionary = ACTIONS.get(id, {})
		var label: String = str(data.get("display", ""))
		if label == "":
			label = id
		result.append(label)
	return result
