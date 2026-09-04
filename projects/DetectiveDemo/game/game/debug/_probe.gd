extends Node
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	var room = R.current if R else null
	print("[PROBE] R.current = ", room.script_name if room else "null")
	if room:
		print("[PROBE] room.is_current = ", room.is_current)
		print("[PROBE] room process_unhandled = ", room.is_processing_unhandled_input())
		print("[PROBE] room process_input = ", room.is_processing_input())
	print("[PROBE] g.is_blocked = ", G.is_blocked if G else "no G")
	print("[PROBE] g.blocked signal connected? ", G.blocked.get_connections().size() if G else 0)
	print("[PROBE] player = ", C.player.script_name if C and C.player else "none")
	print("[PROBE] player moving = ", C.player.moving if C and C.player else "?")
	print("[PROBE] walked check done")
	get_tree().quit()
