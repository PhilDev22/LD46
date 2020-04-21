extends Sprite

var speed = 700
var move = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	move.y = -speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += move * delta
	
	if position.y < 0:
		queue_free()
