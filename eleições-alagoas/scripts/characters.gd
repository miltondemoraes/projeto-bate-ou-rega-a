extends RefCounted

const Prim = preload("res://scripts/prim.gd")
const Fighter = preload("res://scripts/fighter.gd")

const ROSTER := ["deodoro", "firmino", "djavan", "zagallo"]

const INFO := {
	"deodoro": {
		"name": "Marechal Deodoro",
		"tag": "1º presidente do Brasil",
		"fact": "Manuel Deodoro da Fonseca nasceu em Alagoas, na cidade que hoje leva o seu nome. Proclamou a República em 15 de novembro de 1889.",
		"color": Color(0.2, 0.32, 0.62),
	},
	"firmino": {
		"name": "Roberto Firmino",
		"tag": "Atacante camisa 9",
		"fact": "Nasceu em Maceió. Brilhou no Liverpool e na Seleção Brasileira, famoso pelo sorrisão e pelos gols sem olhar para a bola.",
		"color": Color(0.8, 0.1, 0.18),
	},
	"djavan": {
		"name": "Djavan",
		"tag": "Cantor e compositor",
		"fact": "Djavan nasceu em Maceió em 1949. É autor de sucessos como \"Flor de Lis\", \"Oceano\" e \"Sina\".",
		"color": Color(0.85, 0.5, 0.1),
	},
	"zagallo": {
		"name": "Zagallo",
		"tag": "O Velho Lobo, camisa 13",
		"fact": "Mário Jorge Lobo Zagallo nasceu em Atalaia (AL). Ganhou 4 Copas do Mundo com o Brasil e adorava o número 13.",
		"color": Color(0.1, 0.6, 0.3),
	},
}


static func create(id: String) -> Node3D:
	var f := Fighter.new()
	var info: Dictionary = INFO[id]
	f.id = id
	f.name = id.capitalize()
	f.display_name = info.name
	f.tagline = info.tag
	f.fact = info.fact
	f.color = info.color
	match id:
		"deodoro": _deodoro(f)
		"firmino": _firmino(f)
		"djavan": _djavan(f)
		"zagallo": _zagallo(f)
	return f


