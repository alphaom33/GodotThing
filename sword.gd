extends Node2D

var timi: Timer
@export var countDown: float
var player: RigidBody2D
var playerGrounded
var playerSide: float
var playerOffset: Vector2
var m_rot: float
signal died

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	player.connect("ground", onGround)
	player.connect("newSword", get_side)
	timi = get_node("Timer")
	timi.start(countDown)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + Vector2(playerOffset.x * playerSide, playerOffset.y)
	rotation_degrees = m_rot
	print(playerGrounded)
	if timi.time_left <= 0 and playerGrounded:
		died.emit()
		queue_free()
		
func onGround(newGround):
	playerGrounded = newGround
	
func get_side(side, offset, rot):
	playerSide = side
	playerOffset = offset
	m_rot = rot
