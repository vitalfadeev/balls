extends KinematicBody2D

var color = 1
var selected = 0
const speed = 1000

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	#set_process_input(1)

func _fixed_process( delta ):
	var direction = Vector2(0, 0)
	move(Vector2(0, 1) * speed * delta)
	
func _draw():
	if selected:
		var tf = get_node("TextureFrame")
		tf.set_opacity(.3)
		#var tf = get_node("TextureFrame")
		#var ball_size = get_tree().get_root().get_node("root").ball_size
		#tf.draw_circle(Vector2(ball_size / 2, ball_size / 2), ball_size / 2, Color(1, 1, 1, .2))
	else:
		var tf = get_node("TextureFrame")
		tf.set_opacity(1)
		pass
