# @popochiu-docs-ignore-class
@tool
extends PopochiuCharacter

const Data := preload("detective_state.gd")

var state: Data = load("res://game/characters/detective/detective.tres")


#region Virtual
func _on_click() -> void:
	PopochiuUtils.e.command_fallback()


func _on_right_click() -> void:
	PopochiuUtils.e.command_fallback()
#endregion
