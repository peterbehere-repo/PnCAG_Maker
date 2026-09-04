extends CanvasLayer

var _lines: Array = []
var _last_click := "none"
var _panel: RichTextLabel
var _area_drawer: Control = null

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
	var bid := "dev"
	if FileAccess.file_exists("res://game/debug/build_id.txt"):
		bid = FileAccess.get_file_as_string("res://game/debug/build_id.txt").strip_edges()
	l.append("build: %s" % bid)
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
	_draw_areas()

func _draw_areas() -> void:
	_panel_draw_areas()

func _panel_draw_areas() -> void:
	# draw geometric outlines via a temporary canvas item on the layer
	if _area_drawer == null:
		_area_drawer = AreaDrawer.new()
		add_child(_area_drawer)
	_area_drawer.queue_redraw()

class AreaDrawer extends Control:
	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var room = R.current if R else null
		if room == null:
			return
		var vt := get_viewport_transform()
		# walkable areas (green)
		for wa in get_tree().get_nodes_in_group("walkable_areas"):
			_draw_clickable(wa, vt, Color(0.2, 1, 0.3, 0.9))
		# props (orange)
		for pr in get_tree().get_nodes_in_group("props"):
			_draw_clickable(pr, vt, Color(1, 0.6, 0.1, 0.9))
		# hotspots (cyan)
		for hs in get_tree().get_nodes_in_group("hotspots"):
			_draw_clickable(hs, vt, Color(0.2, 0.9, 1, 0.9))
	func _draw_clickable(node: Node2D, vt: Transform2D, col: Color) -> void:
		if not node.visible:
			return
		for child in node.get_children():
			if child is CollisionPolygon2D and child.get_polygon().size() > 2:
				pass
			elif child is NavigationRegion2D and child.navigation_polygon and child.navigation_polygon.get_polygon_count() > 0:
				var npts := PackedVector2Array()
				for p in child.navigation_polygon.get_vertices():
					npts.append(vt * (node.global_position + child.position + p))
				if npts.size() > 0:
					npts.append(npts[0])
					draw_polyline(npts, col, 2.0)
		for child in node.get_children():
			if child is CollisionPolygon2D and child.get_polygon().size() > 2:
				var pts := PackedVector2Array()
				for p in child.get_polygon():
					pts.append(vt * (node.global_position + p))
				pts.append(pts[0])
				draw_polyline(pts, col, 2.0)
			elif child is CollisionShape2D and child.shape:
				var r := Rect2()
				if child.shape is RectangleShape2D:
					r = Rect2(-child.shape.size / 2, child.shape.size)
					var pts := PackedVector2Array()
					for corner in [r.position, r.position + Vector2(r.size.x,0), r.position + r.size, r.position + Vector2(0,r.size.y), r.position]:
						pts.append(vt * (node.global_position + child.position + corner))
					draw_polyline(pts, col, 2.0)
