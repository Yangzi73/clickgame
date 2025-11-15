extends StaticBody2D

func _ready():
	# 添加到地面组
	add_to_group("ground")
	
	# 设置位置在屏幕底部
	var viewport_size = get_viewport_rect().size
	position = Vector2(viewport_size.x / 2, viewport_size.y + 25)
