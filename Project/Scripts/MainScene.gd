extends Node2D

const PLAY_INTRO = true
const LEVEL_TIME_MAX = 30.0
const SPAWN_POS_LEFT = -50
const SPAWN_POS_RIGHT = 1070
const SPAWN_RANGE_Y = 320
const SPAWN_TIME_INITIAL = 1.5
const SPAWN_TIME_INTERVAL = 0.08
const SPAWN_TIME_MIN = 0.2
const START_SPAWN_SPEED = 150
const SPAWN_SPEED_INTERVAL = 17
const SPAWN_SPEED_MAX = 400
const START_FOOD_MAX = 4
const START_BONES = 5
const BONES_COUNT_MAX = 10

onready var node_intro = get_node("IntroScene")
onready var node_gui = get_node("GUI")
onready var node_label_info = get_node("GUI/LabelInfo")
onready var node_birds = get_node("Birds")
onready var node_food = get_node("DropsFood")
onready var node_bones = get_node("DropsBones")
onready var node_player = get_node("Player")
onready var node_doggo = get_node("Doggo")

onready var scene_bird1 = load("res://Scenes/Bird1.tscn")
onready var scene_food = load("res://Scenes/Food.tscn")
onready var scene_egg = load("res://Scenes/Egg.tscn")
onready var scene_bone = load("res://Scenes/Bone.tscn")

var rng = RandomNumberGenerator.new()
var intro_ended = false
var spawn_time = SPAWN_TIME_INITIAL
var spawn_timer = 0.0
var spawn_speed = START_SPAWN_SPEED
var rand_y_pos
var bones_count = 3
var level_time = LEVEL_TIME_MAX
var food_count = 0
var food_max = START_FOOD_MAX
var game_over = false
var game_over_processed = false
var level_completed = true
var level_nr = 0
var show_dialog_level_complete = false
var start_new_level = false
var block_input = false
var block_input_time = 1.0
var block_input_time_max = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	node_intro.visible = true
	if not PLAY_INTRO:
		node_intro.queue_free()
	
	$DropsBones.visible = false
	level_completed = true # show dialog "Level 1"
	node_gui.update_gui_bones(bones_count)
	node_gui.update_gui_food(food_count, food_max)
	node_gui.update_gui_time(level_time)
	_show_dialog_level_complete()

func _input(event):
	if intro_ended and not block_input:
		if game_over:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT and event.pressed:
					node_label_info.hide_label()
					_restart()
			elif event is InputEventKey:
				if event.is_action_pressed("ui_select"):
					_restart()
		elif level_completed:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT and event.pressed:
					node_label_info.hide_label()
					start_new_level = true
			elif event is InputEventKey:
				if event.is_action_pressed("ui_select"):
					start_new_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if intro_ended:
		if not level_completed and not game_over:
			level_time -= delta
			if level_time <= 0.0:
				level_time = 0.0
				if food_count >= food_max:
					level_completed = true
					show_dialog_level_complete = true
				else:
					game_over = true
					
			node_gui.update_gui_time(level_time)
			_spawn_birds(delta)
		else:
			
			if not game_over: # level completed
				
				if show_dialog_level_complete:
					node_doggo.stop()
					node_doggo.show_heart_animation()
					_clear_food()
					_clear_birds()
					_show_dialog_level_complete()
					show_dialog_level_complete = false
		
				elif start_new_level: # start new level
					node_label_info.hide_label()
					start_new_level = false
					level_nr += 1
					_init_level(level_nr)
					
			else: # game over
				if not game_over_processed:
					_process_game_over()
					
		if block_input:
			block_input_time -= delta
			if block_input_time <= 0:
				block_input = false


