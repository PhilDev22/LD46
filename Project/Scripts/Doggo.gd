extends AnimatedSprite


var speed_x = 400
var moving_offset = 50

var move = Vector2()
var new_position = Vector2()
var moving_to = false

var moving_queue = Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	$SpeechBubbleAmount.visible = false
	$SpeechBubble.visible = false
	$HeartsAnim.visible = false
	stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving_to:
		if position.x > new_position.x + moving_offset:
			_move_left()
		elif position.x < new_position.x -moving_offset:
			_move_right()
		else:
			moving_queue.pop_front()
			if (moving_queue.size() > 0):
				move_to(moving_queue.front(), false)
			else:
				stop()

	position += move * delta


func show_speechbubble_amount(amount):
	$SpeechBubbleAmount/Label.text = str(amount)
	$SpeechBubbleAmount/AnimationPlayer.playback_speed = 1	
	$SpeechBubbleAmount/AnimationPlayer.play("show_and_hide")
	$AudioBark.play()

func show_speechbubble_collected(amount, max_amount):
	if amount < max_amount:
		$SpeechBubbleAmount/Label.text = str(max_amount - amount)
		$SpeechBubbleAmount/AnimationPlayer.stop(true)
		$SpeechBubbleAmount/AnimationPlayer.playback_speed = 4
		$SpeechBubbleAmount/AnimationPlayer.play("show_and_hide")
		#$AudioBark.play()
	
func show_heart_animation():
	$HeartsAnim.visible = true
	$HeartsAnim.frame = 0
	$HeartsAnim.play("default")
	$AudioBark.play()


func move_to(to_position, queue = true):
	if queue:
		moving_queue.append(to_position)
		if (moving_queue.size() == 1):
			new_position = to_position
	else:
		new_position = to_position
	moving_to = true
	
func _move_left():
	move.x = -speed_x
	flip_h = false
	animation = "running"
	
func _move_right():
	move.x = speed_x
	flip_h = true
	animation = "running"

func stop():
	moving_to = false
	moving_queue.clear()
	move = Vector2()
	animation = "default"

func _on_Area2D_body_entered(body):
	if body.name == "RigidBodyFood":
		print("Food detected!")
		body.get_parent().queue_free()
		get_node("../../MainScene").on_food_eaten(position + Vector2(0, -30))
		$AudioEat.play()
		
	if body.name == "RigidBodyEgg":
		print("Egg detected!")
		body.get_parent().queue_free()
		get_node("../../MainScene").on_egg_hit(position)
		#$AudioWhine.play()


func _on_HeartsAnim_animation_finished():
	$HeartsAnim.visible = false
	$HeartsAnim.frame = 0
	
