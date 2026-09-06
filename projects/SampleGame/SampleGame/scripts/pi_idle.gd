extends AnimatedSprite2D
## PI character controller - walks along the office floor.

signal movement_finished

const WALK_SPEED := 240.0
const FLOOR_RECT := Rect2(60, 700, 1288, 58)

var _target := Vector2.ZERO
var _moving := false


func _ready() -> void:
	# FIX: Popochiu ships camera limits of 320x180; our room is 1408x768.
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 1408
		cam.limit_bottom = 768
		cam.reset_smoothing()
	play(&"idle")


func walk_to(point: Vector2) -> void:
	_target = Vector2(
		clampf(point.x, FLOOR_RECT.position.x, FLOOR_RECT.end.x),
		clampf(point.y, FLOOR_RECT.position.y, FLOOR_RECT.end.y)
	)
	_moving = true
	flip_h = _target.x < global_position.x
	play(&"walk")


func _process(delta: float) -> void:
	if not _moving:
		return
	var to_target := _target - global_position
	var step := WALK_SPEED * delta
	if to_target.length() <= step:
		global_position = _target
		_moving = false
		play(&"idle")
		movement_finished.emit()
		return
	global_position += to_target.normalized() * step

