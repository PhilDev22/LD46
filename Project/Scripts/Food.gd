extends Node2D


var main_scene
var notified_mainscene = false
var current_pos 

func init(main_scene):
	self.main_scene = main_scene
	
# Called when the node enters the scene tree for the first time.
func _process(delta):
	if not notified_mainscene:
		current_pos = position + $RigidBodyFood.position
		#print(current_pos)
		if current_pos.y > 500:
			notified_mainscene = true
			main_scene.on_food_dropped(current_pos)
