extends PathFollow2D
var question
var option1
var option2
var speed = 1.0
var out = false
var correct_option = 1
var correct_option_reveal = ""
var sound
signal correct
signal incorrect

func _ready():
	self.connect('correct', 
	get_parent().get_parent().get_parent().get_parent(), 
	'correct')
	self.connect('incorrect', 
	get_parent().get_parent().get_parent().get_parent(), 
	'incorrect')
	$Control/Question.text = question
	$Control/Option1.text = str (option1,$Control/Option1.text)
	$Control/Option2.text = str (option2,$Control/Option2.text)
	$Control.rect_pivot_offset = $Control.get_size()/2
	show()
	$AnimationPlayer.play("FadeIn")

func _process(delta):
	if !out:
		if unit_offset < 0.9:
			unit_offset += speed/1000
		else:
			emit_signal("incorrect")
			out = true
			$AnimationPlayer.play_backwards("FadeIn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if out:
		self.disconnect('correct', 
		get_parent().get_parent().get_parent().get_parent(), 
		'correct')
		self.disconnect('incorrect', 
		get_parent().get_parent().get_parent().get_parent(), 
		'incorrect')
		queue_free()

func _on_Option1_pressed():
	if !result(1):
		$Control/Option1.text = correct_option_reveal

func _on_Option2_pressed():
	if !result(2):
		$Control/Option2.text = correct_option_reveal

func result(_selected_option):
	$Control/Option1/Option1.disabled = true
	$Control/Option2/Option2.disabled = true
	if _selected_option == correct_option:
		sound = load("res://Assets/Audio/correct.wav")
		$Control.modulate = Color(0, 1, 0)
		$AudioStreamPlayer.volume_db = -10
		emit_signal("correct")
		out_selection()
		return true
	else:
		sound = load("res://Assets/Audio/incorrect.wav")
		$Control.modulate = Color(1, 0, 0)
		$AudioStreamPlayer.volume_db = 0
		emit_signal("incorrect")
		out_selection()
		return false

func out_selection():
	$AudioStreamPlayer.stream=sound
	$AudioStreamPlayer.play()
	out = true
	$AnimationPlayer.play_backwards("FadeIn")