func _init_level(level):
	level_nr = level
	level_time = LEVEL_TIME_MAX
	food_count = 0
	
	if level == 1:
		food_max = START_FOOD_MAX
		spawn_speed = START_SPAWN_SPEED
		bones_count = START_BONES
		spawn_time = SPAWN_TIME_INITIAL
	else:
		food_max = START_FOOD_MAX + ((level - 1) * 2)
		spawn_speed = START_SPAWN_SPEED + ((level - 1) * SPAWN_SPEED_INTERVAL)
		if spawn_speed > SPAWN_SPEED_MAX:
			spawn_speed = SPAWN_SPEED_MAX
		spawn_time = SPAWN_TIME_INITIAL - ((level - 1) * SPAWN_TIME_INTERVAL)
		if spawn_time < SPAWN_TIME_MIN:
			spawn_time = SPAWN_TIME_MIN
	
	node_gui.update_gui_bones(bones_count)
	node_gui.update_gui_food(food_count, food_max)
	node_gui.update_gui_time(level_time)
	
	$DropsBones.visible = true
	
	game_over = false
	game_over_processed = false
	level_completed = false
	
	node_doggo.animation = "default"
	node_doggo.show_speechbubble_amount(food_max)


func _process_game_over():
	node_doggo.stop()
	node_doggo.animation = "dead"
	node_doggo.get_node("AudioWhine").play()
	_clear_bones()
	_clear_food()
	_clear_birds()
	_show_dialog_game_over()
	game_over_processed = true


func _restart():
	node_label_info.hide_label()
	_init_level(1)


func _spawn_birds(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_time:
		var rand_flip = rng.randi_range(0, 1)
		var rand_y_pos = rng.randf_range(100, SPAWN_RANGE_Y)
		var bird = scene_bird1.instance()
		bird.flip_h = bool(rand_flip)
		if bird.flip_h:
			bird.position = Vector2(SPAWN_POS_LEFT, rand_y_pos)
		else:
			bird.position = Vector2(SPAWN_POS_RIGHT, rand_y_pos)
		var type = 0	
		if level_nr >= 3:
			var type_range = 6
			if level_nr >= 8:
				type_range = 4
			elif level_nr >= 15:
				type_range = 2
			var rand = rng.randi_range(0, type_range - 1)
			if rand == 1:
				type = 1
		bird.init(self, spawn_speed, type)
		node_birds.add_child(bird)
		spawn_timer = 0.0
		
	# node_doggo.move_to(node_player.position, false)


func _clear_food():
	for i in range(0, node_food.get_child_count()):
		node_food.get_child(i).queue_free()


func _clear_bones():
	for i in range(0, node_bones.get_child_count()):
		node_bones.get_child(i).queue_free()


func _clear_birds():
	for i in range(0, node_birds.get_child_count()):
		node_birds.get_child(i).queue_free()


func _show_dialog_level_complete():
	block_input = true
	block_input_time = block_input_time_max
	node_label_info.show_label("Level " + str(level_nr + 1))


func _show_dialog_game_over():
	block_input = true
	block_input_time = block_input_time_max
	node_label_info.show_label("Game Over!")


func is_game_over():
	return game_over


func is_level_completed():
	return level_completed


func get_current_bone_count():
	return bones_count


func on_bird_dead(pos, type = 0):
	if type == 0:
		var food = scene_food.instance()
		food.position = pos
		food.init(self)
		node_food.add_child(food)
	if type == 1:
		var egg = scene_egg.instance()
		egg.position = pos
		node_food.add_child(egg)

func on_food_dropped(drop_position):
	node_doggo.move_to(drop_position)


func on_food_eaten(pos):
	var bone = scene_bone.instance()
	bone.position = pos
	node_bones.add_child(bone)
	food_count += 1
	node_gui.update_gui_food(food_count, food_max)
	node_doggo.show_speechbubble_collected(food_count, food_max)
	if food_count >= food_max:
		level_completed = true
		show_dialog_level_complete = true


func on_egg_hit(pos):
	game_over = true


func on_bone_collected():
	bones_count += 1
	if bones_count > BONES_COUNT_MAX:
		bones_count = BONES_COUNT_MAX
	node_gui.update_gui_bones(bones_count)
	node_player.get_node("SpeechBubble").visible = false


func on_bone_shot():
	bones_count -= 1
	if bones_count < 0:
		bones_count = 0
	node_gui.update_gui_bones(bones_count)
	if bones_count == 0:
		node_player.get_node("SpeechBubble").visible = true


func _on_IntroScene_tree_exiting():
	$AudioMusic.play()
	intro_ended = true
