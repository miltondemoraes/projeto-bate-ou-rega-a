extends CanvasLayer

signal character_picked(index: int)
signal difficulty_picked(key: String)
signal start_requested
signal answer_picked(index: int)
signal target_picked(index: int)
signal restart_requested
signal menu_requested
signal clicked

const YELLOW := Color(1.0, 0.82, 0.1)
const NAVY := Color(0.03, 0.15, 0.3, 0.88)
const PERFECT_MIN := 0.82
const PERFECT_MAX := 0.95
const STRONG_MIN := 0.5

var root: Control
var menu: Control
var hud: Control

var fact_label: Label
var diff_desc: Label
var diff_buttons := {}
var char_buttons: Array[Button] = []
var _fighters: Array = []
var _diffs: Dictionary = {}

var round_label: Label
var score_label: Label
var diff_label: Label
var status_cards: Array = []

var question_panel: PanelContainer
var question_label: Label
var timer_bar: ProgressBar
var timer_fill_ok: StyleBoxFlat
var timer_fill_low: StyleBoxFlat
var answer_buttons: Array[Button] = []
var _answers_open := false

var target_panel: PanelContainer
var target_box: HBoxContainer
var _target_count := 0

var power_panel: PanelContainer
var power_title: Label
var power_marker: ColorRect
var power_result: Label

var banner: VBoxContainer
var banner_title: Label
var banner_sub: Label
var _banner_tw: Tween

var pow_label: Label
var end_panel: PanelContainer
var end_title: Label
var end_stats: Label


func build(fighters: Array, diffs: Dictionary) -> void:
	_fighters = fighters
	_diffs = diffs
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var th := Theme.new()
	var bold := FontVariation.new()
	bold.base_font = ThemeDB.fallback_font
	bold.variation_embolden = 0.8
	th.default_font = bold
	th.default_font_size = 22
	root.theme = th
	add_child(root)
	_build_menu()
	_build_hud()
	_build_banner()
	_build_end()


func _sb(bg: Color, radius := 16, border := Color(0, 0, 0, 0), bw := 0, pad := 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	if bw > 0:
		s.border_color = border
		s.set_border_width_all(bw)
	s.set_content_margin_all(pad)
	return s


func _label(text: String, size := 22, color := Color.WHITE, outline := 6, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", outline)
	return l


func _button(text: String, bg: Color, font_size := 24, min_size := Vector2(0, 56)) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func(): clicked.emit())
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_stylebox_override("normal", _sb(bg, 14, bg.darkened(0.4), 3))
	b.add_theme_stylebox_override("hover", _sb(bg.lightened(0.15), 14, Color.WHITE, 3))
	b.add_theme_stylebox_override("pressed", _sb(bg.lightened(0.1), 14, YELLOW, 5))
	b.add_theme_stylebox_override("hover_pressed", _sb(bg.lightened(0.2), 14, YELLOW, 5))
	b.add_theme_stylebox_override("disabled", _sb(bg.darkened(0.45), 14, bg.darkened(0.6), 3))
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_disabled_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	b.add_theme_constant_override("outline_size", 5)
	return b


func _panel(bg := NAVY, border := YELLOW) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(bg, 22, border, 4, 18))
	return p


func _bottom_center(c: Control, width: float, height: float, margin := 16.0) -> void:
	c.anchor_left = 0.5
	c.anchor_right = 0.5
	c.anchor_top = 1.0
	c.anchor_bottom = 1.0
	c.offset_left = -width / 2.0
	c.offset_right = width / 2.0
	c.offset_top = -height - margin
	c.offset_bottom = -margin
	c.grow_vertical = Control.GROW_DIRECTION_BEGIN


