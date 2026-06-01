extends AnimatedSprite3D
 
@export var anim_col: int = 0
 
var camera: Camera3D = null

func set_camera(c):
	camera = c
 
func _process(_delta):
	if camera == null:
		return
 
	var p_fwd = -camera.global_transform.basis.z
	var fwd = global_transform.basis.z
	var left = global_transform.basis.x
 
	var l_dot = left.dot(p_fwd)
	var f_dot = fwd.dot(p_fwd)
	var row = 0
	flip_h = false
	if f_dot < -0.85:
		row = 0 # front sprite
	elif f_dot > 0.85:
		row = 4 # back sprite
	else:
		flip_h = l_dot > 0
		if abs(f_dot) < 0.3:
			row = 2 # left sprite
		elif f_dot < 0:
			row = 1 # forward left sprite
		else:
			row = 3 # back left sprite
	frame = anim_col + row * 4
