extends Node2D

## Desk-sit state machine: click the keyboard to sit, click again to get up.
## Baked sprite (pi_desk_sit_baked.png) includes the desk, so PI's walk sprite
## must be hidden while seated - no layering math at runtime.

const SIT_SPOT := Vector2(845, 745)      # walk target before sitting
const KEYBOARD_RECT := Rect2(655, 460, 260, 90)  # scene-space keys area

var _sitting := false
var _sit_pending := false

const HOTSPOTS := [
	{
		"rect": Rect2(105, 155, 320, 270),
		"name": "Evidence wall",
		"interact": "The case board is crowded with leads and red thread.",
		"examine": "Names, dates, and one missing photograph. Someone has been thorough."
	},
	{
		"rect": Rect2(555, 230, 290, 245),
		"name": "Desk terminal",
		"interact": "The terminal wakes with a tired blue glow.",
		"examine": "A locked message waits behind three layers of encryption."
	},
	{
		"rect": Rect2(975, 105, 265, 310),
		"name": "Window",
		"interact": "Rain turns the city into a smear of neon beyond the glass.",
		"examine": "The blinds are half-closed. A silhouette moved on the roof opposite."
	}
]

const HOVER_AREAS := [
	{"rect": Rect2(820, 375, 225, 140), "label": "chair"},
	{"rect": Rect2(425, 335, 205, 225), "label": "computer"},
	{"rect": Rect2(190, 35, 520, 285), "label": "window"},
	{"rect": Rect2(775, 520, 145, 125), "label": "radio"},
	{"rect": Rect2(60, 390, 185, 290), "label": "file cabinet"},
	{"rect": Rect2(1240, 475, 168, 230), "label": "drawers"}
]

@onready var status_label: Label = $Interface/StatusPanel/Status
@onready var scene_interact_zones: Control = $"Interface/Scene Interact Zones"
@onready var popochiu_hotspots: CanvasLayer = $PopochiuHotspots
@onready var pi: AnimatedSprite2D = $Pi
@onready var desk_sit: Sprite2D = $DeskSit
var _hovered_label := ""
var _gui_was_blocked := false


func _sit_down() -> void:
	_sitting = true
	pi.visible = false
	desk_sit.visible = true
	status_label.text = "PI IS AT THE DESK  //  CLICK KEYBOARD TO GET UP"


func _get_up() -> void:
	_sitting = false
	desk_sit.visible = false
	pi.visible = true
	pi.global_position = SIT_SPOT
	pi.play(&"idle")
	status_label.text = "ROOM READY  //  LEFT CLICK TO INTERACT"


func _try_keyboard_click(position: Vector2) -> bool:
	if not KEYBOARD_RECT.has_point(position):
		return false
	if _sitting:
		_get_up()
	elif not _sit_pending:
		_sit_pending = true
		status_label.text = "SITTING..."
		pi.walk_to(SIT_SPOT)
	get_viewport().set_input_as_handled()
	return true


func _on_pi_arrived() -> void:
	if _sit_pending:
		_sit_pending = false
		_sit_down()


func _ready() -> void:
	pi.movement_finished.connect(_on_pi_arrived)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	status_label.text = "ROOM READY  //  LEFT CLICK TO INTERACT  //  RIGHT CLICK TO EXAMINE"


func _process(_delta: float) -> void:
	var gui_blocked: bool = is_instance_valid(PopochiuUtils.g) and PopochiuUtils.g.is_blocked
	if gui_blocked != _gui_was_blocked:
		_gui_was_blocked = gui_blocked
		scene_interact_zones.visible = not gui_blocked
		_set_hotspot_input(not gui_blocked)
		if gui_blocked:
			_hovered_label = ""
	if gui_blocked:
		return

	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	_update_hover(mouse_position)


func _input(event: InputEvent) -> void:
	if _gui_was_blocked:
		return

	if event is InputEventMouseMotion:
		_update_hover(event.position)
		return

	if not event is InputEventMouseButton or not event.pressed:
		return
	if event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		return

	var position := _viewport_to_image(event.position)
	if _try_keyboard_click(position):
		return
	for hotspot: Dictionary in HOTSPOTS:
		if hotspot.rect.has_point(position):
			var action: String = "interact" if event.button_index == MOUSE_BUTTON_LEFT else "examine"
			status_label.text = "%s  //  %s" % [hotspot.name.to_upper(), hotspot[action]]
			get_viewport().set_input_as_handled()
			return

	# Click on open floor -> PI walks there (disabled while at the desk).
	if event.button_index == MOUSE_BUTTON_LEFT and pi.FLOOR_RECT.has_point(position):
		if _sitting:
			status_label.text = "CLICK THE KEYBOARD TO GET UP"
			get_viewport().set_input_as_handled()
			return
		pi.walk_to(position)
		status_label.text = "MOVING"
		get_viewport().set_input_as_handled()
		return

	status_label.text = "NOTHING OF INTEREST HERE  //  TRY THE OFFICE HOTSPOTS"


func _update_hover(viewport_position: Vector2) -> void:
	var image_position := _viewport_to_image(viewport_position)
	var current_label := ""
	for area: Dictionary in HOVER_AREAS:
		if area.rect.has_point(image_position):
			current_label = area.label
			break
	if current_label.is_empty() and KEYBOARD_RECT.has_point(image_position):
		current_label = "use computer" if not _sitting else "get up"

	if current_label == _hovered_label:
		return

	_hovered_label = current_label
	if _hovered_label.is_empty():
		status_label.text = "ROOM READY  //  LEFT CLICK TO INTERACT  //  RIGHT CLICK TO EXAMINE"
	else:
		status_label.text = _hovered_label.to_upper()


func _set_hotspot_input(enabled: bool) -> void:
	for hotspot: Node in popochiu_hotspots.get_children():
		if hotspot is Area2D:
			hotspot.input_pickable = enabled


func _viewport_to_image(viewport_position: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var image_size: Vector2 = Vector2(1408, 768)
	var scale: float = min(viewport_size.x / image_size.x, viewport_size.y / image_size.y)
	var image_offset: Vector2 = (viewport_size - image_size * scale) / 2.0
	return (viewport_position - image_offset) / scale