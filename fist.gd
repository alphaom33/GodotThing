extends Node2D

var timi: Timer
@export var time: float

func _ready():
	timi = get_node("Timer")
	#timi.connect("timeout", yes)
	timi.start(time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timi.time_left <= 0:
		queue_free()
