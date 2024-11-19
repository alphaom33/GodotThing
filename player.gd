extends RigidBody2D

@export var horizonZeroSpeed = 2000
@export var negatSpeed = 13
@export var maxHorizonSpeed = 500

@export var skyMove = 2000
@export var maxAir = Vector2(300, 1000)
@export var airDrag = 1

@export var jump = 30000
@export var normalGrav = 1
var numJumps = 1
var isOnGround = false
signal ground(newGround);

var poinch: PackedScene
var offset = Vector2(50, 0)

@export var upSpecialForce = 70000
@export var specialGrav = 3
@export var sideSpecialForce = 100000
var sideAirSpecialForce = 50000
var sword: PackedScene
var swordOffJump = Vector2(50, 25)
var swordOffDash = Vector2(50, 0)
var swordOffDashAir = Vector2(50, 25)
signal newSword(sign, off, rot)
var inSpecial = false

var crouch: PackedScene

var sprite: Sprite2D

var disk: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	onGround()
	poinch = load("res://fist.tscn")
	crouch = load("res://crouch.tscn")
	sword = load("res://sword.tscn")
	disk = load("res://disk.tscn")
	sprite = $"Sprite2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	rotation = 0

	if isOnGround:
		groundMove()
	else:
		airMove()

	if not inSpecial:
		joinp()
		fisticuffs()
		doSpecials()

func onGround():
	var collision = $"Area2D"
	collision.connect("area_entered", go)
	collision.connect("area_exited", leave)

func go(area: Area2D):
	if area.is_in_group("ground"):
		numJumps = 2
		isOnGround = true
		ground.emit(isOnGround)
		gravity_scale = normalGrav

func leave(area):
	if area.is_in_group("ground"):
		numJumps = 1
		isOnGround = false
		ground.emit(isOnGround)
	elif (area.is_in_group("death")):
		kill()

func groundMove():
	if Input.is_action_pressed("move_left") and not inSpecial:
		apply_central_force(Vector2.LEFT * horizonZeroSpeed)
		sprite.scale.x = -0.65
	elif Input.is_action_pressed("move_right") and not inSpecial:
		apply_central_force(Vector2.RIGHT * horizonZeroSpeed)
		sprite.scale.x = 0.65
	else:
		apply_central_force(Vector2(-linear_velocity.x * negatSpeed, 0))
		
	var dir = clamp(sign(sprite.scale.x), 0, 1)
	linear_velocity.x = clamp(linear_velocity.x, (1 - dir) * -maxHorizonSpeed, dir * maxHorizonSpeed)
	
	if Input.is_action_pressed("crouch"):
		var newMe = crouch.instantiate()
		get_parent().add_child(newMe)
		get_parent().get_node("Crouch").position = position + Vector2(0, 25)
		queue_free()

func airMove():
	if Input.is_action_pressed("move_left") and linear_velocity.x > -maxAir.x:
		apply_central_force(Vector2.LEFT * skyMove)
	elif Input.is_action_pressed("move_right") and linear_velocity.x < maxAir.x:
		apply_central_force(Vector2.RIGHT * skyMove)
	else:
		apply_central_force(Vector2(-linear_velocity.x * airDrag, 0))

func joinp():
	if Input.is_action_just_pressed("jump") and (numJumps > 0):
		numJumps -= 1
		linear_velocity = Vector2(linear_velocity.x, clamp(linear_velocity.y, 0, float('inf')))
		apply_central_force(Vector2.UP * jump)

func fisticuffs():
	if (Input.is_action_just_pressed("faaaaalcon")):
		var yes = poinch.instantiate()
		get_parent().add_child(yes)
		get_parent().get_node("Fist").position = position + Vector2(offset.x * sign(sprite.scale.x), offset.y)

func doSpecials():
	if (Input.is_action_just_pressed("up_special")):
		inSpecial = true
		upSpecial()
	if (Input.is_action_just_pressed("right_special")):
		inSpecial = true
		sideSpecial(1)
	if (Input.is_action_just_pressed("left_special")):
		inSpecial = true
		sideSpecial(-1)
	if (Input.is_action_just_pressed("down_special")):
		downSpecial()

func upSpecial():
	linear_velocity = Vector2.ZERO
	var side = sign(sprite.scale.x)
	apply_central_force(Vector2.UP * upSpecialForce)
	gravity_scale = specialGrav
	var blade = sword.instantiate()
	get_parent().add_child(blade)
	newSword.emit(side, swordOffJump, 0)
	maxHorizonSpeed = 10000
	blade.connect("died", speedReset)

func sideSpecial(side):
	linear_velocity = Vector2.ZERO
	sprite.scale.x = 0.65 * side
	var blade = sword.instantiate()
	get_parent().add_child(blade)
	ground.emit(isOnGround)
	if (isOnGround):
		apply_central_force(Vector2.RIGHT * sideSpecialForce * side)
		newSword.emit(side, swordOffDash, 0)
		negatSpeed = 6
	else:
		apply_central_force(Vector2.RIGHT * sideAirSpecialForce * side)
		apply_central_force(Vector2.DOWN * sideAirSpecialForce)
		newSword.emit(side, swordOffDashAir, 45 if sprite.scale.x > 0 else -45)
	maxHorizonSpeed = 10000
	blade.connect("died", speedReset)

func downSpecial():
	if !get_parent().get_node("disk"):
		var ellipse = disk.instantiate()
		get_parent().add_child(ellipse)
	speedReset()

func speedReset():
	maxHorizonSpeed = 500
	inSpecial = false
	negatSpeed = 13

func kill():
	pass
