# @popochiu-docs-ignore-class
@tool
extends PopochiuProp

#region Virtual
func _on_look() -> void:
	E.run_character_line(C.detective, "The desk is stacked with case files.")


func _on_interact() -> void:
	E.run_character_line(C.detective, "I find a brass key in the drawer.")
	C.detective.add_item("brass_key")
#endregion
