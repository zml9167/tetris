class_name PieceRotation


static func rotate_point_around_center(offset: Vector2, rad: float) -> Vector2:
	# 应用旋转矩阵计算新偏移
	# 旋转矩阵公式：
	# x' = x*cosθ - y*sinθ
	# y' = x*sinθ + y*cosθ
	var new_x = offset.x * cos(rad) - offset.y * sin(rad)
	var new_y = offset.x * sin(rad) + offset.y * cos(rad)
	
	return Vector2(new_x, new_y)
