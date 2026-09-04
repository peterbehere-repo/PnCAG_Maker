# @popochiu-docs-ignore-class
@tool
extends PopochiuHotspot

#region Virtual
func _on_look() -> void:
	C.player.say("Rain. It's been raining all week.")


func _on_interact() -> void:
	C.player.say("Can't go out — the case comes first.")
#endregion
