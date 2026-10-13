extends RefCounted

static var _mats: Dictionary = {}


static func mat(color: Color, rough: float = 0.85, metal: float = 0.0) -> StandardMaterial3D:
	var key := "%s|%.2f|%.2f" % [color.to_html(), rough, metal]
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metal
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mats[key] = m
	return m


static func put(parent: Node3D, mesh: Mesh, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, scl := Vector3.ONE, rough := 0.85, metal := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color, rough, metal)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	parent.add_child(mi)
	return mi


static func node(parent: Node3D, pos := Vector3.ZERO, rot_deg := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot_deg
	parent.add_child(n)
	return n


static func box(parent: Node3D, size: Vector3, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, rough := 0.85, metal := 0.0) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	return put(parent, m, color, pos, rot_deg, Vector3.ONE, rough, metal)


static func sphere(parent: Node3D, radius: float, color: Color, pos := Vector3.ZERO, scl := Vector3.ONE, rough := 0.85, metal := 0.0) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 20
	m.rings = 10
	return put(parent, m, color, pos, Vector3.ZERO, scl, rough, metal)


static func cyl(parent: Node3D, top_r: float, bottom_r: float, height: float, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, scl := Vector3.ONE, rough := 0.85, metal := 0.0) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.top_radius = top_r
	m.bottom_radius = bottom_r
	m.height = height
	m.radial_segments = 18
	m.rings = 1
	return put(parent, m, color, pos, rot_deg, scl, rough, metal)


static func capsule(parent: Node3D, radius: float, height: float, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, scl := Vector3.ONE) -> MeshInstance3D:
	var m := CapsuleMesh.new()
	m.radius = radius
	m.height = maxf(height, radius * 2.0)
	m.radial_segments = 16
	m.rings = 6
	return put(parent, m, color, pos, rot_deg, scl)


static func prism(parent: Node3D, size: Vector3, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, left_to_right := 0.5) -> MeshInstance3D:
	var m := PrismMesh.new()
	m.size = size
	m.left_to_right = left_to_right
	return put(parent, m, color, pos, rot_deg)


static func torus(parent: Node3D, inner_r: float, outer_r: float, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO, scl := Vector3.ONE) -> MeshInstance3D:
	var m := TorusMesh.new()
	m.inner_radius = inner_r
	m.outer_radius = outer_r
	m.rings = 24
	m.ring_segments = 12
	return put(parent, m, color, pos, rot_deg, scl)


static func segment(parent: Node3D, a: Vector3, b: Vector3, r_a: float, r_b: float, color: Color) -> MeshInstance3D:
	var d := b - a
	var mi := cyl(parent, r_b, r_a, d.length(), color, (a + b) * 0.5)
	mi.basis = basis_y(d)
	return mi


static func basis_y(dir: Vector3) -> Basis:
	var y := dir.normalized()
	var ref := Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT
	var x := y.cross(ref).normalized()
	var z := x.cross(y)
	return Basis(x, y, z)


const SEGMENTS := {
	"0": "abcdef", "1": "bc", "2": "abged", "3": "abcdg", "4": "fgbc",
	"5": "afgcd", "6": "afgedc", "7": "abc", "8": "abcdefg", "9": "abcfgd",
}

static func number(parent: Node3D, text: String, color: Color, center: Vector3, h: float, back: bool) -> void:
	var w := h * 0.55
	var t := h * 0.17
	var gap := w * 0.45
	var total := text.length() * w + (text.length() - 1) * gap
	var mirror := -1.0 if back else 1.0
	for i in text.length():
		var cx := -total / 2.0 + w / 2.0 + i * (w + gap)
		var segs: String = SEGMENTS[text[i]]
		for s in segs:
			var p := Vector3.ZERO
			var size := Vector3(w, t, 0.02)
			match s:
				"a": p = Vector3(0, h / 2, 0)
				"b": p = Vector3(w / 2, h / 4, 0); size = Vector3(t, h / 2, 0.02)
				"c": p = Vector3(w / 2, -h / 4, 0); size = Vector3(t, h / 2, 0.02)
				"d": p = Vector3(0, -h / 2, 0)
				"e": p = Vector3(-w / 2, -h / 4, 0); size = Vector3(t, h / 2, 0.02)
				"f": p = Vector3(-w / 2, h / 4, 0); size = Vector3(t, h / 2, 0.02)
				"g": p = Vector3.ZERO
			box(parent, size, color, center + Vector3((cx + p.x) * mirror, p.y, 0))
