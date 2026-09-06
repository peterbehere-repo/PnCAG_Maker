# QA_Runner.gd — SampleGame (First Office) headless QA harness.
# Runs as part of the game (autoload-style) and is armed only when:
#   PNCAG_QA=1 env var AND project setting game/debug/qa_mode is enabled.
# Usage: PNCAG_QA=1 godot --headless --path . --quit-after 240
extends Node

const MAIN_SCENE := "res://scenes/first_office.tscn"
const HOTSPOT_NAMES := ["Chair", "Computer", "Window", "Radio", "FileCabinet", "Drawers"]
const OVERLAY_NAMES := ["monitor", "board", "plant", "chair", "mug", "door"]  # hover regions

var failures: Array[String] = []
var passes := 0
var repeat := 3
var _started := false
var _frames := 0

func _ready() -> void:
	var qa_env := OS.get_environment("PNCAG_QA")
	var qa_setting: bool = ProjectSettings.get_setting("game/debug/qa_mode", true)
	if qa_env != "1" and not qa_setting:
		return
	print("QA_Runner: armed (repeat=", repeat, ") scene=", MAIN_SCENE)

func _process(_delta: float) -> void:
	_frames += 1
	var main: Node = get_tree().current_scene
	# Wait for the main scene to be loaded and settled (or 120-frame cap)
	var ready := main != null
	if _frames >= 120:
		ready = true
	if _frames >= 3 and ready:
		if not _started:
			_started = true
			_run_all()
			_report()
		if OS.get_environment("PNCAG_QA") == "1":
			get_tree().quit(0 if failures.is_empty() else 1)

func _assert(cond: bool, name: String, detail := "") -> void:
	if cond:
		passes += 1
		print("  PASS  ", name, detail)
	else:
		failures.append(name + (": " + detail if detail else ""))
		print("  FAIL  ", name, " ", detail)

func _al(name: String) -> Node:
	return get_node_or_null("/root/" + name)

func _run_all() -> void:
	print("\n========== QA START ==========")
	_test_autoloads_present()
	_main_scene_boot()
	_hotspots_present()
	_hotspot_interact_repeat()
	_pi_character_and_sprites()
	_audio_cue()
	_save_load_api()
	print("========== QA END ==========")

func _test_autoloads_present() -> void:
	print("\n[1] Autoloads")
	for key in ["Globals", "Cursor", "E", "R", "C", "I", "D", "A", "G", "T"]:
		_assert(_al(key) != null, "autoload " + key)

func _main_scene_boot() -> void:
	print("\n[2] Main scene boot (Node2D)")
	var main: Node = get_tree().current_scene
	_assert(main != null, "main scene", str(main))
	if main == null: return
	_assert(main.is_inside_tree(), "in tree")
	_assert(main.scene_file_path == MAIN_SCENE, "scene path", str(main.scene_file_path))
	_assert(main.get("HOTSPOTS") != null or main.get("script_name") != null, "scene script has data")

func _hotspots_present() -> void:
	print("\n[3] Hotspots present")
	var main: Node = get_tree().current_scene
	if main == null: return
	var all: Array = main.get("all_hotspots") if main.get("all_hotspots") != null else []
	for hname in HOTSPOT_NAMES:
		var n: Node = _find_node_in(main, hname)
		_assert(n != null, "hotspot " + hname, n.name if n else "missing")

func _hotspot_interact_repeat() -> void:
	print("\n[4] Hotspot click simulation x", repeat)
	var main: Node = get_tree().current_scene
	if main == null: return
	var desk: Node = _find_node_in(main, "computer")
	_assert(desk != null, "computer hotspot found")
	if desk:
		var before: int = desk.get("times_clicked")
		for i in repeat:
			_simulate_click(desk, MOUSE_BUTTON_LEFT)
		var after: int = desk.get("times_clicked")
		_assert(after > before, "computer left-click increments", str(before) + "->" + str(after))
	var win: Node = _find_node_in(main, "window")
	_assert(win != null, "window found")
	if win:
		var before: int = win.get("times_right_clicked")
		for i in repeat:
			_simulate_click(win, MOUSE_BUTTON_RIGHT)
		var after: int = win.get("times_right_clicked")
		_assert(after > before, "window right-click increments", str(before) + "->" + str(after))

