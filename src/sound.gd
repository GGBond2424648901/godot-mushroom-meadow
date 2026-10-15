extends Node
var voices: Array[AudioStreamPlayer] = []
var tones: Array[AudioStreamWAV] = []
var muted := false
var next_voice := 0

func _ready() -> void:
	for species in range(3):
		var wav := AudioStreamWAV.new()
		wav.format = AudioStreamWAV.FORMAT_16_BITS
		wav.mix_rate = 48000
		var bytes := PackedByteArray()
		bytes.resize(11520 * 2)
		for i in range(11520):
			var t := i / 48000.0
			var phase := TAU * ((330.0 + species * 95) * t - 190.0 * t * t)
			var value := sin(phase) * exp(-t * 18.0) * minf(t * 150, 1) * 0.22
			bytes.encode_s16(i * 2, int(value * 32767))
		wav.data = bytes
		tones.append(wav)
	for i in range(6):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voice.volume_db = -11.0
		voices.append(voice)

func pop(species: int, strength: float) -> void:
	if muted or voices.is_empty():
		return
	var voice := voices[next_voice % voices.size()]
	voice.stop()
	voice.stream = tones[species]
	voice.pitch_scale = clampf(1.18 - strength * 0.16, 0.8, 1.2)
	voice.play()
	next_voice += 1

func reset() -> void:
	for voice in voices:
		voice.stop()
	next_voice = 0

func _exit_tree() -> void:
	for voice in voices:
		if is_instance_valid(voice):
			voice.stop()
			voice.stream = null
	tones.clear()
