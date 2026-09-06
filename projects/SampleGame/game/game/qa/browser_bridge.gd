extends Node
## QA bridge: reports game state to the browser console (web) or stdout (headless).

var _t := 0.0

func _log(msg: String) -> void:
	var line := "[QA] " + msg
	if OS.has_feature("web"):
		JavaScriptBridge.eval("console.log(%s)" % JSON.stringify(line), true)
	else:
		print(line)

func _ready() -> void:
	_log("bridge armed, platform=%s" % OS.get_name())
	var office := get_tree().root.get_node_or_null("FirstOffice")
	if office == null:
		# wait a frame for scene tree
		await get_tree().process_frame
		office = get_tree().root.get_node_or_null("FirstOffice")
	if office:
		var pi := office.get_node_or_null("Pi")
		if pi:
			_log("boot pos=(%d,%d) visible=%s" % [int(pi.global_position.x), int(pi.global_position.y), pi.visible])
			pi.movement_finished.connect(func(): _log("arrived (%d,%d)" % [int(pi.global_position.x), int(pi.global_position.y)]))
		var sit := office.get_node_or_null("DeskSitLayer")
		if sit:
			sit.visibility_changed.connect(func(): _log("sit_layer_visible=%s" % sit.visible))
	else:
		_log("first_office not found")

func _process(delta: float) -> void:
	_t += delta
	if _t < 2.0:
		return
	_t = 0.0
	var office := get_tree().root.get_node_or_null("FirstOffice")
	if office and office.has_node("Pi"):
		var pi := office.get_node("Pi")
		_log("tick pos=(%d,%d) vis=%s sit=%s" % [int(pi.global_position.x), int(pi.global_position.y), pi.visible, office.get_node("DeskSitLayer").visible])
