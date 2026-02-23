extends Node3D

@onready var _player := $Player
@onready var _queue_panel := $UI/QueuePanel
@onready var _callout_label := $UI/CalloutLabel

func _ready() -> void:
	if not _player:
		push_warning("Player node not found; UI will not update sword actions.")
		return
	var sword: Node = _player.get_node_or_null("ArmRight/SwordAnchor/Sword")
	if sword:
		sword.queue_updated.connect(_queue_panel.set_queue)
		sword.action_started.connect(_on_action_started)
		sword.action_finished.connect(_on_action_finished)
	_queue_panel.set_current_action("-")
	_queue_panel.set_queue(PackedStringArray())
	_callout_label.visible = false

func _on_action_started(_id: String, display_name: String) -> void:
	_queue_panel.set_current_action(display_name)

func _on_action_finished(_id: String, display_name: String) -> void:
	_queue_panel.set_current_action("-")
	_callout_label.show_move(display_name)