func _build_menu() -> void:
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(menu)
	var panel := _panel()
	panel.anchor_bottom = 1.0
	panel.offset_left = 20
	panel.offset_top = 16
	panel.offset_right = 580
	panel.offset_bottom = -16
	menu.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	panel.add_child(v)

	v.add_child(_label("BATE OU REGAÇA", 42, YELLOW, 12))
	v.add_child(_label("da Matemática", 26, Color.WHITE, 8))
	v.add_child(_label("Marco dos Corais  •  Maceió - AL", 18, Color(0.6, 0.95, 1.0), 5))

	v.add_child(_label("1. Escolha seu personagem", 20, YELLOW, 5, HORIZONTAL_ALIGNMENT_LEFT))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	var group := ButtonGroup.new()
	for i in _fighters.size():
		var f = _fighters[i]
		var b := _button("%s\n%s" % [f.display_name, f.tagline], f.color, 18, Vector2(256, 58))
		b.toggle_mode = true
		b.button_group = group
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_char_button.bind(i))
		grid.add_child(b)
		char_buttons.append(b)
	fact_label = _label("", 16, Color(0.9, 0.95, 1.0), 4, HORIZONTAL_ALIGNMENT_LEFT)
	fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fact_label.custom_minimum_size = Vector2(0, 60)
	v.add_child(fact_label)

	v.add_child(_label("2. Escolha a dificuldade", 20, YELLOW, 5, HORIZONTAL_ALIGNMENT_LEFT))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	v.add_child(h)
	var dgroup := ButtonGroup.new()
	var dcolors := {"facil": Color(0.15, 0.65, 0.3), "medio": Color(0.9, 0.55, 0.05), "dificil": Color(0.85, 0.15, 0.2)}
	for key in _diffs.keys():
		var b := _button(_diffs[key].label, dcolors[key], 22, Vector2(0, 52))
		b.toggle_mode = true
		b.button_group = dgroup
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_diff_button.bind(key))
		h.add_child(b)
		diff_buttons[key] = b
	diff_desc = _label("", 16, Color(0.9, 0.95, 1.0), 4, HORIZONTAL_ALIGNMENT_LEFT)
	diff_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diff_desc.custom_minimum_size = Vector2(0, 44)
	v.add_child(diff_desc)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(spacer)
	var play := _button("JOGAR!", Color(0.95, 0.7, 0.0), 34, Vector2(0, 66))
	play.pressed.connect(func(): start_requested.emit())
	v.add_child(play)
	v.add_child(_label("Responda com o mouse ou teclas 1 a 4  •  ESPAÇO para dar o tapa", 14, Color(0.8, 0.85, 0.9), 3))


func _on_char_button(i: int) -> void:
	select_character(i)
	character_picked.emit(i)


func _on_diff_button(key: String) -> void:
	select_difficulty(key)
	difficulty_picked.emit(key)


func select_character(i: int) -> void:
	char_buttons[i].set_pressed_no_signal(true)
	var f = _fighters[i]
	fact_label.text = f.fact


func select_difficulty(key: String) -> void:
	diff_buttons[key].set_pressed_no_signal(true)
	diff_desc.text = _diffs[key].desc


func show_menu() -> void:
	menu.visible = true
	hud.visible = false
	end_panel.visible = false
	banner.visible = false