static func _deodoro(f) -> void:
	var skin := Color(0.93, 0.76, 0.62)
	var navy := Color(0.1, 0.15, 0.32)
	var gold := Color(0.95, 0.74, 0.2)
	var white := Color(0.95, 0.95, 0.93)
	var black := Color(0.05, 0.05, 0.06)
	f.build_skeleton({"skin": skin, "shirt": navy, "pants": Color(0.22, 0.26, 0.38), "shoes": black})
	var b: Node3D = f.body
	Prim.cyl(b, 0.25, 0.31, 0.34, navy, Vector3(0, -0.22, 0), Vector3.ZERO, Vector3(1, 1, 0.75))
	Prim.cyl(b, 0.095, 0.1, 0.08, gold, Vector3(0, 0.5, 0), Vector3.ZERO, Vector3.ONE, 0.4, 0.7)
	for i in 5:
		for s in [-1, 1]:
			Prim.sphere(b, 0.022, gold, Vector3(0.075 * s, 0.38 - i * 0.1, 0.175), Vector3.ONE, 0.3, 0.8)
	for s in [-1, 1]:
		Prim.cyl(b, 0.1, 0.11, 0.05, gold, Vector3(0.31 * s, 0.53, 0), Vector3(0, 0, -14 * s), Vector3.ONE, 0.35, 0.8)
		Prim.cyl(b, 0.12, 0.125, 0.08, gold.darkened(0.2), Vector3(0.32 * s, 0.47, 0), Vector3(0, 0, -14 * s), Vector3.ONE, 0.5, 0.6)
	Prim.box(b, Vector3(0.1, 0.8, 0.39), Color(0.0, 0.55, 0.25), Vector3(0, 0.15, 0), Vector3(0, 0, 38))
	Prim.box(b, Vector3(0.03, 0.81, 0.395), Color(1.0, 0.85, 0.1), Vector3(0, 0.15, 0), Vector3(0, 0, 38))
	for i in 3:
		var p := Vector3(0.1 + i * 0.055, 0.33, 0.18)
		Prim.box(b, Vector3(0.04, 0.05, 0.02), [Color(0.8, 0.1, 0.1), Color(0.1, 0.3, 0.8), Color(0.1, 0.6, 0.3)][i], p)
		Prim.cyl(b, 0.022, 0.022, 0.012, gold, p + Vector3(0, -0.055, 0.005), Vector3(90, 0, 0), Vector3.ONE, 0.3, 0.9)
	Prim.cyl(b, 0.245, 0.245, 0.05, black, Vector3(0, -0.04, 0), Vector3.ZERO, Vector3(1, 1, 0.72))
	Prim.box(b, Vector3(0.07, 0.06, 0.02), gold, Vector3(0, -0.04, 0.18), Vector3.ZERO, 0.3, 0.9)
	Prim.cyl(b, 0.022, 0.018, 0.85, Color(0.75, 0.76, 0.8), Vector3(0.29, -0.45, 0.06), Vector3(14, 0, 6), Vector3.ONE, 0.25, 0.9)
	Prim.box(b, Vector3(0.14, 0.025, 0.04), gold, Vector3(0.28, -0.02, 0.0), Vector3.ZERO, 0.3, 0.9)
	Prim.cyl(b, 0.02, 0.02, 0.12, black, Vector3(0.28, 0.05, -0.01))
	for arm in [f.arm_l, f.arm_r]:
		Prim.cyl(arm, 0.092, 0.092, 0.07, gold, Vector3(0, -0.55, 0), Vector3.ZERO, Vector3.ONE, 0.4, 0.7)
	for pair in [[f.leg_l, 1], [f.leg_r, -1]]:
		var leg: Node3D = pair[0]
		Prim.box(leg, Vector3(0.025, 0.4, 0.05), Color(0.75, 0.1, 0.12), Vector3(0.095 * pair[1], -0.2, 0))
		Prim.cyl(leg, 0.115, 0.105, 0.38, black, Vector3(0, -0.56, 0), Vector3.ZERO, Vector3.ONE, 0.3)
	var h: Node3D = f.head
	Prim.sphere(h, 0.2, white, Vector3(0, 0.27, -0.12), Vector3(1.25, 0.9, 0.75))
	for s in [-1, 1]:
		Prim.sphere(h, 0.1, white, Vector3(0.21 * s, 0.32, -0.03), Vector3(0.7, 1.0, 1.2))
	Prim.sphere(h, 0.2, white, Vector3(0, 0.07, 0.12), Vector3(1.15, 1.2, 0.85))
	for s in [-1, 1]:
		Prim.capsule(h, 0.035, 0.2, white, Vector3(0.075 * s, 0.17, 0.245), Vector3(0, 0, 72 * s))
	f.add_brows(white, 0.035)
	var kepi := Prim.node(f.arm_l, Vector3(0, -0.72, 0.1), Vector3(-20, 0, 0))
	Prim.cyl(kepi, 0.12, 0.13, 0.14, navy, Vector3.ZERO)
	Prim.cyl(kepi, 0.132, 0.132, 0.035, gold, Vector3(0, -0.04, 0), Vector3.ZERO, Vector3.ONE, 0.4, 0.8)
	Prim.cyl(kepi, 0.13, 0.13, 0.02, Color(0.75, 0.1, 0.12), Vector3(0, 0.07, 0))
	Prim.box(kepi, Vector3(0.18, 0.015, 0.09), black, Vector3(0, -0.065, 0.14), Vector3(-12, 0, 0))


static func _firmino(f) -> void:
	var skin := Color(0.55, 0.36, 0.24)
	var red := Color(0.78, 0.06, 0.15)
	var white := Color(0.97, 0.97, 0.97)
	var dark := Color(0.12, 0.08, 0.06)
	f.build_skeleton({"skin": skin, "shirt": red, "short_sleeves": true, "pants": red, "shorts": true,
		"socks": red, "shoes": Color(0.2, 0.95, 0.45)})
	var b: Node3D = f.body
	Prim.cyl(b, 0.1, 0.11, 0.04, white, Vector3(0, 0.5, 0))
	Prim.number(b, "9", white, Vector3(0, 0.2, -0.185), 0.32, true)
	Prim.number(b, "9", white, Vector3(-0.12, 0.33, 0.18), 0.1, false)
	Prim.box(b, Vector3(0.06, 0.07, 0.02), Color(0.95, 0.8, 0.3), Vector3(0.12, 0.33, 0.18))
	for arm in [f.arm_l, f.arm_r]:
		Prim.cyl(arm, 0.1, 0.1, 0.03, white, Vector3(0, -0.22, 0))
		Prim.box(arm, Vector3(0.02, 0.2, 0.08), skin.darkened(0.5), Vector3(0, -0.42, 0.068))
	for leg in [f.leg_l, f.leg_r]:
		Prim.cyl(leg, 0.097, 0.097, 0.03, white, Vector3(0, -0.41, 0))
	var h: Node3D = f.head
	Prim.sphere(h, 0.27, dark, Vector3(0, 0.36, -0.03), Vector3(1.0, 0.65, 1.0))
	Prim.box(h, Vector3(0.17, 0.075, 0.03), Color(0.35, 0.12, 0.1), Vector3(0, 0.15, 0.226))
	Prim.box(h, Vector3(0.15, 0.05, 0.03), white, Vector3(0, 0.152, 0.234))
	Prim.sphere(h, 0.07, dark, Vector3(0, 0.05, 0.2), Vector3(1.2, 0.6, 0.7))
	f.add_brows(dark)
	var ball := Prim.node(f, Vector3(0.38, 0.11, 0.35))
	Prim.sphere(ball, 0.11, white)
	for d in [Vector3.UP, Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT, Vector3(0.6, 0.6, 0.6).normalized()]:
		Prim.sphere(ball, 0.04, dark, d * 0.095, Vector3(1, 1, 1))


