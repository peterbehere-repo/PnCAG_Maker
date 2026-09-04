extends CanvasLayer

var _lines: Array = []
var _last_click := "none"
var _click_count := 0
var _room_handled := "?"
var _key_state := "?"
var _panel: RichTextLabel
var _area_drawer: Control = null

## Per-category toggles for the scene overlays (static so the inner drawer can read them).
static var show_walkable := true
static var show_props := true
static var show_hotspots := true
static var show_labels := true

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
	_create_toggle_bar()
	_create_audio_gate()

## On-screen toggle buttons for the overlay categories (for browser testing).
func _create_toggle_bar() -> void:
	var bar := HBoxContainer.new()
	bar.name = "ToggleBar"
	bar.position = Vector2(8, 440)
	bar.add_theme_constant_override("separation", 8)
	var cb_w := CheckButton.new()
	cb_w.text = "W: Walk"
	cb_w.button_pressed = true
	cb_w.toggled.connect(func(on: bool) -> void:
		DebugOverlay.show_walkable = on
		_update()
	)
	bar.add_child(cb_w)
	var cb_p := CheckButton.new()
	cb_p.text = "P: Props"
	cb_p.button_pressed = true
	cb_p.toggled.connect(func(on: bool) -> void:
		DebugOverlay.show_props = on
		_update()
	)
	bar.add_child(cb_p)
	var cb_h := CheckButton.new()
	cb_h.text = "H: Hot"
	cb_h.button_pressed = true
	cb_h.toggled.connect(func(on: bool) -> void:
		DebugOverlay.show_hotspots = on
		_update()
	)
	bar.add_child(cb_h)
	var cb_l := CheckButton.new()
	cb_l.text = "L: Names"
	cb_l.button_pressed = true
	cb_l.toggled.connect(func(on: bool) -> void:
		DebugOverlay.show_labels = on
		_update()
	)
	bar.add_child(cb_l)
	add_child(bar)

## Chrome/Windows autoplay policy: no audio until the first user gesture.
## A full-screen button guarantees a real gesture and unlocks the audio context.
func _create_audio_gate() -> void:
	var btn := Button.new()
	btn.name = "AudioGate"
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.text = ""
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
	# Fire on RELEASE: Chrome unlocks the AudioContext on pointerup, so the
	# restart must happen after release, not on press-down.
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	# start fully transparent so the game is visible behind it
	btn.modulate = Color(1, 1, 1, 0.02)
	btn.pressed.connect(func() -> void:
		print("[DBG] audio gate clicked (release)")
		_unlock_audio_now()
		btn.queue_free()
	)
	add_child(btn)
	print("[DBG] audio gate created")

func _unlock_audio_now() -> void:
	print("[DBG] audio unlock now")
	if A:
		# Kill the cue that was started at room-entry (it's trapped in Chrome's
		# suspended AudioContext -> "playing" but silent). Stop removes it from
		# the manager's _active map, so the next play() attaches a fresh stream
		# while the context is now unlocked by the user gesture.
		if PopochiuUtils and PopochiuUtils.e and PopochiuUtils.e.am:
			PopochiuUtils.e.am.stop("ambience_study")
			print("[DBG] stopped trapped ambience")
		A.ambience_study.play()
		# Chrome actually resumes the context on pointerup which lands moments
		# AFTER this handler; re-attach the stream twice more so at least one
		# attach lands after the context is truly running.
		_restart_ambience_later()

func _restart_ambience_later() -> void:
	for delay in [0.6, 1.6]:
		await get_tree().create_timer(delay).timeout
		if not A:
			return
		if PopochiuUtils and PopochiuUtils.e and PopochiuUtils.e.am:
			PopochiuUtils.e.am.stop("ambience_study")
		A.ambience_study.play()
		print("[DBG] ambience re-attach +%.1fs; playing=%s" % [delay, A.is_playing_cue("ambience_study")])

var _audio_unlocked := false

## Browsers block audio until the first user gesture; play any pending cue after it.
func _unlock_audio(_e: InputEvent) -> void:
	if _audio_unlocked:
		return
	_audio_unlocked = true
	print("[DBG] audio unlock on first gesture")
	_unlock_audio_now()

