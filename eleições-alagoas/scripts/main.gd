extends Node3D

const Prim = preload("res://scripts/prim.gd")
const World = preload("res://scripts/world.gd")
const Characters = preload("res://scripts/characters.gd")
const Questions = preload("res://scripts/questions.gd")
const GameUI = preload("res://scripts/ui.gd")

const SPOTS := [Vector3(-4.5, 0, 0.5), Vector3(-1.5, 0, 0.5), Vector3(1.5, 0, 0.5), Vector3(4.5, 0, 0.5)]
const DIFFICULTY := {
	"facil": {"label": "Fácil", "time": 20.0, "bar_speed": 0.75, "bot_skill": 0.35,
		"desc": "Somas e subtrações até 20, formas geométricas e dobro. 20 segundos por pergunta."},
	"medio": {"label": "Médio", "time": 14.0, "bar_speed": 1.05, "bot_skill": 0.55,
		"desc": "Contas até 100, tabuada, divisão e metade. 14 segundos por pergunta."},
	"dificil": {"label": "Difícil", "time": 9.0, "bar_speed": 1.4, "bot_skill": 0.75,
		"desc": "Multiplicações maiores, expressões, número que falta, quadrados e frações. 9 segundos!"},
}
const OVERVIEW_POS := Vector3(0, 2.4, 9.0)
const OVERVIEW_LOOK := Vector3(0, -0.4, 0)
const PLAYER_LIVES := 3
const BOT_LIVES := 2
const POW_WORDS := ["PAAAF!", "PLAFT!", "TÁÁÁ!", "POW!", "SLAP!"]

signal answered(index: int)
signal power_locked(value: float)

var fighters: Array = []
var player = null
var selected := 0
var difficulty := "facil"
var questions := Questions.new()
var ui: GameUI
var camera: Camera3D

var state := "menu"
var time_left := 0.0
var current_q: Dictionary = {}
var round_num := 0
var score := 0
var hits := 0
var misses := 0

var bar_time := 0.0
var bar_value := 0.0
var bar_player := false
var bot_goal := 0.5

var cam_pos := OVERVIEW_POS
var cam_look := OVERVIEW_LOOK
var cam_follow: Node3D = null
var cam_follow_offset := Vector3(3, 2.5, 7)
var cam_smooth := 3.0
var shake := 0.0
var _look_cur := OVERVIEW_LOOK
var _clock := 0.0


func _ready() -> void:
	randomize()
	World.build(self)
	for i in Characters.ROSTER.size():
		var f = Characters.create(Characters.ROSTER[i])
		f.home = SPOTS[i]
		f.position = f.home
		add_child(f)
		fighters.append(f)
	camera = Camera3D.new()
	camera.fov = 55
	camera.far = 600
	add_child(camera)
	camera.position = OVERVIEW_POS
	camera.look_at(OVERVIEW_LOOK)
	ui = GameUI.new()
	add_child(ui)
	ui.build(fighters, DIFFICULTY)
	ui.character_picked.connect(_on_character_picked)
	ui.difficulty_picked.connect(_on_difficulty_picked)
	ui.start_requested.connect(_start_game)
	ui.answer_picked.connect(_on_answer)
	ui.restart_requested.connect(_start_game)
	ui.menu_requested.connect(_show_menu)
	ui.select_difficulty(difficulty)
	_show_menu()


func _show_menu() -> void:
	state = "menu"
	Engine.time_scale = 1.0
	cam_follow = null
	for f in fighters:
		f.reset_for_game()
		f.is_player = false
		f.set_player_marker(false)
	ui.show_menu()
	ui.select_character(selected)
	_on_character_picked(selected)


func _on_character_picked(i: int) -> void:
	selected = i
	var f = fighters[i]
	cam_pos = f.home + Vector3(-1.4, 1.5, 4.4)
	cam_look = f.home + Vector3(-1.4, 1.15, 0)
	if state == "menu":
		f.wave()


func _on_difficulty_picked(key: String) -> void:
	difficulty = key


func _start_game() -> void:
	if state != "menu" and state != "end":
		return
	state = "intro"
	round_num = 0
	score = 0
	hits = 0
	misses = 0
	for i in fighters.size():
		var f = fighters[i]
		f.reset_for_game()
		f.is_player = i == selected
		f.max_lives = PLAYER_LIVES if f.is_player else BOT_LIVES
		f.lives = f.max_lives
		f.set_player_marker(f.is_player)
	player = fighters[selected]
	ui.show_hud(DIFFICULTY[difficulty].label)
	ui.set_score(0)
	cam_follow = null
	cam_smooth = 1.2
	cam_pos = Vector3(4, 4, 4)
	cam_look = Vector3(11, 4, -9)
	ui.show_banner("Bem-vindos ao Marco dos Corais!", GameUI.YELLOW, "Maceió - Alagoas", 2.0)
	await _wait(2.4)
	_set_overview()
	ui.show_banner("Você é %s!" % player.display_name, Color(0.4, 1, 0.5), "Acerte as contas para dar tapas nos robôs", 1.8)
	await _wait(2.2)
	cam_smooth = 3.0
	while player.lives > 0 and not _alive_bots().is_empty():
		await _play_round()
	_end_game(player.lives > 0)


