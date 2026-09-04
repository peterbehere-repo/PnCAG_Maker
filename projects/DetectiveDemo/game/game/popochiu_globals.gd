extends Node
## Popochiu Globals autoload — project-wide helpers.
## [L2] Was an empty shell; now provides debug + room-state conveniences so the
## autoload isn't dead code.

## True in editor or --debug builds (matches the DebugOverlay gate).
func is_debug() -> bool:
	return OS.is_debug_build()

## Returns the current room's state resource if it exposes one, else null.
## Follows Popochiu's convention: rooms preload a state resource into `state`.
func room_state() -> Resource:
	var r := get_tree().current_scene
	if r and "state" in r and r.state != null:
		return r.state
	return null

## Convenience: the running room (current scene).
func current_room() -> Node:
	return get_tree().current_scene
