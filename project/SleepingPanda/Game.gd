extends Control

const RIDDLE = preload("res://Riddle.tscn")
const STAR = preload("res://Star.tscn")

var song = preload("res://Assets/Audio/Song.wav")
var song_is_playing = false
var riddles_spawning = 0
var riddle_spawn_speed = 5.0
var riddle_speed = 1.0
var difficulty = 1
var db = []
var score = 0

func _ready():
	#Prepare database
	loadAndParse("res://Assets/Storing/db.json")
	#Enable shaders
	var mat = $Background/Waterfall/Shine.get_material()
	mat.set_shader_param("speed_scale",0.05)
	$Background/Waterfall/Shine.set_material(mat)
	#Messages
	var label_M_size = $Messages.rect_size/2
	$Messages.set_pivot_offset(
	Vector2(label_M_size.x,label_M_size.y))
	#Button
	$Button.show()
	var label_B_size = $Button.rect_size/2
	$Button.set_pivot_offset(
	Vector2(label_B_size.x,label_B_size.y))
	get_tree().set_quit_on_go_back(false)

func _process(delta):
	audio_handler()
	riddles_handler()

func riddles_handler():
	if riddles_spawning > 0: 
		spawn_riddle()

func spawn_riddle():
	if riddles_spawning > 1:
		riddles_spawning = 1
		var new_riddle = RIDDLE.instance()
		new_riddle.speed = riddle_speed
		generate_riddle(new_riddle)
		$WaterPath/Center/Waterfall.add_child(new_riddle)
		if riddle_speed < 2.0:
			riddle_speed += 0.1
			riddle_spawn_speed -= 0.1
		else:
			difficulty = 2
			$WaterPath/Indicators/Difficulty/Number.text = str(difficulty)
			$Music.pitch_scale = 1.5
			$Music.volume_db = -15
		$RiddleTimer.wait_time = riddle_spawn_speed
		$RiddleTimer.start()

func random_number(_from,_to):
	randomize()
	return randi()%_to+_from

func audio_handler():
	if song_is_playing and !$Music.is_playing():
		$MusicToggle.show()
		$Music.play()

func start():
	$UIAnimator.play("Start")
	yield($UIAnimator, "animation_finished")
	$Music.set_stream(song)
	song_is_playing = true
	riddles_spawning = 2

func loadAndParse(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	file.open(file_path,file.READ)
	db = parse_json(file.get_as_text())
	file.close()
	assert db.size()>0

func generate_riddle(_riddle):
	randomize()
#	var random_riddle = db[0].values() #test for specific id
	var random_riddle = db[random_number(1,db.size())-1].values()
	randomize()
	var question_language = randi()%2+1
	var oposite_language = get_oposite_language(question_language)
	randomize()
	var correct_option = randi()%2+1
	#set the question given a random language
	_riddle.question = random_riddle[question_language]
	_riddle.correct_option = correct_option
	var another_riddle = get_another_riddle(random_riddle)
	if correct_option == 1:
		_riddle.option1 = random_riddle[oposite_language]
		_riddle.option2 = another_riddle[oposite_language]
	else:
		_riddle.option1 = another_riddle[oposite_language]
		_riddle.option2 = random_riddle[oposite_language]
	_riddle.correct_option_reveal = another_riddle[question_language]

func get_oposite_language(question_language):
	if question_language == 1:
		return 2
	else:
		return 1

func get_another_riddle(_original_riddle):
	var random_riddle = null
	var filtered = []
	#filter
	match difficulty:
		1: 
			for i in db:
				if (
				#doubles
				i.values()[0] != _original_riddle[0] and 
				#double meanings
				i.values()[3] != _original_riddle[3]):
					filtered.append(i)
		2: 
			for i in db:
				if (
				#doubles
				i.values()[0] != _original_riddle[0] and 
				#class
				i.values()[5] != _original_riddle[5] and 
				#double meanings
				i.values()[3] != _original_riddle[3]):
					filtered.append(i)
	randomize()
	filtered.shuffle()
	return filtered.front().values()

func _on_Game_resized():
	$Background/Sky.rect_size = OS.window_size
	if OS.window_size.y >= 750:
		$Background/Waterfall.rect_scale = Vector2(1,1.5)
	elif OS.window_size.y > 640 and OS.window_size.y < 750:
		$Background/Waterfall.rect_scale = Vector2(1,1.2)
	else:
		$Background/Waterfall.rect_scale = Vector2(1,1)
	if OS.window_size.x < 442:
		$PandainTree/Tree/Panda/Head/ZZZ.texture = load("res://Assets/ZDark.png")
	else:
		$PandainTree/Tree/Panda/Head/ZZZ.texture = load("res://Assets/ZBright.png")

func _on_Button_pressed():
	start()

func _on_MusicToggle_pressed():
	if song_is_playing:
		$MusicToggle.icon = load("res://Assets/musicOff.png")
		$Music.stream_paused = true
		song_is_playing = false
	else:
		$MusicToggle.icon = load("res://Assets/musicOn.png")
		$Music.stream_paused = false
		song_is_playing = true

func _on_RiddleTimer_timeout():
	riddles_spawning = 2

func find_by_class(_riddle):
	var filtered = []
	for i in db:
		if (
		i.values()[5] == _riddle[5]
		):
			filtered.append(i)
	randomize()
	filtered.shuffle()
	return filtered.front()

func correct():
	score += 1
	$WaterPath/Indicators/Score/Number.text = str(score)

func incorrect():
	if score != 0:
		score -= 1
		$WaterPath/Indicators/Score/Number.text = str(score)

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        _on_Back_pressed()

func _on_Back_pressed():
	pass