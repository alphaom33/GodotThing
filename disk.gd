extends RigidBody2D

@export var initial: float
@export var against: float
@export var maxSpeed: float
@export var up: float

var parent
var dir: float

var onScreen: VisibleOnScreenNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent().get_node("Player")
	position = parent.position
	dir = sign(parent.get_node("Sprite2D").scale.x)
	linear_velocity.x = dir * initial
	linear_velocity.y = up
	
	onScreen = $"VisibleOnScreenNotifier2D"

func exitedScreen():
	if sign(linear_velocity.x) != dir:
		queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	onScreen.screen_exited.connect(exitedScreen)
	
	add_constant_central_force(Vector2(against * -dir, 0))
	linear_velocity.x = clamp(linear_velocity.x, -maxSpeed, maxSpeed)

