# @popochiu-docs-ignore-class
@tool
extends PopochiuHotspot

func _on_look() -> void:
	E.run_character_line(C.detective, "Rain. It's been raining all week.")

func _on_interact() -> void:
	E.run_character_line(C.detective, "Can't go out — the case comes first.")
