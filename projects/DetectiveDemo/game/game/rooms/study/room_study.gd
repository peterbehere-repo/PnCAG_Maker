# @popochiu-docs-ignore-class
@tool
extends PopochiuRoom

const Data := preload("room_study_state.gd")

var state: Data = load("res://game/rooms/study/room_study.tres")


#region Virtual
func _on_room_entered() -> void:
	var detective := C.get_character("detective")
	if detective:
		detective.position = Vector2(900, 780)
		detective.face_left()
	# Start the ambience loop
	if not A.is_playing_cue("ambience_study"):
		A.ambience_study.play()


func _on_room_transition_finished() -> void:
	pass


func _on_room_exited() -> void:
	pass
#endregion