func _play_round() -> void:
	round_num += 1
	_set_overview()
	current_q = questions.generate(difficulty)
	time_left = DIFFICULTY[difficulty].time
	ui.show_question(current_q, round_num)
	state = "question"
	var idx: int = await answered
	ui.lock_answers(idx, current_q)
	var correct: bool = idx >= 0 and current_q.options[idx] == current_q.answer
	if correct:
		hits += 1
		var bonus := 10 + int(ceil(time_left))
		score += bonus
		ui.set_score(score)
		ui.show_banner("ACERTOU!  +%d" % bonus, Color(0.4, 1, 0.5), "", 1.2)
		await _wait(1.4)
		ui.hide_question()
		var target = await _choose_target()
		await _slap(player, target)
	else:
		misses += 1
		var title := "TEMPO ESGOTADO!" if idx < 0 else "ERROU!"
		ui.show_banner(title, Color(1, 0.4, 0.4), "Resposta certa: %s" % current_q.explain, 2.8)
		await _wait(3.0)
		ui.hide_question()
		var attacker = _alive_bots().pick_random()
		ui.show_banner("%s (robô) vai bater!" % attacker.display_name, Color(1, 0.6, 0.2), "", 1.2)
		await _wait(1.2)
		await _slap(attacker, player)


func _on_answer(i: int) -> void:
	if state == "question":
		state = "busy"
		answered.emit(i)


func _choose_target():
	var bots := _alive_bots()
	if bots.size() == 1:
		return bots[0]
	state = "target"
	ui.show_target_choice(bots)
	var i: int = await ui.target_picked
	state = "busy"
	return bots[i]


func _alive_bots() -> Array:
	return fighters.filter(func(f): return not f.is_player and f.lives > 0)


func _end_game(won: bool) -> void:
	state = "end"
	cam_follow = null
	if won:
		cam_pos = player.home + Vector3(0, 1.8, 4.5)
		cam_look = player.home + Vector3(0, 1.2, 0)
		player.celebrate()
	else:
		cam_pos = player.position + Vector3(0, 4, 8)
		cam_look = player.position + Vector3(0, 1, 0)
	ui.show_end(won, player.display_name, score, hits, misses)


func _slap(attacker, target) -> void:
	state = "busy"
	var from_right: bool = attacker.home.x > target.home.x
	var ang := atan2(-1.0, -0.35) if from_right else atan2(1.0, -0.7)
	var o := Vector3(-0.4, 0, 0.78).rotated(Vector3.UP, ang)
	var spot: Vector3 = target.position - o
	await attacker.walk_to(spot, 0.9)
	await attacker.turn_to_angle(ang, 0.15)
	target.idle_enabled = false
	target.turn_to(-o, 0.25)

	var mid: Vector3 = (attacker.position + target.position) * 0.5
	var perp := Vector3(-o.z, 0, o.x).normalized()
	if perp.z < 0:
		perp = -perp
	cam_pos = mid + perp * 4.0 + Vector3(0, 2.3, 1.2)
	cam_look = mid + Vector3(0, 1.3, 0)

	await attacker.wind_up()
	bar_player = attacker.is_player
	bar_time = 0.0
	bot_goal = _bot_goal()
	ui.show_power_bar(bar_player, attacker.display_name)
	state = "power"
	var v: float = await power_locked
	var grade := _grade(v)
	var power := _power_from(v)
	ui.show_power_result(grade)
	if attacker.is_player:
		score += {"perfeito": 50, "forte": 30, "fraco": 10}[grade]
		ui.set_score(score)

	await attacker.swing()
	target.hit_react()
	_impact_fx(target.global_position + Vector3(0, 1.85, 0))
	ui.pow_text(POW_WORDS.pick_random())
	shake = 0.35
	Engine.time_scale = 0.15
	await get_tree().create_timer(0.6, true, false, true).timeout
	Engine.time_scale = 1.0
	ui.hide_power_bar()

	var dir := Vector3(o.x, 0, o.z - 0.6).normalized()
	cam_follow_offset = perp * 9.0 - dir * 3.0 + Vector3(0, 2.5, 0)
	cam_follow = target
	cam_smooth = 6.0
	attacker.recover()
	var landing: Vector3 = await target.launch(dir, power, World.WATER_Y)
	_splash(Vector3(landing.x, World.WATER_Y, landing.z))
	shake = 0.25
	ui.pow_text("TCHIBUM!")
	target.lives -= 1
	ui.update_status()
	await _wait(1.6)
	cam_follow = null
	cam_smooth = 3.0

	if target.lives <= 0:
		target.eliminate()
		cam_pos = target.position + Vector3(0, 3.5, 7)
		cam_look = target.position + Vector3(0, 1, 0)
		var who: String = "Você" if target.is_player else target.display_name
		ui.show_banner("%s caiu fora!" % who, Color(0.6, 0.9, 1.0), "Boiando no mar de Maceió...", 1.6)
		await _wait(1.8)
		_set_overview()
		if target.is_player:
			return
	else:
		target.respawn()
		_set_overview()
	await attacker.walk_to(attacker.home, 1.0)
	await attacker.turn_to_angle(0.0, 0.2)
	attacker.idle_enabled = true
	await _wait(0.4)


