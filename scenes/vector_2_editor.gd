@tool
extends VBoxContainer
class_name Vector2Editor


signal value_changed(value: Vector2)


enum Mode {
	X_Y,
	MIN_MAX,
}

@export var value: Vector2 :
	get:
		return _value
	set(v):
		_value = v
		if readied:
			x_spinbox.value = v.x
			y_spinbox.value = v.y
var _value: Vector2

@export var mode: Mode = Mode.X_Y :
	set(value):
		mode = value
		if readied:
			if mode == Mode.X_Y:
				x_spinbox.prefix = "x:"
				y_spinbox.prefix = "y:"
			elif mode == Mode.MIN_MAX:
				x_spinbox.prefix = "min:"
				y_spinbox.prefix = "max:"
@export var label_text: String :
	set(value):
		label_text = value
		if readied:
			label.text = label_text

@onready var x_spinbox: SpinBox = $HBoxContainer/XSpinBox
@onready var y_spinbox: SpinBox = $HBoxContainer/YSpinBox
@onready var label: Label = $Label

var readied = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	readied = true
	x_spinbox.value_changed.connect(_on_spinbox_changed.unbind(1))
	y_spinbox.value_changed.connect(_on_spinbox_changed.unbind(1))
	mode = mode
	label_text = label_text
	value = value


func _on_spinbox_changed():
	_value.x = x_spinbox.value
	_value.y = y_spinbox.value
	value_changed.emit(value)
