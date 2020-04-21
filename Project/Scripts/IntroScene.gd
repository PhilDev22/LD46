extends Node2D


var main_scene
var allow_input = false
var time = 0.0
var time_max = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("IntroSequence")

func _input(event):
	if allow_input:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				_load_main_scene()
		elif event is InputEventKey:
			if event.is_action_pressed("ui_select"):
				_load_main_scene()

func _process(delta):
	time += delta
	if time >= time_max:
		allow_input = true

func _load_main_scene():
	queue_free()

