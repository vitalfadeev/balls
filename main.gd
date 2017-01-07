extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
	
var area = {}
var w = 18
var h = 10


class Ball extends RigidBody2D:
	var color = 1
	var selected = 0
	var ball_size = 48

	func _init():
		set_mode(MODE_CHARACTER)
		set_gravity_scale(50)
		set_weight(1000)
		#set_friction(1)
		#set_bounce(0)
		set_linear_velocity(Vector2(0, 1))
		#set_angular_velocity(0)
		
		var tf = TextureFrame.new()
		tf.set_name("TextureFrame")
		tf.set_ignore_mouse(0)
		tf.set_stretch_mode(TextureFrame.STRETCH_SCALE)
		tf.set_expand(1)
		tf.set_size(Vector2(ball_size, ball_size))
		tf.set_pos(Vector2(-ball_size/2, -ball_size/2))
		add_child(tf)

		var shape = CircleShape2D.new()
		shape.set_radius(ball_size / 2)
		add_shape(shape)
		#var cs = CollisionShape2D.new()
		#cs.set_name("CollisionShape2D")
		##shape.set_pos(Vector2(64/2, 64/2))
		#cs.set_shape(shape)
		#cs.set_pos(Vector2(ball_size / 2, ball_size / 2))
		#add_child(cs)
		#tf.connect("mouse_enter", self, "_on_mouse_enter")
		tf.connect("input_event", self, "_on_input_event")

	func _draw():
		if selected:
			var tf = get_node("TextureFrame")
			tf.set_opacity(.3)
			tf.draw_circle(Vector2(ball_size / 2, ball_size / 2), ball_size / 2, Color(1, 1, 1, .2))
		else:
			var tf = get_node("TextureFrame")
			tf.set_opacity(1)

	func _on_mouse_enter():
		check_balls()

	func _on_mouse_exit():
		var root = get_tree().get_root().get_node("root")
		
		for ball in root.area.values():
			ball.selected = 0
			ball.update()
			
	func _on_input_event(ev):
		if ev.is_action("click") and ev.is_pressed():
			# remove balls
			var root = get_tree().get_root().get_node("root")
			root.remove_checked()
			if root.area.size() == 0:
				root.fill_area(root.w, root.h)

func fill_area(w, h):
	var colors =  ["r.tex", "g.tex", "b.tex"]
	var ball
	
	for y in range(h):
		for x in range(w):
			ball = Ball.new()
			
			ball.color = round(rand_range(0, colors.size() - 1))
			var texture = load("res://" + colors[ball.color])
			var tf = ball.get_node("TextureFrame")
			tf.set_texture(texture)
			
			ball.set_pos(Vector2(ball.ball_size * x, ball.ball_size * y) + Vector2(ball.ball_size, ball.ball_size))
			area[Vector2(x, y)] = ball
			add_child(ball)
			
	var thefloor = get_node("floor")
	thefloor.set_pos(Vector2(0, h * ball.ball_size) + Vector2(ball.ball_size, ball.ball_size))
	var floor_shape = thefloor.get_node("CollisionShape2D").get_shape()
	floor_shape.set_extents(Vector2((w+5) * ball.ball_size, ball.ball_size))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	fill_area(w, h)
	set_process_input(1)
	set_process(1)
	pass


func _process(delta):
	check_balls()

func add_to_pipe(pos, pipe, passed):
	if pos in passed:
		return
	else:
		pipe.append(pos)


func check_ball(pipe, color, passed):
	for pos in pipe:
		var ball = find_ball(pos)
		if ball:
			if ball.color == color:
				ball.selected = 1
				ball.update()
				
				# top, right, left,  bottom
				var s = ball.ball_size
				add_to_pipe(pos + Vector2( 0, -s), pipe, passed)
				add_to_pipe(pos + Vector2( s,  0), pipe, passed)
				add_to_pipe(pos + Vector2(-s,  0), pipe, passed)
				add_to_pipe(pos + Vector2( 0,  s), pipe, passed)
					
		passed[pos] = 1


func find_ball(coord):
	for ball in area.values():
		var pos = ball.get_node("TextureFrame").get_global_pos()
		if coord.x >= pos.x and coord.x <= pos.x + ball.ball_size:
			if coord.y >= pos.y and coord.y <= pos.y + ball.ball_size:
				return ball
				
	return null


func remove_checked():
	for key in area.keys():
		var ball = area[key]
		
		if ball.selected:
			var fx = get_node("fx").duplicate(1)
			fx.set_hidden(0)
			fx.set_as_toplevel(1)
			fx.set_pos(ball.get_pos())
			#fx.set_emit_timeout(2)
			fx.set_emitting(true)
			var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
			fx.set_color(colors[ball.color])
			fx.queue_free()
			add_child(fx)
			
			get_node("SamplePlayer2D").play("ball" + str(ball.color+1))
			
			area.erase(key)
			ball.queue_free()


func check_balls():
	var pipe = []
	var passed = {}

	var root = get_tree().get_root().get_node("root")

	for ball in root.area.values():
		ball.selected = 0
		ball.update()

	var ball = root.find_ball(get_global_mouse_pos())

	if ball:
		pipe.append(ball.get_pos())
		root.check_ball(pipe, ball.color, passed)
