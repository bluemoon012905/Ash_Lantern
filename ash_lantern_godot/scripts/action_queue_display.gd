extends PanelContainer

@onready var _current_label: Label = $VBoxContainer/CurrentActionLabel
@onready var _queue_label: Label = $VBoxContainer/QueueLabel

func set_current_action(label_text: String) -> void:
	var text := label_text if label_text != "" else "-"
	_current_label.text = "当前: %s" % text

func set_queue(queue: PackedStringArray) -> void:
	if queue.is_empty():
		_queue_label.text = "队列: (空)"
	else:
		var queue_text: String = _join_labels(queue, " ")
		_queue_label.text = "队列: %s" % queue_text

func _join_labels(values: PackedStringArray, separator: String) -> String:
	var builder := ""
	for i in range(values.size()):
		builder += values[i]
		if i < values.size() - 1:
			builder += separator
	return builder
