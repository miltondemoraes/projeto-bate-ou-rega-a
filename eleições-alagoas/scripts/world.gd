extends RefCounted

const Prim = preload("res://scripts/prim.gd")

const WATER_Y := -0.8
const SAND := Color(0.93, 0.85, 0.66)
const WOOD := Color(0.62, 0.42, 0.26)

const WATER_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec4 shallow : source_color = vec4(0.12, 0.78, 0.74, 1.0);
uniform vec4 deep : source_color = vec4(0.02, 0.33, 0.56, 1.0);
uniform vec4 foam : source_color = vec4(0.92, 0.98, 1.0, 1.0);
varying float wave;
varying vec3 wpos;

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float a = w.x * 0.35 + TIME * 1.3;
	float b = w.z * 0.5 - TIME * 1.1;
	float c = (w.x + w.z) * 0.9 + TIME * 2.0;
	float h = sin(a) * 0.08 + sin(b) * 0.07 + sin(c) * 0.03;
	VERTEX.y += h;
	float dx = cos(a) * 0.028 + cos(c) * 0.027;
	float dz = cos(b) * 0.035 + cos(c) * 0.027;
	NORMAL = normalize(vec3(-dx, 1.0, -dz));
	wave = h;
	wpos = w;
}

void fragment() {
	float shore = clamp((wpos.z + 25.0) / 28.0, 0.0, 1.0);
	vec3 col = mix(deep.rgb, shallow.rgb, shore);
	col = mix(col, foam.rgb, smoothstep(0.1, 0.17, wave) * 0.5);
	ALBEDO = col;
	ROUGHNESS = 0.08;
	SPECULAR = 0.7;
}
"""


static func build(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1889
	_environment(root)
	_sea(root)
	_beach(root)
	_deck(root)
	_seahorse(root, Vector3(11.0, WATER_Y, -9.0), rng)
	_coral_sculptures(root, rng)
	_gogo_da_ema(root, Vector3(-10.5, -0.55, 6.0))
	for p in [Vector3(-15, -0.55, 9), Vector3(13.5, -0.55, 7.5), Vector3(17, -0.55, 12), Vector3(-19, -0.55, 14), Vector3(9.5, -0.55, 13)]:
		_palm(root, p, rng)
	_jangada(root, Vector3(-14, WATER_Y, -15), 30, Color(0.95, 0.3, 0.2))
	_jangada(root, Vector3(-3, WATER_Y, -28), -10, Color(0.98, 0.98, 0.95))
	_jangada(root, Vector3(18, WATER_Y, -22), 60, Color(0.2, 0.55, 0.95))
	_reefs(root, rng)
	_skyline(root, rng)
	_sky_props(root, rng)


static func _environment(root: Node3D) -> void:
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.2, 0.47, 0.86)
	sm.sky_horizon_color = Color(0.72, 0.86, 0.96)
	sm.ground_horizon_color = Color(0.62, 0.76, 0.86)
	sm.ground_bottom_color = Color(0.22, 0.34, 0.42)
	var sky := Sky.new()
	sky.sky_material = sm
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(1.0, 0.96, 0.9)
	env.ambient_light_sky_contribution = 0.55
	env.ambient_light_energy = 1.3
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	env.ssao_enabled = true
	env.ssao_radius = 0.9
	env.ssao_intensity = 1.8
	env.fog_enabled = true
	env.fog_light_color = Color(0.72, 0.85, 0.95)
	env.fog_density = 0.005
	env.fog_sky_affect = 0.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.15
	var we := WorldEnvironment.new()
	we.name = "LuzGlobal"
	we.environment = env
	root.add_child(we)


static func _sea(root: Node3D) -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(320, 320)
	plane.subdivide_width = 160
	plane.subdivide_depth = 160
	var sh := Shader.new()
	sh.code = WATER_SHADER
	var m := ShaderMaterial.new()
	m.shader = sh
	var mi := MeshInstance3D.new()
	mi.name = "Mar"
	mi.mesh = plane
	mi.material_override = m
	mi.position = Vector3(0, WATER_Y, -40)
	root.add_child(mi)


static func _beach(root: Node3D) -> void:
	Prim.box(root, Vector3(200, 1.0, 60), SAND, Vector3(0, -1.05, 34))
	Prim.box(root, Vector3(200, 0.3, 5), SAND.darkened(0.12), Vector3(0, -0.85, 2.6), Vector3(-9, 0, 0))
	Prim.box(root, Vector3(70, 0.08, 6), Color(0.92, 0.9, 0.84), Vector3(0, -0.51, 13))
	for i in 24:
		var x := -34.0 + i * 3.0
		Prim.box(root, Vector3(1.4, 0.09, 6), Color(0.35, 0.33, 0.32), Vector3(x, -0.505, 13), Vector3(0, 25, 0))
	for x in [-16.0, -6.0, 6.0, 16.0]:
		Prim.box(root, Vector3(1.8, 0.1, 0.5), WOOD, Vector3(x, -0.05, 11))
		for s in [-1, 1]:
			Prim.box(root, Vector3(0.1, 0.45, 0.4), Color(0.3, 0.3, 0.32), Vector3(x + 0.75 * s, -0.3, 11))
	for x in [-21.0, -11.0, 0.0, 11.0, 21.0]:
		Prim.cyl(root, 0.06, 0.08, 4.0, Color(0.25, 0.27, 0.3), Vector3(x, 1.45, 15.5))
		Prim.sphere(root, 0.22, Color(0.95, 0.95, 0.9), Vector3(x, 3.5, 15.5))


static func _deck(root: Node3D) -> void:
	Prim.box(root, Vector3(15, 0.3, 9), WOOD, Vector3(0, -0.15, -0.5))
	for i in range(-14, 15):
		Prim.box(root, Vector3(0.03, 0.02, 9), WOOD.darkened(0.35), Vector3(i * 0.5, 0.005, -0.5))
	for x in [-7.0, -3.5, 0.0, 3.5, 7.0]:
		for z in [-4.7, -0.5, 3.6]:
			Prim.cyl(root, 0.16, 0.16, 2.2, WOOD.darkened(0.3), Vector3(x, -1.2, z))
	var white := Color(0.96, 0.96, 0.96)
	for i in 11:
		Prim.cyl(root, 0.04, 0.04, 0.9, white, Vector3(-7.2 + i * 1.44, 0.45, -4.85))
	Prim.box(root, Vector3(14.6, 0.08, 0.1), white, Vector3(0, 0.92, -4.85))
	for s in [-1, 1]:
		for i in 6:
			Prim.cyl(root, 0.04, 0.04, 0.9, white, Vector3(7.35 * s, 0.45, -4.85 + i * 1.6))
		Prim.box(root, Vector3(0.1, 0.08, 8.2), white, Vector3(7.35 * s, 0.92, -0.75))
	var spot_cols := [Color(0.25, 0.4, 0.85), Color(0.85, 0.15, 0.2), Color(0.95, 0.6, 0.1), Color(0.1, 0.65, 0.3)]
	for i in 4:
		var x := -4.5 + i * 3.0
		Prim.cyl(root, 0.62, 0.62, 0.05, Color.WHITE, Vector3(x, 0.02, 0.5))
		Prim.cyl(root, 0.55, 0.55, 0.06, spot_cols[i], Vector3(x, 0.025, 0.5))
	var truss := Color(0.75, 0.76, 0.8)
	for s in [-1, 1]:
		Prim.box(root, Vector3(0.4, 6.0, 0.4), truss, Vector3(6.8 * s, 3.0, -4.2), Vector3.ZERO, 0.4, 0.7)
		for k in 6:
			Prim.box(root, Vector3(0.46, 0.06, 0.46), truss.darkened(0.3), Vector3(6.8 * s, 0.5 + k, -4.2))
	Prim.box(root, Vector3(14.0, 0.5, 0.5), truss, Vector3(0, 6.1, -4.2), Vector3.ZERO, 0.4, 0.7)
	var cols := [Color(1, 0.8, 0.1), Color(0.9, 0.2, 0.2), Color(0.15, 0.5, 0.95), Color(0.1, 0.7, 0.35)]
	for i in 8:
		Prim.box(root, Vector3(1.2, 1.2, 0.15), cols[i % 4], Vector3(-4.2 + i * 1.2, 7.0, -4.2))
	for i in 5:
		var x := -5.0 + i * 2.5
		var lamp := Prim.node(root, Vector3(x, 5.65, -4.0), Vector3(-35, 0, 0))
		Prim.cyl(lamp, 0.18, 0.24, 0.4, Color(0.1, 0.1, 0.12), Vector3.ZERO, Vector3(90, 0, 0))
		Prim.cyl(lamp, 0.2, 0.2, 0.02, Color(1, 0.95, 0.7), Vector3(0, 0, 0.21), Vector3(90, 0, 0))


static func _seahorse(root: Node3D, base: Vector3, rng: RandomNumberGenerator) -> void:
	var n := Prim.node(root, base, Vector3(0, -40, 0))
	n.scale = Vector3.ONE * 1.25
	Prim.sphere(n, 1.4, Color(0.35, 0.32, 0.28), Vector3(0, 0, 0), Vector3(1.3, 0.55, 1.2))
	var tiles := [Color(0.05, 0.45, 0.78), Color(0.1, 0.72, 0.82), Color(0.12, 0.55, 0.42), Color(0.98, 0.78, 0.2), Color(0.04, 0.28, 0.6)]
	var spine := [
		Vector3(1.3, -0.15, 0.32), Vector3(1.9, 0.12, 0.52), Vector3(2.5, 0.3, 0.68), Vector3(3.1, 0.32, 0.74),
		Vector3(3.7, 0.12, 0.64), Vector3(4.2, -0.15, 0.5), Vector3(4.7, -0.25, 0.42), Vector3(5.2, -0.08, 0.5),
	]
	var idx := 0
	for i in spine.size() - 1:
		for k in 4:
			var t := k / 4.0
			var p: Vector3 = spine[i].lerp(spine[i + 1], t)
			Prim.sphere(n, p.z, tiles[idx % tiles.size()], Vector3(0, p.x, p.y), Vector3(0.8, 1, 1), 0.15, 0.2)
			idx += 1
	for i in 70:
		var sp: Vector3 = spine[rng.randi_range(1, spine.size() - 2)]
		var a := rng.randf() * TAU
		var pos := Vector3(cos(a) * sp.z * 0.8, sp.x + rng.randf_range(-0.25, 0.25), sp.y + sin(a) * sp.z)
		var tile := Prim.box(n, Vector3(0.12, 0.12, 0.12), tiles[rng.randi() % tiles.size()], pos, Vector3.ZERO, 0.1, 0.3)
		tile.basis = Prim.basis_y(pos - Vector3(0, sp.x, sp.y))
	Prim.cyl(n, 0.11, 0.2, 1.0, tiles[1], Vector3(0, 5.0, 0.75), Vector3(108, 0, 0), Vector3.ONE, 0.15, 0.2)
	for s in [-1, 1]:
		Prim.sphere(n, 0.13, Color.WHITE, Vector3(0.33 * s, 5.35, 0.12))
		Prim.sphere(n, 0.07, Color(0.05, 0.05, 0.08), Vector3(0.41 * s, 5.37, 0.15))
	for i in 4:
		Prim.cyl(n, 0.0, 0.1, 0.35, tiles[3], Vector3(0, 5.65 + i * 0.05, -0.2 - i * 0.15), Vector3(-30 - i * 10, 0, 0))
	Prim.prism(n, Vector3(0.08, 1.2, 0.8), Color(0.98, 0.78, 0.2, 0.85), Vector3(0, 3.2, -0.75), Vector3(90, 0, 0))
	Prim.torus(n, 0.22, 0.48, tiles[0], Vector3(0, 0.95, -0.35), Vector3(0, 0, 90))
	Prim.sphere(n, 0.2, tiles[2], Vector3(0, 0.6, -0.15))


static func _branch(parent: Node3D, pos: Vector3, dir: Vector3, length: float, radius: float, color: Color, depth: int, rng: RandomNumberGenerator) -> void:
	var end := pos + dir * length
	Prim.segment(parent, pos, end, radius, radius * 0.75, color)
	Prim.sphere(parent, radius * 0.8, color.lightened(0.15), end)
	if depth <= 0:
		return
	for k in rng.randi_range(2, 3):
		var nd := (dir + Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(0.1, 0.6), rng.randf_range(-0.9, 0.9))).normalized()
		_branch(parent, end, nd, length * 0.72, radius * 0.72, color, depth - 1, rng)


static func _coral(root: Node3D, pos: Vector3, scale: float, color: Color, rng: RandomNumberGenerator) -> void:
	var n := Prim.node(root, pos)
	n.scale = Vector3.ONE * scale
	Prim.cyl(n, 0.5, 0.6, 0.3, Color(0.85, 0.82, 0.76), Vector3(0, 0.15, 0))
	_branch(n, Vector3(0, 0.3, 0), Vector3.UP, 0.9, 0.16, color, 3, rng)


static func _brain_coral(root: Node3D, pos: Vector3, r: float, color: Color) -> void:
	Prim.sphere(root, r, color, pos, Vector3(1, 0.7, 1))
	for i in 4:
		Prim.torus(root, r * (0.25 + i * 0.18), r * (0.32 + i * 0.18), color.darkened(0.25), pos + Vector3(0, r * 0.55 - i * 0.08 * r, 0), Vector3.ZERO, Vector3(1, 1.5, 1))


static func _coral_sculptures(root: Node3D, rng: RandomNumberGenerator) -> void:
	_coral(root, Vector3(-7.0, -0.55, 6.5), 1.8, Color(0.98, 0.45, 0.35), rng)
	_coral(root, Vector3(7.8, -0.55, 6.0), 1.6, Color(0.75, 0.35, 0.85), rng)
	_coral(root, Vector3(-4.0, -0.55, 8.5), 1.0, Color(1.0, 0.7, 0.2), rng)
	_brain_coral(root, Vector3(4.5, -0.45, 8.0), 0.7, Color(0.95, 0.55, 0.6))
	_brain_coral(root, Vector3(-12.5, -0.45, 4.8), 0.6, Color(0.5, 0.8, 0.5))
	for i in 10:
		var p := Vector3(rng.randf_range(-14, 14), WATER_Y - 0.5, rng.randf_range(-12, -6))
		_coral(root, p, rng.randf_range(0.6, 1.0), [Color(1, 0.5, 0.4), Color(0.9, 0.4, 0.8), Color(1, 0.8, 0.3)][i % 3], rng)


static func _crown(root: Node3D, top: Vector3, rng: RandomNumberGenerator) -> void:
	for k in 9:
		var leaf := Prim.node(root, top, Vector3(rng.randf_range(15, 35), k * 40.0 + rng.randf_range(-8, 8), 0))
		Prim.sphere(leaf, 0.95, Color(0.18, 0.55, 0.2).lightened(rng.randf_range(0, 0.15)), Vector3(0, 0, 0.95), Vector3(0.32, 0.05, 1.0))
	for k in 3:
		var a := k * TAU / 3.0
		Prim.sphere(root, 0.15, Color(0.45, 0.3, 0.12), top + Vector3(cos(a) * 0.2, -0.2, sin(a) * 0.2))


static func _palm(root: Node3D, base: Vector3, rng: RandomNumberGenerator) -> void:
	var lean := Vector3(rng.randf_range(-0.6, 0.6), 0, rng.randf_range(-0.6, 0.6))
	var prev := base
	var h := rng.randf_range(5.0, 7.0)
	for i in 8:
		var t := (i + 1) / 8.0
		var p := base + Vector3(0, h * t, 0) + lean * t * t * 3.0
		Prim.segment(root, prev, p, 0.2 - 0.06 * t + 0.06 / 8.0, 0.2 - 0.06 * t, Color(0.55, 0.42, 0.28).darkened(0.12 * (i % 2)))
		prev = p
	_crown(root, prev, rng)


static func _gogo_da_ema(root: Node3D, base: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1955
	var pts := [Vector3(0, 0, 0), Vector3(0.5, 0.6, 0), Vector3(1.3, 1.0, 0.1), Vector3(2.3, 1.1, 0.2), Vector3(3.1, 1.4, 0.2),
		Vector3(3.5, 2.2, 0.1), Vector3(3.55, 3.2, 0.0), Vector3(3.3, 4.2, -0.1), Vector3(2.9, 5.0, -0.1)]
	var n := Prim.node(root, base, Vector3(0, 150, 0))
	for i in pts.size() - 1:
		Prim.segment(n, pts[i], pts[i + 1], 0.22 - i * 0.01, 0.21 - i * 0.01, Color(0.55, 0.42, 0.28).darkened(0.1 * (i % 2)))
		Prim.sphere(n, 0.21 - i * 0.01, Color(0.5, 0.38, 0.25), pts[i + 1])
	_crown(n, pts[-1], rng)
	Prim.cyl(root, 1.3, 1.4, 0.25, Color(0.6, 0.6, 0.58), base + Vector3(0, 0.1, 0))
	Prim.cyl(root, 1.15, 1.15, 0.27, Color(0.35, 0.28, 0.2), base + Vector3(0, 0.1, 0))


static func _jangada(root: Node3D, pos: Vector3, yaw: float, sail: Color) -> void:
	var n := Prim.node(root, pos + Vector3(0, 0.1, 0), Vector3(0, yaw, 0))
	for i in 5:
		Prim.cyl(n, 0.13, 0.13, 3.6, Color(0.7, 0.55, 0.35), Vector3(0, 0, -0.5 + i * 0.25), Vector3(0, 0, 90))
	Prim.box(n, Vector3(0.6, 0.35, 0.4), Color(0.55, 0.4, 0.25), Vector3(-1.0, 0.3, 0))
	Prim.cyl(n, 0.05, 0.06, 4.5, Color(0.45, 0.32, 0.2), Vector3(0.6, 2.3, 0))
	Prim.prism(n, Vector3(2.4, 3.8, 0.04), sail, Vector3(-0.6, 2.6, 0), Vector3.ZERO, 1.0)
	Prim.box(n, Vector3(2.4, 0.06, 0.06), Color(0.45, 0.32, 0.2), Vector3(-0.6, 0.7, 0))
	var tw := n.create_tween().set_loops()
	tw.tween_property(n, "rotation_degrees:z", 4.0, 1.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(n, "rotation_degrees:z", -4.0, 1.6).set_trans(Tween.TRANS_SINE)


static func _reefs(root: Node3D, rng: RandomNumberGenerator) -> void:
	for i in 26:
		var p := Vector3(rng.randf_range(-60, 60), WATER_Y - 0.15, rng.randf_range(-55, -32))
		Prim.sphere(root, rng.randf_range(1.0, 2.6), Color(0.35, 0.33, 0.22).lerp(Color(0.2, 0.45, 0.3), rng.randf()), p, Vector3(1.4, 0.18, 1.0))


static func _skyline(root: Node3D, rng: RandomNumberGenerator) -> void:
	Prim.box(root, Vector3(80, 1.0, 30), SAND, Vector3(-75, -1.0, -45), Vector3(0, 35, 0))
	for i in 22:
		var t := i / 21.0
		var base := Vector3(-48 - t * 45, -0.5, -18 - t * 55)
		var h := rng.randf_range(6, 26)
		var w := rng.randf_range(3, 6)
		var col := Color(0.93, 0.92, 0.88).lerp(Color(0.85, 0.78, 0.65), rng.randf())
		Prim.box(root, Vector3(w, h, w), col, base + Vector3(rng.randf_range(-6, 6), h / 2.0, rng.randf_range(-4, 4)), Vector3(0, 35, 0))
	for k in 3:
		var p := Vector3(-60 - k * 8, -0.5, -70 + k * 4)
		Prim.box(root, Vector3(0.8, 14, 0.8), Color(0.9, 0.45, 0.1), p + Vector3(0, 7, 0))
		Prim.box(root, Vector3(12, 0.7, 0.7), Color(0.9, 0.45, 0.1), p + Vector3(3, 13.5, 0), Vector3(0, 35, 0))
	Prim.cyl(root, 0.9, 1.3, 12, Color.WHITE, Vector3(-38, 5.5, -60))
	for k in 3:
		Prim.cyl(root, 1.0 - k * 0.05, 1.05 - k * 0.05, 1.2, Color(0.85, 0.1, 0.1), Vector3(-38, 1.5 + k * 3.2, -60))
	Prim.cyl(root, 0.0, 1.1, 1.2, Color(0.85, 0.1, 0.1), Vector3(-38, 12.2, -60))


static func _sky_props(root: Node3D, rng: RandomNumberGenerator) -> void:
	var sun := Prim.sphere(root, 9.0, Color(1.0, 0.93, 0.6), Vector3(70, 75, -170))
	var sun_mat := StandardMaterial3D.new()
	sun_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sun_mat.albedo_color = Color(1.0, 0.95, 0.7)
	sun_mat.disable_fog = true
	sun.material_override = sun_mat
	for c in 9:
		var cloud := Prim.node(root, Vector3(rng.randf_range(-120, 120), rng.randf_range(28, 45), rng.randf_range(-160, -90)))
		for k in 5:
			Prim.sphere(cloud, rng.randf_range(4, 7), Color(1, 1, 1), Vector3(k * 4.5 - 9, rng.randf_range(-1, 1.5), rng.randf_range(-2, 2)), Vector3(1.2, 0.7, 1.0))
		var tw := cloud.create_tween().set_loops()
		tw.tween_property(cloud, "position:x", cloud.position.x + 25, 40.0).set_trans(Tween.TRANS_SINE)
		tw.tween_property(cloud, "position:x", cloud.position.x, 40.0).set_trans(Tween.TRANS_SINE)
