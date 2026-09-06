extends CanvasLayer
## Diagnostic: red marker + PI idle-frame copy on a CanvasLayer (layer 10).

func _ready() -> void:
	layer = 10
	var red := ColorRect.new()
	red.color = Color(1, 0, 0)
	red.position = Vector2(8, 8)
	red.size = Vector2(40, 40)
	add_child(red)
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/pi/pi_walk_idle_sheet_v2_tinted.png")
	spr.region_enabled = true
	spr.region_rect = Rect2(0, 0, 128, 128)
	spr.position = Vector2(704, 300)
	add_child(spr)
	var node := get_tree().root.get_node_or_null("FirstOffice/Pi")
	if node:
		print("[QA] diag layer up, PI tex=", node.sprite_frames.get_frame_texture(&"idle", 0).get_size())