func _simulate_click(node: Node, button: int) -> void:
	# Simulate a real Popochiu click through the input_event signal path
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	ev.pressed = true
	ev.position = node.position
	# Popochiu's click gate checks PopochiuUtils.e.hovered via _hovered_queue;
	# use add_hovered() to set it properly (set_hovered alone bypasses queue).
	var e: Node = get_node("/root/E")
	e.call("add_hovered", node)
	node.emit_signal("input_event", get_viewport(), ev, 0)
	e.call("remove_hovered", node)

func _pi_character_and_sprites() -> void:
	print("\n[5] PI character + sprites")
	var pi: Node = get_node_or_null("/root/Game/Player") if _al("Game") else null
	if pi == null:
		# Pi may be a child of the scene
		pi = _find_in_main("pi")
	_assert(pi != null, "pi character found")
	if pi == null: return
	# Pi's AnimatedSprite2D is at PiLayer/Pi; _find_in_main matched the CanvasLayer.
	var pi_sprite: Node = get_tree().current_scene.get_node_or_null("PiLayer/Pi")
	_assert(pi_sprite != null, "Pi AnimatedSprite2D at PiLayer/Pi")
	pi = pi_sprite if pi_sprite != null else pi
	var pf: SpriteFrames = pi.get("sprite_frames") if pi.get("sprite_frames") != null else null
	var anim: String = str(pi.get("animation"))
	_assert(pf != null, "pi has sprite_frames")
	_assert(anim == "typing", "pi animation == typing", anim)
	_assert(pi.get("script") != null or pi.get_script() != null, "pi has script attached")
	# Assert the sprite sheet resource is loadable
	var sheet := load("res://assets/sprites/pi/pi_typing_32f.png")
	_assert(sheet != null, "pi typing sheet loadable")
	var idle := load("res://assets/sprites/pi/pi_idle.png")
	_assert(idle != null, "pi idle sheet loadable")

func _audio_cue() -> void:
	print("\n[6] Audio cue")
	var A: Node = _al("A")
	_assert(A != null, "A (audio) autoload", "missing" if A == null else "")
	if A == null: return
	_assert(A.has_method("is_playing_cue"), "is_playing_cue exists")
	var cue := load("res://assets/audio/Neon Rain in Sector 7.mp3")
	_assert(cue != null, "mp3 loadable")

func _save_load_api() -> void:
	print("\n[7] Save/load API")
	var E: Node = _al("E")
	_assert(E != null, "E (game) autoload")
	if E == null: return
	_assert(E.has_method("save_game"), "save_game exists")
	_assert(E.has_method("load_game"), "load_game exists")
	_assert(E.has_method("has_save"), "has_save exists")

func _find_in_main(needle: String) -> Node:
	var main: Node = get_tree().current_scene
	if main == null: return null
	var found: Array[Node] = []
	_find_recursive(main, needle.to_lower(), found)
	return found[0] if found.size() > 0 else null

func _find_node_in(root: Node, needle: String) -> Node:
	if root == null: return null
	var found: Array[Node] = []
	_find_recursive(root, needle.to_lower(), found)
	return found[0] if found.size() > 0 else null

func _find_recursive(node: Node, needle_lower: String, found: Array[Node]) -> void:
	if found.size() > 50: return
	if node.name.to_lower().find(needle_lower) != -1:
		found.append(node)
	for c in node.get_children():
		_find_recursive(c, needle_lower, found)

func _report() -> void:
	print("\n===== QA REPORT =====")
	print("PASS: ", passes, "  FAIL: ", failures.size())
	if failures.is_empty():
		print("RESULT: OK")
	else:
		print("RESULT: FAIL")
		for f in failures:
			print("  - ", f)
