extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
	
var area = []
export var w = 3
export var h = 3
export var ball_size = 64
export (PackedScene) var Ball
var shift = Vector2(ball_size, 0)

var accum=0

func fill_area(w, h):
	var colors =  ["r.tex", "g.tex", "b.tex"]
	var textures = []
	
	for c in colors:
		var tex = load("res://" + c)
		textures.append(tex)
		
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(int(ball_size/2)-1, int(ball_size/2)))
	
	for y in range(h):
		for x in range(w):
			var ball = Ball.instance()
			
			ball.color = round(rand_range(0, colors.size() - 1))
			
			var tf = ball.get_node("TextureFrame")
			tf.set_texture(textures[ball.color])
			tf.set_size(Vector2(ball_size, ball_size))
			tf.set_pos(Vector2(-ball_size / 2, -ball_size / 2))
	
			#var cs = ball.get_node("CollisionShape2D").get_shape()
			#cs.set_extents(Vector2(int(ball_size/2)-1, int(ball_size/2)-1))
			ball.add_shape(shape)
		
			ball.set_pos(Vector2(ball_size * x, ball_size * y) + shift)
			area.append(ball)
			add_child(ball)
			
			#ball.connect("mouse_enter", self, "_om_ball_mouse_enter")
			#ball.connect("mouse_exit", self, "_om_ball_mouse_enter")
			
	var thefloor = get_node("floor")
	thefloor.set_pos(Vector2(0, h * ball_size) + shift)
	var floor_shape = thefloor.get_node("CollisionShape2D").get_shape()
	floor_shape.set_extents(Vector2(w * ball_size, 1))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	fill_area(w, h)
	set_process(1)
	set_process_input(1)


func _process(delta):
	accum += delta
	
	if accum > .04:
		accum = 0
		check_balls()

func _input(event):
	if event.is_action("click") and event.is_pressed():
		remove_checked()
		
		if area.size() == 0:
			fill_area(w, h)

func add_to_pipe(pos, pipe, passed):
	if pos.x >= 0 and pos.x < w:
		if pos.y >= 0 and pos.y < h:
			if not pos in passed:
				pipe.append(pos)


func check_ball(pipe, color, passed, map):
	for pos in pipe:
		var x = pos.x
		var y = pos.y
		
		var ball = map[x][y]
		
		if ball:
			if not ball.selected:
				if ball.color == color:
					ball.selected = 1
					
					# top, right, left,  bottom
					add_to_pipe(pos + Vector2( 0, -1), pipe, passed)
					add_to_pipe(pos + Vector2( 1,  0), pipe, passed)
					add_to_pipe(pos + Vector2(-1,  0), pipe, passed)
					add_to_pipe(pos + Vector2( 0,  1), pipe, passed)
		
		passed[pos] = 1


func ball_map():
	var map = []
	
	# init
	for x in range(w):
		var col = []
		map.append(col)
		
		for y in range(h):
			col.append(0)
	
	# install
	for ball in area:
		var pos = ball.get_pos() - shift - Vector2(-ball_size / 2, -ball_size / 2)
		var x = int(pos.x / ball_size)
		var y = int(pos.y / ball_size)
			
		map[x][y] = ball

	return map

func remove_checked():
	var toremove = []
	
	for ball in area:
		if ball.selected:
			var fx = get_node("fx").duplicate(1)
			fx.set_hidden(0)
			fx.set_as_toplevel(1)
			fx.set_pos(ball.get_pos())
			fx.set_emitting(true)
			var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
			fx.set_color(colors[ball.color])
			add_child(fx)
			
			get_node("SamplePlayer2D").play("ball" + str(ball.color+1))
			
			toremove.append(ball)
			
	for ball in toremove:
		area.erase(ball)
		ball.queue_free()


func check_balls():
	var pipe = []
	var passed = {}
	var map = ball_map()

	# clear
	for ball in area:
		if ball.selected:
			ball.selected = 0
			ball.update()

	var pos = get_global_mouse_pos() - Vector2(ball_size-5, 0)
	var x = int(pos.x / ball_size)
	var y = int(pos.y / ball_size)
	
	if x >= w or y >= h:
		return
		
	var ball = map[x][y]

	if ball:
		if not ball.selected:
			pipe.append(Vector2(x, y))
			check_ball(pipe, ball.color, passed, map)


func _om_ball_mouse_enter():
	check_balls()
