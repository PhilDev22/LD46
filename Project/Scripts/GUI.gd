extends Node2D


onready var node_gui_bones = get_node("GUI_Bones")
onready var node_gui_food = get_node("GUI_Food/LabelFood")
onready var node_gui_time = get_node("LabelTime")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_gui_time(time):
	node_gui_time.text = str(int(ceil(time)))
	if time <= 10:
		node_gui_time.get_node("AnimationPlayer").play("pulsate")
	else:
		node_gui_time.get_node("AnimationPlayer").play("none")
	
func update_gui_food(count, food_max):
	node_gui_food.text = (str(int(count)) + "/" + str(int(food_max)))

func update_gui_bones(count):
	for i in range(0, node_gui_bones.get_child_count()):
		if i < count:
			node_gui_bones.get_child(i).show()
		else:
			node_gui_bones.get_child(i).hide()
