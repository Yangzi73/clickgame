extends RigidBody2D

var is_clicked = false
var fruit_type = 0  # 水果类型，由主场景设置
var is_bad_object = false  # 是否是坏的对象
var image_type = 0  # 图片类型（0=LHC, 1=LNX, 2=CZN）

# 水果纹理映射（使用const避免重复加载）
const FRUIT_TEXTURES = {
	0: preload("res://Pic/LHC.png"),  # LHC
	1: preload("res://Pic/LNX.png"),  # LNX
	2: preload("res://Pic/czn.png")   # CZN
}

func _ready():
	# 设置重力影响
	gravity_scale = 1.0
	
	# 启用输入事件处理
	input_pickable = true
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	
	# 解析水果类型：fruit_type < 10 为好对象，>=10 为坏对象
	if fruit_type >= 10:
		is_bad_object = true
		image_type = fruit_type - 10  # 坏对象的图片类型
	else:
		is_bad_object = false
		image_type = fruit_type  # 好对象的图片类型
	
	# 延迟一帧设置纹理，确保参数已被正确设置
	call_deferred("set_fruit_texture")

func set_fruit_texture():
	# 根据图片类型设置纹理
	if FRUIT_TEXTURES.has(image_type) and FRUIT_TEXTURES[image_type] != null:
		$Sprite2D.texture = FRUIT_TEXTURES[image_type]
		
		# 如果是坏对象，将图片色调改为红色
		if is_bad_object:
			$Sprite2D.modulate = Color(1.5, 0.5, 0.5)  # 偏红色调
		else:
			$Sprite2D.modulate = Color(1, 1, 1)  # 正常色调
	else:
		# 使用默认纹理或打印警告
		print("Warning: Invalid image type or texture not found: ", image_type)

func _on_body_entered(body):
	# 如果碰到地面，移除水果
	if body.is_in_group("ground"):
		queue_free()
	
	# 检查是否超出屏幕边界
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()

func handle_click():
	if is_clicked:
		return
	
	is_clicked = true
	
	# 安全地获取父节点
	var parent = get_parent()
	if parent:
		# 通知主场景加分或减分
		var main_parent = parent.get_parent()
		if main_parent and main_parent.has_method("add_score"):
			if is_bad_object:
				# 点击坏对象减分
				main_parent.add_score(-10)
				# 播放不好吃音效
				if main_parent.has_method("play_bad_sound"):
					main_parent.play_bad_sound()
			else:
				# 点击好对象加分
				main_parent.add_score(10)
				# 播放好吃音效
				if main_parent.has_method("play_good_sound"):
					main_parent.play_good_sound()
	
	# 添加点击消失效果（简单的缩放动画）
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.2)
	tween.tween_callback(queue_free)

func _input_event(_viewport, event, _shape_idx):
	# 支持触摸和鼠标点击
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		handle_click()
