# @popochiu-docs-ignore-class
@tool
extends PopochiuProp

#region Virtual
func _on_look() -> void:
	C.player.say("The desk is stacked with case files.")


func _on_interact() -> void:
	C.player.say("I find a brass key in the drawer.")
	I.brass_key.add()
#endregion
