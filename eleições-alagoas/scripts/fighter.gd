extends Node3D

const Prim = preload("res://scripts/prim.gd")

var id := ""
var display_name := ""
var tagline := ""
var fact := ""
var color := Color.WHITE

var is_player := false
var lives := 2
var max_lives := 2
var eliminated := false
var home := Vector3.ZERO

var body: Node3D
var head: Node3D
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var marker: Node3D
var bobbers: Array[Node3D] = []

var idle_enabled := true
var walking := false
var charging := false
var floating := false
var _t := 0.0
var _float_base := 0.0
var _buoy: Node3D


func _ready() -> void:
	_t = randf() * 10.0


func build_skeleton(c: Dictionary) -> void:
	var skin: Color = c.skin
	body = Prim.node(self, Vector3(0, 1.0, 0))
	Prim.cyl(body, 0.27, 0.23, 0.66, c.shirt, Vector3(0, 0.15, 0), Vector3.ZERO, Vector3(1, 1, 0.68))
	Prim.sphere(body, 0.27, c.shirt, Vector3(0, 0.45, 0), Vector3(1.0, 0.32, 0.68))
	Prim.cyl(body, 0.235, 0.24, 0.22, c.pants, Vector3(0, -0.15, 0), Vector3.ZERO, Vector3(1, 1, 0.7))
	Prim.cyl(body, 0.075, 0.08, 0.16, skin, Vector3(0, 0.53, 0))
	head = Prim.node(body, Vector3(0, 0.58, 0))
	Prim.sphere(head, 0.26, skin, Vector3(0, 0.26, 0))
	for s in [-1, 1]:
		Prim.sphere(head, 0.06, skin, Vector3(0.255 * s, 0.25, 0), Vector3(0.5, 1, 0.8))
		Prim.sphere(head, 0.055, Color(0.98, 0.98, 0.98), Vector3(0.09 * s, 0.31, 0.215))
		Prim.sphere(head, 0.03, Color(0.08, 0.06, 0.05), Vector3(0.09 * s, 0.31, 0.262))
	Prim.sphere(head, 0.045, skin.darkened(0.08), Vector3(0, 0.23, 0.255))
	arm_l = _make_arm(1, c)
	arm_r = _make_arm(-1, c)
	leg_l = _make_leg(1, c)
	leg_r = _make_leg(-1, c)


func _make_arm(side: int, c: Dictionary) -> Node3D:
	var p := Prim.node(body, Vector3(0.33 * side, 0.42, 0))
	if c.get("short_sleeves", false):
		Prim.cyl(p, 0.1, 0.095, 0.26, c.shirt, Vector3(0, -0.1, 0))
		Prim.capsule(p, 0.075, 0.6, c.skin, Vector3(0, -0.33, 0))
	else:
		Prim.capsule(p, 0.085, 0.64, c.shirt, Vector3(0, -0.3, 0))
	Prim.sphere(p, 0.085, c.skin, Vector3(0, -0.64, 0))
	return p


func _make_leg(side: int, c: Dictionary) -> Node3D:
	var p := Prim.node(body, Vector3(0.13 * side, -0.2, 0))
	if c.get("shorts", false):
		Prim.cyl(p, 0.125, 0.12, 0.26, c.pants, Vector3(0, -0.08, 0))
		Prim.capsule(p, 0.085, 0.72, c.skin, Vector3(0, -0.4, 0))
		Prim.cyl(p, 0.095, 0.09, 0.34, c.socks, Vector3(0, -0.57, 0))
	else:
		Prim.capsule(p, 0.1, 0.76, c.pants, Vector3(0, -0.38, 0))
	Prim.box(p, Vector3(0.17, 0.11, 0.3), c.shoes, Vector3(0, -0.745, 0.05))
	return p


func add_mouth(col := Color(0.55, 0.15, 0.15), w := 0.1, z := 0.232) -> void:
	Prim.box(head, Vector3(w, 0.028, 0.03), col, Vector3(0, 0.15, z))


func add_brows(col: Color, thick := 0.025) -> void:
	for s in [-1, 1]:
		Prim.box(head, Vector3(0.1, thick, 0.03), col, Vector3(0.09 * s, 0.385, 0.21), Vector3(0, 0, -8 * s))


