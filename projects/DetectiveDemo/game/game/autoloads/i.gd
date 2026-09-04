@tool
extends "res://addons/popochiu/engine/interfaces/i_inventory.gd"
## Inventory items autoload — Popochiu 2.1.1. The editor fills in class/node/function markers.
# classes ----
const PRBrassKey := preload("res://game/inventory_items/brass_key/brass_key.gd")
# ---- classes

# nodes ----
var brass_key: PRBrassKey : get = get_brass_key
# ---- nodes

# functions ----
func get_brass_key() -> PRBrassKey:
	return get_instance("brass_key") as PRBrassKey
# ---- functions
