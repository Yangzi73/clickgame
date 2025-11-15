extends Node2D

var touch_start_position = Vector2()
var touch_end_position = Vector2()
var is_touching = false

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_position = event.position
			is_touching = true
		else:
			touch_end_position = event.position
			is_touching = false
			check_cut()
	
	elif event is InputEventScreenDrag and is_touching:
		touch_end_position = event.position

func check_cut():
	var cut_direction = touch_end_position - touch_start_position
	var cut_length = cut_direction.length()
	
	# 只有滑动距离足够长才认为是切割
	if cut_length > 50:
		# 安全检查世界状态
		var world_2d = get_world_2d()
		if world_2d:
			var space_state = world_2d.direct_space_state
			if space_state:
				var query = PhysicsRayQueryParameters2D.create(touch_start_position, touch_end_position)
				var result = space_state.intersect_ray(query)
				
				if result:
					var collider = result.get("collider")
					if collider and collider.has_method("cut"):
						collider.cut()
						
						# 添加切割特效
						create_cut_effect(touch_start_position, touch_end_position)

func create_cut_effect(_start_pos, _end_pos):
	# 创建简单的切割线效果
	#var line = Line2D.new()
	#line.width = 3
	#line.default_color = Color.WHITE
	#line.add_point(start_pos)
	#line.add_point(end_pos)
	#add_child(line)
	
	# 2秒后移除效果
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	timer.start()
