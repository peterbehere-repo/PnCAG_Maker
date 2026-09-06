extends Control

const IMAGE_SIZE := Vector2(1408, 768)
const AREAS := [
	{"rect": Rect2(820, 375, 225, 140), "label": "CHAIR"},
	{"rect": Rect2(425, 335, 205, 225), "label": "COMPUTER"},
	{"rect": Rect2(190, 35, 520, 285), "label": "WINDOW"},
	{"rect": Rect2(775, 520, 145, 125), "label": "RADIO"},
	{"rect": Rect2(60, 390, 185, 290), "label": "FILE CABINET"},
	{"rect": Rect2(1240, 475, 168, 230), "label": "DRAWERS"}
]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var viewport_size: Vector2 = size
	var scale: float = min(viewport_size.x / IMAGE_SIZE.x, viewport_size.y / IMAGE_SIZE.y)
	var offset: Vector2 = (viewport_size - IMAGE_SIZE * scale) / 2.0
	for area: Dictionary in AREAS:
		var source_rect: Rect2 = area.rect
		var screen_rect := Rect2(offset + source_rect.position * scale, source_rect.size * scale)
		var is_hovered := screen_rect.has_point(get_local_mouse_position())
		var line_color := Color(1.0, 0.78, 0.28, 1.0) if is_hovered else Color(0.2, 0.95, 0.82, 0.85)
		draw_rect(screen_rect, line_color, false, 4.0 if is_hovered else 3.0)
		if is_hovered:
			var label_position := get_local_mouse_position() + Vector2(18, -38)
			label_position.x = clamp(label_position.x, 8.0, viewport_size.x - 188.0)
			label_position.y = clamp(label_position.y, 8.0, viewport_size.y - 40.0)
			draw_rect(Rect2(label_position, Vector2(180, 34)), Color(0.02, 0.04, 0.06, 0.95), true)
			draw_string(ThemeDB.fallback_font, label_position + Vector2(10, 24), area.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, line_color)