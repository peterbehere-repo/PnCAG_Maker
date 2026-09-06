extends AnimatedSprite2D

const FRAME_SIZE := Vector2(176, 192)
const TYPING_SHEET := preload("res://assets/sprites/pi/pi_typing_32f.png")


func _ready() -> void:
	randomize()
	var frames := SpriteFrames.new()
	var typing_frames: Array[AtlasTexture] = []
	for frame_index in 32:
		var frame := AtlasTexture.new()
		frame.atlas = TYPING_SHEET
		frame.region = Rect2(frame_index * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		typing_frames.append(frame)
	frames.add_animation(&"typing")
	frames.set_animation_loop(&"typing", true)
	frames.set_animation_speed(&"typing", 8.0)
	for frame in typing_frames:
		frames.add_frame(&"typing", frame)
	sprite_frames = frames
	play(&"typing")

