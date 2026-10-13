extends Node

const RATE := 22050

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _hum: AudioStreamPlayer
var _sea: AudioStreamPlayer


func _ready() -> void:
	for i in 12:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_streams.slap = _wav(_slap())
	_streams.whoosh = _wav(_whoosh(0.4))
	_streams.whoosh_long = _wav(_whoosh(1.5))
	_streams.splash = _wav(_splash())
	_streams.step = _wav(_step())
	_streams.boing = _wav(_boing())
	_streams.crowd = _wav(_crowd())
	_streams.robot = _wav(_robot())
	_streams.click = _wav(_note(_buf(0.08), 0.0, 0.07, 800.0, 0.6, true, 0.02))
	_streams.tick = _wav(_note(_buf(0.06), 0.0, 0.05, 1250.0, 0.6, false, 0.015))
	_streams.chime = _wav(_note(_note(_buf(0.7), 0.0, 0.5, 880.0, 0.5, false, 0.2), 0.12, 0.55, 1174.7, 0.5, false, 0.25))
	_streams.ding = _wav(_note(_note(_buf(1.0), 0.0, 1.0, 1568.0, 0.6, false, 0.35), 0.0, 1.0, 2093.0, 0.35, false, 0.28))
	_streams.correct = _wav(_melody([[523.3, 0.0, 0.3], [659.3, 0.08, 0.3], [784.0, 0.16, 0.3], [1046.5, 0.24, 0.5]], 0.8, false, 0.15))
	_streams.wrong = _wav(_melody([[233.1, 0.0, 0.22], [185.0, 0.24, 0.4]], 0.7, true, 0.5))
	_streams.fanfare = _wav(_melody([[392.0, 0.0, 0.14], [523.3, 0.15, 0.14], [659.3, 0.3, 0.14], [784.0, 0.45, 0.25],
		[659.3, 0.72, 0.13], [784.0, 0.86, 1.0]], 2.0, true, 0.5))
	_streams.lose = _wav(_sad_trombone())
	_hum = AudioStreamPlayer.new()
	_hum.stream = _wav(_hum_wave(), true)
	_hum.volume_db = -16.0
	add_child(_hum)
	_sea = AudioStreamPlayer.new()
	_sea.stream = _wav(_sea_wave(), true)
	_sea.volume_db = -20.0
	add_child(_sea)
	_sea.play()


func play(sound: String, volume_db := 0.0, pitch := 1.0, rand := 0.06) -> void:
	if not _streams.has(sound):
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[sound]
	p.volume_db = volume_db
	p.pitch_scale = pitch * randf_range(1.0 - rand, 1.0 + rand)
	p.play()


func hum(on: bool, value := 0.0) -> void:
	if not on:
		_hum.stop()
		return
	if not _hum.playing:
		_hum.play()
	_hum.pitch_scale = 0.7 + value * 1.4


func _buf(sec: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(sec * RATE))
	return b