static func _djavan(f) -> void:
	var skin := Color(0.45, 0.29, 0.18)
	var shirt := Color(0.95, 0.91, 0.82)
	var wood := Color(0.78, 0.5, 0.25)
	var brown := Color(0.3, 0.18, 0.1)
	f.build_skeleton({"skin": skin, "shirt": shirt, "pants": Color(0.25, 0.22, 0.2), "shoes": brown})
	var b: Node3D = f.body
	Prim.prism(b, Vector3(0.13, 0.15, 0.02), skin, Vector3(0, 0.42, 0.172), Vector3(0, 0, 180))
	for i in 4:
		Prim.sphere(b, 0.015, brown, Vector3(0, 0.28 - i * 0.1, 0.175))
	var beads := [Color(0.9, 0.2, 0.2), Color(1, 0.8, 0.1), Color(0.1, 0.6, 0.3), Color(0.2, 0.4, 0.9)]
	for i in 9:
		var a := lerpf(-1.1, 1.1, i / 8.0)
		Prim.sphere(b, 0.022, beads[i % 4], Vector3(sin(a) * 0.15, 0.5 - cos(a) * 0.12, 0.17 + cos(a) * 0.02))
	Prim.box(b, Vector3(0.04, 0.82, 0.39), brown, Vector3(0, 0.15, 0), Vector3(0, 0, -35))
	var g := Prim.node(b, Vector3(0.02, 0.0, -0.27), Vector3(0, 0, 35))
	Prim.cyl(g, 0.21, 0.21, 0.1, wood, Vector3(0, -0.12, 0), Vector3(90, 0, 0))
	Prim.cyl(g, 0.16, 0.16, 0.1, wood, Vector3(0, 0.13, 0), Vector3(90, 0, 0))
	Prim.cyl(g, 0.055, 0.055, 0.01, Color(0.05, 0.03, 0.02), Vector3(0, 0.0, -0.052), Vector3(90, 0, 0))
	Prim.box(g, Vector3(0.06, 0.5, 0.03), brown, Vector3(0, 0.5, 0))
	Prim.box(g, Vector3(0.08, 0.13, 0.035), brown.darkened(0.3), Vector3(0, 0.81, 0))
	var h: Node3D = f.head
	var grey := Color(0.42, 0.4, 0.38)
	var light := Color(0.68, 0.66, 0.63)
	Prim.sphere(h, 0.28, grey, Vector3(0, 0.36, -0.03), Vector3(1.02, 0.68, 1.02))
	var k := 0
	for deg in range(-135, 136, 18):
		var a := deg_to_rad(deg)
		var ln := 0.6 if absf(deg) < 100 else 0.38
		var top := Vector3(sin(a) * 0.25, 0.36, -cos(a) * 0.25)
		Prim.capsule(h, 0.042, ln, grey if k % 2 == 0 else light, top + Vector3(sin(a) * 0.04, -ln / 2.0 + 0.04, -cos(a) * 0.04), Vector3(cos(a) * -6.0, 0, sin(a) * 6.0))
		k += 1
	Prim.sphere(h, 0.17, light, Vector3(0, 0.08, 0.11), Vector3(1.25, 0.85, 0.95))
	Prim.capsule(h, 0.03, 0.2, light, Vector3(0, 0.185, 0.24), Vector3(0, 0, 90))
	f.add_mouth(Color(0.45, 0.12, 0.12), 0.09, 0.262)
	f.add_brows(grey)
	for spec in [[Vector3(0.55, 2.25, 0.1), 1], [Vector3(-0.55, 2.4, 0.0), 2]]:
		var n := Prim.node(f, spec[0])
		n.set_meta("base_y", spec[0].y)
		Prim.sphere(n, 0.06, Color(0.08, 0.08, 0.1), Vector3.ZERO, Vector3(1.25, 0.9, 0.6))
		Prim.cyl(n, 0.012, 0.012, 0.24, Color(0.08, 0.08, 0.1), Vector3(0.06, 0.12, 0))
		if spec[1] == 2:
			Prim.box(n, Vector3(0.1, 0.03, 0.02), Color(0.08, 0.08, 0.1), Vector3(0.1, 0.23, 0), Vector3(0, 0, -20))
		f.bobbers.append(n)


