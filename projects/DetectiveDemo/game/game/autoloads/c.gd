@tool
extends "res://addons/popochiu/engine/interfaces/i_character.gd"
## Characters autoload — Popochiu 2.1.1. The editor fills in class/node/function markers.
# classes ----
const PRDetective := preload("res://game/characters/detective/detective.gd")
# ---- classes

# nodes ----
var detective: PRDetective : get = get_detective
# ---- nodes

# functions ----
func get_detective() -> PRDetective:
	return get_character("detective") as PRDetective
# ---- functions
