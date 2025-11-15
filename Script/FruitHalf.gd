extends RigidBody2D

func _ready():
	# 设置重力影响
	gravity_scale = 1.0
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	
	# 设置生命周期，2秒后自动消失
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	timer.start()

func _on_body_entered(body):
	# 如果碰到地面，移除半片
	if body.is_in_group("ground"):
		queue_free()