func set_player_marker(on: bool) -> void:
	if marker == null:
		marker = Prim.node(self, Vector3(0, 2.6, 0))
		Prim.cyl(marker, 0.17, 0.0, 0.32, Color(0.2, 0.95, 0.35))
		Prim.sphere(marker, 0.17, Color(0.2, 0.95, 0.35), Vector3(0, 0.16, 0), Vector3(1, 0.4, 1))
	marker.visible = on


func _process(delta: float) -> void:
	_t += delta
	if marker and marker.visible:
		marker.rotation.y += delta * 2.5
		marker.position.y = 2.6 + sin(_t * 4.0) * 0.07
	for i in bobbers.size():
		bobbers[i].position.y = bobbers[i].get_meta("base_y") + sin(_t * 2.5 + i * 1.7) * 0.1
	if floating:
		position.y = _float_base + sin(_t * 2.0) * 0.08
		body.rotation.z = sin(_t * 1.3) * 0.15
		return
	if walking:
		var s := sin(_t * 12.0)
		leg_l.rotation.x = s * 0.6
		leg_r.rotation.x = -s * 0.6
		arm_l.rotation.x = -s * 0.5
		arm_r.rotation.x = s * 0.5
		body.position.y = 1.0 + absf(s) * 0.05
	elif idle_enabled:
		body.position.y = 1.0 + sin(_t * 2.2) * 0.025
		arm_l.rotation.z = 0.08 + sin(_t * 2.2) * 0.04
		arm_r.rotation.z = -0.08 - sin(_t * 2.2) * 0.04
		head.rotation.y = sin(_t * 0.8) * 0.2
	if charging:
		body.position.x = randf_range(-0.015, 0.015)


func reset_limbs() -> void:
	for n in [arm_l, arm_r, leg_l, leg_r, head]:
		n.rotation = Vector3.ZERO
	body.rotation = Vector3.ZERO
	body.position = Vector3(0, 1.0, 0)


func reset_for_game() -> void:
	eliminated = false
	floating = false
	walking = false
	charging = false
	if _buoy:
		_buoy.queue_free()
		_buoy = null
	reset_limbs()
	position = home
	rotation = Vector3.ZERO
	scale = Vector3.ONE
	visible = true
	for b in bobbers:
		b.visible = true
	idle_enabled = true


func turn_to_angle(a: float, dur := 0.2) -> void:
	var start := rotation.y
	var tw := create_tween()
	tw.tween_method(func(t: float): rotation.y = lerp_angle(start, a, t), 0.0, 1.0, dur)
	await tw.finished


func turn_to(dir: Vector3, dur := 0.2) -> void:
	await turn_to_angle(atan2(dir.x, dir.z), dur)


