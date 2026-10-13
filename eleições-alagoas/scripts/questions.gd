extends RefCounted


func generate(level: String) -> Dictionary:
	match level:
		"facil":
			return _facil()
		"medio":
			return _medio()
		_:
			return _dificil()


func _facil() -> Dictionary:
	match randi() % 6:
		0:
			var a := randi_range(1, 10)
			var b := randi_range(1, 10)
			return _q("Quanto é %d + %d ?" % [a, b], a + b, "%d + %d = %d" % [a, b, a + b])
		1:
			var a := randi_range(5, 20)
			var b := randi_range(1, a)
			return _q("Quanto é %d - %d ?" % [a, b], a - b, "%d - %d = %d" % [a, b, a - b])
		2:
			var shapes := [
				["um triângulo", "lados", 3], ["um quadrado", "lados", 4], ["um pentágono", "lados", 5],
				["um hexágono", "lados", 6], ["um cubo", "faces", 6], ["um cubo", "vértices (pontas)", 8],
			]
			var s: Array = shapes.pick_random()
			return _q("Quantos %s tem %s?" % [s[1], s[0]], s[2], "%s tem %d %s." % [_cap(s[0]), s[2], s[1]])
		3:
			var a := randi_range(1, 6)
			var b := randi_range(1, 6)
			return _q("Firmino fez %d gols no 1º tempo e %d gols no 2º tempo. Quantos gols ele fez?" % [a, b], a + b, "%d + %d = %d gols" % [a, b, a + b])
		4:
			var a := randi_range(6, 15)
			var b := randi_range(1, a - 1)
			return _q("Havia %d jangadas na praia. %d saíram para o mar. Quantas ficaram?" % [a, b], a - b, "%d - %d = %d jangadas" % [a, b, a - b])
		_:
			var n := randi_range(2, 10)
			return _q("Qual é o dobro de %d ?" % n, n * 2, "O dobro de %d é %d + %d = %d" % [n, n, n, n * 2])


func _medio() -> Dictionary:
	match randi() % 7:
		0:
			var a := randi_range(12, 60)
			var b := randi_range(10, 39)
			return _q("Quanto é %d + %d ?" % [a, b], a + b, "%d + %d = %d" % [a, b, a + b])
		1:
			var a := randi_range(30, 99)
			var b := randi_range(10, a - 5)
			return _q("Quanto é %d - %d ?" % [a, b], a - b, "%d - %d = %d" % [a, b, a - b])
		2:
			var a := randi_range(2, 10)
			var b := randi_range(2, 10)
			return _q("Quanto é %d × %d ?" % [a, b], a * b, "%d × %d = %d (tabuada do %d)" % [a, b, a * b, a])
		3:
			var d := randi_range(2, 10)
			var q := randi_range(2, 10)
			return _q("Quanto é %d ÷ %d ?" % [d * q, d], q, "%d ÷ %d = %d, porque %d × %d = %d" % [d * q, d, q, q, d, d * q])
		4:
			var a := randi_range(3, 9)
			var b := randi_range(2, 6)
			return _q("Cada jangada leva %d turistas. Quantos turistas cabem em %d jangadas?" % [a, b], a * b, "%d × %d = %d turistas" % [b, a, a * b])
		5:
			var shows := randi_range(2, 5)
			var per := randi_range(2, 8)
			return _q("Djavan vai cantar %d músicas divididas igualmente em %d shows. Quantas músicas por show?" % [shows * per, shows], per, "%d ÷ %d = %d músicas" % [shows * per, shows, per])
		_:
			var n := randi_range(10, 50) * 2
			return _q("Qual é a metade de %d ?" % n, n / 2, "A metade de %d é %d ÷ 2 = %d" % [n, n, n / 2])


func _dificil() -> Dictionary:
	match randi() % 9:
		0:
			var a := randi_range(11, 30)
			var b := randi_range(3, 9)
			return _q("Quanto é %d × %d ?" % [a, b], a * b, "%d × %d = %d" % [a, b, a * b])
		1:
			var d := randi_range(3, 12)
			var q := randi_range(6, 15)
			return _q("Quanto é %d ÷ %d ?" % [d * q, d], q, "%d ÷ %d = %d, porque %d × %d = %d" % [d * q, d, q, q, d, d * q])
		2:
			var a := randi_range(2, 20)
			var b := randi_range(2, 9)
			var c := randi_range(2, 9)
			return _q("Quanto é %d + %d × %d ?" % [a, b, c], a + b * c, "Primeiro a multiplicação: %d × %d = %d. Depois %d + %d = %d" % [b, c, b * c, a, b * c, a + b * c])
		3:
			var a := randi_range(2, 9)
			var b := randi_range(2, 9)
			var c := randi_range(2, 6)
			return _q("Quanto é (%d + %d) × %d ?" % [a, b, c], (a + b) * c, "Primeiro o parênteses: %d + %d = %d. Depois %d × %d = %d" % [a, b, a + b, a + b, c, (a + b) * c])
		4:
			var x := randi_range(3, 12)
			var b := randi_range(3, 9)
			return _q("Qual número falta?   ? × %d = %d" % [b, x * b], x, "%d × %d = %d" % [x, b, x * b])
		5:
			var n := randi_range(3, 12)
			return _q("Quanto é %d² (%d ao quadrado)?" % [n, n], n * n, "%d² = %d × %d = %d" % [n, n, n, n * n])
		6:
			var den: int = [2, 3, 4, 5].pick_random()
			var num := randi_range(1, den - 1)
			var total := den * randi_range(2, 12)
			var ans := total / den * num
			return _q("Quanto é %d/%d de %d ?" % [num, den, total], ans, "%d ÷ %d = %d; depois %d × %d = %d" % [total, den, total / den, total / den, num, ans])
		7:
			var year := randi_range(1950, 2026)
			return _q("Deodoro proclamou a República em 1889. Quantos anos se passaram até %d?" % year, year - 1889, "%d - 1889 = %d anos" % [year, year - 1889])
		_:
			var k := randi_range(3, 9)
			return _q("Zagallo adorava o número 13! Quanto é 13 × %d ?" % k, 13 * k, "13 × %d = 10 × %d + 3 × %d = %d" % [k, k, k, 13 * k])


func _q(text: String, answer: int, explain: String) -> Dictionary:
	var opts: Array[int] = [answer]
	var span := maxi(3, int(absf(answer) * 0.25))
	var guard := 0
	while opts.size() < 4 and guard < 200:
		guard += 1
		var c := answer + randi_range(-span, span)
		if c < 0 or opts.has(c):
			continue
		opts.append(c)
	var extra := 1
	while opts.size() < 4:
		if not opts.has(answer + extra):
			opts.append(answer + extra)
		extra += 1
	opts.shuffle()
	return {"text": text, "answer": answer, "options": opts, "explain": explain}


func _cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1)
