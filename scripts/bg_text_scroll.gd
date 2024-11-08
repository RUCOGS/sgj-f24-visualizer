extends Control
class_name BGTextScroll


@export var text_scroll_container: VBoxContainer
@export var text_scroll: TextScroll
@export var rows: int = 10


func _ready() -> void:
	for i in range(rows - 1):
		text_scroll_container.add_child(text_scroll.duplicate())
	
	for i in rows:
		var curr_text_scroll: TextScroll = text_scroll_container.get_child(i)
		if i % 2 == 0:
			curr_text_scroll.speed *= -1
	
	#text_scroll_container.position.y = -text_scroll_container.size.y / 2
