extends Node2D

var score = 0
var game_over = false
var game_started = false
var round_time = 30.0  # 每回合60秒
var current_time = 0.0
var fruit_scene = preload("res://Scene/Fruit.tscn")

# 音频资源
var bgm_audio = preload("res://Sound/my-8-bit-hero-301280.mp3")
var good_sound = preload("res://Sound/好吃 (1).wav")
var bad_sound = preload("res://Sound/不好吃.wav")

# 三种水果类型
enum FruitType {LHC, LNX, CZN}

# 水果纹理数组
var fruit_textures = {
	FruitType.LHC: preload("res://Pic/LHC.png"),
	FruitType.LNX: preload("res://Pic/LNX.png"), 
	FruitType.CZN: preload("res://Pic/czn.png")
}

func _ready():
	# 显示开始界面
	show_start_screen()
	
	# 播放BGM
	play_bgm()
	
	# 连接按钮信号
	if $UI/StartButton:
		$UI/StartButton.pressed.connect(_on_StartButton_pressed)
	if $UI/ResultPanel/RestartButton:
		$UI/ResultPanel/RestartButton.pressed.connect(_on_RestartButton_pressed)

func _process(delta):
	if game_started and not game_over: 
		current_time -= delta
		update_timer()
		
		if current_time <= 0:
			current_time = 0
			end_round()

func show_start_screen():
	$UI/StartButton.visible = true
	$UI/GameOverLabel.visible = false
	$UI/ScoreLabel.visible = false
	$UI/TimeLabel.visible = false
	$UI/ResultPanel.visible = false

func start_game():
	game_started = true
	game_over = false
	score = 0
	current_time = round_time
	
	# 隐藏开始界面，显示游戏界面
	$UI/StartButton.visible = false
	$UI/ScoreLabel.visible = true
	$UI/TimeLabel.visible = true
	
	# 开始生成水果
	$SpawnTimer.timeout.connect(_on_SpawnTimer_timeout)
	$SpawnTimer.start()
	
	update_score()
	update_timer()

func end_round():
	game_over = true
	game_started = false
	$SpawnTimer.stop()
	
	# 显示结算界面
	show_result_screen()

func show_result_screen():
	$UI/ResultPanel.visible = true
	$UI/ResultPanel/ResultScore.text = "Mark: " + str(score)
	
	# 清空所有水果
	for child in $FruitContainer.get_children():
		child.queue_free()

func play_bgm():
	if $AudioStreamPlayer:
		$AudioStreamPlayer.stream = bgm_audio
		$AudioStreamPlayer.volume_db = -20.0  # 调小音量
		$AudioStreamPlayer.play()

func play_good_sound():
	if $GoodSoundPlayer:
		$GoodSoundPlayer.stream = good_sound
		$GoodSoundPlayer.play()

func play_bad_sound():
	if $BadSoundPlayer:
		$BadSoundPlayer.stream = bad_sound
		$BadSoundPlayer.play()

func _on_SpawnTimer_timeout():
	if game_over:
		return
	
	spawn_fruit()

func spawn_fruit():
	var fruit = fruit_scene.instantiate()
	$FruitContainer.add_child(fruit)
	
	# 随机决定是否为坏对象
	var is_bad = randf() < 0.45  # 45%概率生成坏对象
	
	# 随机选择图片类型（0=LHC, 1=LNX, 2=CZN）
	var image_type = randi() % 3
	
	# 设置水果类型：第一位表示好坏，第二位表示图片类型
	# 例如：10 = 坏对象使用LHC图片，20 = 坏对象使用LNX图片，30 = 坏对象使用CZN图片
	# 0 = 好对象使用LHC图片，1 = 好对象使用LNX图片，2 = 好对象使用CZN图片
	var fruit_type = image_type
	if is_bad:
		fruit_type = image_type + 10  # 坏对象类型从10开始
	
	# 设置水果类型
	fruit.fruit_type = fruit_type
	fruit.is_bad_object = is_bad
	fruit.image_type = image_type
	
	# 随机位置（从屏幕顶部生成）
	var spawn_x = randf_range(100, get_viewport_rect().size.x - 100)
	fruit.position = Vector2(spawn_x, -50)  # 从屏幕上方生成
	
	# 随机速度和旋转（向下掉落）
	var velocity = Vector2(randf_range(-50, 50), randf_range(300, 500))
	fruit.linear_velocity = velocity
	fruit.angular_velocity = randf_range(-5, 5)
	
	# 调试信息
	var object_type = "坏对象" if is_bad else "好对象"
	var image_names = ["LHC", "LNX", "CZN"]
	print("生成对象类型: ", object_type, " 图片: ", image_names[image_type])

func add_score(points):
	score += points
	update_score()

func update_score():
	$UI/ScoreLabel.text = "Mark: " + str(score)

func update_timer():
	$UI/TimeLabel.text = "Time: " + str(int(current_time)) + "s"

func end_game():
	game_over = true
	$SpawnTimer.stop()
	$UI/GameOverLabel.visible = true

func _on_StartButton_pressed():
	start_game()

func _on_RestartButton_pressed():
	# 重新开始游戏
	get_tree().reload_current_scene()

func _input(event):
	if game_over and event is InputEventScreenTouch and event.pressed:
		# 重新开始游戏
		get_tree().reload_current_scene()
