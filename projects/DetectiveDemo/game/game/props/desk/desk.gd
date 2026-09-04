# @popochiu-docs-ignore-class
@tool
extends PopochiuProp

#region Virtual
func _on_look() -> void:
	C.player.say("The desk is stacked with case files.")


func _on_interact() -> void:
	if I.has_item_been_collected("brass_key"):
		C.player.say("Already got it. The drawer is empty now.")
	else:
		C.player.say("I find a brass key in the drawer.")
		await C.player.say("This might open the cabinet...")
		I.brass_key.add()
#endregion
