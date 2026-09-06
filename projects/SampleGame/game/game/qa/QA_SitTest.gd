extends SceneTree
## Functional QA: click keyboard -> PI walks -> DeskSit shows -> click again -> standing restored.
## Run: godot --headless --path . -s res://game/qa/QA_SitTest.gd

var _frames := 0

func _initialize() -> void:
	change_scene_to_file("res://scenes/first_office.tscn")

var _phase := "boot"
var _fails: Array[String] = []
var _passes := 0

func _assert(cond: bool, name: String) -> void:
	if cond:
		_passes += 1
		print("  PASS  ", name)
	else:
		_fails.append(name)
		print("  FAIL  ", name)

func _click(pos: Vector2) -> void:
	var vs: Vector2 = root.size
	var scale: float = min(vs.x / 1408.0, vs.y / 768.0)
	var off: Vector2 = (vs - Vector2(1408, 768) * scale) / 2.0
	pos = pos * scale + off
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = pos
	Input.parse_input_event(down)
	var up := down.duplicate()
	up.pressed = false
	Input.parse_input_event(up)

func _process(_delta: float) -> bool:
	_frames += 1
	var main := current_scene
	if main == null:
		return false
	match _phase:
		"boot":
			if _frames > 30:
				_assert(main.name == "FirstOffice", "scene booted")
				_assert(main.get_node("Pi") != null, "PI present")
				_assert(not main.get_node("DeskSitLayer").visible, "DeskSit hidden at boot")
				_click(Vector2(785, 505))   # keyboard
				_phase = "walking"
				_t = 0
		"walking":
			_t += 1
			if main.get_node("DeskSitLayer").visible:
				_assert(main.get_node("DeskSitLayer").layer == 7, "DeskSit layer=7 (matches bg transform space)")
				_assert(main.get_node("DeskSitLayer/DeskSit").texture.get_size() == Vector2(1408, 768), "sit texture full-scene 1408x768")
				_assert(not main.get_node("Pi").visible, "walk sprite hidden while seated")
				_click(Vector2(785, 505))   # get up
				_phase = "getting_up"
				_t = 0
			elif _t > 2000:
				_assert(false, "DeskSit never became visible (walk/sit failed)")
				return _done()
		"getting_up":
			_t += 1
			if main.get_node("Pi").visible:
				_assert(main.get_node("Pi").global_position.distance_to(Vector2(845, 745)) < 2.0, "PI restored at sit spot")
				_assert(not main.get_node("DeskSitLayer").visible, "DeskSit hidden after get up")
				return _done()
			elif _t > 500:
				_assert(false, "PI never stood up")
				return _done()
	return false

var _t := 0

func _done() -> bool:
	print("========== SIT QA: %d PASS / %d FAIL ==========" % [_passes, _fails.size()])
	for f in _fails:
		print("  FAILED: ", f)
	quit(1 if _fails.size() > 0 else 0)
	return true
