extends Node
class_name Visualizer


@export var logo: Control
@export var output_player: AudioStreamPlayer
@export var capture_player: AudioStreamPlayer
@export var block_size: int = 4400

@export var input_device_option_button: OptionButton

@export var volume_cache_interval: float = 0.05
@export var volume_cache_size: int = 1
@export var lerp_duration: float = 0.05

@export var debug_label: Label
@export var debug_ui: Control

@export var init_volume_range: Vector2 = Vector2(-150, 1)
@export var init_scale_range: Vector2 = Vector2(0.75, 1.1)

@export var volume_range_editor: Vector2Editor
@export var scale_range_editor: Vector2Editor

@export var theme: Control
@export var attendance_qr: Control

var output_playback: AudioStreamGeneratorPlayback
var volume_cache = []
var volume_cache_timer: float = 0
var average_volume: float = 0
var min_volume: float = INF
var max_volume: float = -INF

var lerp_volume: float = 1
var lerp_start_volume: float = 1
var lerp_timer: float = 0

var capture_bus_idx: int
var capture_effect: AudioEffectCapture

var volume_range: Vector2 :
	get():
		return volume_range_editor.value
var scale_range: Vector2 :
	get():
		return scale_range_editor.value


func _ready() -> void:
	capture_bus_idx = AudioServer.get_bus_index("Capture")
	capture_effect = AudioServer.get_bus_effect(capture_bus_idx, 0)
	output_playback = output_player.get_stream_playback()
	
	var input_devices = AudioServer.get_input_device_list()
	input_device_option_button.item_selected.connect(_on_input_device_selected)
	for device in input_devices:
		input_device_option_button.add_item(device.substr(0, 30))
		input_device_option_button.set_item_metadata(input_device_option_button.item_count - 1, device)
	
	debug_ui.visible = false
	
	volume_range_editor.value = init_volume_range
	scale_range_editor.value = init_scale_range


func _on_input_device_selected(index: int):
	var device = input_device_option_button.get_item_metadata(index)
	AudioServer.input_device = device


func _process(delta: float) -> void:
	#while capture_effect.can_get_buffer(block_size) and output_playback.can_push_buffer(block_size):
		#output_playback.push_buffer(capture_effect.get_buffer(block_size))
	if volume_cache_timer >= 0:
		volume_cache_timer -= delta
		if volume_cache_timer < 0:
			var volume = AudioServer.get_bus_peak_volume_left_db(capture_bus_idx, 0)
			if volume < min_volume:
				min_volume = volume
			if volume > max_volume:
				max_volume = volume
			volume_cache.append(volume)
			if len(volume_cache) > volume_cache_size:
				volume_cache.pop_front()
			while volume_cache_timer < 0:
				volume_cache_timer += volume_cache_interval
			
			average_volume = 0
			for cached_volume in volume_cache:
				average_volume += cached_volume
			average_volume /= len(volume_cache)
			
			lerp_start_volume = lerp_volume
			lerp_timer = 0
	
	if lerp_timer < lerp_duration:
		lerp_timer += delta
	debug_label.text = "MIN: %s MAX: %s\nLERP: %s" % [min_volume, max_volume, lerp_volume]
	lerp_volume = lerpf(lerp_start_volume, average_volume, min(1, lerp_timer / lerp_duration))
	logo.scale = Vector2.ONE * remap(clamp(lerp_volume, min_volume * 0.1, max_volume), min_volume * 0.1, max_volume, scale_range.x, scale_range.y) 

	if Input.is_action_just_pressed("debug"):
		debug_ui.visible = not debug_ui.visible
	
	if Input.is_action_just_pressed("fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN
	
	if Input.is_action_just_pressed("reveal"):
		theme.visible = not theme.visible

	if Input.is_action_just_pressed("qr"):
		attendance_qr.visible = not attendance_qr.visible
