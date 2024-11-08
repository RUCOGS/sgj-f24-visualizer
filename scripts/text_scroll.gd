extends Control
class_name TextScroll


@export var speed: float
@export var padding: float
@export var text_count: int = 10

var children: Array[Control]

@onready var label_container = $LabelContainer


func _ready() -> void:
	if label_container.get_child_count() < 1:
		printerr("TextScroll expects >= 1 child")
		return
	var template = label_container.get_child(0)
	if label_container.get_child_count() > text_count:
		# remove extra children
		for i in range(label_container.get_child_count() - text_count):
			label_container.get_child(i).queue_free()
	for i in range(text_count - label_container.get_child_count()):
		label_container.add_child(template.duplicate())
	
	children = []
	children.append_array(label_container.get_children())
	var curr_x: float = 0
	for child in children:
		child.position = Vector2(curr_x, 0)
		curr_x += child.size.x + padding
	label_container.size.y = 64
	label_container.size.x = curr_x
	label_container.position = Vector2(-label_container.size.x / 2, 0)


func _process(delta: float) -> void:
	for child in children:
		child.position.x += delta * speed
		if speed > 0 and child.position.x > label_container.size.x:
			child.position.x = 0
		elif speed < 0 and child.position.x < 0:
			child.position.x = label_container.size.x
