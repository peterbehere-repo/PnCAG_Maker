extends SceneTree

const SAMPLE_RATE := 22050
const DURATION_SECONDS := 150
const OUTPUT_PATH := "res://assets/audio/neo_noir_office_theme.wav"


func _init() -> void:
	var sample_count := SAMPLE_RATE * DURATION_SECONDS
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to create music file")
		quit(1)
		return

	_write_header(file, sample_count)
	for sample_index in sample_count:
		var time := float(sample_index) / SAMPLE_RATE
		var pulse := 0.5 + 0.5 * sin(TAU * 0.125 * time)
		var drone := sin(TAU * 73.42 * time) * 0.14 + sin(TAU * 110.0 * time) * 0.06
		var pad := sin(TAU * 146.83 * time) * 0.035 + sin(TAU * 220.0 * time) * 0.025
		var bass := sin(TAU * 55.0 * time) * (0.05 + pulse * 0.04)
		var arp_phase: float = fmod(time, 8.0)
		var arp_frequencies: Array[float] = [293.66, 349.23, 440.0, 523.25]
		var arp_frequency: float = arp_frequencies[int(arp_phase / 2.0)]
		var arp_envelope: float = max(0.0, 1.0 - fmod(arp_phase, 2.0) / 2.0) * 0.035
		var arp: float = sin(TAU * arp_frequency * time) * arp_envelope
		var shimmer: float = sin(TAU * 880.0 * time) * max(0.0, sin(TAU * 0.031 * time)) * 0.012
		var value: float = clamp(drone + pad + bass + arp + shimmer, -0.8, 0.8)
		file.store_16(int(value * 30000.0))

	file.close()
	quit()


func _write_header(file: FileAccess, sample_count: int) -> void:
	var data_size := sample_count * 2
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + data_size)
	file.store_buffer("WAVE".to_ascii_buffer())
	file.store_buffer("fmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(1)
	file.store_32(SAMPLE_RATE)
	file.store_32(SAMPLE_RATE * 2)
	file.store_16(2)
	file.store_16(16)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_size)