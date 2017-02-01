extends Node2D

var area = []
export var w = 3
export var h = 3
export var ball_size = 64
export (PackedScene) var Ball
var shift = Vector2(64, 64)

# 0. Click all
# 1. Click all not green
var stage = null

var accum=0


class StageClickAll:
	var root = null
	
	func _init(proot):
		root = proot
		root.w = 20
		root.h = 10
		root.ball_size = 48
		root.calc_shift()
		root.fill_area(root.w, root.h)
		
	func process(root):
		root.remove_checked()
		
		if root.area.size() == 0:
			root.get_node("Timer").start()


class StageClickAll3x3:
	var root = null
	
	func _init(proot):
		root = proot
		root.w = 3
		root.h = 3
		root.ball_size = 96
		root.calc_shift()
		root.fill_area(root.w, root.h)

	func process(root):
		root.remove_checked()
		
		if root.area.size() == 0:
			root.get_node("Timer").start()


class StageClickAll7x15:
	var root = null
	
	func _init(proot):
		root = proot
		root.w = 15
		root.h = 7
		root.ball_size = 64
		root.calc_shift()
		root.fill_area(root.w, root.h)

	func process(root):
		root.remove_checked()
		
		if root.area.size() == 0:
			root.get_node("Timer").start()


class StageKeepGreen:
	var root = null
	
	func _init(proot):
		root = proot
		root.w = 20
		root.h = 10
		root.ball_size = 48
		root.calc_shift()
		root.fill_area(root.w, root.h)

	func process(root):
		var is_green_only = true
		
		for ball in root.area:
			if ball.color != 1:
				is_green_only = false
				break
		
		if is_green_only:
			root.remove_checked()
			
			if root.area.size() == 0:
				root.next_stage()
		
		for ball in root.area:
			if ball.selected:
				if ball.color == 1:
					#if get_node("mute").is_pressed():
					#	get_node("SamplePlayer2D").play("wrong")
					pass
				else:
					root.remove_checked()
					
				break


func fill_area(w, h):
	var colors =  ["r.tex", "g.tex", "b.tex"]
	var textures = []

	area.clear()
	
	for c in colors:
		var tex = load("res://" + c)
		tex.set_size_override(Vector2(ball_size, ball_size))
		textures.append(tex)
		
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(int(ball_size/2)-1, int(ball_size/2)))
	
	seed(OS.get_ticks_msec() + OS.get_system_time_secs())
	randomize()
	
	for y in range(h):
		for x in range(w):
			var ball = Ball.instance()

			# color
			ball.color = round(rand_range(0, colors.size() - 1))
			
			# texture
			var sprite = ball.get_node("Sprite")
			sprite.set_texture(textures[ball.color])
	
			# collision shape
			ball.add_shape(shape)
		
			# position
			ball.set_pos(Vector2(ball_size * x , ball_size * y) + shift)
			
			area.append(ball)
			add_child(ball)
			
	# floor
	var thefloor = get_node("floor")
	thefloor.set_pos(Vector2(w * ball_size / 2, h * ball_size) + shift)
	
	var floor_shape = thefloor.get_node("CollisionShape2D").get_shape()
	floor_shape.set_extents(Vector2(w * ball_size, ball_size/2-1))

func remove_checked():
	var toremove = []
	
	for ball in area:
		if ball.selected:
			# fx
			var fx = get_node("fx").duplicate(1)
			fx.set_hidden(0)
			fx.set_as_toplevel(1)
			fx.set_pos(ball.get_pos())
			fx.set_emitting(true)
			
			# color
			var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
			fx.set_color(colors[ball.color])
			
			# velocity
			var velocities = [60, 100, 80]
			fx.set_param(Particles2D.PARAM_LINEAR_VELOCITY, velocities[ball.color])
			
			add_child(fx)
			
			# sound
			if get_node("mute").is_pressed():
				get_node("SamplePlayer2D").play("ball" + str(ball.color+1))
			
			toremove.append(ball)
	
	for ball in toremove:
		area.erase(ball)
		ball.queue_free()