func _grade(v: float) -> String:
	if v >= GameUI.PERFECT_MIN and v <= GameUI.PERFECT_MAX:
		return "perfeito"
	if v >= GameUI.STRONG_MIN:
		return "forte"
	return "fraco"


func _power_from(v: float) -> float:
	match _grade(v):
		"perfeito":
			return 1.0
		"forte":
			return 0.45 + (minf(v, GameUI.PERFECT_MIN) - GameUI.STRONG_MIN) * 0.9
		_:
			return 0.1 + v * 0.4


func _bot_goal() -> float:
	var skill: float = DIFFICULTY[difficulty].bot_skill
	if randf() < skill:
		return randf_range(0.84, 0.93)
	if randf() < 0.6:
		return randf_range(0.55, 0.8)
	return randf_range(0.2, 0.45)


func _lock_power() -> void:
	if state == "power":
		state = "busy"
		power_locked.emit(bar_value)


func _impact_fx(pos: Vector3) -> void:
	var cols := [Color(1.0, 0.9, 0.2), Color(1.0, 0.6, 0.1), Color(1, 1, 1)]
	for i in 18:
		var star := Prim.prism(self, Vector3(0.16, 0.16, 0.04), cols[i % 3], pos)
		var d := Vector3(randf_range(-1, 1), randf_range(-0.6, 1), randf_range(-1, 1)).normalized()
		var tw := create_tween().set_parallel()
		tw.tween_property(star, "position", pos + d * randf_range(0.8, 1.6), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(star, "rotation", Vector3(randf() * 6, randf() * 6, randf() * 6), 0.5)
		tw.tween_property(star, "scale", Vector3.ONE * 0.05, 0.5).set_delay(0.15)
		tw.chain().tween_callback(star.queue_free)


func _splash(pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	var m := SphereMesh.new()
	m.radius = 0.09
	m.height = 0.18
	m.radial_segments = 8
	m.rings = 4
	p.mesh = m
	p.material_override = Prim.mat(Color(0.85, 0.95, 1.0))
	p.amount = 90
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = 1.4
	p.direction = Vector3.UP
	p.spread = 28.0
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 9.5
	p.gravity = Vector3(0, -14, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.8
	add_child(p)
	p.global_position = pos
	p.emitting = true
	get_tree().create_timer(3.0).timeout.connect(p.queue_free)
	for k in 2:
		var ring := Prim.torus(self, 0.45, 0.6, Color(0.92, 0.98, 1.0), pos + Vector3(0, 0.12, 0))
		ring.scale = Vector3(1, 0.3, 1)
		var tw := create_tween().set_parallel()
		tw.tween_property(ring, "scale", Vector3(7 + k * 4, 0.3, 7 + k * 4), 1.6 + k * 0.5).set_delay(k * 0.25).set_ease(Tween.EASE_OUT)
		tw.tween_property(ring, "transparency", 1.0, 1.6 + k * 0.5).set_delay(k * 0.25)
		tw.chain().tween_callback(ring.queue_free)


func _set_overview() -> void:
	cam_follow = null
	cam_pos = OVERVIEW_POS
	cam_look = OVERVIEW_LOOK


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _process(delta: float) -> void:
	_clock += delta
	match state:
		"question":
			time_left -= delta
			ui.set_timer(time_left / DIFFICULTY[difficulty].time)
			if time_left <= 0.0:
				_on_answer(-1)
		"power":
			bar_time += delta
			bar_value = pingpong(bar_time * DIFFICULTY[difficulty].bar_speed, 1.0)
			ui.set_power(bar_value)
			if not bar_player and bar_time > 0.9 and (absf(bar_value - bot_goal) < 0.03 or bar_time > 5.0):
				_lock_power()
			elif bar_player and bar_time > 7.0:
				_lock_power()
	_update_camera(delta)


func _update_camera(delta: float) -> void:
	var target_pos := cam_pos
	var target_look := cam_look
	if cam_follow:
		target_look = cam_follow.global_position + Vector3(0, 1.0, 0)
		target_pos = target_look + cam_follow_offset
	elif state == "menu":
		target_pos += Vector3(sin(_clock * 0.4) * 0.4, sin(_clock * 0.3) * 0.15, 0)
	var k := 1.0 - exp(-cam_smooth * delta)
	camera.position = camera.position.lerp(target_pos, k)
	_look_cur = target_look if cam_follow else _look_cur.lerp(target_look, k)
	if camera.position.distance_to(_look_cur) > 0.01:
		camera.look_at(_look_cur)
	shake = move_toward(shake, 0.0, delta * 0.8)
	camera.h_offset = randf_range(-shake, shake) * 0.5
	camera.v_offset = randf_range(-shake, shake) * 0.5


func _unhandled_input(event: InputEvent) -> void:
	if state != "power" or not bar_player:
		return
	var hit := false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		hit = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hit = true
	if hit:
		get_viewport().set_input_as_handled()
		_lock_power()