static func _zagallo(f) -> void:
	var skin := Color(0.9, 0.72, 0.58)
	var yellow := Color(1.0, 0.85, 0.05)
	var green := Color(0.0, 0.58, 0.27)
	var blue := Color(0.1, 0.25, 0.65)
	var black := Color(0.06, 0.06, 0.07)
	f.build_skeleton({"skin": skin, "shirt": yellow, "short_sleeves": true, "pants": blue, "shorts": true,
		"socks": Color(0.97, 0.97, 0.97), "shoes": black})
	var b: Node3D = f.body
	for s in [-1, 1]:
		Prim.box(b, Vector3(0.03, 0.14, 0.02), green, Vector3(0.04 * s, 0.44, 0.172), Vector3(0, 0, 25 * s))
	Prim.cyl(b, 0.1, 0.11, 0.035, green, Vector3(0, 0.505, 0))
	for arm in [f.arm_l, f.arm_r]:
		Prim.cyl(arm, 0.1, 0.1, 0.035, green, Vector3(0, -0.22, 0))
	Prim.number(b, "13", green, Vector3(0, 0.2, -0.185), 0.3, true)
	Prim.number(b, "13", green, Vector3(-0.13, 0.33, 0.18), 0.09, false)
	Prim.box(b, Vector3(0.07, 0.08, 0.02), blue, Vector3(0.13, 0.31, 0.18))
	Prim.box(b, Vector3(0.04, 0.04, 0.022), yellow.darkened(0.1), Vector3(0.13, 0.31, 0.185), Vector3(0, 0, 45))
	for i in 4:
		Prim.sphere(b, 0.012, green, Vector3(0.1 + i * 0.02, 0.37, 0.18))
	var h: Node3D = f.head
	var silver := Color(0.82, 0.82, 0.8)
	Prim.sphere(h, 0.275, silver, Vector3(0, 0.34, -0.035), Vector3(1.04, 0.68, 1.0))
	for s in [-1, 1]:
		Prim.torus(h, 0.055, 0.075, black, Vector3(0.09 * s, 0.31, 0.27), Vector3(90, 0, 0))
		Prim.cyl(h, 0.058, 0.058, 0.005, Color(0.75, 0.88, 1.0, 0.35), Vector3(0.09 * s, 0.31, 0.27), Vector3(90, 0, 0))
		Prim.box(h, Vector3(0.015, 0.015, 0.24), black, Vector3(0.19 * s, 0.32, 0.13))
	Prim.box(h, Vector3(0.05, 0.015, 0.015), black, Vector3(0, 0.32, 0.28))
	f.add_brows(silver.darkened(0.25))
	f.add_mouth()
	var clip := Prim.node(f.arm_l, Vector3(0, -0.66, 0.12), Vector3(-15, 0, 0))
	Prim.box(clip, Vector3(0.24, 0.32, 0.02), Color(0.55, 0.35, 0.18))
	Prim.box(clip, Vector3(0.2, 0.26, 0.005), Color.WHITE, Vector3(0, -0.01, 0.012))
	Prim.box(clip, Vector3(0.08, 0.03, 0.03), Color(0.7, 0.7, 0.72), Vector3(0, 0.15, 0.01), Vector3.ZERO, 0.3, 0.9)
	Prim.box(clip, Vector3(0.12, 0.008, 0.004), blue, Vector3(0, 0.04, 0.016), Vector3(0, 0, 30))
	Prim.box(clip, Vector3(0.1, 0.008, 0.004), Color(0.8, 0.1, 0.1), Vector3(0.02, -0.06, 0.016), Vector3(0, 0, -25))