func _build_hud() -> void:
	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)

	var top := _panel(Color(0.03, 0.15, 0.3, 0.8))
	top.anchor_right = 1.0
	top.offset_left = 16
	top.offset_right = -16
	top.offset_top = 10
	top.add_theme_stylebox_override("panel", _sb(Color(0.03, 0.15, 0.3, 0.8), 18, YELLOW, 3, 8))
	hud.add_child(top)
	var bar := HBoxContainer.new()
	top.add_child(bar)
	round_label = _label("Rodada 1", 24, YELLOW, 6, HORIZONTAL_ALIGNMENT_LEFT)
	round_label.custom_minimum_size = Vector2(200, 0)
	bar.add_child(round_label)
	var title := _label("BATE OU REGAÇA  •  Marco dos Corais, Maceió-AL", 22, Color.WHITE, 6)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(title)
	diff_label = _label("", 18, Color(0.6, 0.95, 1.0), 5, HORIZONTAL_ALIGNMENT_RIGHT)
	bar.add_child(diff_label)
	score_label = _label("Pontos: 0", 24, YELLOW, 6, HORIZONTAL_ALIGNMENT_RIGHT)
	score_label.custom_minimum_size = Vector2(200, 0)
	bar.add_child(score_label)

	var row := HBoxContainer.new()
	row.anchor_left = 0.5
	row.anchor_right = 0.5
	row.offset_left = -470
	row.offset_right = 470
	row.offset_top = 72
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	hud.add_child(row)
	for f in _fighters:
		var p := PanelContainer.new()
		p.custom_minimum_size = Vector2(220, 0)
		p.add_theme_stylebox_override("panel", _sb(Color(f.color, 0.85), 14, Color.WHITE, 2, 6))
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 2)
		p.add_child(v)
		v.add_child(_label(f.display_name, 18, Color.WHITE, 5))
		var tag := _label("ROBÔ", 13, Color(0.9, 0.9, 0.9), 4)
		v.add_child(tag)
		var lives := HBoxContainer.new()
		lives.alignment = BoxContainer.ALIGNMENT_CENTER
		lives.add_theme_constant_override("separation", 5)
		v.add_child(lives)
		row.add_child(p)
		status_cards.append({"panel": p, "lives": lives, "tag": tag})

	question_panel = _panel()
	_bottom_center(question_panel, 960, 250)
	hud.add_child(question_panel)
	var qv := VBoxContainer.new()
	qv.add_theme_constant_override("separation", 8)
	question_panel.add_child(qv)
	question_label = _label("", 32, Color.WHITE, 8)
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qv.add_child(question_label)
	timer_bar = ProgressBar.new()
	timer_bar.show_percentage = false
	timer_bar.custom_minimum_size = Vector2(0, 16)
	timer_bar.max_value = 1.0
	timer_bar.step = 0.0
	timer_bar.add_theme_stylebox_override("background", _sb(Color(0, 0, 0, 0.5), 8, Color(0, 0, 0, 0), 0, 0))
	timer_fill_ok = _sb(Color(0.2, 0.85, 0.4), 8, Color(0, 0, 0, 0), 0, 0)
	timer_fill_low = _sb(Color(0.95, 0.2, 0.2), 8, Color(0, 0, 0, 0), 0, 0)
	timer_bar.add_theme_stylebox_override("fill", timer_fill_ok)
	qv.add_child(timer_bar)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	qv.add_child(grid)
	var acolors := [Color(0.2, 0.45, 0.9), Color(0.85, 0.2, 0.3), Color(0.95, 0.6, 0.05), Color(0.15, 0.65, 0.35)]
	for i in 4:
		var b := _button("", acolors[i], 30, Vector2(0, 58))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_answer.bind(i))
		grid.add_child(b)
		answer_buttons.append(b)

	target_panel = _panel()
	_bottom_center(target_panel, 860, 150)
	hud.add_child(target_panel)
	var tv := VBoxContainer.new()
	target_panel.add_child(tv)
	tv.add_child(_label("Quem vai levar o tapa?", 30, YELLOW, 8))
	target_box = HBoxContainer.new()
	target_box.alignment = BoxContainer.ALIGNMENT_CENTER
	target_box.add_theme_constant_override("separation", 12)
	tv.add_child(target_box)

	power_panel = _panel()
	_bottom_center(power_panel, 820, 170)
	hud.add_child(power_panel)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	power_panel.add_child(pv)
	power_title = _label("", 28, YELLOW, 8)
	pv.add_child(power_title)
	var bar_root := Control.new()
	bar_root.custom_minimum_size = Vector2(760, 46)
	bar_root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pv.add_child(bar_root)
	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", _sb(Color(0, 0, 0, 0.6), 10, Color.WHITE, 3, 0))
	bar_root.add_child(bg)
	for z in [[0.0, STRONG_MIN, Color(0.85, 0.2, 0.2), "FRACO"], [STRONG_MIN, PERFECT_MIN, Color(0.95, 0.75, 0.1), "FORTE"],
			[PERFECT_MIN, PERFECT_MAX, Color(0.15, 0.85, 0.35), "PERFEITO!"], [PERFECT_MAX, 1.0, Color(0.95, 0.75, 0.1), ""]]:
		var r := ColorRect.new()
		r.color = z[2]
		r.anchor_left = z[0]
		r.anchor_right = z[1]
		r.anchor_bottom = 1.0
		r.offset_left = 3 if z[0] == 0.0 else 0
		r.offset_right = -3 if z[1] == 1.0 else 0
		r.offset_top = 3
		r.offset_bottom = -3
		bar_root.add_child(r)
		var zl := _label(z[3], 14, Color.WHITE, 4)
		zl.set_anchors_preset(Control.PRESET_FULL_RECT)
		zl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		r.add_child(zl)
	power_marker = ColorRect.new()
	power_marker.color = Color.WHITE
	power_marker.anchor_top = 0.0
	power_marker.anchor_bottom = 1.0
	power_marker.offset_left = -6
	power_marker.offset_right = 6
	power_marker.offset_top = -10
	power_marker.offset_bottom = 10
	bar_root.add_child(power_marker)
	var mk_border := ColorRect.new()
	mk_border.color = Color.BLACK
	mk_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	mk_border.offset_left = 4
	mk_border.offset_right = -4
	mk_border.offset_top = 3
	mk_border.offset_bottom = -3
	power_marker.add_child(mk_border)
	power_result = _label("", 24, Color.WHITE, 6)
	pv.add_child(power_result)

	pow_label = _label("", 96, YELLOW, 18)
	pow_label.add_theme_color_override("font_outline_color", Color(0.75, 0.05, 0.05))
	pow_label.anchor_left = 0.5
	pow_label.anchor_right = 0.5
	pow_label.anchor_top = 0.3
	pow_label.anchor_bottom = 0.3
	pow_label.offset_left = -400
	pow_label.offset_right = 400
	pow_label.offset_top = -80
	pow_label.offset_bottom = 80
	pow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pow_label.pivot_offset = Vector2(400, 80)
	pow_label.visible = false
	hud.add_child(pow_label)
	hud.visible = false


