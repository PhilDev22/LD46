extends Label

var showing = false

		
func show_label(text):
	if not showing:
		self.text = text
		showing = true
		show()
		$AnimationPlayer.play("fade_in")
	
func hide_label():
	if showing:
		$AnimationPlayer.play("fade_out")
		showing = false