func remove_all():
	for ball in area:
		# fx
		var fx = get_node("fx").duplicate(1)
		fx.set_hidden(0)
		fx.set_as_toplevel(1)
		fx.set_pos(ball.get_pos())
		fx.set_emitting(true)
		
		# color
		var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
		fx.set_color(colors[ball.color])
		
		# velocity
		var velocities = [60, 100, 80]
		fx.set_param(Particles2D.PARAM_LINEAR_VELOCITY, velocities[ball.color])
		
		add_child(fx)
		
		# sound
		if get_node("mute").is_pressed():
			get_node("SamplePlayer2D").play("ball" + str(ball.color+1))
		
	for ball in area:
		ball.queue_free()
		
	area.clear()



func create_map(w, h):
	var map = []
	
	# init
	for x in range(w):
		var col = []
		col.resize(h)
		map.append(col)
	
	# install
	for ball in area:
		ball.passed = 0
		ball.selected = 0
		ball.update()
		
		var pos = ball.get_pos() - shift
		var x = int(pos.x / ball_size)
		var y = int(pos.y / ball_size)
		
		if x >= w:
			x = w-1
		
		if y >= h:
			y = h-1
		
		map[x][y] = ball

	return map


func check_balls():
	var pipe = []
	var map = create_map(w, h)

	var pos = get_global_mouse_pos() - shift + Vector2(ball_size / 2, ball_size / 2)
	var x = int(pos.x / ball_size)
	var y = int(pos.y / ball_size)
	
	if x >= w or y >= h:
		return
		
	if x < 0 or y < 0:
		return
		
	var ball = map[x][y]

	if ball:
		if not ball.selected:
			pipe.append(Vector2(x, y))
			check_ball(pipe, ball.color, map)

func add_to_pipe(pos, pipe):
	if pos.x >= 0 and pos.x < w:
		if pos.y >= 0 and pos.y < h:
			pipe.append(pos)


func check_ball(pipe, color, map):
	for pos in pipe:
		var x = pos.x
		var y = pos.y
		
		var ball = map[x][y]
		
		if ball and ball.passed == 0:
			if ball.selected == 0:
				if ball.color == color:
					ball.selected = 1
					ball.update()
					
					# top, right, left,  bottom
					add_to_pipe(pos + Vector2( 0, -1), pipe)
					add_to_pipe(pos + Vector2( 1,  0), pipe)
					add_to_pipe(pos + Vector2(-1,  0), pipe)
					add_to_pipe(pos + Vector2( 0,  1), pipe)
		
			ball.passed = 1


func next_stage():
	#stage = StageClickAll.new(self)
	stage = StageClickAll7x15.new(self)


func _ready():
	set_process(1)
	set_process_input(1)
	stage = StageClickAll3x3.new(self)


func calc_shift():
	var size = get_tree().get_root().get_visible_rect().size
	var cx = (size.width - w * ball_size) / 2 + ball_size / 2
	var cy = (size.height - h * ball_size)
	shift = Vector2(cx, cy)
	

func _process(delta):
	accum += delta
	
	if accum > .04:
		accum = 0
		check_balls()


func _input(event):
	if event.is_action("click") and event.is_pressed():
		stage.process(self)


func _on_Timer_timeout():
	remove_all()
	stage._init(self)
	pass # replace with function body


func _on_stage3x3_pressed():
	get_node("Timer").stop()
	remove_all()
	stage = StageClickAll3x3.new(self)
	pass # replace with function body


func _on_stage7x15_pressed():
	get_node("Timer").stop()
	remove_all()
	stage = StageClickAll7x15.new(self)
	pass # replace with function body


func _on_stage10x20_pressed():
	get_node("Timer").stop()
	remove_all()
	stage = StageClickAll.new(self)


func _on_saythanks_meta_clicked( meta ):
	OS.shell_open("http://www.donationalerts.ru/r/vitalfadeev")
	pass # replace with function body