func show_hud(diff_text: String) -> void:
	menu.visible = false
	end_panel.visible = false
	hud.visible = true
	question_panel.visible = false
	target_panel.visible = false
	power_panel.visible = false
	diff_label.text = "Nível: %s   " % diff_text
	update_status()


func update_status() -> void:
	for i in _fighters.size():
		var f = _fighters[i]
		var card: Dictionary = status_cards[i]
		var tag: Label = card.tag
		tag.text = "VOCÊ" if f.is_player else "ROBÔ"
		tag.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5) if f.is_player else Color(0.9, 0.9, 0.9))
		var lives: HBoxContainer = card.lives
		for c in lives.get_children():
			c.queue_free()
		for k in f.max_lives:
			var heart := Panel.new()
			heart.custom_minimum_size = Vector2(20, 20)
			var on: bool = k < f.lives
			heart.add_theme_stylebox_override("panel", _sb(Color(1, 0.2, 0.3) if on else Color(0.2, 0.2, 0.2, 0.6), 10, Color.WHITE, 2, 0))
			lives.add_child(heart)
		if f.lives <= 0:
			tag.text = "FORA! (no mar)"
		var p: PanelContainer = card.panel
		p.modulate = Color(0.55, 0.55, 0.55) if f.lives <= 0 else Color.WHITE


func set_score(n: int) -> void:
	score_label.text = "Pontos: %d" % n


func show_question(q: Dictionary, round_num: int) -> void:
	round_label.text = "Rodada %d" % round_num
	question_label.text = q.text
	for i in 4:
		var b := answer_buttons[i]
		b.text = "%d)   %d" % [i + 1, q.options[i]]
		b.disabled = false
		b.modulate = Color.WHITE
		b.add_theme_stylebox_override("disabled", _sb(Color(0.25, 0.25, 0.3), 14, Color(0.15, 0.15, 0.2), 3))
	timer_bar.value = 1.0
	question_panel.visible = true
	_answers_open = true


func set_timer(frac: float) -> void:
	timer_bar.value = clampf(frac, 0.0, 1.0)
	timer_bar.add_theme_stylebox_override("fill", timer_fill_low if frac < 0.3 else timer_fill_ok)


func lock_answers(chosen: int, q: Dictionary) -> void:
	_answers_open = false
	for i in 4:
		var b := answer_buttons[i]
		b.disabled = true
		if q.options[i] == q.answer:
			b.add_theme_stylebox_override("disabled", _sb(Color(0.12, 0.72, 0.3), 14, YELLOW, 5))
		elif i == chosen:
			b.add_theme_stylebox_override("disabled", _sb(Color(0.85, 0.15, 0.2), 14, Color.WHITE, 3))
		else:
			b.modulate = Color(1, 1, 1, 0.45)


func hide_question() -> void:
	question_panel.visible = false


func _on_answer(i: int) -> void:
	if _answers_open:
		answer_picked.emit(i)


func show_target_choice(bots: Array) -> void:
	for c in target_box.get_children():
		c.queue_free()
	_target_count = bots.size()
	for i in bots.size():
		var f = bots[i]
		var b := _button("%d)  %s" % [i + 1, f.display_name], f.color, 22, Vector2(240, 60))
		b.pressed.connect(_on_target.bind(i))
		target_box.add_child(b)
	target_panel.visible = true


func _on_target(i: int) -> void:
	if target_panel.visible:
		target_panel.visible = false
		target_picked.emit(i)


func show_power_bar(is_player: bool, who: String) -> void:
	power_title.text = "APERTE ESPAÇO NA HORA CERTA!" if is_player else "%s (robô) está mirando..." % who
	power_result.text = ""
	set_power(0.0)
	power_panel.visible = true