func _wav(data: PackedFloat32Array, loop := false) -> AudioStreamWAV:
	var peak := 0.0001
	for v in data:
		peak = maxf(peak, absf(v))
	var gain := 0.9 / peak
	var bytes := PackedByteArray()
	bytes.resize(data.size() * 2)
	for i in data.size():
		bytes.encode_s16(i * 2, int(clampf(data[i] * gain, -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = bytes
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = data.size()
	return s


func _note(b: PackedFloat32Array, start: float, dur: float, freq: float, vol := 0.5, square := false, decay := 0.15) -> PackedFloat32Array:
	var s0 := int(start * RATE)
	for j in int(dur * RATE):
		var i := s0 + j
		if i >= b.size():
			break
		var t := j / float(RATE)
		var ph := sin(TAU * freq * t)
		var w := signf(ph) * 0.5 + ph * 0.5 if square else ph + 0.3 * sin(TAU * freq * 2.0 * t)
		b[i] += w * minf(1.0, t / 0.005) * exp(-t / decay) * vol
	return b


func _melody(notes: Array, sec: float, square: bool, decay: float) -> PackedFloat32Array:
	var b := _buf(sec)
	for n in notes:
		b = _note(b, n[1], n[2], n[0], 0.5, square, decay)
	return b


func _slap() -> PackedFloat32Array:
	var b := _buf(0.45)
	var lp := 0.0
	for i in b.size():
		var t := i / float(RATE)
		var n := randf_range(-1.0, 1.0)
		var crack := (n - lp) * exp(-t / 0.018)
		lp = lerpf(lp, n, 0.35)
		var thump := sin(TAU * 140.0 * t) * exp(-t / 0.06) * 0.7
		var tail := randf_range(-1.0, 1.0) * exp(-t / 0.12) * 0.1
		b[i] = crack + thump + tail
	return b


func _whoosh(sec: float) -> PackedFloat32Array:
	var b := _buf(sec)
	var lp := 0.0
	for i in b.size():
		var u := i / float(b.size())
		var env := sin(PI * u)
		lp = lerpf(lp, randf_range(-1.0, 1.0), lerpf(0.02, 0.3, env))
		b[i] = lp * env * env
	return b


func _splash() -> PackedFloat32Array:
	var b := _buf(1.4)
	var lp := 0.0
	for i in b.size():
		var t := i / float(RATE)
		lp = lerpf(lp, randf_range(-1.0, 1.0), 0.3)
		b[i] = lp * (1.0 - exp(-t / 0.01)) * exp(-t / 0.35)
	for k in 16:
		var s0 := int(randf_range(0.08, 1.0) * RATE)
		var f0 := randf_range(450.0, 1100.0)
		for j in int(0.06 * RATE):
			var tt := j / float(RATE)
			if s0 + j < b.size():
				b[s0 + j] += sin(TAU * (f0 + tt * 5000.0) * tt) * exp(-tt / 0.02) * 0.12
	return b


func _step() -> PackedFloat32Array:
	var b := _buf(0.09)
	var lp := 0.0
	for i in b.size():
		var t := i / float(RATE)
		lp = lerpf(lp, randf_range(-1.0, 1.0), 0.15)
		b[i] = lp * exp(-t / 0.012) * 1.5 + sin(TAU * 95.0 * t) * exp(-t / 0.025)
	return b


func _boing() -> PackedFloat32Array:
	var b := _buf(0.55)
	var phase := 0.0
	for i in b.size():
		var t := i / float(RATE)
		var f := lerpf(180.0, 620.0, minf(1.0, t / 0.25)) * (1.0 + 0.08 * sin(TAU * 18.0 * t))
		phase += TAU * f / RATE
		b[i] = sin(phase) * exp(-t / 0.2)
	return b


func _crowd() -> PackedFloat32Array:
	var b := _buf(2.0)
	var lp1 := 0.0
	var lp2 := 0.0
	for i in b.size():
		var t := i / float(RATE)
		var n := randf_range(-1.0, 1.0)
		lp1 = lerpf(lp1, n, 0.25)
		lp2 = lerpf(lp2, n, 0.04)
		var env := minf(1.0, t / 0.2) * exp(-maxf(0.0, t - 0.3) / 0.6)
		var wobble := 1.0 + 0.25 * sin(TAU * 6.0 * t) * sin(TAU * 0.9 * t)
		b[i] = (lp1 - lp2) * env * wobble
	return b


func _robot() -> PackedFloat32Array:
	var b := _buf(0.5)
	var freqs := [660.0, 440.0, 880.0, 520.0]
	for k in freqs.size():
		b = _note(b, k * 0.1, 0.09, freqs[k], 0.5, true, 0.08)
	return b


func _sad_trombone() -> PackedFloat32Array:
	var b := _buf(2.6)
	var notes := [[311.1, 0.0, 0.38], [293.7, 0.42, 0.38], [277.2, 0.84, 0.38], [261.6, 1.26, 1.2]]
	for n in notes:
		var s0 := int(n[1] * RATE)
		var phase := 0.0
		for j in int(n[2] * RATE):
			var t := j / float(RATE)
			var vib := 1.0 + (0.02 * sin(TAU * 6.0 * t) if n == notes[-1] else 0.0)
			phase += TAU * n[0] * vib / RATE
			var saw := fmod(phase / TAU, 1.0) * 2.0 - 1.0
			var env := minf(1.0, t / 0.03) * minf(1.0, (n[2] - t) / 0.08)
			if s0 + j < b.size():
				b[s0 + j] += (saw * 0.6 + sin(phase) * 0.4) * env * 0.5
	return b


func _hum_wave() -> PackedFloat32Array:
	var b := _buf(0.5)
	for i in b.size():
		var t := i / float(RATE)
		b[i] = sin(TAU * 220.0 * t) + 0.3 * sin(TAU * 660.0 * t)
	return b


func _sea_wave() -> PackedFloat32Array:
	var b := _buf(6.0)
	var lp := 0.0
	for i in b.size():
		var t := i / float(RATE)
		lp = lerpf(lp, randf_range(-1.0, 1.0), 0.06)
		var swell := 0.2 + 0.8 * pow(sin(PI * t / 3.0), 2.0)
		b[i] = lp * swell
	return b
