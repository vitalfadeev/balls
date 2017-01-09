extends RigidBody2D

var color = 1
var selected = 0
var passed = 0

func _draw():
	if selected:
		var tf = get_node("Sprite")
		tf.set_opacity(.5)
		#var tf = get_node("TextureFrame")
		#var ball_size = get_tree().get_root().get_node("root").ball_size
		#tf.draw_circle(Vector2(ball_size / 2, ball_size / 2), ball_size / 2, Color(1, 1, 1, .2))
	else:
		var tf = get_node("Sprite")
		tf.set_opacity(.9)
		pass
