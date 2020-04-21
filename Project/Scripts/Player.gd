extends AnimatedSprite


var main_scene
var speed = 500
var move = Vector2()
var node_bullets

# Called when the node enters the scene tree for the first time.
func _ready():
	self.main_scene = get_node("../../MainScene")
	
func _input(event):
	if main_scene.intro_ended and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# shooting
			if not main_scene.is_game_over() and not main_scene.is_level_completed():
				#prevent shooting when pressing on dialog
				if not main_scene.node_label_info.visible: 
					_spawn_bullet()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if main_scene.intro_ended:
		# movement
		if Input.is_action_pressed("ui_right"):
			animation = "walk"
			flip_h = false
			move.x = speed
		elif Input.is_action_pressed("ui_left"):
			animation = "walk"
			flip_h = true
			move.x = -speed
		elif Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
			animation = "default"
			move.x = 0
		
		position += move * delta

		if position.x < 0:
			position.x = 0
		elif position.x > 1024:
			position.x = 1024
		
		# shooting
		if not main_scene.is_game_over() and not main_scene.is_level_completed():
			if not main_scene.node_label_info.visible: #prevent shooting when pressing space on dialog
				if Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up"):
					_spawn_bullet()
	
func _spawn_bullet():
	if main_scene.get_current_bone_count() > 0:
		var bone_scene = load("res://Scenes/WeaponBone.tscn")
		var bullet = bone_scene.instance()
		bullet.position = position
		get_node("../Bullets").add_child(bullet)
		main_scene.on_bone_shot()
		animation = "throw"
		$AudioThrow.play()


func _on_Area2D_area_entered(area):
	if area.name == "Area2DBone":
		print("Bone detected!")
		$AudioCollect.play()
		main_scene.on_bone_collected()
		area.get_parent().queue_free()


func _on_Player_animation_finished():
	if animation == "throw":
		animation = "default"
