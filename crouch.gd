extends RigidBody2D

var stands: PackedScene
var sprite: Sprite2D

func _ready():
	stands = load("res://player.tscn")
	sprite = $"Sprite2D"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_left"):
		sprite.scale.x = -0.65
	elif Input.is_action_pressed("move_right"):
		sprite.scale.x = 0.65
	
	if Input.is_action_just_released("crouch"):
		var a = stands.instantiate()
		get_parent().add_child(a)
		get_parent().get_node("Player").position = position - Vector2(0, 25)
		queue_free()