func walk_to(target: Vector3, dur := 0.8) -> void:
	idle_enabled = false
	var d := target - position
	d.y = 0
	if d.length() > 0.05:
		rotation.y = atan2(d.x, d.z)
	walking = true
	var tw := create_tween()
	tw.tween_property(self, "position", target, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	walking = false
	reset_limbs()


func wave() -> void:
	idle_enabled = false
	var tw := create_tween()
	tw.tween_property(arm_l, "rotation", Vector3(0, 0, deg_to_rad(160)), 0.3)
	for i in 3:
		tw.tween_property(arm_l, "rotation", Vector3(0, deg_to_rad(25), deg_to_rad(150)), 0.18)
		tw.tween_property(arm_l, "rotation", Vector3(0, deg_to_rad(-25), deg_to_rad(165)), 0.18)
	tw.tween_property(arm_l, "rotation", Vector3.ZERO, 0.3)
	await tw.finished
	idle_enabled = true


func celebrate() -> void:
	idle_enabled = false
	var tw := create_tween().set_loops(4)
	tw.tween_property(arm_l, "rotation", Vector3(0, 0, deg_to_rad(165)), 0.15)
	tw.parallel().tween_property(arm_r, "rotation", Vector3(0, 0, deg_to_rad(-165)), 0.15)
	tw.parallel().tween_property(body, "position:y", 1.45, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(body, "position:y", 1.0, 0.2).set_ease(Tween.EASE_IN)
	await tw.finished


func wind_up() -> void:
	idle_enabled = false
	charging = true
	var tw := create_tween().set_parallel()
	tw.tween_property(arm_r, "rotation", Vector3(0, deg_to_rad(-75), deg_to_rad(-105)), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(body, "rotation:y", deg_to_rad(-35), 0.35)
	tw.tween_property(arm_l, "rotation", Vector3(deg_to_rad(-30), 0, deg_to_rad(25)), 0.35)
	await tw.finished


func swing() -> void:
	charging = false
	body.position.x = 0
	var tw := create_tween().set_parallel()
	tw.tween_property(arm_r, "rotation", Vector3(0, deg_to_rad(85), deg_to_rad(-105)), 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(body, "rotation:y", deg_to_rad(40), 0.13)
	await tw.finished


func recover() -> void:
	var tw := create_tween().set_parallel()
	tw.tween_property(arm_r, "rotation", Vector3.ZERO, 0.4)
	tw.tween_property(arm_l, "rotation", Vector3.ZERO, 0.4)
	tw.tween_property(body, "rotation", Vector3.ZERO, 0.4)
	await tw.finished


func hit_react() -> void:
	var tw := create_tween()
	tw.tween_property(head, "rotation", Vector3(0.2, 1.0, 0.3), 0.05)


func launch(dir: Vector3, power: float, water_y: float) -> Vector3:
	idle_enabled = false
	walking = false
	charging = false
	if marker:
		marker.visible = false
	for b in bobbers:
		b.visible = false
	var start := position
	var dist := 8.5 + power * 12.0
	var height := 3.5 + power * 7.0
	var end := start + dir * dist
	if absf(end.x) < 8.5 and end.z > -6.5:
		end.z = -6.5
	end.y = water_y - 1.0
	var dur := 1.2 + power * 0.9
	var spins := float(1 + int(power * 2.0)) + 0.25
	var tw := create_tween().set_parallel()
	tw.tween_property(arm_l, "rotation", Vector3(0, 0, deg_to_rad(150)), 0.2)
	tw.tween_property(arm_r, "rotation", Vector3(0, 0, deg_to_rad(-150)), 0.2)
	tw.tween_property(leg_l, "rotation", Vector3(0, 0, deg_to_rad(25)), 0.2)
	tw.tween_property(leg_r, "rotation", Vector3(0, 0, deg_to_rad(-25)), 0.2)
	tw.tween_property(head, "rotation", Vector3.ZERO, 0.3)
	tw.tween_method(_fly.bind(start, end, height, spins), 0.0, 1.0, dur)
	await tw.finished
	body.rotation = Vector3(deg_to_rad(-90), 0, 0)
	arm_l.rotation = Vector3(0, 0, deg_to_rad(110))
	arm_r.rotation = Vector3(0, 0, deg_to_rad(-110))
	_float_base = position.y
	floating = true
	return end


func _fly(t: float, start: Vector3, end: Vector3, height: float, spins: float) -> void:
	var p := start.lerp(end, t)
	p.y = lerpf(start.y, end.y, t) + 4.0 * height * t * (1.0 - t)
	position = p
	body.rotation.x = -t * TAU * spins
	body.rotation.z = sin(t * PI) * 0.6


func respawn() -> void:
	floating = false
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 1.6, 0.5)
	await tw.finished
	reset_limbs()
	rotation = Vector3.ZERO
	position = home
	scale = Vector3.ONE * 0.01
	var tw2 := create_tween()
	tw2.tween_property(self, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await tw2.finished
	for b in bobbers:
		b.visible = true
	if marker:
		marker.visible = is_player
	idle_enabled = true


func eliminate() -> void:
	eliminated = true
	if _buoy == null:
		_buoy = Prim.node(body, Vector3(0, 0.05, 0))
		Prim.torus(_buoy, 0.26, 0.48, Color(1.0, 0.45, 0.05), Vector3.ZERO, Vector3.ZERO, Vector3(1, 1.6, 0.85))
		for i in 4:
			var a := i * PI / 2.0 + PI / 4.0
			Prim.box(_buoy, Vector3(0.1, 0.2, 0.1), Color.WHITE, Vector3(cos(a) * 0.37, 0, sin(a) * 0.37 * 0.85), Vector3(0, -rad_to_deg(a), 0))
