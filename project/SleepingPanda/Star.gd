extends Sprite

var posPercent = Vector2()
var started = false

func _ready():
	posPercent = Vector2(
	position.x*100/OS.get_window_size().x,
	position.y*100/OS.get_window_size().y)
	position = Vector2(0,0)
	started = true
	show()

func _process(delta):
	if started:
		global_position = Vector2(
		OS.get_window_size().x*posPercent.x/100,
		OS.get_window_size().y*posPercent.y/100)