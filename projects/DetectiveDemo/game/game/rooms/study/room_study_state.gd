# @popochiu-docs-ignore-class
extends PopochiuRoomData
# Add variables here that should be saved and restored with the room state.
func _on_save() -> Dictionary:
	return {}
func _on_load(data: Dictionary) -> void:
	prints(data)