func set_power(v: float) -> void:
	power_marker.anchor_left = v
	power_marker.anchor_right = v


func show_power_result(grade: String) -> void:
	match grade:
		"perfeito":
			power_result.text = "TAPA PERFEITO!"
			power_result.add_theme_color_override("font_color", Color(0.3, 1.0, 0.45))
		"forte":
			power_result.text = "TAPA FORTE!"
			power_result.add_theme_color_override("font_color", YELLOW)
		_:
			power_result.text = "Tapinha fraco..."
			power_result.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))


func hide_power_bar() -> void:
	power_panel.visible = false


func pow_text(text: String) -> void:
	pow_label.text = text
	pow_label.visible = true
	pow_label.scale = Vector2(0.2, 0.2)
	pow_label.rotation = randf_range(-0.25, 0.25)
	pow_label.modulate = Color.WHITE
	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(pow_label, "scale", Vector2.ONE * 1.15, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.6)
	tw.tween_property(pow_label, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): pow_label.visible = false)


func _build_banner() -> void:
	banner = VBoxContainer.new()
	banner.anchor_left = 0.5
	banner.anchor_right = 0.5
	banner.anchor_top = 0.24
	banner.offset_left = -520
	banner.offset_right = 520
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(banner)
	banner_title = _label("", 54, YELLOW, 14)
	banner_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.add_child(banner_title)
	banner_sub = _label("", 28, Color.WHITE, 8)
	banner_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.add_child(banner_sub)
	banner.visible = false


func show_banner(title: String, color := YELLOW, sub := "", duration := 2.0) -> void:
	if _banner_tw:
		_banner_tw.kill()
	banner_title.text = title
	banner_title.add_theme_color_override("font_color", color)
	banner_sub.text = sub
	banner_sub.visible = sub != ""
	banner.visible = true
	banner.modulate = Color.WHITE
	banner.scale = Vector2.ONE
	_banner_tw = create_tween()
	_banner_tw.tween_interval(duration)
	_banner_tw.tween_property(banner, "modulate:a", 0.0, 0.3)
	_banner_tw.tween_callback(func(): banner.visible = false)


func _build_end() -> void:
	end_panel = _panel()
	end_panel.anchor_left = 0.5
	end_panel.anchor_right = 0.5
	end_panel.anchor_top = 0.5
	end_panel.anchor_bottom = 0.5
	end_panel.offset_left = -330
	end_panel.offset_right = 330
	end_panel.offset_top = -40
	end_panel.offset_bottom = 300
	root.add_child(end_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	end_panel.add_child(v)
	end_title = _label("", 40, YELLOW, 10)
	end_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(end_title)
	end_stats = _label("", 22, Color.WHITE, 5)
	v.add_child(end_stats)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	v.add_child(h)
	var again := _button("Jogar de novo", Color(0.15, 0.65, 0.3), 24, Vector2(0, 60))
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	again.pressed.connect(func(): restart_requested.emit())
	h.add_child(again)
	var back := _button("Menu", Color(0.2, 0.45, 0.9), 24, Vector2(0, 60))
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(func(): menu_requested.emit())
	h.add_child(back)
	end_panel.visible = false


func show_end(won: bool, player_name: String, score: int, hits: int, misses: int) -> void:
	question_panel.visible = false
	target_panel.visible = false
	power_panel.visible = false
	end_title.text = ("%s é o CAMPEÃO do Marco dos Corais!" % player_name) if won else "Tchibum! %s caiu no mar..." % player_name
	end_title.add_theme_color_override("font_color", YELLOW if won else Color(0.6, 0.9, 1.0))
	var total := hits + misses
	var pct := 0 if total == 0 else int(round(100.0 * hits / total))
	end_stats.text = "Pontos: %d\nAcertos: %d   •   Erros: %d\nAproveitamento: %d%%" % [score, hits, misses, pct]
	end_panel.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.keycode
	var n := -1
	if k >= KEY_1 and k <= KEY_4:
		n = k - KEY_1
	elif k >= KEY_KP_1 and k <= KEY_KP_4:
		n = k - KEY_KP_1
	if n < 0:
		return
	if _answers_open and question_panel.visible:
		_on_answer(n)
		get_viewport().set_input_as_handled()
	elif target_panel.visible and n < _target_count:
		_on_target(n)
		get_viewport().set_input_as_handled()
