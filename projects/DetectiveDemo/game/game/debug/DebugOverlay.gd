extends CanvasLayer

var _lines: Array = []
var _last_click := "none"
var _panel: RichTextLabel

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = RichTextLabel.new()
	_panel.name = "DebugPanel"
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.position = Vector2(8, 8)
	_panel.size = Vector2(760, 420)
	_panel.bbcode_enabled = true
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_theme_color_override("default_color", Color(0.2, 1, 0.6))
	_panel.add_theme_constant_override("outline_size", 4)
	_panel.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_panel.visible = true
	add_child(_panel)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_last_click = "(%d, %d) btn%d" % [event.position.x, event.position.y, event.button_index]
		_update()

func _process(_delta: float) -> void:
	_update()

func _collect() -> Array:
	var l: Array = []
	l.append("=== POPOCHIU DEBUG ===")
	if R:
		var room = R.current
		l.append("room: %s" % (room.script_name if room else "NO ROOM"))
		if room:
			l.append("walkable areas: %d" % room.get_walkable_areas().size())
			var wa = room.get_active_walkable_area()
			l.append("active WA: %s" % (wa.name if wa else "NONE"))
	else:
		l.append("room: R missing")
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

func _update() -> void:
	_lines = _collect()
	var txt := "\n".join(_lines)
	_panel.text = txt
	# also mirror to console so it survives even if panel rendering fails
	print("[DEBUG] " + txt.replace("\n", " | "))
