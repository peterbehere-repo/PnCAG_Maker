# @popochiu-docs-ignore-class
@tool
extends PopochiuRoom
const Data := preload("room_study_state.gd")
var state: Data = load("res://game/rooms/study/room_study.tres")

func _on_room_entered() -> void:
	print("[ROOM] entered; is_current=", is_current, " proc_uh=", is_processing_unhandled_input(), " blocked=", G.is_blocked if G else "?")
	var detective := C.get_character("detective")
	if detective:
		# Reposition only if the detective isn't already mid-movement (avoids
		# fighting the nav/anti-glide system on re-entry or save loads).
		if not detective.is_moving:
			detective.position = Vector2(1450, 900)
			detective.face_left()
	if not A.is_playing_cue("ambience_study"):
		A.ambience_study.play()
		print("[ROOM] ambience play() called; playing=", A.is_playing_cue("ambience_study"))

func _on_room_transition_finished() -> void:
	print("[ROOM] transition done; is_current=", is_current, " proc_uh=", is_processing_unhandled_input(), " blocked=", G.is_blocked if G else "?", " in_room=", E.in_room if E else "?")
func _on_room_exited() -> void:
	pass
