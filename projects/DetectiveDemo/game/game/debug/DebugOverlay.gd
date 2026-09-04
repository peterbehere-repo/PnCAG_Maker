extends CanvasLayer

var _visible := false
var _lines: Array = []
var _last_click := "none"
var _panel: Control

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.draw.connect(_draw_panel)
	add_child(_panel)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		_visible = not _visible
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if _visible and event is InputEventMouseButton and event.pressed:
		_last_click = "(%d, %d) btn%d" % [event.position.x, event.position.y, event.button_index]

func _process(_delta: float) -> void:
	if _visible:
		_lines = _collect()
	_panel.queue_redraw()

func _collect() -> Array:
	var l: Array = []
	l.append("=== POPOCHIU DEBUG (` to hide) ===")
	var room = null
	if R and R.has_method("get_active_room"):
		room = R.get_active_room()
	if room:
		l.append("room: %s" % room.script_name)
		l.append("walkable areas: %d" % room.get_walkable_areas().size())
		var wa = room.get_active_walkable_area()
		l.append("active WA: %s" % (wa.name if wa else "NONE"))
	else:
		l.append("room: NO ROOM")
	l.append("props group: %d" % get_tree().get_nodes_in_group("props").size())
	l.append("hotspots group: %d" % get_tree().get_nodes_in_group("hotspots").size())
	l.append("walkable_areas group: %d" % get_tree().get_nodes_in_group("walkable_areas").size())
	l.append("player: %s" % (C.player if C else "NO C"))
	if C and C.player:
		l.append("player pos: (%d, %d)" % [C.player.position.x, C.player.position.y])
		l.append("player moving: %s" % C.player.is_moving)
	l.append("hovered: %s" % (E.hovered.script_name if E and E.hovered else "none"))
	l.append("ambience: loaded=%s playing=%s" % [A.ambience_study != null, A.is_playing_cue("ambience_study") if A else false])
	l.append("key in inv: %s" % (I.is_item_in_inventory("brass_key") if I else false))
	l.append("last click: %s" % _last_click)
	return l

func _draw_panel() -> void:
	if not _visible:
		return
	_panel.draw_rect(Rect2(0, 0, 700, 340), Color(0, 0, 0, 0.75))
	var y := 18
	for line in _lines:
		_panel.draw_string(ThemeDB.fallback_font, Vector2(14, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.3, 1, 0.7))
		y += 22