func _input(event: InputEvent) -> void:
	_unlock_audio(event)
	if event is InputEventMouseButton and event.pressed:
		_last_click = "(%d, %d) btn%d" % [event.position.x, event.position.y, event.button_index]
		_click_count += 1
		print("[DBG] click %d at (%d, %d) btn%d hovered=%s" % [_click_count, event.position.x, event.position.y, event.button_index, E.hovered.script_name if E and E.hovered else "none"])
		_update()
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_QUOTELEFT:
				_panel.visible = not _panel.visible
				print("[DBG] debug panel: %s" % _panel.visible)
			KEY_1:
				DebugOverlay.show_walkable = not DebugOverlay.show_walkable
				print("[DBG] walkable overlay: %s" % DebugOverlay.show_walkable)
				_update()
			KEY_2:
				DebugOverlay.show_props = not DebugOverlay.show_props
				print("[DBG] props overlay: %s" % DebugOverlay.show_props)
				_update()
			KEY_3:
				DebugOverlay.show_hotspots = not DebugOverlay.show_hotspots
				print("[DBG] hotspots overlay: %s" % DebugOverlay.show_hotspots)
				_update()
			KEY_4:
				DebugOverlay.show_labels = not DebugOverlay.show_labels
				print("[DBG] labels: %s" % DebugOverlay.show_labels)
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
	l.append("toggles  [`]panel [1]walk [2]props [3]hot [4]names")
	l.append("show: W=%s P=%s H=%s N=%s" % [DebugOverlay.show_walkable, DebugOverlay.show_props, DebugOverlay.show_hotspots, DebugOverlay.show_labels])
	if R:
		var room = R.current
		l.append("room: %s" % (room.script_name if room else "NO ROOM"))
		if room:
			l.append("walkable areas: %d" % room.get_walkable_areas().size())
			var wa = room.get_active_walkable_area()
			l.append("active WA: %s" % (wa.name if wa else "NONE"))
			var ip: Variant = wa.get("interaction_polygon") if wa else null
			var n_out := 0
			var n_pts := 0
			if ip is Array:
				n_out = ip.size()
				for o: PackedVector2Array in ip:
					n_pts += o.size()
			l.append("WA outlines: %d pts: %d" % [n_out, n_pts])
			l.append("room is_current: %s" % room.is_current)
			l.append("room proc_uh: %s" % room.is_processing_unhandled_input())
			l.append("gui blocked: %s" % (G.is_blocked if G else "?"))
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
	l.append("click count: %d" % _click_count)
	l.append("room unhandled: %s" % _room_handled)
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
		if DebugOverlay.show_walkable:
			for wa in get_tree().get_nodes_in_group("walkable_areas"):
				_draw_clickable(wa, vt, Color(0.2, 1, 0.3, 0.9))
		# props (orange)
		if DebugOverlay.show_props:
			for pr in get_tree().get_nodes_in_group("props"):
				_draw_clickable(pr, vt, Color(1, 0.6, 0.1, 0.9))
		# hotspots (cyan)
		if DebugOverlay.show_hotspots:
			for hs in get_tree().get_nodes_in_group("hotspots"):
				_draw_clickable(hs, vt, Color(0.2, 0.9, 1, 0.9))
	func _draw_poly(vt: Transform2D, origin: Vector2, pts: PackedVector2Array, col: Color) -> void:
		if pts.size() < 3:
			return
		var xf := PackedVector2Array()
		for p in pts:
			xf.append(vt * (origin + p))
		if xf.size() < 3:
			return
		var closed := xf.duplicate()
		closed.append(xf[0])
		draw_polyline(closed, col, 2.0)
		var fill := col
		fill.a = 0.14
		draw_colored_polygon(xf, fill)

	func _draw_clickable(node: Node2D, vt: Transform2D, col: Color) -> void:
		if not node.visible:
			return
		# PopochiuWalkableArea stores its click polygon in `interaction_polygon` as
		# an Array[PackedVector2Array] (one outline per polygon) — its Area2D
		# collision. Draw each outline (same proof as the orange/cyan boxes).
		# FALLBACK for plain PackedVector2Array exports (flat list of points).
		var ip: Variant = node.get("interaction_polygon")
		if ip != null and not (ip is Array and ip.is_empty()):
			var drew := false
			# Outlines are stored relative to the Perimeter child, whose position is
			# cached in interaction_polygon_position.
			var off: Vector2 = node.global_position
			if node.get("interaction_polygon_position") != null:
				off += node.interaction_polygon_position
			if ip is Array:
				for outline: PackedVector2Array in ip:
					if outline.size() > 2:
						_draw_poly(vt, off, outline, col)
						if DebugOverlay.show_labels:
							_draw_centroid_label(node.name, vt, off, outline, col)
						drew = true
			elif ip is PackedVector2Array and ip.size() > 2:
				_draw_poly(vt, off, ip, col)
				if DebugOverlay.show_labels:
					_draw_centroid_label(node.name, vt, off, ip, col)
				drew = true
			if drew:
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
				if DebugOverlay.show_labels:
					var c := Vector2.ZERO
					for p in child.get_polygon():
						c += vt * (node.global_position + p)
					c /= child.get_polygon().size()
					_draw_name_label(node.name, c, col)
			elif child is CollisionShape2D and child.shape:
				var r := Rect2()
				if child.shape is RectangleShape2D:
					r = Rect2(-child.shape.size / 2, child.shape.size)
					var pts := PackedVector2Array()
					for corner in [r.position, r.position + Vector2(r.size.x,0), r.position + r.size, r.position + Vector2(0,r.size.y), r.position]:
						pts.append(vt * (node.global_position + child.position + corner))
					draw_polyline(pts, col, 2.0)
					if DebugOverlay.show_labels:
						_draw_name_label(node.name, vt * (node.global_position + child.position), col)

	func _draw_name_label(text: String, pos: Vector2, col: Color) -> void:
		var fnt := ThemeDB.fallback_font
		draw_string(fnt, pos + Vector2(6, -8), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)

	func _draw_centroid_label(text: String, vt: Transform2D, origin: Vector2, pts: PackedVector2Array, col: Color) -> void:
		var c := Vector2.ZERO
		for p in pts:
			c += vt * (origin + p)
		c /= pts.size()
		_draw_name_label(text, c, col)
