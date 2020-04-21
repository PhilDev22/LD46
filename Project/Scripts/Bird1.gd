extends AnimatedSprite


var main_scene
var speed_x = 200
var move = Vector2()
var x_max = 1200
var x_min = -100
var dead = false
var type = 0

func init(main_scene, moving_speed, type = 0):
	self.main_scene = main_scene
	self.speed_x = moving_speed
	self.type = type
	if type == 1:
		animation = "default2"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if flip_h:
		move.x = speed_x
	else:
		move.x = -speed_x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dead:
		position += move * delta
	if position.x > x_max or position.x < x_min:
		queue_free()
		

func _on_Area2D_body_entered(body):
	if dead == false:
		dead = true
		$AudioHit.play()
		main_scene.on_bird_dead(position, type)
		if type == 0:
			$AnimationPlayer.play("fall")
		elif type == 1:
			$AnimationPlayer.play("fall2")
